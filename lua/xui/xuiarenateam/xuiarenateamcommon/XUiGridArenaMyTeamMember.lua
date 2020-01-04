local XUiGridArenaMyTeamMember = XClass()

function XUiGridArenaMyTeamMember:Ctor(ui, rootUi)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi

    XTool.InitUiObject(self)
    self:AutoAddListener()
end

function XUiGridArenaMyTeamMember:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiGridArenaMyTeamMember:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiGridArenaMyTeamMember:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiGridArenaMyTeamMember:AutoAddListener()
    self:RegisterClickEvent(self.BtnKickOut, self.OnBtnKickOutClick)
    self:RegisterClickEvent(self.BtnHead, self.OnBtnHeadClick)
    self:RegisterClickEvent(self.BtnAddTeamMember, self.OnBtnAddTeamMemberClick)
end

function XUiGridArenaMyTeamMember:OnBtnHeadClick(eventData)
    if not self.Data or self.Data.Id == XPlayer.Id then
        return
    end

    XDataCenter.PersonalInfoManager.ReqShowInfoPanel(self.Data.Id)
end

function XUiGridArenaMyTeamMember:OnBtnKickOutClick(eventData)
    if not self.Data then
        return
    end

    if self.Data.Id == XPlayer.Id then
        return
    end

    if not XDataCenter.ArenaManager.CheckSelfIsCaptain() then
        return
    end

    XUiManager.DialogTip("", CS.XTextManager.GetText("ArenaTeamKickOutMemberConfirm", self.Data.Name), XUiManager.DialogType.Normal, nil, function()
        XDataCenter.ArenaManager.RequestKickTeam(self.Data.Id)
    end)
end

function XUiGridArenaMyTeamMember:OnBtnAddTeamMemberClick(eventData)
    if self.Data then
        return
    end

    if not XDataCenter.ArenaManager.CheckSelfIsCaptain() then
        return
    end

    self.RootUi:JumpToHallPanel(2)
end

function XUiGridArenaMyTeamMember:Refresh(data)
    self.Data = data

    -- 是否队长权限
    local isSelfCaptain = XDataCenter.ArenaManager.CheckSelfIsCaptain()
    self.ImgAdd.gameObject:SetActive(isSelfCaptain)
    self.BtnKickOut.gameObject:SetActive(isSelfCaptain)

    -- 没有队员
    if not data then
        self.PanelSomeOne.gameObject:SetActive(false)
        self.PanelNone.gameObject:SetActive(true)
        return
    end

    -- 有队员
    self.PanelSomeOne.gameObject:SetActive(true)
    self.PanelNone.gameObject:SetActive(false)

    -- 是否队长
    local isCaptain = XDataCenter.ArenaManager.CheckPlayerIsCaptain(self.Data.Id)
    self.ImgCaptain.gameObject:SetActive(isCaptain)

    -- 是否自己
    local isSelf = self.Data.Id == XPlayer.Id
    self.PanelSelf.gameObject:SetActive(isSelf)
    self.PanelOthers.gameObject:SetActive(not isSelf)

    -- 显示信息
    self.TxtNickname.text = self.Data.Name
    self.TxtPlayerLevel.text = self.Data.Level
    self.TxtOnline.gameObject:SetActive(self.Data.Online == 1)
    self.TxtOffline.gameObject:SetActive(self.Data.Online ~= 1)
    local info = XPlayerManager.GetHeadPortraitInfoById(self.Data.CurrHeadPortraitId)
    if (info ~= nil) then
        self.RImgHeadIcon:SetRawImage(info.ImgSrc)
    end
end

return XUiGridArenaMyTeamMember
