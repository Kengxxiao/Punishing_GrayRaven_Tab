----------------------------------------------------------------
--单个类型任务奖励检测
local XRedPointConditionDormMainTaskRed = {}
local Events = nil
function XRedPointConditionDormMainTaskRed.GetSubEvents()
    Events = Events or
    {
        XRedPointEventElement.New(XEventId.EVENT_TASK_SYNC),
        XRedPointEventElement.New(XEventId.EVENT_FUNCTION_OPEN_COMPLETE),
    }
    return Events
end

function XRedPointConditionDormMainTaskRed.Check()
    local dormNormal = XDataCenter.TaskManager.TaskType.DormNormal
    local dormDaily = XDataCenter.TaskManager.TaskType.DormDaily
    local red = XDataCenter.TaskManager.GetIsRewardForEx(dormNormal) or XDataCenter.TaskManager.GetIsRewardForEx(dormDaily)
    return red
end

return XRedPointConditionDormMainTaskRed