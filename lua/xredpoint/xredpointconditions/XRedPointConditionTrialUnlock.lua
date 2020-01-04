----------------------------------------------------------------
--关卡解锁
local XRedPointConditionTrialUnlock = {}
local Events = nil

function XRedPointConditionTrialUnlock.GetSubEvents()
    Events = Events or {
        XRedPointEventElement.New(XEventId.EVENT_TRIAL_LEVEL_FINISH),
        XRedPointEventElement.New(XEventId.EVENT_PLAYER_LEVEL_CHANGE),
    }
    return Events
end

function XRedPointConditionTrialUnlock.Check()
    return XDataCenter.TrialManager.TrialLevelLockSignRedPoint()
end

return XRedPointConditionTrialUnlock 