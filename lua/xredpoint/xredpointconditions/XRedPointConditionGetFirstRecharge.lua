----------------------------------------------------------------
-- 首充奖励领取
local XRedPointConditionGetFirstRecharge = {}

function XRedPointConditionGetFirstRecharge.Check()
    return not XDataCenter.PayManager.IsGotFirstReCharge()
end

return XRedPointConditionGetFirstRecharge