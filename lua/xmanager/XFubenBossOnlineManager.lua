XFubenBossOnlineManagerCreator = function()

    local XFubenBossOnlineManager = {}

    XFubenBossOnlineManager.OnlineBossDifficultLevel = {
        SIMPLE = 1,
        NORMAL = 2,
        HARD = 3,
        HELL = 4
    }

    local METHOD_NAME = {
        GetActivityBossDataRequest = "GetActivityBossDataRequest"
    }

    local TABLE_FUBEN_ONLINEBOSS_SECTION = "Share/Fuben/BossOnline/BossOnlineSection.tab"
    local TABLE_FUBEN_ONLINEBOSS_CHAPTER = "Share/Fuben/BossOnline/BossOnlineChapter.tab"
    local TABLE_FUBEN_ONLINEBOSS_RISK = "Share/Fuben/BossOnline/BossOnlineRisk.tab"
    local IsActivity
    local BossDataList
    local OnlineLelfTime --联机Boss刷新时间
    local OnlineBeginTime
    local OnlineBossSectionTemplates = {}
    local OnlineBossChapterTemplates = {}
    local OnlineBossRiskTemplates = {}
    local NormalChapterId
    local ActivityChapterId
    local LastRequestTime = 0
    local RequestInterval = 30

    function XFubenBossOnlineManager.Init()
        OnlineBossChapterTemplates = XTableManager.ReadByIntKey(TABLE_FUBEN_ONLINEBOSS_CHAPTER, XTable.XTableBossOnlineChapter, "Id")
        OnlineBossSectionTemplates = XTableManager.ReadByIntKey(TABLE_FUBEN_ONLINEBOSS_SECTION, XTable.XTableBossOnlineSection, "Id")
        OnlineBossRiskTemplates = XTableManager.ReadByIntKey(TABLE_FUBEN_ONLINEBOSS_RISK, XTable.XTableBossOnlineRisk, "Id")
        NormalChapterId = CS.XGame.Config:GetInt("OnlineBossNormalChapterId")
        ActivityChapterId = CS.XGame.Config:GetInt("OnlineBossActivityChapterId")
    end

    function XFubenBossOnlineManager.GetRiskTemplate(count)
        for _, v in pairs(OnlineBossRiskTemplates) do
            if (v.MinCount <= 0 or count >= v.MinCount) and (v.MaxCount <= 0 or count <= v.MaxCount) then
                return v
            end
        end
    end

    function XFubenBossOnlineManager.GetBossOnlineChapters()
        if not BossDataList then
            return {}
        end
        local list = {}
        local chapterId = IsActivity and ActivityChapterId or NormalChapterId
        for k, v in pairs(OnlineBossChapterTemplates) do
            if k == chapterId then
                table.insert(list, v)
            end
        end
        table.sort(list, function(a, b)
            return a.Id < b.Id
        end)
        return list
    end

    function XFubenBossOnlineManager.UpdateStageUnlock(stageId, diff)
        local stageInfo = XDataCenter.FubenManager.GetStageInfo(stageId)
        local stageCfg = XDataCenter.FubenManager.GetStageCfg(stageId)
        stageInfo.Unlock = false
        stageInfo.IsOpen = false
        if stageCfg.RequireLevel > 0 and XPlayer.Level < stageCfg.RequireLevel then
            return
        end

        if diff > 1 then
            for k, v in pairs(OnlineBossSectionTemplates) do
                if v.DifficultType == diff - 1 then
                    local preStageInfo = XDataCenter.FubenManager.GetStageInfo(v.StageId)
                    if preStageInfo.Passed then
                        stageInfo.Unlock = true
                        stageInfo.IsOpen = true
                        return
                    end
                end
            end
        else
            stageInfo.Unlock = true
            stageInfo.IsOpen = true
        end
    end

    function XFubenBossOnlineManager.InitStageInfo()
        for sectionId, sectionCfg in pairs(OnlineBossSectionTemplates) do
            local stageInfo = XDataCenter.FubenManager.GetStageInfo(sectionCfg.StageId)
            stageInfo.BossSectionId = sectionCfg.Id
            stageInfo.Type = XDataCenter.FubenManager.StageType.BossOnline
            stageInfo.Difficult = sectionCfg.DifficultType
            XFubenBossOnlineManager.UpdateStageUnlock(sectionCfg.StageId, sectionCfg.DifficultType)
        end
    end

    function XFubenBossOnlineManager.CheckAutoExitFight()
        return true
    end

    function XFubenBossOnlineManager.OpenFightLoading(stageId)
        XLuaUiManager.Open("UiOnLineLoading")
    end

    function XFubenBossOnlineManager.CloseFightLoading(stageId)
        XLuaUiManager.Remove("UiOnLineLoading")
    end

    function XFubenBossOnlineManager.ShowReward(winData)
        -- XEventManager.DispatchEvent(XEventId.EVENT_FUBEN_SHOW_REWARD, winData)
        -- XLuaUiManager.Open("UiSettleWin", winData)
        if XDataCenter.FubenManager.CheckHasFlopReward(winData) then
            XLuaUiManager.Open("UiFubenFlopReward", function()
                XLuaUiManager.PopThenOpen("UiMultiplayerFightGrade", function ()
                    XLuaUiManager.PopThenOpen("UiSettleWin", winData)
                end)
            end, winData)
            if XDataCenter.FubenManager.CheckHasFlopReward(winData, true) and not XDataCenter.FubenManager.CheckCanFlop(winData.StageId) then
                XUiManager.TipText("BossOnlineConsumeFinish", XUiManager.UiTipType.Success)
            end
        else
            XLuaUiManager.Open("UiMultiplayerFightGrade", function ()
                XLuaUiManager.PopThenOpen("UiSettleWin", winData)
            end)
        end
    end

    function XFubenBossOnlineManager.CheckIsInvade()
        local key = "OnlineBossBeginTime_" .. XPlayer.Id
        local time = XSaveTool.GetData(key)
        return OnlineBeginTime == time
    end

    function XFubenBossOnlineManager.RecordInvade()
        local key = "OnlineBossBeginTime_" .. XPlayer.Id
        XSaveTool.SaveData(key, OnlineBeginTime)
    end

    function XFubenBossOnlineManager.GetActOnlineBossSectionForDiff(difficult)
        if not BossDataList then
            return
        end

        for k, v in pairs(BossDataList) do
            if v.DifficultyType == difficult then
                return v
            end
        end
    end

    function XFubenBossOnlineManager.GetStageIdByDiff(difficult)
        for k, v in pairs(OnlineBossSectionTemplates) do
            if v.DifficultType == difficult then
                return v.StageId
            end
        end
        return 0
    end

    function XFubenBossOnlineManager.GetActOnlineBossSectionById(secitonId, useLastTemplate)
        if useLastTemplate then
            local tmp = OnlineBossSectionTemplates[secitonId]
            return OnlineBossSectionTemplates[tmp.LastSectionId]
        end
        return OnlineBossSectionTemplates[secitonId]
    end

    function XFubenBossOnlineManager.GetBossDataList()
        return BossDataList
    end

    function XFubenBossOnlineManager.GetIsActivity()
        return IsActivity
    end

    function XFubenBossOnlineManager.CheckBossDataCorrect()
        if not BossDataList then
            XLog.Error("XFubenBossOnlineManager.CheckBossDataCorrect error, BossDataList is nil")
            return false
        end
        for k, v in pairs(BossDataList) do
            if not OnlineBossSectionTemplates[v.BossId] then
                XLog.Error("XFubenBossOnlineManager.CheckBossDataCorrect error, section id not found:" .. v.BossId)
                return false
            end
        end
        return true
    end

    function XFubenBossOnlineManager.OnRefreshBossData(data)
        local oldBeginTime = OnlineBeginTime
        IsActivity = data.Activity == 1
        OnlineBeginTime = data.BeginTime
        OnlineLelfTime = data.LeftTime + XTime.Now()
        BossDataList = data.BossDataList
        if oldBeginTime == OnlineBeginTime then
            XEventManager.DispatchEvent(XEventId.EVENT_ONLINEBOSS_UPDATE)
        else
            XEventManager.DispatchEvent(XEventId.EVENT_ONLINEBOSS_REFRESH)
        end
    end

    -- 获取联机BOSS信息
    function XFubenBossOnlineManager.RequsetGetBossDataList(cb)
        LastRequestTime = XTime.Now()
        XNetwork.Call(METHOD_NAME.GetActivityBossDataRequest, nil, function(reply)
            if reply.Code ~= XCode.Success then
                XUiManager.TipCode(reply.Code)
                return
            end
            XFubenBossOnlineManager.OnRefreshBossData(reply)
            if cb then
                cb()
            end
        end)
    end

    function XFubenBossOnlineManager.RefreshBossData(cb)
        if not XFubenBossOnlineManager.BossDataList or
        XFubenBossOnlineManager.CheckOnlineBossTimeOut() or
        XTime.Now() - LastRequestTime > RequestInterval then
            XFubenBossOnlineManager.RequsetGetBossDataList(cb)
        else
            if cb then
                cb()
            end
        end
    end

    function XFubenBossOnlineManager.GetOnlineBossUpdateTime()
        return OnlineLelfTime
    end

    --检测boss是否已经更新
    function XFubenBossOnlineManager.CheckOnlineBossTimeOut()
        if OnlineLelfTime == nil then
            return false
        end
        local curTime = XTime.Now()
        local offset = OnlineLelfTime - curTime
        return offset <= 0
    end

    --检测前置条件
    function XFubenBossOnlineManager.CheckOnlineBossUnlock(diffcult, needTips)
        if not BossDataList then
            return false
        end

        local bossData = XFubenBossOnlineManager.GetActOnlineBossSectionForDiff(diffcult)
        if not bossData then
            return false
        end

        local boSection = XFubenBossOnlineManager.GetActOnlineBossSectionById(bossData.BossId)
        if not boSection then
            return false
        end

        local stageCfg = XDataCenter.FubenManager.GetStageCfg(boSection.StageId)
        local stageInfo = XDataCenter.FubenManager.GetStageInfo(stageCfg.StageId)

        if needTips then
            if not stageInfo.Unlock then
                XUiManager.TipMsg(XDataCenter.FubenManager.GetFubenOpenTips(stageCfg.StageId, CS.XTextManager.GetText("BossOnlineNotUnlock")))
            end
        end

        return stageInfo.Unlock
    end

    function XFubenBossOnlineManager.GetFlopConsumeItemCount()
        local template
        for k, v in pairs(OnlineBossSectionTemplates) do
            template = v
            break
        end
        if not template then
            return 0
        end
        local itemId = XDataCenter.FubenManager.GetFlopConsumeItemId(template.StageId)
        local item = XDataCenter.ItemManager.GetItem(itemId)
        return item and item:GetCount() or 0
    end

    function XFubenBossOnlineManager.OpenBossOnlineUi(selectIdx)
        XFubenBossOnlineManager.RefreshBossData(function()
            if not XDataCenter.FubenBossOnlineManager.CheckBossDataCorrect() then
                return
            end
            local isActivity = XFubenBossOnlineManager.GetIsActivity()
            if isActivity and XFubenBossOnlineManager.CheckIsInvade() then
                XLuaUiManager.Open("UiOnlineBossActivity", selectIdx)
            else
                XLuaUiManager.Open("UiOnlineBoss", selectIdx)
            end
        end)
    end

    function XFubenBossOnlineManager.OnActivityEnd()
        BossDataList = nil
        XFubenBossOnlineManager.RequsetGetBossDataList()
        if CS.XFight.IsRunning or XLuaUiManager.IsUiLoad("UiLoading") then
            return
        end
        XUiManager.TipText("ActivityBossOnlineOver")
        XLuaUiManager.RunMain()
    end

    XFubenBossOnlineManager.Init()
    return XFubenBossOnlineManager
end

XRpc.NotifyBossOnlineActivityStatus = function(data)
    XDataCenter.FubenBossOnlineManager.OnRefreshBossData(data)
end