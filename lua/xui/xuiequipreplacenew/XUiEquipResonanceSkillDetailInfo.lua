local XUiGridResonanceSkill = require("XUi/XUiEquipResonanceSkill/XUiGridResonanceSkill")

local XUiEquipResonanceSkillDetailInfo = XLuaUiManager.Register(XLuaUi, "UiEquipResonanceSkillDetailInfo")

function XUiEquipResonanceSkillDetailInfo:OnAwake()
    self:RegisterClickEvent(self.BtnHideCurResonance, function ()
        self:Close()
    end)
end

function XUiEquipResonanceSkillDetailInfo:OnStart(equipId, pos, characterId)
    self.EquipId = equipId
    self.Pos = pos
    self.CharacterId = characterId
    self:Refresh()
end

function XUiEquipResonanceSkillDetailInfo:Refresh()
    local equipId = self.EquipId
    local pos = self.Pos
    local characterId = self.CharacterId
    self.CurResonanceSkillGrid = self.CurResonanceSkillGrid or XUiGridResonanceSkill.New(self.GridCurResonanceSkill, equipId, pos, characterId)
    self.CurResonanceSkillGrid:SetEquipIdAndPos(equipId, pos)
    self.CurResonanceSkillGrid:Refresh()
end
