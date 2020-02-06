
XComeAcrossManagerCreator = function()
    local XComeAcrossManager = {}
    --更新冷却
    local GAME_REFRESH_TIME = 3600
    local GRID_COUNT_LIMIT = 5 -- 最多五个关卡 

    --上次更新的时间
    local LastRefreshTime = -1
    local LastReuslt = nil
    local CurComeAcrossGames = nil
    local PlayCount = 0
    local COMEACROSS_PROTO ={
        TrustGamePlayRequest = "TrustGamePlayRequest",
        TrustGameResultRequest = "TrustGameResultRequest"
    }

    --获取偶遇小游戏列表
    function XComeAcrossManager.GetComeAcrossGames()
        if CurComeAcrossGames == nil or XTime.GetServerNowTimestamp() > LastRefreshTime + GAME_REFRESH_TIME then

            local ownsCharacter = XDataCenter.CharacterManager.GetOwnCharacterList()
            if not ownsCharacter then
                return false
            end
        
            local charaterData = XComeAcrossManager.RandowGetOwnCharacter(ownsCharacter)
            if not charaterData then
                return false
            end

            local count = #charaterData
            CurComeAcrossGames = XComeAcrossConfig.RandomNumberGetGameConfig(count)
            if CurComeAcrossGames then
                for i,v in ipairs(CurComeAcrossGames) do
                    v.Character = charaterData[i]
                end
            end

            LastRefreshTime = XTime.GetServerNowTimestamp()
        end

        return CurComeAcrossGames
    end


    --随机获取拥有的角色
    function XComeAcrossManager.RandowGetOwnCharacter(characters)
        if not characters then
            return
        end

        if #characters <= GRID_COUNT_LIMIT then
            return characters
        end

        local chars = {}
        for i = 1, GRID_COUNT_LIMIT,1 do
            local length = #characters 
            local rand = math.random(1,length)
            local char = table.remove(characters, rand)
            table.insert(chars, char)
        end

        return chars
    end

    --获取游戏次数
    function XComeAcrossManager.GetPlayCount()
        return PlayCount
    end

      --获取最近一次结算
      function XComeAcrossManager.GetLastResult()
        return LastReuslt
    end

    

    ------------------------------------------------
    --数据下发
    function XComeAcrossManager.NotifyTrustGameData(data)
        if not data then
            return
        end

        PlayCount = data.TrustData.PlayCount
    end

    --请求游戏开始
    function XComeAcrossManager.ReqTrustGamePlayRequest(cb)
        XNetwork.Call(COMEACROSS_PROTO.TrustGamePlayRequest,nil, function(res)
            if res.code ~= XCode.Success then
                XUiManager.TipCode(res.code)
                return
            end
            
            if cb then
                cb()
            end

            PlayCount = PlayCount + 1
            XEventManager.DispatchEvent(XEventId.EVENT_COMEACROSS_PLAY)
        end)
    end

    --请求游戏结算
    function XComeAcrossManager.ReqTrustGameResultRequest(characterId,gameId,finishNum,cb)
        XNetwork.Call(COMEACROSS_PROTO.TrustGameResultRequest,{CharacterId = characterId, GameId = gameId,FinishNum = finishNum }, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            if cb then
                cb(res)
            end

            LastReuslt = res
            XEventManager.DispatchEvent(XEventId.EVENT_COMEACROSS_PLAYRESULT)
        end)
    end

    return XComeAcrossManager
end

XRpc.NotifyTrustGameData = function(data)
    XDataCenter.ComeAcrossManager.NotifyTrustGameData(data)
end