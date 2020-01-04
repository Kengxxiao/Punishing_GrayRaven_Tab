local XUiGridArenaTeamSingle = XClass()

function XUiGridArenaTeamSingle:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
    self:AutoAddListener()
    self.ArenaLevel = XUiHelper.TryGetComponent(self.Transform, "ArenaLevel", nil).gameObject
end

function XUiGridArenaTeamSingle:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiGridArenaTeamSingle:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiGridArenaTeamSingle:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiGridArenaTeamSingle:AutoAddListener()
    self:RegisterClickEvent(self.BtnInvite, self.OnBtnInviteClick)
    self:RegisterClickEvent(self.BtnHead, self.OnBtnHeadClick)
    self:RegisterClickEvent(self.BtnInviteDis, self.OnBtnInviteDisClick)
end

function XUiGridArenaTeamSingle:OnBtnHeadClick(eventData)
    if not self.Data or not self.Data.Info or self.Data.Info.Id == XPlayer.Id then
        return
    end

    XDataCenter.PersonalInfoManager.ReqShowInfoPanel(self.Data.Info.Id)
end

function XUiGridArenaTeamSingle:OnBtnInviteDisClick(eventData)
    local text = CS.XTextManager.GetText("ArenaTeamInvitError")
    XUiManager.TipError(text)
end

function XUiGridArenaTeamSingle:OnBtnInviteClick(eventData)
    if not self.Data then
        return
    end

    if self.Data.Invite == 1 then
        return
    end

    local teamId = XDataCenter.ArenaManager.GetTeamId()
    if teamId <= 0 then
        XUiManager.TipError(CS.XTextManager.GetText("ArenaTeamCanNotInvite"))
        return
    end

    if not XDataCenter.ArenaManager.CheckSelfIsCaptain() then
        XUiManager.TipError(CS.XTextManager.GetText("ArenaTeamIsNotCaptain"))
        return
    end

    XDataCenter.ArenaManager.RequestInvitePlayer(self.Data.Info.Id, function()
        self.Data.ChallengeId = XDataCenter.ArenaManager.GetCurChallengeId()
        self:Refresh()
    end)
end

function XUiGridArenaTeamSingle:ResetData(data, rootUi)
    self.Data = data
    self.RootUi = rootUi
    self:Refresh()
end

function XUiGridArenaTeamSingle:Refresh()
    if not self.Data then
        return
    end

    self.TxtNickname.text = self.Data.Info.Name
    self.TxtPlayerLevel.text = self.Data.Info.Level

    local isOnline = self.Data.Info.Online == 1
    self.TxtOnline.gameObject:SetActiveEx(isOnline)
    self.TxtOffline.gameObject:SetActiveEx(not isOnline)

    local isInvited = self.Data.Invite == 1
    self.TxtInvited.gameObject:SetActiveEx(isInvited)
    self.TxtNotInvited.gameObject:SetActiveEx(not isInvited)
    if self.BtnInviteDis and not XTool.UObjIsNil(self.BtnInviteDis) then
        self.BtnInviteDis.gameObject:SetActiveEx(false)
    end

    local info = XPlayerManager.GetHeadPortraitInfoById(self.Data.Info.CurrHeadPortraitId)
    if (info ~= nil) then
        self.RImgHeadIcon:SetRawImage(info.ImgSrc)
    end

    if self.Data.ArenaLevel then
        self.ArenaLevel:SetActiveEx(true)
        local isSameId = self.Data.ChallengeId == XDataCenter.ArenaManager.GetCurChallengeId()
        if self.BtnInviteDis and not XTool.UObjIsNil(self.BtnInviteDis) then
            self.BtnInviteDis.gameObject:SetActiveEx(not isSameId)
        end
        self.RImgArenaLevel.gameObject:SetActiveEx(true)
        local arenaCfg = XArenaConfigs.GetArenaLevelCfgByLevel(self.Data.ArenaLevel)
        self.RImgArenaLevel:SetRawImage(arenaCfg.Icon)
    else
        self.ArenaLevel:SetActiveEx(false)
        self.RImgArenaLevel.gameObject:SetActiveEx(false)
    end
end

return XUiGridArenaTeamSingle
