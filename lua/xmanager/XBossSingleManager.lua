XFubenBossSingleManagerCreator = function()

    local XFubenBossSingleManager = {}

    -- 重置倒计时
    local RESET_COUNT_DOWN_NAME = "SingleBossReset"

    -- templates
    local BossSingleGradeCfg = {}
    local RankRewardCfg = {}    -- key = levelType, value = {cfg}
    local ScoreRewardCfg = {}   -- key = levelType, value = {cfg}
    local BossSectionCfg = {}
    local BossChapterTemplates = {}
    local BossStageCfg = {}
    local BossSectionInfo = {}

    local FubenBossSingleData = {}
    local BossList = {}

    local LastSyncServerTimes = {}
    local RankData = {}
    local RankRole = {}
    local OnSyncBossDataCb = nil

    local RANK_SERVICE_NAME = "XRankService"
    local METHOD_NAME = {
        GetBossInfo = "BossSingleGetBossSingleDataRequest",
        GetRankData = "BossSingleGetRankRequest",
        GetReward = "BossSingleGetRewardRequest",
        AutoFight = "BossSingleAutoFightRequest",
        SaveScore = "BossSingleSaveScoreRequest",
    }

    local SYNC_SERVER_BOSS_SECOND = 20
    XFubenBossSingleManager.MAX_RANK_COUNT = CS.XGame.ClientConfig:GetInt("BossSingleMaxRanCount")

    function XFubenBossSingleManager.InitFubenBossSingleData(data)
        FubenBossSingleData = data
        XCountDown.CreateTimer(RESET_COUNT_DOWN_NAME, FubenBossSingleData.RemainTime)
    end

    function XFubenBossSingleManager.Init()
        BossSingleGradeCfg = XFubenBossSingleConfigs.GetBossSingleGradeCfg()
        BossSectionCfg = XFubenBossSingleConfigs.GetBossSectionCfg()
        BossSectionInfo = XFubenBossSingleConfigs.GetBossSectionInfo()
        BossStageCfg = XFubenBossSingleConfigs.GetBossStageCfg()
        RankRole = XFubenBossSingleConfigs.GetRankRole()
        ScoreRewardCfg = XFubenBossSingleConfigs.GetScoreRewardCfg()
        RankRewardCfg = XFubenBossSingleConfigs.GetRankRewardCfg()
       
        XFubenBossSingleManager.BOSS_SINGLE_CHALLENGE_COUNT = CS.XGame.Config:GetInt("BossSingleChallengeNum")
        XFubenBossSingleManager.MAX_STAMINA = CS.XGame.Config:GetInt("BossSingleMaxStamina")
    end

    function XFubenBossSingleManager.InitStageInfo()
        for sectionId, sectionCfg in pairs(BossSectionCfg) do
            for i = 1, #sectionCfg.StageId do
                local bossStageCfg = BossStageCfg[sectionCfg.StageId[i]]
                local stageInfo = XDataCenter.FubenManager.GetStageInfo(bossStageCfg.StageId)
                stageInfo.BossSectionId = sectionCfg.Id
                stageInfo.Type = XDataCenter.FubenManager.StageType.BossSingle
            end
        end
    end

    function XFubenBossSingleManager.GetResetCountDownName()
        return RESET_COUNT_DOWN_NAME
    end

    -- function XFubenBossSingleManager.FinishFight(settle)
    --     XDataCenter.FubenManager.ChallengeWin(settle)
    -- end
    function XFubenBossSingleManager.GetBossSingleTemplates()
        return BossChapterTemplates
    end

    function XFubenBossSingleManager.GetRankLevelCfg(type)
        local cfgs = {}
        for k, cfg in ipairs(BossSingleGradeCfg) do
            table.insert(cfgs, cfg)
        end

        table.sort(cfgs, function(a, b)
            return a.LevelType < b.LevelType
        end)

        return cfgs
    end

    function XFubenBossSingleManager.GetRankLevelCfgByType(type)
        return BossSingleGradeCfg[type]
    end

    function XFubenBossSingleManager.GetRankLevelCfgs()
        return BossSingleGradeCfg
    end

    function XFubenBossSingleManager.GetRankRewardCfg(levelType)
        return RankRewardCfg[levelType]
    end

    function XFubenBossSingleManager.GetScoreRewardCfg(levelType)
        return ScoreRewardCfg[levelType]
    end

    function XFubenBossSingleManager.GetBossSectionCfg(bossId)
        return BossSectionCfg[bossId]
    end

    function XFubenBossSingleManager.GetBossSectionInfo(bossId)
        return BossSectionInfo[bossId]
    end

    function XFubenBossSingleManager.GetBossStageCfg(bossStageId)
        return BossStageCfg[bossStageId]
    end

    function XFubenBossSingleManager.RefreshBossSingleData(bossSingleData)
        FubenBossSingleData = bossSingleData
        XCountDown.CreateTimer(RESET_COUNT_DOWN_NAME, FubenBossSingleData.RemainTime)
    end

    function XFubenBossSingleManager.GetCharacterChallengeCount(charId)
        return FubenBossSingleData.CharacterPoints[charId] or 0
    end

    function XFubenBossSingleManager.GetBoosSingleData()
        return FubenBossSingleData
    end

    function XFubenBossSingleManager.GetProposedLevel(stageId)
        local levelType = FubenBossSingleData.LevelType
        local bossSingleGradeCfg = BossSingleGradeCfg[levelType]
        return XDataCenter.FubenManager.GetStageProposedLevel(stageId, bossSingleGradeCfg.MaxPlayerLevel)
    end

    function XFubenBossSingleManager.GetScoreInfo(stageId, scoreData)
        local index = FubenBossSingleData.LevelType
        local cfg = RankRole[stageId]
        local bossLoseHpScore = 0
        if scoreData.BossTotalHp > 0 then
            bossLoseHpScore = math.floor(scoreData.BossLoseHp / scoreData.BossTotalHp / cfg.BossLoseHp[index] * cfg.BossLoseHpScore[index])
        end
        local leftTimeScore = math.floor(scoreData.LeftTime / cfg.LeftTime[index] * cfg.LeftTimeScore[index])
        local charLeftHpScore = 0
        if scoreData.CharTotalHp > 0 then
            charLeftHpScore = math.floor(scoreData.CharLeftHp / scoreData.CharTotalHp / cfg.CharLeftHp[index] * cfg.CharLeftHpSocre[index])
        end

        local scoreInfo = {
            BossLoseHpScore = bossLoseHpScore,
            LeftTimeScore = leftTimeScore,
            CharLeftHpScore = charLeftHpScore,
            AllScore = bossLoseHpScore + leftTimeScore + charLeftHpScore
        }
        return scoreInfo
    end

    function XFubenBossSingleManager.GetNpcScores(stageId, bossLeftHp, bossMaxHp)
        local levelType = FubenBossSingleData.LevelType
        local cfg = RankRole[stageId]
        if not cfg then
            XLog.Error("XFubenBossSingleManager.GetNpcScores error, stageId: " .. stageId)
            return 0
        end
        local bossLoseHpScore = 0
        if bossMaxHp > 0 then
            bossLoseHpScore = math.floor((bossMaxHp - bossLeftHp) / bossMaxHp / cfg.BossLoseHp[levelType] * cfg.BossLoseHpScore[levelType])
        end
        return bossLoseHpScore
    end

    -- 检查奖励是否领取
    function XFubenBossSingleManager.CheckRewardGet(rewardId)
        local rewardIds = FubenBossSingleData.RewardIds
        for _, id in pairs(rewardIds) do
            if rewardId == id then
                return true
            end
        end
        return false
    end

    -- 检查奖励是否还有奖励需要领取
    function XFubenBossSingleManager.CheckRewardRedHint()
        local index = FubenBossSingleData.LevelType
        local cfgs = XFubenBossSingleManager.GetScoreRewardCfg(index)
        local totalScore = FubenBossSingleData.TotalScore
        local rewardIds = FubenBossSingleData.RewardIds

        for _, v in pairs(cfgs) do
            local canGet = totalScore >= v.Score
            local got = false
            if canGet then
                for _, id in pairs(rewardIds) do
                    if id == v.Id then 
                        got = true
                        break
                    end
                end

                if not got then 
                    return 1
                end
            end
        end

        return -1
    end

    -- 检查自动战斗保存
    function XFubenBossSingleManager.CheckAtuoFight(stageId)
        for _, v in pairs(FubenBossSingleData.HistoryList) do
            if v.StageId == stageId then 
                return v
            end
        end

        return nil
    end

    function XFubenBossSingleManager.CheckStagePassed(sectionId, index)
        local sectionInfo = XFubenBossSingleManager.GetBossSectionInfo(sectionId)
        local stageId = sectionInfo[index].StageId
        local stageInfo = XDataCenter.FubenManager.GetStageInfo(stageId)
        return stageInfo.Unlock
    end

    function XFubenBossSingleManager.GetCurScoreRewardCfg()
        local curSocre = FubenBossSingleData.TotalScore
        local levelType = FubenBossSingleData.LevelType

        for i = 1, #ScoreRewardCfg[levelType] do
            if curSocre < ScoreRewardCfg[levelType][i].Score then
                return ScoreRewardCfg[levelType][i]
            end
        end
    end

    function XFubenBossSingleManager.GetCurBossIndex(bossId)
        local sectionInfo = XFubenBossSingleManager.GetBossSectionInfo(bossId)
        for i = 1, #sectionInfo do
            local stageInfo = XDataCenter.FubenManager.GetStageInfo(sectionInfo[i].StageId)
            if not stageInfo.Passed then
                return sectionInfo[i].DifficultyType
            end
        end
        return #sectionInfo
    end

    function XFubenBossSingleManager.CheckBossAllPassed(bossId)
        local sectionInfo = XFubenBossSingleManager.GetBossSectionInfo(bossId)
        for i = 1, #sectionInfo do
            local stageInfo = XDataCenter.FubenManager.GetStageInfo(sectionInfo[i].StageId)
            if not stageInfo.Passed then
                return false
            end
        end
        return true
    end

    function XFubenBossSingleManager.GetBossCurDifficultyInfo(bossId, index)
        local sectionInfo = XFubenBossSingleManager.GetBossSectionInfo(bossId)
        local sectionCfg = XFubenBossSingleManager.GetBossSectionCfg(bossId)
        local curBossCfg = sectionInfo[#sectionInfo]
        for i = 1, #sectionInfo do
            local stageInfo = XDataCenter.FubenManager.GetStageInfo(sectionInfo[i].StageId)
            if not stageInfo.Passed then
                curBossCfg = sectionInfo[i]
                break
            end
        end

        local now = XTime.GetServerNowTimestamp()
        local tagTmepIcon = nil
        for i = 1, #sectionCfg.ActivityBeginTime do
           local stratTime = XTime.ParseToTimestamp(sectionCfg.ActivityBeginTime[i])
           local endTime = XTime.ParseToTimestamp(sectionCfg.ActivityEndTime[i])

           if stratTime and endTime and  now >= stratTime and now < endTime then
                tagTmepIcon = sectionCfg.ActivityTag[i]
                break
           end
        end

        local groupTempId = nil
        local groupTempName = nil
        local groupTempIcon = nil

        local levelTypeCfg = XFubenBossSingleManager.GetRankLevelCfgByType(FubenBossSingleData.LevelType)
        if levelTypeCfg and levelTypeCfg.GroupId[index] then
            groupTempId = levelTypeCfg.GroupId[index]
            local groupInfo = XFubenBossSingleConfigs.GetBossSingleGroupById(groupTempId)
            groupTempName = groupInfo.GroupName
            groupTempIcon = groupInfo.GroupIcon
        end

        local info = {
            bossName = curBossCfg.BossName,
            bossIcon = sectionCfg.BossHeadIcon,
            bossDiffiName = curBossCfg.DifficultyDesc,
            tagIcon = tagTmepIcon,
            groupId = groupTempId,
            groupName = groupTempName,
            groupIcon = groupTempIcon
        }
        return info
    end

    function XFubenBossSingleManager.GetBossNameInfo(bossId, stageId)
        local stageName = ""
        local chapterName = ""
        local sectionInfo = XFubenBossSingleManager.GetBossSectionInfo(bossId)
        for i = 1, #sectionInfo do
            if sectionInfo[i].StageId == stageId then
                local stageCfg = XDataCenter.FubenManager.GetStageCfg(stageId)
                local curBossStageCfg = XFubenBossSingleManager.GetBossStageCfg(sectionInfo[i].StageId)
                stageName = stageCfg.Name
                chapterName = curBossStageCfg.BossName
            end
        end
        return chapterName, stageName
    end

    function XFubenBossSingleManager.GetBossStageInfo(stageId)
        local bossId = XDataCenter.FubenManager.GetStageInfo(stageId).BossSectionId
        local sectionInfo = XFubenBossSingleManager.GetBossSectionInfo(bossId)
        for i = 1, #sectionInfo do
            if sectionInfo[i].StageId == stageId then
                return sectionInfo[i]
            end
        end
        return nil
    end

    function XFubenBossSingleManager.GetBossDifficultName(stageId)
        local name = ""
        local bossId = XDataCenter.FubenManager.GetStageInfo(stageId).BossSectionId
        local sectionInfo = XFubenBossSingleManager.GetBossSectionInfo(bossId)
        for i = 1, #sectionInfo do
            if sectionInfo[i].StageId == stageId then
                name = sectionInfo[i].DifficultyDesc
            end
        end
        return name
    end

    function XFubenBossSingleManager.GetRankSpecialIcon(num, levelType)
        if not levelType then
            levelType = FubenBossSingleData.LevelType
        end

        local cfgs = XFubenBossSingleManager.GetRankRewardCfg(levelType)
        return cfgs[num].RankIcon
    end

    function XFubenBossSingleManager.OpenBossSingleView(cfg)
        local func = function()
            XLuaUiManager.Open("UiFubenBossSingle", FubenBossSingleData, BossList, cfg)
        end
        XFubenBossSingleManager.GetBossInfo(func)
    end

    function XFubenBossSingleManager.GetBossInfo(cb)
        XNetwork.Call(METHOD_NAME.GetBossInfo, nil, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end
            local bossList = {}
            for _, v in pairs(res.BossList) do
                local data = {
                    BossId = v,
                    Open = true
                }
                table.insert(bossList, data)
            end

            table.sort(bossList, function(a, b)
                if a.Open ~= b.Open then
                    return a.Open
                end
                return a.BossId < b.BossId
            end)

            BossList = res.BossList
            XFubenBossSingleManager.RefreshBossSingleData(res.FubenBossSingleData)
            if cb then
                cb()
            end
        end)
    end

    function XFubenBossSingleManager.GetRankData(cb, levelType)
        local now = XTime.GetServerNowTimestamp()
        if LastSyncServerTimes[levelType]
        and LastSyncServerTimes[levelType] + SYNC_SERVER_BOSS_SECOND >= now then
            if cb then
                cb(RankData[levelType])
            end
            return
        end

        local req = { Level = levelType }
        XNetwork.Call(METHOD_NAME.GetRankData, req,
        function(response)
            if response.Code ~= XCode.Success then
                XUiManager.TipCode(response.Code)
                return
            end
            LastSyncServerTimes[levelType] = now

            local luaRankData = {}
            luaRankData.MineRankNum = response.RankNum
            luaRankData.HistoryMaxRankNum = response.HistoryNum
            luaRankData.LeftTime = response.LeftTime
            luaRankData.TotalCount = response.TotalCount
            luaRankData.rankData = {}

            if response.RankList and #response.RankList > 0 then
                XTool.LoopCollection(response.RankList, function(data)
                    local luaRankMetaData = {}
                    luaRankMetaData.PlayerId = data.Id
                    luaRankMetaData.RankNum = data.RankNum
                    luaRankMetaData.HeadPortraitId = data.HeadPortraitId
                    luaRankMetaData.Name = data.Name
                    luaRankMetaData.Score = data.Score
                    luaRankMetaData.CharacterHeadData = data.CharacterList or {}
                    table.insert(luaRankData.rankData, luaRankMetaData)
                end)
            end

            RankData[levelType] = luaRankData
            if cb then
                cb(RankData[levelType])
            end
        end)
    end

    function XFubenBossSingleManager.GetRankRewardReq(rewardId, cb)
        local req = { Id = rewardId }
        XNetwork.Call(METHOD_NAME.GetReward ,req, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            table.insert(FubenBossSingleData.RewardIds, rewardId)
            
            if cb then
                cb(res.RewardGoodsList)
            end
        end)
    end

    -- 自动战斗
    function XFubenBossSingleManager.AutoFight(stagedId, cb)
        local req = { StageId = stagedId }
        XNetwork.Call(METHOD_NAME.AutoFight ,req, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            if cb then
                cb()
            end
        end)
    end

    -- 保存战斗数据
    function XFubenBossSingleManager.SaveScore(stagedId, cb)
        local req = { StageId = stagedId }
        XNetwork.Call(METHOD_NAME.SaveScore ,req, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            if cb then
                cb()
            end
        end)
    end

    function XFubenBossSingleManager.OnSyncBossSingleData(bossSingleData)
        XFubenBossSingleManager.RefreshBossSingleData(bossSingleData)
    end

    function XFubenBossSingleManager.CheckPreFight(stage)
        local stageId = stage.StageId
        local stageInfo = XDataCenter.FubenManager.GetStageInfo(stageId)
        local curCount = XFubenBossSingleManager.GetBoosSingleData().ChallengeCount
        local allCount = XFubenBossSingleManager.BOSS_SINGLE_CHALLENGE_COUNT
        if allCount - curCount <= 0 then
            local msg = CS.XTextManager.GetText("FubenChallengeCountNotEnough")
            XUiManager.TipMsg(msg)
            return false
        end
        return true
    end

    -- 胜利 & 奖励界面
    function XFubenBossSingleManager.ShowReward(winData)
        if XDataCenter.FubenManager.CheckHasFlopReward(winData) then
            XLuaUiManager.Open("UiFubenFlopReward", function()
                XLuaUiManager.PopThenOpen("UiSettleWinSingleBoss", winData)
            end, winData)
        else
            XLuaUiManager.Open("UiSettleWinSingleBoss", winData)
        end
    end

    XFubenBossSingleManager.Init()
    return XFubenBossSingleManager
end

XRpc.NotifyFubenBossSingleData = function(data)
    XDataCenter.FubenBossSingleManager.OnSyncBossSingleData(data.FubenBossSingleData)
    XEventManager.DispatchEvent(XEventId.EVENT_FUBEN_SINGLE_BOSS_SYNC)
end