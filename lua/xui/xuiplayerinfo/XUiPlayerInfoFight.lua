XUiPlayerInfoFight = XClass()
function XUiPlayerInfoFight:Ctor(ui, rootUi)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
end

function XUiPlayerInfoFight:UpdateInfo()
end

return XUiPlayerInfoFight