XUiGridEmoji = XClass()

local EmojiTag = "[%d]"

function XUiGridEmoji:Ctor(rootUi, ui, parent)
    self.RootUi = rootUi
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    if emojiPanel then
        self.MainPanel = emojiPanel
    end
    XTool.InitUiObject(self)
    self:InitAutoScript()

    self.ClickCallBack = nil
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiGridEmoji:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiGridEmoji:AutoInitUi()
    -- self.RImgEmojiD = self.Transform:Find("RImgEmoji"):GetComponent("RawImage")
    -- self.BtnEmoji = self.Transform:Find("BtnEmoji"):GetComponent("Button")
end

function XUiGridEmoji:GetAutoKey(uiNode, eventName)
    if not uiNode then
        return
    end
    return eventName .. uiNode:GetHashCode()
end

function XUiGridEmoji:RegisterListener(uiNode, eventName, func)
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
            XLog.Error("XUiGridEmoji:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiGridEmoji:AutoAddListener()
    self.AutoCreateListeners = {}
    XUiHelper.RegisterClickEvent(self, self.BtnEmoji, self.OnBtnEmojiClick)
end
-- auto

function XUiGridEmoji:OnBtnEmojiClick(...)
    if self.ClickCallBack then
        local content = string.format(EmojiTag, self.EmojiId)
        self.ClickCallBack(content)
    end
end

function XUiGridEmoji:Refresh(emojiId, icon)
    self.EmojiId = emojiId
    if icon ~= nil then
        self.RImgEmojiD:SetRawImage(icon)
    end
end

function XUiGridEmoji:SetClickCallBack(cb)
    self.ClickCallBack = cb
end

function XUiGridEmoji:Show()
    if self.GameObject:Exist() and self.GameObject.activeSelf == false then
        self.GameObject:SetActive(true)
    end
end

function XUiGridEmoji:Hide()
    if self.GameObject:Exist() and self.GameObject.activeSelf then
        self.GameObject:SetActive(false)
    end
end 