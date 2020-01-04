local XUiGridWelfareItem = XClass()

function XUiGridWelfareItem:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform

    XTool.InitUiObject(self)
end

function XUiGridWelfareItem:Init(uiRoot)
    self.UiRoot = uiRoot
end

-- 刷新界面修改self.Transform.sizeDelta

return XUiGridWelfareItem