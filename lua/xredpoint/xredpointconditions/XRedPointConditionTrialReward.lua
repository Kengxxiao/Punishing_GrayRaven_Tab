----------------------------------------------------------------
--关卡奖励
local XRedPointConditionTrialReward = {}
local Events = nil

function XRedPointConditionTrialReward.GetSubEvents()
    Events = Events or {
        XRedPointEventElement.New(XEventId.EVENT_TRIAL_LEVEL_FINISH),
    }
    return Events
end

function XRedPointConditionTrialReward.Check(checkArgs)
    local cfg = XTrialConfigs.GetForTotalData()
    for _, v in pairs(cfg) do
        if XDataCenter.TrialManager.TrialLevelRewardGetSignRedPoint(v.Id) then
            return true
        end
    end

    cfg = XTrialConfigs.GetBackEndTotalData()
    for _, v in pairs(cfg) do
        if XDataCenter.TrialManager.TrialLevelRewardGetSignRedPoint(v.Id) then
            return true
        end
    end
    
    return XDataCenter.TrialManager.TrialTypeRewardRedPoint()
end

return XRedPointConditionTrialReward 