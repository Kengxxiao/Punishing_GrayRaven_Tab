XHaruUserManager = XHaruUserManager or {}

function XHaruUserManager.IsNeedLogin()
    return not XUserManager.UserId or #XUserManager.UserId == 0
end

function XHaruUserManager.Login(cb)
    if XHaruUserManager.IsNeedLogin() then
        CsXUiManager.Instance:Open("UiRegister", cb)
    end
end

function XHaruUserManager.Logout(cb)
    if XHaruUserManager.IsNeedLogin() then
        if cb then
            cb()
        end

        return
    end

    local title = CS.XTextManager.GetText("TipTitle")
    local content = CS.XTextManager.GetText("LoginSignOut")
    local dialogType = XUiManager.DialogType.Normal
    local closeCallback = nil
    local sureCallback = function()
        XUserManager.SignOut()
    end

    CsXUiManager.Instance:Open("UiDialog", title, content, dialogType, closeCallback, sureCallback);

    if cb then
        cb()
    end
end

function XHaruUserManager.SignIn(userId, cb)
    XUserManager.SetUserId(userId)
    XUserManager.SetUserName(userId)
    if cb then
        cb()
    end
end