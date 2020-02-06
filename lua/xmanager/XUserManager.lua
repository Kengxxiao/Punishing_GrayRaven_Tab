XUserManager = XUserManager or {}

local Application = CS.UnityEngine.Application
local Platform = Application.platform
local RuntimePlatform = CS.UnityEngine.RuntimePlatform

XUserManager.CHANNEL = {
    HARU = 1,
    HERO = 2
}

XUserManager.PLATFORM = {
    Win = 0,
    Android = 1,
    IOS = 2
}

XUserManager.UserId = nil
XUserManager.UserName = nil
XUserManager.Token = nil
XUserManager.ReconnectedToken = nil
XUserManager.Channel = nil
XUserManager.Platform = nil

local InitPlatform = function()
    if Platform == RuntimePlatform.Android then
        XUserManager.Platform = XUserManager.PLATFORM.Android
    elseif Platform == RuntimePlatform.IPhonePlayer then
        XUserManager.Platform = XUserManager.PLATFORM.IOS
    else
        XUserManager.Platform = XUserManager.PLATFORM.Win
    end
end

function XUserManager.Init()
    XUserManager.Channel = CS.XRemoteConfig.Channel
    if XUserManager.Channel ~= XUserManager.CHANNEL.HERO then
        XUserManager.UserId = CS.UnityEngine.PlayerPrefs.GetString(XPrefs.UserId)
        XUserManager.UserName = CS.UnityEngine.PlayerPrefs.GetString(XPrefs.UserName)
        XUserManager.Token = CS.UnityEngine.PlayerPrefs.GetString(XPrefs.Token)
    end
    InitPlatform()
end

function XUserManager.IsNeedLogin()
    if XUserManager.Channel == XUserManager.CHANNEL.HERO then
        return XHeroSdkManager.IsNeedLogin()
    else
        return XHaruUserManager.IsNeedLogin()
    end
end

function XUserManager.ShowLogin()
    if XUserManager.Channel == XUserManager.CHANNEL.HERO then
        XHeroSdkManager.Login()
    else
        XHaruUserManager.Login()
    end
end

function XUserManager.Logout(cb)
    if XUserManager.Channel == XUserManager.CHANNEL.HERO then
        XHeroSdkManager.Logout(cb)
    else
        XHaruUserManager.Logout(cb)
    end
end

function XUserManager.ClearLoginData()
    if XUserManager.Channel == XUserManager.CHANNEL.HERO then
        XHeroSdkManager.Logout()
    else
        XUserManager.SignOut()
    end
end

function XUserManager.SetUserId(userId)
    XUserManager.UserId = userId
    --BDC
    CS.XHeroBdcAgent.UserId = userId
    if XUserManager.Channel ~= XUserManager.CHANNEL.HERO then
        CS.UnityEngine.PlayerPrefs.SetString(XPrefs.UserId, XUserManager.UserId)
        CS.UnityEngine.PlayerPrefs.Save()
    end
    XEventManager.DispatchEvent(XEventId.EVENT_USERID_CHANGE, userId)
end

function XUserManager.SetUserName(userName)
    XUserManager.UserName = userName

    if XUserManager.Channel ~= XUserManager.CHANNEL.HERO then
        CS.UnityEngine.PlayerPrefs.SetString(XPrefs.UserName, XUserManager.UserName)
        CS.UnityEngine.PlayerPrefs.Save()
    end
    XEventManager.DispatchEvent(XEventId.EVENT_USERNAME_CHANGE, userName)
end

function XUserManager.SetToken(token)
    XUserManager.Token = token
    if XUserManager.Channel ~= XUserManager.CHANNEL.HERO then
        CS.UnityEngine.PlayerPrefs.SetString(XPrefs.Token, XUserManager.Token)
        CS.UnityEngine.PlayerPrefs.Save()
    end
end

local DoRunLogin = function()
    if CS.XFight.Instance ~= nil then
        CS.XFight.ClearFight()
    end
    CS.Movie.XMovieManager.Instance:Clear()
    CsXUiManager.Instance:Clear()
    XHomeSceneManager.LeaveScene()
    CsXUiManager.Instance:Open("UiLogin")
end

function XUserManager.SignOut()
    XLoginManager.Disconnect()

    XUserManager.SetUserId(nil)
    XUserManager.SetUserName(nil)
    XUserManager.SetToken(nil)

    XEventManager.DispatchEvent(XEventId.EVENT_USER_LOGOUT)
    CsXGameEventManager.Instance:Notify(XEventId.EVENT_USER_LOGOUT)

    XDataCenter.Init()

    DoRunLogin()
end

function XUserManager.OnSwitchAccountSuccess(uid, username, token)
    XLoginManager.Disconnect()

    XUserManager.SetUserId(uid)
    XUserManager.SetUserName(username)
    XUserManager.SetToken(token)

    XEventManager.DispatchEvent(XEventId.EVENT_USER_LOGOUT)
    CsXGameEventManager.Instance:Notify(XEventId.EVENT_USER_LOGOUT)

    XDataCenter.Init()

    DoRunLogin()
end

function XUserManager.GetLoginType()
    return XUserManager.LoginType[XUserManager.Channel]
end

XRpc.LoginResponse = function(response)
    if response.Token then
        XUserManager.ReconnectedToken = response.Token
        --BDC
        CS.XHeroBdcAgent.UserId = XUserManager.UserId
        if XUserManager.Channel ~= XUserManager.CHANNEL.HERO then
            CS.UnityEngine.PlayerPrefs.SetString(XPrefs.UserId, XUserManager.UserId)
            CS.UnityEngine.PlayerPrefs.SetString(XPrefs.UserName, XUserManager.UserName)
            -- CS.UnityEngine.PlayerPrefs.SetString(XPrefs.Token, XUserManager.Token)
            CS.UnityEngine.PlayerPrefs.Save()
        end
    end
end