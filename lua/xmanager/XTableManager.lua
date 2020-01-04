XTableManager = XTableManager or {}

local pairs = pairs
local tonumber = tonumber
local tostring = tostring
local math = math
local mathFloor = math.floor
local string = string
local stringFind = string.find
local stringSub = string.sub
local stringGmatch = string.gmatch
local stringSplit = string.Split
local table = table 
local tableInsert = table.insert

local loadFileProfiler = XGame.Profiler:CreateChild("LoadTableFile")
local readTabFileProfiler = XGame.Profiler:CreateChild("ReadTabFile")

local DefaultOfType = {
    ["int"] = 0,
    ["float"] = 0.0,
    ["string"] = nil,
    ["bool"] = false,
    ["fix"] = fix.zero,
}

local ToInt = function (value)
    return mathFloor(value)
end

local ToFloat = function (value)
    return tonumber(value)
end

local ToString = function (value)
    return tostring(value)
end

local ToBool = function (value)
    return tonumber(value) ~= 0 and true or false
end

local ToFix = function(value)
    return FixParse(value)
end

local LIST_FLAG = 1
local DICTIONARY_FLAG = 2

local ValueFunc = {
    ["int"] = ToInt,
    ["float"] = ToFloat,
    ["string"] = ToString,
    ["bool"] = ToBool,
    ["fix"] = ToFix,
}

local KeyFunc = {
    ["int"] = ToInt,
    ["string"] = ToString,
}

local GetSingleValue = function(type, value)
    local func = ValueFunc[type]
    if not func then
        return
    end

    if not value or #value == 0 then
        return DefaultOfType[type]
    end

    return func(value)
end

local GetContainerValue = function(type, value)
    local func = ValueFunc[type]
    if not func then
        return
    end

    if not value or #value == 0 then
        return
    end

    return func(value)
end

local GetDictionaryKey = function(type, value)
    local func = KeyFunc[type]
    if not func then
        return
    end

    if not value or #value == 0 then
        return
    end

    return func(value)
end

local IsDictionary = function (paramConfig)
    return paramConfig.Type == DICTIONARY_FLAG
end

local IsList = function (paramConfig)
    return paramConfig.Type == LIST_FLAG
end

local IsTable = function(pramsConfig)
    return IsDictionary(pramsConfig) or IsList(pramsConfig)
end

local CreateColElems = function(tableConfig)
    local elems = {}
    for key, paramConfig in pairs(tableConfig) do
        if IsTable(paramConfig) then
            elems[key] = {}
        else
            elems[key] = DefaultOfType[paramConfig.ValueType]
        end
    end

    return elems
end

-- type func end--

local READ_KEY_TYPE =
{
    INT = 0,
    STRING = 1
}

local Split = function(str)
    local arr = {}
    for v in stringGmatch(str, '[^\t]*') do
        tableInsert(arr, v)
    end
    return arr
end

local ReadWithContext = function (context, tableConfig, keyType, identifier, path)
    local file = assert(context)
    local iter = stringSplit(file, "\r\n")
    local names = Split(iter[1])
    local keys = {}
    local cols = #names

    -- 表头解析和检查
    for i=1, cols do
        local name = names[i]
        local key
        local startIndex = stringFind(name, "[[]")
        if startIndex and startIndex > 0 then
            local endIndex = stringFind(name, "[]]")
            if startIndex ~= endIndex and endIndex == #name then
                key = stringSub(name, startIndex + 1, endIndex - 1)
                name = stringSub(name, 1, startIndex - 1)
                names[i] = name
            else
                XLog.Error("XTableManager.ReadTabFile error, format error, path = " .. path .. ", name = " .. name .. ", startIndex = " .. startIndex .. ", endIndex = " .. endIndex)
                return
            end
        end

        -- 检查属性是否有配置
        local paramConfig = tableConfig[name]
        if not paramConfig then
            goto continue
        end 

        -- 字典类型处理
        if IsDictionary(paramConfig) then
            if not key then
                XLog.Error("XTableManager.ReadTabFile error: read dictionary key is nil.path = " .. path .. ", name = " .. name)
                return 
            end
            
            local ret = GetDictionaryKey(paramConfig.KeyType, key)
            if not ret then
                XLog.Error("XTableManager.ReadTabFile error: key type nonsupport.path = " .. path .. ", name = " .. name .. ", type = " .. paramConfig.KeyType .. ", key = " .. key)
                return
            end

            keys[i] = ret
        end

        ::continue::
    end

    local tab = {}
    
    local index = 1
    local lineCount = #iter
    for i = 2, lineCount do
        local line = iter[i]
        if not line or #line == 0 then
            goto nextLine
        end

        local elems = CreateColElems(tableConfig)
        local tmpElems = Split(line)

        if #tmpElems ~= cols then
            XLog.Warning("XTableManager.ReadTabFile warning: cols not match, path = " .. path .. ", row = " .. index .. ", cols = " .. cols .. ", cells length = " .. #tmpElems)
        end

        for i = 1, cols do
            local name = names[i]
            local value = tmpElems[i]
            local paramConfig = tableConfig[name]
        
            if not paramConfig then
                goto continue
            end

            if IsList(paramConfig) then   -- 数组
                value = GetContainerValue(paramConfig.ValueType, value)
                if value then
                    tableInsert(elems[name], value)
                end
            elseif IsDictionary(paramConfig) then     -- 字典
                value = GetContainerValue(paramConfig.ValueType, value)
                if value then
                    local key = keys[i]
                    elems[name][key] = value
                end
            else
                elems[name] = GetSingleValue(paramConfig.ValueType, value)
            end

            ::continue::
        end

        if identifier then
            local id = keyType == READ_KEY_TYPE.STRING and tostring(elems[identifier]) or mathFloor(elems[identifier])
            tab[id] = elems
        else
            tab[index] = elems
        end

        index = index + 1

        ::nextLine::
    end

    return tab
end

local ReadTabFile = function (path, tableConfig, keyType, identifier)
    loadFileProfiler:Start()
    local context = CS.XTableManager.Load(path)
    loadFileProfiler:Stop()
    
    readTabFileProfiler:Start()
    local content = ReadWithContext(context, tableConfig, keyType, identifier, path)
    readTabFileProfiler:Stop()
    return content
end

function XTableManager.ReadByIntKeyWithContent(context, xtable, identifier)
    return ReadWithContext(context, xtable, READ_KEY_TYPE.INT, identifier, "unknown")
end

function XTableManager.ReadByStringKeyWithContent(context, xtable, identifier)
    return ReadWithContext(context, xtable, READ_KEY_TYPE.STRING, identifier, "unknown")
end

function XTableManager.ReadByIntKey(path, xtable, identifier)
    if path == nil or #path == 0 then
        XLog.Error("XTableManager ReadByIntKey error, path is null or empty, xtable: ".. xtable)
        return
    end

    if xtable == nil then
        XLog.Error("XTableManager ReadByIntKey error, xtable is null, path: " .. path)
        return
    end

    if string.EndsWith(path, ".tab") then
        return XReadOnlyTable.Create(ReadTabFile(path, xtable, READ_KEY_TYPE.INT, identifier))
    end

    local paths = CS.XTableManager.GetPaths(path)
    local mergeTable = {}

    XTool.LoopCollection(paths, function (path)
        local t = ReadTabFile(path, xtable, READ_KEY_TYPE.INT, identifier)
        for k, v in pairs(t) do
            if mergeTable[k] then
                XLog.Error("XTableManager ReadByIntKey error, key repeat, path: " .. path .. ", identifier: " .. identifier .. ", key: " .. k)
                return
            end
            mergeTable[k] = v
        end
    end)

    return XReadOnlyTable.Create(mergeTable)
end

function XTableManager.ReadByStringKey(path, xtable, identifier)
    if path == nil or #path == 0 then
        XLog.Error("XTableManager ReadByStringKey error, path is null or empty, xtable: " .. xtable)
        return
    end

    if xtable == nil then
        XLog.Error("XTableManager ReadByStringKey error, xtable is null, path: " .. path)
        return
    end

    if identifier == nil or #identifier == 0 then
        XLog.Error("XTableManager ReadByStringKey error, identifier is null or empty, path: " .. path .. ", xtable: ", xtable)
        return
    end

    if string.EndsWith(path, ".tab") then
        return XReadOnlyTable.Create(ReadTabFile(path, xtable, READ_KEY_TYPE.STRING, identifier))
    end

    local paths = CS.XTableManager.GetPaths(path)
    local mergeTable = {}

    XTool.LoopCollection(paths, function(path)
        local t = ReadTabFile(path, xtable, READ_KEY_TYPE.STRING, identifier)
        for k, v in pairs(t) do
            if mergeTable[k] then
                XLog.Error("XTableManager ReadByStringKey error, key repeat, path: " .. path .. ", identifier: " .. identifier .. ", key: " .. k)
                return
            end
            mergeTable[k] = v
        end
    end)

    return XReadOnlyTable.Create(mergeTable) 
end