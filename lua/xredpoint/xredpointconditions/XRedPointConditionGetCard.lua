----------------------------------------------------------------
-- 月卡奖励领取
local XRedPointConditionGetCard = {}

function XRedPointConditionGetCard.Check()
    return not XDataCenter.PayManager.IsGotCard()
end

return XRedPointConditionGetCard