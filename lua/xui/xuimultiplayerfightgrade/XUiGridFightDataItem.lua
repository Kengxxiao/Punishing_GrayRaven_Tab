local XUiGridFightDataItem = XClass()

function XUiGridFightDataItem:Ctor(ui, name)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
    self.TxtTitle.text = name
end

function XUiGridFightDataItem:Refresh(mvp, value)
    self.ImgMvp.gameObject:SetActive(mvp and true or false)
    self.TxtValue.text = value
end

return XUiGridFightDataItem
