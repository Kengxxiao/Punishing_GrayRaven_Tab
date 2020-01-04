XTaskForceManagerCreator = function()

    --派遣
    local XTaskForceManager = {}

    --随机打乱
    local RandomBreakTableOrder = function(t)
        local index = 1
        local temp
        local total = #t
        for i = 1, total, 1 do
            for j = i + 1, total, 1 do
                index = math.random(j, total);
                temp = t[i];
                t[i] = t[index];
                t[index] = temp;
                break
            end
        end

        return t
    end

    --派遣任务状态
    XTaskForceManager.TaskForceTaskStatus = {
        Normal = 0,
        Accept = 1,
        Complete = 2,
    }

    local TaskForceConfig = {}
    local TaskForceExpendConfig = {}
    local TaskForceSectionConfig = {}
    local TaskForceTaskPoolConfig = {}
    local TaskForceCountConfig = {}

    local MaxRefreshTimes = 0 --最大刷新次数，可以超过
    local TotalFreeRefreshTimes = 0 -- 总的免费次数
    local TotalSectionCount = 0 -- 总的章节数


    local TaskForceInfo = {} --所有派遣信息
    local NextRefreshTime = -1

    local Condition = {}

    local XTaskForceRequest = {
        TaskForceRefreshRequest = "TaskForceRefreshRequest",
        AcceptTaskForceTaskRequest = "AcceptTaskForceTaskRequest",
        GiveUpTaskForceTaskRequest = "GiveUpTaskForceTaskRequest",
        TaskForceTaskFinishRequest = "TaskForceTaskFinishRequest",
        AcceptTaskForceRewardRequest = "AcceptTaskForceRewardRequest",
    }


    --初始化
    function XTaskForceManager.Init()
        XTaskForceManager.InitConfig()
    end


    --初始化表
    function XTaskForceManager.InitConfig()
        TaskForceConfig = XTaskForceConfigs.GetTaskForceConfig()
        TaskForceExpendConfig = XTaskForceConfigs.GetTaskForceExpendConfig()
        TaskForceSectionConfig = XTaskForceConfigs.GetTaskForceSectionConfig()
        TaskForceTaskPoolConfig = XTaskForceConfigs.GetTaskForceTaskPoolConfig()
        TaskForceCountConfig = XTaskForceConfigs.GetTaskForceCountConfig()

        MaxRefreshTimes = XTaskForceConfigs.MaxRefreshTimes
        TotalFreeRefreshTimes = XTaskForceConfigs.TotalFreeRefreshTimes
        TotalSectionCount = XTaskForceConfigs.TotalSectionCount
    end

    --获取章节表
    function XTaskForceManager.GetTaskForceSectionConfig()
        return TaskForceSectionConfig
    end

    --获取当前章节Id
    function XTaskForceManager.GetCurTaskForceSectionId()
        if not TaskForceInfo then
            return -1
        end

        return TaskForceInfo.SectionId
    end

    --获取派遣上限相关
    function XTaskForceManager.GetTaskForceConfigById(id)
        if not TaskForceConfig then
            XLog.Warning("TaskForceConfig can not find Id " .. tostring(id))
            return
        end

        return TaskForceConfig[id]
    end

    ---获取总章节数
    function XTaskForceManager.GetTotalTaskForeSectionCount()
        return TotalSectionCount
    end

    --获取章节
    function XTaskForceManager.GetTaskForceSectionConfigById(id)
        if not TaskForceSectionConfig then
            XLog.Warning("TaskForceSectionConfig can not find Id " .. tostring(id))
            return
        end

        return TaskForceSectionConfig[id]
    end

    ---获取派遣最大次数条件数据
    function XTaskForceManager.GetTaskForceConfigInfo()
        return TaskForceConfig
    end

    ---获取派遣数据
    function XTaskForceManager.GetTaskForeInfo()
        return TaskForceInfo
    end

    --获取下次更新时间
    function XTaskForceManager.GetNextRefreshTime()
        return NextRefreshTime
    end

    --获取最近一个要完成的派遣任务
    function XTaskForceManager.GetLatelyTaskForeInfo()
        if not TaskForceInfo then
            return
        end

        if not TaskForceInfo.TaskList or #TaskForceInfo.TaskList <= 0 then
            return
        end

        local taskForeInfo = nil
        for i, v in ipairs(TaskForceInfo.TaskList) do
            if v.Status == XTaskForceManager.TaskForceTaskStatus.Accept then
                if taskForeInfo then
                    taskForeInfo = taskForeInfo.UtcFinishTime < v.UtcFinishTime and taskForeInfo or v
                else
                    taskForeInfo = v
                end
            end
        end

        return taskForeInfo
    end

    --获取进行中的任务数量
    function XTaskForceManager.GetWorkingTaskCount()
        if not TaskForceInfo then
            return 0
        end

        if not TaskForceInfo.TaskList then
            return 0
        end

        local taskCount = 0
        for i, v in ipairs(TaskForceInfo.TaskList) do
            if v.Status ~= XTaskForceManager.TaskForceTaskStatus.Normal then
                taskCount = taskCount + 1
            end
        end

        return taskCount
    end


    --获取任务池数据
    function XTaskForceManager.GetTaskPoolInfo()

        if not TaskForceTaskPoolConfig then
            return
        end

        if not TaskForceInfo then
            return
        end

        local tasks = {}

        for i, v in ipairs(TaskForceInfo.TaskList) do
            local task = {}
            task.TaskCfg = TaskForceTaskPoolConfig[v.TaskId]
            task.Task = v
            task.IsWorking = v.Status ~= XTaskForceManager.TaskForceTaskStatus.Normal
            table.insert(tasks, task)
        end

        table.sort(tasks, function(a, b)
            return tonumber(a.Task.Status) > tonumber(b.Task.Status)
        end)

        return tasks
    end

    --获取免费刷新总次数
    function XTaskForceManager.GetTotalFreeRefreshTimes()
        return TotalFreeRefreshTimes
    end

    --获取刷新信息
    function XTaskForceManager.GetRefreshInfoByTimes(times)
        if not TaskForceExpendConfig then
            return
        end

        if times <= MaxRefreshTimes then
            return TaskForceExpendConfig[times]
        end

        return TaskForceExpendConfig[MaxRefreshTimes]
    end

    --刷新任务池
    function XTaskForceManager.CheckCanRefresh(id, count)
        if count < 0 then
            return false
        end

        local enough = XDataCenter.ItemManager.CheckItemCountById(id, count)
        if not enough then
            local itemName = XDataCenter.ItemManager.GetItemName(id)
            local text = CS.XTextManager.GetText('AssetsBuyConsumeNotEnough', itemName)
            XUiManager.TipMsg(text, XUiManager.UiTipType.Tip)
            return false
        end

        return true
    end

    --檢查隊伍條件
    function XTaskForceManager.CheckTeamCondition(taskId, characterIds)
        if #characterIds <= 0 then
            return false, CS.XTextManager.GetText("MissionConditionMemberLimit")
        end


        if not TaskForceTaskPoolConfig then
            return false
        end

        local taskCfg = TaskForceTaskPoolConfig[taskId]
        if not taskCfg then
            return false
        end

        local requireMemberCount = taskCfg.MemberCount
        if #characterIds < requireMemberCount then
            return false, CS.XTextManager.GetText("MissionConditionMemberLimit")
        end
        --[[    local characterLevelLimit = taskCfg.CharacterLevelLimit
        for i, id in ipairs(characterIds) do
            local character = XDataCenter.CharacterManager.GetCharacter(id)
            if character.Level < characterLevelLimit then
                return false, CS.XTextManager.GetText("MissionConditionNotEnough")
            end
        end]]
        --
        return true
    end

    local DefaultSort = function(a, b)

        if a.IsWorking ~= b.IsWorking then
            return a.IsWorking < b.IsWorking
        end

        if a.Level ~= b.Level then
            return a.Level > b.Level
        end

        if a.Quality ~= b.Quality then
            return a.Quality > b.Quality
        end

        local priorityA = XCharacterConfigs.GetCharacterPriority(a.Id)
        local priorityB = XCharacterConfigs.GetCharacterPriority(b.Id)

        if priorityA ~= priorityB then
            return priorityA < priorityB
        end

        return a.Id > b.Id
    end

    --获取可选择的角色
    function XTaskForceManager.GetOwnCharacterList()
        local characterList = XDataCenter.CharacterManager.GetOwnCharacterList()
        if not characterList then
            return
        end

        if not TaskForceInfo or not TaskForceInfo.TaskList or #TaskForceInfo.TaskList == 0 then
            return characterList
        end


        local workingId = {}
        for i, v in ipairs(TaskForceInfo.TaskList) do
            if v.Status ~= XTaskForceManager.TaskForceTaskStatus.Normal then
                local members = v.Members
                for _, id in ipairs(members) do
                    workingId[id] = true
                end
            end
        end

        for i, v in ipairs(characterList) do
            if workingId[v.Id] then
                v.IsWorking = 1
            else
                v.IsWorking = 0
            end
        end

        table.sort(characterList, DefaultSort)

        return characterList
    end


    --获取可选择的角色
    function XTaskForceManager.GetOwnCharacterCanTeamList()
        local characterList = XDataCenter.CharacterManager.GetOwnCharacterList()
        if not characterList then
            return
        end

        if not TaskForceInfo or not TaskForceInfo.TaskList or #TaskForceInfo.TaskList == 0 then
            return characterList
        end

        local workingId = {}
        for i, v in ipairs(TaskForceInfo.TaskList) do
            if v.Status ~= XTaskForceManager.TaskForceTaskStatus.Normal then
                local members = v.Members
                for _, id in ipairs(members) do
                    workingId[id] = true
                end
            end
        end

        local list = {}
        for i, v in ipairs(characterList) do
            if not workingId[v.Id] then
                table.insert(list, v.Id)
            end
        end

        return list
    end

    --一键选择
    function XTaskForceManager.AutoChoiceCharacter(taskId)
        local charIds = {}
        local emptyTable = {}
        if not TaskForceTaskPoolConfig then
            return emptyTable
        end

        local taskCfg = TaskForceTaskPoolConfig[taskId]
        if not taskCfg then
            return emptyTable
        end

        local requireMemberCount = taskCfg.MemberCount

        local charIds = XTaskForceManager.GetOwnCharacterCanTeamList()

        if not charIds or #charIds <= 0 then
            return emptyTable
        end

        --条件筛选
        local conditions = {}
        local conditionIds = taskCfg.ConditionList
        local conditionCount = #conditionIds
        for i, id in ipairs(conditionIds) do
            local conditionRequireMember = XTaskForceManager.GetConditionRequireMember(id)
            if conditionRequireMember == requireMemberCount then
                charIds = XTaskForceManager.FitterPriorityCondition(charIds, id)
            else
                local condition = {}
                condition.Id = id
                condition.Members = {}
                condition.MemberIndexs = {}
                condition.ConditionRequireMember = conditionRequireMember
                table.insert(conditions, condition)
            end
        end

        if not charIds or #charIds < requireMemberCount then
            return emptyTable
        end

        --如果没有需要匹配的条件
        if not conditions or #conditions <= 0 then
            local newCharIds = {}
            for i = 1, requireMemberCount, 1 do
                local rand = math.random(1, #charIds)
                table.insert(newCharIds, charIds[rand])
                table.remove(charIds, rand)
            end
            return newCharIds
        end

        --乱序
        charIds = RandomBreakTableOrder(charIds)

        --获得多个条件集合
        for index = 1, #conditions, 1 do
            local condition = conditions[index]
            for i, id in ipairs(charIds) do
                if XTaskForceManager.CheckCondition(condition.Id, id) then
                    condition.Members[id] = id
                    table.insert(condition.MemberIndexs, id)
                end
            end

            --某一个条件不满足
            if #condition.MemberIndexs < condition.ConditionRequireMember then
                return emptyTable
            end
        end

        local ret, charIds = XTaskForceManager.RandomMultContionCalculate(charIds, requireMemberCount, conditions)

        if not ret then
            return emptyTable
        end

        return charIds
    end

    --多条件随机算法
    function XTaskForceManager.RandomMultContionCalculate(charIds, requireCount, conditions)
        local charIdMap = {}
        local count = 0
        local ret = false

        ret, charIdMap, count = XTaskForceManager.RecursionCalculate(charIdMap, requireCount, conditions, count, 1)
        if not ret then
            return false
        end

        --提前满足条件，随机补充
        while count < requireCount do
            local rand = math.random(1, #charIds)
            local id = charIds[rand]
            if not charIdMap[id] then
                charIdMap[id] = id
                count = count + 1
            end
        end

        local Ids = {}
        for k, v in pairs(charIdMap) do
            table.insert(Ids, k)
        end

        return true, Ids
    end

    --递归检查条件
    function XTaskForceManager.RecursionCalculate(charIds, requireCount, conditions, count, index)

        --超出条件上限
        if index > #conditions then
            return false
        end

        local curCondition = conditions[index]

        for randIndex = 1, #curCondition.MemberIndexs do
            local id = curCondition.MemberIndexs[randIndex]
            if not charIds[id] then
                charIds[id] = id
                --检测是否行得通
                local result, refCount = XTaskForceManager.CheckAllConditionEnough(charIds, conditions, requireCount, count + 1)
                if result == 1 then
                    return true, charIds, count + 1
                elseif result == 0 then
                    if refCount[index] >= curCondition.ConditionRequireMember then
                        return XTaskForceManager.RecursionCalculate(charIds, requireCount, conditions, count + 1, index + 1)
                    else
                        count = count + 1
                    end
                else
                    charIds[id] = nil
                end
            end
        end

        return false
    end

    --检测
    --返回 1 完成
    --返回 0 继续
    --返回 -1 返回上一步
    function XTaskForceManager.CheckAllConditionEnough(charIds, conditions, requireCount, count)

        --检测每个条件的满足情况
        local refCount = {}
        local compeltedCount = 0
        for index, condition in ipairs(conditions) do
            refCount[index] = refCount[index] or 0
            for i, v in pairs(charIds) do
                if condition.Members[v] then
                    refCount[index] = refCount[index] + 1
                end
            end

            --当前条件的需求数量大于坑位数
            if refCount[index] >= condition.ConditionRequireMember then
                compeltedCount = compeltedCount + 1
            elseif condition.ConditionRequireMember - refCount[index] > requireCount - count then
                return -1
            end
        end

        --满足了所有条件
        if compeltedCount == #conditions then
            return 1
        end

        --没有坑位
        if count == requireCount then
            return -1
        end

        return 0, refCount

    end


    --过滤全条件不满足的构造体
    function XTaskForceManager.FitterPriorityCondition(charIdList, id)
        if not charIdList or #charIdList <= 0 then
            return
        end

        local newList = {}

        for i, charId in ipairs(charIdList) do
            if XTaskForceManager.CheckCondition(id, charId) then
                table.insert(newList, charId)
            end
        end

        return newList
    end

    --检测红点
    function XTaskForceManager.CheckTaskForceCompleted()

        if not TaskForceInfo or not TaskForceInfo.TaskList or #TaskForceInfo.TaskList == 0 then
            return false
        end

        for i, v in ipairs(TaskForceInfo.TaskList) do
            if v.Status == XTaskForceManager.TaskForceTaskStatus.Complete then
                return true
            end
        end

        return false
    end
    ------------------------------------------------------------
    --完成任务
    function XTaskForceManager.CompletedTaskForceTask(taskId)
        if not TaskForceInfo then
            return
        end

        if not TaskForceInfo.TaskList or #TaskForceInfo.TaskList <= 0 then
            return
        end

        for index, var in ipairs(TaskForceInfo.TaskList) do
            if var.TaskId == taskId then
                var.Status = XTaskForceManager.TaskForceTaskStatus.Complete
                break
            end
        end

    end


    --网络协议----------------------------
    --放弃任务
    function XTaskForceManager.GiveUpTaskForceTaskRequest(taskId)
        XNetwork.Call(XTaskForceRequest.GiveUpTaskForceTaskRequest, { TaskId = taskId }, function(resp)
            if resp.Code ~= XCode.Success then
                XUiManager.TipCode(resp.Code)
                return
            end

            if not TaskForceInfo then
                return
            end

            if not TaskForceInfo.TaskList or #TaskForceInfo.TaskList <= 0 then
                return
            end

            local removeIndex = -1
            for index, var in ipairs(TaskForceInfo.TaskList) do
                if var.TaskId == resp.TaskId then
                    var.Members = {}
                    var.Status = XTaskForceManager.TaskForceTaskStatus.Normal
                    break
                end
            end

            -- if removeIndex > 0 then
            --     table.remove(TaskForceInfo.TaskList, removeIndex)
            -- end
            XUiManager.TipMsg(CS.XTextManager.GetText("MissionGiveupSuccess"))


            XEventManager.DispatchEvent(XEventId.EVENT_TASKFORCE_GIVEUP_TASK_REQUEST)
        end)
    end

    --接受任务
    function XTaskForceManager.AcceptTaskForceTaskRequest(taskId, members, callback)
        XNetwork.Call(XTaskForceRequest.AcceptTaskForceTaskRequest, { TaskId = taskId, Members = members }, function(resp)
            if resp.Code ~= XCode.Success then
                XUiManager.TipCode(resp.Code)
                return
            end

            if not TaskForceInfo then
                return
            end

            local removeIndex = -1
            for index, v in ipairs(TaskForceInfo.TaskList) do
                if resp.TaskId == v.TaskId then
                    removeIndex = index
                    --v.Status = XTaskForceManager.TaskForceTaskStatus.Accept
                    break
                end
            end


            if removeIndex > 0 then
                TaskForceInfo.TaskList[removeIndex] = resp.TaskInfo
            end

            if callback then
                callback()
            end

            --XUiManager.TipMsg(CS.XTextManager.GetText("MissionSendSuccess"))
            XEventManager.DispatchEvent(XEventId.EVENT_TASKFORCE_ACCEPT_TASK_REQUEST)
        end)
    end

    --请求刷新任务池
    function XTaskForceManager.TaskForceRefreshRequest(cb)
        XNetwork.Call(XTaskForceRequest.TaskForceRefreshRequest, nil, function(resp)
            if resp.Code ~= XCode.Success then
                XUiManager.TipCode(resp.Code)
                return
            end

            if not TaskForceInfo then
                return
            end

            TaskForceInfo.TaskList = resp.TaskList
            TaskForceInfo.RefreshCount = TaskForceInfo.RefreshCount + 1

            --XUiManager.TipMsg(CS.XTextManager.GetText("MissionRefreshSuccess"))
            if cb then
                cb()
            end

            XEventManager.DispatchEvent(XEventId.EVENT_TASKFORCE_REFRESH_REQUEST)
        end)
    end

    --请求立即完成任务
    function XTaskForceManager.TaskForceTaskFinishRequest(taskId)
        XNetwork.Call(XTaskForceRequest.TaskForceTaskFinishRequest, { TaskId = taskId }, function(resp)
            if resp.Code ~= XCode.Success then
                XUiManager.TipCode(resp.Code)
                return
            end

            if not TaskForceInfo then
                return
            end

            if not TaskForceInfo.TaskList or #TaskForceInfo.TaskList <= 0 then
                return
            end

            for index, var in ipairs(TaskForceInfo.TaskList) do
                if var.TaskId == resp.TaskId then
                    var.Status = XTaskForceManager.TaskForceTaskStatus.Complete
                    break
                end
            end

            XEventManager.DispatchEvent(XEventId.EVENT_TASKFORCE_TASKFINISH_REQUEST, { taskId })

        end)
    end

    --请求领取奖励
    function XTaskForceManager.AcceptTaskForceRewardRequest(taskId, callback)
        XNetwork.Call(XTaskForceRequest.AcceptTaskForceRewardRequest, { TaskId = taskId }, function(resp)
            if resp.Code ~= XCode.Success then
                XUiManager.TipCode(resp.Code)
                return
            end

            if not TaskForceInfo then
                return
            end

            if not TaskForceInfo.TaskList or #TaskForceInfo.TaskList <= 0 then
                return
            end


            TaskForceInfo.TaskList = resp.TaskList

            local result = {}
            result.DropList = {}
            result.ExtraRewardList = {}
            result.Rewards = {}

            if resp.DropList and #resp.DropList > 0 then
                result.IsBigReward = true
                for i, var in ipairs(resp.DropList) do
                    table.insert(result.DropList, var)
                end
            end


            if resp.ExtraRewardList and #resp.ExtraRewardList > 0 then
                for i, var in ipairs(resp.ExtraRewardList) do
                    table.insert(result.ExtraRewardList, var)
                end
            end

            if resp.RewardList and #resp.RewardList > 0 then
                for i, var in ipairs(resp.RewardList) do
                    table.insert(result.Rewards, var)
                end
            end

            if callback then
                callback(result)
            end

            XEventManager.DispatchEvent(XEventId.EVENT_TASKFORCE_ACCEPT_REWARD_REQUEST)

        end)
    end

    XTaskForceManager.ShowMaxTaskForceTeamCountChangeTips = false
    XTaskForceManager.ShowMaxTaskForceCountChangeTips = false
    --消息推送
    function XTaskForceManager.TaskForceInfoNotify(data)

        if TaskForceInfo and TaskForceInfo.ConfigIndex then
            if data.TaskForceInfo.ConfigIndex ~= TaskForceInfo.ConfigIndex then
                XTaskForceManager.ShowMaxTaskForceTeamCountChangeTips = true
            end
        end

        TaskForceInfo = data.TaskForceInfo
        NextRefreshTime = data.NextRefreshTime


        XEventManager.DispatchEvent(XEventId.EVENT_TASKFORCE_INFO_NOTIFY)
    end

    --章节变化
    function XTaskForceManager.TaskForceSectionChangeNotify(data)
        if not TaskForceInfo then
            return
        end

        TaskForceInfo.SectionId = data.SectionId
        XEventManager.DispatchEvent(XEventId.EVENT_TASKFORCE_SECTIONCHANGE_NOTIFY)

    end

    --可派遣队伍最大数量改变通知
    function XTaskForceManager.MaxTaskForceCountChangeNotify(data)
        if not TaskForceInfo then
            return
        end

        if TaskForceCountConfig and TaskForceCountConfig[data.MaxTaskForceCount] then
            local config = TaskForceCountConfig[data.MaxTaskForceCount]
            TaskForceInfo.ConfigIndex = config.Id
        end

        XEventManager.DispatchEvent(XEventId.EVENT_TASKFORCE_MAXTASKFORCECOUNT_CHANGE_NOTIFY)
    end

    --任务完成
    function XTaskForceManager.TaskForceCompleteNotify(data)
        if not TaskForceInfo then
            return
        end

        local taskList = data.TaskList
        for i, taskId in ipairs(taskList) do
            XTaskForceManager.CompletedTaskForceTask(taskId)
        end

        XEventManager.DispatchEvent(XEventId.EVENT_TASKFORCE_COMPLETE_NOTIFY, data.TaskList)
    end

    function XTaskForceManager.HandlerPlayTipMission()
        if XDataCenter.TaskForceManager.ShowMaxTaskForceTeamCountChangeTips then
            local missionData = XDataCenter.TaskForceManager.GetTaskForeInfo()
            local taskForeCfg = XDataCenter.TaskForceManager.GetTaskForceConfigById(missionData.ConfigIndex)
            XUiManager.TipMsg(string.format(CS.XTextManager.GetText("MissionTaskTeamCountContent"), taskForeCfg.MaxTaskForceCount), nil, function()
                XEventManager.DispatchEvent(XEventId.EVENT_TASKFORCE_TIP_MISSION_END)
            end)
            XDataCenter.TaskForceManager.ShowMaxTaskForceTeamCountChangeTips = false
            return true
        end
        return false
    end
    ---------------------------------------
    local Condition = {
        [18105] = function(condition, characterId) -- 派遣中拥有指定数量指定兵种构造
            local character = XDataCenter.CharacterManager.GetCharacter(characterId)
            local npcId = XCharacterConfigs.GetCharNpcId(character.Id, character.Quality)
            local npcTemplate = CS.XNpcManager.GetNpcTemplate(npcId)
            if npcTemplate.Type == condition.Params[1] then
                return true
            end
            return false, condition.Desc
        end,

        [18106] = function(condition, characterId) -- 派遣中拥有指定数量达到指定战斗力的构造体
            return true
        end,

        [18107] = function(condition, characterId) -- 派遣中拥有指定数量达到指定品质的构造体
            local character = XDataCenter.CharacterManager.GetCharacter(characterId)
            if character.Quality >= condition.Params[1] then
                return true
            end
            return false, condition.Desc
        end,

        [18108] = function(condition, characterId) -- 派遣中拥有指定数量达到指定等级的构造体
            local character = XDataCenter.CharacterManager.GetCharacter(characterId)
            return character.Level >= condition.Params[1], condition.Desc
        end,

        [18109] = function(condition, characterId) -- 派遣中拥有指定数量指定性别的构造体
            local characterTemplate = XCharacterConfigs.GetCharacterTemplate(characterId)
            return characterTemplate.Sex == condition.Params[1], condition.Desc
        end,

        [18110] = function(condition, characterId) -- 派遣中拥有构造体
            if characterId == condition.Params[1] then
                return true
            end

            return false, condition.Desc
        end,
    }

    ---检查单个
    function XTaskForceManager.CheckCondition(conditionId, characterId)

        local template = XConditionManager.GetConditionTemplate(conditionId)
        if not template then
            XLog.Error("XConditionManager.CheckCharacterCondtion error: can not found template, id is " .. conditionId)
            return false
        end

        local func = Condition[template.Type]
        if not func then
            XLog.Error("XConditionManager.CheckCharacterCondtion error: can not found condition, id is " .. conditionId .. " type is " .. template.Type)
            return false
        end

        return func(template, characterId)
    end

    ---检查需求人数
    function XTaskForceManager.GetConditionRequireMember(conditionId)
        local template = XConditionManager.GetConditionTemplate(conditionId)
        if not template then
            XLog.Error("XConditionManager.CheckCharacterCondtion error: can not found template, id is " .. conditionId)
            return 0
        end

        if template.Type >= 18105 and template.Type < 18110 then
            return template.Params[2]
        end

        return 1
    end
    ------
    XTaskForceManager.Init()
    return XTaskForceManager
end

XRpc.TaskForceInfoNotify = function(data)
    XDataCenter.TaskForceManager.TaskForceInfoNotify(data)
end

XRpc.TaskForceSectionChangeNotify = function(data)
    XDataCenter.TaskForceManager.TaskForceSectionChangeNotify(data)
end

XRpc.MaxTaskForceCountChangeNotify = function(data)
    XDataCenter.TaskForceManager.MaxTaskForceCountChangeNotify(data)
end

XRpc.TaskForceCompleteNotify = function(data)
    XDataCenter.TaskForceManager.TaskForceCompleteNotify(data)
end