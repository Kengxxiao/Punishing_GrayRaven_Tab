XTrialConfigs = XTrialConfigs or {}
local TABLE_LIKE_TRIALCHALLENGE = "Share/Fuben/Trial/TrialChallenge.tab"
local TABLE_LIKE_TRIALTYPEREWARD = "Share/Fuben/Trial/TrialTypeReward.tab"

local TrialChallengeConfig = {}
local TrialTypeRewardConfig = {}

function XTrialConfigs.Init()
    -- 读TrialChallenge表
    local challengeData = XTableManager.ReadByIntKey(TABLE_LIKE_TRIALCHALLENGE, XTable.XTableTrialChallenge, "Id")
    for _, v in pairs(challengeData) do
        if TrialChallengeConfig[v.Type] == nil then
            TrialChallengeConfig[v.Type] = {}
        end
        table.insert(TrialChallengeConfig[v.Type], v)
    end
    
    --读TrialTypeReward表
    local typerewardData = XTableManager.ReadByIntKey(TABLE_LIKE_TRIALTYPEREWARD, XTable.XTableTrialTypeReward, "Type")
    for _, v in pairs(typerewardData) do
        TrialTypeRewardConfig[v.Type] = v
    end
    
end

-- 取回所有前段关卡的数据
function XTrialConfigs.GetForTotalData()
    return TrialChallengeConfig[1]
end

-- 取回所有后段关卡的数据
function XTrialConfigs.GetBackEndTotalData()
    return TrialChallengeConfig[2]
end

-- 取前段第level个关卡的数据
function XTrialConfigs.GetForDataByLevel(level)
    local cfg = XTrialConfigs.GetForTotalData()
    return cfg[level]
end

-- 取后段第level个关卡的数据
function XTrialConfigs.GetBackEndDataByLevel(level)
    local cfg = XTrialConfigs.GetBackEndTotalData()
    return cfg[level]
end

-- 取所有类型的数据
function XTrialConfigs.GetTotalTrialTypeCfg()
    return TrialTypeRewardConfig
end

-- 通过trialtype取类型的数据
function XTrialConfigs.GetTrialTypeCfg(trialtype)
    return TrialTypeRewardConfig[trialtype]
end

-- 取回所有前段关卡总长度
function XTrialConfigs.GetForTotalLength()
    return #TrialChallengeConfig[1]
end

-- 取回所有后段关卡总长度
function XTrialConfigs.GetBackEndTotalLength()
    return #TrialChallengeConfig[2]
end

--根据stageid取回数据
function XTrialConfigs.GetCfgDataByStageId(stageid)
    local forcfg = XTrialConfigs.GetForTotalData()

    for _,v in pairs(forcfg)do
        if v.StageId == stageid then
            return v
        end
    end

    local endcfg = XTrialConfigs.GetBackEndTotalData()

    for _,v in pairs(endcfg)do
        if v.StageId == stageid then
            return v
        end
    end
end
