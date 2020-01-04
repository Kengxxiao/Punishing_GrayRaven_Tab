local XUiGridMulitiplayerRoomChar = XClass()

function XUiGridMulitiplayerRoomChar:Ctor(ui, parent, index, rolePanel)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Parent = parent
    self.Index = index
    self.RolePanel = rolePanel
    XTool.InitUiObject(self)

    XUiHelper.RegisterClickEvent(self, self.BtnDetailInfo, self.OnBtnDetailInfoClick)
    XUiHelper.RegisterClickEvent(self, self.BtnAddFriend, self.OnBtnAddFriendClick)
    XUiHelper.RegisterClickEvent(self, self.BtnChangeLeader, self.OnBtnChangeLeaderClick)
    XUiHelper.RegisterClickEvent(self, self.BtnKick, self.OnBtnKickClick)
    XUiHelper.RegisterClickEvent(self, self.BtnItem, self.OnBtnItemClick)
    XUiHelper.RegisterClickEvent(self, self.BtnFriend, self.OnBtnFriendClick)
    XUiHelper.RegisterClickEvent(self, self.BtnWorld, self.OnBtnWorldClick)
    XUiHelper.RegisterClickEvent(self, self.BtnTeam, self.OnBtnTeamClick)

    self.PanelCountDown.gameObject:SetActiveEx(false)
end

function XUiGridMulitiplayerRoomChar:InitCharData(playerData)
    self.PanelInfo.gameObject:SetActiveEx(true)
    self.PanelHaveCharacter.gameObject:SetActiveEx(true)
    self.PanelNoCharacter.gameObject:SetActiveEx(false)
    self.PanelOperation.gameObject:SetActiveEx(false)
    self:RefreshPlayer(playerData)
end

function XUiGridMulitiplayerRoomChar:InitEmpty()
    self.PlayerData = nil
    self.PanelInfo.gameObject:SetActiveEx(false)
    self.PanelHaveCharacter.gameObject:SetActiveEx(false)
    self.PanelNoCharacter.gameObject:SetActiveEx(true)
    self.PanelInvite.gameObject:SetActiveEx(false)
    self.RolePanel:HideRoleModel()
end

function XUiGridMulitiplayerRoomChar:RefreshPlayer(playerData)
    local medalConfig = XMedalConfigs.GetMeadalConfigById(playerData.MedalId)
    local medalIcon = nil
    if medalConfig then 
        medalIcon = medalConfig.MedalIcon
    end
    if medalIcon ~= nil then
        self.ImgMedalIcon:SetRawImage(medalIcon)
        self.ImgMedalIcon.gameObject:SetActiveEx(true)
    else
        self.ImgMedalIcon.gameObject:SetActiveEx(false)
    end
    
    self.PlayerData = playerData
    self.TxtName.text = playerData.Name
    self.TxtLevel.text = playerData.Level
    self.ImgLeader.gameObject:SetActiveEx(playerData.Leader)

    -- 准备状态
    if playerData.State == XDataCenter.RoomManager.PlayerState.Select then
        self.ImgReady.gameObject:SetActiveEx(false)
        self.ImgModifying.gameObject:SetActiveEx(true)
    elseif playerData.State == XDataCenter.RoomManager.PlayerState.Ready or playerData.Leader then
        self.ImgReady.gameObject:SetActiveEx(true)
        self.ImgModifying.gameObject:SetActiveEx(false)
    else
        self.ImgReady.gameObject:SetActiveEx(false)
        self.ImgModifying.gameObject:SetActiveEx(false)
    end

    -- 战斗类型
    local charId = playerData.FightNpcData.Character.Id
    local quality = playerData.FightNpcData.Character.Quality
    local npcId = XCharacterConfigs.GetCharNpcId(charId, quality)
    local npcTemplate = XCharacterConfigs.GetNpcTemplate(npcId)
    self.RImgArms:SetRawImage(XCharacterConfigs.GetNpcTypeIcon(npcTemplate.Type))

    -- 战斗力
    self.TxtAbility.text = playerData.FightNpcData.Character.Ability

    -- 操作按钮状态
    local curRole = self.Parent:GetCurRole()
    if curRole and curRole.Leader then
        self.BtnChangeLeader.ButtonState = CS.UiButtonState.Normal
        self.BtnKick.ButtonState = CS.UiButtonState.Normal
    else
        self.BtnChangeLeader.ButtonState = CS.UiButtonState.Disable
        self.BtnKick.ButtonState = CS.UiButtonState.Disable
    end

    -- 模型
    self.RolePanel:UpdateCharacterModelByFightNpcData(playerData.FightNpcData)
    self.RolePanel:ShowRoleModel()
end

function XUiGridMulitiplayerRoomChar:ShowOperationPanel()
    self.IsShowOperationPanel = not self.IsShowOperationPanel
    self.PanelOperation.gameObject:SetActiveEx(self.IsShowOperationPanel)
end

function XUiGridMulitiplayerRoomChar:ShowInvitePanel()
    self.IsShowInvitePanel = not self.IsShowInvitePanel
    self.PanelInvite.gameObject:SetActiveEx(self.IsShowInvitePanel)
end

function XUiGridMulitiplayerRoomChar:ShowSameCharTips(enable)
    self.PanelSameCharTips.gameObject:SetActive(enable)
end

function XUiGridMulitiplayerRoomChar:CloseAllOperationPanel()
    self.Parent:CloseAllOperationPanel()
end

function XUiGridMulitiplayerRoomChar:CloseOperationPanelAndInvitePanel()
    if self.PlayerData then
        self.PanelOperation.gameObject:SetActiveEx(false)
        self.IsShowOperationPanel = false
    else
        self.PanelInvite.gameObject:SetActiveEx(false)
        self.IsShowInvitePanel = false
    end
end

function XUiGridMulitiplayerRoomChar:OpenSelectCharView()
    local playerData = self.PlayerData
    if not playerData or playerData.State == XDataCenter.RoomManager.PlayerState.Ready then
        XUiManager.TipText("OnlineCancelReadyBeforeSelectCharacter")
        return
    end

    XDataCenter.RoomManager.BeginSelectRequest()
    XLuaUiManager.Open("UiRoomCharacter", {[1] = playerData.FightNpcData.Character.Id }, 1, handler(self, self.OnSelectCharacter), nil, true)
end

function XUiGridMulitiplayerRoomChar:OnSelectCharacter(charIdMap)
    if not XDataCenter.RoomManager.RoomData then
        -- 被踢出房间不回调
        return
    end

    XDataCenter.RoomManager.EndSelectRequest()

    local charId = charIdMap[1]
    XDataCenter.RoomManager.Select(charId, function(code)
        if code ~= XCode.Success then
            XUiManager.TipCode(code)
            return
        end
        XUiManager.TipText("OnlineFightSuccess", XUiManager.UiTipType.Success)
    end)
end

function XUiGridMulitiplayerRoomChar:ShowCountDownPanel(enable)
    self.PanelCountDown.gameObject:SetActiveEx(enable)
end

function XUiGridMulitiplayerRoomChar:SetCountDownTime(second)
    self.TxtCountDown.text = second
end

----------------------- 按钮回调 -----------------------

function XUiGridMulitiplayerRoomChar:OnBtnDetailInfoClick(eventData)
    -- 查看信息
    XDataCenter.PersonalInfoManager.ReqShowInfoPanel(self.PlayerData.Id, handler(self, self.CloseAllOperationPanel))
end

function XUiGridMulitiplayerRoomChar:OnBtnAddFriendClick(eventData)
    -- 加好友
    XDataCenter.SocialManager.ApplyFriend(self.PlayerData.Id, handler(self, self.CloseAllOperationPanel))
end

function XUiGridMulitiplayerRoomChar:OnBtnChangeLeaderClick(eventData)
    local curRole = self.Parent:GetCurRole()
    if not curRole or not curRole.Leader then
        return
    end

    --转移队长
    XDataCenter.RoomManager.ChangeLeader(self.PlayerData.Id, handler(self, self.CloseAllOperationPanel))
end

function XUiGridMulitiplayerRoomChar:OnBtnKickClick(eventData)
    local curRole = self.Parent:GetCurRole()
    if not curRole or not curRole.Leader then
        return
    end

    --移出队伍
    XDataCenter.RoomManager.KickOut(self.PlayerData.Id, handler(self, self.CloseAllOperationPanel))
end

function XUiGridMulitiplayerRoomChar:OnBtnItemClick(eventData)
    self.Parent:CloseAllOperationPanel(self.Index)
    if self.PlayerData then
        if self.PlayerData.Id == XPlayer.Id then
            self:OpenSelectCharView()
        else
            self:ShowOperationPanel()
        end
    else
        self:ShowInvitePanel()
    end
end

function XUiGridMulitiplayerRoomChar:OnBtnFriendClick(eventData)
    self.Parent:CloseAllOperationPanel()
    XLuaUiManager.Open("UiMultiplayerInviteFriend")
end

function XUiGridMulitiplayerRoomChar:OnBtnWorldClick(eventData)
    self.Parent:CloseAllOperationPanel()
    --邀请世界
    local cfgData = XDataCenter.FubenManager.GetStageCfg(XDataCenter.RoomManager.RoomData.StageId)
    local content = CS.XTextManager.GetText("OnlineInviteFriend", XPlayer.Name, cfgData.Name)
    local customContent = CS.XTextManager.GetText("OnlineInviteLink", XDataCenter.RoomManager.RoomData.Id .. "|" .. XDataCenter.RoomManager.RoomData.StageId)
    local sendChat = {}
    sendChat.ChannelType = ChatChannelType.World
    sendChat.Content = content
    sendChat.CustomContent = XMessagePack.Encode(customContent)
    sendChat.MsgType = ChatMsgType.Normal
    sendChat.TargetIds = { XPlayer.Id }
    local callBack = function()
        XUiManager.TipText("OnlineSendWorldSuccess")
    end
    XDataCenter.ChatManager.SendChat(sendChat, callBack, true)
end

function XUiGridMulitiplayerRoomChar:OnBtnTeamClick(eventData)
    self.Parent:CloseAllOperationPanel(self.Index)
end

return XUiGridMulitiplayerRoomChar
