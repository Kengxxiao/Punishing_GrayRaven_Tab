----------------------------------------------------------------
-- 单机Boss检查奖励领取
local XRedPointConditionBossSingleReward = {}

function XRedPointConditionBossSingleReward.Check()
    return XDataCenter.FubenBossSingleManager.CheckRewardRedHint()
end

return XRedPointConditionBossSingleReward