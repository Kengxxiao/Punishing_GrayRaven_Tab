----------------------------------------------------------------
--好友联系红点检测
local XRedPointConditionFriendContact = {}
local Events = nil
function XRedPointConditionFriendContact.GetSubEvents()
    Events = Events or
    { 
        XRedPointEventElement.New(XEventId.EVENT_FRIEND_READ_PRIVATE_MSG),
        XRedPointEventElement.New(XEventId.EVENT_FRIEND_DELETE),
        XRedPointEventElement.New(XEventId.EVENT_CHAT_RECEIVE_PRIVATECHAT),
    }
    return Events
end

function XRedPointConditionFriendContact.Check()
    return XDataCenter.ChatManager.GetAllPrivateChatMsgCount()
end

return XRedPointConditionFriendContact  