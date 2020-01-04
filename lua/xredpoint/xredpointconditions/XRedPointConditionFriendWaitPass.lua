----------------------------------------------------------------
--角色晋升红点检测
local XRedPointConditionFriendWaitPass = {}
local Events = nil
function XRedPointConditionFriendWaitPass.GetSubEvents()
    Events = Events or
    { 
        XRedPointEventElement.New(XEventId.EVENT_FRIEND_WAITING_PASS),
    }
    return Events
end

function XRedPointConditionFriendWaitPass.Check()
    return XDataCenter.SocialManager.HasFriendApplyWaitPass()
end

return XRedPointConditionFriendWaitPass  