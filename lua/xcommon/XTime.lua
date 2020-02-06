XTime = XTime or {}

local floor = math.floor
local realtimeSinceStartup = function() return CS.UnityEngine.Time.realtimeSinceStartup end

local ServerTimeWhenStartupList = {}    --客户端启动时，服务器的时间戳
local ServerTimeMaxCount = 10           --保存服务端时间的最大个数
local CurrentSaveIndex = 1              --当前保存到的下标
local ServerTimeWhenStartupAverage = 0  --客户端启动时，服务器的时间戳平局值

-- 一星期中的第几天	(3)[1 - 6 = 星期天 - 星期六]
local WeekOfDay = {
    Sun = 0,
    Mon = 1,
    Tues = 2,
    Wed = 3,
    Thur = 4,
    Fri = 5,
    Sat = 6,
}

local WeekOfDayIndex = {
    [WeekOfDay.Mon] = 1,
    [WeekOfDay.Tues] = 2,
    [WeekOfDay.Wed] = 3,
    [WeekOfDay.Thur] = 4,
    [WeekOfDay.Fri] = 5,
    [WeekOfDay.Sat] = 6,
    [WeekOfDay.Sun] = 7,
}
local WeekLength = 7
local sec_of_a_day = 24 * 60 * 60
local sec_of_refresh_time = 5 * 60 * 60

--==============================--
--desc: 获取服务器当前时间戳
--@return 长整型时间戳，单位（秒）
--==============================--
function XTime.GetServerNowTimestamp()
    local sinceStartup = realtimeSinceStartup()
    return floor(ServerTimeWhenStartupAverage + sinceStartup)
end

--==============================--
--desc: 同步时间
--@serverTime: 服务器时间
--@reqTime: 发起请求时间
--@resTime: 收到响应时间
--==============================--
function XTime.SyncTime(serverTime, reqTime, resTime)
    local startup = (reqTime + resTime) * 0.5
    local span = serverTime - startup

    if CurrentSaveIndex > ServerTimeMaxCount then
        CurrentSaveIndex = CurrentSaveIndex - ServerTimeMaxCount
    end
    ServerTimeWhenStartupList[CurrentSaveIndex] = span
    CurrentSaveIndex = CurrentSaveIndex + 1

    local count = #ServerTimeWhenStartupList
    local total = 0
    for _, v in ipairs(ServerTimeWhenStartupList) do
        total = total + v
    end
    ServerTimeWhenStartupAverage = total / count
end

--==============================--
--desc: 时间字符串转时间戳
--@dateTimeString: 时间字符串
--@return 转失败返回nil
--==============================--
function XTime.ParseToTimestamp(dateTimeString)
    if dateTimeString == nil or dateTimeString == "" then
        return
    end

    local success, timestamp = CS.XDateUtil.TryParseToTimestamp(dateTimeString)
    if not success then
        XLog.Error("XTime.TryParseToTimestamp parse to timestamp failed. invalid time argument: " .. tostring(dateTimeString))
        return
    end

    return timestamp
end

--时间戳转utc时间字符串
function XTime.TimestampToUtcDateTimeString(timestamp, format)
    format = format or "yyyy-MM-dd HH:mm:ss"
    local dt = CS.XDateUtil.GetUtcDateTime(timestamp)
    return dt:ToString(format)
end

--时间戳转设备本地时间字符串
function XTime.TimestampToLocalDateTimeString(timestamp, format)
    format = format or "yyyy-MM-dd HH:mm:ss"
    local dt = CS.XDateUtil.GetLocalDateTime(timestamp)
    return dt:ToString(format)
end

--时间戳转游戏指定时区时间字符串
function XTime.TimestampToGameDateTimeString(timestamp, format)
    format = format or "yyyy-MM-dd HH:mm:ss"
    local dt = CS.XDateUtil.GetGameDateTime(timestamp)
    return dt:ToString(format)
end

-- c#星期枚举转整形数
function XTime.DayOfWeekToInt(dayOfWeek)
    if dayOfWeek == CS.System.DayOfWeek.Sunday then
        return 0
    elseif dayOfWeek == CS.System.DayOfWeek.Monday then
        return 1
    elseif dayOfWeek == CS.System.DayOfWeek.Tuesday then
        return 2
    elseif dayOfWeek == CS.System.DayOfWeek.Wednesday then
        return 3
    elseif dayOfWeek == CS.System.DayOfWeek.Thursday then
        return 4
    elseif dayOfWeek == CS.System.DayOfWeek.Friday then
        return 5
    else
        return 6
    end
end

--获取今天时间
function XTime.GetTodayTime(hour, min, sec)
    hour = hour or 0
    min = min or 0
    sec = sec or 0
    local nowTime = XTime.GetServerNowTimestamp()
    local dt = CS.XDateUtil.GetGameDateTime(nowTime)
    dt = dt.Date;
    dt:AddSeconds(sec)
    dt:AddMinutes(min)
    dt:AddHours(hour)
    return dt:ToTimestamp()
end

-- 获取距离下一个星期x的时间,默认每周第一天为周一
function XTime.GetNextWeekOfDayStartWithMon(weekOfDay, offsetTime)
    local needTime = 0
    local nowTime = XTime.GetServerNowTimestamp()
    local dateTime = CS.XDateUtil.GetGameDateTime(nowTime)
    local weekZero = CS.XDateUtil.GetFirstDayOfThisWeek(dateTime):ToTimestamp()

    local resetTime = (WeekOfDayIndex[weekOfDay] - 1) * sec_of_a_day + offsetTime + weekZero
    if nowTime < resetTime then
        needTime = resetTime - nowTime
    else
        needTime = WeekLength * sec_of_a_day - (nowTime - resetTime)
    end

    return needTime
end

-- 获取服务器当天5点更新时间戳
function XTime.GetSeverTodayFreshTime()
    local now = XTime.GetServerNowTimestamp()
    local dateTime = CS.XDateUtil.GetGameDateTime(now)
    local dayZero = dateTime.Date:ToTimestamp()

    return dayZero + sec_of_refresh_time
end

-- 获取服务器昨天5点更新时间戳
function XTime.GetSeverYesterdayFreshTime()
    local dayFreshTime = XTime.GetSeverTodayFreshTime()
    return dayFreshTime - sec_of_a_day
end
