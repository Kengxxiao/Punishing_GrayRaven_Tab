----------------------------------------------------------------
--单个类型任务奖励检测
local XRedPointConditionTaskType = {}
local Events = nil
function XRedPointConditionTaskType.GetSubEvents()
    Events = Events or
    {
        XRedPointEventElement.New(XEventId.EVENT_TASK_SYNC),
        XRedPointEventElement.New(XEventId.EVENT_FUNCTION_OPEN_COMPLETE),
    }
    return Events
end


function XRedPointConditionTaskType.Check(taskType)

    if not XFunctionManager.JudgeOpen(XFunctionManager.FunctionName.TaskActivity) and taskType == XDataCenter.TaskManager.TaskType.Activity then 
        return  false
    end

    if not XFunctionManager.JudgeOpen(XFunctionManager.FunctionName.TaskDay) and taskType == XDataCenter.TaskManager.TaskType.Daily then 
        return  false
    end

    if not XFunctionManager.JudgeOpen(XFunctionManager.FunctionName.TaskWeekly) and taskType == XDataCenter.TaskManager.TaskType.Weekly then
        return false
    end

    if taskType == XDataCenter.TaskManager.TaskType.Daily then --日活跃
        if XDataCenter.TaskManager.CheckHasDailyActiveTaskReward() then
            return true
        end
    --去掉周任务判断
    --    if XDataCenter.TaskManager.CheckHasWeekActiveTaskReward() then
    --        return true
    --    end
    end

    return XDataCenter.TaskManager.GetIsRewardForEx(taskType)
end

return XRedPointConditionTaskType