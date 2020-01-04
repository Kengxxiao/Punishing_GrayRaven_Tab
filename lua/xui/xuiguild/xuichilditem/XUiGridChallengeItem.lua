local XUiGridChallengeItem = XClass()

function XUiGridChallengeItem:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform

    XTool.InitUiObject(self)
end

function XUiGridChallengeItem:Init(uiRoot)
    self.UiRoot = uiRoot
end

-- 刷新界面修改self.Transform.sizeDelta

return XUiGridChallengeItem