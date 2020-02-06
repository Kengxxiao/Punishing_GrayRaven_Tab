----------------------------------------------------------------
--异闻检测：信赖度等级，需要参数characterId
local XRedPointConditionFavorabilityPlot = {}
local Events = nil
function XRedPointConditionFavorabilityPlot.GetSubEvents()
    Events = Events or { 
        XRedPointEventElement.New(XEventId.EVENT_FAVORABILITY_LEVELCHANGED),
        XRedPointEventElement.New(XEventId.EVENT_FAVORABILITY_PLOTUNLOCK),
    }
    return Events
end

function XRedPointConditionFavorabilityPlot.Check(checkArgs)
    if XFunctionManager.CheckFunctionFitter(XFunctionManager.FunctionName.FavorabilityStory) then
        return false
    end

    if not checkArgs then return false end
    local characterId = checkArgs.CharacterId
    if characterId == nil then return false end
    local isOpen = XFunctionManager.JudgeCanOpen(XFunctionManager.FunctionName.FavorabilityStory)
    if not isOpen then return false end
    return XDataCenter.FavorabilityManager.HasStroyToBeUnlock(characterId)
end



return XRedPointConditionFavorabilityPlot