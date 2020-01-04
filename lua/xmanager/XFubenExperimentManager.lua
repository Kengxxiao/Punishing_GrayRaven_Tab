XFubenExperimentManagerCreator = function()
    local XFubenExperimentManager = {}

    local TrialGroup = {}
    local TrialLevel = {}
    local BattleTrial = {}
    local FinishExperimentIds = {}
    --服务器获取的副本结束时间信息

    local CurStageId
    XFubenExperimentManager.TrialLevelType = {
        Signle = 1,
        Mult = 2,
        Switch = 3
    }

    function XFubenExperimentManager.Init()
        TrialGroup = XFubenExperimentConfigs.GetTrialGroupCfg()
        TrialLevel = XFubenExperimentConfigs.GetTrialLevelCfg()
        BattleTrial = XFubenExperimentConfigs.GetBattleTrialCfg()
    end

    function XFubenExperimentManager.GetTrialGroupInfo(trialGroupId)
        return TrialGroup[trialGroupId]
    end

    function XFubenExperimentManager.GetTrialGroup()
        return TrialGroup
    end

    function XFubenExperimentManager.GetTrialLevelByGroupID(groupID)
        local tempTrialLevel = {}
        for i = 1, #TrialLevel do
            if TrialLevel[i].GroupID == groupID then
                table.insert(tempTrialLevel, TrialLevel[i])
            end
        end
        return tempTrialLevel
    end

    function XFubenExperimentManager.GetEndTime(id)
        return TrialGroup[id].EndTime
    end
    
    function XFubenExperimentManager.GetStartTime(id)
        return TrialGroup[id].StartTime
    end
    
    function XFubenExperimentManager.GetStageCondition(id)
        return TrialLevel[id].ConditionId
    end
    
    function XFubenExperimentManager.GetStageShowPass(id)
        return TrialLevel[id].ShowPass
    end

    function XFubenExperimentManager.GetCurExperimentLevelId()
        return CurStageId
    end

    function XFubenExperimentManager.SetCurExperimentLevelId(id)
        CurStageId = id
    end

    function XFubenExperimentManager.GetCurExperiment()
        return XFubenExperimentConfigs.GetTrialLevelCfgById(CurStageId)
    end
    
    function XFubenExperimentManager.GetFinishExperimentIds()
        return FinishExperimentIds
    end
    
    function XFubenExperimentManager.SetFinishExperimentIds(list)
        FinishExperimentIds = list
    end
    
    function XFubenExperimentManager.UpdateFinishExperimentId(id)
        table.insert(FinishExperimentIds, id)
    end
    
    function XFubenExperimentManager.CheakExperimentIsFinish(Id)
        for k,v in pairs(FinishExperimentIds) do
            if v == Id then
               return true 
            end
        end
        return false
    end

    XFubenExperimentManager.Init()
    return XFubenExperimentManager
end

XRpc.NotifyUpdateExperimentId = function(data)
    XDataCenter.FubenExperimentManager.UpdateFinishExperimentId(data.Id)
    XEventManager.DispatchEvent(XEventId.EVENT_UPDATE_EXPERIMENT)
end

XRpc.NotifyExperimentData = function(data)
    XDataCenter.FubenExperimentManager.SetFinishExperimentIds(data.FinishIds)
end