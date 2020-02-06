XServerManager = XServerManager or {}

XServerManager.SERVER_STATE = {
    MAINTAIN = 0, -- 维护
    LOW = 1,  -- 畅通
    GIGH = 2    -- 爆满
}

-- 服务器状态优先级
local ServerStatePriority = {
    [XServerManager.SERVER_STATE.MAINTAIN] = 0,
    [XServerManager.SERVER_STATE.LOW] = 2,
    [XServerManager.SERVER_STATE.GIGH] = 1,
}

local ServerList = {}

local GetServerDataCb

XServerManager.Id = nil
XServerManager.ServerName = nil

XServerManager.LastId = nil

function XServerManager.GetLoginUrl()
    XServerManager.LastId = XServerManager.Id
    local server = ServerList[XServerManager.Id]
    if not server then
        return nil
    end

    return server.LoginUrl
end

function XServerManager.CheckIsChangedServer()
    return XServerManager.LastId ~= XServerManager.Id
end

function XServerManager.Init(cb)
    XServerManager.Id = CS.UnityEngine.PlayerPrefs.GetInt(XPrefs.ServerId, 1)

    ServerList = {}
    local i = 1
    local strs = string.Split(CS.XRemoteConfig.ServerListStr, "|")
    for _, value in ipairs(strs) do
        local item = string.Split(value, "#")
        if #item >= 2 then
            local server = {}
            server.Id = i
            server.Name = item[1]
            server.State = 2
            server.LoginUrl = item[2]

            ServerList[server.Id] = server
            i = i + 1
        end
    end

    if not ServerList or #ServerList <= 0 then
        XLog.Error("getServerList content error. content = " .. CS.XRemoteConfig.ServerListStr)
        return
    end

    if XServerManager.Id and ServerList[XServerManager.Id] then
        XServerManager.Select(ServerList[XServerManager.Id])
    else
        XServerManager.Select(ServerList[1])
    end

    if cb then
        cb()
    end
end

function XServerManager.Select(server)
    if not server then
        XLog.Error("Selected Server is nil.")
        return
    end

    XServerManager.Id = server.Id
    XServerManager.ServerName = server.Name

    CS.UnityEngine.PlayerPrefs.SetInt(XPrefs.ServerId, server.Id)
end

function XServerManager.GetServerList(  )
    return ServerList
end

function XServerManager.GetCurServerName(  )
    return XServerManager.ServerName
end