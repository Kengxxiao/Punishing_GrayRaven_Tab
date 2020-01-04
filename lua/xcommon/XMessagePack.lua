local type = type
local pairs = pairs
local pcall = pcall
local select = select
local table = table
local string = string
local math = math
local utf8 = utf8

local tableConcat = table.concat
local tableInsert = table.insert
local tableUnpack = table.unpack
local stringPack = string.pack
local stringUnpack = string.unpack
local stringFormat = string.format
local mathType = math.type
local utf8Len = utf8.len

local decoderTable

local function Unpack(context, format)
    local value, position = stringUnpack(format, context.input, context.position)
    context.position = position
    return value
end

local function DecodeNext(context)
    return decoderTable[Unpack(context, ">B")](context)
end

local function DecodeArray(context, length)
    local array = {}
    for i = 1, length do
        array[i] = DecodeNext(context)
    end
    return array
end

local function DecodeMap(context, length)
    local map = {}
    for i = 1, length do
        local k = DecodeNext(context)
        local v = DecodeNext(context)
        map[k] = v
    end
    return map
end

decoderTable = {
    [192] = function() return nil end,
    [194] = function() return false end,
    [195] = function() return true end,
    [196] = function(context) return Unpack(context, ">s1") end,
    [197] = function(context) return Unpack(context, ">s2") end,
    [198] = function(context) return Unpack(context, ">s4") end,
    [202] = function(context) return Unpack(context, ">f") end,
    [203] = function(context) return Unpack(context, ">d") end,
    [204] = function(context) return Unpack(context, ">I1") end,
    [205] = function(context) return Unpack(context, ">I2") end,
    [206] = function(context) return Unpack(context, ">I4") end,
    [207] = function(context) return Unpack(context, ">I8") end,
    [208] = function(context) return Unpack(context, ">i1") end,
    [209] = function(context) return Unpack(context, ">i2") end,
    [210] = function(context) return Unpack(context, ">i4") end,
    [211] = function(context) return Unpack(context, ">i8") end,
    [217] = function(context) return Unpack(context, ">s1") end,
    [218] = function(context) return Unpack(context, ">s2") end,
    [219] = function(context) return Unpack(context, ">s4") end,
    [220] = function(context) return DecodeArray(context, Unpack(context, ">I2")) end,
    [221] = function(context) return DecodeArray(context, Unpack(context, ">I4")) end,
    [222] = function(context) return DecodeMap(context, Unpack(context, ">I2")) end,
    [223] = function(context) return DecodeMap(context, Unpack(context, ">I4")) end,
}

-- add single byte integers
for i = 0, 127 do
    decoderTable[i] = function() return i end
end
for i = 224, 255 do
    decoderTable[i] = function() return -32 + i - 224 end
end

-- add fixed maps
for i = 128, 143 do
    decoderTable[i] = function(context) return DecodeMap(context, i - 128) end
end

-- add fixed arrays
for i = 144, 159 do
    decoderTable[i] = function(context) return DecodeArray(context, i - 144) end
end

-- add fixed strings
for i = 160, 191 do
    local format = stringFormat(">c%d", i - 160)
    decoderTable[i] = function(context) return Unpack(context, format) end
end

local encoderTable

local function EncodeValue(value)
    return encoderTable[type(value)](value)
end

local function CheckArray(value) -- simple function to verify a table is a proper array
    local count = 0
    for k in pairs(value) do
        if type(k) ~= "number" then
            return false
        else
            count = count + 1
        end
    end
    for i = 1, count do
        if not value[i] and type(value[i]) ~= "nil" then
            return false
        end
    end
    return true
end

encoderTable = {
    ["nil"] = function()
        return stringPack(">B", 192)
    end,

    ["boolean"] = function(value)
        return stringPack(">B", value and 195 or 194)
    end,

    ["string"] = function(value)
        local length = #value
        if utf8Len(value) then -- valid UTF-8 ... encode as string
            if length < 32 then
                return stringPack(">B", 160 + length) .. value
            elseif length <= 255 then
                return stringPack(">B s1", 217, value)
            elseif length <= 65535 then
                return stringPack(">B s2", 218, value)
            else
                return stringPack(">B s4", 219, value)
            end
        else -- encode as binary
            if length <= 255 then
                return stringPack(">B s1", 196, value)
            elseif length <= 65535 then
                return stringPack(">B s2", 197, value)
            else
                return stringPack(">B s4", 198, value)
            end
        end
    end,

    ["number"] = function(value)
        if mathType(value) == "integer" then
            if value >= 0 then
                if value <= 127 then
                    return stringPack(">B", value)
                elseif value <= 255 then
                    return stringPack(">B I1", 204, value)
                elseif value <= 65535 then
                    return stringPack(">B I2", 205, value)
                elseif value <= 4294967295 then
                    return stringPack(">B I4", 206, value)
                else
                    return stringPack(">B I8", 207, value)
                end
            else
                if value >= -32 then
                    return stringPack(">B", 224 + value + 32)
                elseif value >= -127 then
                    return stringPack(">B i1", 208, value)
                elseif value >= -32767 then
                    return stringPack(">B i2", 209, value)
                elseif value >= -2147483647 then
                    return stringPack(">B i4", 210, value)
                else
                    return stringPack(">B i8", 211, value)
                end
            end
        else
            local converted = stringUnpack(">f", stringPack(">f", value))
            if converted == value then
                return stringPack(">B f", 202, value)
            else
                return stringPack(">B d", 203, value)
            end
        end
    end,

    ["table"] = function(value)
        local meta = getmetatable(value)
        if CheckArray(value) and (meta == nil or not meta.IsTable) then
            local elements = {}
            for i, v in pairs(value) do
                elements[i] = EncodeValue(v)
            end

            local length = #elements
            if length == 0 then
                return stringPack(">B", 192)
            end

            if length <= 15 then
                return stringPack(">B", 144 + length) .. tableConcat(elements)
            elseif length <= 65535 then
                return stringPack(">B I2", 220, length) .. tableConcat(elements)
            else
                return stringPack(">B I4", 221, length) .. tableConcat(elements)
            end
        else
            local elements = {}
            for k, v in pairs(value) do
                elements[#elements + 1] = EncodeValue(k)
                elements[#elements + 1] = EncodeValue(v)
            end

            local length = #elements // 2
            if length == 0 then
                return stringPack(">B", 192)
            end

            if length <= 15 then
                return stringPack(">B", 128 + length) .. tableConcat(elements)
            elseif length <= 65535 then
                return stringPack(">B I2", 222, length) .. tableConcat(elements)
            else
                return stringPack(">B I4", 223, length) .. tableConcat(elements)
            end
        end
    end,
}

XMessagePack = XMessagePack or {}

function XMessagePack.Encode(value)
    local ok, result = pcall(EncodeValue, value)
    if ok then
        return result
    else
        return nil, stringFormat("XMessagePack cannot encode type %s", type(value))
    end
end

function XMessagePack.EncodeAll(...)
    local result = {}
    for i = 1, select("#", ...) do
        local data, error = XMessagePack.Encode(select(i, ...))
        if data then
            tableInsert(result, data)
        else
            return nil, error
        end
    end
    return tableConcat(result)
end

function XMessagePack.Decode(input, position)
    local context = { input = input, position = position or 1 }
    local ok, result = pcall(DecodeNext, context)
    if ok then
        return result, context.position
    else
        return nil, stringFormat("XMessagePack cannot decode position %d", context.position)
    end
end

function XMessagePack.DecodeAll(input, position)
    local context = { input = input, position = position or 1 }
    local result = {}
    while context.position <= #context.input do
        local ok, value = pcall(DecodeNext, context)
        if ok then
            tableInsert(result, value)
        else
            return nil, stringFormat("XMessagePack cannot decode position %d", context.position)
        end
    end
    return tableUnpack(result)
end

function XMessagePack.MarkAsTable(value)
    if value == nil then
        XLog.Error("XMessagePack MarkAsTable error, value is nil")
        return
    end
    if type(value) ~= "table" then
        XLog.Error("XMessagePack MarkAsTable error, value not table")
        return
    end
    setmetatable(value, {IsTable = true})
end
