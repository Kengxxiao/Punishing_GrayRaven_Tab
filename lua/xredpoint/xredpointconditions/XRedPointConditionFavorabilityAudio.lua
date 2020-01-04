----------------------------------------------------------------
--资料检测：只关心依赖度等级变化，需要参数characterId，语音有变化也检查
local XRedPointConditionFavorabilityAudio = {}
local Events = nil
function XRedPointConditionFavorabilityAudio.GetSubEvents()
    Events = Events or { 
        XRedPointEventElement.New(XEventId.EVENT_FAVORABILITY_LEVELCHANGED),
        XRedPointEventElement.New(XEventId.EVENT_FAVORABILITY_AUDIOUNLOCK),
    }
    return Events
end

function XRedPointConditionFavorabilityAudio.Check(checkArgs)
    if not checkArgs then return false end
    local characterId = checkArgs.CharacterId
    if characterId == nil then return false end
    local isOpen = XFunctionManager.JudgeCanOpen(XFunctionManager.FunctionName.FavorabilityFile)
    if not isOpen then return false end
    return XDataCenter.FavorabilityManager.HasAudioToBeUnlock(characterId)
end

return XRedPointConditionFavorabilityAudio