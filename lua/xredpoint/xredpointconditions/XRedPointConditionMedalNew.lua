----------------------------------------------------------------
-- 勋章检测
local XRedPointConditionMedalNew = {}

local Events = nil
function XRedPointConditionMedalNew.GetSubEvents()
    Events = Events or
            {
                XRedPointEventElement.New(XEventId.EVENT_MEDAL_NOTIFY),
                XRedPointEventElement.New(XEventId.EVENT_MEDAL_IN_DETAIL),
            }
    return Events
end

function XRedPointConditionMedalNew.Check()
    return XDataCenter.MedalManager.CheakHaveNewMedal()
end

return XRedPointConditionMedalNew