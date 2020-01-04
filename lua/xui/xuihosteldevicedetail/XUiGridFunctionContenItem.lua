XUiGridFunctionContenItem = XClass()

function XUiGridFunctionContenItem:Ctor(rootUi, ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
    self.GameObject:SetActive(true)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiGridFunctionContenItem:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiGridFunctionContenItem:AutoInitUi()
    self.TxtName = self.Transform:Find("TxtName"):GetComponent("Text")
    self.TxtValue = self.Transform:Find("TxtValue"):GetComponent("Text")
end

function XUiGridFunctionContenItem:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiGridFunctionContenItem:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiGridFunctionContenItem:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiGridFunctionContenItem:AutoAddListener()
    self.AutoCreateListeners = {}
end
-- auto

function XUiGridFunctionContenItem:SetData(name, value)
    self.GameObject:SetActive(true)
    self.TxtName.text = name
    self.TxtValue.text = value
end