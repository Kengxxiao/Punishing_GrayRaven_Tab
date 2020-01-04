local XUiAutoFightTip = XLuaUiManager.Register(XLuaUi, "UiAutoFightTip")

local AnimBegin = "UiAutoFightTipBegin"

function XUiAutoFightTip:OnStart()
    self.Transform:PlayLegacyAnimation(AnimBegin, function()
        self:Close()
    end)
end