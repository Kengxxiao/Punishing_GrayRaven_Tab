local XUiPanelProbability = XClass()

function XUiPanelProbability:Ctor(ui, parent)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
    self.Parent = parent
end

function XUiPanelProbability:SetData(data)
    if not data or self.Data == data then
        return
    end
    self.Data = data
    self:SetIsUp(data.IsUp)
    self.TxtName.text = data.Name
    self.TxtType.text = data.Type
    if data.IsUp then
        self.TxtUpProb.text = data.ProbShow
    else
        self.TxtNorProb.text = data.ProbShow
    end
    self:SetActive(true)
end

function XUiPanelProbability:SetIsUp(bool)
    self.TxtUp.gameObject:SetActive(bool)
    self.TxtUpProb.gameObject:SetActive(bool)
    self.TxtNorProb.gameObject:SetActive(not bool)
end

function XUiPanelProbability:SetActive(bool)
    self.GameObject:SetActive(bool)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelProbability:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiPanelProbability:AutoInitUi()
    self.TxtType = self.Transform:Find("TxtType"):GetComponent("Text")
    self.TxtName = self.Transform:Find("TxtName"):GetComponent("Text")
    self.TxtUpProb = self.Transform:Find("TxtUpProb"):GetComponent("Text")
    self.TxtNorProb = self.Transform:Find("TxtNorProb"):GetComponent("Text")
    self.TxtUp = self.Transform:Find("TxtUp"):GetComponent("Text")
end

function XUiPanelProbability:GetAutoKey(uiNode, eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiPanelProbability:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiPanelProbability:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiPanelProbability:AutoAddListener()
    self.AutoCreateListeners = {}
end
-- auto
return XUiPanelProbability