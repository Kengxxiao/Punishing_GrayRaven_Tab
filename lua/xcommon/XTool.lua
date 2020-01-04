local table = table
local string = string
local math = math

local tableInsert = table.insert
local stringMatch = string.match
local mathModf = math.modf

XTool = XTool or {}

XTool.UObjIsNil = function(uobj)
    return uobj == nil or not uobj:Exist()
end

XTool.LoopMap = function(map, func)
    if type(map) == "userdata" then
        if not map then
            return
        end

        local e = map:GetEnumerator()
        while e:MoveNext() do
            func(e.Current.Key, e.Current.Value)
        end
        e:Dispose()
    elseif type(map) == "table" then
        for key, value in pairs(map) do
            func(key, value)
        end
    end
end

XTool.LoopCollection = function(collection, func)
    if type(collection) == "table" then
        for key, value in pairs(collection) do
            func(value)
        end
    elseif type(collection) == "userdata" then
        for i = 0, collection.Count - 1 do
            func(collection[i])
        end
    end
end

XTool.LoopArray = function(collection, func)
    for i = 0, collection.Length - 1 do
        func(collection[i])
    end
end

XTool.CsList2LuaTable = function(collection)
    local ret = {}
    for i = 0, collection.Count - 1 do
        tableInsert(ret, collection[i])
    end
    return ret
end

XTool.CsMap2LuaTable = function(map)
    local ret = {}
    local e = map:GetEnumerator()
    while e:MoveNext() do
        ret[e.Current.Key] = e.Current.Value
    end
    e:Dispose()
    return ret
end

XTool.Clone = function(t)
    if type(t) ~= "table" then
        return t
    end
    local target = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            target[k] = XTool.Clone(v)
        else
            target[k] = v
        end
    end
    local meta = getmetatable(t)
    if type(meta) == "table" then
        setmetatable(target, meta)
    end
    return target
end

XTool.GetFileNameWithoutExtension = function(path)
    return stringMatch(path, "[./]*([^/]*)%.%w+")
end

XTool.GetFileName = function(path)
    return stringMatch(path, "[./]*([^/]*%.%w+)")
end

XTool.GetExtension = function(path)
    return stringMatch(path, "[./]*(%.%w+)")
end

XTool.GetTableCount = function(list)
    if type(list) ~= "table" then
        XLog.Error("  XTool.GetTableCount error : list is not a table")
        return
    end

    local count = 0
    for k, v in pairs(list) do
        count = count + 1
    end

    return count
end

local NumberText = {
    [0] = "",
    [1] = CS.XTextManager.GetText("One"),
    [2] = CS.XTextManager.GetText("Two"),
    [3] = CS.XTextManager.GetText("Three"),
    [4] = CS.XTextManager.GetText("Four"),
    [5] = CS.XTextManager.GetText("Five"),
    [6] = CS.XTextManager.GetText("Six"),
    [7] = CS.XTextManager.GetText("Seven"),
    [8] = CS.XTextManager.GetText("Eight"),
    [9] = CS.XTextManager.GetText("Nine"),
}

XTool.ParseNumberString = function(num)
    return NumberText[mathModf(num / 10)] .. NumberText[num % 10]
end


XTool.MatchEmoji = function(text)
    return stringMatch(text, '%[%d%d%d%d%d%]')
end

XTool.CopyToClipboard = function(text)
    CS.XAppPlatBridge.CopyStringToClipboard(tostring(text))
    XUiManager.TipText("Clipboard", XUiManager.UiTipType.Tip)
end

XTool.ToArray = function(t)
    local array = {}
    for k, v in pairs(t) do
        table.insert(array, v)
    end
    return array
end

XTool.MergeArray = function(...)
    local res = {}
    for _, t in pairs({ ... }) do
        if type(t) == "table" then
            for _, v in pairs(t) do
                table.insert(res, v)
            end
        end
    end
    return res
end

function XTool.ReverseList(list)
    local reverse = {}
    if not list or not next(list) then return reverse end

    for i = 1, #list do
        reverse[i] = table.remove(list, #list)
    end

    return reverse
end

XTool.Waterfall = function(cbList)
    local last
    for i = #cbList, 1, -1 do
        if type(cbList[i]) == "function" then
            local nextCb = last
            local cb = function()
                cbList[i](nextCb)
            end
            last = cb
        else
            XLog.Error("XTool.Waterfall error, unit is not function")
        end
    end
    if last then
        last()
    end
end

XTool.InitUiObject = function(targetObj) 
    targetObj.Obj = targetObj.Transform:GetComponent("UiObject")
    if targetObj.Obj ~= nil then
        for i = 0, targetObj.Obj.NameList.Count - 1 do
            targetObj[targetObj.Obj.NameList[i]] = targetObj.Obj.ObjList[i]
        end
    end 
end