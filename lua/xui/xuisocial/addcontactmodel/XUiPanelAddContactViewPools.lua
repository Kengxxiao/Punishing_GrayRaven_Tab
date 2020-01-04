XUiPanelAddContactViewPools = XClass()

function XUiPanelAddContactViewPools:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelAddContactViewPools:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiPanelAddContactViewPools:AutoInitUi()
    self.GridAddContact = self.Transform:Find("GridAddContact")
end

function XUiPanelAddContactViewPools:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiPanelAddContactViewPools:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiPanelAddContactViewPools:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiPanelAddContactViewPools:AutoAddListener()
    self.AutoCreateListeners = {}
end
-- auto

function XUiPanelAddContactViewPools:InitData(dynamicList)
    self.GameObject:SetActive(false)
    dynamicList:AddObjectPools("contactItem",self.GridAddContact.gameObject)
end
