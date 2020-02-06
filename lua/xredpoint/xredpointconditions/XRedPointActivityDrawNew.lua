----------------------------------------------------------------
-- 是否有新活动奖池开启
local XRedPointActivityDrawNew = {}

local Events = nil
function XRedPointActivityDrawNew.GetSubEvents()
    Events = Events or
            {
                XRedPointEventElement.New(XEventId.EVENT_DRAW_ACTIVITYDRAW_CHANGE),
                XRedPointEventElement.New(XEventId.EVENT_MAINUI_ENABLE),        
            }
    return Events
end

function XRedPointActivityDrawNew.Check()
    return XDataCenter.DrawManager.CheakNewActivityDraw()
end

return XRedPointActivityDrawNew