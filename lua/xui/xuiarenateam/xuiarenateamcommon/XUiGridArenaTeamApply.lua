local XUiGridArenaTeamApply = XClass()

function XUiGridArenaTeamApply:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
    self:AutoAddListener()
end

function XUiGridArenaTeamApply:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiGridArenaTeamApply:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiGridArenaTeamApply:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiGridArenaTeamApply:AutoAddListener()
    self:RegisterClickEvent(self.BtnRefuse, self.OnBtnRefuseClick)
    self:RegisterClickEvent(self.BtnAccept, self.OnBtnAcceptClick)
    self:RegisterClickEvent(self.BtnHead, self.OnBtnHeadClick)
end

function XUiGridArenaTeamApply:OnBtnHeadClick(eventData)
    if not self.Data or self.Data.Id == XPlayer.Id then
        return
    end

    XDataCenter.PersonalInfoManager.ReqShowInfoPanel(self.Data.Id)
end

function XUiGridArenaTeamApply:OnBtnRefuseClick(eventData)
    if not self.Data then
        return
    end

    if self.IsInTeam then
        if XDataCenter.ArenaManager.CheckSelfIsCaptain() then
            XDataCenter.ArenaManager.RequestRefuseApply(self.Data.Id)
        end
    else
        XDataCenter.ArenaManager.RequestRefuseInvite(self.Data.Id)
    end
end

function XUiGridArenaTeamApply:OnBtnAcceptClick(eventData)
    if not self.Data then
        return
    end

    if self.IsInTeam then
        if XDataCenter.ArenaManager.CheckSelfIsCaptain() then
            XDataCenter.ArenaManager.RequestAcceptApply(self.Data.Id)
        end
    else
        XDataCenter.ArenaManager.RequestAcceptInvite(self.Data.Id)
    end
end

function XUiGridArenaTeamApply:ResetData(data, rootUi)
    self.Data = data
    self.RootUi = rootUi
    self:Refresh()
end

function XUiGridArenaTeamApply:Refresh()
    if not self.Data then
        return
    end

    self.IsInTeam = XDataCenter.ArenaManager.GetTeamId() > 0
    self.TxtApplyOfPlayer.gameObject:SetActive(self.IsInTeam)
    self.TxtApplyOfTeam.gameObject:SetActive(not self.IsInTeam)

    self.TxtNickname.text = self.Data.Name
    self.TxtPlayerLevel.text = self.Data.Level

    local info = XPlayerManager.GetHeadPortraitInfoById(self.Data.CurrHeadPortraitId)
    if (info ~= nil) then
        self.RImgHeadIcon:SetRawImage(info.ImgSrc)
    end
end

return XUiGridArenaTeamApply
