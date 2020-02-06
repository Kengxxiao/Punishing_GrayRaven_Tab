local XUiAwarenessTfBtnPos = XClass()

--has:是否拥有1个以上该位置的意识
function XUiAwarenessTfBtnPos:Ctor(ui, pos, posNum, templateId, cb)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Pos = pos
    self.PosNum = posNum
    self.CallBack = cb
    self.TemplateId = templateId
    self:InitAutoScript()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiAwarenessTfBtnPos:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiAwarenessTfBtnPos:AutoInitUi()
    self.TxtPosNum = self.Transform:Find("TxtPosNum"):GetComponent("Text")
    self.UiBtnBackHas = self.Transform:Find("UiBtnBackHas")
    self.UiBtnBackNone = self.Transform:Find("UiBtnBackNone")
    self.UiSelectBG = self.Transform:Find("UiSelectBG")
    self.BtnPos = self.Transform:Find("BtnPos"):GetComponent("Button")
end

function XUiAwarenessTfBtnPos:AutoAddListener()
    self.AutoCreateListeners = {}
    XUiHelper.RegisterClickEvent(self, self.BtnPos, self.OnBtnPosClick)
end
-- auto
function XUiAwarenessTfBtnPos:GetAutoKey(uiNode, eventName)
    if not uiNode then
        return
    end
    return eventName .. uiNode:GetHashCode()
end

function XUiAwarenessTfBtnPos:RegisterListener(uiNode, eventName, func)
    if not uiNode then return end
    local key = eventName .. uiNode:GetHashCode()
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiBtnTab:RegisterListener: func is not a function")
        end

        listener = function(...)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiAwarenessTfBtnPos:OnBtnPosClick(eventData)
    if self.CallBack then
        self.CallBack(self.Pos)
    end
end

function XUiAwarenessTfBtnPos:Refresh(posNum, templateId)
    self.PosNum = posNum
    self.TemplateId = templateId
    self.TxtPosNum.text = self.PosNum
    if XDataCenter.EquipManager.GetEquipCountByTemplateID(self.TemplateId) > 0 then
        self.UiBtnBackHas.gameObject:SetActive(true)
        self.UiBtnBackNone.gameObject:SetActive(false)
    else
        self.UiBtnBackHas.gameObject:SetActive(false)
        self.UiBtnBackNone.gameObject:SetActive(true)
    end
end

function XUiAwarenessTfBtnPos:Select(select)
    self.UiSelectBG.gameObject.SetActive(select)
end

return XUiAwarenessTfBtnPos