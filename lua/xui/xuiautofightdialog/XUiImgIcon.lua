local XUiImgIcon = XClass()

function XUiImgIcon:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiImgIcon:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiImgIcon:AutoInitUi()
    self.ImgIcon = self.Transform:GetComponent("Image")
end

function XUiImgIcon:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiImgIcon:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiImgIcon:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiImgIcon:AutoAddListener()
end
-- auto

return XUiImgIcon
