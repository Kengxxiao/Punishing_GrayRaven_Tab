local XUiTogFriendBox = XClass()

function XUiTogFriendBox:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform

    self:InitAutoScript()
end

function XUiTogFriendBox:Init(rootUi)
    self.RootUi = rootUi
    self.ImgNewTag.gameObject:SetActive(false)
    self.RedPointId = XRedPointManager.AddRedPointEvent(self.ImgNewTag,self.OnCheckUnReadMsgCount,self,{ XRedPointConditions.Types.CONDITION_FRIEND_CHAT_PRIVATE },nil,false)
end

function XUiTogFriendBox:OnCheckUnReadMsgCount(count,args)
    if args == self.FriendId then
        self.ImgNewTag.gameObject:SetActive(count >= 0)
        self.TxtUnMsgCount.text = tostring(count)
    end
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiTogFriendBox:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiTogFriendBox:AutoInitUi()
    self.BtnBackground = self.Transform:Find("BtnBackground"):GetComponent("XUiButton")
    self.ImgNewTag = self.Transform:Find("ImgNewTag"):GetComponent("Image")
    self.TxtUnMsgCount = self.Transform:Find("ImgNewTag/TxtUnMsgCount"):GetComponent("Text")
    self.ImgFriendIcon = self.Transform:Find("PanelRole/ImgFriendIcon"):GetComponent("RawImage")
    self.HeadIconEffect = self.Transform:Find("PanelRole/ImgFriendIcon/Effect"):GetComponent("XUiEffectLayer")
end

function XUiTogFriendBox:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiTogFriendBox:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiTogFriendBox:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiTogFriendBox:AutoAddListener()
    self.AutoCreateListeners = {}
end

function XUiTogFriendBox:SetSelect(isSelect)
    if isSelect then
        self.BtnBackground:SetButtonState(CS.UiButtonState.Select)
    else
        self.BtnBackground:SetButtonState(CS.UiButtonState.Normal)
    end

    self.isSelect = isSelect
end

function XUiTogFriendBox:UpdateLastChatText()
    local chatDataList = XDataCenter.ChatManager.GetPrivateDynamicList(self.FriendId)
    if not chatDataList or #chatDataList <= 0 then
        self.BtnBackground:SetTxtByObjName("TxtNewChat", "")
        return
    end

    local chatData = chatDataList[1]
    if chatData.MsgType == ChatMsgType.Emoji then
        self.BtnBackground:SetTxtByObjName("TxtNewChat", CS.XTextManager.GetText("EmojiText"))
    elseif chatData.MsgType == ChatMsgType.Tips then
        self.BtnBackground:SetTxtByObjName("TxtNewChat", XDataCenter.ChatManager.CreateGiftTips(chatData))
    elseif chatData.MsgType == ChatMsgType.Gift then
        self.BtnBackground:SetTxtByObjName("TxtNewChat", XDataCenter.ChatManager.CreateGiftTips(chatData))
    else
        self.BtnBackground:SetTxtByObjName("TxtNewChat", chatData.Content)
    end
end

function XUiTogFriendBox:SetHead(icon)
    local info = XPlayerManager.GetHeadPortraitInfoById(icon)
    if info then
        self.ImgFriendIcon:SetRawImage(info.ImgSrc)
        
        if info.Effect then
            self.HeadIconEffect.gameObject:LoadPrefab(info.Effect)
            self.HeadIconEffect.gameObject:SetActiveEx(true)
            self.HeadIconEffect:Init()
        else
            self.HeadIconEffect.gameObject:SetActiveEx(false)
        end
    end
end

function XUiTogFriendBox:Refresh(friendData, isSelect)
    if friendData == nil then
        return
    end

    self.FriendId = friendData.FriendId

    self:SetSelect(isSelect)

    self:SetHead(friendData.Icon)
    self:UpdateLastChatText()
    self.BtnBackground:SetTxtByObjName("TxtFriendName", friendData.NickName)

    XRedPointManager.Check(self.RedPointId, self.FriendId)
end


return XUiTogFriendBox