--==============================--
-- 通用数据收集事件
--==============================--
XAnalyticsEvent = XAnalyticsEvent or {}

local OnRoleCreate = function ()
    if XUserManager.Channel == XUserManager.CHANNEL.HERO then
        XHeroSdkManager.CreateNewRole()
    end
end

local OnLogin = function ()
    if XUserManager.Channel == XUserManager.CHANNEL.HERO then
        XHeroSdkManager.EnterGame()
    end

    CS.BuglyAgent.SetUserId(tostring(XPlayer.Id))
end

local OnLevelUp = function (level)
    if XUserManager.Channel == XUserManager.CHANNEL.HERO then
        XHeroSdkManager.RoleLevelUp()
    end
end

local OnLogout = function ()

end

function XAnalyticsEvent.Init()
    XEventManager.AddEventListener(XEventId.EVENT_NEW_PLAYER, OnRoleCreate)
    XEventManager.AddEventListener(XEventId.EVENT_LOGIN_SUCCESS, OnLogin)
    XEventManager.AddEventListener(XEventId.EVENT_PLAYER_LEVEL_CHANGE, OnLevelUp)
    XEventManager.AddEventListener(XEventId.EVENT_USER_LOGOUT, OnLogout)
end

