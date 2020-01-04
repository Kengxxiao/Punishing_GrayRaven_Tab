----------------------------------------------------------------
--新手任务奖励检测
local XRedPointConditionActivityBriefTaskFinished = {}
local Events = nil

function XRedPointConditionActivityBriefTaskFinished.GetSubEvents()
    Events = Events or
    { 
        XRedPointEventElement.New(XEventId.EVENT_TASK_SYNC),
    }
    return Events
end

function XRedPointConditionActivityBriefTaskFinished.Check()
    return XDataCenter.ActivityBriefManager.CheckAnyTaskFinished()
end

return XRedPointConditionActivityBriefTaskFinished