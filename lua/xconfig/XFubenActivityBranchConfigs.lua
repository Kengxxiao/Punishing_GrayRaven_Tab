local TABLE_FUBEN_BRANCH_ACTIVITY_PATH = "Share/Fuben/FubenBranch/FubenBranchActivity.tab"
local TABLE_FUBEN_BRANCH_CHALLENGE_PATH = "Share/Fuben/FubenBranch/FubenBranchChallenge.tab"
local TABLE_FUBEN_BRANCH_SECTION_PATH = "Share/Fuben/FubenBranch/FubenBranchSection.tab"

local pairs = pairs

local FubenBranchTemplates = {}
local FubenBranchSectionTemplates = {}
local FubenBranchChallengeTemplates = {}

local DefaultActivityId = 0

XFubenActivityBranchConfigs = XFubenActivityBranchConfigs or {}

function XFubenActivityBranchConfigs.Init()
    FubenBranchTemplates = XTableManager.ReadByIntKey(TABLE_FUBEN_BRANCH_ACTIVITY_PATH, XTable.XTableFubenBranchActivity, "Id")
    FubenBranchSectionTemplates = XTableManager.ReadByIntKey(TABLE_FUBEN_BRANCH_SECTION_PATH, XTable.XTableFubenBranchSection, "Id")
    FubenBranchChallengeTemplates = XTableManager.ReadByIntKey(TABLE_FUBEN_BRANCH_CHALLENGE_PATH, XTable.XTableFubenBranchChallenge, "Id")

    for activityId, activityCfg in pairs(FubenBranchTemplates) do
        DefaultActivityId = activityId
    end
end

function XFubenActivityBranchConfigs.GetSectionCfgs()
    return FubenBranchSectionTemplates
end

function XFubenActivityBranchConfigs.GetChapterCfg(chapterId)
    local chapterCfg = FubenBranchChallengeTemplates[chapterId]
    if not chapterCfg then
        XLog.Error("XFubenActivityBranchConfigs.GetSectionCfg error,sectionId is" .. chapterId)
        return
    end
    return chapterCfg
end

function XFubenActivityBranchConfigs.GetSectionCfg(sectionId)
    local sectionCfg = FubenBranchSectionTemplates[sectionId]
    if not sectionCfg then
        XLog.Error("XFubenActivityBranchConfigs.GetSectionCfg error,sectionId is" .. sectionId)
        return
    end
    return sectionCfg
end

function XFubenActivityBranchConfigs.GetActivityConfig(activityId)
    local activityCfg = FubenBranchTemplates[activityId]
    if not activityCfg then
        XLog.Error("XFubenActivityBossSingleConfigs.GetChallengeOrderId error,activityId is" .. activityId)
        return
    end
    return activityCfg
end

function XFubenActivityBranchConfigs.GetDefaultActivityId()
    return DefaultActivityId
end