
local XUiDialog = require("XUi/XUiDialog/XUiDialog")

local XUiSystemDialog = XLuaUiManager.Register(XUiDialog, "UiSystemDialog")

function XUiSystemDialog:OkBtnClick()
    self:Close()
    if self.OkCallBack then
        self.OkCallBack()
    end

    self.OkCallBack = nil
    self.CancelCallBack = nil
end

function XUiSystemDialog:CancelBtnClick()
    self:Close()
    if self.CancelCallBack then
        self.CancelCallBack()
    end

    self.OkCallBack = nil
    self.CancelCallBack = nil
end
