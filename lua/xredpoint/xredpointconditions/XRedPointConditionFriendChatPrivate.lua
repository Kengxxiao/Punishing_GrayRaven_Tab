----------------------------------------------------------------
--好友联系红点检测
local XRedPointConditionFriendChatPrivate = {}
local Events = nil
function XRedPointConditionFriendChatPrivate.GetSubEvents()
    Events = Events or
    { 
        XRedPointEventElement.New(XEventId.EVENT_CHAT_RECEIVE_PRIVATECHAT),
        XRedPointEventElement.New(XEventId.EVENT_CHAT_MSG_SYNC),
    }
    return Events
end

function XRedPointConditionFriendChatPrivate.Check(friendId)
    if not friendId then
        return false
    end

    return XDataCenter.ChatManager.GetPrivateUnreadChatCountByFriendId(friendId)
end

return XRedPointConditionFriendChatPrivate  