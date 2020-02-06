XResetManager = XResetManager or {}

local floor = math.floor
local insert = table.insert

local DailyResetSpan = 0
local ResetCfg = {}
local TABLE_RESET = "Share/Reset/SystemResetConfig.tab"

XResetManager.ResetType = {
    NoNeed = 0, -- 无需重置
    Interval = 1, -- 间隔一段时间
    Daily = 2, -- 每天
    Weekly = 3, -- 每周
    Monthly = 4   -- 每月
}

function XResetManager.Init()
    DailyResetSpan = CS.XGame.Config:GetInt("DailyResetTimestamp")

    ResetCfg = XTableManager.ReadByIntKey(TABLE_RESET, XTable.XTableSystemReset, "ResetKey")
end

function XResetManager.GetTodayRemainTime(checkTime)
    checkTime = checkTime or XTime.GetServerNowTimestamp()
    local targetTime = CS.XDateUtil.GetGameDateTime(checkTime).Date:AddSeconds(DailyResetSpan):ToTimestamp()
    targetTime = checkTime > targetTime and (targetTime + CS.XDateUtil.ONE_DAY_SECOND) or targetTime
    return targetTime - checkTime
end

function XResetManager.GetResetTimeByString(resetType, timeStr)
    local seconds, days = {}, {}

    if resetType == XResetManager.ResetType.Interval or resetType == XResetManager.ResetType.Daily then
        seconds = string.ToIntArray(timeStr, '|')
    elseif resetType == XResetManager.ResetType.Weekly or resetType == XResetManager.ResetType.Monthly then
        local times = string.Split(timeStr)
        for _, str in pairs(times) do
            local dayAndSecond = string.ToIntArray(str, '#')
            if #dayAndSecond > 1 then
                insert(days, dayAndSecond[1])
                insert(seconds, dayAndSecond[2])
            elseif #dayAndSecond > 0 then
                insert(days, dayAndSecond[1])
                insert(seconds, DailyResetSpan)
            end
        end
    end

    return seconds, days
end

function XResetManager.GetResetTodayDayOfWeek()
    local day = XTime.DayOfWeekToInt(CS.XDateUtil.GetGameNow().DayOfWeek)
    local now = XTime.GetServerNowTimestamp()
    local stamp = CS.XDateUtil.GetGameDateTime(checkTime).Date:AddSeconds(DailyResetSpan):ToTimestamp()

    if now >= stamp then -- 超过属于后面的一天
        day = (day + 1) % 7
    end
    return day
end

function XResetManager.GetNextResetTime(resetType, lastTime, seconds, days)
    return CS.XReset.GetNextResetTime(resetType, lastTime, seconds, days)
end

function XResetManager.GetRemainTime(resetCfg, lastTime)
    local resetType = resetCfg.ResetType
    local recTime = resetCfg.ResetTime
    local seconds, days = XResetManager.GetResetTimeByString(resetType, recTime)
    return CS.XReset.GetNextResetTime(resetType, lastTime, seconds, days) - XTime.GetServerNowTimestamp()
end

function XResetManager.GetResetCfg(reseTimeId)
    local cfg = ResetCfg[reseTimeId]
    if not cfg then
        XLog.Error("XResetManager.GetResetCfg error: cfg not found, reseTimeId is " .. reseTimeId)
        return
    end

    return cfg
end