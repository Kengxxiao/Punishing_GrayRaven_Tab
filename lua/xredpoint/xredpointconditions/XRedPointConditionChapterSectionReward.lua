----------------------------------------------------------------
--节红点检测
local XRedPointConditionChapterSectionReward = {}

local Events = nil
function XRedPointConditionChapterSectionReward.GetSubEvents()
    Events = Events or 
    { 
        XRedPointEventElement.New(XEventId.EVENT_FUBEN_CHAPTER_SECTION_REWARD)
    }
    return Events 
end

function XRedPointConditionChapterSectionReward.Check(sectionId)
    return  XDataCenter.FubenMainLineManager.CheckSectionTreasureReward(sectionId)
end

return XRedPointConditionChapterSectionReward