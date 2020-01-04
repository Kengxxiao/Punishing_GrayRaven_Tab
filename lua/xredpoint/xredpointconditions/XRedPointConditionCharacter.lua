
----------------------------------------------------------------
--角色入口红点检测
local XRedPointConditionCharacter = {}
local SubCondition = nil
function XRedPointConditionCharacter.GetSubConditions()
    SubCondition = SubCondition or {
        XRedPointConditions.Types.CONDITION_CHARACTER_GRADE ,
        XRedPointConditions.Types.CONDITION_CHARACTER_QUALITY,
        XRedPointConditions.Types.CONDITION_CHARACTER_UNLOCK,
        XRedPointConditions.Types.CONDITION_EXHIBITION_NEW,
    }
    return SubCondition
end

function XRedPointConditionCharacter.Check(characterId)
  
    if not characterId then
        return false
    end

    if XRedPointConditionCharacterUnlock.Check(characterId) then
        return true
    end

    if XRedPointConditionCharacterGrade.Check(characterId) then
        return true
    end

    if XRedPointConditionCharacterQuality.Check(characterId) then
        return true 
    end

    if XRedPointConditionExhibitionNew.Check(characterId) then
        return true 
    end

    return false

end

return XRedPointConditionCharacter