--local XUiRegister = XUiManager.Register("UiRegister")
local XUiRegister = XLuaUiManager.Register(XLuaUi, "UiRegister")

function XUiRegister:OnAwake()
    self:InitAutoScript()
end

function XUiRegister:OnStart(loginCb)
    self.LoginCb = loginCb
    self.InFUserId.text = XUserManager.UserId
    self.PanelRegister.gameObject:SetActive(true)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiRegister:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiRegister:AutoInitUi()
    self.PanelRegister = self.Transform:Find("SafeAreaContentPane/PanelRegister")
    self.BtnSignIn = self.Transform:Find("SafeAreaContentPane/PanelRegister/SafeAreaContentPane/BtnSignIn"):GetComponent("Button")
    self.BtnCancel = self.Transform:Find("SafeAreaContentPane/PanelRegister/SafeAreaContentPane/BtnCancel"):GetComponent("Button")
    self.InFUserId = self.Transform:Find("SafeAreaContentPane/PanelRegister/SafeAreaContentPane/InFUserId"):GetComponent("InputField")
    self.TxtUserId = self.Transform:Find("SafeAreaContentPane/PanelRegister/SafeAreaContentPane/InFUserId/TxtUserId"):GetComponent("Text")
end

function XUiRegister:GetAutoKey(uiNode, eventName)
    if not uiNode then
        return
    end
    return eventName .. uiNode:GetHashCode()
end

function XUiRegister:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then
        return
    end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiRegister:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiRegister:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterListener(self.BtnSignIn, "onClick", self.OnBtnSignInClick)
    self:RegisterListener(self.BtnCancel, "onClick", self.OnBtnCancelClick)
end
-- auto

function XUiRegister:OnBtnSignInClick(...)
    local userIdText = self.InFUserId.text

    if not userIdText or #self.InFUserId.text == 0 then
        XUiManager.TipText("LoginPhoneEmpty")
        return
    end

    XHaruUserManager.SignIn(userIdText, function()
        if self.LoginCb then
            self.LoginCb()
        end

        --CS.XUiManager.ViewManager:Pop()
        --CsXUiManager.Instance:Close("UiRegister");
        self.super.Close(self)

    end)
end

function XUiRegister:OnBtnCancelClick(...)
    self.super.Close(self)
end
