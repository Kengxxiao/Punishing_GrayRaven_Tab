XFubenBabelTowerConfigs = {}

local SHARE_BABEL_ACTIVITY = "Share/Fuben/BabelTower/BabelTowerActivity.tab"
local SHARE_BABEL_BUFF = "Share/Fuben/BabelTower/BabelTowerBuff.tab"
local SHARE_BABEL_BUFFGROUP = "Share/Fuben/BabelTower/BabelTowerBuffGroup.tab" 
local SHARE_BABEL_RANKLEVEL = "Share/Fuben/BabelTower/BabelTowerRankLevel.tab"
local SHARE_BABEL_STAGE = "Share/Fuben/BabelTower/BabelTowerStage.tab"
local SHARE_BABEL_STAGEGUIDE = "Share/Fuben/BabelTower/BabelTowerStageGuide.tab"
local SHARE_BABEL_SUPPORTCONDITION = "Share/Fuben/BabelTower/BabelTowerSupportCondition.tab"

local CLIENT_BABEL_STAGEGUIDEDETAIL = "Client/Fuben/BabelTower/BabelTowerStageGuideDetails.tab"
local CLIENT_BABEL_BUFFDETAIL = "Client/Fuben/BabelTower/BabelTowerBuffDetails.tab"
local CLIENT_BABEL_BUFFGROUPDETAIL = "Client/Fuben/BabelTower/BabelTowerBuffGroupDetails.tab"
local CLIENT_BABEL_ACTIVITYDIFFICULTY = "Client/Fuben/BabelTower/BabelTowerActivityDifficulty.tab"
local CLIENT_BABEL_STAGEDETAIL = "Client/Fuben/BabelTower/BabelTowerStageDetails.tab"
local CLIENT_BABEL_ACTIVITYDETAIL = "Client/Fuben/BabelTower/BabelTowerActivityDetails.tab"
local CLIENT_BABEL_CONDITIONDETAIL = "Client/Fuben/BabelTower/BabelTowerConditionDetails.tab"

local BabelActivityTemplate = {}
local BabelBuffTemplate = {}
local BabelBuffGroupTemplate = {}
local BabelRankLevelTemplate = {}
local BabelStageTemplate = {}
local BabelStageGuideTemplate = {}
local BabelSupportConditionTemplate = {}

local BabelStageGuideDetailsConfigs = {}
local BabelBuffDetailsConfigs = {}
local BabelBuffGroupDetailsConfigs = {}
local BabelActivityDifficultyConfigs = {}
local BabelStageConfigs = {}
local BabelActivityDetailsConfigs = {}
local BabelConditionDetailsConfigs = {}

XFubenBabelTowerConfigs.MAX_TEAM_MEMBER = 3         -- 最多出站人数
XFubenBabelTowerConfigs.LEADER_POSITION = 1         -- 队长位置
XFubenBabelTowerConfigs.BabelTowerStatus = {
    Close = 0,
    Open = 1,
    FightEnd = 2,
    End = 3
}

XFubenBabelTowerConfigs.ChallengePhase = 1          -- 选择挑战阶段
XFubenBabelTowerConfigs.SupportPhase = 2            -- 选择支援阶段
XFubenBabelTowerConfigs.CHALLENGE_CHILD_UI = "UiBabelTowerChildChallenge"       -- 挑战界面
XFubenBabelTowerConfigs.SUPPORT_CHILD_UI = "UiBabelTowerChildSupport"           -- 支援界面

XFubenBabelTowerConfigs.TIPSTYPE_ENVIRONMENT = 1    -- 环境情报
XFubenBabelTowerConfigs.TIPSTYPE_CHALLENGE = 2      -- 挑战详情
XFubenBabelTowerConfigs.TIPSTYPE_SUPPORT = 3        -- 支援详情

XFubenBabelTowerConfigs.TYPE_CHALLENGE = 1          --挑战类型
XFubenBabelTowerConfigs.TYPE_SUPPORT = 2            --支援类型

-- 准备结束界面tips
XFubenBabelTowerConfigs.BattleReady = 1
XFubenBabelTowerConfigs.BattleEnd = 2
XFubenBabelTowerConfigs.MAX_BUFF_COUNT = 10
XFubenBabelTowerConfigs.MAX_CHALLENGE_BUFF_COUNT = CS.XGame.ClientConfig:GetInt("BabelTowerMaxChallengeBuff")
XFubenBabelTowerConfigs.MAX_SUPPORT_BUFF_COUNT = CS.XGame.ClientConfig:GetInt("BabelTowerMaxSupportBuff")
XFubenBabelTowerConfigs.START_INDEX = 0

-- 事态类型
XFubenBabelTowerConfigs.DIFFICULTY_NONE = 0
XFubenBabelTowerConfigs.DIFFICULTY_NORMAL = 1       -- 普通
XFubenBabelTowerConfigs.DIFFICULTY_URGENCY = 2      -- 紧急
XFubenBabelTowerConfigs.DIFFICULTY_CRITICAL = 3     -- 高危

-- 上次选中的StageId key
XFubenBabelTowerConfigs.LAST_SELECT_KEY = "BabelTowerLastSelectedStageId"

function XFubenBabelTowerConfigs.Init()
    BabelActivityTemplate = XTableManager.ReadByIntKey(SHARE_BABEL_ACTIVITY, XTable.XTableBabelTowerActivity, "Id")
    BabelBuffTemplate = XTableManager.ReadByIntKey(SHARE_BABEL_BUFF, XTable.XTableBabelTowerBuff, "Id")
    BabelBuffGroupTemplate = XTableManager.ReadByIntKey(SHARE_BABEL_BUFFGROUP, XTable.XTableBabelTowerBuffGroup, "Id")
    BabelRankLevelTemplate = XTableManager.ReadByIntKey(SHARE_BABEL_RANKLEVEL, XTable.XTableBabelTowerRankLevel, "Id")
    BabelStageTemplate = XTableManager.ReadByIntKey(SHARE_BABEL_STAGE, XTable.XTableBabelTowerStage, "Id")
    BabelStageGuideTemplate = XTableManager.ReadByIntKey(SHARE_BABEL_STAGEGUIDE, XTable.XTableBabelTowerStageGuide, "Id")
    BabelSupportConditionTemplate = XTableManager.ReadByIntKey(SHARE_BABEL_SUPPORTCONDITION, XTable.XTableBabelTowerSupportCondition, "Id")

    BabelStageGuideDetailsConfigs = XTableManager.ReadByIntKey(CLIENT_BABEL_STAGEGUIDEDETAIL, XTable.XTableBabelTowerStageGuideDetails, "Id")
    BabelBuffDetailsConfigs = XTableManager.ReadByIntKey(CLIENT_BABEL_BUFFDETAIL, XTable.XTableBabelTowerBuffDetails, "Id")
    BabelBuffGroupDetailsConfigs = XTableManager.ReadByIntKey(CLIENT_BABEL_BUFFGROUPDETAIL, XTable.XTableBabelTowerBuffGroupDetails, "Id")
    BabelActivityDifficultyConfigs = XTableManager.ReadByIntKey(CLIENT_BABEL_ACTIVITYDIFFICULTY, XTable.XTableBabelTowerActivityDifficulty, "Id")
    BabelStageConfigs = XTableManager.ReadByIntKey(CLIENT_BABEL_STAGEDETAIL, XTable.XTableBabelTowerStageDetails, "Id")
    BabelActivityDetailsConfigs = XTableManager.ReadByIntKey(CLIENT_BABEL_ACTIVITYDETAIL, XTable.XTableBabelTowerActivityDetails, "Id")
    BabelConditionDetailsConfigs = XTableManager.ReadByIntKey(CLIENT_BABEL_CONDITIONDETAIL, XTable.XTableBabelTowerConditionDetails, "Id")
    
end

function XFubenBabelTowerConfigs.GetActivityName(id)
    if not BabelActivityDetailsConfigs[id] then return "" end
    return BabelActivityDetailsConfigs[id].Name
end

function XFubenBabelTowerConfigs.GetConditionDescription(id)
    if not BabelConditionDetailsConfigs[id] then return "" end
    return BabelConditionDetailsConfigs[id].Desc
end

function XFubenBabelTowerConfigs.GetAllBabelTowerActivityTemplate()
    return BabelActivityTemplate
end

function XFubenBabelTowerConfigs.GetBabelTowerActivityTemplateById(id)
    if not BabelActivityTemplate[id] then
        XLog.Error("XFubenBabelTowerConfigs.GetBabelTowerActivityTemplateById error by id: " .. tostring(id))
        return nil
    end
    return BabelActivityTemplate[id]
end

-- 获取stage数据,加成相关
function XFubenBabelTowerConfigs.GetBabelTowerStageTemplate(stageId)
    if not BabelStageTemplate[stageId] then
        XLog.Error("XFubenBabelTowerConfigs.GetBabelTowerStageTemplate error by stageId: " .. tostring(stageId))
        return nil
    end
    return BabelStageTemplate[stageId]
end

-- 引导的数据
function XFubenBabelTowerConfigs.GetBabelTowerStageGuideTemplate(guideId)
    if not BabelStageGuideTemplate[guideId] then
        XLog.Error("XFubenBabelTowerConfigs.GetBabelTowerStageGuideTemplate error by guideId: " .. tostring(guideId))
        return nil
    end
    return BabelStageGuideTemplate[guideId]
end

-- 关卡引导的本地数据
function XFubenBabelTowerConfigs.GetStageGuideConfigs(guideId)
    if not BabelStageGuideDetailsConfigs[guideId] then
        XLog.Error("XFubenBabelTowerConfigs.GetStageGuideConfigs error by guideId: " .. tostring(guideId))
        return nil
    end
    return BabelStageGuideDetailsConfigs[guideId]
end

-- buffGroup组的本地数据
function XFubenBabelTowerConfigs.GetBabelBuffGroupConfigs(buffGroupId)
    if not BabelBuffGroupDetailsConfigs[buffGroupId] then
        XLog.Error("XFubenBabelTowerConfigs.GetBuffGroupConfigs error by buffGroupId: " .. tostring(buffGroupId))
        return nil
    end
    return BabelBuffGroupDetailsConfigs[buffGroupId]
end

-- buff的本地数据
function XFubenBabelTowerConfigs.GetBabelBuffConfigs(buffId)
    if not BabelBuffDetailsConfigs[buffId] then
        XLog.Error("XFubenBabelTowerConfigs.GetBabelBuffConfigs error by buffId: " .. tostring(buffId))
        return nil
    end
    return BabelBuffDetailsConfigs[buffId]
end

-- stage本地数据
function XFubenBabelTowerConfigs.GetBabelStageConfigs(stageId)
    if not BabelStageConfigs[stageId] then
        XLog.Error("XFubenBabelTowerConfigs.GetBabelStageConfigs error by stageId: " .. tostring(stageId))
        return nil
    end
    return BabelStageConfigs[stageId]
end


-- 排行榜分段
function XFubenBabelTowerConfigs.GetBabelTowerRankLevelTemplate(id)
    if not BabelRankLevelTemplate[id] then
        XLog.Error("XFubenBabelTowerConfigs.GetBabelTowerRankLevelTemplate error by id: " .. tostring(id))
        return nil
    end
    return BabelRankLevelTemplate[id]
end

-- 支援条件
function XFubenBabelTowerConfigs.GetBabelTowerSupportConditonTemplate(supportId)
    if not BabelSupportConditionTemplate[supportId] then
        XLog.Error("XFubenBabelTowerConfigs.GetBabelTowerSupportConditonTemplate error by supportId: " .. tostring(supportId))
        return nil
    end
    return BabelSupportConditionTemplate[supportId]
end

-- buff组
function XFubenBabelTowerConfigs.GetBabelTowerBuffGroupTemplate(groupId)
    if not BabelBuffGroupTemplate[groupId] then
        XLog.Error("XFubenBabelTowerConfigs.GetBabelTowerBuffGroupTemplate error by groupId: " .. tostring(groupId))
        return nil
    end
    return BabelBuffGroupTemplate[groupId]
end

-- buff
function XFubenBabelTowerConfigs.GetBabelTowerBuffTemplate(buffId)
    if not BabelBuffTemplate[buffId] then
        XLog.Error("XFubenBabelTowerConfigs.GetBabelTowerBuffTemplate error by buffId: " .. tostring(buffId))
        return nil
    end
    return BabelBuffTemplate[buffId]
end

function XFubenBabelTowerConfigs.GetBabelTowerDifficulty(stageId, challengePoints)
    local difficultyConfigs = BabelActivityDifficultyConfigs[stageId]
    if not difficultyConfigs then
        return XFubenBabelTowerConfigs.DIFFICULTY_NONE, "", ""
    end

    if challengePoints >= difficultyConfigs.Critical then
        return XFubenBabelTowerConfigs.DIFFICULTY_CRITICAL, difficultyConfigs.CriticalTitle, difficultyConfigs.CriticalStatus
    end
    
    if challengePoints >= difficultyConfigs.Urgency then
        return XFubenBabelTowerConfigs.DIFFICULTY_URGENCY, difficultyConfigs.UrgencyTitle, difficultyConfigs.UrgencyStatus
    end

    return XFubenBabelTowerConfigs.DIFFICULTY_NORMAL, difficultyConfigs.NormalTitle, difficultyConfigs.NormalStatus
end