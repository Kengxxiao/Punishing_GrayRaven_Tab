----------------------------------------------------------------
--单个邮件检测
local XRedPointConditionFavorability = {}

local SubCondition = nil
function XRedPointConditionFavorability.GetSubConditions()
    SubCondition = SubCondition or {
        XRedPointConditions.Types.CONDITION_FAVORABILITY_DOCUMENT_INFO,
        XRedPointConditions.Types.CONDITION_FAVORABILITY_DOCUMENT_RUMOR,
        XRedPointConditions.Types.CONDITION_FAVORABILITY_GIFT,
    }
    return SubCondition
end

function XRedPointConditionFavorability.Check()
    
    local allCharDatas = XDataCenter.CharacterManager.GetCharacterList()
    for k, v in pairs(allCharDatas or {}) do
        local isOwn = XDataCenter.CharacterManager.IsOwnCharacter(v.Id)
        if isOwn then
            local args = {}
            args.CharacterId = v.Id
            if XRedPointConditionFavorabilityInfo.Check(args) then
                return true
            end
        
            if XRedPointConditionFavorabilityRumor.Check(args) then
                return true
            end
        
            if XRedPointConditionFavorabilityGift.Check(args) then
                return true
            end            
        end
    end

    return false
end



return XRedPointConditionFavorability