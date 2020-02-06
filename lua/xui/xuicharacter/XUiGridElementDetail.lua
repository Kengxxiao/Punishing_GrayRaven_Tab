local XUiGridElementDetail = XClass()

function XUiGridElementDetail:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
end

function XUiGridElementDetail:Refresh(elementId)
    self.PanelCur.gameObject:SetActiveEx(elementId < 0)
    elementId = elementId > 0 and elementId or -elementId
    local elementConfig = XCharacterConfigs.GetCharElment(elementId)
    self.TxtName.text = elementConfig.ElementName
    self.TxtContent.text = elementConfig.Description
    self.RImgIcon:SetRawImage(elementConfig.Icon)
end

return XUiGridElementDetail