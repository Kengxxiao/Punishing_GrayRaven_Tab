local XUiGridLogisticSkill = XClass()

function XUiGridLogisticSkill:Ctor(ui, viewData)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
    self:UpdateView(viewData)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiGridLogisticSkill:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiGridLogisticSkill:AutoInitUi()
    self.TxtEchelonIndex = self.Transform:Find("ImageBg/TxtEchelonIndex"):GetComponent("Text")
    self.TxtSkillDes = self.Transform:Find("TxtSkillDes"):GetComponent("Text")
end

function XUiGridLogisticSkill:GetAutoKey(uiNode, eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiGridLogisticSkill:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiGridLogisticSkill:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiGridLogisticSkill:AutoAddListener()
    self.AutoCreateListeners = {}
end
-- auto
function XUiGridLogisticSkill:UpdateView(viewData)
    local logisticSkillDes = XDataCenter.BfrtManager.GetLogisticSkillDes(viewData.EchelonId)
    self.TxtEchelonIndex.text = viewData.EchelonIndex
    self.TxtSkillDes.text = logisticSkillDes
end

return XUiGridLogisticSkill