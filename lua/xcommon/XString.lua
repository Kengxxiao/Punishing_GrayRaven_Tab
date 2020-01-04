--==============================--
-- 字符串相关扩展方法
--==============================--
local tonumber = tonumber
local next = next
local pairs = pairs
local string = string 
local table = table
local math = math

local stringLen = string.len
local stringByte = string.byte
local stringSub = string.sub
local stringGsub = string.gsub
local stringFind = string.find
local stringMatch = string.match
local tableInsert = table.insert
local mathFloor = math.floor

--==============================--
--desc: 通过utf8获取字符串长度
--@str: 字符串
--@return 字符串长度
--==============================--
function string.Utf8Len(str)
    local len = stringLen(str)
    local left = len
    local cnt = 0
    local arr = { 0, 192, 224, 240, 248, 252 }
    while left ~= 0 do
        local tmp = stringByte(str, -left)
        local i = #arr
        while arr[i] do
            if tmp >= arr[i] then
                left = left - i
                break
            end
            i = i - 1
        end
        cnt = cnt + 1
    end
    return cnt
end

--==============================--
--desc: 通过utf8获取单个字符长度
--@str: 单个字符
--@return 字符串长度
--==============================--
function string.Utf8Size(char)
    if not char then
        return 0
    elseif char >= 252 then
        return 6
    elseif char >= 248 then
        return 5
    elseif char >= 240 then
        return 4
    elseif char >= 225 then
        return 3
    elseif char >= 192 then
        return 2
    else
        return 1
    end
end

--==============================--
--desc: 按utf8长度截取字符串
--@str: 字符串
--@return 字符串
--==============================--
function string.Utf8Sub(str, startChar, numChars)
    local startIndex = 1
    while startChar > 1 do
        local char = stringByte(str, startIndex)
        startIndex = startIndex + string.Utf8Size(char)
        startChar = startChar - 1
    end

    local currentIndex = startIndex
    while numChars > 0 and currentIndex <= #str do
        local char = stringByte(str, currentIndex)
        currentIndex = currentIndex + string.Utf8Size(char)
        numChars = numChars -1
    end
    return str:sub(startIndex, currentIndex - 1)
end

--==============================--
--desc: 将字符串分割成char table
--@str: 字符串
--@return char table
--==============================--
function string.SplitWordsToCharTab(str)
    local len = stringLen(str)
    local left = len
    local chartab = {}
    local arr = { 0, 192, 224, 240, 248, 252 }
    while left ~= 0 do
        local tmp = stringByte(str, -left)
        local i = #arr
        local value = left

        while arr[i] do
            if tmp >= arr[i] then
                left = left - i
                break
            end
            i = i - 1
        end

        local char = stringSub(str, -value, -left - 1)
        if stringSub(str, -left, -left + 1) == "\\n" then
            left = left - 2
            char = char .. "\n"
        end
        tableInsert(chartab, char)
    end
    return chartab
end

--==============================--
--desc: 把有富文本格式的字符串变成char table
--@str: 富文本字符串
--@return char table
--==============================--
function string.CharsConvertToCharTab(str)
    --str = "我只是用来{<color=#00ffffff><size=40>测一测</size></color>}别xiabibi{<size=25><color=#ff0000ff>红色试一试</color></size>}试玩啦"--
    local leftindexs = {}
    local rightindexs = {}
    local startpos = 1
    while true do
        local pos = stringFind(str, "{", startpos)

        if not pos then
            break
        end

        tableInsert(leftindexs, pos)
        pos = stringFind(str, "}", pos + 1)
        if not pos then
            break
        end

        tableInsert(rightindexs, pos)
        startpos = pos + 1
    end

    local words = {}
    if #leftindexs > 0 then
        startpos = 1
        for i = 1, #leftindexs do
            tableInsert(words, stringSub(str, startpos, leftindexs[i] - 1))
            tableInsert(words, stringSub(str, leftindexs[i] + 1, rightindexs[i] - 1))
            startpos = rightindexs[i] + 1
        end

        if rightindexs[#rightindexs] ~= stringLen(str) then
            tableInsert(words, stringSub(str, startpos))
        end
    else
        tableInsert(words, str)
    end

    local result = {}
    for i = 1, #words do
        local tab
        local IsRichText = false
        local format = ""

        if stringSub(words[i], 1, 1) == "<" then
            IsRichText = true
            local pa = stringMatch(words[i], "%b></")
            pa = stringMatch(pa, ">(.*)<")
            format = stringGsub(words[i], "%b></", ">#$#</", 1)
            tab = string.SplitWordsToCharTab(pa)
        else
            IsRichText = false
            format = ""
            tab = string.SplitWordsToCharTab(words[i])
        end

        for j = 1, #tab do
            if IsRichText then
                local char = stringGsub(format, "#$#", tab[j])
                tableInsert(result, char)
            else
                tableInsert(result, tab[j])
            end
        end
    end
    return result
end

--==============================--
--desc: 检查字符串的开头是否与指定字符串匹配
--@str: 需要检查的字符串
--@value: 指定的字符串
--@return true：匹配，false：不匹配
--==============================--
function string.StartsWith(str, value)
    return stringSub(str, 1, stringLen(value)) == value
end

--==============================--
--desc: 检查字符串的结尾是否与指定字符串匹配
--@str: 需要检查的字符串
--@value: 指定的字符串
--@return true：匹配，false：不匹配
--==============================--
function string.EndsWith(str, value)
    return value == "" or stringSub(str, -stringLen(value)) == value
end

--==============================--
--desc: 字符串分割
--@str: 原字符串
--@separator: 分割符
--@return 字符串数组
--==============================--
function string.Split(str, separator)
    if str == nil or str == "" then
        return {}
    end

    if not separator then
        separator = "|"
    end

    local result = {}
    local startPos = 1
    while true do
        local endPos = str:find(separator, startPos)
        if endPos == nil then
            break
        end

        local elem = str:sub(startPos, endPos - 1)
        tableInsert(result, elem)
        startPos = endPos + #separator
    end

    tableInsert(result, str:sub(startPos))
    return result
end

--==============================--
--desc: 将字符串分割成int数组
--@str: 原字符串
--@separator: 分割符
--@return int数组
--==============================--
function string.ToIntArray(str, separator)
    local strs = string.Split(str, separator)
    local array = {}
    if next(strs) then
        for _, v in pairs(strs) do
            tableInsert(array, mathFloor(tonumber(v)))
        end
    end
    return array
end

--==============================--
--desc: 从一个字符串中查找另一个字符串的第一次匹配的索引
--@str: 原字符串
--@separator: 需要匹配的字符串
--@return 索引号
--==============================--
function string.IndexOf(str, separator)
    if not str or str == "" or not separator or separator == "" then
        return -1
    end
    for i = 1, #str do
        local success = true
        for s = 1, #separator do
            local strChar = stringByte(str, i + s - 1)
            local sepChar = stringByte(separator, s)
            if strChar ~= sepChar then
                success = false
                break
            end
        end
        if success then
            return i
        end
    end
    return -1
end

--==============================--
--desc: 从一个字符串中查找另一个字符串的最后一次匹配的索引
--@str: 原字符串
--@separator: 需要匹配的字符串
--@return 索引号
--==============================--
function string.LastIndexOf(str, separator)
    if not str or str == "" or not separator or separator == "" then
        return -1
    end
    local strLen = #str
    local sepLen = #separator
    for i = 0, strLen - 1 do
        local success = true
        for s = 0, sepLen - 1 do
            local strChar = stringByte(str, strLen - i - s)
            local sepChar = stringByte(separator, sepLen - s)
            if strChar ~= sepChar then
                success = false
                break
            end
        end
        if success then
            return strLen - i - sepLen + 1
        end
    end
    return -1
end

--==============================--
--desc: 判断字符串是否为nil或者为空
--@str: 字符串对象
--@return 如果为nil或者为空，返回true，否则返回fale
--==============================--
function string.IsNilOrEmpty(str)
    return str == nil or #str == 0
end

--==============================--
--desc: 过滤utf文本特殊屏蔽字干扰字符
--@str: 字符串对象
--@return 过滤后文本
--==============================--
local FilterSymbols = [[·~！@#￥%……&*（）-=——+【】｛｝、|；‘’：“”，。、《》？[]{}""'';:./?,<>\|-_=+*()!@#$%^&*~` ]]
local FilterSymbolsTable = FilterSymbols:SplitWordsToCharTab()
function string.FilterWords(str)
    local result = ""
    for i = 1, string.Utf8Len(str) do
        local nowStr = string.Utf8Sub(str, i, 1)
        local isValid = true
        for k, v in pairs(FilterSymbolsTable) do
            if nowStr == v then
                isValid = false
                break
            end
        end
        if isValid then
            result = result .. nowStr
        end
    end

    return result
end


