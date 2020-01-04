local XUiGridBossSkill = XClass()

function XUiGridBossSkill:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
end

function XUiGridBossSkill:Refresh(title, desc)
    self.TxtTitle.text = title
    self.TxtDesc.text = desc
end

return XUiGridBossSkill
