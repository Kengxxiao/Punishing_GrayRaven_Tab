XUiPanelSkillBox = XClass()

function XUiPanelSkillBox:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
end

function XUiPanelSkillBox:Refresh(skillName, skillDesc)
    self.TxtSkillName.text = skillName
    self.TxtDesc.text = skillDesc
end

function XUiPanelSkillBox:SetActive(enabled)
    self.GameObject:SetActive(enabled)
end

return XUiPanelSkillBox