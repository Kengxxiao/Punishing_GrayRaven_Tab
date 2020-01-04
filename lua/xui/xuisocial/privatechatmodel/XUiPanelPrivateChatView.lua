XUiPanelPrivateChatView = XClass()
local XUiTogFriendBox = require("XUi/XUiSocial/PrivateChatModel/ItemModel/XUiTogFriendBox")

WorldChatBoxType = {
    OtherChatBox = 1,
    OtherChatBoxEmoji = 2,
    SelfChatBox = 3,
    SelfChatBoxEmoji = 4
}

function XUiPanelPrivateChatView:Ctor(rootUi, ui, emojiPanel)
    self.RootUi = rootUi
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
    self.ChatButtonGroups = {}
    self.FriendId = 0
    self:InitView()
    self:Hide()
    self.XUiPanelFriendEmoji = XUiPanelFriendEmoji.New(self.PanelEmoji, self.RootUi, self)
    local clickCallBack = function(content)
        self.XUiPanelFriendEmoji:Hide()
        self:OnClickEmoji(content)
    end
    self.XUiPanelFriendEmoji:SetClickCallBack(clickCallBack)

    self.XUiPanelSocialPools = XUiPanelSocialPools.New(self.PanelSocialPools)

    self.PrivateDynamicList = XDynamicList.New(self.PanelChatView.transform, self)
    self.PrivateDynamicList:SetReverse(true)

    self.PanelMsgListPools = XUiPanelSocialPools.New(self.PanelMsgListPools)
    self.PanelMsgListPools:InitData(self.PrivateDynamicList)

    self.GroupDynamicListManager = XDynamicTableNormal.New(self.ContactGroupList)
    self.GroupDynamicListManager:SetProxy(XUiTogFriendBox)
    self.GroupDynamicListManager:SetDelegate(self)
    self.GroupDynamicListManager:SetDynamicEventDelegate(function (...) self:OnGroupDynamicTableEvent(...) end)
end

function XUiPanelPrivateChatView:InitView()
    --初始化View
    self.PanelEmoji.gameObject:SetActive(false)
    self.PanelInputField.characterLimit = CS.XGame.ClientConfig:GetInt("PrivateChatTextLimit")
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelPrivateChatView:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiPanelPrivateChatView:AutoInitUi()
    self.PanelChatView = self.Transform:Find("Content/MsgList/Content/PanelChatView"):GetComponent("XVerticalDynamicList")
    self.PanelSocialPools = self.Transform:Find("Content/MsgList/Content/PanelChatView/PanelSocialPools")
    self.PanelInputField = self.Transform:Find("Content/MsgList/Share/PanelInputField"):GetComponent("InputField")
    self.ContactGroupList = self.Transform:Find("Content/ContactGroupList")
    self.PanelEmoji = self.Transform:Find("Content/MsgList/Share/PanelEmoji")
    self.PanelMsgListPools = self.Transform:Find("Content/MsgList/Content/PanelChatView/PanelSocialPools")
    self.BtnSendMsg = self.Transform:Find("Content/MsgList/Share/BtnSendMsg"):GetComponent("XUiButton")
    self.BtnEmoji = self.Transform:Find("Content/MsgList/Share/BtnEmoji"):GetComponent("XUiButton")
    self.BtnLuomu = self.Transform:Find("Content/MsgList/Share/BtnLuomu"):GetComponent("XUiButton")
end

function XUiPanelPrivateChatView:GetAutoKey(uiNode, eventName)
    if not uiNode then
        return
    end
    return eventName .. uiNode:GetHashCode()
end

function XUiPanelPrivateChatView:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then
        return
    end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiPanelPrivateChatView:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiPanelPrivateChatView:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterListener(self.BtnSendMsg, "onClick", self.OnBtnSendMsgClick)

    self.BtnSendMsg.CallBack = function () self:OnBtnSendMsgClick() end
    self.BtnEmoji.CallBack = function () self:OnBtnEmojiPanelClick() end
    self.BtnLuomu.CallBack = function () self:OnBtnCoinPanelClick() end
end
-- auto


function XUiPanelPrivateChatView:OnBtnSendMsgClick(...)
    --发送聊天消息
    local text = self.PanelInputField.text
    if text == nil or text == "" then
        return
    end

    self.PanelInputField.text = ""

    -- 替换空白控制符
    text = string.gsub(text, "%s", " ")

    local sendChat = {}
    sendChat.ChannelType = ChatChannelType.Private
    sendChat.MsgType = ChatMsgType.Normal
    sendChat.Content = text
    sendChat.TargetIds = { self.FriendId }
    XDataCenter.ChatManager.SendChat(sendChat, nil, true)
end

function XUiPanelPrivateChatView:OnBtnAddClick(...)
    if self.PanelEmoji.gameObject.activeInHierarchy then
        self.PanelEmoji.gameObject:SetActive(false)
    end
end

function XUiPanelPrivateChatView:OnBtnEmojiPanelClick(...)
    --打开表情面板
    self.XUiPanelFriendEmoji:OpenOrClosePanel()
end

function XUiPanelPrivateChatView:OnBtnCoinPanelClick(...)
    --发送螺母
    if XDataCenter.SocialManager.GetFriendInfo(self.FriendId) == nil then
        XUiManager.TipError(CS.XTextManager.GetText("ChatManagerNotSendCoinToNotFriend"))
        return 
    end
    
    local sendChat = {}
    sendChat.ChannelType = ChatChannelType.Private
    sendChat.MsgType = ChatMsgType.Gift
    sendChat.Content = ""
    sendChat.TargetIds = { self.FriendId }

    XDataCenter.ChatManager.SendChat(sendChat)
end

function XUiPanelPrivateChatView:OnBtnPanelChooseBackClick(...)
    self.XUiPanelFriendEmoji:Hide()
end

function XUiPanelPrivateChatView:OnClickEmoji(content)
    --发送表情
    local sendChat = {}
    sendChat.ChannelType = ChatChannelType.Private
    sendChat.MsgType = ChatMsgType.Emoji
    sendChat.Content = content
    sendChat.TargetIds = { self.FriendId }
    XDataCenter.ChatManager.SendChat(sendChat)
end

-----------------------------------------------------------------------------------
function XUiPanelPrivateChatView:OnEnable()
    if self.GameObject.activeSelf == false then
        return
    end
    self:InitData()
end

function XUiPanelPrivateChatView:Refresh(friendId)
    --friend为选中的玩家ID
    self.GameObject:SetActive(true)
    self.RootUi:PlayAnimation("PrivateChatViewEnable")
    self.FriendId = friendId
    self:InitData()

    XEventManager.AddEventListener(XEventId.EVENT_CHAT_RECEIVE_PRIVATECHAT, self.NewChatMsgHandler, self)
end

function XUiPanelPrivateChatView:InitData()
    XDataCenter.ChatManager.UpdateGiftStatus()

    self:UpdatePrivateDynamicList()

    self:UpdateGroupDynamicList()
end

function XUiPanelPrivateChatView:UpdatePrivateDynamicList()
    local msgData = XDataCenter.ChatManager.GetPrivateDynamicList(self.FriendId)
    --初始化私聊动态列表数据
    self.PrivateDynamicList:SetData(msgData, function(data, cb)
        local poolName = nil
        local ctor = nil
        if data.MsgType == ChatMsgType.Normal and data.SenderId == XPlayer.Id then
            poolName = "myMsg"
            ctor = XUiPanelSocialMyMsgItem.New
        elseif data.MsgType == ChatMsgType.Normal and data.SenderId ~= XPlayer.Id then
            poolName = "otherMsg"
            ctor = XUiPanelSocialMyMsgItem.New
        elseif data.MsgType == ChatMsgType.Emoji and data.SenderId == XPlayer.Id then
            poolName = "myEmoji"
            ctor = XUiPanelSocialMyMsgEmojiItem.New
        elseif data.MsgType == ChatMsgType.Emoji and data.SenderId ~= XPlayer.Id then
            poolName = "otherEmoji"
            ctor = XUiPanelSocialMyMsgEmojiItem.New
        elseif data.MsgType == ChatMsgType.Gift and data.SenderId == XPlayer.Id then
            poolName = "myGift"
            ctor = XUiPanelSocialMyMsgGiftItem.New
        elseif data.MsgType == ChatMsgType.Gift and data.SenderId ~= XPlayer.Id then
            poolName = "otherGift"
            ctor = XUiPanelSocialMyMsgGiftItem.New
        elseif data.MsgType == ChatMsgType.Tips then
            poolName = "tips"
            ctor = XUiPanelSocialTipsItem.New
        end
        if cb and poolName and ctor then
            local item = cb(poolName, ctor)
            item.RootUi = self.RootUi
            item.Parent = self
            item:Refresh(data)
        else
            XLog.Error("------Init social privateChatData item is error!------")
        end
    end)

    XDataCenter.ChatManager.SetPrivateChatReadByFriendId(self.FriendId)
end

function XUiPanelPrivateChatView:UpdateGroupDynamicList()
    self.FriendGroupData = XDataCenter.ChatManager.GetPrivateChatGroupData(self.FriendId)

    self.GroupDynamicListManager:SetDataSource(self.FriendGroupData)
    self.GroupDynamicListManager:ReloadDataASync()
end

function XUiPanelPrivateChatView:OnDynamicTableEvent(event, index, grid)

end

function XUiPanelPrivateChatView:OnGroupDynamicTableEvent(event, index, grid)
    local friend = self.FriendGroupData[index]

    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:Init(self.RootUi)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        grid:Refresh(friend, friend.FriendId == self.FriendId)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then
        local lastIndex, lastFriend = self:GetGroupDataByFriendId(self.FriendId)
        local lastGrid = self.GroupDynamicListManager:GetGridByIndex(lastIndex)
        if lastGrid then
            lastGrid:Refresh(lastFriend, false)
        end

        self.FriendId = friend.FriendId
        self:UpdatePrivateDynamicList()
        grid:Refresh(friend, true)
    end
end

function XUiPanelPrivateChatView:GetGroupDataByFriendId(friendId)
    for k, friend in pairs(self.FriendGroupData) do
        if friendId == friend.FriendId then
            return k, friend
        end
    end
end

function XUiPanelPrivateChatView:Hide()
    XEventManager.RemoveEventListener(XEventId.EVENT_CHAT_RECEIVE_PRIVATECHAT, self.NewChatMsgHandler, self)

    if not XTool.UObjIsNil(self.GameObject) and self.GameObject.activeSelf then
        self.GameObject:SetActive(false)
    end
end

--当有新的私聊进来的时候调用
function XUiPanelPrivateChatView:NewChatMsgHandler(chatData, isInit)
    if chatData == nil then
        return
    end

    if (chatData.ChannelType ~= ChatChannelType.Private and chatData.ChaneelType ~= ChatChannelType.PrivateInvite) then
        return
    end

    self:UpdateGroupDynamicList()

    if self.FriendId ~= chatData.TargetId and self.FriendId ~= chatData.SenderId then
        return
    end

    self:UpdatePrivateDynamicList()
end

function XUiPanelPrivateChatView:OnClose()
    XEventManager.RemoveEventListener(XEventId.EVENT_CHAT_RECEIVE_PRIVATECHAT, self.NewChatMsgHandler, self)
end