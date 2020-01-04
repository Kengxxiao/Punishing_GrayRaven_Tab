XUiGridFuncUpgradeResItem = XClass()

function XUiGridFuncUpgradeResItem:Ctor(rootUi, ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiGridFuncUpgradeResItem:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiGridFuncUpgradeResItem:AutoInitUi()
    self.TxtName = self.Transform:Find("TxtName"):GetComponent("Text")
    self.TxtValue = self.Transform:Find("TxtValue"):GetComponent("Text")
end

function XUiGridFuncUpgradeResItem:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiGridFuncUpgradeResItem:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiGridFuncUpgradeResItem:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiGridFuncUpgradeResItem:AutoAddListener()
    self.AutoCreateListeners = {}
end
-- auto
function XUiGridFuncUpgradeResItem:SetData(name, value)
    self.GameObject:SetActive(true)
    self.TxtName.text = name
    self.TxtValue.text = value
end