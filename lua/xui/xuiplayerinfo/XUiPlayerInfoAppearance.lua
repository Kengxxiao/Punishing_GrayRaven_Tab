XUiPlayerInfoAppearance = XClass()
function XUiPlayerInfoAppearance:Ctor(ui, rootUi)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
end

function XUiPlayerInfoAppearance:UpdateInfo()
end

return XUiPlayerInfoAppearance