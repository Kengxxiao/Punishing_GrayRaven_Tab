XBountyTaskManagerCreator = function()

    local XBountyTaskManager = {}
    XBountyTaskManager.BountyTaskStatus = {
        ["Normal"]    = 0,
        ["DifficultStageWin"] = 1,
        ["Complete"]    = 2,
        ["AcceptReward"] = 3,
    }

    --最大任务数
    XBountyTaskManager.MAX_BOUNTY_TASK_COUNT = CS.XGame.Config:GetInt("BountyTaskCount")
    --最大刷新次數
    XBountyTaskManager.MAX_BOUNTY_TASK_REFRESH_COUNT = CS.XGame.Config:GetInt("BountyTaskRefreshCount")


    --赏金任务数据
    local BountyTaskInfo = nil
    local BountyTaskPreFightData = nil
    local BountyTaskFightData = nil
    --表数据
    local BountyTaskConfig = {}
    local BountyTaskRankConfig = {}
    local BountyTaskRandomEventConfig = {}
    local BountyTaskDifficultStageConfig = {}

    local FakeBountyTaskOrder = {}
    local SelectIndex = -1;
    local MaxRankLevel = 0

    local RefreshTime = -1

    --协议
    local BountyTaskRequest = {
        AcceptBountyTaskRequest = "AcceptBountyTaskRequest",
        AcceptBountyTaskRewardRequest = "AcceptBountyTaskRewardRequest",
        RefreshBountyTaskPoolRequest = "RefreshBountyTaskPoolRequest",
    }

    function XBountyTaskManager.Init()
        XBountyTaskManager.InitConfig()
    end

    --初始化表
    function XBountyTaskManager.InitConfig()
        BountyTaskConfig = XBountyTaskConfigs.GetBountyTaskConfig()
        BountyTaskRankConfig = XBountyTaskConfigs.GetBountyTaskRankConfig()
        BountyTaskRandomEventConfig = XBountyTaskConfigs.GetBountyTaskRandomEventConfig()
        BountyTaskDifficultStageConfig = XBountyTaskConfigs.GetBountyTaskDifficultStageConfig()

        --获取最高等级
        MaxRankLevel = XBountyTaskConfigs.MaxRankLevel
    end

    --登录下发
    function XBountyTaskManager.InitData(taskInfo)
        BountyTaskInfo = taskInfo
    end

    ---外部接口------------------------------------------------------
    ---获取任务数据
    function XBountyTaskManager.GetBountyTaskInfo()
        return BountyTaskInfo
    end

    --获取等级
    function XBountyTaskManager.GetBountyTaskInfoRankLevel()
        if not BountyTaskInfo then
            return 0
        end

        return BountyTaskInfo.RankLevel
    end


    --获取最大等级
    function XBountyTaskManager.GetMaxBountyTaskInfoRankLevel()
        return MaxRankLevel
    end

    --获取任务完成数量
    function XBountyTaskManager.GetBountyTaskCompletedCount()
        if not BountyTaskInfo then
            return 0
        end

        local taskCount = #BountyTaskInfo.TaskCards

        local completeCount = 0

        for index = 1, taskCount do
            if BountyTaskInfo.TaskCards[index].Status == XBountyTaskManager.BountyTaskStatus.Complete or BountyTaskInfo.TaskCards[index].Status == XBountyTaskManager.BountyTaskStatus.AcceptReward then
                completeCount = completeCount + 1
            end
        end

        return completeCount
    end


    --是否有可以领奖的任务
    function XBountyTaskManager.CheckBountyTaskCanReward()
        if not BountyTaskInfo then
            return false
        end

        local taskCount = #BountyTaskInfo.TaskCards

        for index = 1, taskCount do
            if BountyTaskInfo.TaskCards[index].Status == XBountyTaskManager.BountyTaskStatus.Complete then
                return true
            end
        end

        return false
    end

    --获取任务完成并且领奖的数量
    function XBountyTaskManager.GetBountyTaskCompletedAndAcceptRewardCount()
        if not BountyTaskInfo then
            return 0
        end

        local taskCount = #BountyTaskInfo.TaskCards

        local completeCount = 0

        for index = 1, taskCount do
            if  BountyTaskInfo.TaskCards[index].Status == XBountyTaskManager.BountyTaskStatus.AcceptReward then
                completeCount = completeCount + 1
            end
        end

        return completeCount
    end

    --获取排行奖励表格
    function XBountyTaskManager.GetBountyTaskRankTable()
        if not BountyTaskRankConfig then
            return nil
        end

        local config = {}
        for key, value in pairs(BountyTaskRankConfig) do
            table.insert(config, value)
        end

        table.sort(config, function(a, b)
            return b.RankLevel < a.RankLevel
        end)

        return config
    end

    --获取本地数据
    function XBountyTaskManager.GetBountyTaskConfig(id)
        if not BountyTaskConfig then
            return
        end

        if not BountyTaskConfig[id] then
            XLog:Debug("Get BountyTaskConfig err,id not exist " .. tostring(id))
            return
        end

        return BountyTaskConfig[id]
    end

    --获取随机事件数据
    function XBountyTaskManager.GetBountyTaskRandomEventConfig(eventId)
        if not BountyTaskRandomEventConfig then
            return
        end


        if not BountyTaskRandomEventConfig[eventId] then
            XLog:Debug("Get BountyTaskRandomEventConfig err,eventId not exist " .. tostring(eventId))
            return
        end

        return BountyTaskRandomEventConfig[eventId]
    end


    --获取等级数据
    function XBountyTaskManager.GetBountyTaskRankConfig(rankLevel)
        if not BountyTaskRankConfig then
            return
        end


        if not BountyTaskRankConfig[rankLevel] then
            XLog:Debug("Get BountyTaskRankConfig err,rankLevel not exist " .. tostring(rankLevel))
            return
        end


        return BountyTaskRankConfig[rankLevel]
    end


    --获取困难关卡数据
    function XBountyTaskManager.GetBountyTaskDifficultStageConfig(id)
        if not BountyTaskDifficultStageConfig then
            return
        end

        if not BountyTaskDifficultStageConfig[id] then
            XLog:Debug("Get BountyTaskDifficultStageConfig err,Id not exist " .. tostring(id))
            return
        end

        return BountyTaskDifficultStageConfig[id]
    end

    --设置选中索引
    function XBountyTaskManager.SetSelectIndex(index)
        SelectIndex = index
    end

    --获取选中索引
    function XBountyTaskManager.GetSelectIndex()
        return SelectIndex
    end

    --获取一个假的任务顺序
    function XBountyTaskManager.GetFakeTaskOrder()
        return FakeBountyTaskOrder
    end

    --是否是赏金任务完成
    function XBountyTaskManager.CheckBountyTaskHasReward()
        if not BountyTaskInfo or not BountyTaskInfo.TaskCards then
            return false
        end

        for i, task in ipairs(BountyTaskInfo.TaskCards) do
            if task.Status == XBountyTaskManager.BountyTaskStatus.Complete then
                return true
            end
        end

        return false
    end


    --是否是赏金前置困难副本
    function XBountyTaskManager.CheckBountyTaskPreFight(stageId)
        if not BountyTaskInfo or not BountyTaskInfo.TaskCards then
            return false
        end

        for i, var in ipairs(BountyTaskInfo.TaskCards) do
            if var.DifficultStageId == stageId then
                return true, var
            end
        end

        return false
    end

    --是否是赏金前置困难副本，判断状态
    function XBountyTaskManager.CheckBountyTaskPreFightWithStatus(stageId)
        local isPreFight, task = XBountyTaskManager.CheckBountyTaskPreFight(stageId)
        if task and (task.Status == XBountyTaskManager.BountyTaskStatus.Complete or task.Status == XBountyTaskManager.BountyTaskStatus.AcceptReward) then
            return false
        end
        return isPreFight, task
    end

    --是否是前置关卡
    function XBountyTaskManager.IsBountyPreFight()
        return BountyTaskPreFightData ~= nil
    end

    --是否是赏金关卡
    function XBountyTaskManager.IsBountyTaskFight()
        return BountyTaskFightData ~= nil
    end

    --获取赏金关卡数据
    function XBountyTaskManager.GetBountyTaskFightData()
        return BountyTaskFightData
    end

    --获取赏金刷新时间
    function XBountyTaskManager.GetRefreshTime()
        return RefreshTime
    end

    --设置上次进入赏金的时间
    function XBountyTaskManager.SetBountyTaskLastLoginTime()
        local key = tostring(XPlayer.Id) .. "_LastBountyTaskTime"
        CS.UnityEngine.PlayerPrefs.SetInt(key, XTime.Now())
    end

    --获取上次进入赏金的时间
    function XBountyTaskManager.GetBountyTaskLastLoginTime()
        local key = tostring(XPlayer.Id) .. "_LastBountyTaskTime"
        local lastLoginTime = CS.UnityEngine.PlayerPrefs.GetInt(key, -1)
        return lastLoginTime
    end

    --记录前置关卡战斗
    function XBountyTaskManager.RecordPreFightData(taskId, teamId, isHasAssist, assisPId, assistType)
        local bountyTask = XBountyTaskManager.GetBountyTaskConfig(taskId)
        if not bountyTask then
            return
        end

        BountyTaskPreFightData = {}
        BountyTaskPreFightData.taskId = taskId
        BountyTaskPreFightData.stageId = bountyTask.StageId
        BountyTaskPreFightData.teamId = teamId
        BountyTaskPreFightData.isHasAssist = isHasAssist
        BountyTaskPreFightData.assisPId = assisPId
        BountyTaskPreFightData.assistType = assistType
    end

    --进入战斗
    function XBountyTaskManager.EnterFight(result)
        if not BountyTaskPreFightData then
            return
        end

        local stage = XDataCenter.FubenManager.GetStageCfg(BountyTaskPreFightData.stageId)
        XDataCenter.FubenManager.EnterFight(stage, BountyTaskPreFightData.teamId)
        BountyTaskPreFightData = nil
        BountyTaskFightData = {}
        BountyTaskFightData.PreFightResult = result
    end

    --重置战斗数据
    function XBountyTaskManager.ResetFightData()
        BountyTaskFightData = nil
        BountyTaskPreFightData = nil
    end
    --------------------------------------------------------------
    --从池中抽取任务
    function XBountyTaskManager.GetTaskCardFromTaskPool(taskId)
        if not BountyTaskInfo or not BountyTaskInfo.TaskPool then
            return
        end

        local index = -1
        local taskCard = nil
        for i, var in ipairs(BountyTaskInfo.TaskPool) do
            if var.Id == taskId then
                taskCard = var
                index = i
                break
            end
        end

        if index == -1 or taskCard == nil then
            return
        end

        return taskCard
    end

    --完成任务
    function XBountyTaskManager.FinshedTask(taskId)
        if not BountyTaskInfo then
            return
        end

        for i, var in ipairs(BountyTaskInfo.TaskCards) do
            if var.Id == taskId then
                var.Status = XBountyTaskManager.BountyTaskStatus.Complete
                break
            end
        end
    end


    --领取奖励
    function XBountyTaskManager.GetBountyTaskReward(resp)
        if not BountyTaskInfo then
            return
        end

        local taskId = resp.TaskId

        for i, var in ipairs(BountyTaskInfo.TaskCards) do
            if var.Id == taskId then
                var.Status = XBountyTaskManager.BountyTaskStatus.AcceptReward
                break
            end
        end

        local levelUp = false
        local oldLevel = BountyTaskInfo.RankLevel

        if BountyTaskInfo.RankLevel < resp.RankLevel then
            levelUp = true
            BountyTaskInfo.RankLevel = resp.RankLevel
        end

        --升级
        XUiManager.OpenUiObtain(resp.RewardGoodsList, CS.XTextManager.GetText("BountyTaskRewardTipTitle"), function()
            -- if levelUp then
            --     --CS.XUiManager.ViewManager:Push("UiMoneyRewardLevelUpTips", true, false, oldLevel, resp.RankLevel)
            --     XLuaUiManager.Open("UiMoneyRewardLevelUpTips",oldLevel, resp.RankLevel)
            -- else
            XEventManager.DispatchEvent(XEventId.EVENT_BOUNTYTASK_ACCEPT_TASK_REWARD)
            --end
        end)

    end



    ----协议----------------------------------------------------------------------
    --请求接受任务
    function XBountyTaskManager.AcceptBountyTask(taskId, cb)
        XNetwork.Call(BountyTaskRequest.AcceptBountyTaskRequest, { TaskId = taskId }, function(resp)
            if resp.Code ~= XCode.Success then
                XUiManager.TipCode(resp.Code)
                return
            end

            if not BountyTaskInfo then
                return
            end

            if SelectIndex > 0 then
                FakeBountyTaskOrder[taskId] = SelectIndex;
            end

            local taskCard = XBountyTaskManager.GetTaskCardFromTaskPool(taskId)
            if taskCard then
                table.insert(BountyTaskInfo.TaskCards, taskCard)
            end

            BountyTaskInfo.TaskPool = resp.TaskPool
            -- XUiManager.TipMsg(CS.XTextManager.GetText("BountyTaskAccetpTaskSuccess"))
            if cb then
                cb()
            end

            XEventManager.DispatchEvent(XEventId.EVENT_BOUNTYTASK_ACCEPT_TASK)
        end)
    end

    --请求领取奖励
    function XBountyTaskManager.AcceptBountyTaskReward(taskId, cb)
        XNetwork.Call(BountyTaskRequest.AcceptBountyTaskRewardRequest, { TaskId = taskId }, function(resp)
            if resp.Code ~= XCode.Success then
                XUiManager.TipCode(resp.Code)
                return
            end

            if not BountyTaskInfo then
                return
            end

            XBountyTaskManager.GetBountyTaskReward(resp)

            if cb then
                cb()
            end

        end)
    end

    --刷新任务池
    function XBountyTaskManager.RefreshBountyTaskPool(cb)
        XNetwork.Call(BountyTaskRequest.RefreshBountyTaskPoolRequest, nil, function(resp)
            if resp.Code ~= XCode.Success then
                XUiManager.TipCode(resp.Code)
                return
            end

            if not BountyTaskInfo then
                return
            end

            BountyTaskInfo.TaskPoolRefreshCount = resp.TaskPoolRefreshCount
            BountyTaskInfo.TaskPool = resp.TaskPool

            if cb then
                cb()
            end

            XEventManager.DispatchEvent(XEventId.EVENT_BOUNTYTASK_TASK_REFRESH)
        end)
    end

    --通知任务信息改变
    function XBountyTaskManager.NotifyBountyTaskInfo(data)
        BountyTaskInfo = data.TaskInfo
        RefreshTime = data.RefreshTime
        FakeBountyTaskOrder = {}
        SelectIndex = -1
        XEventManager.DispatchEvent(XEventId.EVENT_BOUNTYTASK_INFO_CHANGE_NOTIFY)
    end

    --推送任务完成
    function XBountyTaskManager.NotifyBountyTaskComplete(data)
        XBountyTaskManager.FinshedTask(data.TaskId)
        XEventManager.DispatchEvent(XEventId.EVENT_BOUNTYTASK_TASK_COMPLETE_NOTIFY)
    end
    --------------------------------------------------------------------------
    function XBountyTaskManager.CheckReadyToFight(stageId)
        return not XBountyTaskManager.IsBountyTaskFight()
    end

    function XBountyTaskManager.FinishFight(settle)
        local preSettle = XBountyTaskManager.GetBountyTaskFightData().PreFightResult
        XDataCenter.FubenManager.ChallengeWin(preSettle)
        XBountyTaskManager.ResetFightData()
    end

    --打开加载界面
    function XBountyTaskManager.OpenFightLoading(stageId)
        XLuaUiManager.Remove("UiMoneyRewardFightTipFind")

        XLuaUiManager.Open("UiMoneyRewardFightTips",stageId)
    end


    function XBountyTaskManager.CloseFightLoading(stageId)
        XLuaUiManager.Remove("UiMoneyRewardFightTips")
    end

    --初始化关卡数据
    function XBountyTaskManager.InitStageInfo()
        for id, v in pairs(BountyTaskConfig) do
            local stageInfo = XDataCenter.FubenManager.GetStageInfo(v.StageId)
            stageInfo.BountyId = id
            stageInfo.Type = XDataCenter.FubenManager.StageType.BountyTask
        end
    end

    XBountyTaskManager.Init()
    return XBountyTaskManager
end

XRpc.NotifyBountyTaskInfo = function(data)
    XDataCenter.BountyTaskManager.NotifyBountyTaskInfo(data)
end

XRpc.NotifyBountyTaskComplete = function(data)
    XDataCenter.BountyTaskManager.NotifyBountyTaskComplete(data)
end