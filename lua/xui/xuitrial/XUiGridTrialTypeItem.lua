local XUiGridTrialTypeItem = XClass()

function XUiGridTrialTypeItem:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
    self:InitAutoScript()
end


function XUiGridTrialTypeItem:Init(uiRoot)
    self.UiRoot = uiRoot
end

function XUiGridTrialTypeItem:OnRefresh(itemdata)
    if not itemdata then
        return
    end
    self.TxtName.text = itemdata.Name
end


-- auto
-- Automatic generation of code, forbid to edit
function XUiGridTrialTypeItem:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiGridTrialTypeItem:AutoInitUi()
    -- self.TxtName = self.Transform:Find("TxtName"):GetComponent("Text")
end

function XUiGridTrialTypeItem:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiGridTrialTypeItem:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiGridTrialTypeItem:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiGridTrialTypeItem:AutoAddListener()
end
-- auto

return XUiGridTrialTypeItem
