XUiGridAttributeComparable = XClass()

function XUiGridAttributeComparable:Ctor(rootUi, ui)
    self.RootUi = rootUi
    self.GameObject = ui.gameObject
    self.Transform = ui.transform

    XTool.InitUiObject(self)
end

function XUiGridAttributeComparable:Init(data)
    self:UpdateData(data)
end


function XUiGridAttributeComparable:UpdateData(data)
    local attrTemplates = XFurnitureConfigs.GetDormFurnitureType(data.AttrKey)
    if attrTemplates==nil then return end
    self.RootUi:SetUiSprite(self.ImgAttributeIcon, attrTemplates.TypeIcon)
    self.TxtAttributeScore.text = data.AttrNewVal

    self.ImgScoreDown.gameObject:SetActive(data.AttrOldVal > data.AttrNewVal)
    self.ImgScoreUp.gameObject:SetActive(data.AttrOldVal < data.AttrNewVal)
end

return XUiGridAttributeComparable
