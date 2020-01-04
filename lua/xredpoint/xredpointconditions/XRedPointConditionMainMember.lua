
----------------------------------------------------------------
--角色入口红点检测
local XRedPointConditionMainMember = {}
local SubConditions = nil
function XRedPointConditionMainMember.Check()
    local characterList = XDataCenter.CharacterManager.GetCharacterList()
    
    if not characterList then
        return false
    end

    local count = #characterList
    local isEnough = false

    for i = 1, count do
        local character = characterList[i]
        if XRedPointConditionCharacter.Check(character.Id) then
            isEnough = true
            break
        end
    end

    return isEnough
end


function XRedPointConditionMainMember.GetSubConditions()
    SubConditions = SubConditions or
    {
        XRedPointConditions.Types.CONDITION_CHARACTER,
    }
    return SubConditions
end

return XRedPointConditionMainMember