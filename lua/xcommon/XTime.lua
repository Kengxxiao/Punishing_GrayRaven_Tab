XTime = XTime or {}

local time = os.time
local floor = math.floor

local clientTimeDifference = 0          -- 客户端与服务端时间差

-- 一星期中的第几天	(3)[1 - 6 = 星期天 - 星期六]
local WeekOfDay = {
    Sun = 1,
    Mon = 2,
    Tues = 3,
    Wed = 4,
    Thur = 5,
    Fri = 6,
    Sat = 7,
}

local WeekOfDayIndex = {
   [WeekOfDay.Sun] = 7,
   [WeekOfDay.Mon] = 1,
   [WeekOfDay.Tues] = 2,
   [WeekOfDay.Wed] = 3,
   [WeekOfDay.Thur] = 4,
   [WeekOfDay.Fri] = 5,
   [WeekOfDay.Sat] = 6,
}
local WeekLength = 7
local sec_of_a_day = 24 * 60 * 60

-- 设置时间差
local SetClientTimeDifference = function(value)
    clientTimeDifference = value
end

--==============================--
--desc: 获取当前时间
--@return 当前时间（秒）
--==============================--
function XTime.Now()
    return time() - clientTimeDifference
end

--==============================--
--desc: 同步时间
--@serverTime: 服务器时间
--@reqTime: 发起请求时间
--@resTime: 收到响应时间
--==============================--
function XTime.SyncTime(serverTime, reqTime, resTime)
    local now = time()

    if reqTime and resTime then
        now = reqTime + floor((resTime - reqTime) / 2)
    end

    SetClientTimeDifference(now - serverTime)
end


--获取今天时间
function XTime.GetTodayTime(hour, min, sec)
    local nowTime = XTime.Now()
    local nowDate = os.date("*t", nowTime)
    hour = hour or 0
    min = min or 0
    sec = sec or 0

    local dateTodayTime = os.time({ year = nowDate.year, month = nowDate.month, day = nowDate.day, hour = hour, min = min, sec = sec })
    return dateTodayTime
end

-- 获取距离下一个星期x的时间
function XTime.GetNextWeekOfDay(weekOfDay, offsetTime)
    local needTime = 0
    local nowTime = XTime.Now()
    local nowDate = os.date("*t", nowTime)
    local currentWeekOfDay = nowDate.wday

    local today_0_oclock = XTime.GetTodayTime(0, 0, 0)
    local nextday_0_oclock = today_0_oclock + sec_of_a_day

    if WeekOfDayIndex[currentWeekOfDay] == weekOfDay and nowTime <= (today_0_oclock + offsetTime) then
        --eg: 周一5点刷新，现在是周一5点前
        needTime = today_0_oclock + offsetTime - nowTime
    else
        --eg: 周一5点刷新，现在是周一5点后
        local leftDay = WeekLength - WeekOfDayIndex[currentWeekOfDay]
        local todayLeftTime = nextday_0_oclock - nowTime
        local otherDayTime = leftDay * sec_of_a_day
        needTime = todayLeftTime + otherDayTime + offsetTime
    end

    return needTime
end
