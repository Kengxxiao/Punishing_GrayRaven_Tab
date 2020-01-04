XPrequelManagerCreator = function()
    local XPrequelManager = {}

    local UnlockChallengeStages = {}
    local RewardedStages = {}
    local NextCheckPoint = nil
    -- manager层
    local Cover2ChapterMap = {}--记录上一个封面
    local CoverPrefix = "CoverPrefix"
    local Stage2ChapterMap = {}

    function XPrequelManager.InitPrequelData(fubenPrequelData)
        if not fubenPrequelData then return end
        for k, v in pairs(fubenPrequelData.RewardedStages or {}) do
            RewardedStages[v] = true
        end
        for k, v in pairs(fubenPrequelData.UnlockChallengeStages or {}) do
            UnlockChallengeStages[v.StageId] = v
        end
    end

    function XPrequelManager.SaveCoverChapterHint(key, value)
        if XPlayer.Id then
            key = string.format("%s_%s", tostring(XPlayer.Id), key)
            CS.UnityEngine.PlayerPrefs.SetInt(key, value)
            CS.UnityEngine.PlayerPrefs.Save()
        end
    end

    function XPrequelManager.GetCoverChapterHint(key, defaultValue)
        if XPlayer.Id then
            key = string.format("%s_%s", tostring(XPlayer.Id), key)
            if CS.UnityEngine.PlayerPrefs.HasKey(key) then
                local newPlayerHint = CS.UnityEngine.PlayerPrefs.GetInt(key)
                return (newPlayerHint == nil or newPlayerHint == 0) and defaultValue or newPlayerHint
            end
        end
        return defaultValue
    end

    function XPrequelManager.InitStageInfo()
        for chapterId, chapterCfg in pairs(XPrequelConfigs.GetPequelAllChapter() or {}) do
            for _, stageId in pairs(chapterCfg.StageId or {}) do
                Stage2ChapterMap[stageId] = chapterId
                local stageInfo = XDataCenter.FubenManager.GetStageInfo(stageId)
                if stageInfo then
                    stageInfo.Type = XDataCenter.FubenManager.StageType.Prequel
                end
            end
        end

        for coverId, coverCfg in pairs(XPrequelConfigs.GetPrequelCoverList() or {}) do
            for _, stageId in pairs(coverCfg.ChallengeStage or {}) do
                local stageInfo = XDataCenter.FubenManager.GetStageInfo(stageId)
                if stageInfo then
                    stageInfo.Type = XDataCenter.FubenManager.StageType.Prequel
                end
            end
        end
    end

    -- [更新封面显示的chapter]
    function XPrequelManager.UpdateShowChapter(stageId)
        if not stageId then return end
        local chapterId = XPrequelConfigs.GetChapterByStageId(stageId)
        if not chapterId then return end
        local coverId = XPrequelConfigs.GetCoverByChapterId(chapterId)
        if not coverId then return end
        local key = string.format( "%s%s", CoverPrefix, tostring(coverId))
        XPrequelManager.SaveCoverChapterHint(key, chapterId)
        Cover2ChapterMap[coverId] = chapterId
    end

    function XPrequelManager.ShowReward(winData)
        XLuaUiManager.Open("UiSettleWin", winData)
    end

    -- [获取已经解锁的挑战关卡，nil代表未解锁]
    function XPrequelManager.GetUnlockChallengeStagesByStageId(stageId)
        return UnlockChallengeStages[stageId]
    end

    -- [解锁挑战]
    function XPrequelManager.UnlockPrequelChallengeRequest(coverId, challengeIdx, stageId, cb)
        XNetwork.Call("UnlockPrequelChallengeRequest", {CoverId = coverId, ChallengeId = challengeIdx}, function(res)
            cb = cb or function() end
            if res.Code == XCode.Success then
                UnlockChallengeStages[stageId] = res.ChallengeStage
                cb(res)
            else
                XUiManager.TipCode(res.Code)
            end
        end)
    end
    -- [前传奖励领取]
    function XPrequelManager.ReceivePrequelRewardRequest(stageId, cb)
        XNetwork.Call("ReceivePrequelRewardRequest", {StageId = stageId}, function(res)
            cb = cb or function() end
            if res.Code == XCode.Success then
                RewardedStages[res.StageId] = true
                -- 显示奖励
                local stageCfg = XDataCenter.FubenManager.GetStageCfg(stageId)
                local rewardId = stageCfg.FirstRewardShow
                local rewardList = XRewardManager.GetRewardList(rewardId)
                XUiManager.OpenUiObtain(res.RewardGoodsList, CS.XTextManager.GetText("DailyActiveRewardTitle"))
                cb(res)
            else
                XUiManager.TipCode(res.Code)
            end
        end)
    end

    -- [剧情]
    function XPrequelManager.FinishStoryRequest(stageId, cb)
        XNetwork.Call("EnterStoryRequest", {StageId = stageId}, function(res)
            cb = cb or function() end
            if res.Code == XCode.Success then
                cb(res)
            else
                XUiManager.TipCode(res.Code)
            end
        end)
    end

    function XPrequelManager.GetRewardedStages()
        return RewardedStages
    end

    function XPrequelManager.IsRewardStageCollected(stageId)
        return RewardedStages[stageId]
    end

    function XPrequelManager.IsStoryStage(stageId)
        local stageCfg = XDataCenter.FubenManager.GetStageCfg(stageId)
        if not stageCfg then return false end
        return stageCfg.StageType == XFubenConfigs.STAGETYPE_STORYEGG
    end

    -- [服务器同步领取奖励的剧情关卡数据]
    function XPrequelManager.OnSyncRewardedStage(response)
        for k, v in pairs(response.RewardedStages or {}) do
            RewardedStages[v] = true
        end
    end

    -- [服务器同步解锁的挑战关卡数据]
    function XPrequelManager.OnSyncUnlockChallengeStage(response)
        UnlockChallengeStages = response.UnlockChallengeStages
        XEventManager.DispatchEvent(XEventId.EVENT_NOTICE_CHALLENGESTAGES_CHANGE)
    end

    function XPrequelManager.OnSyncSingleUnlockChallengeStage(response)
        local currentStage = response.ChallengeStage
        UnlockChallengeStages[currentStage.StageId] = currentStage
        XEventManager.DispatchEvent(XEventId.EVENT_NOTICE_CHALLENGESTAGES_CHANGE)
    end

    -- [刷新时间-需要通知界面及时更新]
    function XPrequelManager.OnSyncNextRefreshTime(response)
        NextCheckPoint = response.NextRefreshTime
        XEventManager.DispatchEvent(XEventId.EVENT_NOTICE_REFRESHTIME_CHANGE)
    end

    -- [判断解锁条件]
    function XPrequelManager.CheckPrequelStageOpen(stageId)
        local stageCfg = XDataCenter.FubenManager.GetStageCfg(stageId)
        local stageInfo = XDataCenter.FubenManager.GetStageInfo(stageId)
        local isUnlock = stageInfo.Unlock
        if stageInfo.Unlock then
            for _, conditionId in pairs(stageCfg.ForceConditionId or {}) do
                local rect, _ = XConditionManager.CheckCondition(conditionId)
                if not rect then
                    return rect
                end
            end
        end
        if stageCfg.StageType == XFubenConfigs.STAGETYPE_STORYEGG or stageCfg.StageType == XFubenConfigs.STAGETYPE_FIGHTEGG then
            return isUnlock and XDataCenter.FubenManager.GetUnlockHideStageById(stageId)
        end
        return isUnlock
    end

    function XPrequelManager.GetCoverUnlockDescription(coverId)
        local coverInfos = XPrequelConfigs.GetPrequelCoverById(coverId)
        local chapterIds = coverInfos.ChapterId

        for _, chapterId in pairs(chapterIds or {}) do
            local chapterInfo = XPrequelConfigs.GetPrequelChapterById(chapterId)
            for k, openConditoinId in pairs(chapterInfo.OpenCondition or {}) do
                local rect, desc = XConditionManager.CheckCondition(openConditoinId)
                if not rect then
                    return desc
                end
            end
        end
        return ""
    end

    -- 检查章节开启条件
    function XPrequelManager.GetChapterUnlockDescription(chapterId)
        local chapterTemplate = XPrequelConfigs.GetPrequelChapterById(chapterId)
        -- 如果处于活动，优先判断活动的Condition
         local inActivity = XPrequelManager.IsChapterInActivity(chapterId)
         if chapterTemplate.ActivityCondition ~= 0 and inActivity then
            local rect, desc = XConditionManager.CheckCondition(chapterTemplate.ActivityCondition)
            if not rect then
                return desc
            end
            return nil
         end

        for k, openConditoinId in pairs(chapterTemplate.OpenCondition or {}) do
            local rect, desc = XConditionManager.CheckCondition(openConditoinId)
            if not rect then
                return desc
            end
        end
    end

    -- [进度]
    function XPrequelManager.GetChapterProgress(chapterId)
        local chapterInfos = XPrequelConfigs.GetPrequelChapterById(chapterId)
        local total = 0
        local finishedStageNum = 0
        for _, stageId in pairs(chapterInfos.StageId or {}) do
            local stageInfo = XDataCenter.FubenManager.GetStageInfo(stageId)
            local stageCfg = XDataCenter.FubenManager.GetStageCfg(stageId)
            if stageCfg.StageType ~= XFubenConfigs.STAGETYPE_STORYEGG and stageCfg.StageType ~= XFubenConfigs.STAGETYPE_FIGHTEGG then
                total = total + 1
                if stageInfo.Passed then
                    finishedStageNum = finishedStageNum + 1
                end
            end
        end
        return finishedStageNum, total
    end

    -- [寻找一个可以使用的章节]
    function XPrequelManager.GetSelectableChaperIndex(cover)
        local showChapter = cover.ShowChapter
        local defaultChapter = 1
        local hasDefault = false
        for index, chapterId in pairs(cover.CoverVal.ChapterId or {}) do
            if not XPrequelManager.GetChapterLockStatus(chapterId) then
                if showChapter and showChapter == chapterId then
                    return index
                end
                if not hasDefault then
                    hasDefault = true
                    defaultChapter = index
                end
            end
        end
        return defaultChapter
    end

    function XPrequelManager.GetIndexByChapterId(cover, chapterId)
        if not chapterId then return nil end
        local index = nil
        for i, id in pairs(cover.CoverVal.ChapterId or {}) do
            if not XPrequelManager.GetChapterLockStatus(id) then
                if chapterId == id then
                    return i
                end
            end
        end
        return index
    end

    -- [获取章节锁定状态]
    function XPrequelManager.GetChapterLockStatus(chapterId)
        local chapterInfo = XPrequelConfigs.GetPrequelChapterById(chapterId)
        for _, conditionId in pairs(chapterInfo.OpenCondition or {}) do
            local rect, _ = XConditionManager.CheckCondition(conditionId)
            if not rect then
                return true
            end
        end
        return false
    end

    -- [章节是否处于活动中]
    function XPrequelManager.IsInActivity()
        local chapters = XPrequelConfigs.GetPequelAllChapter()

        for chapterId in pairs(chapters) do
            if XPrequelManager.IsChapterInActivity(chapterId) then
                return true
            end
        end

        return false
    end

    -- [是否有章节处于活动中]
    function XPrequelManager.IsChapterInActivity(chapterId)
        local currentTime = XTime.Now()
        local chapterInfo = XPrequelConfigs.GetPrequelChapterById(chapterId)
        if chapterInfo.ActivityBegin and chapterInfo.ActivityEnd then
            local activityBeginTime = CS.XDate.GetTime(chapterInfo.ActivityBegin)
            local activityEndTime = CS.XDate.GetTime(chapterInfo.ActivityEnd)
            if currentTime >= activityBeginTime and currentTime <= activityEndTime then
                return true
            end
        end
        return false
    end

    -- 支线奖励
    function XPrequelManager.CheckRewardAvaliable(chapterId)
        local chapterInfos = XPrequelConfigs.GetPrequelChapterById(chapterId)
        local rewardedStages = XPrequelManager.GetRewardedStages()
        for _, stageId in pairs(chapterInfos.StageId or {}) do
            local stageCfg = XDataCenter.FubenManager.GetStageCfg(stageId)
            local stageInfo = XDataCenter.FubenManager.GetStageInfo(stageId)
            if stageCfg.FirstRewardShow > 0 and stageInfo.Passed and rewardedStages and (not rewardedStages[stageId]) then
                return true
            end
        end
        return false
    end

    function XPrequelManager.GetListCovers()
        local coverList = {}
        for k, v in pairs(XPrequelConfigs.GetPrequelCoverList() or {}) do
            local showChapter, isActivity, isAllChapterLock, isActivityNotOpen = XPrequelManager.GetPriorityChapter(v.ChapterId, k)
            local chapterWeight = 0
            if isActivity then
                chapterWeight = 4
            else
                if isAllChapterLock == false then
                    chapterWeight = 3
                end
                if isActivityNotOpen then
                    chapterWeight = 2
                end
            end
            table.insert(coverList, {
                CoverId = k,
                CoverVal = v,
                ShowChapter = showChapter,
                IsActivity = isActivity,
                IsAllChapterLock = isAllChapterLock,
                IsActivityNotOpen = isActivityNotOpen,
                ChapterWeight = chapterWeight,
            })
        end
        table.sort(coverList, function(coverA, coverB)
            local coverAWeight = coverA.ChapterWeight
            local coverBWeight = coverB.ChapterWeight
            if coverAWeight == coverBWeight then
                return coverA.CoverVal.Priority < coverB.CoverVal.Priority
            end
            return coverAWeight > coverBWeight
        end)
        return coverList
    end

    function XPrequelManager.GetPriorityChapter(chapters, coverId)
        local currentChapter = chapters[1]
        local currentPriority = 0
        local isActivity = false
        local isActivityNotOpen = false
        local isAllChapterLock = true
        for k, chapterId in pairs(chapters or {}) do
            local chapterInfo = XPrequelConfigs.GetPrequelChapterById(chapterId)
            if chapterInfo.ActivityBegin and chapterInfo.ActivityEnd then
                local currentTime = XTime.Now()
                local activityBeginTime = CS.XDate.GetTime(chapterInfo.ActivityBegin)
                local activityEndTime = CS.XDate.GetTime(chapterInfo.ActivityEnd)
                if currentTime >= activityBeginTime and currentTime <= activityEndTime and currentPriority < chapterInfo.Priority then
                    isActivityNotOpen = true
                    if chapterInfo.ActivityCondition > 0 and XConditionManager.CheckCondition(chapterInfo.ActivityCondition) then
                        currentChapter = chapterId
                        currentPriority = chapterInfo.Priority
                        isActivity = true
                        isActivityNotOpen = false
                    end
                end
            end

            for _, conditionId in pairs(chapterInfo.OpenCondition or {}) do
                local rect, _ = XConditionManager.CheckCondition(conditionId)
                if rect then
                    isAllChapterLock = false
                end
            end
        end
        -- [寻找一个正确的显示在封面的章节]
        if (not isAllChapterLock) and (not isActivity) then
            for k, chapterId in pairs(chapters or {}) do
                if not XDataCenter.PrequelManager.GetChapterLockStatus(chapterId) then
                    currentChapter = chapterId
                    break
                end
            end
        end

        -- 优先显示上一次打过的章节
        if not Cover2ChapterMap[coverId] then
            local key = string.format("%s%s", CoverPrefix, tostring(coverId))
            local recordChapter = XPrequelManager.GetCoverChapterHint(key, currentChapter)
            local isRecordChapterInActivity = XPrequelManager.IsChapterInActivity(recordChapter)
            local recordChapterDescription = XPrequelManager.GetChapterUnlockDescription(recordChapter)
            if isRecordChapterInActivity then
                currentChapter = recordChapter
            else
                if recordChapterDescription == nil then
                    currentChapter = recordChapter
                end
            end
        elseif Cover2ChapterMap[coverId] and Cover2ChapterMap[coverId] ~= currentChapter then
            local recordChapter = Cover2ChapterMap[coverId]
            local recordChapterDescription = XPrequelManager.GetChapterUnlockDescription(recordChapter)
            local isRecordChapterInActivity = XPrequelManager.IsChapterInActivity(recordChapter)
            if isRecordChapterInActivity then
                currentChapter = Cover2ChapterMap[coverId]
            else
                if recordChapterDescription == nil then
                    currentChapter = recordChapter
                end
            end
        end

        return currentChapter, isActivity, isAllChapterLock, isActivityNotOpen
    end

    function XPrequelManager.GetNextCheckPointTime()
        return NextCheckPoint
    end

    function XPrequelManager.GetChapterIdByStageId(stageId)
        return Stage2ChapterMap[stageId]
    end

    return XPrequelManager
end

XRpc.NotifyFubenPrequelData = function (response)
    if not response then return end
    XDataCenter.PrequelManager.InitPrequelData(response.FubenPrequelData)
end

-- [领取奖励]
XRpc.NotifyPrequelRewardedStages = function(response)
    if not response then return end
    XDataCenter.PrequelManager.OnSyncRewardedStage(response)
end

-- [解锁挑战关卡回复]
XRpc.NotifyPrequelUnlockChallengeStages = function(response)
    if not response then return end
    XDataCenter.PrequelManager.OnSyncUnlockChallengeStage(response)
end

XRpc.NotifyPrequelChallengeStage = function(response)
    if not response then return end
    XDataCenter.PrequelManager.OnSyncSingleUnlockChallengeStage(response)
end

-- [下一个刷新时间]
XRpc.NotifyPrequelChallengeRefreshTime = function(response)
    if not response then return end
    XDataCenter.PrequelManager.OnSyncNextRefreshTime(response)
end