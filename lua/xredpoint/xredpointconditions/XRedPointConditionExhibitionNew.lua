----------------------------------------------------------------
-- 构造体展示厅奖励领取检测
local XRedPointConditionExhibitionNew = {}

local Events = nil
function XRedPointConditionExhibitionNew.GetSubEvents()
    Events = Events or
    {
        XRedPointEventElement.New(XEventId.EVENT_CHARACTER_EXHIBITION_REFRESH),
    }
    return Events
end

function XRedPointConditionExhibitionNew.Check(characterId)
    if XFunctionManager.CheckFunctionFitter(XFunctionManager.FunctionName.CharacterExhibition) then
        return false
    end
    characterId = type(characterId) == "table" and characterId[1] or characterId
    return XDataCenter.ExhibitionManager.CheckNewCharacterReward(characterId)
end

return XRedPointConditionExhibitionNew