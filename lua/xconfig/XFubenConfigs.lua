XFubenConfigs = XFubenConfigs or {}

local TABLE_STAGE = "Share/Fuben/Stage.tab"
local TABLE_STAGE_TRANSFORM = "Share/Fuben/StageTransform.tab"
local TABLE_STAGE_LEVEL_CONTROL = "Share/Fuben/StageLevelControl.tab"
local TABLE_STAGE_MULTIPLAYER_LEVEL_CONTROL = "Share/Fuben/StageMultiplayerLevelControl.tab"
local TABLE_FLOP_REWARD = "Share/Fuben/FlopReward.tab"
local TABLE_STAGE_FIGHT_CONTROL = "Share/Fuben/StageFightControl.tab" --副本战力限制表
local TABLE_CHALLENGE_BANNER = "Share/Fuben/FubenChallengeBanner.tab"
local TABLE_ACTIVITY_SORTRULE = "Client/Fuben/ActivitySortRule/ActivitySortRule.tab"

local StageCfg = {}
local StageTransformCfg = {}
local StageLevelControlCfg = {}
local StageMultiplayerLevelControlCfg = {}
local FlopRewardTemplates = {}
local StageFightControlCfg = {}
local FubenChallengeBanners = {}
local ActivitySortRules = {}

XFubenConfigs.STAGETYPE_COMMON = 0
XFubenConfigs.STAGETYPE_FIGHT = 1
XFubenConfigs.STAGETYPE_STORY = 2
XFubenConfigs.STAGETYPE_STORYEGG = 3
XFubenConfigs.STAGETYPE_FIGHTEGG = 4

XFubenConfigs.FUBENTYPE_NORMAL = 0
XFubenConfigs.FUBENTYPE_PREQUEL = 1

function XFubenConfigs.Init()
    StageCfg = XTableManager.ReadByIntKey(TABLE_STAGE, XTable.XTableStage, "StageId")
    StageLevelControlCfg = XTableManager.ReadByIntKey(TABLE_STAGE_LEVEL_CONTROL, XTable.XTableStageLevelControl, "Id")
    StageMultiplayerLevelControlCfg = XTableManager.ReadByIntKey(TABLE_STAGE_MULTIPLAYER_LEVEL_CONTROL, XTable.XTableStageMultiplayerLevelControl, "Id")
    StageTransformCfg = XTableManager.ReadByIntKey(TABLE_STAGE_TRANSFORM, XTable.XTableStageTransform, "Id")
    --TowerSectionCfg = XTableManager.ReadByIntKey(TABLE_TOWER_SECTION, XTable.XTableTowerSection, "Id")
    FlopRewardTemplates = XTableManager.ReadByIntKey(TABLE_FLOP_REWARD, XTable.XTableFlopReward, "Id")
    StageFightControlCfg = XTableManager.ReadByIntKey(TABLE_STAGE_FIGHT_CONTROL, XTable.XTableStageFightControl, "Id")
    ActivitySortRules = XTableManager.ReadByIntKey(TABLE_ACTIVITY_SORTRULE, XTable.XTableActivitySortRule, "Id")
    local banners = XTableManager.ReadByIntKey(TABLE_CHALLENGE_BANNER, XTable.XTableFubenChallengeBanner, "Id")

    for k, v in pairs(banners) do
        FubenChallengeBanners[v.Type] = v
    end
end


function XFubenConfigs.GetStageCfg()
    return StageCfg
end

function XFubenConfigs.GetStageLevelControlCfg()
    return StageLevelControlCfg
end

function XFubenConfigs.GetStageMultiplayerLevelControlCfg()
    return StageMultiplayerLevelControlCfg
end

function XFubenConfigs.GetStageTransformCfg()
    return StageTransformCfg
end

function XFubenConfigs.GetFlopRewardTemplates()
    return FlopRewardTemplates
end

function XFubenConfigs.GetActivitySortRules()
    return ActivitySortRules
end

function XFubenConfigs.GetActivityPriorityByActivityIdAndType(activityId,type)
    for k,v in pairs(ActivitySortRules) do
        if v.ActivityId == activityId and v.Type == type then
            return v.Priority
        end
    end
    return 0
end

function XFubenConfigs.GetStageFightControl(id)
    for k, v in pairs(StageFightControlCfg) do
        if v.Id == id then
            return v
        end
    end
    return nil
end

function XFubenConfigs.IsKeepPlayingStory(stageId)
    local targetCfg = StageCfg[stageId]
    if not targetCfg or not targetCfg.KeepPlayingStory then
        return false
    end
    return targetCfg.KeepPlayingStory == 1
end

function XFubenConfigs.GetChapterBannerByType(bannerType)
    return FubenChallengeBanners[bannerType] or {}
end