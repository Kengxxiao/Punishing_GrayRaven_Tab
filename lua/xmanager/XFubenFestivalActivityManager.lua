XFubenFestivalActivityManagerCreator = function()

    local XFubenFestivalActivityManager = {}
    local FestivalInfos = {}

    local FestivalId2StageInfos = {}
    local FestivalStageType2StageInfos = {}
    local FestivalStageInfos = {}
    local FestivalStagePassCounts = {}

    XFubenFestivalActivityManager.StageFuben = 1    --战斗
    XFubenFestivalActivityManager.StageStory = 2    --剧情

    function XFubenFestivalActivityManager.Init()
        XEventManager.AddEventListener(XEventId.EVENT_PLAYER_LEVEL_CHANGE, XFubenFestivalActivityManager.RefreshStagePassed)
    end

    -- [初始化数据]
    function XFubenFestivalActivityManager.InitStageInfo()
        local festivalTemplates = XFestivalActivityConfig.GetFestivalsTemplates()
        for id, festivalTemplate in pairs(festivalTemplates or {}) do
            for _, stageId in pairs(festivalTemplate.StageId) do
                local stageInfo = XDataCenter.FubenManager.GetStageInfo(stageId)
                if stageInfo then
                    stageInfo.Type = XDataCenter.FubenManager.StageType.Festival
                end
            end
        end

        XFubenFestivalActivityManager.RefreshStagePassed()
    end

    -- [胜利]
    function XFubenFestivalActivityManager.ShowReward(winData)
        if not winData then return end
        XFubenFestivalActivityManager.RefreshStagePassedBySettleDatas(winData.SettleData)
        XLuaUiManager.Open("UiSettleWin", winData)
    end

    function XFubenFestivalActivityManager.RefreshStagePassedBySettleDatas(settleData)
        if not settleData then return end

        local festivalTemplates = XFestivalActivityConfig.GetFestivalsTemplates()
        local festivalId = 0
        for id, chapter in pairs(festivalTemplates) do
            for _, stageId in pairs(chapter.StageId) do
                if stageId == settleData.StageId then
                    festivalId = id
                    break
                end
            end
            if festivalId ~= 0 then
                if not FestivalId2StageInfos[festivalId] then
                    FestivalId2StageInfos[festivalId] = {}
                end
                FestivalId2StageInfos[festivalId][settleData.StageId] = true
                FestivalStageInfos[settleData.StageId] = true
                FestivalStagePassCounts[settleData.StageId] = (FestivalStagePassCounts[settleData.StageId] or 0) + 1
                XFubenFestivalActivityManager.RefreshStagePassed()
                XEventManager.DispatchEvent(XEventId.EVENT_ON_FESTIVAL_CHANGED)
                break
            end
        end
    end

    function XFubenFestivalActivityManager.RefreshStagePassed()
        local festivalTemplates = XFestivalActivityConfig.GetFestivalsTemplates()
        for id, festival in pairs(festivalTemplates) do
            for _, stageId in pairs(festival.StageId) do
                local stageInfo = XDataCenter.FubenManager.GetStageInfo(stageId)
                local stageCfg = XDataCenter.FubenManager.GetStageCfg(stageId)
                if stageInfo then
                    stageInfo.Passed = FestivalStageInfos[stageId] or false

                    stageInfo.Unlock = true
                    stageInfo.IsOpen = true

                    if stageCfg.RequireLevel > 0 and XPlayer.Level < stageCfg.RequireLevel then
                        stageInfo.Unlock = false
                        stageInfo.IsOpen = false
                    end
                    for k, prestageId in pairs(stageCfg.PreStageId or {}) do
                        if prestageId > 0 then
                            if not FestivalStageInfos[prestageId] then
                                stageInfo.Unlock = false
                                stageInfo.IsOpen = false
                                break
                            end
                        end
                    end

                end
            end
        end
    end

    -- 是否已经解锁
    function XFubenFestivalActivityManager.CheckFestivalStageOpen(stageId)
        local stageInfo = XDataCenter.FubenManager.GetStageInfo(stageId)
        local stageCfg = XDataCenter.FubenManager.GetStageCfg(stageId)
        if not stageInfo.Unlock then return false, CS.XTextManager.GetText("FubenNotUnlock") end

        if stageCfg.RequireLevel > 0 and XPlayer.Level < stageCfg.RequireLevel then
            return false, CS.XTextManager.GetText("TeamLevelToOpen", stageCfg.RequireLevel)
        end

        for _, conditionId in pairs(stageCfg.ForceConditionId or {}) do
            local ret, desc = XConditionManager.CheckCondition(conditionId)
            if not ret then
                return false, desc
            end
        end

        -- 如果是彩蛋关
        if XFubenFestivalActivityManager.IsEgg(stageId) then
            if stageInfo.Unlock and XDataCenter.FubenManager.GetUnlockHideStageById(stageId) then
                -- 彩蛋已经解锁
                return true, ""
            else
                -- 彩蛋未解锁
                return false, CS.XTextManager.GetText("FubenNotUnlock")
            end
        end

        return true, ""
    end

    -- 是否已经通关
    function XFubenFestivalActivityManager.GetFestivalStagePassed(stageId)
        return FestivalStageInfos[stageId]
    end

    -- 挑战次数
    function XFubenFestivalActivityManager.GetFestivalStageChallengeCount(stageId)
        return FestivalStagePassCounts[stageId] or 0
    end

    -- 获取关卡外观类型：剧情、战斗、彩蛋
    function XFubenFestivalActivityManager.GetStageShowType(stageId)
        local stageCfg = XDataCenter.FubenManager.GetStageCfg(stageId)
        if stageCfg == nil then
            return XFubenFestivalActivityManager.StageFuben
        end
        if stageCfg.StageType == XFubenConfigs.STAGETYPE_FIGHT or stageCfg.StageType == XFubenConfigs.STAGETYPE_FIGHTEGG then
            return XFubenFestivalActivityManager.StageFuben

        elseif stageCfg.StageType == XFubenConfigs.STAGETYPE_STORY or stageCfg.StageType == XFubenConfigs.STAGETYPE_STORYEGG then
            return XFubenFestivalActivityManager.StageStory

        else
            return XFubenFestivalActivityManager.StageFuben

        end
    end

    function XFubenFestivalActivityManager.IsFestivalAllPass(festivalId)
        local festival = XFestivalActivityConfig.GetFestivalById(festivalId)
        for _, stageId in pairs(festival.StageId) do
            if not FestivalStageInfos[stageId] then
                return false
            end
        end
        return true
    end

    -- 序号，表里填的序号
    function XFubenFestivalActivityManager.GetStageIndex(festivalId, stageId)
        local festival = XFestivalActivityConfig.GetFestivalById(festivalId)
        if not festival then return 0 end
        local hasEgg = XFubenFestivalActivityManager.IsEgg(festival.StageId[1])
        for _number, id in pairs(festival.StageId) do
            if id == stageId then
                return hasEgg and (_number - 1) or _number
            end
        end
        return 0
    end

    -- 是否是彩蛋
    function XFubenFestivalActivityManager.IsEgg(stageId)
        return XFubenFestivalActivityManager.IsStoryEgg(stageId) or XFubenFestivalActivityManager.IsFightEgg(stageId)
    end

    -- 是否是剧情彩蛋
    function XFubenFestivalActivityManager.IsStoryEgg(stageId)
        local stageCfg = XDataCenter.FubenManager.GetStageCfg(stageId)
        if stageCfg == nil then
            return false
        end
        return stageCfg.StageType == XFubenConfigs.STAGETYPE_STORYEGG
    end
    
    -- 是否是战斗彩蛋
    function XFubenFestivalActivityManager.IsFightEgg(stageId)
        local stageCfg = XDataCenter.FubenManager.GetStageCfg(stageId)
        if stageCfg == nil then
            return false
        end
        return stageCfg.StageType == XFubenConfigs.STAGETYPE_FIGHTEGG
    end

    -- 获取节日活动进度
    function XFubenFestivalActivityManager.GetFestivalProgress(festivalId)
        local festivalTemplate = XFestivalActivityConfig.GetFestivalById(festivalId)
        local totalCount = 0
        local finishCount = 0
        for k, stageId in pairs(festivalTemplate.StageId) do
            if not XFubenFestivalActivityManager.IsEgg(stageId) then
                totalCount = totalCount + 1
                if FestivalStageInfos[stageId] then
                    finishCount = finishCount + 1
                end
            end
        end
        return finishCount, totalCount
    end

    function XFubenFestivalActivityManager.GetAvaliableFestivals()
        local festivals = XFestivalActivityConfig.GetFestivalsTemplates()
        local activityList = {}
        local now = XTime.Now()
        for k, v in pairs(festivals) do

            local beginTimeSecond = CS.XDate.GetTime(v.BeginTimeStr)
            local endTimeSecond = CS.XDate.GetTime(v.EndTimeStr)
            if (not XFunctionManager.CheckFunctionFitter(XFunctionManager.FunctionName.FestivalActivity)) and now > beginTimeSecond and endTimeSecond > now then
                table.insert(activityList, {
                    Id = v.Id,
                    Type = v.ChapterType,
                    Name = v.Name,
                    Icon = v.BannerBg,
                })
            end
        end
        return activityList
    end

    function XFubenFestivalActivityManager.IsFestivalInActivity(festivalId)
        local festivalTemplate = XFestivalActivityConfig.GetFestivalById(festivalId)
        local now = XTime.Now()
        local beginTimeSecond = CS.XDate.GetTime(festivalTemplate.BeginTimeStr)
        local endTimeSecond = CS.XDate.GetTime(festivalTemplate.EndTimeStr)
        return now > beginTimeSecond and endTimeSecond > now
    end

     -- [播放剧情]
     function XFubenFestivalActivityManager.FinishStoryRequest(stageId, cb)
        XNetwork.Call("EnterStoryRequest", {StageId = stageId}, function(res)
            cb = cb or function() end
            if res.Code == XCode.Success then
                cb(res)
            else
                XUiManager.TipCode(res.Code)
            end
        end)
    end

    function XFubenFestivalActivityManager.OnAsyncFestivalStages(response)
        if not response then return end
        for k, info in pairs(response.FestivalInfos or {}) do

            local festivalTemplate = XFestivalActivityConfig.GetFestivalById(info.Id)

            FestivalId2StageInfos[info.Id] = FestivalId2StageInfos[info.Id] or {}
            for k, stageInfos in pairs(info.StageInfos or {}) do
                FestivalId2StageInfos[info.Id][stageInfos.Id] = true
                FestivalStageInfos[stageInfos.Id] = true

                FestivalStagePassCounts[stageInfos.Id] = stageInfos.ChallengeCount
            end
        end

        XFubenFestivalActivityManager.RefreshStagePassed()
    end

    XFubenFestivalActivityManager.Init()
    return XFubenFestivalActivityManager
end

XRpc.NotifyFestivalData = function(response)
    XDataCenter.FubenFestivalActivityManager.OnAsyncFestivalStages(response)
end