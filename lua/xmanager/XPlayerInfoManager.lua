--查看玩家信息管理器
XPlayerInfoManagerCreator = function()
    local XPlayerInfoManager = {}
    --缓存玩家信息
    local PlayerInfoCache = {}
    local PlayerInfoCacheTime = {}
    local PlayerInfoSetCacheTime = -9999
    --请求间隔
    local GET_PLAYER_INFO_INTERVAL = 120
    local SET_PLAYER_INFO_INTERVAL = 0

    local PlayerInfoRequest = {
        RequestPlayerInfo = "QueryPlayerDetailRequest", -- 获取玩家信息
    }
    --请求玩家信息
    function XPlayerInfoManager.RequestPlayerInfoData(playerId, cb)
        --检查缓存
        if PlayerInfoCache[playerId] ~= nil then
            if XTime.GetServerNowTimestamp() - PlayerInfoCacheTime[playerId] < GET_PLAYER_INFO_INTERVAL then
                if cb then
                    cb(PlayerInfoCache[playerId])
                end
                return
            end
        end

        XNetwork.Call(PlayerInfoRequest.RequestPlayerInfo, { PlayerId = playerId }, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end
            --res.data(XPersonalInfoAttribute)
            PlayerInfoCache[playerId] = res.Detail
            PlayerInfoCacheTime[playerId] = XTime.GetServerNowTimestamp()

            --XEventManager.DispatchEvent(XEventId.EVENT_REQUEST_PLAYER_INFO_BACK, playerId, PlayerInfoCache[playerId])

            if cb then
                cb(PlayerInfoCache[playerId])
            end
        end)
    end
    --保存展示信息
    function XPlayerInfoManager.SaveData(characterIds, cb)
        XPlayer.SetAppearance(characterIds, cb)
    end
    return XPlayerInfoManager
end