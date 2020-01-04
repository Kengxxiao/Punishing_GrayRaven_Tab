----------------------------------------------------------------
-- 构造体展示厅奖励领取检测
local XRedPointConditionHeadPortraitNew = {}

local Events = nil
function XRedPointConditionHeadPortraitNew.GetSubEvents()
    Events = Events or
            {
                XRedPointEventElement.New(XEventId.EVENT_HEAD_PORTRAIT_NOTIFY),
                XRedPointEventElement.New(XEventId.EVENT_HEAD_PORTRAIT_RESETINFO),
            }
    return Events
end

function XRedPointConditionHeadPortraitNew.Check()
    return XDataCenter.HeadPortraitManager.CheakIsNewHeadPortrait()
end

return XRedPointConditionHeadPortraitNew