----------------------------------------------------------------
--成就标签奖励检测
local XRedPointConditionPlayerAchieve = {}
local SubConditions = nil

function XRedPointConditionPlayerAchieve.GetSubConditions()
     SubConditions = SubConditions or { XRedPointConditions.Types.CONDITION_PLAYER_ACHIEVE_TYPE }
     return SubConditions
end

function XRedPointConditionPlayerAchieve.Check()
    if not XFunctionManager.JudgeOpen(XFunctionManager.FunctionName.PlayerAchievement) then
        return false
    end

    if XRedPointConditionPlayerAchieveType.Check(XDataCenter.TaskManager.AchvType.Fight) then
        return true
    end

    if XRedPointConditionPlayerAchieveType.Check(XDataCenter.TaskManager.AchvType.Collect) then
        return true
    end

    if XRedPointConditionPlayerAchieveType.Check(XDataCenter.TaskManager.AchvType.Social) then
        return true
    end

    if XRedPointConditionPlayerAchieveType.Check(XDataCenter.TaskManager.AchvType.Other) then
        return true
    end

    return false
end

return XRedPointConditionPlayerAchieve