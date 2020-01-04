local XUiExhibitionGroupTip = XLuaUiManager.Register(XLuaUi, "UiExhibitionGroupTip")

function XUiExhibitionGroupTip:OnAwake()
    self.BtnClose.CallBack= function() self:OnBtnCloseClick() end
end

function XUiExhibitionGroupTip:OnStart(groupID)
    self.GroupID = groupID
    self:ShowGroupInfo()
end

function XUiExhibitionGroupTip:ShowGroupInfo()
    local groupNameConfig = XExhibitionConfigs.GetExhibitionGroupNameConfig()
    local groupIconConfig = XExhibitionConfigs.GetExhibitionGroupLogoConfig()
    local groupDescConfig = XExhibitionConfigs.GetExhibitionGroupDescConfig()
    self.TxtGroupName.text = groupNameConfig[self.GroupID]
    self.RImgGroupIcon:SetRawImage(groupIconConfig[self.GroupID])
    self.TxtContent.text = groupDescConfig[self.GroupID]
end

function XUiExhibitionGroupTip:OnBtnCloseClick()
    self:Close()
end