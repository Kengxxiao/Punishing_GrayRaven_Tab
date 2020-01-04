----------------------------------------------------------------
local XRedPointConditionBaseEquip = {}
local Events = nil
function XRedPointConditionBaseEquip.GetSubEvents()
    Events = Events or
            {
                XRedPointEventElement.New(XEventId.EVENT_BASE_EQUIP_DATA_REFRESH),
            }
    return Events
end

function XRedPointConditionBaseEquip.Check()
    if not XFunctionManager.JudgeOpen(XFunctionManager.FunctionName.Domitory) then
        return false
    end

    if XDataCenter.BaseEquipManager.CheckBaseEquipHint() then--基地装备
        return true
    end

    return false
end

return XRedPointConditionBaseEquip