local XUiGridParticularsItem = XClass()

function XUiGridParticularsItem:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
end

function XUiGridParticularsItem:Init(uiRoot)
    self.UiRoot = uiRoot
end

-- 更新数据
function XUiGridParticularsItem:OnRefresh(itemdata)
    if not itemdata then
        return
    end

    self.ItemData = itemdata
    self:SetData()
end

return XUiGridParticularsItem