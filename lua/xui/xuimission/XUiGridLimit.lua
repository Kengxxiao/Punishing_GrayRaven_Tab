XUiGridLimit = XClass()

function XUiGridLimit:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
end

function XUiGridLimit:SetupContent(data,curId)
    if not data then
        return
    end

    self.PanelLock.gameObject:SetActive(data.Id > curId)
    self.PanelOpen.gameObject:SetActive(data.Id <= curId)

    local condition = XConditionManager.GetConditionTemplate(data.ConditionId)
    self.Txt1.text = tostring(data.MaxTaskForceCount)
    self.Txt1A.text = tostring(data.MaxTaskForceCount)
    
    self.Txt2A.text = tostring(condition.Desc)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiGridLimit:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiGridLimit:AutoInitUi()
    self.PanelOpen = self.Transform:Find("PanelOpen")
    self.Txt1 = self.Transform:Find("PanelOpen/Txt1"):GetComponent("Text")
    self.Txt2 = self.Transform:Find("PanelOpen/Txt2"):GetComponent("Text")
    self.PanelLock = self.Transform:Find("PanelLock")
    self.Txt1A = self.Transform:Find("PanelLock/Txt1"):GetComponent("Text")
    self.Txt2A = self.Transform:Find("PanelLock/Txt2"):GetComponent("Text")
end

function XUiGridLimit:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiGridLimit:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiGridLimit:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiGridLimit:AutoAddListener()
    self.AutoCreateListeners = {}
end
-- auto

return XUiGridLimit
