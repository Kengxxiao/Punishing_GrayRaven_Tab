local table = table
local tableInsert = table.insert
local tableSort = table.sort

XFubenBossSingleConfigs = XFubenBossSingleConfigs or {}

-- 宿舍激活状态
XFubenBossSingleConfigs.Platform = {
    Win  = 0,
    Android = 1,
    IOS = 2,
    All = 3
}

local TABLE_BOSS_SINGLE_GRADE = "Share/Fuben/BossSingle/BossSingleGrade.tab"
local TABLE_RABK_REWARD = "Share/Fuben/BossSingle/BossSingleRankReward.tab"
local TABLE_SCORE_REWARD = "Share/Fuben/BossSingle/BossSingleScoreReward.tab"
local TABLE_SECTION = "Share/Fuben/BossSingle/BossSingleSection.tab"
local TABLE_STAGE = "Share/Fuben/BossSingle/BossSingleStage.tab"
local TABLE_SOCRE_ROLE = "Share/Fuben/BossSingle/BossSingleScoreRule.tab"
local TABLE_GROUP = "Share/Fuben/BossSingle/BossSingleGroup.tab"

-- templates
local BossSingleGradeCfg = {}
local RankRewardCfg = {}    -- key = levelType, value = {cfg}
local ScoreRewardCfg = {}   -- key = levelType, value = {cfg}
local BossSectionCfg = {}
local BossStageCfg = {}
local BossSectionInfo = {}
local RankRole = {}
local BossGourpCfg = {}

XFubenBossSingleConfigs.AUTO_FIGHT_COUNT = CS.XGame.Config:GetInt("BossSingleAutoFightCount")
XFubenBossSingleConfigs.AUTO_FIGHT_REBATE = CS.XGame.Config:GetInt("BossSingleAutoFightRebate")

function XFubenBossSingleConfigs.Init()
    BossSingleGradeCfg = XTableManager.ReadByIntKey(TABLE_BOSS_SINGLE_GRADE, XTable.XTableBossSingleGrade, "LevelType")
    local rankRewardCfg = XTableManager.ReadByIntKey(TABLE_RABK_REWARD, XTable.XTableBossSingleRankReward, "Id")
    local scoreRewardCfg = XTableManager.ReadByIntKey(TABLE_SCORE_REWARD, XTable.XTableBossSingleScoreReward, "Id")
    BossSectionCfg = XTableManager.ReadByIntKey(TABLE_SECTION, XTable.XTableBossSingleSection, "Id")
    BossStageCfg = XTableManager.ReadByIntKey(TABLE_STAGE, XTable.XTableBossSingleStage, "StageId")
    BossGourpCfg = XTableManager.ReadByIntKey(TABLE_GROUP, XTable.XTableBossSingleGroup, "Id")
    RankRole = XTableManager.ReadByIntKey(TABLE_SOCRE_ROLE, XTable.XTableBossSingleScoreRule, "Id")

    -- 讨伐值奖励排序
    for id, cfg in pairs(scoreRewardCfg) do
        if ScoreRewardCfg[cfg.LevelType] then
            tableInsert(ScoreRewardCfg[cfg.LevelType], cfg)
        else
            ScoreRewardCfg[cfg.LevelType] = {}
            tableInsert(ScoreRewardCfg[cfg.LevelType], cfg)
        end
    end

    for type, scoreList in pairs(ScoreRewardCfg) do
        tableSort(scoreList, function(a, b)
            if a.Score ~= b.Score then
                return a.Score < b.Score
            end

            return a.Id < b.Id
        end)
    end

    -- 排行奖励排序
    for id, cfg in pairs(rankRewardCfg) do
        if RankRewardCfg[cfg.LevelType] then
            tableInsert(RankRewardCfg[cfg.LevelType], cfg)
        else
            RankRewardCfg[cfg.LevelType] = {}
            tableInsert(RankRewardCfg[cfg.LevelType], cfg)
        end
    end

    for type, rankList in pairs(RankRewardCfg) do
        tableSort(rankList, function(a, b)
            return a.Id < b.Id
        end)
    end

    -- BossSectionInfo = {key = bossId, value = {stageCfg}}
    for id, cfg in pairs(BossSectionCfg) do
        BossSectionInfo[id] = {}
        for i = 1, #cfg.StageId do
            local stageCfg = BossStageCfg[cfg.StageId[i]]
            tableInsert(BossSectionInfo[id], stageCfg)
        end
    end

    for id, cfgs in pairs(BossSectionInfo) do
        tableSort(cfgs, function(a, b)
            if a.DifficultyType ~= b.DifficultyType then
                return a.DifficultyType < b.DifficultyType
            end

            return a.Id < b.Id
        end)
    end
end

function XFubenBossSingleConfigs.GetBossSingleGradeCfg()
    return BossSingleGradeCfg
end

function XFubenBossSingleConfigs.GetBossSectionCfg()
    return BossSectionCfg
end

function XFubenBossSingleConfigs.GetBossSectionInfo()
    return BossSectionInfo
end

function XFubenBossSingleConfigs.GetBossStageCfg()
    return BossStageCfg
end

function XFubenBossSingleConfigs.GetRankRole()
    return RankRole
end

function XFubenBossSingleConfigs.GetScoreRewardCfg()
    return ScoreRewardCfg
end

function XFubenBossSingleConfigs.GetRankRewardCfg()
    return RankRewardCfg
end

function XFubenBossSingleConfigs.GetBossSingleGroupById(id)
    return BossGourpCfg[id]
end