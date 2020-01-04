local XUiGridArenaTeamMember = XClass()

function XUiGridArenaTeamMember:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
    self:AutoAddListener()
end

function XUiGridArenaTeamMember:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiGridArenaTeamMember:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiGridArenaTeamMember:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiGridArenaTeamMember:AutoAddListener()
    self:RegisterClickEvent(self.BtnHead, self.OnBtnHeadClick)
end

function XUiGridArenaTeamMember:OnBtnHeadClick(eventData)
    if not self.Data or self.Data.Id == XPlayer.Id then
        return
    end

    XDataCenter.PersonalInfoManager.ReqShowInfoPanel(self.Data.Id)
end

function XUiGridArenaTeamMember:SetData(data, captainId, rootUi)
    self.Data = data

    if not data then
        self.PanelSomeOne.gameObject:SetActive(false)
        self.PanelNone.gameObject:SetActive(true)
        return
    end

    self.PanelSomeOne.gameObject:SetActive(true)
    self.PanelNone.gameObject:SetActive(false)

    self.TxtNickname.text = data.Name
    self.TxtPlayerLevel.text = data.Level
    local isCaptain = data.Id == captainId
    self.ImgCaptain.gameObject:SetActive(isCaptain)
    local info = XPlayerManager.GetHeadPortraitInfoById(data.CurrHeadPortraitId)
    if (info ~= nil) then
        self.RImgHeadIcon:SetRawImage(info.ImgSrc)
    end
end

return XUiGridArenaTeamMember
