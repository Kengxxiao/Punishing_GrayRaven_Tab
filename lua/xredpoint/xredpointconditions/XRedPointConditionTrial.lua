----------------------------------------------------------------
local XRedPointConditionTrial = {}
local SubCondition = nil
function XRedPointConditionTrial.GetSubConditions()
    SubCondition =
        SubCondition or
        {
            XRedPointConditions.Types.CONDITION_TRIAL_REWARD_RED
        }
    return SubCondition
end

function XRedPointConditionTrial.Check()
    -- 没有开启
    local isOpen = XFunctionManager.JudgeCanOpen(XFunctionManager.FunctionName.Trial)
    if not isOpen then
        return false
    end

    if XRedPointConditionTrialReward.Check() then
        return true
    end
    
    return false
end

return XRedPointConditionTrial
