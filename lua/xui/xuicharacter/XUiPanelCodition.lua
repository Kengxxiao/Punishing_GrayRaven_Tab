XUiPanelCodition = XClass()

function XUiPanelCodition:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelCodition:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiPanelCodition:AutoInitUi()
    self.TxtSatisfy = self.Transform:Find("TxtSatisfy"):GetComponent("Text")
    self.TxtDissatisfy = self.Transform:Find("TxtDissatisfy"):GetComponent("Text")
end

function XUiPanelCodition:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiPanelCodition:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiPanelCodition:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiPanelCodition:AutoAddListener()
    self.AutoCreateListeners = {}
end
-- auto
function XUiPanelCodition:Refresh(data)
    local ret, desc = XConditionManager.CheckCondition(data.conditionId, data.charId)
    self.TxtSatisfy.text = desc
    self.TxtDissatisfy.text = desc
    self.TxtSatisfy.gameObject:SetActive(not ret)
    self.TxtDissatisfy.gameObject:SetActive( ret)
end

function XUiPanelCodition:RefreshCoin(data)
    self.TxtSatisfy.text = data.Desc
    self.TxtDissatisfy.text = data.Desc
    self.TxtSatisfy.gameObject:SetActive(not data.isEnough)
    self.TxtDissatisfy.gameObject:SetActive( data.isEnough)
end
