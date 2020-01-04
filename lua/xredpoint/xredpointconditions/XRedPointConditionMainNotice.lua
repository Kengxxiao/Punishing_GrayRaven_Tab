
----------------------------------------------------------------
local XRedPointConditionMainNotice = {}
local SubConditions = nil

function XRedPointConditionMainNotice.Check()
    return XRedPointConditionActivityNewAcitivies.Check() or XRedPointConditionActivityNewNotices.Check() or XRedPointConditionActivityNewActivityNotices.Check()
end

function XRedPointConditionMainNotice.GetSubConditions()
    return SubConditions or {
        XRedPointConditions.Types.CONDITION_ACTIVITY_NEW_ACTIVITIES,
        XRedPointConditions.Types.CONDITION_ACTIVITY_NEW_NOTICES,
        XRedPointConditions.Types.CONDITION_ACTIVITY_NEW_ACTIVITY_NOTICES,
    }
end

return XRedPointConditionMainNotice
