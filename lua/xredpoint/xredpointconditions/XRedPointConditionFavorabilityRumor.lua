----------------------------------------------------------------
--异闻检测：两种条件：信赖度等级以及宿舍事件，宿舍事件暂时还没有，需要参数characterId
local XRedPointConditionFavorabilityRumor = {}
local Events = nil
function XRedPointConditionFavorabilityRumor.GetSubEvents()
    Events = Events or { 
        XRedPointEventElement.New(XEventId.EVENT_FAVORABILITY_LEVELCHANGED),
        XRedPointEventElement.New(XEventId.EVENT_FAVORABILITY_RUMERUNLOCK),
    }
    return Events
end

function XRedPointConditionFavorabilityRumor.Check(checkArgs)
    if not checkArgs then return false end
    local characterId = checkArgs.CharacterId
    if characterId == nil then return false end
    local isOpen = XFunctionManager.JudgeCanOpen(XFunctionManager.FunctionName.FavorabilityFile)
    if not isOpen then return false end
    return XDataCenter.FavorabilityManager.HasRumorsToBeUnlock(characterId)
end

return XRedPointConditionFavorabilityRumor