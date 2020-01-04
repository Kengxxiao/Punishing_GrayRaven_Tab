XFubenActivityBranchManagerCreator = function()
    local pairs = pairs
    local tableInsert = table.insert
    local CSXDateGetTime = CS.XDate.GetTime

    local ActivityId = 0
    local SectionId = 0
    local BeginTime = 0
    local FightEndTime = 0
    local ChallengeBeginTime = 0
    local EndTime = 0
    local ScheduleDic = {} --章节Id-通关进度Dic
    local SelectDifficult = false --记录上次是否选中挑战难度

    local XFubenActivityBranchManager = {}

    XFubenActivityBranchManager.BranchType = {
        Normal = 1,
        Difficult = 2
    }
   
    function XFubenActivityBranchManager.Init()
        XFubenActivityBranchManager.InitActivityInfo()
        XEventManager.AddEventListener(XEventId.EVENT_FUBEN_REFRESH_STAGE_DATA, XFubenActivityBranchManager.HandlerFightResult)
    end

    function XFubenActivityBranchManager.InitActivityInfo(activityId)
        activityId = activityId or XFubenActivityBranchConfigs.GetDefaultActivityId()
        if activityId == 0 then return end  --未配置活动信息
        local config = XFubenActivityBranchConfigs.GetActivityConfig(activityId)
        ActivityId = activityId
        BeginTime = CSXDateGetTime(config.BeginTimeStr)
        ChallengeBeginTime = CSXDateGetTime(config.ChallengeBeginTimeStr)
        FightEndTime = CSXDateGetTime(config.FightEndTimeStr)
        EndTime = CSXDateGetTime(config.EndTimeStr)
    end

    function XFubenActivityBranchManager.HandlerFightResult(stageId)
        XFubenActivityBranchManager.RefreshStagePassed()
    end

    function XFubenActivityBranchManager.GetActivitySections()
        local sections = {}

        if XFubenActivityBranchManager.IsOpen() then
            local section = {
                Type = XDataCenter.FubenManager.ChapterType.ActivtityBranch,
                Id = SectionId
            }
            tableInsert(sections, section)
        end

        return sections
    end

    function XFubenActivityBranchManager.InitStageInfo()
        local sectionCfgs = XFubenActivityBranchConfigs.GetSectionCfgs()

        for _, sectionCfg in pairs(sectionCfgs) do
            local normalChapterCfg = XFubenActivityBranchConfigs.GetChapterCfg(sectionCfg.NormalId)
            for _, stageId in pairs(normalChapterCfg.StageId) do
                local stageInfo = XDataCenter.FubenManager.GetStageInfo(stageId)
                stageInfo.Type = XDataCenter.FubenManager.StageType.ActivtityBranch
            end

            local difficultChapterCfg = XFubenActivityBranchConfigs.GetChapterCfg(sectionCfg.DifficultyId)
            for _, stageId in pairs(difficultChapterCfg.StageId) do
                local stageInfo = XDataCenter.FubenManager.GetStageInfo(stageId)
                stageInfo.Type = XDataCenter.FubenManager.StageType.ActivtityBranch
            end
        end
    end

    --刷新通关记录
    function XFubenActivityBranchManager.RefreshStagePassed()
        for chapterId, schedule in pairs(ScheduleDic) do
            local chapterCfg = XFubenActivityBranchConfigs.GetChapterCfg(chapterId)
            for index, stageId in pairs(chapterCfg.StageId) do
                local stageInfo = XDataCenter.FubenManager.GetStageInfo(stageId)
                if index <= schedule then
                    stageInfo.Passed = true
                else
                    stageInfo.Passed = false
                end

                if index <= schedule + 1 then
                    stageInfo.Unlock = true
                    stageInfo.IsOpen = true
                else
                    stageInfo.IsOpen = false
                end
            end
        end
    end

    function XFubenActivityBranchManager.SelectDifficult(selectDifficult)
        SelectDifficult = selectDifficult
    end

    function XFubenActivityBranchManager.IsSelectDifficult()
        return SelectDifficult
    end

    function XFubenActivityBranchManager.GetCurSectionId()
        return SectionId
    end

    function XFubenActivityBranchManager.GetCurChapterId(sectionId)
        local sectionCfg = XFubenActivityBranchConfigs.GetSectionCfg(sectionId)
        return XFubenActivityBranchManager.IsSelectDifficult() and sectionCfg.DifficultyId or sectionCfg.NormalId
    end

    function XFubenActivityBranchManager.GetChapterFinishCount(chapterId)
        return ScheduleDic[chapterId]
    end

    function XFubenActivityBranchManager.GetActivityBeginTime()
        return BeginTime
    end

    function XFubenActivityBranchManager.GetActivityChallengeBeginTime()
        return ChallengeBeginTime
    end

    function XFubenActivityBranchManager.GetFightEndTime()
        return FightEndTime
    end

    function XFubenActivityBranchManager.GetActivityEndTime()
        return EndTime
    end

    function XFubenActivityBranchManager.IsStatusEqualFightEnd()
        local now = XTime.Now()
        return FightEndTime <= now and now < EndTime
    end

    function XFubenActivityBranchManager.IsStatusEqualChallengeBegin()
        local now = XTime.Now()
        return ChallengeBeginTime <= now and now < EndTime
    end

    function XFubenActivityBranchManager.IsOpen()
        local nowTime = XTime.Now()
        return BeginTime <= nowTime and nowTime < EndTime and SectionId ~= 0
    end

    function XFubenActivityBranchManager.OnActivityEnd()
        if CS.XFight.IsRunning or XLuaUiManager.IsUiLoad("UiLoading") then
            return
        end
        XUiManager.TipText("ActivityBranchOver")
        XLuaUiManager.RunMain()
    end

    function XFubenActivityBranchManager.NotifyBranchData(data)
        SectionId = data.SectionId
        for _, branchChallengeInfo in pairs(data.ChallengeInfos) do
            ScheduleDic[branchChallengeInfo.Id] = branchChallengeInfo.Schedule
        end

        XFubenActivityBranchManager.InitActivityInfo(data.ActivityId)
        XFubenActivityBranchManager.RefreshStagePassed()
    end

    function XFubenActivityBranchManager.CheckActivityCondition(sectionId)
        local sectionCfg = XFubenActivityBranchConfigs.GetSectionCfg(sectionId)
        local chapterCfg = XFubenActivityBranchConfigs.GetChapterCfg(sectionCfg.DifficultyId)
        local conditionId = chapterCfg.OpenCondition
        if conditionId ~= 0 then
            return XConditionManager.CheckCondition(conditionId)
        end
        return true
    end

    XFubenActivityBranchManager.Init()
    return XFubenActivityBranchManager
end

XRpc.NotifyBranchData = function(data)
    XDataCenter.FubenActivityBranchManager.NotifyBranchData(data)
end
