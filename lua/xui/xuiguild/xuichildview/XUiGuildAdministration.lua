local XUiGuildAdministration = XClass()

function XUiGuildAdministration:Ctor(ui, uiRoot)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.UiRoot = uiRoot

    XTool.InitUiObject(self)
    self:InitChildView()
end

function XUiGuildAdministration:OnEnable()
    self.GameObject:SetActiveEx(true)
end

function XUiGuildAdministration:OnDisable()
    self.GameObject:SetActiveEx(false)
end

function XUiGuildAdministration:InitChildView()
    
end

return XUiGuildAdministration