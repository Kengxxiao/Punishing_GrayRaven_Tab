----------------------------------------------------------------
--单个邮件检测
local XRedPointConditionFavorabilityDocument = {}

local SubCondition = nil
function XRedPointConditionFavorabilityDocument.GetSubConditions()
    SubCondition = SubCondition or {
        XRedPointConditions.Types.CONDITION_FAVORABILITY_DOCUMENT_INFO ,
        XRedPointConditions.Types.CONDITION_FAVORABILITY_DOCUMENT_RUMOR,
        XRedPointConditions.Types.CONDITION_FAVORABILITY_DOCUMENT_AUDIO,
    }
    return SubCondition
end

function XRedPointConditionFavorabilityDocument.Check(checkArgs)
    if XFunctionManager.CheckFunctionFitter(XFunctionManager.FunctionName.FavorabilityFile) then
        return false
    end

    if not checkArgs then return false end
    local characterId = checkArgs.CharacterId
    if characterId == nil then return false end

    if XRedPointConditionFavorabilityInfo.Check(checkArgs) then
        return true
    end

    if XRedPointConditionFavorabilityRumor.Check(checkArgs) then
        return true
    end

    if XRedPointConditionFavorabilityAudio.Check(checkArgs) then
        return true
    end

    return false
end



return XRedPointConditionFavorabilityDocument