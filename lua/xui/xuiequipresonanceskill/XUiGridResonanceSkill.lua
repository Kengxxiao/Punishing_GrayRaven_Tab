local XUiGridResonanceSkill = XClass()

function XUiGridResonanceSkill:Ctor(ui, equipId, pos, characterId, clickCb)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.EquipId = equipId
    self.Pos = pos
    self.CharacterId = characterId
    self.ClickCb = clickCb
    self:InitAutoScript()
end

function XUiGridResonanceSkill:SetEquipIdAndPos(equipId, pos)
    self.EquipId = equipId
    self.Pos = pos
end

function XUiGridResonanceSkill:Refresh(skillInfo, bindCharacterId)
    skillInfo = skillInfo or XDataCenter.EquipManager.GetResonanceSkillInfo(self.EquipId, self.Pos)
    bindCharacterId = bindCharacterId or XDataCenter.EquipManager.GetResonanceBindCharacterId(self.EquipId, self.Pos)

    if self.PanelBindCharacter and self.RImgHead then
        if bindCharacterId and bindCharacterId > 0 then
            self.RImgHead:SetRawImage(XDataCenter.CharacterManager.GetCharRoundnessHeadIcon(bindCharacterId))
            self.PanelBindCharacter.gameObject:SetActive(true)
        else
            self.PanelBindCharacter.gameObject:SetActive(false)
        end
    end

    if self.RImgResonanceSkill and skillInfo.Icon then
        self.RImgResonanceSkill:SetRawImage(skillInfo.Icon)
    end

    if self.TxtSkillName then
        self.TxtSkillName.text = skillInfo.Name
    end

    if self.TxtSkillDes then
        self.TxtSkillDes.text = skillInfo.Description
    end

    if self.ImgNotResonance then
        self.ImgNotResonance.gameObject:SetActive(bindCharacterId ~= 0 and self.CharacterId ~= bindCharacterId)
    end
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiGridResonanceSkill:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiGridResonanceSkill:AutoInitUi()
    self.TxtSkillDes = XUiHelper.TryGetComponent(self.Transform, "TxtSkillDes", "Text")
    self.TxtSkillName = XUiHelper.TryGetComponent(self.Transform, "TxtSkillName", "Text")
    self.PanelBindCharacter = XUiHelper.TryGetComponent(self.Transform, "PanelBindCharacter", nil)
    self.RImgHead = XUiHelper.TryGetComponent(self.Transform, "PanelBindCharacter/RImgHead", "RawImage")
    self.RImgResonanceSkill = XUiHelper.TryGetComponent(self.Transform, "RImgResonanceSkill", "RawImage")
    self.ImgNotResonance = XUiHelper.TryGetComponent(self.Transform, "ImgNotResonance", "Image")
    self.BtnClick = XUiHelper.TryGetComponent(self.Transform, "BtnClick", "Button")
end

function XUiGridResonanceSkill:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiGridResonanceSkill:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiGridResonanceSkill:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiGridResonanceSkill:AutoAddListener()
    self:RegisterClickEvent(self.BtnClick, self.OnBtnClickClick)
end
-- auto
function XUiGridResonanceSkill:OnBtnClickClick(eventData)
    if self.ClickCb then self.ClickCb(self.EquipId, self.Pos, self.CharacterId) end
end

return XUiGridResonanceSkill