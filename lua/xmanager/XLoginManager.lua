XLoginManager = XLoginManager or {}

local Json = require("XCommon/Json")

-- 服务器正常维护
local ErrServerMaintaining = 1
-- 初次封禁
local FirstLoginIsBanned = 11
--
local MultiLoginIsBanned = 12

local NEW_PLAYER_FLAG = 1 << 0
local OsTime = os.time

local TableLoginErrCode = "Share/Login/LoginCode.tab"
local LoginErrCodeTemplate

-- 登陆token缓存
local LoginTokenCache

local UI_LOGIN = "UiLogin"
local LoginCb
local IsConnected = false
local IsLogin = false
local FirstOpenMainUi = false    --首次登陆成功打开主界面
local StartGuide = false --首次进入主界面播放完成动画后才能开始引导
local HeartbeatInterval = CS.XGame.Config:GetInt("HeartbeatInterval")
local HeartbeatTimeout = CS.XGame.Config:GetInt("HeartbeatTimeout")
local HeartbeatTimer
local MaxDisconnectTime = CS.XGame.Config:GetInt("MaxDisconnectTime") --最大断线重连时间（服务器保留时间）
local ReconnectInterval = CS.XGame.Config:GetInt("ReconnectInterval") --重连间隔

local IsKcpConnected = false
local IsRehandedKcp = false
local RetryKcpConnectCount = 3
local KcpConnectRequestInterval = 2 * 1000
local KcpHeartbeatInterval = 10 * 1000
local KcpHeartbeatTimeout = KcpHeartbeatInterval + (2 * 1000)
local KcpHeartbeatTimer
local RemoteKcpConv

local GateHandshakeTimer
local ReconnectTimer
local MaxReconnectTimer

local LoginTimeOutSecond = CS.XGame.Config:GetInt("LoginTimeOutInterval")
local LoginTimeOutInterval = LoginTimeOutSecond * 1000
local LoginTimeOutTimer
local LoginNetworkError = CS.XTextManager.GetText("LoginNetworkError")
local LoginHttpError = CS.XTextManager.GetText("LoginHttpError")

local RetryLoginCount = 0
local RETRY_LOGIN_MAX_COUNT = 3

-- 声明local方法
local DoReconnect
local StartReconnect
local DoDisconnect
local CreateKcpSession
local DoKcpHeartbeat

local DoMtpLogin    --腾讯反外挂

local ConnectGate = function(cb, bReconnect)
    cb = cb or function()
    end

    if IsConnected then
        cb()
        return
    end

    local args = {}
    args.ConnectCb = function()
        --BDC
        CS.XHeroBdcAgent.BdcServiceState(XServerManager.Id, "1")
        CS.XHeroBdcAgent.IntoGameTimeStart = CS.UnityEngine.Time.time
        IsConnected = true
        cb()
    end
    args.DisconnectCb = function()
        IsConnected = false
        IsRehandedKcp = false
        if LoginCb then
            LoginCb(XCode.Fail)
            LoginCb = nil
        end
    end
    args.RemoteDisconnectCb = function()
        DoReconnect()
    end
    args.ErrorCb = function(err)
        --BDC
        CS.XHeroBdcAgent.BdcServiceState(XServerManager.Id, "2")
        if err and (err ~= CS.System.Net.Sockets.SocketError.Success and err ~= CS.System.Net.Sockets.SocketError.OperationAborted) then
            local errStr = tostring(err:ToString())
            XLog.Warning("XNetwork.ConnectGateServer error. ============ SocketError." .. errStr)
            local msgtab = {}
            msgtab["error"] = errStr
            local jsonstr = Json.encode(msgtab)
            CS.XRecord.Record("24013", "ConnectGateSeverSocketError")
            if LoginCb then
                XLuaUiManager.ClearAnimationMask()
                XUiManager.SystemDialogTip(CS.XTextManager.GetText("TipTitle"), CS.XTextManager.GetText("NetworkError"), XUiManager.DialogType.OnlySure, nil, nil)
                LoginCb(XCode.Fail)
                LoginCb = nil
            end
        end
    end
    args.MsgErrorCb = function()
        if ReconnectTimer then
            CS.XScheduleManager.UnSchedule(ReconnectTimer)
        end
        if MaxReconnectTimer then
            CS.XScheduleManager.UnSchedule(MaxReconnectTimer)
        end
        DoDisconnect()
    end
    args.IsReconnect = bReconnect
    args.CreateKcpCb = CreateKcpSession
    args.RemoveHandshakeTimerCb = function()
        if GateHandshakeTimer then
            CS.XScheduleManager.UnSchedule(GateHandshakeTimer)
        end
    end

    XNetwork.ConnectGateServer(args)
end

local Disconnect = function(bLogout)
    if HeartbeatTimer then
        CS.XScheduleManager.UnSchedule(HeartbeatTimer)
    end

    if KcpHeartbeatTimer then
        CS.XScheduleManager.UnSchedule(KcpHeartbeatTimer)
        KcpHeartbeatTimer = nil
    end

    CS.XNetwork.Disconnect()
    IsConnected = false
    IsRehandedKcp = false

    if bLogout then
        IsLogin = false
    end

    if LoginCb then
        LoginCb(XCode.Fail)
        LoginCb = nil
    end

    XEventManager.DispatchEvent(XEventId.EVENT_NETWORK_DISCONNECT)
end

DoDisconnect = function()
    Disconnect(true)

    if LoginTimeOutTimer then
        CS.XScheduleManager.UnSchedule(LoginTimeOutTimer)
        LoginTimeOutTimer = nil
    end

    if GateHandshakeTimer then
        CS.XScheduleManager.UnSchedule(GateHandshakeTimer)
        GateHandshakeTimer = nil
    end

    if MaxReconnectTimer then
        CS.XScheduleManager.UnSchedule(MaxReconnectTimer)
        MaxReconnectTimer = nil
    end

    XLuaUiManager.ClearAnimationMask()
    CS.XRecord.Record("24014", "SocketDisconnect");

    if CS.XNetwork.IsShowNetLog then
        XLog.Debug("DoDisconnect!!!")
    end

    XUiManager.SystemDialogTip(CS.XTextManager.GetText("TipTitle"), CS.XTextManager.GetText("HeartbeatTimeout"), XUiManager.DialogType.OnlySure, nil, function()
        CS.Movie.XMovieManager.Instance:Clear()
        CsXUiManager.Instance:Clear()
        XHomeSceneManager.LeaveScene()
        if CS.XFight.Instance ~= nil then
            CS.XFight.ClearFight()
        end
        CsXUiManager.Instance:Open(UI_LOGIN)
    end)
end
XLoginManager.DoDisconnect = DoDisconnect

local DoHeartbeat
DoHeartbeat = function()
    if not IsLogin then
        return
    end

    HeartbeatTimer = CS.XScheduleManager.Schedule(function(...)
        -- if CS.XNetwork.IsShowNetLog then
            XLog.Debug("tcp heartbeat time out.")
        -- end

        if KcpHeartbeatTimer then
            CS.XScheduleManager.UnSchedule(KcpHeartbeatTimer)
            KcpHeartbeatTimer = nil
        end

        StartReconnect()
    end, HeartbeatTimeout, 1)

    local reqTime = OsTime()
    if CS.XNetwork.IsShowNetLog then
        XLog.Debug("tcp heartbeat request.")
    end
    XNetwork.Call("HeartbeatRequest", nil, function(res)
        XTime.SyncTime(res.ServerTime, reqTime, OsTime())
        CS.XScheduleManager.UnSchedule(HeartbeatTimer)
        if CS.XNetwork.IsShowNetLog then
            XLog.Debug("tcp heartbeat response.")
        end
        HeartbeatTimer = CS.XScheduleManager.Schedule(function()
            DoHeartbeat()
        end, HeartbeatInterval, 1)
    end)
end

StartReconnect = function()
    CS.XRecord.Record("24033", "StartReconnect");
    local startReconnectTime = OsTime()

    if MaxReconnectTimer then
        CS.XScheduleManager.UnSchedule(MaxReconnectTimer)
        MaxReconnectTimer = nil
    end

    MaxReconnectTimer = CS.XScheduleManager.Schedule(function(...)
        if OsTime() - startReconnectTime > MaxDisconnectTime then
            if CS.XNetwork.IsShowNetLog then
                XLog.Debug("超过服务器保留最长时间")
            end
            if KcpHeartbeatTimer then
                CS.XScheduleManager.UnSchedule(KcpHeartbeatTimer)
                KcpHeartbeatTimer = nil
            end
            if HeartbeatTimer then
                CS.XScheduleManager.UnSchedule(HeartbeatTimer)
                HeartbeatTimer = nil
            end
            CS.XScheduleManager.UnSchedule(MaxReconnectTimer)
            DoDisconnect()
        end
    end, 1000, 0)
    DoReconnect()
end

-- 断线重连方法
DoReconnect = function()
    if not IsLogin then
        return
    end

    if not XUserManager.ReconnectedToken then
        DoDisconnect()
        return
    end

    ReconnectTimer = CS.XScheduleManager.Schedule(function(...)
        -- if CS.XNetwork.IsShowNetLog then
            XLog.Debug("断线重连响应超时")
        -- end
        CS.XNetwork.Disconnect()
        DoReconnect()
    end, ReconnectInterval, 1)

    if CS.XNetwork.IsShowNetLog then
        XLog.Debug("开始断线重连...")
    end
    Disconnect(false)
    --重连网关
    ConnectGate(function()
        CS.XScheduleManager.UnSchedule(ReconnectTimer)
        -- if CS.XNetwork.IsShowNetLog then
            XLog.Debug("reconnect, then request heart beat.")
        -- end
        if MaxReconnectTimer then
            CS.XScheduleManager.UnSchedule(MaxReconnectTimer)
            MaxReconnectTimer = nil
        end
        DoMtpLogin(XUserManager.UserId, XUserManager.UserName)
        DoHeartbeat()
    end, true)
end

DoMtpLogin = function(uid, username)
    CS.XMtp.Login(uid, username)
end

local OnLoginSuccess = function()
    CS.XRecord.Record("24018", "OnLoginSuccess")
    IsLogin = true
    if CS.XNetwork.IsShowNetLog then
        XLog.Debug("login success, then request heart beat.")
    end
    DoMtpLogin(XUserManager.UserId, XUserManager.UserName)
    DoHeartbeat()
    XNetwork.ConnectKcp(CreateKcpSession)
    XEventManager.DispatchEvent(XEventId.EVENT_LOGIN_SUCCESS)
end

-- KCP心跳
DoKcpHeartbeat = function()
    if not IsKcpConnected then
        return
    end

    KcpHeartbeatTimer = CS.XScheduleManager.Schedule(function(id)
        if not IsKcpConnected then
            return
        end

        -- if CS.XNetwork.IsShowNetLog then
            XLog.Debug("kcp heartbeat time out.")
        -- end

        if HeartbeatTimer then
            CS.XScheduleManager.UnSchedule(HeartbeatTimer)
            HeartbeatTimer = nil
        end

        StartReconnect()
    end, KcpHeartbeatTimeout, 1)

    if CS.XNetwork.IsShowNetLog then
        XLog.Debug("kcp heartbeat request.")
    end
    XNetwork.CallKcp("KcpHeartbeatRequest", nil, function(res)
        if CS.XNetwork.IsShowNetLog then
            XLog.Debug("kcp heartbeat response.")
        end
        if KcpHeartbeatTimer then
            CS.XScheduleManager.UnSchedule(KcpHeartbeatTimer)
            KcpHeartbeatTimer = nil
        end

        KcpHeartbeatTimer = CS.XScheduleManager.Schedule(function(id)
            DoKcpHeartbeat()
        end, KcpHeartbeatInterval, 1)
    end)
end

-- 创建KCP会话
CreateKcpSession = function(ip, port, remoteConv)
    --XLog.Debug("create kcp session. ip=" .. tostring(ip) .. ", port=" .. tostring(port) .. ", remoteConv=" .. tostring(remoteConv))
    IsKcpConnected = false
    CS.XNetwork.CreateUdpSession()
    CS.XNetwork.UdpConnect(ip, port)
    CS.XNetwork.CreateKcpSession(remoteConv)
    RemoteKcpConv = remoteConv

    if KcpHeartbeatTimer then
        CS.XScheduleManager.UnSchedule(KcpHeartbeatTimer)
        KcpHeartbeatTimer = nil
    end

    if CS.XNetwork.IsShowNetLog then
        XLog.Debug("kcp connect request.")
    end

    local tryCount = 0
    CS.XNetwork.KcpConnectRequest(remoteConv)
    KcpHeartbeatTimer = CS.XScheduleManager.Schedule(function(id)
        if not IsKcpConnected then
            if tryCount >= RetryKcpConnectCount then
                if not IsRehandedKcp then
                    IsRehandedKcp = true
                    XNetwork.ConnectKcp(CreateKcpSession)
                end
                return
            end

            tryCount = tryCount + 1
            if CS.XNetwork.IsShowNetLog then
                XLog.Debug("kcp connect request retry.")
            end
            CS.XNetwork.KcpConnectRequest(remoteConv)
        end
    end, KcpConnectRequestInterval, 0)
end

local OnLogin = function(errCode)
    if LoginTimeOutTimer then
        CS.XScheduleManager.UnSchedule(LoginTimeOutTimer)
    end

    if not errCode or errCode == XCode.Success then
        OnLoginSuccess()
    else
        CS.XRecord.Record("24015", "OnLoginError")
    end
    if LoginCb then
        LoginCb(errCode)
        LoginCb = nil
    end
end

local DoLoginTimeOut = function(cb)
    Disconnect(true)
    XLuaUiManager.ClearAnimationMask()
    CS.XRecord.Record("24016", "DoLoginTimeOut")
    XUiManager.SystemDialogTip(CS.XTextManager.GetText("TipTitle"), CS.XTextManager.GetText("LoginTimeOut"), XUiManager.DialogType.Normal, function()
        OnLogin(XCode.Fail)
    end, function()
        XLoginManager.Login(cb)
    end)
end

local DoLogin
DoLogin = function(cb)
    if XUserManager.Channel == nil or
        XUserManager.UserId == nil or
        CS.XHeroSdkAgent.GetAppProjectId() == nil then
        return
    end

    local loginUrl = XServerManager.GetLoginUrl() ..
    "?loginType=" .. XUserManager.Channel ..
    "&userId=" .. XUserManager.UserId ..
    "&projectId=" .. CS.XHeroSdkAgent.GetAppProjectId() ..
    "&token=" .. (XUserManager.Token or "")

    local request = CS.UnityEngine.Networking.UnityWebRequest.Get(loginUrl)
    request.timeout = LoginTimeOutSecond
    CS.XRecord.Record("24009", "RequestLoginHttpSever")
    CS.XUiManager.Instance:SetAnimationMask(true)
    XLog.Debug("login manager: request login http server to open mask.")
    CS.XTool.WaitNativeCoroutine(request:SendWebRequest(), function()
        if request.isNetworkError then
            XLog.Error("login network error，url is " .. loginUrl .. ", message is " .. request.error)
            XLuaUiManager.ClearAnimationMask()
            XUiManager.SystemDialogTip("", LoginNetworkError, XUiManager.DialogType.OnlySure, nil, function()
                if LoginCb then
                    LoginCb(XCode.Fail)
                    LoginCb = nil
                end
            end)
            CS.XRecord.Record("24010", "RequestLoginHttpSeverNetWorkError")
            return
        end

        if request.isHttpError then
            XLog.Error("login http error，url is " .. loginUrl .. ", message is " .. request.error)
            XLuaUiManager.ClearAnimationMask()
            XUiManager.SystemDialogTip("", LoginHttpError, XUiManager.DialogType.OnlySure, nil, function()
                if LoginCb then
                    LoginCb(XCode.Fail)
                    LoginCb = nil
                end
            end)
            CS.XRecord.Record("24011", "RequestLoginHttpSeverHttpError")
            return
        end

        local result = Json.decode(request.downloadHandler.text)
        if result.code ~= 0 then
            local tipMsg

            if result.code == ErrServerMaintaining then
                tipMsg = result.msg
            elseif result.code == FirstLoginIsBanned or result.code == MultiLoginIsBanned then
                local template = LoginErrCodeTemplate[result.code]
                tipMsg = string.format(template.Msg, XUiHelper.GetTime(result.loginLockTime))
            else
                local template = LoginErrCodeTemplate[result.code]
                if template then
                    tipMsg = template.Msg
                else
                    tipMsg = "login errCode is " .. result.code
                end
            end

            XLuaUiManager.ClearAnimationMask()
            XUiManager.SystemDialogTip("", tipMsg, XUiManager.DialogType.OnlySure, nil, function()
                if LoginCb then
                    LoginCb(XCode.Fail)
                    LoginCb = nil
                end
            end)
            CS.XRecord.Record("24012", "RequestLoginHttpSeverLoginError")
            return
        end

        CS.XUiManager.Instance:SetAnimationMask(false)
        XLog.Debug("login manager: request login http server to close mask.")
        CS.XRecord.Record("24031", "RequestLoginHttpSeverLoginSuccess")
        if cb then
            cb(result.token, result.ip, result.host, result.port)
        end

        request:Dispose()
    end)
end

local DoLoginGame
DoLoginGame = function(cb)
    if LoginTimeOutTimer then
        CS.XScheduleManager.UnSchedule(LoginTimeOutTimer)
    end

    LoginTimeOutTimer = CS.XScheduleManager.Schedule(function(...)
        DoLoginTimeOut(cb)
    end, LoginTimeOutInterval, 1)

    XLog.Debug("loing platform is " .. XUserManager.Platform)

    XNetwork.Call("LoginRequest", {
        LoginType = XUserManager.Channel,
        LoginPlatform = XUserManager.Platform,
        UserId = XUserManager.UserId,
        ProjectId = CS.XHeroSdkAgent.GetAppProjectId(),
        Token = LoginTokenCache,
        DeviceId = CS.XHeroBdcAgent.GetDeviceId()
    }, function(res)
        if res.Code ~= XCode.Success then
            --BDC
            CS.XHeroBdcAgent.BdcRoleLogin("1", "")
            if res.Code == XCode.LoginServiceRetry and RetryLoginCount < RETRY_LOGIN_MAX_COUNT then
                RetryLoginCount = RetryLoginCount + 1
                local msgtab = {}
                msgtab["retry_login_count"] = tostring(RetryLoginCount)
                local jsonStr = Json.encode(msgtab)
                CS.XRecord.Record("24017", "DoLoginGameRequestError", jsonStr)
                DoLoginGame(cb)
            else
                local msgtab = {}
                msgtab["retry_login_count"] = tostring(RetryLoginCount)
                local jsonStr = Json.encode(msgtab)
                CS.XRecord.Record("24017", "DoLoginGameRequestError", jsonStr)
                RetryLoginCount = 0
                XLuaUiManager.ClearAnimationMask()
                XUiManager.SystemDialogTip("", CS.XTextManager.GetCodeText(res.Code), XUiManager.DialogType.OnlySure, nil, function()
                    OnLogin(res.Code)
                end)
            end
        else
            --BDC
            CS.XHeroBdcAgent.BdcRoleLogin("2", CS.XTextManager.GetCodeText(res.Code))
            RetryLoginCount = 0
            XUserManager.ReconnectedToken = res.ReconnectToken
            CS.XRecord.Record("24021", "LoginRequestSuccess")
        end
    end)
end

function XLoginManager.CreateKcpSession()
    XNetwork.ConnectKcp(CreateKcpSession)
end

function XLoginManager.CloseKcpSession()
    --关闭kcp心跳
    IsKcpConnected = false
    if KcpHeartbeatTimer then
        CS.XScheduleManager.UnSchedule(KcpHeartbeatTimer)
        KcpHeartbeatTimer = nil
    end
end

function XLoginManager.IsFirstOpenMainUi()
    return FirstOpenMainUi
end

function XLoginManager.IsStartGuide()
    return StartGuide
end

function XLoginManager.SetStartGuide(v)
    StartGuide = v
end

function XLoginManager.SetFirstOpenMainUi(flag)
    FirstOpenMainUi = flag
end

function XLoginManager.IsLogin()
    return IsLogin
end

function XLoginManager.Login(cb)
    CS.XRecord.Record("24007", "InvokeLoginStart")
    XDataCenter.Init()

    local alive = false
    LoginCb = cb

    DoLogin(function(loginToken, ip, host, port)
        XLog.Debug(loginToken, ip, host, port)
        if host then
            XLog.Debug(host)
            local address = CS.System.Net.Dns.GetHostAddresses(host)
            XTool.LoopArray(address, function(v)
                if v.AddressFamily == CS.System.Net.Sockets.AddressFamily.InterNetwork then
                    ip = v:ToString()
                end
            end)
        end

        XLog.Debug(loginToken, ip, port)
        XNetwork.SetGateAddress(ip, port)
        LoginTokenCache = loginToken

        ---- 网关已连接，且与上次登录服务器相同
        if IsConnected and not XNetwork.CheckIsChangedGate() then
            DoLoginGame(cb)
            return
        end

        ---- 网关已连接，切换了服务器
        if IsConnected then
            CS.XNetwork.Disconnect()
            IsConnected = false
        end

        if GateHandshakeTimer then
            CS.XScheduleManager.UnSchedule(GateHandshakeTimer)
        end

        GateHandshakeTimer = CS.XScheduleManager.Schedule(function(...)
            CS.XRecord.Record("24008", "GateHandShakeTimeOut")
            DoLoginTimeOut(cb)
        end, LoginTimeOutInterval, 1)

        ConnectGate(function()
            DoLoginGame(cb)
        end, false)
    end)
end

local OnCreateRole = function()
    XEventManager.DispatchEvent(XEventId.EVENT_NEW_PLAYER)
end

XRpc.NotifyLogin = function(data)
    CS.XRecord.Record("24022", "NotifyLogin")
    local loginProfiler = CS.XProfiler.Create("NotifyLogin")
    loginProfiler:Start()

    local playerProfiler = loginProfiler:CreateChild("XPlayer")
    playerProfiler:Start()
    XPlayer.Init(data.PlayerData, data.HeadPortraitList)
    playerProfiler:Stop()

    local itemProfiler = loginProfiler:CreateChild("ItemManager")
    itemProfiler:Start()
    XDataCenter.ItemManager.InitItemData(data.ItemList)
    XDataCenter.ItemManager.InitItemRecycle(data.ItemRecycleDict)
    XDataCenter.ItemManager.InitBatchItemRecycle(data.BatchItemRecycle)
    itemProfiler:Stop()

    local characterProfiler = loginProfiler:CreateChild("CharacterManager")
    characterProfiler:Start()
    XDataCenter.CharacterManager.InitCharacters(data.CharacterList)
    characterProfiler:Stop()

    local equipProfiler = loginProfiler:CreateChild("EquipManager")
    equipProfiler:Start()
    XDataCenter.EquipManager.InitEquipData(data.EquipList)
    equipProfiler:Stop()

    local fashionProfiler = loginProfiler:CreateChild("FashionManager")
    fashionProfiler:Start()
    XDataCenter.FashionManager.InitFashions(data.FashionList)
    fashionProfiler:Stop()

    local baseEquipProfiler = loginProfiler:CreateChild("BaseEquipManager")
    baseEquipProfiler:Start()
    XDataCenter.BaseEquipManager.InitLoginData(data.BaseEquipLoginData)
    baseEquipProfiler:Stop()

    local fubenProfiler = loginProfiler:CreateChild("FubenManager")
    fubenProfiler:Start()
    XDataCenter.FubenManager.InitFubenData(data.FubenData)
    fubenProfiler:Stop()

    local fubenMailLineProfiler = loginProfiler:CreateChild("FubenMainLineManager")
    fubenMailLineProfiler:Start()
    XDataCenter.FubenMainLineManager.InitFubenMainLineData(data.FubenMainLineData)
    fubenMailLineProfiler:Stop()

    local fubenDailyProfiler = loginProfiler:CreateChild("FubenDailyManager")
    fubenDailyProfiler:Start()
    XDataCenter.FubenDailyManager.InitFubenDailyData(data.FubenDailyData)
    fubenDailyProfiler:Stop()

    local fubenBossSinleProfiler = loginProfiler:CreateChild("FubenBossSingleManager")
    fubenBossSinleProfiler:Start()
    XDataCenter.FubenBossSingleManager.InitFubenBossSingleData(data.FubenBossSingleData)
    fubenBossSinleProfiler:Stop()

    local fubenUrgentEventProfiler = loginProfiler:CreateChild("FubenUrgentEventManager")
    fubenUrgentEventProfiler:Start()
    XDataCenter.FubenUrgentEventManager.InitData(data.FubenUrgentEventData)
    fubenUrgentEventProfiler:Stop()

    local autoFightProfiler = loginProfiler:CreateChild("AutoFightManager")
    autoFightProfiler:Start()
    XDataCenter.AutoFightManager.InitAutoFightData(data.AutoFightRecords)
    autoFightProfiler:Stop()

    local teamProfiler = loginProfiler:CreateChild("TeamManager")
    teamProfiler:Start()
    XDataCenter.TeamManager.InitTeamGroupData(data.TeamGroupData)
    XDataCenter.TeamManager.InitTeamPrefabData(data.TeamPrefabData)
    teamProfiler:Stop()

    local guildProfiler = loginProfiler:CreateChild("GuideManager")
    guildProfiler:Start()
    XDataCenter.GuideManager.InitGuideData(data.PlayerData.GuideData)
    guildProfiler:Stop()

    local functionOpenProfiler = loginProfiler:CreateChild("FunctionManager")
    functionOpenProfiler:Start()
    XFunctionManager.InitData(data.PlayerData.ShieldFuncList)
    functionOpenProfiler:Stop()

    local signInProfiler = loginProfiler:CreateChild("SignInManager")
    signInProfiler:Start()
    XDataCenter.SignInManager.InitData(data.SignInfos)
    signInProfiler:Stop()

    --BDC
    CS.XHeroBdcAgent.RoleId = data.PlayerData.Id
    CS.XHeroBdcAgent.RoleKey = data.PlayerData.ServerId .. "_" .. data.PlayerData.Id
    CS.XHeroBdcAgent.ServerId = data.PlayerData.ServerId
    local balance = XDataCenter.ItemManager.GetCount(XDataCenter.ItemManager.ItemId.ActionPoint)
    local hongka = XDataCenter.ItemManager.GetCount(XDataCenter.ItemManager.ItemId.HongKa)
    local heika = XDataCenter.ItemManager.GetCount(XDataCenter.ItemManager.ItemId.FreeGem)
    local luomu = XDataCenter.ItemManager.GetCount(XDataCenter.ItemManager.ItemId.Coin)
    CS.XHeroBdcAgent.BdcUserInfo(data.PlayerData.Name, data.PlayerData.Level, balance, hongka, heika, luomu)

    if (data.PlayerData.Flags & NEW_PLAYER_FLAG) == NEW_PLAYER_FLAG then
        -- new player
        OnCreateRole()
    end

    XEventManager.DispatchEvent(XEventId.EVENT_LOGIN_DATA_LOAD_COMPLETE)

    local onloginProfiler = loginProfiler:CreateChild("OnLogin")
    onloginProfiler:Start()
    OnLogin()
    onloginProfiler:Stop()

    loginProfiler:Stop()
    XLog.Debug(loginProfiler);
end

function XLoginManager.Disconnect()
    Disconnect(true)
end

function XLoginManager.Init()
    LoginErrCodeTemplate = XTableManager.ReadByIntKey(TableLoginErrCode, XTable.XTableLoginCode, "ErrCode")
end

XRpc.ForceLogoutNotify = function(res)
    Disconnect(true)
    CS.XScheduleManager.UnSchedule(HeartbeatTimer)
    XUiManager.SystemDialogTip(CS.XTextManager.GetText("TipTitle"), CS.XTextManager.GetCodeText(res.Code), XUiManager.DialogType.OnlySure, nil, function()
        CS.Movie.XMovieManager.Instance:Clear()
        CsXUiManager.Instance:Clear()
        XHomeSceneManager.LeaveScene()
        if CS.XFight.Instance ~= nil then
            CS.XFight.ClearFight()
        end
        --CS.XUiManager.ViewManager:Run(UI_LOGIN)
        XLuaUiManager.Open(UI_LOGIN)
    end)
end

XRpc.RpcErrorNotify = function(res)
    if res.Code ~= XCode.Success then
        XUiManager.TipCode(res.Code)
    end
end

XRpc.KcpConnectedNotify = function()
    if KcpHeartbeatTimer then
        CS.XScheduleManager.UnSchedule(KcpHeartbeatTimer)
        KcpHeartbeatTimer = nil
    end
    IsKcpConnected = true
    DoKcpHeartbeat()

    --CS.XNetwork.Test()
end

local test_id = 1
local tcp_time_table = {}
local kcp_time_table = {}

function XLoginManager.Test()
    local i = test_id
    test_id = test_id + 1

    local kcp_time = CS.XDate.NowMilliseconds()
    XNetwork.CallKcp("KcpPing", { UtcTime = kcp_time }, function(res)
        local delta = CS.XDate.NowMilliseconds() - kcp_time

        if #kcp_time_table >= 10 then
            table.remove(kcp_time_table, 1)
        end
        table.insert(kcp_time_table, delta)

        local total = 0
        for _, v in ipairs(kcp_time_table) do
            total = total + v
        end
        local average = total / #kcp_time_table

        XLog.Error(string.format("********************************* kcp ping. id = %d, delta = %d, average = <color=yellow>%s</color>", i, delta, tostring(average)))
    end)

    local tcp_time = CS.XDate.NowMilliseconds()
    XNetwork.Call("Ping", { UtcTime = tcp_time }, function(res)
        local delta = CS.XDate.NowMilliseconds() - tcp_time

        if #tcp_time_table >= 10 then
            table.remove(tcp_time_table, 1)
        end
        table.insert(tcp_time_table, delta)

        local total = 0
        for _, v in ipairs(tcp_time_table) do
            total = total + v
        end
        local average = total / #tcp_time_table

        XLog.Error(string.format("+++++++++++++++++++++++++++++++++ tcp ping. id = %d, delta = %d, average = <color=red>%s</color>", i, delta, tostring(average)))
    end)
end