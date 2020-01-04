local XUiPanelBtn = XClass()

function XUiPanelBtn:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelBtn:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiPanelBtn:AutoInitUi()
    self.TxtFightTimes = self.Transform:Find("TxtFightTimes"):GetComponent("Text")
    self.BtnSub = self.Transform:Find("BtnSub"):GetComponent("Button")
    self.BtnAdd = self.Transform:Find("BtnAdd"):GetComponent("Button")
    self.BtnStart = self.Transform:Find("BtnStart"):GetComponent("Button")
end

function XUiPanelBtn:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelBtn:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelBtn:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelBtn:AutoAddListener()
    self:RegisterClickEvent(self.BtnSub, self.OnBtnSubClick)
    self:RegisterClickEvent(self.BtnAdd, self.OnBtnAddClick)
    self:RegisterClickEvent(self.BtnStart, self.OnBtnStartClick)
end
-- auto

function XUiPanelBtn:OnBtnSubClick(eventData)

end

function XUiPanelBtn:OnBtnAddClick(eventData)

end

function XUiPanelBtn:OnBtnStartClick(eventData)

end

return XUiPanelBtn
