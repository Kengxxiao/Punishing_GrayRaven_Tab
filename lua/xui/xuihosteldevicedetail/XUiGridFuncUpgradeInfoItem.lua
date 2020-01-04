XUiGridFuncUpgradeInfoItem = XClass()

function XUiGridFuncUpgradeInfoItem:Ctor(rootUi, ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
    self.GameObject:SetActive(true)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiGridFuncUpgradeInfoItem:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiGridFuncUpgradeInfoItem:AutoInitUi()
    self.TxtName = self.Transform:Find("TxtName"):GetComponent("Text")
    self.TxtCurValue = self.Transform:Find("TxtCurValue"):GetComponent("Text")
    self.TxtNextValue = self.Transform:Find("TxtNextValue"):GetComponent("Text")
end

function XUiGridFuncUpgradeInfoItem:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiGridFuncUpgradeInfoItem:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiGridFuncUpgradeInfoItem:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiGridFuncUpgradeInfoItem:AutoAddListener()
    self.AutoCreateListeners = {}
end
-- auto

function XUiGridFuncUpgradeInfoItem:SetData(name, curValue, nextValue)
    self.TxtName.text = name
    self.TxtCurValue.text = curValue
    self.TxtNextValue.text = nextValue
end