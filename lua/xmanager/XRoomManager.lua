XRoomManagerCreator = function()
    local XRoomManager = {
        IsOpen = false,
        UiRoom = nil,
        UiOnlineInstance = nil,
        Matching = false,
        MatchStageId = nil,
        RoomData = nil,
        StageInfo = nil, --关卡
    }

    XRoomManager.PlayerState = {
        Normal = 0,
        Ready = 1,
        Select = 2,
        Clump = 3,
        Fight = 4,
        Settle = 5,
    }

    XRoomManager.IndexType = {
        Left = 1,
        Center = 2,
        Right = 3,
        Max = 3
    }

    local RequestProto = {
        CreateRoomRequest = "CreateRoomRequest", --创建房间
        MatchRoomRequest = "MatchRoomRequest", --匹配
        CancelMatchRequest = "CancelMatchRequest", --取消匹配
        ChangeQuickMatchRequest = "ChangeQuickMatchRequest", --快速匹配
        QuitRoomRequest = "QuitRoomRequest", --退出房间
        ReadyRequest = "ReadyRequest", --准备
        CancelReadyRequest = "CancelReadyRequest", --取消准备
        EnterFightRequest = "EnterFightRequest", -- 进入战斗
        SelectRequest = "SelectRequest", --抽卡
        ChangeLeaderRequest = "ChangeLeaderRequest", --切换房主
        KickOutRequest = "KickOutRequest", --踢人
        AddLikeRequest = "AddLikeRequest", --
        UpdateLoadProcessRequest = "UpdateLoadProcessRequest", -- 更新进度
        EnterTargetRoomRequest = "EnterTargetRoomRequest", -- 进入目标房间
        SelectRewardRequest = "SelectRewardRequest",
        ChangePlayerStateRequest = "ChangePlayerStateRequest",
        BeginSelectRequest = "BeginSelectRequest", -- 进入切换角色状态
        EndSelectRequest = "EndSelectRequest", -- 退出切换角色状态
        JoinFightRequest = "JoinFightRequest", --请求进入战斗服
        SetStageLevelRequest = "SetStageLevelRequest", --请求进入战斗服
        SetAutoMatchRequest = "SetAutoMatchRequest", --请求进入战斗服
        SetAbilityLimitRequest = "SetAbilityLimitRequest" --修改房间战力限制
    }

    --获取默认角色
    function XRoomManager.GetDefaultChar()
        local list = XDataCenter.CharacterManager.GetOwnCharacterList()
        local char
        for k, v in pairs(list) do
            if not char or v.Ability > char.Ability then
                char = v
            end
        end
        return char
    end

    --创建房间
    function XRoomManager.CreateRoom(stageId, cb)
        local req = {
            StageId = stageId,
            StageLevel = 1,
            AutoMatch = true,
        }
        XNetwork.Call(RequestProto.CreateRoomRequest, req, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end
            XRoomManager.Matching = false
            XRoomManager.MatchStageId = nil
            XRoomManager.OnCreateRoom(res.RoomData)
            if cb then
                cb()
            end
        end)
    end

    function XRoomManager.OnCreateRoom(roomData)
        -- 创建房间
        if XDataCenter.RoomManager.RoomData then
            XLog.Error("XRoomManager.OnCreateRoom error, RoomManager is already has RoomData")
            XDataCenter.RoomManager.RoomData = roomData
            XEventManager.DispatchEvent(XEventId.EVENT_ROOM_REFRESH, roomData)
        else
            XDataCenter.RoomManager.RoomData = roomData
            XRoomManager.Matching = false
            XRoomManager.MatchStageId = nil
            --如果是聊天跳转，需要先关闭聊天
            if XLuaUiManager.IsUiShow("UiChatServeMain") then
                XLuaUiManager.Close("UiChatServeMain")
            end
            -- XLuaUiManager.Open("UiOnLineTranscriptRoom")
            XLuaUiManager.Open("UiMultiplayerRoom")
            XEventManager.DispatchEvent(XEventId.EVENT_ROOM_ENTER_ROOM)
        end
    end

    function XRoomManager.ChangePlayerState(state)
        local req = { RoomPlayerState = state }
        XNetwork.Send(RequestProto.ChangePlayerStateRequest, req)
    end

    function XRoomManager.BeginSelectRequest(cb)
        XNetwork.Call(RequestProto.BeginSelectRequest, {}, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end
            if cb then
                cb()
            end
        end)
    end

    function XRoomManager.EndSelectRequest(cb)
        XNetwork.Call(RequestProto.EndSelectRequest, {}, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end
            if cb then
                cb()
            end
        end)
    end

    --匹配
    function XRoomManager.Match(stageId, cb)
        local req = { StageId = stageId }

        XNetwork.Call(RequestProto.MatchRoomRequest, req, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end
            XRoomManager.Matching = true
            XRoomManager.MatchStageId = stageId

            if cb then
                cb()
            end
            XEventManager.DispatchEvent(XEventId.EVENT_ROOM_MATCH)
        end)
    end

    --取消匹配
    function XRoomManager.CancelMatch(cb)
        if XRoomManager.DoingCancel or not XRoomManager.Matching then
            if cb then
                cb()
            end
            return
        end
        XRoomManager.DoingCancel = true

        local req = { StageId = XRoomManager.MatchStageId }
        XNetwork.Call(RequestProto.CancelMatchRequest, req, function(res)
            XRoomManager.DoingCancel = false
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            XRoomManager.Matching = false
            XRoomManager.MatchStageId = nil

            if cb then
                cb()
            end

            XEventManager.DispatchEvent(XEventId.EVENT_ROOM_CANCEL_MATCH)
        end)
    end

    --快速匹配开关
    --true打开false关闭快速匹配
    function XRoomManager.QuickMatch(isOn, cb)
        local req = { IsOpen = isOn }
        XNetwork.Call(RequestProto.ChangeQuickMatchRequest, req, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            if cb then
                cb(res.Code == XCode.Success)
            end

        end)
    end

    --退出房间
    function XRoomManager.Quit(cb)
        local req = {}
        XNetwork.Call(RequestProto.QuitRoomRequest, req, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
            end
            XRoomManager.RoomData = nil
            XEventManager.DispatchEvent(XEventId.EVENT_ROOM_LEAVE_ROOM)
            if cb then
                cb()
            end
        end)
    end

    --准备
    function XRoomManager.Ready(cb)
        XNetwork.Call(RequestProto.ReadyRequest, {}, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            if cb then
                cb()
            end
        end)
    end

    --取消准备
    function XRoomManager.CancelReady(cb)
        XNetwork.Send(RequestProto.CancelReadyRequest, {})
    end

    --进入战斗
    function XRoomManager.Enter(cb)
        if not XRoomManager.RoomData then
            return
        end

        local stageInfo = XDataCenter.FubenManager.GetStageInfo(XRoomManager.RoomData.StageId)
        if stageInfo.Type == XDataCenter.FubenManager.StageType.BossOnline and XDataCenter.FubenBossOnlineManager.CheckOnlineBossTimeOut() then
            XUiManager.TipMsg(CS.XTextManager.GetText("OnlineBossTimeOut"))
            return
        end

        XNetwork.Call(RequestProto.EnterFightRequest, {}, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            if cb then
                cb(res)
            end
        end)
    end

    function XRoomManager.Select(charId, cb)
        local req = { CharacterId = charId }

        XNetwork.Call(RequestProto.SelectRequest, req, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            if cb then
                cb(res.Code)
            end
        end)
    end

    --切换房主
    function XRoomManager.ChangeLeader(playerId, cb)
        local req = { PlayerId = playerId }
        XNetwork.Call(RequestProto.ChangeLeaderRequest, req, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            if cb then
                cb()
            end
        end)
    end

    --踢出房间
    function XRoomManager.KickOut(playerId, cb)
        local req = { PlayerId = playerId }
        XNetwork.Call(RequestProto.KickOutRequest, req, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end
            if cb then
                cb()
            end
        end)
    end

    -- 设置房间等级难度
    function XRoomManager.SetStageLevel(level, cb)
        local req = { Level = level }
        XNetwork.Call(RequestProto.SetStageLevelRequest, req, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end
            if cb then
                cb()
            end
        end)
    end

    -- 设置房间是否自动匹配
    function XRoomManager.SetAutoMatch(autoMatch, cb)
        local req = { AutoMatch = autoMatch }
        XNetwork.Call(RequestProto.SetAutoMatchRequest, req, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end
            if cb then
                cb()
            end
        end)
    end

    -- 设置房间是否自动匹配
    function XRoomManager.SetAbilityLimit(abilityLimit, cb)
        local req = { AbilityLimit = abilityLimit }
        XNetwork.Call(RequestProto.SetAbilityLimitRequest, req, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end
            if cb then
                cb()
            end
        end)
    end

    --
    function XRoomManager.AddLike(playerId)
        local req = { PlayerId = playerId }
        XNetwork.Send(RequestProto.AddLikeRequest, req)
    end

    function XRoomManager.UpdateLoadProcess(progress)
        --更新进度
        local req = { Process = progress }
        XNetwork.Send(RequestProto.UpdateLoadProcessRequest, req)
    end

    function XRoomManager.ClickEnterRoomHref(param, createTime)
        if not param then
            return
        end

        local result = string.Split(param, '|')
        local roomId = result[1]
        local stageId = tonumber(result[2])

        local stageInfo = XDataCenter.FubenManager.GetStageInfo(stageId)
        if not stageInfo then
            return
        end

        local fubenName = ""
        if stageInfo.Type == XDataCenter.FubenManager.StageType.BossOnline then
            fubenName = XFunctionManager.FunctionName.FubenActivity
        elseif stageInfo.Type == XDataCenter.FubenManager.StageType.Daily then
            local challengeCfg = XDataCenter.FubenDailyManager.GetDailyCfgBySectionId(stageInfo.DailySectionId)
            if challengeCfg and challengeCfg.Type == XDataCenter.FubenManager.ChapterType.EMEX then
                fubenName = XFunctionManager.FunctionName.FubenDailyEMEX
            end
        end

        if not XFunctionManager.DetectionFunction(fubenName) then
            return
        end

        --超链接点击
        XRoomManager.EnterTargetRoom(roomId, stageId, createTime)
    end

    function XRoomManager.EnterTargetRoom(roomId, stageId, createTime)
        --进入房间
        if XRoomManager.RoomData then
            XUiManager.TipCode(XCode.MatchPlayerAlreadyInRoom)
            return
        end

        if XTime.GetServerNowTimestamp() > createTime + CS.XGame.Config:GetInt("RoomHrefDisableTime") then
            XUiManager.TipText("RoomHrefDisabled")
            return
        end

        local req = { RoomId = roomId, StageId = stageId }
        XNetwork.Call(RequestProto.EnterTargetRoomRequest, req, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            XRoomManager.OnCreateRoom(res.RoomData)
            XUiManager.TipText("OnlineInstanceEnterRoom", XUiManager.UiTipType.Success)
        end)
    end

    function XRoomManager.SelectReward(pos)
        --抽奖
        local req = { Pos = pos }

        XNetwork.Send(RequestProto.SelectRewardRequest, req)
    end

    function XRoomManager.OnJoinFightNotify(response)
        local roomData = XDataCenter.RoomManager.RoomData
        if not roomData then
            XLog.Error("XRoomManager.OnJoinFightNotify error")
            return
        end

        XNetwork.Call(RequestProto.JoinFightRequest, { NodeId = response.NodeId }, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            -- 进入战斗前关闭所有弹出框
            XLuaUiManager.Remove("UiDialog")
            XDataCenter.FubenManager.OnEnterFight(res.FightData)
        end)
    end

    function XRoomManager.OnDisconnect()
        if XRoomManager.Matching then
            XRoomManager.Matching = false
            XEventManager.DispatchEvent(XEventId.EVENT_ROOM_CANCEL_MATCH)
        end

        if XRoomManager.RoomData then
            -- 关战斗
            if CS.XFight.Instance and CS.XFight.Instance.Online then
                XLuaUiManager.Close("UiLoading")
                XLuaUiManager.Close("UiOnLineLoading")
                CS.XFight.ClearFight()
            end

            if XLuaUiManager.IsUiShow("UiChatServeMain") then
                XLuaUiManager.Close("UiChatServeMain")
            end
        
            if XLuaUiManager.IsUiShow("UiDialog") then
                XLuaUiManager.Close("UiDialog")
            end

            -- 关房间
            if XLuaUiManager.IsUiShow("UiMultiplayerRoom") then
                XLuaUiManager.Close("UiMultiplayerRoom")
            else
                XLuaUiManager.Remove("UiMultiplayerRoom")
            end

            XLuaUiManager.ShowTopUi()
            
            -- 提示&清数据
            XUiManager.TipText("OnlineRoomOnDisconnet")
            XRoomManager.RoomData = nil
            XEventManager.DispatchEvent(XEventId.EVENT_ROOM_LEAVE_ROOM)
        end
    end

    -- 监听断网
    XEventManager.AddEventListener(XEventId.EVENT_NETWORK_DISCONNECT, XRoomManager.OnDisconnect, XRoomManager)

    return XRoomManager
end

XRpc.SelectRewardNotify = function(data)
    XEventManager.DispatchEvent(XEventId.EVENT_ONLINEBOSS_DROPREWARD_NOTIFY, data)
end

--踢出房间
XRpc.KickOutNotify = function(response)
    if response.Code and response.Code ~= XCode.Success then
        XUiManager.TipCode(response.Code)
    end
    XDataCenter.RoomManager.RoomData = nil
    XEventManager.DispatchEvent(XEventId.EVENT_ROOM_LEAVE_ROOM)
    XEventManager.DispatchEvent(XEventId.EVENT_ROOM_KICKOUT)
end

--更新进度条
XRpc.RefreshLoadProcessNotify = function(response)
    XEventManager.DispatchEvent(XEventId.EVENT_FIGHT_PROGRESS, response.PlayerId, response.Process)
end

XRpc.FightPlayerListNotify = function(response)
    XDataCenter.RoomManager.FightPlayerList = response.PlayerIdList
end

--踢人倒计时
XRpc.OnCountDownNotify = function(response)
    if response.TimeCount == 0 then
        XDataCenter.RoomManager.CountDowning = false
    else
        XDataCenter.RoomManager.CountDowning = true
    end
    XEventManager.DispatchEvent(XEventId.EVENT_ROOM_COUNT_DOWN, response.TimeCount)
end

--匹配通知
XRpc.MatchNotify = function(response)
    if not XDataCenter.RoomManager.Matching then
        return
    end

    if response.Code == XCode.Success then
        XDataCenter.RoomManager.OnCreateRoom(response.RoomData)
    else
        XDataCenter.RoomManager.Matching = false
        XRoomManager.MatchStageId = nil
        XEventManager.DispatchEvent(XEventId.EVENT_ROOM_CANCEL_MATCH)
    end
end

XRpc.PlayerSyncInfoNotify = function(response)
    local roomData = XDataCenter.RoomManager.RoomData
    if roomData then
        for _, playerInfo in pairs(response.PlayerInfoList) do
            for k, v in pairs(roomData.PlayerDataList) do
                if v.Id == playerInfo.Id then
                    v.State = playerInfo.State
                    v.Leader = playerInfo.Leader
                    if playerInfo.FightNpcData then
                        v.FightNpcData = playerInfo.FightNpcData
                    end
                    break
                end
            end
        end

        -- 先赋值再通知事件
        for _, playerInfo in pairs(response.PlayerInfoList) do
            for k, v in pairs(roomData.PlayerDataList) do
                if v.Id == playerInfo.Id then
                    if playerInfo.FightNpcData then
                        XEventManager.DispatchEvent(XEventId.EVENT_ROOM_PLAYER_NPC_REFRESH, v)
                    else
                        XEventManager.DispatchEvent(XEventId.EVENT_ROOM_PLAYER_STAGE_REFRESH, v)
                    end
                    break
                end
            end
        end

        -- XEventManager.DispatchEvent(XEventId.EVENT_ROOM_REFRESH, roomData)
    end
end

XRpc.PlayerEnterNotify = function(response)
    local roomData = XDataCenter.RoomManager.RoomData
    if roomData then
        table.insert(roomData.PlayerDataList, response.PlayerData)
        -- XEventManager.DispatchEvent(XEventId.EVENT_ROOM_REFRESH, roomData)
        XEventManager.DispatchEvent(XEventId.EVENT_ROOM_PLAYER_ENTER, response.PlayerData)
    end
end

XRpc.PlayerLeaveNotify = function(response)
    local roomData = XDataCenter.RoomManager.RoomData
    if roomData then
        for _, targetId in pairs(response.Players) do
            for k, v in pairs(roomData.PlayerDataList) do
                if v.Id == targetId then
                    table.remove(roomData.PlayerDataList, k)
                    XEventManager.DispatchEvent(XEventId.EVENT_ROOM_PLAYER_LEAVE, targetId)
                    break
                end
            end
        end
        -- XEventManager.DispatchEvent(XEventId.EVENT_ROOM_REFRESH, roomData)
    end
end

XRpc.JoinFightNotify = function(response)
    if not XDataCenter.RoomManager.RoomData then
        return
    end
    XDataCenter.RoomManager.OnJoinFightNotify(response)
end

XRpc.RoomInfoChangeNotify = function(response)
    local roomData = XDataCenter.RoomManager.RoomData
    local lastAutoMatch = roomData.AutoMatch
    local lastStageLevel = roomData.StageLevel
    local lastAbilityLimit = roomData.AbilityLimit
    roomData.AutoMatch = response.AutoMatch
    roomData.StageLevel = response.StageLevel
    roomData.AbilityLimit = response.AbilityLimit
    -- 先全部赋值再发事件
    if lastAutoMatch ~= roomData.AutoMatch then
        XEventManager.DispatchEvent(XEventId.EVENT_ROOM_AUTO_MATCH_CHANGE, roomData.AutoMatch)
    end
    if lastStageLevel ~= roomData.StageLevel then
        XEventManager.DispatchEvent(XEventId.EVENT_ROOM_STAGE_LEVEL_CHANGE, lastStageLevel, roomData.StageLevel)
    end
    if lastAbilityLimit ~= roomData.AbilityLimit then
        XEventManager.DispatchEvent(XEventId.EVENT_ROOM_STAGE_ABILITY_LIMIT_CHANGE, lastAbilityLimit, roomData.AbilityLimit)
    end
end

XRpc.RoomStateNotify = function(response)
    local roomData = XDataCenter.RoomManager.RoomData
    roomData.State = response.State
    XEventManager.DispatchEvent(XEventId.EVENT_ROOM_STAGE_CHANGE, response.State)
end