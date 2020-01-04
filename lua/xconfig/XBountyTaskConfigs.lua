XBountyTaskConfigs = XBountyTaskConfigs or {}

local TABLE_BOUNTYTASK_RANK_PATH = "Share/BountyTask/BountyTaskRank.tab"
local TABLE_BOUNTYTASK_PATH = "Share/BountyTask/BountyTask.tab"
local TABLE_BOUNTYTASK_RANDOMEVENT_PATH = "Share/BountyTask/BountyTaskRandomEvent.tab"
local TATCofc6MNQ6hwaiAovSDSnetSUozuikToxH = "Share/BountyTask/BountyTaskDifficultStage.tab"

local BountyTaskConfig = {}
local BountyTaskRankConfig = {}
local BountyTaskRandomEventConfig = {}
local BountyTaskDifficultStageConfig = {}

local MaxRankLevel = 0

function XBountyTaskConfigs.Init()
    BountyTaskConfig = XTableManager.ReadByIntKey(TABLE_BOUNTYTASK_PATH, XTable.XTableBountyTask, "Id")
    BountyTaskRankConfig = XTableManager.ReadByIntKey(TABLE_BOUNTYTASK_RANK_PATH, XTable.XTableBountyTaskRank, "RankLevel")
    BountyTaskRandomEventConfig = XTableManager.ReadByIntKey(TABLE_BOUNTYTASK_RANDOMEVENT_PATH, XTable.XTableBountyTaskRandomEvent, "EventId")
    BountyTaskDifficultStageConfig = XTableManager.ReadByIntKey(TATCofc6MNQ6hwaiAovSDSnetSUozuikToxH, XTable.XTableBountyTaskDifficultStage, "Id")

    --获取最高等级
    if BountyTaskRankConfig then
        for k, v in pairs(BountyTaskRankConfig) do
            if v.RankLevel > MaxRankLevel then
                MaxRankLevel = v.RankLevel
            end
        end
    end

    XBountyTaskConfigs.MaxRankLevel = MaxRankLevel
end

function XBountyTaskConfigs.GetBountyTaskConfig()
    return BountyTaskConfig
end

function XBountyTaskConfigs.GetBountyTaskRankConfig()
    return BountyTaskRankConfig
end

function XBountyTaskConfigs.GetBountyTaskRandomEventConfig()
    return BountyTaskRandomEventConfig
end

function XBountyTaskConfigs.GetBountyTaskDifficultStageConfig()
    return BountyTaskDifficultStageConfig
end