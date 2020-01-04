XUiPanelGroupPools = XClass()

function XUiPanelGroupPools:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelGroupPools:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiPanelGroupPools:AutoInitUi()
    self.TogFriendBox = self.Transform:Find("TogFriendBox"):GetComponent("Toggle")
end

function XUiPanelGroupPools:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiPanelGroupPools:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiPanelGroupPools:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiPanelGroupPools:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterListener(self.TogFriendBox, "onValueChanged", self.OnTogFriendBoxValueChanged)
end
-- auto

function XUiPanelGroupPools:InitData(dynamicList)
    self.GameObject:SetActive(false)
    dynamicList:AddObjectPools("groupItem",self.TogFriendBox.gameObject)
end
