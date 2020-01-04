----------------------------------------------------------------
--单个类型任务奖励检测
local XRedPointConditionTaskWeekActive = {}
local Events = nil
function XRedPointConditionTaskWeekActive.GetSubEvents()
    Events = Events or
    {
        XRedPointEventElement.New(XEventId.EVENT_TASK_SYNC),
    }
    return Events
end

function XRedPointConditionTaskWeekActive.Check()
    if not XFunctionManager.JudgeOpen(XFunctionManager.FunctionName.TaskActivity) then 
        return false
    end

    return XDataCenter.TaskManager.CheckHasWeekActiveTaskReward()
end

return XRedPointConditionTaskWeekActive