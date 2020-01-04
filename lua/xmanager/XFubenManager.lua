XFubenManagerCreator = function()
    local Json = require("XCommon/Json")
    local XFubenManager = {}
    XFubenManager.StageType = {
        Mainline = 1,
        Daily = 2,
        Tower = 3,
        Urgent = 4,
        BossSingle = 5,
        BossOnline = 6,
        Bfrt = 7,
        Resource = 8,
        BountyTask = 9,
        Trial = 10,
        Prequel = 11,
        Arena = 12,
        Experiment = 13, --试验区
        Explore = 14, --探索玩法关卡
        ActivtityBranch = 15, --活动支线副本
        ActivityBossSingle = 16, --活动单挑BOSS
        Practice = 17, --教学关卡
        Festival = 18, --节日副本
    }

    XFubenManager.ChapterType = {
        TOWER = 1,
        YSHTX = 2,
        EMEX = 3,
        DJHGZD = 4,
        BOSSSINGLE = 5,
        Urgent = 6,
        BossOnline = 7,
        Resource = 8,
        Trial = 9,
        ARENA = 10,
        Explore = 11, --探索
        ActivtityBranch = 12, --活动支线副本
        ActivityBossSingle = 13, --活动单挑BOSS
        Practice = 14, --教学关卡
        GZTX = 15, --日常構造體特訓
        XYZB = 16, --日常稀有裝備
        TPCL = 17, --日常突破材料
        ZBJY = 18, --日常裝備經驗
        LMDZ = 19, --日常螺母大戰
        JNQH = 20, --日常技能强化
        Christmas = 21, --节日活动-圣诞节
        BriefDarkStream = 22, --活动-极地暗流
    }

    XFubenManager.ModeType = {
        SINGLE = 1,
        MULTI = 2,
    }

    XFubenManager.ChapterFunctionName = {
        [XFubenManager.ChapterType.Trial] = XFunctionManager.FunctionName.FubenChallengeTrial,
        [XFubenManager.ChapterType.Explore] = XFunctionManager.FunctionName.FubenExplore,
        [XFubenManager.ChapterType.Practice] = XFunctionManager.FunctionName.Practice,
        [XFubenManager.ChapterType.ARENA] = XFunctionManager.FunctionName.FubenArena,
        [XFubenManager.ChapterType.BOSSSINGLE] = XFunctionManager.FunctionName.FubenChallengeBossSingle,
    }

    local StageCfg = {}
    local StageTransformCfg = {}
    local StageLevelControlCfg = {}
    local FlopRewardTemplates = {}
    local StageLevelMap = {}
    local StageMultiplayerLevelMap = {}

    local RefreshTime = 0
    local PlayerStageData = {}
    local AssistSuccess = false
    local UnlockHideStages = {}

    local EnterFightStartTime = 0

    -- CheckPreFight function
    local InitStageInfoHandler = {}
    local CheckPreFightHandler = {}
    local OpenFightLoadingHandler = {}
    local CloseFightLoadingHandler = {}
    local SettleFightHandler = {}
    local ShowSummaryHandler = {}
    local FinishFightHandler = {}
    local ShowRewardHandler = {}
    local CheckReadyToFightHandler = {}
    local CheckAutoExitFightHandler = {}
    local GetArnaChaptaerNameHandler = {}
    local StageInfos = {}

    local METHOD_NAME = {
        PreFight = "PreFightRequest",
        FightSettle = "FightSettleRequest",
        FightWin = "FightWinRequest",
        FightLose = "FightLoseRequest",
        BuyActionPoint = "BuyActionPointRequest",
        RefreshFubenList = "RefreshFubenListRequest",
        EnterChallenge = "EnterChallengeRequest",
        CheckChallengeCanEnter = "CheckChallengeCanEnterRequest",
        GetTowerInfo = "GetTowerInfoRequest",
        GetTowerRecommendedList = "GetTowerRecommendedListRequest",
        GetTowerChapterReward = "GetTowerChapterRewardRequest",
        CheckResetTower = "CheckResetTowerRequest",
        GuideComplete = "GuideCompleteRequest",
        GetFightData = "GetFightDataRequest",
        BOGetBossDataRequest = "BOGetBossDataRequest",
        FightReboot = "FightRebootRequest"
    }

    function XFubenManager.Init()
        StageCfg = XFubenConfigs.GetStageCfg()
        StageLevelControlCfg = XFubenConfigs.GetStageLevelControlCfg()
        StageTransformCfg = XFubenConfigs.GetStageTransformCfg()
        FlopRewardTemplates = XFubenConfigs.GetFlopRewardTemplates()

        XFubenManager.DifficultNormal = CS.XGame.Config:GetInt("FubenDifficultNormal")
        XFubenManager.DifficultHard = CS.XGame.Config:GetInt("FubenDifficultHard")
        XFubenManager.DifficultNightmare = CS.XGame.Config:GetInt("FubenDifficultNightmare")
        XFubenManager.StageStarNum = CS.XGame.Config:GetInt("FubenStageStarNum")
        XFubenManager.NotGetTreasure = CS.XGame.Config:GetInt("FubenNotGetTreasure")
        XFubenManager.GetTreasure = CS.XGame.Config:GetInt("FubenGetTreasure")
        XFubenManager.FubenFlopCount = CS.XGame.Config:GetInt("FubenFlopCount")

        XFubenManager.SettleRewardAnimationDelay = CS.XGame.ClientConfig:GetInt("SettleRewardAnimationDelay")
        XFubenManager.SettleRewardAnimationInterval = CS.XGame.ClientConfig:GetInt("SettleRewardAnimationInterval")

        XEventManager.AddEventListener(XEventId.EVENT_PLAYER_LEVEL_CHANGE, XFubenManager.InitData)

        XFubenManager.RegisterFubenManager(XFubenManager.StageType.Mainline, XDataCenter.FubenMainLineManager)
        XFubenManager.RegisterFubenManager(XFubenManager.StageType.Daily, XDataCenter.FubenDailyManager)
        XFubenManager.RegisterFubenManager(XFubenManager.StageType.BossSingle, XDataCenter.FubenBossSingleManager)
        XFubenManager.RegisterFubenManager(XFubenManager.StageType.Urgent, XDataCenter.FubenUrgentEventManager)
        XFubenManager.RegisterFubenManager(XFubenManager.StageType.Resource, XDataCenter.FubenResourceManager)
        XFubenManager.RegisterFubenManager(XFubenManager.StageType.Bfrt, XDataCenter.BfrtManager)
        XFubenManager.RegisterFubenManager(XFubenManager.StageType.BountyTask, XDataCenter.BountyTaskManager)
        XFubenManager.RegisterFubenManager(XFubenManager.StageType.BossOnline, XDataCenter.FubenBossOnlineManager)
        XFubenManager.RegisterFubenManager(XFubenManager.StageType.Prequel, XDataCenter.PrequelManager)
        XFubenManager.RegisterFubenManager(XFubenManager.StageType.Trial, XDataCenter.TrialManager)
        XFubenManager.RegisterFubenManager(XFubenManager.StageType.Arena, XDataCenter.ArenaManager)
        XFubenManager.RegisterFubenManager(XFubenManager.StageType.Explore, XDataCenter.FubenExploreManager)
        XFubenManager.RegisterFubenManager(XFubenManager.StageType.ActivtityBranch, XDataCenter.FubenActivityBranchManager)
        XFubenManager.RegisterFubenManager(XFubenManager.StageType.Practice, XDataCenter.PracticeManager)
        XFubenManager.RegisterFubenManager(XFubenManager.StageType.Festival, XDataCenter.FubenFestivalActivityManager)
        XFubenManager.InitStageLevelMap()
        XFubenManager.InitStageMultiplayerLevelMap()
    end

    function XFubenManager.RegisterFubenManager(type, manager)
        if manager.InitStageInfo then
            InitStageInfoHandler[type] = manager.InitStageInfo
        end
        if manager.CheckPreFight then
            CheckPreFightHandler[type] = manager.CheckPreFight
        end
        if manager.FinishFight then
            FinishFightHandler[type] = manager.FinishFight
        end
        if manager.OpenFightLoading then
            OpenFightLoadingHandler[type] = manager.OpenFightLoading
        end
        if manager.CloseFightLoading then
            CloseFightLoadingHandler[type] = manager.CloseFightLoading
        end
        if manager.ShowSummary then
            ShowSummaryHandler[type] = manager.ShowSummary
        end
        if manager.SettleFight then
            SettleFightHandler[type] = manager.SettleFight
        end
        if manager.CheckReadyToFight then
            CheckReadyToFightHandler[type] = manager.CheckReadyToFight
        end
        if manager.CheckAutoExitFight then
            CheckAutoExitFightHandler[type] = manager.CheckAutoExitFight
        end
        if manager.ShowReward then
            ShowRewardHandler[type] = manager.ShowReward
        end
    end

    function XFubenManager.InitStageLevelMap()
        StageLevelMap = {}
        local tmpDict = {}
        for k, v in pairs(StageLevelControlCfg) do
            if not tmpDict[v.StageId] then
                tmpDict[v.StageId] = {}
            end
            table.insert(tmpDict[v.StageId], v)
        end

        for k, list in pairs(tmpDict) do
            table.sort(list, function(a, b)
                return a.MaxLevel < b.MaxLevel
            end)
            local tmpByLevel = {}
            local index = 1
            for i = 1, XPlayerManager.PlayerMaxLevel do
                if i > list[index].MaxLevel then
                    index = index + 1
                    if index > #list then
                        break
                    end
                end
                tmpByLevel[i] = list[index]
            end
            StageLevelMap[k] = tmpByLevel
        end
    end

    function XFubenManager.InitStageMultiplayerLevelMap()
        local config = XFubenConfigs.GetStageMultiplayerLevelControlCfg()
        StageMultiplayerLevelMap = {}
        for k, v in pairs(config) do
            if not StageMultiplayerLevelMap[v.StageId] then
                StageMultiplayerLevelMap[v.StageId] = {}
            end
            StageMultiplayerLevelMap[v.StageId][v.Difficulty] = v
        end
    end

    function XFubenManager.GetStageCfg(stageId)
        if not StageCfg[stageId] then
            XLog.Error("XFubenManager.GetStageCfg Error, stageId not found:" .. tostring(stageId))
            return
        end
        return StageCfg[stageId]
    end

    function XFubenManager.GetStageRebootId(stageId)
        if not StageCfg[stageId] then
            return 0
        end
        return StageCfg[stageId].RebootId
    end

    function XFubenManager.GetStageTransformCfg(stageId)
        if not StageTransformCfg[stageId] then
            XLog.Error("XFubenManager.GetStageTransformCfg Error, stageId not found:" .. tostring(stageId))
            return
        end
        return StageTransformCfg[stageId]
    end

    function XFubenManager.GetStageBgmId(stageId)
        if not StageCfg[stageId] then
            return 0
        end
        return StageCfg[stageId].BgmId
    end

    function XFubenManager.GetStageMaxChallengeNums(stageId)
        return StageCfg[stageId] and StageCfg[stageId].MaxChallengeNums or 0
    end

    function XFubenManager.GetStageBuyChallengeCount(stageId)
        return StageCfg[stageId] and StageCfg[stageId].BuyChallengeCount or 0
    end

    function XFubenManager.GetConditonByMapId(stageId)
        local suggestedConditionIds, forceConditionIds = {}, {}
        if StageCfg[stageId] then
            suggestedConditionIds = StageCfg[stageId].SuggestedConditionId
            forceConditionIds = StageCfg[stageId].ForceConditionId
        end
        return suggestedConditionIds, forceConditionIds
    end

    local GetStarsCount = function(starsMark)
        local count = (starsMark & 1) + (starsMark & 2 > 0 and 1 or 0) + (starsMark & 4 > 0 and 1 or 0)
        local map = {(starsMark & 1) > 0, (starsMark & 2) > 0, (starsMark & 4) > 0 }
        return count, map
    end

    function XFubenManager.InitFubenData(fubenData)
        -- 玩家数据
        if fubenData then
            if fubenData.StageData then
                for key, value in pairs(fubenData.StageData) do
                    PlayerStageData[key] = value
                    -- XEventManager.DispatchEvent(XEventId.EVENT_FUBEN_STAGE_SYNC, key)
                end
            end
            if fubenData.FubenBaseData and fubenData.FubenBaseData.RefreshTime > 0 then
                RefreshTime = fubenData.FubenBaseData.RefreshTime
            end
            if fubenData.UnlockHideStages then
                for k, v in pairs(fubenData.UnlockHideStages) do
                    UnlockHideStages[v] = true
                end
            end
        end
        XFubenManager.InitData()
    end

    function XFubenManager.InitData(checkNewUnlock)
        local oldStageInfos = StageInfos

        XFubenManager.InitStageInfo()
        for _, v in pairs(InitStageInfoHandler) do
            v(checkNewUnlock)
        end
        XFubenManager.InitStageInfoNextStageId()
        -- 发送关卡刷新事件
        XEventManager.DispatchEvent(XEventId.EVENT_FUBEN_REFRESH_STAGE_DATA)

        -- 检查新关卡事件
        if checkNewUnlock then
            for k, v in pairs(StageInfos) do
                if v.Unlock and not oldStageInfos[k].Unlock then
                    XEventManager.DispatchEvent(XEventId.EVENT_FUBEN_NEW_STAGE, k)
                end
            end
        end
    end

    function XFubenManager.InitStageInfo()
        -- stage
        StageInfos = {}
        for stageId, stageCfg in pairs(StageCfg) do
            local info = {}
            StageInfos[stageId] = info
            info.HaveAssist = stageCfg.HaveAssist
            info.IsMultiplayer = stageCfg.IsMultiplayer
            if PlayerStageData[stageId] then
                info.Passed = PlayerStageData[stageId].Passed
                info.Stars, info.StarsMap = GetStarsCount(PlayerStageData[stageId].StarsMark)
            else
                info.Passed = false
                info.Stars = 0
                info.StarsMap = {false, false, false }
            end
            info.Unlock = true
            info.IsOpen = true
            if stageCfg.RequireLevel > 0 and XPlayer.Level < stageCfg.RequireLevel then
                info.Unlock = false
            end
            for k, prestageId in pairs(stageCfg.PreStageId or {}) do
                if prestageId > 0 then
                    if not PlayerStageData[prestageId] or not PlayerStageData[prestageId].Passed then
                        info.Unlock = false
                        info.IsOpen = false
                        break
                    end
                end
            end
            info.TotalStars = 3
        end
    end


    function XFubenManager.InitStageInfoNextStageId()
        for k, v in pairs(StageCfg) do
            for _, preStageId in pairs(v.PreStageId) do
                local preStageInfo = XFubenManager.GetStageInfo(preStageId)
                if not(v.StageType == XFubenConfigs.STAGETYPE_STORYEGG or v.StageType == XFubenConfigs.STAGETYPE_FIGHTEGG) then
                    preStageInfo.NextStageId = v.StageId
                end
            end
        end
    end

    function XFubenManager.IsPreStageIdContains(preStageId, stageId)
        for k, v in pairs(preStageId or {}) do
            if v == stageId then return true end
        end
        return false
    end

    -- 获取每个关卡的星星、次数等数据
    function XFubenManager.GetStageInfo(stageId)
        return StageInfos[stageId]
    end

    function XFubenManager.GetStageData(stageId)
        return PlayerStageData[stageId]
    end

    function XFubenManager.GetStageName(stageId)
        local cfg = StageCfg[stageId]
        return cfg and cfg.Name
    end

    function XFubenManager.GetStageNameLevel(stageId)
        local curStageOrderId
        local curChapterOrderId
        local stageInfo
        stageInfo = XFubenManager.GetStageInfo(stageId)
        if stageInfo and stageInfo.ChapterId then
            local chapter = XDataCenter.FubenMainLineManager.GetChapterCfg(stageInfo.ChapterId)
            curStageOrderId = stageInfo.OrderId
            curChapterOrderId = chapter.OrderId
            if curStageOrderId and curChapterOrderId then
                return  "【"..curChapterOrderId .. "-" .. curStageOrderId.."】"..XFubenManager.GetStageName(stageId)
            end
        end
        return XFubenManager.GetStageName(stageId)
    end

    function XFubenManager.GetActivityChapters()
        local chapters = XTool.MergeArray(
        XDataCenter.FubenBossOnlineManager.GetBossOnlineChapters()--联机boss
        , XDataCenter.FubenActivityBranchManager.GetActivitySections()--副本支线活动
        , XDataCenter.FubenActivityBossSingleManager.GetActivitySections()--单挑BOSS活动
        , XDataCenter.FubenFestivalActivityManager.GetAvaliableFestivals())--节日活动副本

        return chapters
    end

    function XFubenManager.GetActivityChaptersBySort()
        local chapters = XTool.MergeArray(
            XDataCenter.FubenBossOnlineManager.GetBossOnlineChapters()--联机boss
            , XDataCenter.FubenActivityBranchManager.GetActivitySections()--副本支线活动
            , XDataCenter.FubenActivityBossSingleManager.GetActivitySections()--单挑BOSS活动
            , XDataCenter.FubenFestivalActivityManager.GetAvaliableFestivals()--节日活动副本
        )
        table.sort(chapters, function(a, b)
                local priority1 = XFubenConfigs.GetActivityPriorityByActivityIdAndType(a.Id,a.Type)
                local priority2 = XFubenConfigs.GetActivityPriorityByActivityIdAndType(b.Id,b.Type)
                return priority1 > priority2
            end)
        return chapters
    end


    function XFubenManager.GetChallengeChapters()
        local list = {}
        --如果完成了全部探索需要把探索拍到最后
        if not XDataCenter.FubenExploreManager.IsFinishAll() then
            local exploreChapters = XFubenConfigs.GetChapterBannerByType(XFubenManager.ChapterType.Explore)
            if exploreChapters.IsOpen and exploreChapters.IsOpen == 1 then
                table.insert(list, exploreChapters)
            end
        end

        local arenaChapters = XFubenConfigs.GetChapterBannerByType(XFubenManager.ChapterType.ARENA)
        if arenaChapters.IsOpen and arenaChapters.IsOpen == 1 then
            table.insert(list, arenaChapters)
        end

        local bossSingleChapters = XFubenConfigs.GetChapterBannerByType(XFubenManager.ChapterType.BOSSSINGLE)
        if bossSingleChapters.IsOpen and bossSingleChapters.IsOpen == 1 then
            table.insert(list, bossSingleChapters)
        end

        local practiceChapters = XFubenConfigs.GetChapterBannerByType(XFubenManager.ChapterType.Practice)
        if practiceChapters.IsOpen and practiceChapters.IsOpen == 1 then
            table.insert(list, practiceChapters)
        end

        local isTrialFinish = false
        local trialChapters = nil
        -- local isOpen = XFunctionManager.JudgeCanOpen(XFunctionManager.FunctionName.Trial)
        -- if isOpen then
            trialChapters = XFubenConfigs.GetChapterBannerByType(XFubenManager.ChapterType.Trial)
            if trialChapters and trialChapters.IsOpen and trialChapters.IsOpen == 1  then
                if XDataCenter.TrialManager.EntranceOpen() then
                    table.insert(list, trialChapters)
                else
                    isTrialFinish = true
                end
            end
        -- end

        table.sort(list, function(chapterA, chapterB)
            local weightA = XFunctionManager.JudgeCanOpen(XFubenManager.ChapterFunctionName[chapterA.Type]) and 1 or 0
            local weightB = XFunctionManager.JudgeCanOpen(XFubenManager.ChapterFunctionName[chapterB.Type]) and 1 or 0
            if weightA == weightB then
                return chapterA.Priority < chapterB.Priority
            end
            return weightA > weightB
        end)
        --如果完成了全部探索需要把探索拍到最后
        if XDataCenter.FubenExploreManager.IsFinishAll() then
            local exploreChapters = XFubenConfigs.GetChapterBannerByType(XFubenManager.ChapterType.Explore)
            if exploreChapters.IsOpen and exploreChapters.IsOpen == 1 then
                table.insert(list, exploreChapters)
            end
        end

        if isTrialFinish then
            table.insert(list, trialChapters)
        end
        return list
    end


    function XFubenManager.GetDailyDungeonRules()
        local dailyDungeonRules = XDataCenter.FubenDailyManager.GetDailyDungeonRulesList()

        local tmpDataList = {}

        for k, v in pairs(dailyDungeonRules) do
            local tmpData = {}
            local tmpDay = XDataCenter.FubenDailyManager.IsDayLock(v.Id)
            local tmpCon = XDataCenter.FubenDailyManager.GetConditionData(v.Id).IsLock
            local tmpOpen = XDataCenter.FubenDailyManager.GetEventOpen(v.Id).IsOpen
            tmpData.Lock = tmpCon or (tmpDay and not tmpOpen)
            tmpData.Rule = v
            tmpData.Open = tmpOpen and not tmpCon
            table.insert(tmpDataList, tmpData)
        end

        -- local resourceChapters = XDataCenter.FubenResourceManager.GetResourceChapters()
        local list = XTool.MergeArray(tmpDataList, resourceChapters)

        table.sort(list, function(a, b)
            if not a.Lock and not b.Lock then
                if (a.Open and b.Open) or (not a.Open and not b.Open) then
                    return a.Rule.Priority < b.Rule.Priority
                else
                    return a.Open and not b.Open
                end
            elseif a.Lock and b.Lock then
                return a.Rule.Priority < b.Rule.Priority
            else
                return not a.Lock and b.Lock
            end
        end)


        dailyDungeonRules = {}
        for k, v in pairs(list) do
            table.insert(dailyDungeonRules, v.Rule)
        end

        return dailyDungeonRules
    end

    function XFubenManager.GetDailyDungeonRule(Id)
        local dailyDungeonRules = XDataCenter.FubenDailyManager.GetDailyDungeonRulesList()
        return dailyDungeonRules[Id]
    end

    function XFubenManager.CheckFightCondition(conditionIds, teamId)
        if #conditionIds <= 0 then
            return true
        end

        local teamData = nil
        if teamId then
            teamData = XDataCenter.TeamManager.GetTeamData(teamId)
        end

        for _, id in pairs(conditionIds) do
            local ret, desc = XConditionManager.CheckCondition(id, teamData)
            if not ret then
                XUiManager.TipError(desc)
                return false
            end
        end
        return true
    end

    function XFubenManager.CheckFightConditionByTeamData(conditionIds, teamData)
        if #conditionIds <= 0 then
            return true
        end

        for _, id in pairs(conditionIds) do
            local ret, desc = XConditionManager.CheckCondition(id, teamData)
            if not ret then
                XUiManager.TipError(desc)
                return false
            end
        end
        return true
    end

    function XFubenManager.CheckPreFightBase(stage)
        -- 检测前置副本
        local stageId = stage.StageId
        local stageInfo = XFubenManager.GetStageInfo(stageId)
        if not stageInfo.Unlock then
            XUiManager.TipMsg(XFubenManager.GetFubenOpenTips(stageId))
            return false
        end

        -- 翻牌额外体力
        local flopRewardId = stage.FlopRewardId
        local flopRewardTemplate = FlopRewardTemplates[flopRewardId]
        if flopRewardTemplate and XDataCenter.ItemManager.CheckItemCountById(flopRewardTemplate.ConsumeItemId, flopRewardTemplate.ConsumeItemCount) then
            if flopRewardTemplate.ExtraActionPoint > 0 then
                if not XDataCenter.ItemManager.DoNotEnoughBuyAsset(XDataCenter.ItemManager.ItemId.ActionPoint,
                        stage.RequireActionPoint + flopRewardTemplate.ExtraActionPoint,
                        1,
                        function() XFubenManager.CheckPreFightBase(stage) end,
                        "FubenActionPointNotEnough") then
                    return false
                end
            end
        end

        -- 检测体力
        if stage.RequireActionPoint > 0 then
            if not XDataCenter.ItemManager.DoNotEnoughBuyAsset(XDataCenter.ItemManager.ItemId.ActionPoint,
                    stage.RequireActionPoint,
                    1,
                    function() XFubenManager.CheckPreFightBase(stage) end,
                    "FubenActionPointNotEnough") then
                return false
            end
        end

        return true
    end

    function XFubenManager.CheckCanFlop(stageId)
        local stage = XFubenManager.GetStageCfg(stageId)
        local flopRewardId = stage.FlopRewardId
        local flopRewardTemplate = FlopRewardTemplates[flopRewardId]
        if not flopRewardTemplate then
            return false
        end

        if flopRewardTemplate.ConsumeItemId > 0 then
            if not XDataCenter.ItemManager.CheckItemCountById(flopRewardTemplate.ConsumeItemId, flopRewardTemplate.ConsumeItemCount) then
                return false
            end
        end

        return true
    end

    function XFubenManager.GetStageActionPointConsume(stageId)
        local stage = XFubenManager.GetStageCfg(stageId)
        local flopRewardId = stage.FlopRewardId
        local flopRewardTemplate = FlopRewardTemplates[flopRewardId]

        -- 没配翻牌
        if not flopRewardTemplate then
            return stage.RequireActionPoint
        end

        -- 翻牌道具不足
        if not XFubenManager.CheckCanFlop(stageId) then
            return stage.RequireActionPoint
        end

        return stage.RequireActionPoint + flopRewardTemplate.ExtraActionPoint
    end

    function XFubenManager.GetFlopShowId(stageId)
        local stage = XFubenManager.GetStageCfg(stageId)
        local flopRewardId = stage.FlopRewardId
        local flopRewardTemplate = FlopRewardTemplates[flopRewardId]
        return flopRewardTemplate and flopRewardTemplate.ShowRewardId or 0
    end

    function XFubenManager.GetFlopConsumeItemId(stageId)
        local stage = XFubenManager.GetStageCfg(stageId)
        local flopRewardId = stage.FlopRewardId
        local flopRewardTemplate = FlopRewardTemplates[flopRewardId]
        return flopRewardTemplate and flopRewardTemplate.ConsumeItemId or 0
    end

    function XFubenManager.CheckPreFight(stage)
        if not XFubenManager.CheckPreFightBase(stage) then
            return false
        end

        local stageId = stage.StageId
        local stageInfo = XFubenManager.GetStageInfo(stageId)
        if CheckPreFightHandler[stageInfo.Type] then
            return CheckPreFightHandler[stageInfo.Type](stage)
        end
        return true
    end

    function XFubenManager.PreFight(stage, teamId, isAssist)
        local preFight = {}
        preFight.CardIds = {}
        preFight.StageId = stage.StageId
        preFight.IsHasAssist = isAssist and true or false

        -- 如果有试玩角色，则不读取玩家队伍信息
        if not stage.RobotId or #stage.RobotId <= 0 then
            local teamData = XDataCenter.TeamManager.GetTeamData(teamId)
            for _, v in pairs(teamData) do
                table.insert(preFight.CardIds, v)
            end
        end

        return preFight
    end

    function XFubenManager.EnterFight(stage, teamId, isAssist)
        if not XFubenManager.CheckPreFight(stage) then
            return
        end
        --检测是否赏金前置战斗
        local isBountyTaskFight, task = XDataCenter.BountyTaskManager.CheckBountyTaskPreFightWithStatus(stage.StageId)
        if isBountyTaskFight then
            XDataCenter.BountyTaskManager.RecordPreFightData(task.Id, teamId)
        end

        local preFight = XFubenManager.PreFight(stage, teamId, isAssist)
        XNetwork.Call(METHOD_NAME.PreFight, { PreFightData = preFight }, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            local fightData = res.FightData
            local stageInfo = XFubenManager.GetStageInfo(fightData.StageId)
            local isKeepPlayingStory = stage and XFubenConfigs.IsKeepPlayingStory(stage.StageId) and (stage.BeginStoryId ~= 0)
            local isNotPass = stage and stage.BeginStoryId ~= 0 and (not stageInfo or not stageInfo.Passed)
            if isKeepPlayingStory or isNotPass then
                -- 播放剧情，进入战斗
                XEventManager.DispatchEvent(XEventId.EVENT_FIGHT_BEGIN_PLAYMOVIE)

                if CS.Movie.XMovieManager.Instance:CheckMovieExist(stage.BeginStoryId) then
                    CS.Movie.XMovieManager.Instance:PlayById(stage.BeginStoryId, function()
                        XFubenManager.EnterRealFight(preFight, fightData)
                    end)
                end

            else
                -- 直接进入战斗
                XFubenManager.EnterRealFight(preFight, fightData)
            end
        end)
    end

    function XFubenManager.EnterBfrtFight(stageId, team)
        local stage = XFubenManager.GetStageCfg(stageId)
        if not XFubenManager.CheckPreFight(stage) then
            return
        end

        local preFight = {}
        preFight.CardIds = {}
        preFight.StageId = stage.StageId

        for _, v in pairs(team) do
            table.insert(preFight.CardIds, v)
        end

        local req = { PreFightData = preFight }
        XNetwork.Call(METHOD_NAME.PreFight, req, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end
            local fightData = res.FightData
            local stageInfo = XFubenManager.GetStageInfo(fightData.StageId)
            if stage and stage.BeginStoryId ~= 0 and (not stageInfo or not stageInfo.Passed) then
                -- 播放剧情，进入战斗
                if CS.Movie.XMovieManager.Instance:CheckMovieExist(stage.BeginStoryId) then
                    CS.Movie.XMovieManager.Instance:PlayById(stage.BeginStoryId, function()
                        XFubenManager.EnterRealFight(preFight, fightData)
                    end)
                end


            else
                -- 直接进入战斗
                XFubenManager.EnterRealFight(preFight, fightData)
            end
        end)
    end

    function XFubenManager.ReconnectFight()
        -- 获取fightData
        XNetwork.Call(METHOD_NAME.GetFightData, nil, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            -- 构造preFightData
            local fightData = res.FightData
            local preFightData = {}
            preFightData.CardIds = {}
            preFightData.StageId = fightData.StageId
            for i = 1, #fightData.RoleData do
                local role = fightData.RoleData[i]
                if role.Id == XPlayer.Id then
                    for j = 1, #role.NpcData do
                        local npc = role.NpcData[j]
                        table.insert(preFightData.CardIds, npc.Character.Id)
                    end
                    break
                end
            end

            XFubenManager.EnterRealFight(preFightData, fightData, true)
        end)
    end

    --==============================--
    --desc: 进入新手战斗，构造战斗数据
    --time:2018-06-19 04:11:30
    --@stageId:
    --@charId:
    --@return
    --==============================--
    function XFubenManager.EnterGuideFight(guiId, stageId, chars, weapons)
        local fightData = {}
        fightData.RoleData = {}
        fightData.FightId = 1
        fightData.Online = false
        fightData.Seed = 1
        fightData.StageId = stageId

        local roleData = {}
        roleData.NpcData = {}
        table.insert(fightData.RoleData, roleData)
        roleData.Id = XPlayer.Id
        roleData.Name = CS.XTextManager.GetText("Aha")
        roleData.Camp = 1

        local npcData = {}
        npcData.Equips = {}
        roleData.NpcData[0] = npcData

        for k, v in pairs(chars) do
            local character = {}
            npcData.Character = character
            character.Id = v
            character.Level = 1
            character.Quality = 1
            character.Star = 1
        end

        for k, v in pairs(weapons) do
            local equipData = {}
            table.insert(npcData.Equips, equipData)
            equipData.Id = 1
            equipData.TemplateId = v
            equipData.Level = 1
            equipData.Star = 0
            equipData.Breakthrough = 0
        end

        local stage = XFubenManager.GetStageCfg(stageId)
        fightData.RebootId = stage.RebootId
        fightData.DisableJoystick = stage.DisableJoystick
        local endFightCb = function()
            if stage.EndStoryId ~= 0 then
                if CS.Movie.XMovieManager.Instance:CheckMovieExist(stage.EndStoryId) then
                    CS.Movie.XMovieManager.Instance:PlayById(stage.EndStoryId, function()
                        local guideFight = XDataCenter.GuideManager.GetNextGuideFight()
                        if guideFight then
                            XDataCenter.FubenManager.EnterGuideFight(guideFight.Id, guideFight.StageId, guideFight.NpcId, guideFight.Weapon)
                        else
                            XLoginManager.SetFirstOpenMainUi(true)
                            XLuaUiManager.RunMain()
                        end
                    end)
                end
            else
                local guideFight = XDataCenter.GuideManager.GetNextGuideFight()
                if guideFight then
                    XDataCenter.FubenManager.EnterGuideFight(guideFight.Id, guideFight.StageId, guideFight.NpcId, guideFight.Weapon)
                else
                    XLoginManager.SetFirstOpenMainUi(true)
                    XLuaUiManager.RunMain()
                end
            end
        end

        local enterFightFunc = function()
            XFubenManager.CallOpenFightLoading(stageId)
            local args = CS.XFightClientArgs()
            args.HideCloseButton = true
            args.RoleId = XPlayer.Id
            args.CloseLoadingCb = function()
                XFubenManager.CallCloseFightLoading(stageId)
            end
            args.FinishCbAfterClear = function()
                local req = { GuideGroupId = guiId }
                XNetwork.Call(METHOD_NAME.GuideComplete, req, function(res)
                    if res.Code ~= XCode.Success then
                        XUiManager.TipCode(res.Code)
                        return
                    end
                    endFightCb()
                end)
            end
            args.ClientOnly = true

            CS.XFight.Enter(fightData, args)
        end

        if stage.BeginStoryId ~= 0 then

            if CS.Movie.XMovieManager.Instance:CheckMovieExist(stage.BeginStoryId) then
                CS.Movie.XMovieManager.Instance:PlayById(stage.BeginStoryId, enterFightFunc)
            end

        else
            enterFightFunc()
        end
    end

    --进入技能教学战斗，构造战斗数据
    function XFubenManager.EnterSkillTeachFight(characterId)
        local stageId = XCharacterConfigs.GetCharTeachStageIdById(characterId)

        local fightData = {}
        fightData.RoleData = {}
        fightData.FightId = 1
        fightData.Online = false
        fightData.Seed = 1
        fightData.StageId = stageId

        local roleData = {}
        roleData.NpcData = {}
        table.insert(fightData.RoleData, roleData)
        roleData.Id = XPlayer.Id
        roleData.Name = CS.XTextManager.GetText("Aha")
        roleData.Camp = 1

        local npcData = {}
        npcData.Equips = {}
        roleData.NpcData[0] = npcData

        npcData.Character = XDataCenter.CharacterManager.GetCharacter(characterId)
        npcData.Equips = XDataCenter.EquipManager.GetCharacterWearingEquips(characterId)

        local stage = XFubenManager.GetStageCfg(stageId)
        fightData.RebootId = stage.RebootId
        local endFightCb = function()
            if stage.EndStoryId ~= 0 then
                if CS.Movie.XMovieManager.Instance:CheckMovieExist(stage.EndStoryId) then
                    CS.Movie.XMovieManager.Instance:PlayById(stage.EndStoryId)
                end
            else
                XLuaUiManager.ShowTopUi()
            end
        end

        local enterFightFunc = function()
            XFubenManager.CallOpenFightLoading(stageId)
            local args = CS.XFightClientArgs()
            args.RoleId = XPlayer.Id
            args.CloseLoadingCb = function()
                XFubenManager.CallCloseFightLoading(stageId)
            end
            args.FinishCbAfterClear = function()
                endFightCb()
            end
            args.ClientOnly = true

            CS.XFight.Enter(fightData, args)
        end

        if stage.BeginStoryId ~= 0 then
            if CS.Movie.XMovieManager.Instance:CheckMovieExist(stage.BeginStoryId) then
                CS.Movie.XMovieManager.Instance:PlayById(stage.BeginStoryId, enterFightFunc)
            end
        else
            enterFightFunc()
        end
    end

    function XFubenManager.PlayStory(storyId, callback)

        if CS.Movie.XMovieManager.Instance:CheckMovieExist(storyId) then
            CS.Movie.XMovieManager.Instance:PlayById(storyId, function()
                if callback then
                    callback()
                end
            end)
        end
    end

    -- 组织战斗需要用的数据
    function XFubenManager.EnterRealFight(preFightData, fightData)
        local isReconnect = false
        local stageId = fightData.StageId
        XFubenManager.CallOpenFightLoading(stageId)
        local assistInfo

        if preFightData.IsHasAssist then
            for i = 1, #fightData.RoleData do
                local role = fightData.RoleData[i]
                if role.Id == XPlayer.Id then
                    assistInfo = role.AssistNpcData
                    break
                end
            end
        end

        local charList = {}
        for i = 1, #preFightData.CardIds do
            table.insert(charList, preFightData.CardIds[i])
        end

        XFubenManager.RecordFightBeginData(stageId, charList, preFightData.IsHasAssist, assistInfo)

        -- 提示加锁
        XTipManager.Suspend()

        -- 功能开启&新手加锁
        XDataCenter.FunctionEventManager.LockFunctionEvent()

        XFubenManager.FubenSettleResult = nil

        local args = XFubenManager.CtorFightArgs(fightData.StageId, fightData.RoleData)
        CS.XFight.Enter(fightData, args)
        EnterFightStartTime = CS.UnityEngine.Time.time
        XEventManager.DispatchEvent(XEventId.EVENT_ENTER_FIGHT)
    end

    function XFubenManager.CtorFightArgs(stageId, roleData)
        local args = CS.XFightClientArgs()
        args.IsReconnect = false
        args.RoleId = XPlayer.Id
        args.FinishCb = XFubenManager.CallFinishFight
        args.ProcessCb = function(progress)
            XDataCenter.RoomManager.UpdateLoadProcess(progress)
        end

        local stageCfg = XFubenManager.GetStageCfg(stageId)
        args.CloseLoadingCb = function()
            XFubenManager.CallCloseFightLoading(stageId)
            local loadingTime = CS.UnityEngine.Time.time - EnterFightStartTime
            local roleIdStr = ""
            if roleData[1] then
                for i = 0, #roleData[1].NpcData do
                    if roleData[1].NpcData[i] then
                        roleIdStr = roleIdStr .. roleData[1].NpcData[i].Character.Id .. ","
                    end
                end
            end
            local msgtab = {}
            msgtab["stageId"] = tostring(stageId)
            msgtab["loadingTime"] = tostring(loadingTime)
            msgtab["roleIdStr"] = tostring(roleIdStr)
            local jsonstr = Json.encode(msgtab)
            CS.XRecord.Record("24034", "BdcEnterFightLoadingTime",jsonstr)
            CS.XHeroBdcAgent.BdcEnterFightLoadingTime(stageId, loadingTime, roleIdStr)
        end
        local list = CS.System.Collections.Generic.List(CS.System.String)()
        for k, v in pairs(stageCfg.StarDesc) do
            list:Add(v)
        end
        args.StarTips = list
        local stageInfo = XFubenManager.GetStageInfo(stageId)
        args.Stars = stageInfo.Stars
        if ShowSummaryHandler[stageInfo.Type] then
            args.ShowSummaryCb = function()
                ShowSummaryHandler[stageInfo.Type](stageId)
            end
        end

        if CheckAutoExitFightHandler[stageInfo.Type] then
            args.AutoExitFight = CheckAutoExitFightHandler[stageInfo.Type](stageId)
        end

        if SettleFightHandler[stageInfo.Type] then
            args.SettleCb = SettleFightHandler[stageInfo.Type]
        else
            args.SettleCb = XFubenManager.SettleFight
        end

        if CheckReadyToFightHandler[stageInfo.Type] then
            args.IsReadyToFight = CheckReadyToFightHandler[stageInfo.Type](stageId)
        end
        return args
    end

    -- 联机副本进入战斗
    function XFubenManager.OnEnterFight(fightData)
        local role
        for i = 1, #fightData.RoleData do
            if fightData.RoleData[i].Id == XPlayer.Id then
                role = fightData.RoleData[i]
                break
            end
        end

        if not role then
            XLog.Error("XFubenManager.OnEnterFight error, role not found")
            return
        end

        local preFightData = {}
        preFightData.StageId = fightData.StageId
        preFightData.CardIds = {}
        for k, v in pairs(role.NpcData) do
            table.insert(preFightData.CardIds, v.Character.Id)
        end
        XFubenManager.EnterRealFight(preFightData, fightData)
    end

    -- 战斗开始前数据记录，便于结算时的 UI 数据显示
    local BeginData
    --返回战前数据
    function XFubenManager.GetFightBeginData()
        return BeginData
    end

    function XFubenManager.RecordFightBeginData(stageId, charList, isHasAssist, assistPlayerData)
        BeginData = {
            CharExp = {},
            RoleExp = 0,
            RoleCoins = 0,
            LastPassed = false,
            AssistPlayerData = nil,
            IsHasAssist = false,
            CharList = charList,
            StageId = stageId
        }

        for _, charId in pairs(charList) do
            local char = XDataCenter.CharacterManager.GetCharacter(charId)
            if char ~= nil then
                table.insert(BeginData.CharExp, { Id = charId, Quality = char.Quality, Exp = char.Exp, Level = char.Level })
            end
        end

        -- local stage = XFubenManager.GetStageCfg(stageId)
        BeginData.RoleLevel = XPlayer.Level
        BeginData.RoleExp = XPlayer.Exp
        BeginData.RoleCoins = XDataCenter.ItemManager.GetCoinsNum()
        local stageInfo = XFubenManager.GetStageInfo(stageId)
        BeginData.LastPassed = stageInfo.Passed
        BeginData.AssistPlayerData = assistPlayerData
        BeginData.IsHasAssist = isHasAssist

        -- 联机相关
        local roomData = XDataCenter.RoomManager.RoomData
        if roomData then
            BeginData.PlayerList = {}
            for k, v in pairs(roomData.PlayerDataList) do
                local playerData = {
                    Id = v.Id,
                    Name = v.Name,
                    CharacterId = v.FightNpcData.Character.Id,
                    MedalId = v.MedalId
                }
                BeginData.PlayerList[v.Id] = playerData
            end
        end
    end

    function XFubenManager.RequestReboot(fightId, rebootCount, cb)
        XNetwork.Call(METHOD_NAME.FightReboot, { FightId = fightId, RebootCount = rebootCount }, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
            end
            cb(res.Code == XCode.Success)
        end)
    end

    --战斗结算统计
    function XFubenManager.StatisticsFightResultDps(result)
        -- 初始化Dps数据
        local dpsTable = {}

        --Dps数据
        if result.NpcDpsTable and result.NpcDpsTable.Count > 0 then
            local damageTotalMvp = -1
            local hurtMvp = -1
            local cureMvp = -1
            local breakEndureMvp = -1

            local damageTotalMvpValue = -1
            local hurtMvpValue = -1
            local cureMvpValue = -1
            local breakEndureValue = -1

            XTool.LoopMap(result.NpcDpsTable, function(k, v)
                dpsTable[v.RoleId] = {}
                dpsTable[v.RoleId].DamageTotal = v.DamageTotal
                dpsTable[v.RoleId].Hurt = v.Hurt
                dpsTable[v.RoleId].Cure = v.Cure
                dpsTable[v.RoleId].BreakEndure = v.BreakEndure
                dpsTable[v.RoleId].RoleId = v.RoleId

                if damageTotalMvpValue == -1 or v.DamageTotal > damageTotalMvpValue then
                    damageTotalMvpValue = v.DamageTotal
                    damageTotalMvp = v.RoleId
                end

                if cureMvpValue == -1 or v.Cure > cureMvpValue then
                    cureMvpValue = v.Cure
                    cureMvp = v.RoleId
                end

                if hurtMvpValue == -1 or v.Hurt > hurtMvpValue then
                    hurtMvpValue = v.Hurt
                    hurtMvp = v.RoleId
                end

                if breakEndureValue == -1 or v.BreakEndure > breakEndureValue then
                    breakEndureValue = v.BreakEndure
                    breakEndureMvp = v.RoleId
                end
            end)

            if damageTotalMvp ~= -1 and dpsTable[damageTotalMvp] then
                dpsTable[damageTotalMvp].IsDamageTotalMvp = true
            end

            if cureMvp ~= -1 and dpsTable[cureMvp] then
                dpsTable[cureMvp].IsCureMvp = true
            end

            if hurtMvp ~= -1 and dpsTable[hurtMvp] then
                dpsTable[hurtMvp].IsHurtMvp = true
            end

            if breakEndureMvp ~= -1 and dpsTable[breakEndureMvp] then
                dpsTable[breakEndureMvp].IsBreakEndureMvp = true
            end
            XFubenManager.LastDpsTable = dpsTable
        end
    end

    function XFubenManager.CallFinishFight()
        local res = XFubenManager.FubenSettleResult
        XFubenManager.FubenSettling = false
        XFubenManager.FubenSettleResult = nil
        if not res then
            -- 强退
            XFubenManager.ChallengeLose()
            return
        end

        if res.Code ~= XCode.Success then
            XUiManager.TipCode(res.Code)
            XFubenManager.ChallengeLose()
            CS.XGameEventManager.Instance:Notify(XEventId.EVENT_FUBEN_SETTLE_FAIL, res.Code)
            return
        end

        local stageId = res.Settle.StageId
        local stageInfo = XFubenManager.GetStageInfo(stageId)

        CsXGameEventManager.Instance:Notify(XEventId.EVENT_FIGHT_RESULT, res.Settle)

        if FinishFightHandler[stageInfo.Type] then
            FinishFightHandler[stageInfo.Type](res.Settle)
        else
            XFubenManager.FinishFight(res.Settle)
        end
    end

    function XFubenManager.FinishFight(settle)
        if settle.IsWin then
            XFubenManager.ChallengeWin(settle)
        else
            XFubenManager.ChallengeLose(settle)
        end
    end

    function XFubenManager.GetChallengeWinData(beginData, settleData)
        local stageData = PlayerStageData[settleData.StageId]

        local starCount = 0
        local starsMap = {}
        local starsMark = stageData and stageData.StarsMark
        if starsMark then
            starCount, starsMap = GetStarsCount(starsMark)
        end

        return {
            SettleData = settleData,
            StageId = settleData.StageId,
            RewardGoodsList = settleData.RewardGoodsList,
            CharExp = beginData.CharExp,
            RoleExp = beginData.RoleExp,
            RoleLevel = beginData.RoleLevel,
            RoleCoins = beginData.RoleCoins,
            StarsMap = starsMap,
            UrgentId = settleData.UrgentEnventId,
            ClientAssistInfo = AssistSuccess and beginData.AssistPlayerData or nil,
            FlopRewardList = settleData.FlopRewardList,
            PlayerList = beginData.PlayerList,
        }
    end

    function XFubenManager.ChallengeWin(settleData)
        -- 据点战关卡处理
        local stageInfo = StageInfos[settleData.StageId]
        if stageInfo.Type == XFubenManager.StageType.Bfrt then
            XDataCenter.BfrtManager.FinishStage(settleData.StageId)
        end
        local winData = XFubenManager.GetChallengeWinData(BeginData, settleData)
        local stage = XFubenManager.GetStageCfg(settleData.StageId)
        local isKeepPlayingStory = stage and XFubenConfigs.IsKeepPlayingStory(stage.StageId) and (stage.EndStoryId ~= 0)
        local isNotPass = stage and stage.EndStoryId ~= 0 and not BeginData.LastPassed
        if isKeepPlayingStory or isNotPass then
            -- 播放剧情，弹出结算
            if CS.Movie.XMovieManager.Instance:CheckMovieExist(stage.EndStoryId) then
                CS.Movie.XMovieManager.Instance:PlayById(stage.EndStoryId, function()
                    XFubenManager.CallShowReward(winData)
                end)
            end

        else
            -- 弹出结算
            XFubenManager.CallShowReward(winData)
        end

        -- XDataCenter.GuideManager.CompleteEvent(XDataCenter.GuideManager.GuideEventType.PassStage, settleData.StageId)
        XEventManager.DispatchEvent(XEventId.EVENT_FIGHT_RESULT_WIN)
    end

    function XFubenManager.CheckHasFlopReward(winData, needMySelf)
        for k, v in pairs(winData.FlopRewardList) do
            if v.PlayerId ~= 0 then
                if not needMySelf or v.PlayerId == XPlayer.Id then
                    return true
                end
            end
        end
        return false
    end

    function XFubenManager.CallShowReward(winData)
        if not winData then
            XLog.Warning("XFubenManager.CallShowReward warning, winData is nil")
            return
        end
        --CS.XAudioManager.PlayMusic(CS.XAudioManager.BATTLE_WIN_BGM)
        --CS.XAudioManager.RemoveCueSheet(CS.XAudioManager.NORMAL_MUSIC_CUE_SHEET_ID)
        local stageInfo = XFubenManager.GetStageInfo(winData.StageId)
        if ShowRewardHandler[stageInfo.Type] then
            ShowRewardHandler[stageInfo.Type](winData)
        else
            XFubenManager.ShowReward(winData)
        end
    end

    -- 胜利 & 奖励界面
    function XFubenManager.ShowReward(winData)
        if winData.SettleData.ArenaResult then
            XLuaUiManager.Open("UiArenaFightResult", winData)
            return
        end
        if XFubenManager.CheckHasFlopReward(winData) then
            XLuaUiManager.Open("UiFubenFlopReward", function()
                XLuaUiManager.PopThenOpen("UiSettleWin", winData)
            end, winData)
        else
            XLuaUiManager.Open("UiSettleWin", winData)
        end
    end

    -- 失败界面
    function XFubenManager.ChallengeLose(settleData)
        --CS.XAudioManager.RemoveCueSheet(CS.XAudioManager.NORMAL_MUSIC_CUE_SHEET_ID)
        --CS.XAudioManager.PlayMusic(CS.XAudioManager.BATTLE_LOSE_BGM)
        XLuaUiManager.Open("UiSettleLose", settleData)
    end

    -- 购买体力，作为测试的暂时工具
    function XFubenManager.BuyActionPoint(cb)
        XNetwork.Call(METHOD_NAME.BuyActionPoint, nil, function(res)
            local val = XDataCenter.ItemManager.GetActionPointsNum()
            cb(val)
        end)
    end

    -- 挑战进入前检查是否结算中
    function XFubenManager.CheckChallengeCanEnter(cb, challengeId)
        local req = { ChallengeId = challengeId }
        XNetwork.Call(METHOD_NAME.CheckChallengeCanEnter, req, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end
            if cb then
                cb()
            end
        end)
    end

    function XFubenManager.GoToFuben(param)
        if param == XFubenManager.StageType.Mainline or param == XFubenManager.StageType.Daily then
            if param == XFubenManager.StageType.Daily then
                if not XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.FubenChallenge) then
                    return
                end
            end
            XFubenManager.OpenFuben(param)
        else
            XFubenManager.OpenFubenByStageId(param)
        end
    end

    function XFubenManager.OpenFuben(type, stageId)
        -- if os.date("%x") ~= os.date("%x", RefreshTime) then
        --     XNetwork.Call(METHOD_NAME.RefreshFubenList, nil, function(res)
        --         if res.Code ~= XCode.Success then
        --             XUiManager.TipCode(res.Code)
        --             return
        --         end
        --         CS.XUiManager.ViewManager:Push("UiFuben", false, false, type, stageId)
        --     end)
        -- else
        --     CS.XUiManager.ViewManager:Push("UiFuben", false, false, type, stageId)
        -- end
        --CS.XUiManager.ViewManager:Push("UiFuben", false, false, type, stageId)
        XLuaUiManager.Open("UiFuben", type, stageId)
    end

    function XFubenManager.OpenFubenByStageId(stageId)
        local stageInfo = XFubenManager.GetStageInfo(stageId)
        if not stageInfo then
            XLog.Error("XFubenManager.OpenFubenByStageId Error, stageId not found: " .. stageId)
            return
        end
        if not stageInfo.Unlock then
            XUiManager.TipMsg(XFubenManager.GetFubenOpenTips(stageId))
            return
        end

        if stageInfo.Type == XFubenManager.StageType.Mainline then
            if stageInfo.Difficult == XFubenManager.DifficultHard and (not XFunctionManager.JudgeCanOpen(XFunctionManager.FunctionName.FubenDifficulty)) then
                local openTips = XFunctionManager.GetFunctionOpenCondition(XFunctionManager.FunctionName.FubenDifficulty)
                XUiManager.TipMsg(openTips)
                return
            end

            local chapter = XDataCenter.FubenMainLineManager.GetChapterCfg(stageInfo.ChapterId)
            CsXUiManager.Instance:Open("UiFubenMainLineChapter", chapter, stageId)
        elseif stageInfo.Type == XFubenManager.StageType.Bfrt then
            if not XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.FubenNightmare) then
                return
            end

            local chapter = XDataCenter.BfrtManager.GetChapterCfg(stageInfo.ChapterId)
            CsXUiManager.Instance:Open("UiFubenMainLineChapter", chapter, stageId)
        elseif stageInfo.Type == XFubenManager.StageType.ActivtityBranch then
            if not XDataCenter.FubenActivityBranchManager.IsOpen() then
                XUiManager.TipText("ActivityBranchNotOpen")
                return
            end

            local sectionId = XDataCenter.FubenActivityBranchManager.GetCurSectionId()
            XLuaUiManager.Open("UiActivityBranch", sectionId)
        elseif stageInfo.Type == XFubenManager.StageType.ActivityBossSingle then
            if not XDataCenter.FubenActivityBossSingleManager.IsOpen() then
                XUiManager.TipText("ActivityBossSingleNotOpen")
                return
            end

            local sectionId = XDataCenter.FubenActivityBossSingleManager.GetCurSectionId()
            XLuaUiManager.Open("UiActivityBossSingle", sectionId)
        end
    end

    function XFubenManager.GoToCurrentMainLine(stageId)
        if not XFubenManager.UiFubenMainLineChapterInst then
            XLog.Error("XFubenManager.GoToCurrentMainLine Error, UiFubenMainLineChapterInst is nil")
            return
        end
        local stageInfo = XFubenManager.GetStageInfo(stageId)
        if not stageInfo then
            XLog.Error("XFubenManager.OpenFubenByStageId Error, stageId not found: " .. stageId)
            return
        end
        if not stageInfo.Unlock then
            XUiManager.TipMsg(XFubenManager.GetFubenOpenTips(stageId))
            return
        end

        XFubenManager.UiFubenMainLineChapterInst:OpenStage(stageId, true)
    end

    function XFubenManager.OpenRoomSingle(stage, ...)
        if XFubenManager.CheckPreFight(stage) then
            XLuaUiManager.Open("UiNewRoomSingle", stage.StageId, ...)
            return true
        end
        return false
    end

    function XFubenManager.RequestCreateRoom(stage, cb)
        if XFubenManager.CheckPreFight(stage) then
            XDataCenter.RoomManager.CreateRoom(stage.StageId, cb)
        end
    end

    function XFubenManager.RequestMatchRoom(stage, cb)
        if XFubenManager.CheckPreFight(stage) then
            XDataCenter.RoomManager.Match(stage.StageId, cb)
        end
    end

    function XFubenManager.GetFubenTitle(stageId)
        local stageInfo = XFubenManager.GetStageInfo(stageId)
        local stageCfg = XFubenManager.GetStageCfg(stageId)
        local res = ""
        if stageInfo and stageInfo.Type == XFubenManager.StageType.Mainline then
            local diffMsg = ""
            local chapterCfg = XDataCenter.FubenMainLineManager.GetChapterCfg(stageInfo.ChapterId)
            if stageInfo.Difficult == XFubenManager.DifficultNormal then
                diffMsg = CS.XTextManager.GetText("FubenDifficultyNormal", chapterCfg.OrderId, stageCfg.OrderId)
            elseif stageInfo.Difficult == XFubenManager.DifficultHard then
                diffMsg = CS.XTextManager.GetText("FubenDifficultyHard", chapterCfg.OrderId, stageCfg.OrderId)
            end
            res = diffMsg
        elseif stageInfo and stageInfo.Type == XFubenManager.StageType.Bfrt then
            local chapterCfg = XDataCenter.FubenMainLineManager.GetChapterCfg(stageInfo.ChapterId)
            res = CS.XTextManager.GetText("FubenDifficultyNightmare", chapterCfg.OrderId, stageCfg.OrderId)
        else
            res = stageCfg.Name
        end
        return res
    end

    function XFubenManager.GetDiccicultIcon(stageId)
        local stageInfo = XFubenManager.GetStageInfo(stageId)
        if stageInfo then
            if stageInfo.Type == XFubenManager.StageType.Mainline then
                if stageInfo.Difficult == XFubenManager.DifficultNormal then
                    return CS.XGame.Config:GetString("StageNomraIcon")
                elseif stageInfo.Difficult == XFubenManager.DifficultHard then
                    return CS.XGame.Config:GetString("StageHardIcon")
                end
            elseif stageInfo.Type == XFubenManager.StageType.Bfrt then
                return CS.XGame.Config:GetString("StageFortress")
            elseif stageInfo.Type == XFubenManager.StageType.Resource then
                return CS.XGame.Config:GetString("StageResourceIcon")
            elseif stageInfo.Type == XFubenManager.StageType.Daily then
                return CS.XGame.Config:GetString("StageDailyIcon")
            end
        end
        return CS.XGame.Config:GetString("StageNomraIcon")
    end

    function XFubenManager.GetFubenOpenTips(stageId, default)
        local curStageCfg = XFubenManager.GetStageCfg(stageId)

        local preStageIds = curStageCfg.PreStageId
        if #preStageIds > 0 then
            for k, preStageId in pairs(preStageIds) do
                local stageInfo = XFubenManager.GetStageInfo(preStageId)
                if not stageInfo.Passed then
                    local title = XFubenManager.GetFubenTitle(preStageId)
                    return CS.XTextManager.GetText("FubenPreStage", title)
                end
            end
        end

        if XDataCenter.BfrtManager.CheckStageTypeIsBfrt(stageId) then
            local groupId = XDataCenter.BfrtManager.GetGroupIdByBaseStage(stageId)
            local preGroupUnlock, preGroupId = XDataCenter.BfrtManager.CheckPreGroupUnlock(groupId)
            if not preGroupUnlock then
                local preStageId = XDataCenter.BfrtManager.GetBaseStage(preGroupId)
                local title = XFubenManager.GetFubenTitle(preStageId)
                return CS.XTextManager.GetText("FubenPreStage", title)
            end
        end

        if XPlayer.Level < curStageCfg.RequireLevel then
            return CS.XTextManager.GetText("FubenNeedLevel", curStageCfg.RequireLevel)
        end

        if default then
            return default
        end
        return CS.XTextManager.GetText("NotUnlock")
    end

    function XFubenManager.GetAssistTemplateInfo()
        local info = {
            IsHasAssist = false
        }

        if BeginData and BeginData.IsHasAssist then
            info.IsHasAssist = BeginData.IsHasAssist
            if BeginData.AssistPlayerData == nil then
                info.FailAssist = CS.XTextManager.GetText("GetAssistFail")
            end
        end

        if BeginData and BeginData.AssistPlayerData then
            local template = XDataCenter.AssistManager.GetAssistRuleTemplate(BeginData.AssistPlayerData.RuleTemplateId)
            if template then
                info.Title = template.Title
                if BeginData.AssistPlayerData.NpcData and BeginData.AssistPlayerData.Id > 0 then
                    info.Sign = BeginData.AssistPlayerData.Sign
                    info.Name = BeginData.AssistPlayerData.Name
                    local headPortraitInfo = XPlayerManager.GetHeadPortraitInfoById(BeginData.AssistPlayerData.HeadPortraitId)
                    if (headPortraitInfo ~= nil) then
                        info.Image = headPortraitInfo.ImgSrc
                    end
                    AssistSuccess = true
                end
                if info.Sign == "" or info.Sign == nil then
                    info.Sign = CS.XTextManager.GetText("CharacterSignTip")
                end
            end
        end

        return info
    end

    function XFubenManager.EnterChallenge(cb)
        XNetwork.Call(METHOD_NAME.EnterChallenge, nil, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end
            if cb then
                cb()
            end
        end)
    end

    -- 是否通过指定关卡
    -- function XFubenManager.CheckStageIsPass(stageId)
    --     local stageInfo = XFubenManager.GetStageInfo(stageId)
    --     if stageInfo then
    --         return stageInfo.Passed
    --     else
    --         return false
    --     end
    -- end
    function XFubenManager.CheckStageIsPass(stageId)
        local stageInfo = XFubenManager.GetStageInfo(stageId)
        if stageInfo then
            if stageInfo.Type == XFubenManager.StageType.Bfrt then
                return XDataCenter.BfrtManager.IsGroupPassedByStageId(stageId)
            end

            return stageInfo.Passed
        end

        return false
    end

    function XFubenManager.GetStageLevelControl(stageId, playerLevel)
        playerLevel = playerLevel or XPlayer.Level
        return StageLevelMap[stageId] and StageLevelMap[stageId][playerLevel]
    end

    function XFubenManager.GetStageProposedLevel(stageId, level)
        local template = StageLevelMap[stageId] and StageLevelMap[stageId][level]
        return template and template.RecommendationLevel or 1
    end

    function XFubenManager.GetStageMultiplayerLevelControl(stageId, difficulty)
        return StageMultiplayerLevelMap[stageId] and StageMultiplayerLevelMap[stageId][difficulty]
    end

    function XFubenManager.CheckMultiplayerLevelControl(stageId)
        return StageMultiplayerLevelMap[stageId]
    end

    function XFubenManager.CtorPreFight(stage, teamId)
        local preFight = {}
        preFight.CardIds = {}
        preFight.StageId = stage.StageId
        if not stage.RobotId or #stage.RobotId <= 0 then
            local teamData = XDataCenter.TeamManager.GetTeamData(teamId)
            for _, v in pairs(teamData) do
                table.insert(preFight.CardIds, v)
            end
        end
        return preFight
    end

    function XFubenManager.CallOpenFightLoading(stageId)
        local stageInfo = XFubenManager.GetStageInfo(stageId)
        if not stageInfo then
            return
        end
        
        if OpenFightLoadingHandler[stageInfo.Type] then
            OpenFightLoadingHandler[stageInfo.Type](stageId)
        else
            XFubenManager.OpenFightLoading(stageId)
        end
    end

    function XFubenManager.OpenFightLoading(stageId)
        XEventManager.DispatchEvent(XEventId.EVENT_FIGHT_LOADINGFINISHED)

        local stageCfg = XDataCenter.FubenManager.GetStageCfg(stageId)

        if stageCfg and stageCfg.LoadingType then
            XLuaUiManager.Open("UiLoading", stageCfg.LoadingType)
        else
            XLuaUiManager.Open("UiLoading", LoadingType.Fight)
        end
    end

    function XFubenManager.CallCloseFightLoading(stageId)
        local stageInfo = XFubenManager.GetStageInfo(stageId)
        if CloseFightLoadingHandler[stageInfo.Type] then
            CloseFightLoadingHandler[stageInfo.Type](stageId)
        else
            XFubenManager.CloseFightLoading(stageId)
        end
    end

    function XFubenManager.CloseFightLoading(stageId)
        XLuaUiManager.Remove("UiLoading")
    end

    -- 通用结算
    function XFubenManager.SettleFight(result)
        if XFubenManager.FubenSettling then
            XLog.Warning("XFubenManager.SettleFight Warning, fuben is settling!")
            return
        end

        XFubenManager.StatisticsFightResultDps(result)
        XFubenManager.FubenSettling = true
        local fightResult = XFubenManager.CtorFightResult(result)
        XFubenManager.CurFightResult = fightResult

        if result.FightData.Online then
            if not result.IsForceExit then
                if XFubenManager.FubenSettleResult then
                    XLuaUiManager.SetMask(true)
                    XFubenManager.IsWaitingResult = true
                end
            end
        else
            XNetwork.Call(METHOD_NAME.FightSettle, { Result = fightResult }, function(res)
                XFubenManager.FubenSettleResult = res
                XEventManager.DispatchEvent(XEventId.EVENT_FUBEN_SETTLE_REWARD, res.Settle)
            end)
        end
    end

    function XFubenManager.FinishStoryRequest(stageId, cb)
        XNetwork.Call("EnterStoryRequest", {StageId = stageId}, function(res)
                cb = cb or function() end
                if res.Code == XCode.Success then
                    cb(res)
                else
                    XUiManager.TipCode(res.Code)
                end
            end)
    end
    
    function XFubenManager.CheckSettleFight()
        return XFubenManager.FubenSettleResult ~= nil
    end

    function XFubenManager.ExitFight()
        if XFubenManager.FubenSettleResult then
            CS.XFight.ExitForClient()
            return true
        end
        return false
    end

    function XFubenManager.ReadyToFight()
        CS.XFight.ReadyToFight()
    end

    function XFubenManager.CtorFightResult(result)
        local bytes = result:GetFightsResultsBytes()
        local fightResult = XMessagePack.Decode(bytes)

        -- 初始化数据结构
        XMessagePack.MarkAsTable(fightResult.IntToIntRecord)
        XMessagePack.MarkAsTable(fightResult.StringToIntRecord)
        XMessagePack.MarkAsTable(fightResult.Operations)
        XMessagePack.MarkAsTable(fightResult.NpcHpInfo)
        XMessagePack.MarkAsTable(fightResult.NpcDpsTable)

        return fightResult
    end

    function XFubenManager.GetFubenNames(stageId)
        local stage = XDataCenter.FubenManager.GetStageCfg(stageId)
        local stageInfo = XFubenManager.GetStageInfo(stageId)
        local chapterName, stageName
        local curStageType = stageInfo.Type

        if curStageType == XDataCenter.FubenManager.StageType.Tower then
            -- local section = XDataCenter.TowerManager.GetSectionCfgByMapId(stageId)
            -- local stageInfo = XDataCenter.TowerManager.GetStageCfg(stageId)
            -- chapterName = section.Name
            -- stageName = stageInfo.Name
        elseif curStageType == XDataCenter.FubenManager.StageType.Mainline then
            local stage = XDataCenter.FubenManager.GetStageCfg(stageId)
            local chapterInfo = XDataCenter.FubenMainLineManager.GetChapterInfo(stageInfo.ChapterId)
            local chapterMain = XDataCenter.FubenMainLineManager.GetChapterMainTemplate(chapterInfo.ChapterMainId)
            chapterName = chapterMain.ChapterName
            stageName = stage.Name
        elseif curStageType == XDataCenter.FubenManager.StageType.Urgent then
            local stageInfo = XDataCenter.FubenManager.GetStageCfg(stageId)
            chapterName = ""
            stageName = stage.Name
        elseif curStageType == XDataCenter.FubenManager.StageType.Daily then
            local stageInfo = XDataCenter.FubenManager.GetStageCfg(stageId)
            chapterName = stageInfo.stageDataName
            stageName = stage.Name
        elseif curStageType == XDataCenter.FubenManager.StageType.BossSingle then
            chapterName, stageName = XDataCenter.FubenBossSingleManager.GetBossNameInfo(stageInfo.BossSectionId, stageId)
        elseif curStageType == XDataCenter.FubenManager.StageType.Arena then
            local areaStageInfo = XDataCenter.ArenaManager.GetEnterAreaStageInfo()
            chapterName = areaStageInfo.ChapterName
            stageName = areaStageInfo.StageName
        end

        return chapterName, stageName
    end

    function XFubenManager.GetUnlockHideStageById(stageId)
        return UnlockHideStages[stageId]
    end

    function XFubenManager.EnterPrequelFight(stageId)
        local stageCfg = XFubenManager.GetStageCfg(stageId)
        local stageInfo = XFubenManager.GetStageInfo(stageId)
        if stageCfg and stageInfo then
            if stageInfo.Unlock then
                if stageCfg.RequireActionPoint > 0 then
                    if not XDataCenter.ItemManager.DoNotEnoughBuyAsset(XDataCenter.ItemManager.ItemId.ActionPoint,
                            stageCfg.RequireActionPoint,
                            1,
                            function() XFubenManager.EnterPrequelFight(stageId) end,
                            "FubenActionPointNotEnough") then
                        return
                    end
                end
                --
                for _, conditionId in pairs(stageCfg.ForceConditionId or {}) do
                    local ret, desc = XConditionManager.CheckCondition(conditionId)
                    if not ret then
                        XUiManager.TipError(desc)
                        return
                    end
                end
                XDataCenter.PrequelManager.UpdateShowChapter(stageId)
                XFubenManager.EnterFight(stageCfg, nil, false)
            else
                XUiManager.TipMsg(XFubenManager.GetFubenOpenTips(stageId))
            end
        end
    end

    -- Rpc相关
    function XFubenManager.OnSyncStageData(stageList)
        for k, v in pairs(stageList) do
            local oldStage = PlayerStageData[v.StageId]
            PlayerStageData[v.StageId] = v
            XEventManager.DispatchEvent(XEventId.EVENT_FUBEN_STAGE_SYNC, v.StageId)
        end
        XFubenManager.InitData(true)
    end

    function XFubenManager.OnSyncUnlockHideStage(unlockHideStage)
        UnlockHideStages[unlockHideStage] = true
    end

    function XFubenManager.OnFightSettleNotify(response)
        if XFubenManager.IsWaitingResult then
            XLuaUiManager.SetMask(false)
        end
        XFubenManager.IsWaitingResult = false
        XFubenManager.FubenSettleResult = response
        XEventManager.DispatchEvent(XEventId.EVENT_FUBEN_SETTLE_REWARD, response.Settle)
    end

    XFubenManager.Init()
    return XFubenManager
end


XRpc.NotifyStageData = function(data)
    XDataCenter.FubenManager.OnSyncStageData(data.StageList)
end

XRpc.OnEnterFight = function(data)
    -- 进入战斗前关闭所有弹出框
    XLuaUiManager.Remove("UiDialog")
    XDataCenter.FubenManager.OnEnterFight(data.FightData)
end

XRpc.NotifyUnlockHideStage = function(data)
    if not data then return end
    XDataCenter.FubenManager.OnSyncUnlockHideStage(data.UnlockHideStage)
end

XRpc.FightSettleNotify = function(response)
    XDataCenter.FubenManager.OnFightSettleNotify(response)
end