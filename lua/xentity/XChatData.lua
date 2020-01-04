--从服务器接收的格式
XChatData = XClass()

local Default = {
    MessageId = 0,
    ChannelType = 0,
    MsgType = 0,
    SenderId = 0,
    Icon = 0,
    NickName = "",
    TargetId = 0,
    CreateTime = 0,
    Content = 0,
    GiftId = 0,
    GiftCount = 0,
    GiftStatus = 0,
    IsRead = false,
    CurrMedalId = 0,
}

function XChatData:Ctor(chatData)
    for key in pairs(Default) do
        self[key] = Default[key]
    end

    if chatData == nil then
        return
    end

    self.MessageId = chatData.MessageId
    self.ChannelType = chatData.ChannelType
    self.MsgType = chatData.MsgType
    self.SenderId = chatData.SenderId
    self.Icon = chatData.Icon
    self.NickName = chatData.NickName
    self.TargetId = chatData.TargetId
    self.CreateTime = chatData.CreateTime
    self.Content = chatData.Content
    self.GiftId = chatData.GiftId
    self.GiftCount = chatData.GiftCount
    self.GiftStatus = chatData.GiftStatus
    self.CurrMedalId = chatData.CurrMedalId
    self.CustomContent = chatData.CustomContent
    self.IsRead = false
end

function XChatData:GetSendTime()
    local curTime = os.date("%Y/%m/%d", XTime.Now())
    local sendTime = os.date("%Y/%m/%d", self.CreateTime)
    local time1 = os.date("%H:%M:%S", self.CreateTime)
    local time = curTime == sendTime and time1 or sendTime .. '    ' .. time1
   return time1
end

--检测是否自己发送的
function XChatData:CheckIsSelfChat()
    return self.SenderId == XPlayer.Id
end

function XChatData:GetChatTargetId()--获取聊天对象的id
    if (self:CheckIsSelfChat()) then
        return self.TargetId
    else
        return self.SenderId
    end
end

--该礼物消息属于送礼还是收礼
function XChatData:GetGiftChatType()
    if self.CreateTime == self.GiftCreateTime then
        return GiftChatType.Send
    else
        return GiftChatType.Receive
    end
end

--是否有自己可领取的礼物
function XChatData:CheckHaveGift()
    if (not self:CheckIsSelfChat() and
        self.MsgType == ChatMsgType.Gift and 
        self.GiftStatus == ChatGiftState.WaitReceive) then
        return true
    else
        return false
    end
end

--发送或者接收的消息的类型
ChatChannelType = 
{
    System = 1, --系统
    World = 2, --世界
    Private = 3, --私聊
    Room = 4, --房间
    Battle = 5, --战斗
}

ChatMsgType = 
{
    Normal = 1,--普通消息
    Emoji = 2,--表情消息
    Gift = 3,--礼物消息
    Tips = 4,--提示消息
}

PrivateChatPrefabType = 
{
    SelfChatBox = 1,
    SelfChatEmojiBox = 2,
    OtherChatBox = 3,
    OtherChatEmojiBox = 4,
    SelfGiftBox = 5,
    OtherGiftBox = 6
}

ChatGiftState =
{
    None = 0,
    WaitReceive = 1,--等待接收状态
    Received = 2,--已领取
    Fetched = 3,--不能领取
}

GiftChatType =
{
    Send = 1,
    Receive = 2,
}