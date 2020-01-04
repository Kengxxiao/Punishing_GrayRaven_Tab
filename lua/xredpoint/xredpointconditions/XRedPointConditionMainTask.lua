----------------------------------------------------------------
--主界面任务奖励检测
local XRedPointConditionMainTask = {}
local SubConditions = nil
function XRedPointConditionMainTask.GetSubConditions()
    SubConditions = SubConditions or
    { 
        XRedPointConditions.Types.CONDITION_TASK_COURSE,
        XRedPointConditions.Types.CONDITION_TASK_TYPE,
        XRedPointConditions.Types.CONDITION_BOUNTYTASK

    }
    return SubConditions
end

function XRedPointConditionMainTask.Check()

    if XRedPointConditionTaskCourse.Check() then
        return true
    end

    if XRedPointConditionBountyTask.Check() then
        return true
    end

    if XRedPointConditionTaskType.Check(XDataCenter.TaskManager.TaskType.Story) then
        return true
    end

    if XRedPointConditionTaskType.Check(XDataCenter.TaskManager.TaskType.Daily) then
        return true
    end

    if XRedPointConditionTaskType.Check(XDataCenter.TaskManager.TaskType.Weekly) then
        return true
    end

    if XRedPointConditionTaskType.Check(XDataCenter.TaskManager.TaskType.Activity) then
        return true
    end
    

    return false
end

return XRedPointConditionMainTask