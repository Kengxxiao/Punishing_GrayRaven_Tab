XBfrtManagerCreator = function()

    local pairs = pairs
    local ipairs = ipairs
    local string = string
    local table = table
    local tableInsert = table.insert
    local tableRemove = table.remove
    local tableSort = table.sort
    local FightCb
    local CloseLoadingCb

    -- 据点战管理器
    local XBfrtManager = {}

    --据点战梯队类型
    XBfrtManager.EchelonType = {
        Fight = 0, --作战梯队
        Logistics = 1, --后勤梯队
    }

    local METHOD_NAME = {
        GetBfrtDataRequest = "GetBfrtDataRequest",
        BfrtTeamSetRequest = "BfrtTeamSetRequest"
    }

    local BfrtChapterTemplates = {}
    local BfrtGroupTemplates = {}
    local EchelonInfoTemplates = {}

    local BfrtFollowGroupDic = {}
    local ChapterInfos = {}
    local GroupInfos = {}
    local ChapterDic = {}
    local GroupIdToOrderIdDic = {}
    local StageDic = {}
    local TaskIdToOrderIdDic = {}
    local GroupIdToChapterIdDic = {}

    --面板上显示的位置 = 队伍中实际中的位置
    local TEAM_POS_DIC = {
        [1] = 2,
        [2] = 1,
        [3] = 3,
    }

    local BfrtData = {}
    local FightTeams = {}
    local LogisticsTeams = {}

    local function IsGroupPassed(groupId)
        local records = BfrtData.BfrtGroupRecords
        if not records then
            return false
        end

        for _, record in pairs(records) do
            if record.Id == groupId then
                return true
            end
        end

        return false
    end

    function XBfrtManager.GetChapterInfo(chapterId)
        return ChapterInfos[chapterId]
    end

    local function GetGroupInfo(groupId)
        return GroupInfos[groupId]
    end

    function XBfrtManager.GetChapterCfg(chapterId)
        local chapterCfg = BfrtChapterTemplates[chapterId]
        if not chapterCfg then
            XLog.Error("XBfrtManager GetChapterCfg error: can not found chapterCfg, chapterId is " .. chapterId)
            return
        end
        return chapterCfg
    end

    local function GetGroupCfg(groupId)
        local groupCfg = BfrtGroupTemplates[groupId]
        if not groupCfg then
            XLog.Error("XBfrtManager GetGroupCfg error: can not found groupCfg, groupId is " .. groupId)
            return
        end
        return groupCfg
    end

    function XBfrtManager.GetStageIdList(groupId)
        local stageIdList = {}

        local groupCfg = GetGroupCfg(groupId)
        local seqList = string.ToIntArray(groupCfg.TeamFightSeq, '|')
        local originList = groupCfg.StageId
        for index, seq in ipairs(seqList) do
            stageIdList[index] = originList[seq]
        end

        return stageIdList
    end

    function XBfrtManager.GetFightInfoIdList(groupId)
        local fightInfoIdList = {}

        local groupCfg = GetGroupCfg(groupId)
        local seqList = string.ToIntArray(groupCfg.TeamFightSeq, '|')
        local originList = groupCfg.FightInfoId
        for index, seq in ipairs(seqList) do
            fightInfoIdList[index] = originList[seq]
        end

        return fightInfoIdList
    end

    function XBfrtManager.GetLogisticsInfoIdList(groupId)
        local groupCfg = GetGroupCfg(groupId)
        return groupCfg.LogisticsInfoId
    end

    local function GetEchelonInfo(echelonId)
        local echelon = EchelonInfoTemplates[echelonId]
        if not echelon then
            XLog.Error("XBfrtManager GetPosCondition error: can not found echelon, echelonId is " .. echelonId)
            return
        end

        return echelon
    end

    function XBfrtManager.GetGroupList(chapterId)
        local chapter = BfrtChapterTemplates[chapterId]
        if not chapter then
            XLog.Error("XBfrtManager.GetGroupList error: can not found bfrt chapter group, chapterId is " .. chapterId)
            return
        end

        return chapter.GroupId
    end

    function XBfrtManager.TeamPosConvert(index)
        return TEAM_POS_DIC[index]
    end

    local function CheckTeamLimit(echelonId, team)
        local needNum = XBfrtManager.GetEchelonNeedCharacterNum(echelonId)
        for i = 1, needNum do
            local characterId = team[i]
            if not characterId or characterId == 0 then
                return false
            end
        end

        return true
    end

    --获取各梯队需求人数
    function XBfrtManager.GetEchelonNeedCharacterNum(echelonId)
        local echelon = GetEchelonInfo(echelonId)
        return echelon and echelon.NeedCharacter
    end

    function XBfrtManager.InitStageInfo()
        for groupId, groupCfg in pairs(BfrtGroupTemplates) do
            local groupInfo = GroupInfos[groupId]
            local count = #groupCfg.StageId
            for k, v in pairs(groupCfg.StageId) do
                local stageInfo = XDataCenter.FubenManager.GetStageInfo(v)
                if not stageInfo then
                    XLog.Error("XBfrtManager InitStageInfo error.Can not find stage in Stage.tab,stageId in BfrtGroup.tab is: " .. v)
                    break
                end

                stageInfo.IsOpen = true
                stageInfo.Type = XDataCenter.FubenManager.StageType.Bfrt
                stageInfo.Unlock = groupInfo and groupInfo.Unlock or false
                stageInfo.ChapterId = groupInfo and groupInfo.ChapterId

            end

            local baseStageInfo = XDataCenter.FubenManager.GetStageInfo(groupCfg.BaseStage)
            baseStageInfo.IsOpen = true
            baseStageInfo.Type = XDataCenter.FubenManager.StageType.Bfrt
            baseStageInfo.Unlock = groupInfo and groupInfo.Unlock or false
            baseStageInfo.ChapterId = groupInfo and groupInfo.ChapterId
        end
    end

    local function InitGroupInfo()
        GroupInfos = {}
        for groupId, groupCfg in pairs(BfrtGroupTemplates) do
            local info = {}
            GroupInfos[groupId] = info
            GroupIdToOrderIdDic[groupId] = groupCfg.GroupOrderId

            info.Unlock = true
            local preGroupId = groupCfg.PreGroupId
            if preGroupId and preGroupId > 0 then
                info.Unlock = false
                for _, record in pairs(BfrtData.BfrtGroupRecords) do
                    if record.Id == preGroupId then
                        info.Unlock = true
                        break
                    end
                end
            end

            StageDic[groupCfg.BaseStage] = {
                GroupId = groupId,
                IsLastStage = false,
            }

            local count = #groupCfg.StageId
            for k, v in pairs(groupCfg.StageId) do
                local stageInfo = XDataCenter.FubenManager.GetStageInfo(v)
                if stageInfo then
                    stageInfo.Unlock = info.Unlock

                    StageDic[v] = {
                        GroupId = groupId,
                        IsLastStage = (k == count)
                    }
                else
                    XLog.Error("InitGroupInfo error. groupCfg.StageId = " .. tostring(v))
                end
            end
            info.Passed = IsGroupPassed(groupId)
        end
    end

    local function InitChapterInfo()
        ChapterInfos = {}
        for chapterId, chapterCfg in pairs(BfrtChapterTemplates) do
            ChapterDic[chapterCfg.OrderId] = chapterId
            local info = {}
            ChapterInfos[chapterId] = info
            info.ChapterId = chapterId
            if #chapterCfg.GroupId > 0 then
                local groupId = chapterCfg.GroupId[1]
                local groupInfo = GroupInfos[groupId]
                if groupInfo then
                    info.Unlock = groupInfo.Unlock
                end
            end

            local allPassed = true
            for k, v in pairs(chapterCfg.GroupId) do
                GroupIdToChapterIdDic[v] = chapterId

                local groupInfo = GroupInfos[v]
                groupInfo.OrderId = k
                groupInfo.ChapterId = chapterId

                local groupCfg = BfrtGroupTemplates[v]
                for k, v in pairs(groupCfg.StageId) do
                    local stageInfo = XDataCenter.FubenManager.GetStageInfo(v)
                    stageInfo.ChapterId = chapterId
                end

                if not groupInfo.Passed then
                    allPassed = false
                end
            end
            info.Passed = allPassed

            for orderId, taskId in ipairs(chapterCfg.TaskId) do
                TaskIdToOrderIdDic[taskId] = orderId
            end
        end
    end

    local function GetChpaterTaskIdList(chapterId)
        local chapterCfg = XBfrtManager.GetChapterCfg(chapterId)
        local taskIdList = chapterCfg.TaskId
        if not taskIdList then
            XLog.Error("XBfrtManager GetChpaterTaskIdList error: can not found bfrt chapter TaskId, chapterId is " .. chapterId)
        end
        return taskIdList
    end

    local function InitFollowGroup()
        for k, v in pairs(BfrtGroupTemplates) do
            if v.PreGroupId > 0 then
                local list = BfrtFollowGroupDic[v.PreGroupId]
                if not list then
                    list = {}
                end

                tableInsert(list, k)
                BfrtFollowGroupDic[v.PreGroupId] = list
            end
        end
    end

    local function InitTeamRecords()
        local records = BfrtData.BfrtGroupRecords
        if not records then return end

        for _, record in pairs(records) do
            local teamInfo = record.TeamInfo
            if teamInfo then
                local groupId = record.Id
                FightTeams[groupId] = teamInfo.FightTeamList
                LogisticsTeams[groupId] = teamInfo.LogisticsTeamList
            end
        end
    end

    local function UnlockFollowGroup(groupId)
        local list = BfrtFollowGroupDic[groupId]
        if not list then
            return
        end

        for _, id in pairs(list) do
            GroupInfos[id].Unlock = true

            local groupCfg = BfrtGroupTemplates[id]
            for k, v in pairs(groupCfg.StageId) do
                local stageInfo = XDataCenter.FubenManager.GetStageInfo(v)
                stageInfo.Unlock = true
            end

            local baseStageInfo = XDataCenter.FubenManager.GetStageInfo(groupCfg.BaseStage)
            baseStageInfo.Unlock = true

            local chapterId = XBfrtManager.GetChapterIdByGroupId(id)
            local chapterInfo = XBfrtManager.GetChapterInfo(chapterId)
            chapterInfo.Unlock = true
        end
    end

    function XBfrtManager.CheckActivityCondition(chapterId)
        local chapterCfg = XBfrtManager.GetChapterCfg(chapterId)
        local conditionId = chapterCfg.ActivityCondition
        if conditionId ~= 0 and not XConditionManager.CheckCondition(conditionId) then
            return false
        end
        return true
    end

    function XBfrtManager.CheckAnyTaskRewardCanGet(chapterId)
        local taskId = XBfrtManager.GetBfrtTaskId(chapterId)
        local taskData = XDataCenter.TaskManager.GetTaskDataById(taskId)
        return taskData and taskData.State == XDataCenter.TaskManager.TaskState.Achieved
    end

    --获取Chapter最新解锁的GroupId
    local function GetActiveGroupId()
        local activeGroupId
        for orderId, chapterId in pairs(ChapterDic) do
            local groupList = XBfrtManager.GetGroupList(chapterId)
            for _, groupId in ipairs(groupList) do
                if GroupInfos[groupId].Unlock then
                    activeGroupId = groupId
                end
            end
        end
        return activeGroupId
    end

    function XBfrtManager.GetTaskOrderId(taskId)
        return TaskIdToOrderIdDic[taskId]
    end

    local function TaskOrderIdSort(l, r)
        return XBfrtManager.GetTaskOrderId(l) < XBfrtManager.GetTaskOrderId(r)
    end

    function XBfrtManager.GetGroupIdByStageId(stageId)
        if not StageDic[stageId] then
            XLog.Error("XBfrtManager GetGroupIdByStageId error: can not found groupId in StageDic, stageId is " .. stageId)
            return
        end
        return StageDic[stageId].GroupId
    end

    function XBfrtManager.GetGroupIdByBaseStage(baseStage)
        return XBfrtManager.GetGroupIdByStageId(baseStage)
    end

    function XBfrtManager.Init()
        BfrtChapterTemplates = XBfrtConfigs.GetBfrtChapterTemplates()
        BfrtGroupTemplates = XBfrtConfigs.GetBfrtGroupTemplates()
        EchelonInfoTemplates = XBfrtConfigs.GetEchelonInfoTemplates()
    end

    function XBfrtManager.GetChapterList()
        return ChapterDic
    end

    function XBfrtManager.GetChapterInfoForOrder(orderId)
        local chapterId = ChapterDic[orderId]
        return ChapterInfos[chapterId]
    end

    function XBfrtManager.GetGroupRequireCharacterNum(groupId)
        local groupRequireCharacterNum = 0

        local fightInfoList = XBfrtManager.GetFightInfoIdList(groupId)
        for _, echelonId in pairs(fightInfoList) do
            groupRequireCharacterNum = groupRequireCharacterNum + XBfrtManager.GetEchelonNeedCharacterNum(echelonId)
        end

        local logisticsInfoList = XBfrtManager.GetLogisticsInfoIdList(groupId)
        for _, echelonId in pairs(logisticsInfoList) do
            groupRequireCharacterNum = groupRequireCharacterNum + XBfrtManager.GetEchelonNeedCharacterNum(echelonId)
        end

        return groupRequireCharacterNum
    end

    function XBfrtManager.CheckChapterNew(chapterId)
        local chapterInfo = XBfrtManager.GetChapterInfo(chapterId)
        return chapterInfo.Unlock and not chapterInfo.Passed
    end

    --获取当前最新解锁的Chapter
    function XBfrtManager.GetActiveChapterId()
        local activeChapterId = 1

        for orderId, chapterId in ipairs(ChapterDic) do
            local chapterInfo = XBfrtManager.GetChapterInfo(chapterId)
            if chapterInfo.Unlock then
                activeChapterId = chapterId
            end
        end

        return activeChapterId
    end

    function XBfrtManager.GetChapterOrderId(chapterId)
        local chapterCfg = XBfrtManager.GetChapterCfg(chapterId)
        return chapterCfg.OrderId
    end

    function XBfrtManager.GetGroupOrderId(groupId)
        local groupInfo = GetGroupInfo(groupId)
        return groupInfo.OrderId
    end

    --获取Chapter最新解锁的Group的OrderId
    function XBfrtManager.GetActiveGroupOrderId()
        local activeGroupId = GetActiveGroupId()
        local groupInfo = GetGroupInfo(activeGroupId)
        return groupInfo.OrderId
    end

    --获取Chapter最新解锁的Group的BaseStage
    function XBfrtManager.GetActiveBaseStageId()
        local activeGroupId = GetActiveGroupId()
        local groupCfg = GetGroupCfg(activeGroupId)
        return groupCfg.BaseStage
    end

    --获取Chapter中所有Group用于展示的BaseStage的List
    function XBfrtManager.GetBaseStageList(chapterId)
        local baseStageList = {}

        local groupList = XBfrtManager.GetGroupList(chapterId)
        for _, groupId in ipairs(groupList) do
            local groupCfg = GetGroupCfg(groupId)
            table.insert(baseStageList, groupCfg.BaseStage)
        end

        return baseStageList
    end

    function XBfrtManager.GetBaseStage(groupId)
        local groupCfg = GetGroupCfg(groupId)
        return groupCfg.BaseStage
    end

    function XBfrtManager.CheckBaseStageUnlock(baseStage)
        local groupId = XBfrtManager.GetGroupIdByBaseStage(baseStage)
        local groupInfo = GetGroupInfo(groupId)
        return groupInfo.Unlock
    end

    function XBfrtManager.IsGroupPassedByStageId(stageId)
        local groupId = XDataCenter.BfrtManager.GetGroupIdByStageId(stageId)
        local groupInfo = GetGroupInfo(groupId)
        return groupInfo.Passed
    end

    function XBfrtManager.GetLogisticSkillDes(echelonId)
        local echelon = GetEchelonInfo(echelonId)
        if not echelon.BuffId or echelon.BuffId == 0 then
            XLog.Error("XBfrtManager GetLogisticSkillDes error: do not have BuffId in echelon, echelonId is " .. echelonId)
            return
        end

        local fightEventCfg = CS.XNpcManager.GetFightEventTemplate(echelon.BuffId)
        return fightEventCfg and fightEventCfg.Description
    end

    function XBfrtManager.GetEchelonRequireAbility(echelonId)
        local echelon = GetEchelonInfo(echelonId)
        return echelon.RequireAbility
    end

    function XBfrtManager.GetEchelonConditionId(echelonId)
        local echelon = GetEchelonInfo(echelonId)
        return echelon.Condition
    end

    function XBfrtManager.CheckStageTypeIsBfrt(stageId)
        local stageInfo = XDataCenter.FubenManager.GetStageInfo(stageId)
        if stageInfo and stageInfo.Type == XDataCenter.FubenManager.StageType.Bfrt then
            return true
        end
        return false
    end

    function XBfrtManager.GetFightTeamList(groupId)
        local team = FightTeams[groupId] or {}
        return XTool.Clone(team)
    end

    function XBfrtManager.GetLogisticsTeamList(groupId)
        local team = LogisticsTeams[groupId] or {}
        return XTool.Clone(team)
    end

    function XBfrtManager.GetTotalTaskNum(chapterId)
        local taskIdList = GetChpaterTaskIdList(chapterId)
        return #taskIdList
    end

    function XBfrtManager.GetCurFinishTaskNum(chapterId)
        local finishTaskNum = 0
        local taskIdList = GetChpaterTaskIdList(chapterId)
        for _, taskId in pairs(taskIdList) do
            local taskData = XDataCenter.TaskManager.GetTaskDataById(taskId)
            if taskData then
                if taskData.State == XDataCenter.TaskManager.TaskState.Achieved or taskData.State == XDataCenter.TaskManager.TaskState.Finish then
                    finishTaskNum = finishTaskNum + 1
                end
            end
        end
        return finishTaskNum
    end

    function XBfrtManager.CheckAllTaskRewardHasGot(chapterId)
        local taskId = XBfrtManager.GetBfrtTaskId(chapterId)
        local taskData = XDataCenter.TaskManager.GetTaskDataById(taskId)
        return taskData and taskData.State == XDataCenter.TaskManager.TaskState.Finish
    end

    function XBfrtManager.GetBfrtTaskId(chapterId)
        local taskIdList = GetChpaterTaskIdList(chapterId)
        return taskIdList[1]
    end

    function XBfrtManager.CheckAllChapterReward()
        if not ChapterDic then return false end
        for _, chapterId in pairs(ChapterDic) do
            if XBfrtManager.CheckAnyTaskRewardCanGet(chapterId) then
                return true
            end
        end
        return false
    end

    function XBfrtManager.FinishStage(stageId)
        local stage = StageDic[stageId]
        if not stage or not stage.IsLastStage then
            return
        end

        local groupId = stage.GroupId
        GroupInfos[groupId].Passed = true

        local findRecord = false
        for _, record in pairs(BfrtData.BfrtGroupRecords) do
            if record.Id == groupId then
                record.Count = record.Count + 1
                findRecord = true
                break
            end
        end

        if not findRecord then
            local record = {
                Id = groupId,
                Count = 1,
            }
            tableInsert(BfrtData.BfrtGroupRecords, record)
        end

        UnlockFollowGroup(groupId)
    end

    function XBfrtManager.GetGroupFinishCount(baseStage)
        local records = BfrtData.BfrtGroupRecords
        if not records then
            return 0
        end

        local groupId = XBfrtManager.GetGroupIdByBaseStage(baseStage)
        for _, record in pairs(records) do
            if record.Id == groupId then
                return record.Count
            end
        end

        return 0
    end

    function XBfrtManager.GetGroupMaxChallengeNum(baseStage)
        local groupId = XBfrtManager.GetGroupIdByBaseStage(baseStage)
        local groupCfg = GetGroupCfg(groupId)
        return groupCfg.ChallengeNum
    end

    function XBfrtManager.GetChapterIdByGroupId(groupId)
        return GroupIdToChapterIdDic[groupId]
    end

    function XBfrtManager.GetEchelonNameTxt(echelonType, echelonIndex)
        local echelonNameTxt
        if echelonType == XBfrtManager.EchelonType.Fight then
            echelonNameTxt = CS.XTextManager.GetText("BfrtFightEchelonTitle", echelonIndex)
        elseif echelonType == XBfrtManager.EchelonType.Logistics then
            echelonNameTxt = CS.XTextManager.GetText("BfrtLogisticEchelonTitle", echelonIndex)
        end

        return echelonNameTxt
    end

    function XBfrtManager.OpenFightLoading(stageId)
        return
    end

    function XBfrtManager.CloseFightLoading(stage)
        if CloseLoadingCb then
            CloseLoadingCb()
        end

        local groupId = XBfrtManager.GetGroupIdByStageId(stage)
        local logisticsInfoIdList = XBfrtManager.GetLogisticsInfoIdList(groupId)
        local totalShowTimes = #logisticsInfoIdList
        if totalShowTimes > 0 then
            XLuaUiManager.Open("UiTipBfrtLogisticSkill", groupId)
        end
    end

    function XBfrtManager.FinishFight(settle)
        XDataCenter.FubenManager.FinishFight(settle)
        if FightCb then
            FightCb(settle.IsWin)
        end
    end

    function XBfrtManager.ShowReward(winData)
        if XBfrtManager.CheckIsGroupLastStage(winData.StageId) then
            XLuaUiManager.Open("UiBfrtPostWarCount", winData)
        end
    end

    function XBfrtManager.SetCloseLoadingCb(cb)
        CloseLoadingCb = cb
    end

    function XBfrtManager.SetFightCb(cb)
        FightCb = cb
    end

    function XBfrtManager.CheckIsGroupLastStage(stageId)
        local groupId = XBfrtManager.GetGroupIdByStageId(stageId)
        local stageIdList = XBfrtManager.GetStageIdList(groupId)
        return stageIdList[#stageIdList] == stageId
    end

    function XBfrtManager.GetGroupOrderIdByStageId(stageId)
        local groupId = XBfrtManager.GetGroupIdByStageId(stageId)
        return GroupIdToOrderIdDic[groupId]
    end

    function XBfrtManager.CheckPreGroupUnlock(groupId)
        local groupInfo = GetGroupInfo(groupId)
        local groupCfg = GetGroupCfg(groupId)
        return groupInfo.Unlock, groupCfg.PreGroupId
    end

    ----------------------服务端协议begin----------------------
    local function CheckFightTeamCondition(groupId, teamList)
        local infoList = XBfrtManager.GetFightInfoIdList(groupId)

        for k, echelonId in pairs(infoList) do
            local team = teamList[k]
            if not team then
                return false
            end

            if not CheckTeamLimit(echelonId, team) then
                return false
            end
        end

        return true
    end

    local function CheckLogisticsTeamCondition(groupId, teamList)
        local infoList = XBfrtManager.GetLogisticsInfoIdList(groupId)

        if not infoList or not next(infoList) then
            return true
        end

        for k, echelonId in pairs(infoList) do
            local team = teamList[k]
            if not team or not CheckTeamLimit(echelonId, team) then
                return false
            end
        end

        return true
    end

    function XBfrtManager.CheckTeam(groupId, fightTeamList, logisticsTeamList, cb)
        if not CheckFightTeamCondition(groupId, fightTeamList) then
            XUiManager.TipText("FightTeamConditionLimit")
            return
        end

        if not CheckLogisticsTeamCondition(groupId, logisticsTeamList) then
            XUiManager.TipText("LogisticsTeamConditionLimit")
            return
        end

        XNetwork.Call(METHOD_NAME.BfrtTeamSetRequest, {
            BfrtGroupId = groupId,
            FightTeam = fightTeamList, --List<List<int /*characterId*/> /*characterId list*/>
            LogisticsTeam = logisticsTeamList --List<List<int /*characterId*/> /*characterId list*/>
        }, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            FightTeams[groupId] = fightTeamList
            LogisticsTeams[groupId] = logisticsTeamList

            if cb then
                cb()
            end
        end)
    end

    function XBfrtManager.AutoTeam(groupId)
        local anyMemberInTeam = false
        local fightTeamList = {}
        local logisticsTeamList = {}
        local sortTeamInfoList = {}

        local fightInfoIdList = XBfrtManager.GetFightInfoIdList(groupId)
        for _, echelonId in ipairs(fightInfoIdList) do
            local fightTeam = { 0, 0, 0 }
            tableInsert(fightTeamList, fightTeam)

            local echelonCfg = GetEchelonInfo(echelonId)
            local teamInfo = {
                RequireAbility = echelonCfg.RequireAbility,
                NeedCharacter = echelonCfg.NeedCharacter,
                Team = fightTeam,
            }
            tableInsert(sortTeamInfoList, teamInfo)
        end

        local logisticsInfoIdList = XBfrtManager.GetLogisticsInfoIdList(groupId)
        for _, echelonId in ipairs(logisticsInfoIdList) do
            local logisticsTeam = { 0, 0, 0 }
            tableInsert(logisticsTeamList, logisticsTeam)

            local echelonCfg = GetEchelonInfo(echelonId)
            local teamInfo = {
                RequireAbility = echelonCfg.RequireAbility,
                NeedCharacter = echelonCfg.NeedCharacter,
                Team = logisticsTeam,
            }
            tableInsert(sortTeamInfoList, teamInfo)
        end

        tableSort(sortTeamInfoList, function(a, b)
            return a.RequireAbility > b.RequireAbility
        end)

        local ownCharacters = XDataCenter.CharacterManager.GetOwnCharacter()
        tableSort(ownCharacters, function(a, b)
            return a.Ability > b.Ability
        end)

        for _, teamInfo in pairs(sortTeamInfoList) do
            if not next(ownCharacters) then break end
            for memberIndex = 1, teamInfo.NeedCharacter do
                for index, character in ipairs(ownCharacters) do
                    -- if character.Ability >= teamInfo.RequireAbility then
                    teamInfo.Team[memberIndex] = character.Id
                    tableRemove(ownCharacters, index)
                    anyMemberInTeam = true
                    break
                    -- end
                end
            end
        end

        return fightTeamList, logisticsTeamList, anyMemberInTeam
    end

    function XBfrtManager.GetChapterPassCount(chapterId)
        local passCount = 0

        local groupList = XBfrtManager.GetGroupList(chapterId)
        for _, groupId in ipairs(groupList) do
            if GroupInfos[groupId].Passed then
                passCount = passCount + 1
            end
        end

        return passCount
    end

    function XBfrtManager.GetGroupCount(chapterId)
        local groupList = XBfrtManager.GetGroupList(chapterId)
        return #groupList
    end

    function XBfrtManager.NotifyBfrtData(data)
        BfrtData = data.BfrtData

        InitGroupInfo()
        InitChapterInfo()
        InitFollowGroup()
        InitTeamRecords()
    end
    ----------------------服务端协议end----------------------
    XBfrtManager.Init()
    return XBfrtManager
end

XRpc.NotifyBfrtData = function(data)
    XDataCenter.BfrtManager.NotifyBfrtData(data)
end