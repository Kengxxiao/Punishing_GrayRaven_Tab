XChatManagerCreator = function()

    local XChatManager = {}

    local TABLE_EMOJI_CONFIG_PATH = "Client/Chat/Emoji.tab"

    local CLIENT_WORLD_CHAT_MAX_SIZE = 0
    local CLIENT_ROOM_CHAT_MAX_SIZE = 0
    local REMOVE_CHAT_RECORD_OF_DAY = 0
    local CHAT_INTERVAL_TIME = 0
    local TODAY_RESET_TIME = 0
    local WORLD_CHAT_MAX_COUNT = 0
    -- 一天的秒数
    local ONE_DAY_SECONDS = 60 * 60 * 24

    local EmojiTemplates = {}

    local WorldChatList = {}    --保存世界聊天记录
    local PrivateChatMap = {}   --保存私聊的聊天纪录
    local ClanChatList = {}     --保存公会聊天纪录
    local SystemChatList = {}   --保存系统消息纪录
    local RoomChatList = {}     --保存房间聊天记录
    local LastChatCoolTime = 0

    local MessageId = -1        --离线消息
    local OfflineMessageTag = "OfflineRecordMessage_"

    local LastRequestChannelTime = 0
    local CurrentChatChannelId = 0
    local ChatChannelInfos

    local IsWorldChatInit = false
    
    local NotAllowedStr = ""

    --协议处理
    local MethodName = {
        SendChat = "SendChatRequest",
        GetGift = "GetGiftsRequest",
        GetAllGiftsRequest = "GetAllGiftsRequest",
        GetOfflineMessageRequest = "OfflineMessageRequest",
        SelectChatChannelRequest = "SelectChatChannelRequest",
        EnterWorldChatRequest = "EnterWorldChatRequest",
        GetWorldChannelInfoRequest = "GetWorldChannelInfoRequest",
    }

    function XChatManager.Init()
        REMOVE_CHAT_RECORD_OF_DAY = CS.XGame.ClientConfig:GetInt("RemoveChatRecordOfDay")
        CLIENT_WORLD_CHAT_MAX_SIZE = CS.XGame.ClientConfig:GetInt("WorldChatMaxSize")
        CLIENT_ROOM_CHAT_MAX_SIZE = CS.XGame.ClientConfig:GetInt("RoomChatMaxSize")
        CHAT_INTERVAL_TIME = CS.XGame.Config:GetInt("ChatIntervalTime")
        WORLD_CHAT_MAX_COUNT = CS.XGame.Config:GetInt("WorldChatMaxCount")
        EmojiTemplates = XTableManager.ReadByIntKey(TABLE_EMOJI_CONFIG_PATH, XTable.XTableEmoji, "Id")
        NotAllowedStr = CS.XTextManager.GetText("ChatNotAllowed")
        XEventManager.AddEventListener(XEventId.EVENT_ROOM_LEAVE_ROOM, function()
            RoomChatList = {}
        end)

        XEventManager.AddEventListener(XEventId.EVENT_LOGIN_DATA_LOAD_COMPLETE, function()
            XChatManager.InitChatChannel()
        end)

    end

    function XChatManager.GetLastRequestChannelTime()
        return LastRequestChannelTime
    end

    function XChatManager.SetLastRequestChannelTime(time)
        LastRequestChannelTime = time
    end

    function XChatManager.GetWorldChatMaxCount()
        return WORLD_CHAT_MAX_COUNT
    end

    -- 初始化世界聊天数据
    function XChatManager.InitWorldChatData(worldChatDataList)
        WorldChatList = {}
        local WorldChatLoop = function(item)
            if item ~= nil then
                XChatManager.ProcessExtraContent(item)
                table.insert(WorldChatList, 1, item)
            end
        end
        XTool.LoopCollection(worldChatDataList, WorldChatLoop)
        IsWorldChatInit = true
    end

    --加载私聊信息
    function XChatManager.InitFriendPrivateChatData()
        PrivateChatMap = {}
        local cb = function()
            for _, friendId in pairs(XDataCenter.SocialManager.GetFriendIds()) do
                XChatManager.ReadSpecifyFriendsChatContent(friendId)
            end
            XChatManager.GetOfflineMessageRequest(XChatManager.GetLocalOfflineRecord())
        end
        XDataCenter.SocialManager.GetFriendsInfo(cb)
    end

    --处理系统消息
    local function HandleSystemChat(chatData)
        --TODO Handle System Chat
    end

    --处理世界消息
    local function HandleWorldChat(chatData, isNotify)
        if #WorldChatList >= CLIENT_WORLD_CHAT_MAX_SIZE then
            table.remove(WorldChatList, #WorldChatList)
        end
        table.insert(WorldChatList, 1, chatData)

        if isNotify then
            XEventManager.DispatchEvent(XEventId.EVENT_CHAT_RECEIVE_WORLD_MSG, chatData)
            CsXGameEventManager.Instance:Notify(XEventId.EVENT_CHAT_RECEIVE_WORLD_MSG, chatData)
        end
    end

    --处理私聊消息
    local function HandlePrivateChat(chatData, ignoreNotify)
        if (not chatData) then
            return
        end
        if chatData.SenderId == XPlayer.Id or
            chatData.MsgType == ChatMsgType.Gift or
            chatData.MsgType == ChatMsgType.Tips then
            chatData.IsRead = true
        end
        if chatData.SenderId ~= XPlayer.Id then
            XChatManager.UpdateLocalOfflineRecord(chatData.MessageId or 0)
        end
        local targetId = chatData:GetChatTargetId()

        XChatManager.AddPrivateChatData(targetId, chatData, false, ignoreNotify)

        --保存消息
        XChatManager.SaveSpecifyFriendsChatContent(targetId)
    end

    --处理房间消息
    local function HandleRoomChat(chatData)
        if #RoomChatList >= CLIENT_ROOM_CHAT_MAX_SIZE then
            table.remove(RoomChatList, 1)
        end
        table.insert(RoomChatList, chatData)
        XEventManager.DispatchEvent(XEventId.EVENT_CHAT_RECEIVE_ROOM_MSG, chatData)
        CsXGameEventManager.Instance:Notify(XEventId.EVENT_CHAT_RECEIVE_ROOM_MSG, chatData)
    end

    function XChatManager.OnSynChat(chatMsg, ignoreNotify)
        local chatData = XChatData.New(chatMsg)
        if chatMsg.ChannelType == ChatChannelType.System then
            HandleSystemChat(chatData)
        elseif chatMsg.ChannelType == ChatChannelType.World then
            HandleWorldChat(chatData, true)
        elseif chatMsg.ChannelType == ChatChannelType.Private then
            HandlePrivateChat(chatData, ignoreNotify)
        elseif chatMsg.ChannelType == ChatChannelType.Room then
            HandleRoomChat(chatData)
        end

        --接收到礼物时增加一条tip提示
        if chatMsg.MsgType == ChatMsgType.Gift then
            chatMsg.MsgType = ChatMsgType.Tips
            chatMsg.CreateTime = chatMsg.CreateTime
            chatMsg.GiftId = chatMsg.GiftId
            XChatManager.OnSynChat(chatMsg)
        end
    end



    ---------------------------------public function-----------------------------------
    function XChatManager.GetRemoveChatRecordOfDays()
        return REMOVE_CHAT_RECORD_OF_DAY
    end

    function XChatManager.GetWorldChatMaxSize()
        return CLIENT_WORLD_CHAT_MAX_SIZE
    end

    --=== Emoji ===
    function XChatManager.GetEmojiIcon(emojiId)
        emojiId = tonumber(emojiId)
        emojiId = emojiId or 0
        local cfg = EmojiTemplates[emojiId]
        if cfg == nil then
            return nil
        end
        return cfg.Path
    end

    function XChatManager.GetEmojiTemplates()
        return EmojiTemplates
    end

    --=== World Chat ===
    function XChatManager.GetWorldChatList()
        return WorldChatList
    end

    --=== Room Chat ===
    function XChatManager.GetRoomChatList()
        table.sort(RoomChatList, function(a, b)
            if a.CreateTime ~= b.CreateTime then
                return a.CreateTime > b.CreateTime
            end
        end)
        return RoomChatList
    end

    --=== Private Chat ===
    -- 获取私聊聊天数据
    function XChatManager.GetPrivateDynamicList(friendId)
        local msgData = XChatManager.GetPrivateChatsByFriendId(friendId)
        local sortFunc = function(a, b)
            if a.CreateTime ~= b.CreateTime then
                return a.CreateTime > b.CreateTime
            else
                if a.MsgType == ChatMsgType.Tips then
                    if b.MsgType == ChatMsgType.Tips then
                        return a.GiftStatus > b.GiftStatus
                    end
                    return true
                end
            end
        end
        table.sort(msgData, sortFunc)
        return msgData
    end

    -- 获取私聊好友id列表
    function XChatManager.GetPrivateChatGroupData(nowID)
        --初始化数据
        local chatFriendIdList = XChatManager.GetHaveChatDataFriendIds()
        local targetInList = false
        for i, id in ipairs(chatFriendIdList) do
            if id == nowID then
                targetInList = true
                break
            end
        end
        if not targetInList then
            table.insert(chatFriendIdList, 1, nowID)
        end

        local dynamicListData = {}
        for i, v in ipairs(chatFriendIdList) do
            local friendInfo = XDataCenter.SocialManager.GetFriendInfo(v)
            table.insert(dynamicListData, friendInfo)
        end
        return dynamicListData
    end


    --新增私聊消息
    function XChatManager.AddPrivateChatData(friendId, chatData, isInit, ignoreNotify)
        --好友聊天数据结构
        local friendChats = PrivateChatMap[friendId]
        if not friendChats then
            friendChats = {}
            friendChats.ChatMap = {}
            friendChats.LastChat = nil
            PrivateChatMap[friendId] = friendChats
        end

        friendChats.LastChat = chatData

        friendChats.ChatMap = friendChats.ChatMap or {}
        table.insert(friendChats.ChatMap, chatData)

        if not isInit or not chatData.IsRead then
            if not ignoreNotify then
                XEventManager.DispatchEvent(XEventId.EVENT_CHAT_RECEIVE_PRIVATECHAT, chatData)
            end
        end
    end

    --获取已聊天过的好友id列表
    function XChatManager.GetHaveChatDataFriendIds()
        local list = {}

        for friendId, chatInfo in pairs(PrivateChatMap) do
            if chatInfo and chatInfo.ChatMap then
                for _, chat in pairs(chatInfo.ChatMap) do
                    table.insert(list, friendId)
                    break
                end
            end
        end

        if #list >= 2 then
            local sortByCreateTime = function(l, r)
                local lchat = XChatManager.GetLastPrivateChatByFriendId(l)
                local rchat = XChatManager.GetLastPrivateChatByFriendId(r)
                if lchat.CreateTime > rchat.CreateTime then
                    return true
                else
                    return false
                end
            end
            table.sort(list, sortByCreateTime)
        end

        return list
    end

    --更新礼物信息
    function XChatManager.UpdateGiftData(friendId, giftId, status, giftCount)
        local friendChats = PrivateChatMap[friendId]
        if not friendChats or not friendChats.ChatMap then
            return
        end

        for k, v in pairs(friendChats.ChatMap) do
            if (v.MsgType == ChatMsgType.Gift or v.MsgType == ChatMsgType.Tips) and v.GiftId == giftId and v.SenderId == friendId then
                friendChats.LastChat = v
                v.GiftStatus = status
                if giftCount and giftCount > 0 then
                    v.GiftCount = giftCount
                end
            end
        end
        --保存消息
        XChatManager.SaveSpecifyFriendsChatContent(friendId)
    end

    --获取指定好友聊天列表
    function XChatManager.GetPrivateChatsByFriendId(friendId)
        local list = {}
        if (PrivateChatMap[friendId] and PrivateChatMap[friendId].ChatMap) then
            for _, chat in pairs(PrivateChatMap[friendId].ChatMap) do
                table.insert(list, chat)
            end
        end
        return list
    end

    --获取好友最后一条聊天
    function XChatManager.GetLastPrivateChatByFriendId(friendId)
        local lastChat = nil
        local info = PrivateChatMap[friendId]
        if (info) then
            lastChat = info.LastChat
        end
        return lastChat
    end

    --获取好友未读聊天数量
    function XChatManager.GetPrivateUnreadChatCountByFriendId(friendId)
        local count = 0
        local info = PrivateChatMap[friendId]
        if (info and info.ChatMap) then
            for _, chat in pairs(info.ChatMap) do
                if (not chat.IsRead) then
                    count = count + 1
                end
            end
        end
        return count
    end

    --设置指定好友全部聊天为已读
    function XChatManager.SetPrivateChatReadByFriendId(friendId)
        local friendChat = PrivateChatMap[friendId]
        local count = 0
        if friendChat and friendChat.ChatMap then
            for _, chat in pairs(friendChat.ChatMap) do
                if not chat.IsRead then
                    chat.IsRead = true
                    count = count + 1
                end
            end
        end

        --保存消息
        XChatManager.SaveSpecifyFriendsChatContent(friendId)

        if count > 0 then
            XEventManager.DispatchEvent(XEventId.EVENT_FRIEND_READ_PRIVATE_MSG)
        end
    end

    --检测好友是否有自己可以领取的礼物
    function XChatManager.CheckDoesHaveGiftByFriendId(friendId)
        local friendChats = PrivateChatMap[friendId]
        if not friendChats or not friendChats.ChatMap then
            return false
        end
        for k, v in pairs(friendChats.ChatMap) do
            if v:CheckHaveGift() then
                return true
            end
        end

        return false
    end

    ---------------------------------Chat Record-----------------------------------
    local ChatRecordTag = "ChatRecord_%d_%d"  --标识 + 好友id + 自己id

    --读取指定好友的聊天内容
    function XChatManager.ReadSpecifyFriendsChatContent(friendId)
        local key = string.format(ChatRecordTag, friendId, XPlayer.Id)
        if CS.UnityEngine.PlayerPrefs.HasKey(key) then
            local chatRecord = CS.UnityEngine.PlayerPrefs.GetString(key)
            local msgTab = string.Split(chatRecord, '\n')
            if msgTab ~= nil and #msgTab > 0 then
                for index = 1, #msgTab do
                    local content = msgTab[index]
                    if (not string.IsNilOrEmpty(content)) then
                        local tab = string.Split(content, '\t')
                        if tab ~= nil then
                            if XChatManager.CheckIsRemove(tonumber(tab[3])) then
                                local chatData = XChatData.New()
                                chatData.ChannelType = ChatChannelType.Private

                                chatData.SenderId = tonumber(tab[1])
                                chatData.TargetId = tonumber(tab[2])
                                chatData.CreateTime = tonumber(tab[3])
                                chatData.Content = tab[4]
                                chatData.MsgType = tonumber(tab[5])
                                chatData.GiftId = tonumber(tab[6])
                                chatData.GiftCount = tonumber(tab[7])
                                chatData.GiftStatus = tonumber(tab[8])
                                chatData.IsRead = tonumber(tab[9]) == 1
                                chatData.CustomContent = tab[10]

                                if XPlayer.Id == chatData.SenderId then
                                    chatData.Icon = XPlayer.CurrHeadPortraitId
                                    chatData.NickName = XPlayer.Name
                                else
                                    local friendInfo = XDataCenter.SocialManager.GetFriendInfo(friendId)
                                    if friendInfo then
                                        chatData.Icon = friendInfo.Icon
                                        chatData.NickName = friendInfo.NickName
                                    end
                                end
                                XChatManager.ProcessExtraContent(chatData)
                                XChatManager.AddPrivateChatData(friendId, chatData, true)
                            end
                        end
                    end
                end
            end
        end
    end

    --检测该消息是否是七天前的
    function XChatManager.CheckIsRemove(time)
        if time == nil then
            return false
        end
        local curTime = XTime.GetServerNowTimestamp()
        return curTime - time <= REMOVE_CHAT_RECORD_OF_DAY * 24 * 60 * 60
    end

    --存储指定好友的聊天内容
    function XChatManager.SaveSpecifyFriendsChatContent(friendId)
        local chatList = XChatManager.GetPrivateDynamicList(friendId)
        if chatList == nil or #chatList == 0 then
            return
        end
        local saveContent = ''
        for index = 1, #chatList do
            local chat = chatList[index]
            if chat ~= nil and type(chat) == 'table' then
                saveContent = saveContent .. chat.SenderId .. '\t'
                saveContent = saveContent .. chat.TargetId .. '\t'
                saveContent = saveContent .. chat.CreateTime .. '\t'
                saveContent = saveContent .. chat.Content .. '\t'
                saveContent = saveContent .. chat.MsgType .. "\t"
                saveContent = saveContent .. tostring(chat.GiftId) .. "\t"
                saveContent = saveContent .. tostring(chat.GiftCount) .. "\t"
                saveContent = saveContent .. tostring(chat.GiftStatus) .. "\t"
                saveContent = saveContent .. (chat.IsRead and "1" or "0") .. "\t"
                saveContent = saveContent .. (chat.CustomContent or "") .. "\n"
            end
        end
        if saveContent ~= nil and saveContent ~= '' then
            local key = string.format(ChatRecordTag, friendId, XPlayer.Id)
            CS.UnityEngine.PlayerPrefs.SetString(key, saveContent)
            CS.UnityEngine.PlayerPrefs.Save()
        end
    end

    --清除指定好友的聊天内容
    function XChatManager.ClearFriendChatContent(friendId)
        local key = string.format(ChatRecordTag, friendId, XPlayer.Id)
        PrivateChatMap[friendId] = nil
        if CS.UnityEngine.PlayerPrefs.HasKey(key) then
            CS.UnityEngine.PlayerPrefs.DeleteKey(key)
            CS.UnityEngine.PlayerPrefs.Save()
        end
    end

    --获取所有私聊信息
    function XChatManager.GetAllPrivateChatMsgCount()

        if not PrivateChatMap then
            return 0
        end
        local count = 0
        for k, v in pairs(PrivateChatMap) do
            local info = v
            if (info and info.ChatMap) then
                for _, chat in pairs(info.ChatMap) do
                    if (not chat.IsRead) then
                        count = count + 1
                    end
                end
            end
        end
        return count
    end

    function XChatManager.CheckCd()
        if LastChatCoolTime > 0 and LastChatCoolTime + CHAT_INTERVAL_TIME > XTime.GetServerNowTimestamp() then
            XUiManager.TipCode(XCode.ChatManagerRefreshTimeCooling)
            return false
        end

        return true
    end

    --发送聊天
    function XChatManager.SendChat(chatData, cb, needReplace)
        XNetwork.Call(MethodName.SendChat, { ChatData = chatData, TargetIdList = chatData.TargetIds }, function(response)
            LastChatCoolTime = response.RefreshTime
            if response.Code ~= XCode.Success then
                XUiManager.TipCode(response.Code)

                if chatData.ChannelType  == ChatChannelType.World then
                    if cb then
                        cb(CHAT_INTERVAL_TIME + LastChatCoolTime - XTime.GetServerNowTimestamp(), response.ChatData)
                    end
                end
                return
            end

            if cb then
                cb(CHAT_INTERVAL_TIME + LastChatCoolTime - XTime.GetServerNowTimestamp(), response.ChatData)
            end
        end)
    end

    --收取单个礼物
    function XChatManager.GetGift(giftId, callback)
        callback = callback or function() end

        XNetwork.Call(MethodName.GetGift, { GiftId = giftId or 0 }, function(response)
            if response.Code ~= XCode.Success then
                XUiManager.TipCode(response.Code)
                return
            end
            callback(response.RewardGoodsList)
        end)
    end

    --群收礼物
    function XChatManager.GetAllGiftsRequest(callback)
        if not XChatManager.CheckHasGift() then
            XUiManager.TipCode(XCode.ChatManagerGetGiftNotGift)
            return
        end
        XNetwork.Call(MethodName.GetAllGiftsRequest, nil, function(response)
            if response.Code ~= XCode.Success then
                XUiManager.TipCode(response.Code)
                return
            end
            if #response.RewardGoodsList <= 0 then
                XUiManager.TipCode(XCode.ChatManagerGetGiftNotGift)
                return
            end
            if callback then
                callback(response.GiftInfoList, response.RewardGoodsList)
            end
        end)
    end

    -- 离线消息
    function XChatManager.GetOfflineMessageRequest(msgId, cb)
        cb = cb or function() end

        XNetwork.Call(MethodName.GetOfflineMessageRequest, {MessageId = msgId}, function(response)
            if response.Code ~= XCode.Success then
                XUiManager.TipCode(response.Code)
                return
            end
            -- 处理离线的消息
            XChatManager.NotifyOfflineMessage(response.Messages)
            cb()
        end)
    end

    function XChatManager.NotifyOfflineMessage(offlineMessages)
        if not offlineMessages then return end

        local isIgnoreNotify = true
        local lastChatData = nil
        for _, chatData in pairs(offlineMessages) do
            XChatManager.ProcessExtraContent(chatData)
            XChatManager.OnSynChat(chatData, true)
            lastChatData = XChatData.New(chatData)
        end

        -- 只在最后检查一次红点
        if lastChatData then
            XEventManager.DispatchEvent(XEventId.EVENT_CHAT_RECEIVE_PRIVATECHAT, lastChatData)
        end
    end

    function XChatManager.UpdateLocalOfflineRecord(messageId)
        if messageId > MessageId then
            MessageId = messageId
            local key = string.format( "%s%s", OfflineMessageTag, tostring(XPlayer.Id))
            CS.UnityEngine.PlayerPrefs.SetInt(key, MessageId)
            CS.UnityEngine.PlayerPrefs.Save()
        end
        
    end

    function XChatManager.GetLocalOfflineRecord()
        local key = string.format( "%s%s", OfflineMessageTag, tostring(XPlayer.Id))
        if CS.UnityEngine.PlayerPrefs.HasKey(key) then
            MessageId = CS.UnityEngine.PlayerPrefs.GetInt(key, MessageId)
        end
        return MessageId
    end

    -- 【聊天分频道】
    function XChatManager.GetCurrentChatChannelId()
        return CurrentChatChannelId
    end

    -- 切换聊天频道
    function XChatManager.SelectChatChannel(channelId, succeedcb, failedcb)
        succeedcb = succeedcb or function() end
        failedcb = failedcb or function() end

        if channelId == CurrentChatChannelId then return end

        XNetwork.Call(MethodName.SelectChatChannelRequest, {ChannelId = channelId-1}, function(response)
            if response.Code ~= XCode.Success then
                XUiManager.TipCode(response.Code)
                failedcb()
                return
            end
            CurrentChatChannelId = channelId
            CsXGameEventManager.Instance:Notify(XEventId.EVENT_CHAT_CHANNEL_CHANGED)
            succeedcb()
        end)
    end

    -- 登录初始化聊天频道
    function XChatManager.InitChatChannel()
        XNetwork.Call(MethodName.EnterWorldChatRequest, {}, function(response)
            if response.Code ~= XCode.Success then
                XUiManager.TipCode(response.Code)
                return
            end
            CurrentChatChannelId = response.ChannelId + 1
            CsXGameEventManager.Instance:Notify(XEventId.EVENT_CHAT_CHANNEL_CHANGED)
        end)
    end

    -- 获取频道消息
    function XChatManager.GetWorldChannelInfos(cb)
        cb = cb or function() end

        XNetwork.Call(MethodName.GetWorldChannelInfoRequest, {}, function(response)
            if response.Code ~= XCode.Success then
                XUiManager.TipCode(response.Code)
                return
            end

            ChatChannelInfos = response.ChannelInfos
            for _, v in pairs(ChatChannelInfos) do
                v.ChannelId = v.ChannelId + 1
            end

            cb(ChatChannelInfos)
        end)
    end

    function XChatManager.GetAllChannelInfos()
        return ChatChannelInfos
    end

    function XChatManager.OnChatChannelChanged(notifyData)
        if not notifyData then return end
        local notifyChannelId = notifyData.ChannelId + 1
        if CurrentChatChannelId ~= notifyChannelId then
            CurrentChatChannelId = notifyChannelId
            CsXGameEventManager.Instance:Notify(XEventId.EVENT_CHAT_SERVER_CHANNEL_CHANGED, notifyChannelId)
        end
    end

    function XChatManager.UpdateGiftResetTime(resetTime)
        TODAY_RESET_TIME = resetTime
    end

    function XChatManager.CheckHasGift()
        for friendId, chatInfo in pairs(PrivateChatMap) do
            for _, chat in pairs(chatInfo.ChatMap) do
                if chat.MsgType == ChatMsgType.Gift and chat.GiftStatus == ChatGiftState.WaitReceive and chat.SenderId ~= XPlayer.Id then
                    return true
                end
            end
        end

        return false
    end

    function XChatManager.UpdateGiftStatus()
        for friendId, chatInfo in pairs(PrivateChatMap) do
            for _, chat in pairs(chatInfo.ChatMap) do
                if TODAY_RESET_TIME > 0
                and chat.MsgType == ChatMsgType.Gift
                and chat.GiftStatus == ChatGiftState.WaitReceive
                and chat.CreateTime < (TODAY_RESET_TIME - ONE_DAY_SECONDS) then
                    chat.GiftStatus = ChatGiftState.Fetched
                end
            end
        end
    end

    -- 创建礼物文本
    function XChatManager.CreateGiftTips(chatData)
        if not chatData then
            return ""
        end

        -- 发礼物提示
        if chatData.GiftStatus == ChatGiftState.WaitReceive then
            if chatData.SenderId == XPlayer.Id then
                local friend = XDataCenter.SocialManager.GetFriendInfo(chatData.TargetId)
                if friend then
                    return CS.XTextManager.GetText("GiftMoneySendNotReceive", friend.NickName, chatData.GiftCount)
                end
            else
                return CS.XTextManager.GetText("GiftMoneyReceiveNotReceive", chatData.NickName, chatData.GiftCount)
            end
            -- 领礼物提示
        elseif chatData.GiftStatus == ChatGiftState.Received then
            -- 自己领礼物
            if chatData.SenderId ~= XPlayer.Id then
                local friend = XDataCenter.SocialManager.GetFriendInfo(chatData.SenderId)
                if friend then
                    return CS.XTextManager.GetText("GiftMoneyReceiveHaveReceive", friend.NickName, chatData.GiftCount)
                else
                    return CS.XTextManager.GetText("GiftMoneyReceiveHaveReceive", "", chatData.GiftCount)
                end
            else
                -- 别人领礼物
                local friend = XDataCenter.SocialManager.GetFriendInfo(chatData.TargetId)
                if friend then
                    return CS.XTextManager.GetText("GiftMoneySendHaveReceive", friend.NickName, chatData.GiftCount)
                end
            end
        end
        return ""
    end

    function XChatManager.ProcessExtraContent(chatData)
        if not chatData then
            return
        end

        local customContent = XMessagePack.Decode(chatData.CustomContent)
        if not customContent then
            return
        end

        if string.find(chatData.Content, "room") then
            chatData.Content = string.gsub(chatData.Content, "room", customContent)
        end
    end

    function XChatManager.NotifyChatMessage(chatData)
        XChatManager.ProcessExtraContent(chatData)
        XChatManager.OnSynChat(chatData)

        XEventManager.DispatchEvent(XEventId.EVENT_CHAT_MSG_SYNC)
    end

    function XChatManager.NotifyWorldChat(chatData)
        if not chatData or not chatData.ChatMessages then
            return
        end

        local lastChatMsg
        for i, chatMsg in ipairs(chatData.ChatMessages) do
            XChatManager.ProcessExtraContent(chatMsg)
            lastChatMsg = XChatData.New(chatMsg)
            HandleWorldChat(lastChatMsg)
        end

        if lastChatMsg then
            XEventManager.DispatchEvent(XEventId.EVENT_CHAT_RECEIVE_WORLD_MSG, lastChatMsg)
            CsXGameEventManager.Instance:Notify(XEventId.EVENT_CHAT_RECEIVE_WORLD_MSG, lastChatMsg)
        end
    end

    XChatManager.Init()
    return XChatManager
end

--同步聊天
XRpc.NotifyChatMessage = function(chatData)
    XDataCenter.ChatManager.NotifyChatMessage(chatData)
end

XRpc.NotifyTodayGiftResetTime = function(notifyData)
    XDataCenter.ChatManager.UpdateGiftResetTime(notifyData.ResetTime)
end

XRpc.NotifyWorldChat = function (chatData)
    XDataCenter.ChatManager.NotifyWorldChat(chatData)
end

-- 聊天频道切换
XRpc.NotifyChatChannelChange = function(notifyData)
    XDataCenter.ChatManager.OnChatChannelChanged(notifyData)
end