XUiPanelSocialPools = XClass()

function XUiPanelSocialPools:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
end
-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelSocialPools:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiPanelSocialPools:AutoInitUi()
    self.PanelOhterMsgItem = self.Transform:Find("PanelSocialOhterMsgItem")
    self.PanelMyMsgItem = self.Transform:Find("PanelSocialMyMsgItem")
    self.PanelTipsItem = self.Transform:Find("PanelSocialTipsItem")
    self.PanelMyMsgGiftItem = self.Transform:Find("PanelSocialMyMsgGiftItem")
    self.PanelOhterMsgGiftItem = self.Transform:Find("PanelSocialOhterMsgGiftItem")
    self.PanelMyMsgEmojiItem = self.Transform:Find("PanelSocialMyMsgEmojiItem")
    self.PanelOhterMsgEmojiItem = self.Transform:Find("PanelSocialOhterMsgEmojiItem")
end

function XUiPanelSocialPools:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiPanelSocialPools:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiPanelSocialPools:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiPanelSocialPools:AutoAddListener()
    self.AutoCreateListeners = {}
end

function XUiPanelSocialPools:InitData(dynamicList)
    self.GameObject:SetActive(false)
    dynamicList:AddObjectPools("myMsg",self.PanelMyMsgItem.gameObject)
    dynamicList:AddObjectPools("otherMsg",self.PanelOhterMsgItem.gameObject)
    dynamicList:AddObjectPools("myEmoji",self.PanelMyMsgEmojiItem.gameObject)
    dynamicList:AddObjectPools("otherEmoji",self.PanelOhterMsgEmojiItem.gameObject)
    dynamicList:AddObjectPools("myGift",self.PanelMyMsgGiftItem.gameObject)
    dynamicList:AddObjectPools("otherGift",self.PanelOhterMsgGiftItem.gameObject)
    dynamicList:AddObjectPools("tips",self.PanelTipsItem.gameObject)
end
