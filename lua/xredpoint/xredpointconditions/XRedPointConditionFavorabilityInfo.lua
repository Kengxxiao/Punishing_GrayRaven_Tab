----------------------------------------------------------------
--资料检测：只关心依赖度等级变化，需要参数characterId
local XRedPointConditionFavorabilityInfo = {}
local Events = nil
function XRedPointConditionFavorabilityInfo.GetSubEvents()
    Events = Events or { 
        XRedPointEventElement.New(XEventId.EVENT_FAVORABILITY_LEVELCHANGED),
        XRedPointEventElement.New(XEventId.EVENT_FAVORABILITY_INFOUNLOCK),
    }
    return Events
end

function XRedPointConditionFavorabilityInfo.Check(checkArgs)
    if not checkArgs then return false end
    local characterId = checkArgs.CharacterId
    if characterId == nil then return false end
    local isOpen = XFunctionManager.JudgeCanOpen(XFunctionManager.FunctionName.FavorabilityFile)
    if not isOpen then return false end
    return XDataCenter.FavorabilityManager.HasDataToBeUnlock(characterId)
end



return XRedPointConditionFavorabilityInfo