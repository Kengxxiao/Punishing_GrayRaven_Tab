----------------------------------------------------------------
local XRedPointConditionActivityNewAcitivies = {}
local Events = nil

function XRedPointConditionActivityNewAcitivies.GetSubEvents()
    Events = Events or {
        XRedPointEventElement.New(XEventId.EVENT_ACTIVITY_ACTIVITIES_READ_CHAGNE),
    }
    return Events
end

function XRedPointConditionActivityNewAcitivies.Check()
    return XDataCenter.ActivityManager.CheckRedPoint()
end

return XRedPointConditionActivityNewAcitivies