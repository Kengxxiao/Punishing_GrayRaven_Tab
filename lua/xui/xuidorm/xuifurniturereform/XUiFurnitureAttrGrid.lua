
local XUiFurnitureAttrGrid = XClass()

function XUiFurnitureAttrGrid:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
end


function XUiFurnitureAttrGrid:SetContent(content,isSelect)
    self.NormalItemLabel.text = content.TagName
    self.PressItemLabel.text  = content.TagName
    self.SelectItemLabel.text  = content.TagName


end

function XUiFurnitureAttrGrid:SetSelect(isSelect)
    self.Normal.gameObject:SetActiveEx(not isSelect)
    self.Select.gameObject:SetActiveEx(isSelect)
end

return XUiFurnitureAttrGrid