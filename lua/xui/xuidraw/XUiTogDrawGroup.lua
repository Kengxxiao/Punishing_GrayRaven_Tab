local XUiTogDrawGroup = XClass()

function XUiTogDrawGroup:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiTogDrawGroup:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiTogDrawGroup:AutoInitUi()
    self.TogDrawGroup = self.Transform:GetComponent("Toggle")
    self.TxtTabName = self.Transform:Find("TxtTabName"):GetComponent("Text")
    self.PanelTag = self.Transform:Find("PanelTag")
    self.TxtTagName = self.Transform:Find("PanelTag/TxtTagName"):GetComponent("Text")
end

function XUiTogDrawGroup:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiTogDrawGroup:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiTogDrawGroup:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiTogDrawGroup:AutoAddListener()
    self:RegisterClickEvent(self.TogDrawGroup, self.OnTogDrawGroupClick)
end
-- auto

function XUiTogDrawGroup:OnTogDrawGroupClick(eventData)

end

return XUiTogDrawGroup
