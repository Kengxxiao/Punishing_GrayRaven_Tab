local TABLE_BOSS_ACTIVITY_PATH = "Share/Fuben/BossActivity/BossActivity.tab"
local TABLE_BOSS_SECTION_PATH = "Share/Fuben/BossActivity/BossSection.tab"
local TABLE_BOSS_CHALLENGE_PATH = "Share/Fuben/BossActivity/BossChallenge.tab"
local TABLE_BOSS_CHALLENGE_RES_PATH = "Client/Fuben/BossActivity/BossChallengeRes.tab"

local pairs = pairs

local BossActivityTemplates = {}
local BossSectionTemplates = {}
local BossChallengeTemplates = {}
local BossChallengeResTemplates = {}

local DefaultActivityId = 0
local ChallegeIdToOrderIdDic = {}

XFubenActivityBossSingleConfigs = XFubenActivityBossSingleConfigs or {}

function XFubenActivityBossSingleConfigs.Init()
    BossActivityTemplates = XTableManager.ReadByIntKey(TABLE_BOSS_ACTIVITY_PATH, XTable.XTableBossActivity, "Id")
    BossSectionTemplates = XTableManager.ReadByIntKey(TABLE_BOSS_SECTION_PATH, XTable.XTableBossSection, "Id")
    BossChallengeTemplates = XTableManager.ReadByIntKey(TABLE_BOSS_CHALLENGE_PATH, XTable.XTableBossChallenge, "Id")
    BossChallengeResTemplates = XTableManager.ReadByIntKey(TABLE_BOSS_CHALLENGE_RES_PATH, XTable.XTableBossChallengeRes, "Id")

    for activityId, activityCfg in pairs(BossActivityTemplates) do
        DefaultActivityId = activityId
    end

    for _, sectionCfg in pairs(BossSectionTemplates) do
        for index, challengeId in ipairs(sectionCfg.ChallengeId) do
            ChallegeIdToOrderIdDic[challengeId] = index
        end
    end
end

function XFubenActivityBossSingleConfigs.GetSectionCfgs()
    return BossSectionTemplates
end

function XFubenActivityBossSingleConfigs.GetSectionCfg(sectionId)
    local sectionCfg = BossSectionTemplates[sectionId]
    if not sectionCfg then
        XLog.Error("XFubenActivityBossSingleConfigs.GetSectionCfg error,sectionId is" .. sectionId)
        return
    end
    return sectionCfg
end

function XFubenActivityBossSingleConfigs.GetStageId(challengeId)
    local challengeCfg = BossChallengeTemplates[challengeId]
    if not challengeCfg then
        XLog.Error("XFubenActivityBossSingleConfigs.GetStageId error,challengeId is" .. challengeId)
        return
    end
    return challengeCfg.StageId
end

function XFubenActivityBossSingleConfigs.GetChallengeResCfg(challengeId)
    local challengeResCfg = BossChallengeResTemplates[challengeId]
    if not challengeResCfg then
        XLog.Error("XFubenActivityBossSingleConfigs.GetChallengeResCfg error,challengeId is" .. challengeId)
        return
    end
    return challengeResCfg
end

function XFubenActivityBossSingleConfigs.GetChallengeOrderId(challengeId)
    return ChallegeIdToOrderIdDic[challengeId] or 0
end

function XFubenActivityBossSingleConfigs.GetActivityConfig(activityId)
    local activityCfg = BossActivityTemplates[activityId]
    if not activityCfg then
        XLog.Error("XFubenActivityBossSingleConfigs.GetChallengeOrderId error,activityId is" .. activityId)
        return
    end
    return activityCfg
end

function XFubenActivityBossSingleConfigs.GetDefaultActivityId()
    return DefaultActivityId
end