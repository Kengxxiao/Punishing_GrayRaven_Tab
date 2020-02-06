XUiEmojiItem = XClass()--表情面板里面的item

local EmojiTag = "[%d]"

function XUiEmojiItem:Ctor(rootUi, ui)
    self.RootUi = rootUi
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()

    self.ClickCallBack = nil
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiEmojiItem:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiEmojiItem:AutoInitUi()
    self.RImgEmojiD = self.Transform:Find("RImgEmoji"):GetComponent("RawImage")
    self.BtnEmoji = self.Transform:Find("BtnEmoji"):GetComponent("Button")
end

function XUiEmojiItem:GetAutoKey(uiNode, eventName)
    if not uiNode then
        return
    end
    return eventName .. uiNode:GetHashCode()
end

function XUiEmojiItem:RegisterListener(uiNode, eventName, func)
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
            XLog.Error("XUiEmojiItem:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiEmojiItem:AutoAddListener()
    self.AutoCreateListeners = {}
    XUiHelper.RegisterClickEvent(self, self.BtnEmoji, self.OnBtnEmojiClick)
end
-- auto
function XUiEmojiItem:OnBtnEmojiClick()--发送表情
    local content = string.format(EmojiTag, self.EmojiId)
    local sendChat = {}
    sendChat.ChannelType = self.RootUi.SelType
    sendChat.MsgType = ChatMsgType.Emoji
    sendChat.Content = content
    sendChat.TargetIds = { XPlayer.Id }

    if self.RootUi then
        self.RootUi:SendChat(sendChat)
        self.RootUi:OnBtnAddClick()
    end
end

function XUiEmojiItem:Refresh(emojiId, icon)
    self.EmojiId = emojiId
    if icon ~= nil then
        self.RImgEmojiD:SetRawImage(icon)
    end
end

function XUiEmojiItem:Show()
    if self.GameObject:Exist() and self.GameObject.activeSelf == false then
        self.GameObject:SetActive(true)
    end
end

function XUiEmojiItem:Hide()
    if self.GameObject:Exist() and self.GameObject.activeSelf then
        self.GameObject:SetActive(false)
    end
end