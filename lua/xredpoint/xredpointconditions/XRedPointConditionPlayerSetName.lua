----------------------------------------------------------------
--玩家改名检测
local XRedPointConditionPlayerSetName = {}

local Events = nil
function XRedPointConditionPlayerSetName.GetSubEvents()
    Events = Events or
            {
                XRedPointEventElement.New(XEventId.EVENT_PLAYER_SET_NAME)
            }
    return Events
end

function XRedPointConditionPlayerSetName.Check()
    if XPlayer.ChangeNameTime == 0 then
        return true
    end
    return false
end

return XRedPointConditionPlayerSetName