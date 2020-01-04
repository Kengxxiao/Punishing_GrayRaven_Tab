local XUiGridHelpCourse = XClass()

function XUiGridHelpCourse:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
end

function XUiGridHelpCourse:Refresh(icon, index, length)
    self.GridHelp:SetRawImage(icon)
    self.ImgArrowNext.gameObject:SetActive(length > index)
    self.TxtPages.text = tostring(length)
    self.TxtNumber.text = tostring(index)
end

return XUiGridHelpCourse