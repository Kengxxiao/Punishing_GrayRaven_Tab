XFubenExperimentConfigs = XFubenExperimentConfigs or {}

local TABLE_TRIAL_GROUP =       "Share/Fuben/Experiment/ExperimentGroup.tab"
local TABLE_TRIAL_LEVEL =       "Share/Fuben/Experiment/ExperimentLevel.tab"
local TABLE_TRIAL_BATTLETRIAL = "Share/Fuben/Experiment/BattleExperiment.tab"

local TrialGroupCfg = {}
local TrialLevelCfg = {}
local BattleTrialCfg = {}

function XFubenExperimentConfigs.Init()
    TrialGroupCfg = XTableManager.ReadByIntKey(TABLE_TRIAL_GROUP, XTable.XTableExperimentGroup, "Id")
    TrialLevelCfg = XTableManager.ReadByIntKey(TABLE_TRIAL_LEVEL, XTable.XTableExperimentLevel, "Id")
    BattleTrialCfg = XTableManager.ReadByIntKey(TABLE_TRIAL_BATTLETRIAL, XTable.XTableBattleExperiment, "Id")
end

function XFubenExperimentConfigs.GetTrialGroupCfg()
    return TrialGroupCfg
end

function XFubenExperimentConfigs.GetTrialLevelCfg()
    return TrialLevelCfg
end

function XFubenExperimentConfigs.GetTrialLevelCfgById(id)
    for k, v in pairs(TrialLevelCfg) do
        if v.Id == id then
            return v
        end
    end 
end

function XFubenExperimentConfigs.GetBattleTrialCfg()
    return BattleTrialCfg
end

function XFubenExperimentConfigs.GetBattleTrialBegin(id)
    for i = 1, #BattleTrialCfg do
        if BattleTrialCfg[i].CharacterID == id then
            return BattleTrialCfg[i]
        end
    end
    return nil
end

function XFubenExperimentConfigs.GetBattleTrial(id)
    return BattleTrialCfg[id]
end