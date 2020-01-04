----------------------------------------------------------------
--单个类型成就奖励检测
local XRedPointConditionPlayerAchieveType = {}
local Events = nil
function XRedPointConditionPlayerAchieveType.GetSubEvents()
    Events = Events or
    { 
        XRedPointEventElement.New(XEventId.EVENT_TASK_SYNC),
    }
    return Events
end

function XRedPointConditionPlayerAchieveType.Check(achieveType)
    if not XFunctionManager.JudgeOpen(XFunctionManager.FunctionName.PlayerAchievement) then
        return false
    end

    return XDataCenter.TaskManager.HasAchieveTaskRewardByAchieveType(achieveType)
end

return XRedPointConditionPlayerAchieveType