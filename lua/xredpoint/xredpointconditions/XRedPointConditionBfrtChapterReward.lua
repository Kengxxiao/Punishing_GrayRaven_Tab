----------------------------------------------------------------
--节红点检测
local XRedPointConditionBfrtChapterReward = {}

local Events = nil
function XRedPointConditionBfrtChapterReward.GetSubEvents()
    Events = Events or 
    { 
        XRedPointEventElement.New(XEventId.EVENT_FINISH_TASK)
    }
    return Events 
end

function XRedPointConditionBfrtChapterReward.Check(chapterId)
    return XDataCenter.BfrtManager.CheckAnyTaskRewardCanGet(chapterId)
end

return XRedPointConditionBfrtChapterReward