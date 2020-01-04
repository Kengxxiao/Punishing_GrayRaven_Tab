----------------------------------------------------------------
--单个类型任务奖励检测
local XRedPointConditionDormTaskType = {}
local Events = nil
function XRedPointConditionDormTaskType.GetSubEvents()
    Events = Events or
    {
        XRedPointEventElement.New(XEventId.EVENT_TASK_SYNC),
        XRedPointEventElement.New(XEventId.EVENT_FUNCTION_OPEN_COMPLETE),
    }
    return Events
end

function XRedPointConditionDormTaskType.Check(taskType)
    return XDataCenter.TaskManager.GetIsRewardForEx(taskType)
end

return XRedPointConditionDormTaskType