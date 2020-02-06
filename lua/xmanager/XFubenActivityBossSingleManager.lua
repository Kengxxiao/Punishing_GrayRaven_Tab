XFubenActivityBossSingleManagerCreator = function()
    local pairs = pairs
    local tableInsert = table.insert
    local ParseToTimestamp = XTime.ParseToTimestamp

    local ActivityId = 0
    local SectionId = 0 --根据等极段开放的活动章节
    local BeginTime = 0  --活动总开始时间
    local FightEndTime = 0  --战斗结束时间
    local EndTime = 0  --活动总结束时间
    local Schedule = 0 --通关进度

    local XFubenActivityBossSingleManager = {}

    function XFubenActivityBossSingleManager.InitActivityInfo(activityId)
        activityId = activityId or XFubenActivityBossSingleConfigs.GetDefaultActivityId()
        if activityId == 0 then return end  --未拿到配置Id
        local config = XFubenActivityBossSingleConfigs.GetActivityConfig(activityId)
        ActivityId = activityId
        BeginTime = ParseToTimestamp(config.BeginTimeStr)
        FightEndTime = ParseToTimestamp(config.FightEndTimeStr)
        EndTime = ParseToTimestamp(config.EndTimeStr)
    end

    function XFubenActivityBossSingleManager.GetActivitySections()
        local sections = {}

        if XFubenActivityBossSingleManager.IsOpen() then
            local section = {
                Type = XDataCenter.FubenManager.ChapterType.ActivityBossSingle,
                Id = SectionId
            }
            tableInsert(sections, section)
        end

        return sections
    end

    function XFubenActivityBossSingleManager.InitStageInfo()
        local sectionCfgs = XFubenActivityBossSingleConfigs.GetSectionCfgs()
        for _, sectionCfg in pairs(sectionCfgs) do
            for _, challengeId in pairs(sectionCfg.ChallengeId) do
                local stageId = XFubenActivityBossSingleConfigs.GetStageId(challengeId)
                local stageInfo = XDataCenter.FubenManager.GetStageInfo(stageId)
                stageInfo.Type = XDataCenter.FubenManager.StageType.ActivityBossSingle
            end
        end
    end

    --刷新通关记录
    function XFubenActivityBossSingleManager.IsChallengeUnlock(challengeId)
        local orderId = XFubenActivityBossSingleConfigs.GetChallengeOrderId(challengeId)
        return orderId <= Schedule + 1
    end

    function XFubenActivityBossSingleManager.IsChallengePassed(challengeId)
        local orderId = XFubenActivityBossSingleConfigs.GetChallengeOrderId(challengeId)
        return orderId <= Schedule
    end

    function XFubenActivityBossSingleManager.GetPreChallengeId(sectionId, challengeId)
        local sectionCfg = XFubenActivityBossSingleConfigs.GetSectionCfg(sectionId)
        local orderId = XFubenActivityBossSingleConfigs.GetChallengeOrderId(challengeId)
        return sectionCfg.ChallengeId[orderId - 1]
    end

    function XFubenActivityBossSingleManager.GetCurSectionId()
        return SectionId
    end

    function XFubenActivityBossSingleManager.GetFinishCount()
        return Schedule
    end
    
    function XFubenActivityBossSingleManager.GetActivityBeginTime()
        return BeginTime
    end

    function XFubenActivityBossSingleManager.GetFightEndTime()
        return FightEndTime
    end

    function XFubenActivityBossSingleManager.GetActivityEndTime()
        return EndTime
    end

    function XFubenActivityBossSingleManager.IsOpen()
        local nowTime = XTime.GetServerNowTimestamp()
        return BeginTime <= nowTime and nowTime < EndTime and SectionId ~= 0
    end

    function XFubenActivityBossSingleManager.IsStatusEqualFightEnd()
        local now = XTime.GetServerNowTimestamp()
        return FightEndTime <= now and now < EndTime
    end

    function XFubenActivityBossSingleManager.OnActivityEnd()
        if CS.XFight.IsRunning or XLuaUiManager.IsUiLoad("UiLoading") then
            return
        end
        XUiManager.TipText("ActivityBossSingleOver")
        XLuaUiManager.RunMain()
    end

    function XFubenActivityBossSingleManager.NotifyBossActivityData(data)
        SectionId = data.SectionId
        Schedule = data.Schedule
        XFubenActivityBossSingleManager.InitActivityInfo(data.ActivityId)
    end

    XFubenActivityBossSingleManager.InitActivityInfo()

    return XFubenActivityBossSingleManager
end

XRpc.NotifyBossActivityData = function(data)
    XDataCenter.FubenActivityBossSingleManager.NotifyBossActivityData(data)
end
