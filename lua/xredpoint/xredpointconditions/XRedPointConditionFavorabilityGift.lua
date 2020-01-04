----------------------------------------------------------------
--好感度奖励检测，跟好感度等级，角色战斗参数，角色等级，角色品质关联，需要参数characterId
local XRedPointConditionFavorabilityGift = {}
local Events = nil
function XRedPointConditionFavorabilityGift.GetSubEvents()
    Events = Events or { 
        XRedPointEventElement.New(XEventId.EVENT_FAVORABILITY_LEVELCHANGED),
        XRedPointEventElement.New(XEventId.EVENT_FAVORABILITY_CHAR_ABILITY_CHANGED),
        XRedPointEventElement.New(XEventId.EVENT_CHARACTER_LEVEL_UP),
        XRedPointEventElement.New(XEventId.EVENT_CHARACTER_QUALITY_PROMOTE),
        XRedPointEventElement.New(XEventId.EVENT_FAVORABILITY_COLLECTGIFT),
    }
    return Events
end

function XRedPointConditionFavorabilityGift.Check(checkArgs)
    if not checkArgs then return false end
    local characterId = checkArgs.CharacterId
    if characterId == nil then return false end
    local isOpen = XFunctionManager.JudgeCanOpen(XFunctionManager.FunctionName.FavorabilityGift)
    if not isOpen then return false end    
    return false
end

return XRedPointConditionFavorabilityGift