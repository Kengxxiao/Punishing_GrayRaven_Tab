XUiPanelSocialTipsItem = XClass()

function XUiPanelSocialTipsItem:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
    self:InitAutoScript()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelSocialTipsItem:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiPanelSocialTipsItem:AutoInitUi()
    -- self.TxtInfo = self.Transform:Find("bg/TxtInfo"):GetComponent("Text")
end

function XUiPanelSocialTipsItem:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiPanelSocialTipsItem:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiPanelSocialTipsItem:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiPanelSocialTipsItem:AutoAddListener()
    self.AutoCreateListeners = {}
end
-- auto

function XUiPanelSocialTipsItem:Refresh(chatData)
    self.CreateTime = chatData.CreateTime
    self.SenderId = chatData.SenderId

    self.TxtInfo.text = XDataCenter.ChatManager.CreateGiftTips(chatData)
end

function XUiPanelSocialTipsItem:SetShow(code)
    self.GameObject.gameObject:SetActive(code)
end