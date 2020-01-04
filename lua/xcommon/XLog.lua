XLog = XLog or {}

local MAX_DEPTH = 5

local Type = type
local Tostring = tostring
local Pairs = pairs
local Ipairs = ipairs
local TableRemove = table.remove
local TableInsert = table.insert
local TableConcat = table.concat
local StringGub = string.gsub
local DebugTraceback = debug.traceback
local XLogDebug = CS.XLog.Debug
local XLogWarning = CS.XLog.Warning
local XLogError = CS.XLog.Error

local indentCache = { "" }
local function GetIndent (depth)
    if not indentCache[depth] then
        indentCache[depth] = GetIndent(depth - 1) .. "    "
    end
    return indentCache[depth]
end

local function Dump (target)
    local content = {}
    local stack = {
        {
            obj = target,
            name = nil,
            depth = 1,
            symbol = nil,
        }
    }

    while #stack > 0 do
        local top = TableRemove(stack)
        local obj = top.obj
        local name = top.name
        local depth = top.depth
        local symbol = top.symbol

        if Type(obj) == "table" then
            if depth > MAX_DEPTH then
                TableInsert(stack, {
                    obj = "too depth ...",
                    name = name,
                    depth = depth,
                    symbol = symbol,
                })
            else
                TableInsert(stack, {
                    obj = "}",
                    name = nil,
                    depth = depth,
                    symbol = symbol,
                })

                local temp = {}
                for k, v in Pairs(obj) do
                    TableInsert(temp, {
                        obj = v,
                        name = k,
                        depth = depth + 1,
                        symbol = ",",
                    })
                end

                local count = #temp
                for i = 1, count do
                    TableInsert(stack, temp[count - i + 1])
                end

                TableInsert(stack, {
                    obj = "{",
                    name = name,
                    depth = depth,
                    symbol = nil,
                })
            end
        else
            TableInsert(content, GetIndent(depth))

            if name then
                if Type(name) == "string" then
                    TableInsert(content, "\"")
                    TableInsert(content, name)
                    TableInsert(content, "\"")
                else
                    TableInsert(content, Tostring(name))
                end

                TableInsert(content, " = ")
            end

            if obj and Type(obj) == "string" then
                if obj ~= "{" and obj ~= "}" then
                    TableInsert(content, "\"")
                    TableInsert(content, obj)
                    TableInsert(content, "\"")
                else
                    TableInsert(content, obj)
                end
            else
                TableInsert(content, Tostring(obj))
            end

            if symbol then
                TableInsert(content, symbol)
            end

            TableInsert(content, "\n")
        end
    end

    return TableConcat(content)
end

local Print = function(...)
    local args = { ... }
    local count = #args
    
    if count <= 0 then
        return
    end

    local content = {}
    for i = 1, count do
        if Type(args[i]) == "table" then
            TableInsert(content, Dump(args[i]))
        else
            TableInsert(content, Tostring(args[i]))
            TableInsert(content, "\n")
        end
    end

    return StringGub(StringGub(TableConcat(content), "{", "{{"), "}", "}}")
end

XLog.Debug = function(...)
    local content = Print(...)
    if content then
        XLogDebug(content .. "\n" .. DebugTraceback())
    else
        XLogDebug("nil\n" .. DebugTraceback())
    end
end

XLog.Warning = function(...)
    local content = Print(...)
    if content then
        XLogWarning(content .. "\n" .. DebugTraceback())
    else
        XLogWarning("nil\n" .. DebugTraceback())
    end
end

XLog.Error = function(...)
    local content = Print(...)
    if content then
        XLogError(content .. "\n" .. DebugTraceback())
    else
        XLogError("nil\n" .. DebugTraceback())
    end
end
