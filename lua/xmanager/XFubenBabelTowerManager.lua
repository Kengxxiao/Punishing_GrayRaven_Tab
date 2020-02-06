XFubenBabelTowerManagerCreator = function()
    local XFubenBabelTowerManager = {}

    local RequestRpc = {
        BabelTowerSelect = "BabelTowerSelectRequest",            --关卡选择请求
        BabelTowerStageReset = "BabelTowerStageResetRequest",    --关卡重置请求
        BabelTowerStageWipeOut = "BabelTowerStageWipeOutRequest",--关卡扫荡请求
    }

    local CurrentActivityNo = nil       --当前活动id
    local CurrentActivityMaxScore = 0   --当前活动最高等级
    local CurrentRankLevel = 0          --当前排行榜等级
    local BabelActivityStatus = {}      --{活动id = 活动状态}
    local BabelActivityStages = {}      --{活动id = 活动Stage列表}
    local Stage2ActivityMap = {}        --{stageId = activityId}

    local StageDefaultBuffList = {}     --{stageId = {groupId=bufferId, ...}, ...}

    local CurStageId = nil              -- 当前通关的副本
    local CurStageGuideId = nil         -- 当前通关的副本阶段
    local CurTeamList = nil             -- 当前组队信息
    local ChallengeBuffList = nil       -- 当前选择的挑战信息
    local SupportBuffList = nil         -- 当前选择的支援信息

    function XFubenBabelTowerManager.InitStageInfo()
        local allBabelActivityTemplates = XFubenBabelTowerConfigs.GetAllBabelTowerActivityTemplate()
        if allBabelActivityTemplates then
            for _, activityTemplate in pairs(allBabelActivityTemplates) do
                for i, stageId in pairs(activityTemplate.StageId or {}) do
                    Stage2ActivityMap[stageId] = activityTemplate.Id
                    local stageInfo = XDataCenter.FubenManager.GetStageInfo(stageId)
                    if stageInfo then
                        stageInfo.Type = XDataCenter.FubenManager.StageType.BabelTower
                    end
                end
            end
            XFubenBabelTowerManager.RefreshStagePassed()
        end
    end

    function XFubenBabelTowerManager.OpenFightLoading(stageId)
        XDataCenter.FubenManager.OpenFightLoading(stageId)
    end

    function XFubenBabelTowerManager.CloseFightLoading(stageId)
        XDataCenter.FubenManager.CloseFightLoading(stageId)

        XLuaUiManager.Open("UiFightBabelTower", stageId, XFubenBabelTowerConfigs.BattleReady)
    end

    function XFubenBabelTowerManager.ShowReward(winData)
        if not winData or not winData.SettleData then
            XLuaUiManager.Open("UiSettleWin", winData)
            return 
        end
        
        XFubenBabelTowerManager.RefreshStagePassed()

        XLuaUiManager.Open("UiFightBabelTower", winData.SettleData.StageId, XFubenBabelTowerConfigs.BattleEnd)
    end

    -- stageInfo刷新

    -- 选中的关卡临时数据
    function XFubenBabelTowerManager.SaveCurStageInfo(stageId, guideId, teamList, challengeBuffs, supportBuffs)
        CurStageId = stageId
        CurStageGuideId = guideId
        CurTeamList = teamList
        ChallengeBuffList = challengeBuffs
        SupportBuffList = supportBuffs
    end

    function XFubenBabelTowerManager.GetCurStageInfo()
        return CurStageId, CurStageGuideId, CurTeamList, ChallengeBuffList, SupportBuffList
    end

    function XFubenBabelTowerManager.ClearCurStageInfo()
        CurStageId = nil
        CurStageGuideId = nil
        CurTeamList = nil
        ChallengeBuffList = nil
        SupportBuffList = nil
    end

    -- 保存本地数据
    function XFubenBabelTowerManager.SaveBabelTowerPrefs(key, value)
        if XPlayer.Id and CurrentActivityNo then
            key = string.format("%s_%s_%s", key, tostring(XPlayer.Id), tostring(CurrentActivityNo))
            CS.UnityEngine.PlayerPrefs.SetInt(key, value)
            CS.UnityEngine.PlayerPrefs.Save()
        end
    end

    function XFubenBabelTowerManager.GetBabelTowerPrefs(key, defaultValue)
        if XPlayer.Id and CurrentActivityNo then
            key = string.format("%s_%s_%s", key, tostring(XPlayer.Id), tostring(CurrentActivityNo))
            if CS.UnityEngine.PlayerPrefs.HasKey(key) then
                local babelTowerPref = CS.UnityEngine.PlayerPrefs.GetInt(key)
                return (babelTowerPref == nil or babelTowerPref == 0) and defaultValue or babelTowerPref
            end
        end
        return defaultValue
    end

    
    -- 是否为自选战略
    function XFubenBabelTowerManager.IsStageGuideAuto(guideId)
        local stageGuideTemplate = XFubenBabelTowerConfigs.GetBabelTowerStageGuideTemplate(guideId)
        return #stageGuideTemplate.BuffGroup <= 0 and #stageGuideTemplate.BuffId <= 0
    end

    function XFubenBabelTowerManager.GetBabelTowerStageInfo(stageId)
        if not BabelActivityStages[CurrentActivityNo] then return nil end
        return BabelActivityStages[CurrentActivityNo][stageId]
    end

    -- 获取扫荡stageId不可出站角色
    function XFubenBabelTowerManager.WipeOutBlackList(stageId)
        local blackList = {}

        if BabelActivityStages[CurrentActivityNo] then
            for id, stageInfo in pairs(BabelActivityStages[CurrentActivityNo]) do
                if stageId ~= id and stageInfo.TeamList and (not stageInfo.IsReset) then
                    for _, characterId in pairs(stageInfo.TeamList) do
                        if characterId ~= 0 then
                            blackList[characterId] = true
                        end
                    end
                end
            end
        end

        return blackList
    end

    function XFubenBabelTowerManager.GetActivityBeginTime(activityNo)
        local activityTemplate = XFubenBabelTowerConfigs.GetBabelTowerActivityTemplateById(activityNo)
        return XTime.ParseToTimestamp(activityTemplate.BeginTimeStr)
    end
    
    function XFubenBabelTowerManager.GetFightEndTime(activityNo)
        local activityTemplate = XFubenBabelTowerConfigs.GetBabelTowerActivityTemplateById(activityNo)
        return XTime.ParseToTimestamp(activityTemplate.FightEndTimeStr)
    end
    
    function XFubenBabelTowerManager.GetActivityEndTime(activityNo)
        local activityTemplate = XFubenBabelTowerConfigs.GetBabelTowerActivityTemplateById(activityNo)
        return XTime.ParseToTimestamp(activityTemplate.EndTimeStr)
    end
    
    function XFubenBabelTowerManager.GetBanCharacterIdsByBuff(challengeBuffList)
        local banCharacterIds = {}

        if challengeBuffList then
            for _, buffDatas in pairs(challengeBuffList) do
                local buffTemplate = XFubenBabelTowerConfigs.GetBabelTowerBuffTemplate(buffDatas.SelectBuffId)
                for k, banChar in pairs(buffTemplate.BanCharacterId) do
                    banCharacterIds[banChar] = true
                end
            end
        end

        return banCharacterIds
    end

    -- 获取可出站的角色列表
    function XFubenBabelTowerManager.GetSelectableTowerTeamListSort(stageId, teamList, challengeBuffList)
        local inTeamList = {}
        local ownCharacterList = XDataCenter.CharacterManager.GetOwnCharacterList()
        local unselectableList = {}
        local selectableList = {}
        for _, characterId in pairs(teamList or {}) do
            if characterId ~= 0 then
                inTeamList[characterId] = true
            end
        end
        
        -- 从拥有的角色中排除其他已经出战的角色
        if BabelActivityStages[CurrentActivityNo] then
            for id, stageInfo in pairs(BabelActivityStages[CurrentActivityNo]) do
                if stageId ~= id and stageInfo.TeamList and (not stageInfo.IsReset) then
                    for _, characterId in pairs(stageInfo.TeamList) do
                        if characterId ~= 0 then
                            unselectableList[characterId] = true
                        end
                    end
                end
            end
        end

        -- 排除选中buff的禁用角色
        if challengeBuffList then
            for _, buffDatas in pairs(challengeBuffList) do
                local buffTemplate = XFubenBabelTowerConfigs.GetBabelTowerBuffTemplate(buffDatas.SelectBuffId)
                for k, banChar in pairs(buffTemplate.BanCharacterId) do
                    unselectableList[banChar] = true
                end
            end
        end

        for _, character in pairs(ownCharacterList or {}) do
            if not unselectableList[character.Id] then
                table.insert(selectableList, {
                    IsInTeam = inTeamList[character.Id] or false,
                    CharacterId = character.Id
                })
            end
        end

        table.sort(selectableList, function(characterA, characterB)
            local characterAPriority = characterA.IsInTeam and 0 or 1
            local characterBPriority = characterB.IsInTeam and 0 or 1
            if characterAPriority == characterBPriority then
                return false
            end
            return characterAPriority > characterBPriority
        end)

        return selectableList
    end

    function XFubenBabelTowerManager.GetCurrentActivityNo()
        return CurrentActivityNo
    end

    function XFubenBabelTowerManager.GetCurrentActivityMaxScore()
        return CurrentActivityMaxScore
    end

    function XFubenBabelTowerManager.GetCurrentActivityScores()
        local curScore = 0
        local maxScore = CurrentActivityMaxScore
        if CurrentActivityNo ~= nil and BabelActivityStages[CurrentActivityNo] then 
            for stageId, stageServerInfo in pairs(BabelActivityStages[CurrentActivityNo]) do
                if not stageServerInfo.IsReset then
                    curScore = curScore + stageServerInfo.CurScore
                end
            end
        end

        return curScore, maxScore
    end

    -- stageId的引导关是否开启
    function XFubenBabelTowerManager.IsBabelStageGuideUnlock(stageId, guideId)
        local isStageUnlock, description = XFubenBabelTowerManager.IsBabelStageUnlock(stageId)
        if not isStageUnlock then
            return false
        end

        -- 上一关是否开启
        local stageTemplate = XFubenBabelTowerConfigs.GetBabelTowerStageTemplate(stageId)
        local stageServerInfo = XFubenBabelTowerManager.GetBabelTowerStageInfo(stageId)
        if not stageServerInfo then
            return stageTemplate.StageGuideId[1] == guideId
        else
            local stageGuideMap = {}
            for i = 1, #stageTemplate.StageGuideId do
                local curGuideId = stageTemplate.StageGuideId[i]
                stageGuideMap[curGuideId] = i
            end
            local maxIndex = (stageGuideMap[stageServerInfo.GuildId] or 0) + 1
            return maxIndex >= stageGuideMap[guideId] or false
        end
    end

    -- stageId是否开启
    function XFubenBabelTowerManager.IsBabelStageUnlock(stageId)
        -- 未到开启时间
        local activityNo = Stage2ActivityMap[stageId]
        if not XFubenBabelTowerManager.IsInActivityFightTime(activityNo) then
            return false, CS.XTextManager.GetText("BabelTowerNoneFight")
        end

        -- stage开启时间
        local stageTemplate = XFubenBabelTowerConfigs.GetBabelTowerStageTemplate(stageId)
        local now = XTime.GetServerNowTimestamp()
        local beginTime = XTime.ParseToTimestamp(stageTemplate.BeginTimeStr)
        local endTime = XTime.ParseToTimestamp(stageTemplate.EndTimeStr)
        if not beginTime or not endTime then
            return false, ""
        end
        if now < beginTime or now > endTime then
            return false, CS.XTextManager.GetText("BabelTowerNoneOpen")
        end
        
        -- 上一个stage是否开启
        local stageInfo = XDataCenter.FubenManager.GetStageInfo(stageId)
        local stageCfg = XDataCenter.FubenManager.GetStageCfg(stageId)
    
        local desc = ""
        for k, prestageId in pairs(stageCfg.PreStageId or {}) do
            if prestageId > 0 then
                local preStageConfigs = XFubenBabelTowerConfigs.GetBabelStageConfigs(prestageId)
                desc = CS.XTextManager.GetText("BabelTowerNotEnoughScore", preStageConfigs.Name, stageTemplate.PreStageScore)
            end
        end
        return stageInfo.Unlock, desc
    end

    -- 是否处于活动战斗时间
    function XFubenBabelTowerManager.IsInActivityFightTime(activityNo)
        if not activityNo then return false end
        local activityTemplate = XFubenBabelTowerConfigs.GetBabelTowerActivityTemplateById(activityNo)
        if not activityTemplate then return false end
        local serverStatus = BabelActivityStatus[activityNo]
        if serverStatus ~= XFubenBabelTowerConfigs.BabelTowerStatus.Open then return false end
        local now = XTime.GetServerNowTimestamp()
        local beginTime = XTime.ParseToTimestamp(activityTemplate.BeginTimeStr)
        local fightEndTime = XTime.ParseToTimestamp(activityTemplate.FightEndTimeStr)
        if not beginTime or not fightEndTime then
            return false
        end
        return now >= beginTime and now <= fightEndTime
    end

    -- 是否处于活动时间
    function XFubenBabelTowerManager.IsInActivityTime(activityNo)
        if not activityNo then return false end
        local activityTemplate = XFubenBabelTowerConfigs.GetBabelTowerActivityTemplateById(activityNo)
        if not activityTemplate then 
            return false 
        end
        local serverStatus = BabelActivityStatus[activityNo]
        if serverStatus ~= XFubenBabelTowerConfigs.BabelTowerStatus.Open and serverStatus ~= XFubenBabelTowerConfigs.BabelTowerStatus.FightEnd then
            return false
        end
        local now = XTime.GetServerNowTimestamp()
        local beginTime = XTime.ParseToTimestamp(activityTemplate.BeginTimeStr)
        local endTime = XTime.ParseToTimestamp(activityTemplate.EndTimeStr)
        if not beginTime or not endTime then return false end
        return now >= beginTime and now <= endTime
    end

    -- StageInfo相关

    -- 刷新通过的StageInfo
    -- 登录同步数据之后,刷新setWinDatas之后,InitStageInfo之后
    function XFubenBabelTowerManager.RefreshStagePassed()
        local allBabelActivityTemplates = XFubenBabelTowerConfigs.GetAllBabelTowerActivityTemplate()
        if allBabelActivityTemplates then
            for _, activityTemplate in pairs(allBabelActivityTemplates) do
                local activityStageList = BabelActivityStages[activityTemplate.Id]
                if not activityStageList then return end
                for i, stageId in pairs(activityTemplate.StageId or {}) do
                    local stageInfo = XDataCenter.FubenManager.GetStageInfo(stageId)
                    local stageCfg = XDataCenter.FubenManager.GetStageCfg(stageId)
                    if stageInfo then
                        stageInfo.Passed = activityStageList[stageId] ~= nil
                        stageInfo.Unlock = true
                        stageInfo.IsOpen = true

                        if stageCfg.RequireLevel > 0 and XPlayer.Level < stageCfg.RequireLevel then
                            stageInfo.Unlock = false
                            stageInfo.IsOpen = false
                        end

                        for k, prestageId in pairs(stageCfg.PreStageId or {}) do
                            if prestageId > 0 then
                                local needScore = XFubenBabelTowerConfigs.GetBabelTowerStageTemplate(stageId).PreStageScore or 0
                                local preScore = (activityStageList[prestageId] ~= nil) and activityStageList[prestageId].MaxScore or 0
                                if needScore > preScore then
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
    end

    -- RPC
    -- 选择关卡
    function XFubenBabelTowerManager.SelectBabelTowerStage(stageId, guideId, teamList, challengeBuffInfos, supportBuffInfos, func)
        XNetwork.Call(RequestRpc.BabelTowerSelect, { 
            StageId = stageId, 
            GuideId = guideId, 
            TeamList = teamList, 
            ChallengeBuffInfos = challengeBuffInfos, 
            SupportBuffInfos = supportBuffInfos
        }, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end
            if func then
                func()
            end
        end)
    end

    -- 重置关卡
    function XFubenBabelTowerManager.ResetBabelTowerStage(stageId, func)
        XNetwork.Call(RequestRpc.BabelTowerStageReset, {StageId = stageId}, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end
            if func then
                func()
            end
        end)
    end

    -- 扫荡关卡
    function XFubenBabelTowerManager.WipeOutBabelTowerStage(stageId, func)
        XNetwork.Call(RequestRpc.BabelTowerStageWipeOut, {StageId = stageId}, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end
            if func then
                func()
            end
        end)
    end

    -- 挑战缓存相关
    function XFubenBabelTowerManager.GetBuffListCacheByStageId(stageId)
        return StageDefaultBuffList[stageId] or {}
    end

    function XFubenBabelTowerManager.UpdateBuffListCache(stageId, challengeBuffList)
        StageDefaultBuffList[stageId] = {}
        for _, challengeBuffData in pairs(challengeBuffList) do
            StageDefaultBuffList[stageId][challengeBuffData.GroupId] = challengeBuffData.BufferId
        end
    end

    -- 初始化buff缓存
    function XFubenBabelTowerManager.InitStageBuffList(stageList)
        for _, stageInfo in pairs(stageList or {}) do
            StageDefaultBuffList[stageInfo.Id] = {}
            for _, challengeBuffData in pairs(stageInfo.ChallengeBuffInfos) do
                StageDefaultBuffList[stageInfo.Id][challengeBuffData.GroupId] = challengeBuffData.BufferId
            end
        end
    end

    -- 登录同步
    function XFubenBabelTowerManager.AsyncBabelTowerData(notifyData)
        if not notifyData then return end
        CurrentActivityNo = notifyData.ActivityNo
        CurrentActivityMaxScore = notifyData.MaxScore
        CurrentRankLevel = notifyData.RankLevel

        if not BabelActivityStages[CurrentActivityNo] then
            BabelActivityStages[CurrentActivityNo] = {}
        end
        local currActivityStageList = BabelActivityStages[CurrentActivityNo]
        for index, stageDetails in pairs(notifyData.StageInfos or {}) do
            currActivityStageList[stageDetails.Id] = stageDetails
        end

        XFubenBabelTowerManager.InitStageBuffList(notifyData.StageInfos)

        XFubenBabelTowerManager.RefreshStagePassed()
    end

    -- 同步活动状态
    function XFubenBabelTowerManager.AsyncActivityStatus(notifyData)
        if not notifyData then return end

        BabelActivityStatus[notifyData.ActivityNo] = notifyData.Status
        XEventManager.DispatchEvent(XEventId.EVENT_BABEL_ACTIVITY_STATUS_CHANGED)
    end

    -- 同步单个关卡数据
    function XFubenBabelTowerManager.AsyncActivityStageInfo(notifyData)
        if not notifyData then return end

        CurrentActivityMaxScore = notifyData.MaxScore

        local stageId = notifyData.StageInfo.Id
        local activityId = Stage2ActivityMap[stageId]
        if not BabelActivityStages[activityId] then
            BabelActivityStages[activityId] = {}
        end
        BabelActivityStages[activityId][stageId] = notifyData.StageInfo
        XFubenBabelTowerManager.RefreshStagePassed()
        
        XEventManager.DispatchEvent(XEventId.EVENT_BABEL_STAGE_INFO_ASYNC)
    end

    function XFubenBabelTowerManager.GetBabelTowerSection()
        local sections = {}
        
        if XFubenBabelTowerManager.IsInActivityTime(CurrentActivityNo) then
            local section = {
                Id = CurrentActivityNo,
                Type = XDataCenter.FubenManager.ChapterType.ActivityBabelTower,
                BannerBg = CS.XGame.ClientConfig:GetString("FubenBabelTowerBannerBg"),
            }
            
            table.insert(sections, section)
        end

        return sections
    end

    return XFubenBabelTowerManager
end

--登录，或者开启通知玩法数据,活动未开启不下发
XRpc.NotifyBabelTowerData = function(notifyData)
    XDataCenter.FubenBabelTowerManager.AsyncBabelTowerData(notifyData)
end

--通知活动状态，先下发这条协议，后下发NotifyBabelTowerData
XRpc.NotifyBabelTowerActivityStatus = function(notifyData)
    XDataCenter.FubenBabelTowerManager.AsyncActivityStatus(notifyData)
end

--更新单个关卡数据
XRpc.NotifyBabelTowerStageInfo = function(notifyData)
    XDataCenter.FubenBabelTowerManager.AsyncActivityStageInfo(notifyData)
end
