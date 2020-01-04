local XGuideCharacterEquipQualityCompareNode = XLuaBehaviorManager.RegisterNode(XLuaBehaviorNode, "CharacterEquipQualityCompare", CsBehaviorNodeType.Action, true, false)
--索引动态列表
function XGuideCharacterEquipQualityCompareNode:OnAwake()
    if self.Fields == nil then
        self.Node.Status = CsNodeStatus.ERROR
        return
    end

    if self.Fields["CharacterId"] == nil or self.Fields["CompareEquipId"] == nil then
        self.Node.Status = CsNodeStatus.ERROR
        return
    end

    self.CharacterId = self.Fields["CharacterId"]
    self.CompareEquipId = self.Fields["CompareEquipId"]
end

function XGuideCharacterEquipQualityCompareNode:OnEnter()
    if not XDataCenter.CharacterManager.IsOwnCharacter(self.CharacterId) then
        self.Node.Status = CsNodeStatus.FAILED
        return
    end

    local temp = XEquipConfig.GetEquipCfg(self.CompareEquipId)
    if not temp then
        self.Node.Status = CsNodeStatus.FAILED
        return
    end


    local equipId = XDataCenter.EquipManager.GetCharacterWearingWeaponId(self.CharacterId)  --初始为角色身上的装备
    local equip = XDataCenter.EquipManager.GetEquip(equipId)
    if not equipId or not equip then
        self.Node.Status = CsNodeStatus.FAILED
        return
    end

    local wearEquip = XEquipConfig.GetEquipCfg(equip.TemplateId)
    if wearEquip.Star <= temp.Star then
        self.Node.Status = CsNodeStatus.FAILED
        return
    end

    self.Node.Status = CsNodeStatus.SUCCESS
end