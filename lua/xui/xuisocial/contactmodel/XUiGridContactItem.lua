local XUiGridContactItem = XClass()

function XUiGridContactItem:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
    self:InitAutoScript()
end

function XUiGridContactItem:ResetStatus(...)
    self.TogSelect.gameObject:SetActiveEx(false)
end

function XUiGridContactItem:Init(mainPanel, parent)
    self.MainPanel = mainPanel
    self.Parent = parent

    XEventManager.AddEventListener(XEventId.EVENT_CHAT_RECEIVE_PRIVATECHAT, self.NewChatMsgHandler, self)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiGridContactItem:InitAutoScript()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiGridContactItem:GetAutoKey(uiNode, eventName)
    if not uiNode then
        return
    end
    return eventName .. uiNode:GetHashCode()
end

function XUiGridContactItem:RegisterListener(uiNode, eventName, func)
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
            XLog.Error("XUiGridContactItem:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiGridContactItem:AutoAddListener()
    self.AutoCreateListeners = {}
    XUiHelper.RegisterClickEvent(self, self.BtnView, self.OnBtnViewClick)
    self:RegisterListener(self.TogSelect, "onValueChanged", self.OnTogSelectValueChanged)
    self.PanelChat.CallBack = function () self:OnBtnChatClick() end
end
-- auto

function XUiGridContactItem:OnTogSelectValueChanged()
    if self.IsDeleting then
        self.Parent:SetSelectDeleteId(self.Id, self.TogSelect.isOn)
    end
end

function XUiGridContactItem:OnBtnChatClick(...)
    --进入私聊
    --关闭新消息提示
    self.TxtNewMessage.text = ''
    self.MainPanel:OpenPrivateChatView(self.Id)

    XDataCenter.ChatManager.SetPrivateChatReadByFriendId(self.Id)
end

function XUiGridContactItem:OnBtnViewClick(...)
    --个人信息
    XDataCenter.PersonalInfoManager.ReqShowInfoPanel(self.Id, nil, function(...)
        -- body
    end)
end

function XUiGridContactItem:ShowDeleteState(isDelete, selectDelete)
    self.IsDeleting = isDelete
    self.TogSelect.gameObject:SetActiveEx(isDelete)
    self.TogSelect.isOn = selectDelete
    self:ShowGift(not isDelete)
end

function XUiGridContactItem:SetSelectDelete(isSelect)
    self.TogSelect.isOn = isSelect
end

function XUiGridContactItem:Refresh(data, isDelete, selectDelete)
    if data == nil then
        return
    end
    
    local medalConfig = XMedalConfigs.GetMeadalConfigById(data.CurrMedalId)
    local medalIcon = nil
    if medalConfig then 
        medalIcon = medalConfig.MedalIcon
    end
    if medalIcon ~= nil then
        self.MedalRawImage:SetRawImage(medalIcon)
        self.MedalRawImage.gameObject:SetActiveEx(true)
    else
        self.MedalRawImage.gameObject:SetActiveEx(false)
    end
    
    self:ResetStatus()
    self.Data = data
    self.Id = data.FriendId
    self.TxtName.text = data.NickName
    self.TxtLevel.text = data.Level
    self.TxtFetterLevel.text = XDataCenter.SocialManager.GetFriendExpLevel(data.FriendId)

    if data.IsOnline then
        self.TxtOnline.gameObject:SetActiveEx(true)
        self.PanelRoleOffLine.gameObject:SetActiveEx(false)
        self.PanelRoleOnLine.gameObject:SetActiveEx(true)
        self.TxtRecentLoginTime.text = ""
    else
        self.TxtOnline.gameObject:SetActiveEx(false)
        self.PanelRoleOffLine.gameObject:SetActiveEx(true)
        self.PanelRoleOnLine.gameObject:SetActiveEx(false)
        self.TxtRecentLoginTime.text = CS.XTextManager.GetText("FriendLatelyLogin") .. XUiHelper.CalcLatelyLoginTime(data.LastLoginTime)
    end

    local headInfo = XPlayerManager.GetHeadPortraitInfoById(data.Icon)
    if headInfo ~= nil then
        self.ImgIconOnLine:SetRawImage(headInfo.ImgSrc)
        self.ImgIconOffLine:SetRawImage(headInfo.ImgSrc)
        
        if headInfo.Effect then
            self.HeadIconEffectOn.gameObject:LoadPrefab(headInfo.Effect)
            self.HeadIconEffectOn.gameObject:SetActiveEx(true)
            self.HeadIconEffectOn:Init()
        else
            self.HeadIconEffectOn.gameObject:SetActiveEx(false)
        end
    end

    self:Show()
    self:ShowDeleteState(isDelete, selectDelete)
end

function XUiGridContactItem:ShowGift(show)
    --是否有礼物标识
    if show then
        local haveGift = XDataCenter.ChatManager.CheckDoesHaveGiftByFriendId(self.Id)
        self.GridCommon.gameObject:SetActiveEx(haveGift)
        self.ImgNone.gameObject:SetActiveEx(not haveGift)
    else
        self.GridCommon.gameObject:SetActiveEx(false)
        self.ImgNone.gameObject:SetActiveEx(false)
    end
end

function XUiGridContactItem:Show()
    self.GameObject:SetActiveEx(true)

    local chatDataList = XDataCenter.ChatManager.GetPrivateDynamicList(self.Id)
    if not chatDataList or #chatDataList <= 0 then
        self.TxtNewMessage.text = ""
        self:UpdateReadStatus()
        return
    end

    local msg = chatDataList[1]
    if msg then
        self:NewChatMsgHandler(msg)
    end
    self:UpdateReadStatus()
end

function XUiGridContactItem:NewChatMsgHandler(chatData)
    --接收到新消息
    if (chatData:GetChatTargetId() ~= self.Id) then
        return
    end
    if XTool.UObjIsNil(self.GameObject) then
        return
    end

    self:UpdateReadStatus()

    if chatData.MsgType == ChatMsgType.Emoji then
        self.TxtNewMessage.text = CS.XTextManager.GetText("EmojiText")
    elseif chatData.MsgType == ChatMsgType.Tips then
        self.TxtNewMessage.text = XDataCenter.ChatManager.CreateGiftTips(chatData)
    elseif chatData.MsgType == ChatMsgType.Gift then
        self.TxtNewMessage.text = XDataCenter.ChatManager.CreateGiftTips(chatData)
    else
        self.TxtNewMessage.text = chatData.Content
        if not string.IsNilOrEmpty(chatData.CustomContent)  then
            self.TxtNewMessage.supportRichText = true
        else
            self.TxtNewMessage.supportRichText = false
        end

    end

    self:ShowGift(true)
end

function XUiGridContactItem:UpdateReadStatus()
    local code = XDataCenter.ChatManager.GetPrivateUnreadChatCountByFriendId(self.Id) > 0

    self.ImgNewChatOff.gameObject:SetActiveEx(not code)
    self.ImgNewChatOn.gameObject:SetActiveEx(code)
end

return XUiGridContactItem