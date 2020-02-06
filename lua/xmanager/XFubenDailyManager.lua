XFubenDailyManagerCreator = function()
    local XFubenDailyManager = {}

    local TABLE_DAILY_DROP_GROUP = "Client/Fuben/Daily/DailyDropGroup.tab"
    local TABLE_DAILT_DUNGEON_RULES = "Share/Fuben/Daily/DailyDungeonRules.tab"
    local TABLE_DAILY_DUNGEON_DATA = "Share/Fuben/Daily/DailyDungeonData.tab"
    local TABLE_DAILY_SPECOAL_CONDITION = "Share/Fuben/Daily/DailySpecialCondition.tab"

    local METHOD_NAME = {
        ReceiveDailyReward = "ReceiveDailyRewardRequest",
    }

    local ConditionType = {
        LeverCondition = 1,
        EventCondition = 2,
    }

    local WEEK = 7
    local RefreshTime=0

    local DailyDungeonRulesTemplates = {}
    local DailyDungeonDataTemplates = {}
    local DailySpecialConditionTemplates = {}
    local DailyDropGroupTemplates = {}


    local DailyOpenDayMap = {}

    local DailySectionData = {}

    function XFubenDailyManager.Init()
        DailyDungeonRulesTemplates = XTableManager.ReadByIntKey(TABLE_DAILT_DUNGEON_RULES, XTable.XTableDailyDungeonRules, "Id")
        DailyDungeonDataTemplates = XTableManager.ReadByIntKey(TABLE_DAILY_DUNGEON_DATA, XTable.XTableDailyDungeonData, "Id")
        DailySpecialConditionTemplates = XTableManager.ReadByIntKey(TABLE_DAILY_SPECOAL_CONDITION, XTable.XTableDailySpecialCondition, "Id")
        DailyDropGroupTemplates = XTableManager.ReadByIntKey(TABLE_DAILY_DROP_GROUP, XTable.XTableDailyDropGroup, "Id")
    end

    function XFubenDailyManager.OpenFightLoading(stageId)
        XEventManager.DispatchEvent(XEventId.EVENT_FIGHT_LOADINGFINISHED)
        local stageInfo = XDataCenter.FubenManager.GetStageInfo(stageId)

        local stageCfg = XDataCenter.FubenManager.GetStageCfg(stageId)

        if stageCfg and stageCfg.LoadingType then
            XLuaUiManager.Open("UiLoading", stageCfg.LoadingType)
        else
            XLuaUiManager.Open("UiLoading", LoadingType.Fight)
        end

    end

    function XFubenDailyManager.CloseFightLoading(stageId)
        local stageInfo = XDataCenter.FubenManager.GetStageInfo(stageId)
        if stageInfo.DailyType == XDataCenter.FubenManager.ChapterType.EMEX then
            -- XLuaUiManager.Remove("UiOnLineLoading")
            XLuaUiManager.Remove("UiLoading")
        else
            XLuaUiManager.Remove("UiLoading")
        end
    end

    -- function XFubenDailyManager.ShowReward(winData)
    --     local stageInfo = XDataCenter.FubenManager.GetStageInfo(winData.StageId)
    --     if stageInfo.DailyType == XDataCenter.FubenManager.ChapterType.EMEX then
    --         XEventManager.DispatchEvent(XEventId.EVENT_FUBEN_SHOW_REWARD, winData)
    --     else
    --         XLuaUiManager.Open("UiSettleWin", winData)
    --     end
    -- end


    function XFubenDailyManager.InitFubenDailyData(fubenDailyData)
        -- if fubenDailyData.DailySectionData then
        --     for k, v in pairs(fubenDailyData.DailySectionData) do
        --         DailySectionData[k] = v
        --     end
        -- end
    end

    function XFubenDailyManager.GetDailySectionData(sectionId)
        return DailySectionData[sectionId]
    end


    function XFubenDailyManager.SyncDailyReward(sectionId)
        DailySectionData[sectionId].ReceiveReward = true
    end

    function XFubenDailyManager.GetDailyDungeonRulesList()
        return DailyDungeonRulesTemplates
    end

    function XFubenDailyManager.GetDailyDungeonRulesById(id)
        return DailyDungeonRulesTemplates[id]
    end

    function XFubenDailyManager.GetDailyDungeonDayOfWeek(Id)
        local tmpTab={}
        for k,v in pairs(DailyDungeonRulesTemplates[Id].OpenDayOfWeek) do
            table.insert(tmpTab,v)
        end
        return tmpTab
    end

    function XFubenDailyManager.IsDayLock(Id)

        for k,v in pairs(XFubenDailyManager.GetDailyDungeonDayOfWeek(Id)) do
            if v > 0 and k == XFubenDailyManager.GetNowDayOfWeekByRefreshTime()then
                return false
            end
        end
        return true
    end

    function XFubenDailyManager.GetConditionData(Id)
        local functionNameId = {}
        local data={}
        local dungeonRule=DailyDungeonRulesTemplates[Id]

        if dungeonRule.Type == XDataCenter.FubenManager.ChapterType.GZTX then--日常構造體特訓
            functionNameId = XFunctionManager.FunctionName.FubenDailyGZTX
        elseif dungeonRule.Type == XDataCenter.FubenManager.ChapterType.XYZB then--日常稀有裝備
            functionNameId = XFunctionManager.FunctionName.FubenDailyXYZB
        elseif dungeonRule.Type == XDataCenter.FubenManager.ChapterType.TPCL then--日常突破材料
            functionNameId = XFunctionManager.FunctionName.FubenDailyTPCL
        elseif dungeonRule.Type == XDataCenter.FubenManager.ChapterType.ZBJY then--日常裝備經驗
            functionNameId = XFunctionManager.FunctionName.FubenDailyZBJY
        elseif dungeonRule.Type == XDataCenter.FubenManager.ChapterType.LMDZ then--日常螺母大戰
            functionNameId = XFunctionManager.FunctionName.FubenDailyLMDZ
        elseif dungeonRule.Type == XDataCenter.FubenManager.ChapterType.JNQH then--日常技能强化
            functionNameId = XFunctionManager.FunctionName.FubenDailyJNQH
        end

        data.IsLock = not XFunctionManager.JudgeCanOpen(functionNameId)
        data.functionNameId=functionNameId

        return data
    end
    function XFubenDailyManager.GetOpenDayString(rule)
        --開放日顯示
        local tmpNum = {"One", "Two", "Three", "Four", "Five", "Six", "Diary"}
        local dayStr = ""
        local dayCount = 0
        local IsAllDay = false
        for i = 1, WEEK do
            if rule.OpenDayOfWeek[i] ~= 0 then
                dayStr = dayStr .. CS.XTextManager.GetText(tmpNum[i])
                dayCount = dayCount + 1
            end
        end

        if dayCount == WEEK then
            dayStr = CS.XTextManager.GetText("FubenDailyAllDayOpen")
            IsAllDay = true
        end

        return dayStr,IsAllDay
    end

    function XFubenDailyManager.GetMainLineFubenOrderId(stageId)
        local chapterCfg = XFubenMainLineConfigs.GetChapterCfg()
        for k1,v1 in pairs(chapterCfg) do
            for k2,v2 in pairs (v1.StageId) do
                if stageId == v2 then
                    return v1.OrderId.."-".. XDataCenter.FubenManager.GetStageCfg(v2).OrderId
                end
            end
        end
        return ""
    end

    function XFubenDailyManager.GetEventOpen(Id)
        local eventOpenData = {}
        local eventText=""
        local dungeonRule = DailyDungeonRulesTemplates[Id]
        local specialCondition = DailySpecialConditionTemplates
        local eventOpen = false
        local nowTime = XTime.GetServerNowTimestamp()
        local stratTime = 0
        local endTime = 0
        for k,v in pairs(dungeonRule.SpecialConditionId)do
            if v ~= 0 then
                if specialCondition[v].Type == ConditionType.LeverCondition then

                    local tmpCon = XConditionManager.CheckPlayerCondtion(specialCondition[v].IntParam[1])
                    eventOpen = eventOpen or tmpCon
                    if tmpCon and eventText == "" then eventText = specialCondition[v].Text end

                elseif specialCondition[v].Type == ConditionType.EventCondition then
                    stratTime = XTime.ParseToTimestamp(specialCondition[v].StringParam[1])
                    endTime = XTime.ParseToTimestamp(specialCondition[v].StringParam[2])
                    if stratTime and endTime then
                        local tmpCon = nowTime > stratTime and nowTime < endTime
                        eventOpen = eventOpen or tmpCon
                        if tmpCon and eventText == "" then eventText = specialCondition[v].Text end
                    end
                end
            else
                eventOpen = eventOpen or false
            end
        end
        eventOpenData.IsOpen = eventOpen
        eventOpenData.Text = eventText
        return eventOpenData
    end


    function XFubenDailyManager.GetDailyDungeonDataList()
        return DailyDungeonDataTemplates
    end


    function XFubenDailyManager.GetDailyDungeonData(Id)
        return DailyDungeonDataTemplates[Id]
    end

    function XFubenDailyManager.GetDailySpecialConditionList()
        return DailySpecialConditionTemplates
    end


    function XFubenDailyManager.GetDailyDropGroupList()
        return DailyDropGroupTemplates
    end

    function XFubenDailyManager.GetDropDataList(Id,dayOfWeek)--根据日期获得掉落的物品组
        local RandomDrop={}
        local FixedDrop={}
        local DropGroupDatas={}
        for k,v in pairs(DailyDropGroupTemplates)do
            if v.DungeonId == Id then
                table.insert(DropGroupDatas, v )
            end
        end

        for k,v in pairs(DropGroupDatas)do
            if v.OpenDayOfWeek == dayOfWeek then
                RandomDrop = XRewardManager.GetRewardList(v.RandomRewardId)

                FixedDrop = XRewardManager.GetRewardList(v.FixedRewardId)

            end
        end
        return RandomDrop,FixedDrop
    end

    function XFubenDailyManager.GetNowDayOfWeekByRefreshTime()

        local toDay = XTime.DayOfWeekToInt(CS.XDateUtil.GetGameNow().DayOfWeek)
        local nowTime = XTime.GetServerNowTimestamp()
        local tmpTime = 0
        RefreshTime = RefreshTime or 0

        if RefreshTime - XTime.GetTodayTime(0,0,0) >= CS.XDateUtil.ONE_DAY_SECOND then
            tmpTime = RefreshTime - CS.XDateUtil.ONE_DAY_SECOND
        else
            tmpTime = RefreshTime
        end

        if nowTime < tmpTime then
            toDay = toDay - 1
        end

        if toDay <= 0 then
            toDay = toDay + 7
        end
        return toDay
    end

    function XFubenDailyManager.InitStageInfo()
        local DungeonDataList = XFubenDailyManager.GetDailyDungeonDataList()
        for id, chapter in pairs(DungeonDataList) do
            for _, stageId in pairs(chapter.StageId) do
                local stageInfo = XDataCenter.FubenManager.GetStageInfo(stageId)
                if stageInfo then
                    stageInfo.Type = XDataCenter.FubenManager.StageType.Daily
                    stageInfo.mode = XDataCenter.FubenManager.ModeType.SINGLE
                    stageInfo.stageDataName = chapter.Name
                end
            end
        end
    end


    -- 领取挑战奖励
    function XFubenDailyManager.ReceiveDailyReward(cb, dailySectionId)
        local req = { DailySectionId = dailySectionId }
        XNetwork.Call(METHOD_NAME.ReceiveDailyReward, req, function(res)
                if res.Code ~= XCode.Success then
                    XUiManager.TipCode(res.Code)
                    return
                end
                XFubenDailyManager.SyncDailyReward(dailySectionId)
                if cb then
                    cb(res.RewardGoodsList)
                end
            end)
    end

    function XFubenDailyManager.GetRemainCount()

    end

    function XFubenDailyManager.NotifyFubenDailyData(req)
        XTool.LoopMap(req.FubenDailyData.DailySectionData, function(k, v)
                DailySectionData[k] = v
                XEventManager.DispatchEvent(XEventId.EVENT_FUBEN_DAILY_REFRESH)
            end)
    end

    function XFubenDailyManager.NotifyDailyFubenRefreshTime(req)
        RefreshTime = req.RefreshTime
    end

    XFubenDailyManager.Init()
    return XFubenDailyManager
end

XRpc.NotifyFubenDailyData = function(req)
    XDataCenter.FubenDailyManager.NotifyFubenDailyData(req)
end

XRpc.NotifyDailyFuBenRefreshTime = function(req)
    XDataCenter.FubenDailyManager.NotifyDailyFubenRefreshTime(req)
end