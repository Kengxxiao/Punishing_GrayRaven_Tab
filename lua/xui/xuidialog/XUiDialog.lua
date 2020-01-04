local XUiDialog = XLuaUiManager.Register(XLuaUi, "UiDialog")

function XUiDialog:OnAwake()
    self:AutoAddListener()
end

function XUiDialog:OnStart(title, content, dialogType, closeCallback, sureCallback)
    self:HideDialogLayer()
    if title then
        self.TxtTitle.text = title
    end

    if dialogType == XUiManager.DialogType.Normal then
        self.PanelDialog.gameObject:SetActive(true)
        self.TxtInfoNormal.text = string.gsub(content, "\\n", "\n")
        self:PlayAnimation("DialogEnable")
    elseif dialogType == XUiManager.DialogType.OnlySure then
        self.PanelSureDialog.gameObject:SetActive(true)
        self.TxtInfoSure.text = string.gsub(content, "\\n", "\n")
        self:PlayAnimation("SureDialogEnable")
    elseif dialogType == XUiManager.DialogType.OnlyClose then
        self.PanelCloseDialog.gameObject:SetActive(true)
        self.TxtInfoClose.text = string.gsub(content, "\\n", "\n")
        self:PlayAnimation("CloseDialogEnable")
    end
    self.OkCallBack = sureCallback
    self.CancelCallBack = closeCallback
end

function XUiDialog:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiGridArenaStage:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiGridArenaStage:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiDialog:AutoAddListener()
    self:RegisterClickEvent(self.BtnConfirmB, self.OnBtnConfirmBClick)
    self:RegisterClickEvent(self.BtnCloseA, self.OnBtnCloseAClick)
    self:RegisterClickEvent(self.BtnConfirm, self.OnBtnConfirmClick)
    self:RegisterClickEvent(self.BtnClose, self.OnBtnCloseClick)
    self:RegisterClickEvent(self.BtnTanchuangClose, self.OnBtnCloseClick)
end

function XUiDialog:HideDialogLayer()
    self.PanelDialog.gameObject:SetActive(false)
    self.PanelCloseDialog.gameObject:SetActive(false)
    self.PanelSureDialog.gameObject:SetActive(false)
end

function XUiDialog:OnBtnCloseAClick()
    self:CancelBtnClick()
end

function XUiDialog:OnBtnConfirmBClick()
    self:OkBtnClick()
end

function XUiDialog:OnBtnConfirmClick()
    self:OkBtnClick()
end

function XUiDialog:OnBtnCloseClick()
    self:CancelBtnClick()
end

function XUiDialog:OkBtnClick()
    CsXUiManager.Instance:Close("UiDialog")
    if self.OkCallBack then
        self.OkCallBack()
    end

    self.OkCallBack = nil
    self.CancelCallBack = nil
end

function XUiDialog:CancelBtnClick()
    CsXUiManager.Instance:Close("UiDialog")
    if self.CancelCallBack then
        self.CancelCallBack()
    end

    self.OkCallBack = nil
    self.CancelCallBack = nil
end

return XUiDialog
