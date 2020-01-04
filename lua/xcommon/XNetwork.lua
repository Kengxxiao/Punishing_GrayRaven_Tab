XNetwork = XNetwork or {}

local Ip
local Port
local LastIp
local LastPort
local Json = require("XCommon/Json")

local function GetIpAndPort()
    return Ip, Port
end

function XNetwork.SetGateAddress(ip, port)
    Ip = ip
    Port = port
end

function XNetwork.CheckIsChangedGate()
    return LastIp ~= Ip or LastPort ~= Port
end

local function TipTableDiff(md5Table)
    XTool.LoopMap(CS.XTableManager.Md5Table, function(k, v)
        local md5 = md5Table[k]
        if not md5 then
            XLog.Error("多余表格: " .. k)
            return
        end

        if v ~= md5 then
            XLog.Error("差异表格: " .. k .. ", 客户端md5: " .. v .. " , 服务端md5: " .. md5)
        end

        md5Table[k] = nil
    end)

    for k, v in pairs(md5Table) do
        XLog.Error("缺少表格: " .. k)
    end
end

XRpc.NotifyCheckTableMd5 = function(data)
    TipTableDiff(data.Md5Table)
end

function XNetwork.ConnectGateServer(args)
    if not args then
        return
    end

    CS.XNetwork.OnConnect = function()
        if args.IsReconnect then
            local request = { UserId = XUserManager.UserId, Token = XUserManager.ReconnectedToken, LastMsgSeqNo = CS.XNetwork.ServerMsgSeqNo }
            if CS.XNetwork.IsShowNetLog then
                XLog.Debug("userid=" .. request.UserId .. ", token=" .. request.Token .. ", LastMsgSeqNo=" .. request.LastMsgSeqNo)
            end

            local request_func
            request_func = function(cb)
                XNetwork.Call("ReconnectRequest", request, function(res)
                    if res.Code == XCode.ReconnectAgain then
                        if CS.XNetwork.IsShowNetLog then
                            XLog.Debug("服务器返回再次重连。" .. tostring(res.Code))
                        end

                        local waitTimer = CS.XScheduleManager.Schedule(function(...)
                            request_func()
                        end, 1000, 1)

                    elseif res.Code ~= XCode.Success then
                        if CS.XNetwork.IsShowNetLog then
                            XLog.Debug("服务器返回断线重连失败。" .. tostring(res.Code))
                        end
                        XLoginManager.DoDisconnect()
                    else
                        if CS.XNetwork.IsShowNetLog then
                            XLog.Debug("服务器返回断线重连成功。")
                        end
                        XUserManager.ReconnectedToken = res.ReconnectToken
                        if args.ConnectCb then
                            args.ConnectCb()
                        end
                        CS.XNetwork.ReCall()
                        XNetwork.ConnectKcp(args.CreateKcpCb)
                    end
                end)
            end

            request_func()
        else
            XNetwork.Call("HandshakeRequest", {
                ApplicationVersion = CS.XRemoteConfig.ApplicationVersion,
                DocumentVersion = CS.XRemoteConfig.DocumentVersion,
                Md5 = CS.XTableManager.Md5
            }, function(response)
                if args.RemoveHandshakeTimerCb then
                    args.RemoveHandshakeTimerCb()
                end

                if response.Code ~= XCode.Success then
                    local msgTab = {}
                    msgTab["error_code"] = tostring(response.Code)
                    local jsonStr = Json.encode(msgTab)
                    CS.XRecord.Record("24019", "HandshakeRequest",jsonStr)
                    if response.Code == XCode.GateServerNotOpen then
                        local context = CS.XTextManager.GetCodeText(response.Code) .. os.date("%Y-%m-%d %H:%M", response.UtcOpenTime)
                        XUiManager.SystemDialogTip("", context, XUiManager.DialogType.OnlySure)
                    elseif response.Code == XCode.LoginApplicationVersionError then
                        CS.XTool.WaitCoroutine(CS.XApplication.CoDialog(CS.XApplication.GetText("Tip"), CS.XStringEx.Format(CS.XApplication.GetText("UpdateApplication"), CS.XInfo.Version) .. "？", nil, function() CS.XTool.WaitCoroutine(CS.XApplication.GoToUpdateURL(), nil) end))
                    end

                    if response.Code == XCode.LoginMd5Error then
                        XLog.Error("配置表客户端和服务端不一致")
                        TipTableDiff(response.Md5Table)
                    end

                    CS.XNetwork.Disconnect()
                    return
                end

                CS.XRecord.Record("24020", "HandshakeRequestSuccess")
                if args.ConnectCb then
                    args.ConnectCb()
                end
            end)
        end
    end
    CS.XNetwork.OnDisconnect = function()
        if args.DisconnectCb then
            args.DisconnectCb()
        end
    end
    CS.XNetwork.OnRemoteDisconnect = function()
        if args.RemoteDisconnectCb then
            args.RemoteDisconnectCb()
        end
    end
    CS.XNetwork.OnError = function(error)
        if args.ErrorCb then
            args.ErrorCb(error)
        end
    end
    CS.XNetwork.OnMessageError = function()
        if args.MsgErrorCb then
            args.MsgErrorCb()
        end
    end

    local ip, port
    if args.IsReconnect then
        ip, port = LastIp, LastPort
    else
        ip, port = GetIpAndPort()
    end

    XNetwork.ConnectServer(ip, port, args.IsReconnect)
end

function XNetwork.ConnectServer(ip, port, bReconnect)
    if not ip or not port then
        return
    end

    LastIp, LastPort = ip, port
    CS.XNetwork.Connect(ip, tonumber(port), bReconnect)
end

-- 连接KCP
function XNetwork.ConnectKcp(cb)
    XNetwork.Call("KcpHandshakeRequest", {}, function(res)
        if res.Code == XCode.Success then
            if cb then
                cb(LastIp, res.Port, res.Conv)
            end
        end
    end)
end

function XNetwork.Send(handler, request)
    local requestContent, error = XMessagePack.Encode(request)
    if requestContent == nil then
        XLog.Error("XNetwork Send error, encode error, error: " .. error)
        return
    end

    CS.XNetwork.Send(handler, requestContent);
end

function XNetwork.Call(handler, request, reply)
    local requestContent, error = XMessagePack.Encode(request)
    if requestContent == nil then
        XLog.Error("XNetwork Call error, encode error, error: " .. error)
        return
    end

    CS.XNetwork.Call(handler, requestContent, function(responseContent)
        local response, err = XMessagePack.Decode(responseContent)
        if response == nil then
            XLog.Error("XNetwork Call error, decode error, error: " .. err)
            return
        end

        reply(response)
    end)
end

function XNetwork.CallKcp(handler, request, reply)
    local requestContent, error = XMessagePack.Encode(request)
    if requestContent == nil then
        XLog.Error("XNetwork Call Kcp error, encode error, error: " .. error)
        return
    end

    CS.XNetwork.CallKcp(handler, requestContent, function(responseContent)
        local response, err = XMessagePack.Decode(responseContent)
        if response == nil then
            XLog.Error("XNetwork Call Kcp error, decode error, error: " .. err)
            return
        end

        reply(response)
    end)
end