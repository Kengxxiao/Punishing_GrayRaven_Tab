
----------------------------------------------------------------
--角色入口红点检测
local XRedPointConditionMainDispatch = {}
local Events = nil

function XRedPointConditionMainDispatch.Check()
   return XDataCenter.TaskForceManager.CheckTaskForceCompleted()
end

function XRedPointConditionMainDispatch.GetSubEvents()
    Events = Events or
    { 
        XRedPointEventElement.New(XEventId.EVENT_TASKFORCE_TASKFINISH_REQUEST),
        XRedPointEventElement.New(XEventId.EVENT_TASKFORCE_COMPLETE_NOTIFY),
        XRedPointEventElement.New(XEventId.EVENT_TASKFORCE_ACCEPT_REWARD_REQUEST),

    }
    return Events
end

return XRedPointConditionMainDispatch