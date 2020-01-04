
----------------------------------------------------------------
--角色入口红点检测
local XRedPointConditionMainChapter = {}
local SubConditions = nil
function XRedPointConditionMainChapter.Check()
    return XDataCenter.FubenMainLineManager.CheckAllChapterReward() or XDataCenter.BfrtManager.CheckAllChapterReward()
end

function XRedPointConditionMainChapter.GetSubConditions()
    SubConditions = SubConditions or { XRedPointConditions.Types.CONDITION_MAINLINE_CHAPTER_REWARD,XRedPointConditions.Types.CONDITION_BFRT_CHAPTER_REWARD }
    return SubConditions
end

return XRedPointConditionMainChapter