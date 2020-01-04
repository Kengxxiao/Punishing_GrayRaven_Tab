XUiPanelPushSet = XClass()

function XUiPanelPushSet:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelPushSet:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiPanelPushSet:AutoInitUi()
    self.TogFullHP = self.Transform:Find("FullHP/TogFullHP"):GetComponent("Toggle")
    self.TogDonateHP = self.Transform:Find("DonateHP/TogDonateHP"):GetComponent("Toggle")
    self.TogHouseUpdate = self.Transform:Find("HouseUpdate/TogHouseUpdate"):GetComponent("Toggle")
    self.TogWorkCom = self.Transform:Find("WorkComp/TogWorkCom"):GetComponent("Toggle")
    self.TogDispatchBack = self.Transform:Find("DispatchBack/TogDispatchBack"):GetComponent("Toggle")
end

function XUiPanelPushSet:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiPanelPushSet:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiPanelPushSet:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiPanelPushSet:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterListener(self.TogFullHP, "onValueChanged", self.OnTogFullHPValueChanged)
    self:RegisterListener(self.TogDonateHP, "onValueChanged", self.OnTogDonateHPValueChanged)
    self:RegisterListener(self.TogHouseUpdate, "onValueChanged", self.OnTogHouseUpdateValueChanged)
    self:RegisterListener(self.TogWorkCom, "onValueChanged", self.OnTogWorkComValueChanged)
    self:RegisterListener(self.TogDispatchBack, "onValueChanged", self.OnTogDispatchBackValueChanged)
end
-- auto

function XUiPanelPushSet:OnTogFullHPValueChanged(...)

end

function XUiPanelPushSet:OnTogDonateHPValueChanged(...)

end

function XUiPanelPushSet:OnTogHouseUpdateValueChanged(...)

end

function XUiPanelPushSet:OnTogWorkComValueChanged(...)

end

function XUiPanelPushSet:OnTogDispatchBackValueChanged(...)

end

function XUiPanelPushSet:OnToggleEValueChanged(...)

end

function XUiPanelPushSet:ShowPanel()
    self.IsShow = true
    self.GameObject:SetActive(true)
end

function XUiPanelPushSet:HidePanel()
    self.IsShow = false
    self.GameObject:SetActive(false)
end

function XUiPanelPushSet:CheckDataIsChange()
    
    return false
end

function XUiPanelPushSet:SaveChange()
    
end

function XUiPanelPushSet:CancelChange()

end

function XUiPanelPushSet:ResetToDefault()
    
end