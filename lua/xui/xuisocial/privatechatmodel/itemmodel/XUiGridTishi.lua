XUiGridTishi = XClass()

function XUiGridTishi:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiGridTishi:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiGridTishi:AutoInitUi()
    self.TxtInfo = self.Transform:Find("ImageBg/TxtInfo"):GetComponent("Text")
    -- self.TxtTime = XUiHelper.TryGetComponent(self.Transform, "TxtTime", "Text")
end

function XUiGridTishi:GetAutoKey(uiNode, eventName)
    if not uiNode then
        return
    end
    return eventName .. uiNode:GetHashCode()
end

function XUiGridTishi:RegisterListener(uiNode, eventName, func)
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
            XLog.Error("XUiGridTishi:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiGridTishi:AutoAddListener()
    self.AutoCreateListeners = {}
end
-- auto

function XUiGridTishi:Refresh(chatData)
    self.CreateTime = chatData.CreateTime
    self.SenderId = chatData.SenderId
    -- self.TxtTime.text = chatData:GetSendTime()
    local friend = XDataCenter.SocialManager.GetFriendInfo(chatData.TargetId)
    local text = ""
    -- if chatData:CheckIsSelfChat() then
    --     if (chatData:GetGiftChatType() == GiftChatType.Send) then
    --         text = CS.XTextManager.GetText("GiftMoneySendNotReceive", friend.Nickname, chatData.Content)
    --     else
    --         text = CS.XTextManager.GetText("GiftMoneySendHaveReceive", friend.Nickname, chatData.Content)
    --     end
    -- else
    --     if (chatData:GetGiftChatType() == GiftChatType.Send) then
    --         text = CS.XTextManager.GetText("GiftMoneyReceiveNotReceive", chatData.NickName, chatData.Content)
    --     else
    --         text = CS.XTextManager.GetText("GiftMoneyReceiveHaveReceive", chatData.NickName, chatData.Content)
    --     end
    -- end

    self.TxtInfo.text = text
end

function XUiGridTishi:Show()
    self.GameObject:SetActive(true)
end

function XUiGridTishi:Hide()
    self.GameObject:SetActive(false)
end
function XUiGridTishi:SetShow( code )
    self.GameObject:SetActive(code)
end