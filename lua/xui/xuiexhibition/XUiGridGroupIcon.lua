local XUiGridGroupIcon = XClass()

function XUiGridGroupIcon:Ctor(ui, imgPath, groupID)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.ImgPath = imgPath
    self.GroupID = groupID
    XTool.InitUiObject(self)
    self:RefreshGroupIcon()
    self.BtnGroupInfo.CallBack = function() self:OnBtnGroupInfoClick() end
end

function XUiGridGroupIcon:RefreshGroupIcon()
    self.RImgIcon:SetRawImage(self.ImgPath)
end

function XUiGridGroupIcon:OnBtnGroupInfoClick()
    XLuaUiManager.Open("UiExhibitionGroupTip", self.GroupID)
end

return XUiGridGroupIcon