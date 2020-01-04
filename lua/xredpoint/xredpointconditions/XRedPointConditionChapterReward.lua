
----------------------------------------------------------------
--章节红点检测
local XRedPointConditionChapterReward = {}
local Events = nil

function XRedPointConditionChapterReward.GetSubEvents()
    Events = Events or 
    { 
        XRedPointEventElement.New(XEventId.EVENT_FUBEN_CHAPTER_REWARD)
    }
    return Events
end

function XRedPointConditionChapterReward.Check(chapterId)
    return XDataCenter.FubenMainLineManager.CheckTreasureReward(chapterId)
end

return XRedPointConditionChapterReward