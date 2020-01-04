local XUiGridGain = XClass()

function XUiGridGain:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiGridGain:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiGridGain:AutoInitUi()
end

function XUiGridGain:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiGridGain:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiGridGain:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiGridGain:AutoAddListener()
    self.AutoCreateListeners = {}
end
-- auto

return XUiGridGain
