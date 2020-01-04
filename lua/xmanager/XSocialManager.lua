XSocialManagerCreator = function()
    local Json = require("XCommon/Json")
    local XSocialManager = {}

    local TABLE_FETTERS_PATH = "Share/Social/FettersLevel.tab"

    local FRIEND_ID_DATA_NAME = "SocialFriendIdList"

    local FRIEND_SEARCH_INTERVAL_TIME = 0       --搜索冷却时间
    local FRIEND_DELETE_APPLY_INTERVAL_SECOND = 0 --删除申请冷却时间
    local FRIEND_REFUSE_APPLY_INTERVAL_SECOND = 0 --拒绝申请冷却时间
    local FRIEND_MAINMAXCLICK_INTERVAL_TIME = 0
    local GET_GIFT_MAXCOUNT_EVERYDAY = 0 --当日收取礼物次数

    local FriendMap = {}                    --好友列表
    local WaitPassMap = {}                     --申请列表
    local RecommendList = {}                --推荐好友列表
    local ApplyedList = {}                  --已申请玩家列表
    local WaitPassLocalMap = {}             --本地申请记录
    
    local LastRecommendTime = 0             --上次推荐时间
    local ApplyCount = 0
    local A_WEEK = 60 * 60 * 24 * 7         --记录保存时长

    local SocialDataTimeInterval = 2 * 60
    local SocialPlayerCache = {}
    local FetterLevelTemplates = {}

    local METHOD_NAME = {
        GetRecommendPlayers = "GetRecommendPlayerListRequest", --获取推荐的好友
        ApplyFriend = "ApplyFriendRequest",                 --申请好友
        OperationFriendReq = "OperationApplyFriendRequest",     --同意或者拒绝的时候调用
        DeleteFriends = "DeleteFriendRequest",             --删除好友
        GetSpecifyPlayer = "GetSpecifyPlayerInfoRequest",   --获取指定的玩家信息  搜索
        GetPlayerInfoList = "GetPlayerInfoListRequest",     --根据Id获取玩家列表
    }

    --------------------------Init----------------------------
    function XSocialManager.Init()
        FRIEND_SEARCH_INTERVAL_TIME = CS.XGame.Config:GetInt("FriendSearchSinglePlayerIntervalTime")
        FRIEND_DELETE_APPLY_INTERVAL_SECOND = CS.XGame.Config:GetInt("FriendDeleteApplyIntervalSecond")
        FRIEND_REFUSE_APPLY_INTERVAL_SECOND = CS.XGame.Config:GetInt("FriendRefuseApplyIntervalSecond")
        FRIEND_MAINMAXCLICK_INTERVAL_TIME = CS.XGame.Config:GetInt("FriendMainMaxClickIntervalTime")
        GET_GIFT_MAXCOUNT_EVERYDAY = CS.XGame.Config:GetInt("GetGiftMaxCountEveryDay")

        FetterLevelTemplates = XTableManager.ReadByIntKey(TABLE_FETTERS_PATH, XTable.XTableFetter, "Level")
    end

    --Public Method
    --初始化社交数据
    function XSocialManager.InitSocialData(socialData)

        if socialData.FriendData then
            FriendMap = {}

            XTool.LoopCollection(socialData.FriendData, function(value)
                XSocialManager.AddFriend(XFriend.New(value.PlayerId, value.CreateTime))
            end)

            -- 清除无效好友聊天数据
            XSocialManager.CheckDeleteFriend()
        end

        if socialData.ApplyData then
            WaitPassMap = {}
            XTool.LoopCollection(socialData.ApplyData, function(value)
                XSocialManager.AddWaitPassFriend(XFriend.New(value.PlayerId, value.CreateTime), true)
            end)
            XSocialManager.InitCheckWaitPassLocalMap()
        end

        --加载私聊数据
        XDataCenter.ChatManager.InitFriendPrivateChatData()

        -- 监听角色数据查询结果，更新好友数据
        XEventManager.AddEventListener(XEventId.EVENT_REQUEST_PLAYER_INFO_BACK, XSocialManager.UpdateSinglePlayerCache)
    end

    -- 获取缓存的好友id列表
    function XSocialManager.GetTempFriendIdList()
        local tempFriendIdList = {}
        if CS.UnityEngine.PlayerPrefs.HasKey(FRIEND_ID_DATA_NAME) then
            local content = CS.UnityEngine.PlayerPrefs.GetString(FRIEND_ID_DATA_NAME)
            local tab = string.Split(content, '\t')
            for k, v in pairs(tab) do
                local friendId = tonumber(v)
                if friendId then
                    tempFriendIdList[friendId] = true
                end
            end
        end
        return tempFriendIdList
    end

    -- 清除无效好友聊天数据
    function XSocialManager.CheckDeleteFriend()
        local lastList = XSocialManager.GetTempFriendIdList()
        for friendId, _ in pairs(lastList) do
            if not FriendMap[friendId] then
                XDataCenter.ChatManager.ClearFriendChatContent(friendId)
            end
        end
    end

    -- 缓存好友id列表
    function XSocialManager.SaveTempFriendIdList()
        local saveContent = ""

        for k, v in pairs(FriendMap) do
            saveContent = saveContent .. v.FriendId .. '\t'
        end
        CS.UnityEngine.PlayerPrefs.SetString(FRIEND_ID_DATA_NAME, saveContent)
        CS.UnityEngine.PlayerPrefs.Save()
    end

    function XSocialManager.CheckIsFriend(playerId)
        return XSocialManager.GetFriendInfo(playerId) ~= nil
    end

    function XSocialManager.CheckIsApplyed( playerId )
        for k, v in pairs(ApplyedList) do
            if v == playerId then
                return true
            end
        end
        return false
    end

    function XSocialManager.AddFriend(friendData)
        if not friendData then
            return
        end
        FriendMap[friendData.FriendId] = friendData

        XSocialManager.SaveTempFriendIdList()
    end

    function XSocialManager.DelFriend(friendId)
        if not friendId then
            return
        end
        XDataCenter.ChatManager.ClearFriendChatContent(friendId)

        if SocialPlayerCache[friendId] then
            SocialPlayerCache[friendId].FriendExp = 0
        end
        
        FriendMap[friendId] = nil

        XSocialManager.SaveTempFriendIdList()

        XEventManager.DispatchEvent(XEventId.EVENT_FRIEND_DELETE, friendId)
    end

    --添加等待通过数据
    function XSocialManager.AddWaitPassFriend(friendData, ignoreCheckWaitPass)
        if not friendData then
            return
        end

        ApplyCount = ApplyCount + 1
        WaitPassMap[friendData.FriendId] = friendData

        if not ignoreCheckWaitPass then
            XEventManager.DispatchEvent(XEventId.EVENT_FRIEND_WAITING_PASS)
        end
    end

    -- 登录初始化WaitPassMap，初始化本地数据，然后触发一次检查
    function XSocialManager.InitCheckWaitPassLocalMap()
        local key = string.format("%s_WaitPass", tostring(XPlayer.Id))
        local cache = CS.UnityEngine.PlayerPrefs.GetString(key)
        local now = XTime.Now()
        if not string.IsNilOrEmpty(cache) then
            local cacheTable = Json.decode(cache)
            for playerId, overTime in pairs(cacheTable or {}) do
                if now < overTime then
                    WaitPassLocalMap[tostring(playerId)] = overTime
                end
            end
        end
        XEventManager.DispatchEvent(XEventId.EVENT_FRIEND_WAITING_PASS)
    end

    -- 点击等待通过-保存已经点了的数据-清除过期数据
    function XSocialManager.ResetWaitPassLocalMap()
        local key = string.format("%s_WaitPass", tostring(XPlayer.Id))
        local now = XTime.Now()
        WaitPassLocalMap = {}
        for k, v in pairs(WaitPassMap or {}) do
            local overTime = v.CreateTime + A_WEEK
            if now < overTime then
                WaitPassLocalMap[tostring(k)] = overTime
            end
        end
        CS.UnityEngine.PlayerPrefs.SetString(key, Json.encode(WaitPassLocalMap))
        CS.UnityEngine.PlayerPrefs.Save()
        XEventManager.DispatchEvent(XEventId.EVENT_FRIEND_WAITING_PASS)
    end

    -- 红点检查
    function XSocialManager.HasFriendApplyWaitPass()
        local key = string.format("%s_WaitPass", tostring(XPlayer.Id))
        local now = XTime.Now()
        for playerId, playerData in pairs(WaitPassMap or {}) do
            local overTime = playerData.CreateTime + A_WEEK
            if not WaitPassLocalMap[tostring(playerId)] and now < overTime then
                return true
            end
        end
        return false
    end

    function XSocialManager.RefreshRecommendData(dataList)
        if dataList then
            LastRecommendTime = XTime.Now()
            RecommendList = {}
            XTool.LoopCollection(dataList, function(item)
                local friend = XFriend.New(0, 0, 0)
                friend:Update(item)
                table.insert(RecommendList, friend)
            end)
        end
    end
    --End Public Method


    --Get Method

    --获取好友ID
    function XSocialManager.GetFriendIds()
        local list = {}
        for key, value in pairs(FriendMap) do
            table.insert(list, key)
        end
        return list
    end

    --上次推荐好友刷新时间
    function XSocialManager.GetLastRecommendTime()
        return LastRecommendTime
    end

    --推荐好友列表
    function XSocialManager.GetRecommendList()
        return RecommendList
    end

    function XSocialManager.RemoveRecommendPlay(id)
        local index = 0
        for i, info in ipairs(RecommendList) do
            if info.FriendId == id then
                index = i
                break
            end
        end

        if index > 0 then
            table.remove(RecommendList, index)
        end
    end

    --好友申请者信息列表
    function XSocialManager.GetApplyFriendList()
        local list = {}
        for key, value in pairs(WaitPassMap) do
            if not XSocialManager.CheckIsFriend(key) then
                table.insert(list, value)
            end
        end
        return list
    end

    --单个好友信息
    function XSocialManager.GetFriendInfo(friendId)
        return FriendMap[friendId]
    end

    --全部好友信息列表
    function XSocialManager.GetFriendList()
        local list = {}
        for key, value in pairs(FriendMap) do
            table.insert(list, value)
        end
        return list
    end

    --好友数量
    function XSocialManager.GetFriendCount()
        local friendIds = XSocialManager.GetFriendIds()
        return #friendIds
    end

    function XSocialManager.GetSearchFriendCoolDownTime()
        return FRIEND_SEARCH_INTERVAL_TIME
    end

    function XSocialManager.GetDeleteApplyCoolDownTime()
        return FRIEND_DELETE_APPLY_INTERVAL_SECOND
    end

    function XSocialManager.GetRefuseApplyCoolDownTime()
        return FRIEND_REFUSE_APPLY_INTERVAL_SECOND
    end

    --配置表每日最大可领取礼物的数量
    function XSocialManager.GetGiftMaxCount()
        return GET_GIFT_MAXCOUNT_EVERYDAY
    end
    --End Get Method

    --刷新推荐列表
    function XSocialManager.GetRecommendPlayers(cb)
        cb = cb or function(code)
        end

        XNetwork.Call(METHOD_NAME.GetRecommendPlayers, nil, function(response)
            if response.Code ~= XCode.Success then
                XUiManager.TipCode(response.Code)
                cb(response.Code,response.RefreshTime)
                return
            end
            XSocialManager.RefreshRecommendData(response.RecommendFriendsList)
            cb(response.Code,response.RefreshTime)
        end)
    end

    --处理服务器返回的错误码
    function XSocialManager:HandleErrorCode(code)
        if code == XCode.FriendManagerApplyFriendFailedIsDeleted then
            return XSocialManager.GetDeleteApplyCoolDownTime()
        elseif code == XCode.FriendManagerApplyFriendFailedIsRefused then
            return XSocialManager.GetRefuseApplyCoolDownTime()
        else
            XUiManager.TipCode(code)
        end
        return nil
    end

    --申请添加好友
    function XSocialManager.ApplyFriend(id, successCb, failedCb)
        if not id or id <= 0 then
            return
        end
        failedCb = failedCb or function() end
        if XSocialManager.CheckIsFriend(id) then
            XUiManager.TipText("AlreadyFriends")
            failedCb()
            return
        end

        successCb = successCb or function()
        end
        XNetwork.Call(METHOD_NAME.ApplyFriend, {TargetPlayerId = id}, function(response)
            if not XSocialManager.CheckIsApplyed(id) then
                table.insert(ApplyedList, id)
            end
            if response.Code ~= XCode.FriendManagerApplySuccess then
                local interval = XSocialManager:HandleErrorCode(response.Code)
                if interval ~= nil then
                    local curTime = XTime.Now()
                    local timeDifference = (response.OperationTime + interval - curTime) / 3600
                    XUiManager.TipError(CS.XTextManager.GetText("ApplyForTip", math.ceil(timeDifference)))
                end
                failedCb()
                return
            end
            XUiManager.TipText("FriendApplySuccess")
            successCb(response.Code)
        end)
    end

    --更新好友信息列表
    function XSocialManager.GetFriendsInfo(cb)
        cb = cb or function()
        end
        local ids = {}
        for key, value in pairs(FriendMap) do
            table.insert(ids, key)
        end
        local func = function(list)
            if not list then
                cb()
                return
            end

            for i, playerInfo in ipairs(list) do
                local friend = FriendMap[playerInfo.Id]
                if friend then
                    friend:Update(playerInfo)
                end
            end
            cb()
        end
        XSocialManager.GetPlayerInfoList(ids, func)
    end

    --更新好友申请列表
    function XSocialManager.GetApplyFriendsInfo(cb)
        cb = cb or function()
        end
        local ids = {}
        for key, value in pairs(WaitPassMap) do
            table.insert(ids, key)
        end
        local func = function(list)
            if not list then
                cb()
                return
            end

            for i, playerInfo in ipairs(list) do
                local applyData = WaitPassMap[playerInfo.Id]
                if applyData then
                    applyData:Update(playerInfo)
                end
            end
            cb()
        end
        XSocialManager.GetPlayerInfoList(ids, func)
    end


    --------------------------------社交系统相关角色数据缓存 beg--------------------------------
    function XSocialManager.GetPlayerCache(playerId)
        if not playerId then
            return
        end

        local playerCache = SocialPlayerCache[playerId]
        if not playerCache then
            return
        end

        if not playerCache.UpdateTime or XTime.Now() - playerCache.UpdateTime > SocialDataTimeInterval then
            return
        end

        return playerCache
    end

    function XSocialManager.UpdateSinglePlayerCache(playerId, playerInfo)

        SocialPlayerCache[playerId] = SocialPlayerCache[playerId] or {}

        local friend = SocialPlayerCache[playerId]

        friend.NickName = playerInfo.BaseInfo.Name
        friend.Level = playerInfo.BaseInfo.Level
        friend.CurrHeadPortraitId = playerInfo.BaseInfo.CurrHeadPortraitId
    end


    function XSocialManager.UpdatePlayerCache(playerInfoList)
        for _, playerData in pairs(playerInfoList) do
            SocialPlayerCache[playerData.Id] = playerData
            SocialPlayerCache[playerData.Id].UpdateTime = XTime.Now()
        end
    end

    --------------------------------社交系统相关角色数据缓存 end--------------------------------

    --搜索好友
    function XSocialManager.SearchPlayer(id, cb)
        if not id then
            return
        end

        local playerCache = XSocialManager.GetPlayerCache(id)
        if playerCache then
            local friend = XFriend.New(0, 0, 0)
            friend:Update(playerCache)
            if cb then
                cb(friend)
            end
            return
        end

        XSocialManager.SearchPlayerByServer(id, function (playerInfo)
            XSocialManager.UpdatePlayerCache({playerInfo})
            if cb then
                local friend = XFriend.New(0, 0, 0)
                friend:Update(playerInfo)
                cb(friend)
            end
        end)
    end

    function XSocialManager.SearchPlayerByServer(id, cb)
        XNetwork.Call(METHOD_NAME.GetSpecifyPlayer, {Id = id}, function(response)
            if response.Code ~= XCode.Success then
                XUiManager.TipCode(response.Code)
                return
            end

            if cb then
                cb(response.PlayerInfo)
            end
        end)
    end


    function XSocialManager.GetPlayerInfoList(idList, cb)
        if not idList or #idList <= 0 then
            if cb then
                cb()
            end
            return
        end

        local needRequestList = {}
        local playerCacheList = {}
        for _, id in pairs(idList) do
            local playerCache = XSocialManager.GetPlayerCache(id)
            if playerCache then
                table.insert(playerCacheList, playerCache)
            else
                table.insert(needRequestList, id)
            end
        end

        if #needRequestList <= 0 then
            if cb then
                cb(playerCacheList)
            end
            return
        end

        XSocialManager.GetPlayerInfoListByServer(needRequestList, function (playerInfoList)
            XSocialManager.UpdatePlayerCache(playerInfoList)
            for _, v in pairs(playerInfoList) do
                table.insert(playerCacheList, v)
            end

            if cb then
                cb(playerCacheList)
            end
        end)
    end

    --根据id数组获取好友列表
    function XSocialManager.GetPlayerInfoListByServer(idList, cb)
        XNetwork.Call(METHOD_NAME.GetPlayerInfoList, {Ids = idList}, function(response)
            if response.Code ~= XCode.Success then
                XUiManager.TipCode(response.Code)
                return
            end

            if cb then
                cb(response.PlayerInfoList or {})
            end
        end)
    end

    --同意或者拒绝添加好友
    function XSocialManager.AcceptApplyFriend(friendId, isAgreed, cb)
        friendId = friendId or 0
        isAgreed = isAgreed or false
        cb = cb or function()
        end
        local request = {TargetPlayerId = friendId,IsAccept = isAgreed}
        XNetwork.Call(METHOD_NAME.OperationFriendReq, request , function(response)
            WaitPassMap[friendId] = nil
            XSocialManager.ResetWaitPassLocalMap()
            if response.Code ~= XCode.Success then
                XUiManager.TipCode(response.Code)
                cb()
                return
            end
            if isAgreed then
                XSocialManager.SearchPlayer(friendId, function (friendData)
                    XSocialManager.AddFriend(friendData)
                end)
                XUiManager.TipText("FriendAgree")
            else
                XUiManager.TipText("FriendRefuse")
            end
            cb()
        end)
    end

    --删除好友
    function XSocialManager.DeleteFriends(friendIds, cb)
        friendIds = friendIds or {}
        cb = cb or function()
        end
        if #friendIds <= 0 then
            cb()
            return
        end

        local playerIds = {}
        for _, id in ipairs(friendIds) do
            table.insert(playerIds,id)
        end

        local request = {Ids = playerIds}
        XNetwork.Call(METHOD_NAME.DeleteFriends, request, function(response)
            XUiManager.TipCode(response.Code)
            if response.Code ~= XCode.FriendManagerDeleteSuccess then
                return
            end
            for _, id in ipairs(friendIds) do
                XSocialManager.DelFriend(id)
                XDataCenter.ChatManager.ClearFriendChatContent(id)
            end
            XEventManager.DispatchEvent(XEventId.EVENT_FRIEND_DELETE,id)
            cb()
        end)
    end

    function XSocialManager.NotifyFriendExp(notify)
        local player = SocialPlayerCache[notify.FriendId]
        if not player then
            return
        end

        player.FriendExp = notify.Exp
    end
    ----------------------End Net-----------------------

    function XSocialManager.GetFriendExp(playerId)
        if not playerId then
            return 0
        end

        local friend = FriendMap[playerId]
        if not friend then
            return 0
        end

        return friend.FriendExp
    end

    function XSocialManager.GetFriendExpLevel(playerId)
        local curExp = XSocialManager.GetFriendExp(playerId)
        for level, v in ipairs(FetterLevelTemplates) do
            if curExp < v.Exp then
                return level, v.Exp - curExp
            end
        end

        return 1, 0
    end

    function XSocialManager.GetFetterTableDataByLevel(level)
        return FetterLevelTemplates[level]
    end

    function XSocialManager.ResetApplyCount()
        ApplyCount = 0
        XEventManager.DispatchEvent(XEventId.EVENT_FRIEND_WAITING_PASS)
    end
    ---------------------------------------------

    function XSocialManager.NotifyAddFriend(friend)
        XSocialManager.SearchPlayer(friend.FriendId, function (friendData)
            FriendMap[friend.FriendId] = friendData
            if WaitPassMap[friend.FriendId] then
                WaitPassMap[friend.FriendId] = nil
            end
        end)
    end

    XSocialManager.Init()
    return XSocialManager
end

--当在线被人申请的时候,增加等待通过数据
XRpc.NotifyAddApply = function(notifyData)
    XDataCenter.SocialManager.AddWaitPassFriend(XFriend.New(notifyData.ApplyId, notifyData.CreateTime))
end

--当在线添加 好友成功之后
XRpc.NotifyAddFriend = function(notifyData)
    local friend = XFriend.New(notifyData.PlayerId, notifyData.CreateTime, notifyData.Exp)
    XDataCenter.SocialManager.NotifyAddFriend(friend)
end

--当在线被人拒绝的时候
XRpc.NotifyRefuseApply = function(notifyData)

end

--当在线被人删除的时候
XRpc.NotifyDeleteFriend = function(notifyData)
    XDataCenter.SocialManager.DelFriend(notifyData.PlayerId)
end

--登陆返回基础好友数据
XRpc.NotifySocialData = function(notifyData)
    XDataCenter.SocialManager.InitSocialData(notifyData)
end

-- 羁绊等级改变
XRpc.NotifyFriendExp = function(notifyData)
    XDataCenter.SocialManager.NotifyFriendExp(notifyData)
end