local XUiGridConditionTxt = XClass()

function XUiGridConditionTxt:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
end


function XUiGridConditionTxt:SetupExtraContent(menberCount,charIds)

    self.TxtDes.text =  string.format(CS.XTextManager.GetText("MissionTaskTeamMember"),menberCount)
    self.TxtDesAct.text =  string.format(CS.XTextManager.GetText("MissionTaskTeamMember"),menberCount)

    local enough = #charIds >= menberCount
    self.TxtDes.gameObject:SetActive(not enough)
    self.TxtDesAct.gameObject:SetActive(enough)
end

function XUiGridConditionTxt:SetupContent(conditionId,charIds)
    local template = XConditionManager.GetConditionTemplate(conditionId)
    if template then
        self.TxtDes.text = template.Desc
        self.TxtDesAct.text = template.Desc
    end

    self.CharacterIds = charIds
    local enough = XConditionManager.CheckCondition(conditionId, self.CharacterIds)
    self.TxtDes.gameObject:SetActive(not enough)
    self.TxtDesAct.gameObject:SetActive(enough)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiGridConditionTxt:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiGridConditionTxt:AutoInitUi()
    self.TxtDesAct = XUiHelper.TryGetComponent(self.Transform, "TxtDesAct", "Text")
    self.TxtDes = XUiHelper.TryGetComponent(self.Transform, "TxtDes", "Text")
end

function XUiGridConditionTxt:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiGridConditionTxt:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiGridConditionTxt:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiGridConditionTxt:AutoAddListener()
    self.AutoCreateListeners = {}
end
-- auto

return XUiGridConditionTxt
