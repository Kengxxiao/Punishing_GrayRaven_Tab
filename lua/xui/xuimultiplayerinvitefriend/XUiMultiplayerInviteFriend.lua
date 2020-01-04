local XUiMultiplayerInviteFriend = XLuaUiManager.Register(XLuaUi, "UiMultiplayerInviteFriend")
local XUiGridInviteFriendItem = require("XUi/XUiMultiplayerInviteFriend/XUiGridInviteFriendItem")

function XUiMultiplayerInviteFriend:OnAwake()
    self:RegisterClickEvent(self.BtnBack, self.OnBtnBackClick)
    self:RegisterClickEvent(self.BtnMainUi, self.OnBtnMainUiClick)
    self.GridInviteFriendItem.gameObject:SetActive(false)
end

function XUiMultiplayerInviteFriend:OnStart(...)
    self.Invited = {}
    self.ItemsPool = {}
    self.DynamicListManager = XDynamicTableNormal.New(self.PanelContactView)
    self.DynamicListManager:SetProxy(XUiGridInviteFriendItem)
    self.DynamicListManager:SetDelegate(self)
    XDataCenter.SocialManager.GetFriendsInfo(handler(self, self.Refresh))
end

function XUiMultiplayerInviteFriend:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:SetRootUi(self)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local data = self.FriendList[index]
        grid:Refresh(data, self.Invited[data.FriendId])
    end
end

function XUiMultiplayerInviteFriend:Refresh()
    self.FriendList = XDataCenter.SocialManager.GetFriendList()
    self.PanelTips.gameObject:SetActive(#self.FriendList == 0)
    self.DynamicListManager:SetDataSource(self.FriendList)
    self.DynamicListManager:ReloadDataASync()
end

function XUiMultiplayerInviteFriend:OnClickInvite(data)
    local cfgData = XDataCenter.FubenManager.GetStageCfg(XDataCenter.RoomManager.RoomData.StageId)
    local content = CS.XTextManager.GetText("OnlineInviteFriend", XPlayer.Name, cfgData.Name)
    local customContent = CS.XTextManager.GetText("OnlineInviteLink", XDataCenter.RoomManager.RoomData.Id .. "|" .. XDataCenter.RoomManager.RoomData.StageId)
    local sendChat = {}
    sendChat.ChannelType = ChatChannelType.Private
    sendChat.MsgType = ChatMsgType.Normal
    sendChat.Content = content
    sendChat.CustomContent = XMessagePack.Encode(customContent)
    sendChat.TargetIds = { data.FriendId }
    self.Invited[data.FriendId] = true
    XDataCenter.ChatManager.SendChat(sendChat, function(...)
        XUiManager.TipText("OnlineSendWorldSuccess")
    end, true)
end

function XUiMultiplayerInviteFriend:OnBtnBackClick(eventData)
    self:Close()
end

function XUiMultiplayerInviteFriend:OnBtnMainUiClick(eventData)
    XLuaUiManager.RunMain()
end