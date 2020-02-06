
----------------------------------------------------------------
--角色升级红点检测
local XRedPointConditionCharacterLevel = {}
local Events = nil
function XRedPointConditionCharacterLevel.GetSubEvents()
    Events = Events or
    { 
        XRedPointEventElement.New(XEventId.EVENT_CHARACTER_LEVEL_UP),
        XRedPointEventElement.New(XEventId.EVENT_PLAYER_LEVEL_CHANGE),
    }
    return Events
end

function XRedPointConditionCharacterLevel.Check(characterId)
    if not characterId then
        return false
    end

    if not XFunctionManager.JudgeOpen(XFunctionManager.FunctionName.Character) then
        return false
    end

    if XDataCenter.CharacterManager.CanLevelUp(characterId) then
        return true
    end

    if XRedPointConditionExhibitionNew.Check(characterId) then
        return true
    end

    return false
end

return XRedPointConditionCharacterLevel
