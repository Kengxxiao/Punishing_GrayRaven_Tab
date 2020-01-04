XFubenExploreManagerCreator = function()
    local XFubenExploreManager = {}
    --服务器数据
    local ExploreChapterData = {}
    --处理后的关卡数据
    local ExploreNodeData = {}
    --保存战斗关卡使用的角色，胜利后扣除体力
    local CurTeam = {}

    local CurSelectChapterId = 1
    local CurNodeId = 1

    function XFubenExploreManager.Init()
        XEventManager.AddEventListener(XEventId.EVENT_FUBEN_SETTLE_REWARD, XFubenExploreManager.HandlerFightResult)
    end

    function XFubenExploreManager.InitNodeData()
        ExploreNodeData = {}
        local nodeData = XFubenExploreConfigs.GetExploreNodeCfg()
        for k, v in pairs(nodeData) do
            ExploreNodeData[k] = { tableData = v }
        end
        for k, v in pairs(ExploreNodeData) do
            XFubenExploreManager.UpdateNodeData(v)
        end
        XEventManager.DispatchEvent(XEventId.EVENT_FUBEN_EXPLORE_UPDATE)
    end

    function XFubenExploreManager.UpdateNodeData(nodeData)
        if XFubenExploreManager.IsNodeFinish(nodeData.tableData.ChapterId, nodeData.tableData.Id) then
            nodeData.State = XFubenExploreConfigs.NodeStateEnum.Complete
        else
            nodeData.State = XFubenExploreConfigs.NodeStateEnum.Visivle
            for j = 1, #nodeData.tableData.PreShowId do
                if #nodeData.tableData.PreShowId > 0 then
                    if XFubenExploreManager.IsNodeFinish(nodeData.tableData.ChapterId, nodeData.tableData.PreShowId[j]) == false then
                        nodeData.State = XFubenExploreConfigs.NodeStateEnum.Invisivle
                        break
                    end
                end
            end

            if nodeData.State == XFubenExploreConfigs.NodeStateEnum.Visivle then
                nodeData.State = XFubenExploreConfigs.NodeStateEnum.Availavle
                for j = 1, #nodeData.tableData.PreOpenId do
                    if XFubenExploreManager.IsNodeFinish(nodeData.tableData.ChapterId, nodeData.tableData.PreOpenId[j]) == false then
                        nodeData.State = XFubenExploreConfigs.NodeStateEnum.Visivle
                        break
                    end
                end
            end
        end
    end

    function XFubenExploreManager.InitStageInfo()
        local battleIdList = {}
        local allNodeData = XFubenExploreConfigs.GetExploreNodeCfg()
        for k, v in pairs(allNodeData) do
            if v.Type == XFubenExploreConfigs.NodeTypeEnum.Stage then
                table.insert(battleIdList, v.TypeValue)
            end
        end
        for _, v in pairs(battleIdList) do
            local stageInfo = XDataCenter.FubenManager.GetStageInfo(v)
            stageInfo.Type = XDataCenter.FubenManager.StageType.Explore
        end
    end


    --Get
    --根据原型ID获取对应角色在某一章的已使用的耐力值
    function XFubenExploreManager.GetEndurance(chapterId, characterId)
        local chapterData = XFubenExploreManager.GetChapterData(chapterId)
        for i = 1, #chapterData.EnduranceInfos do
            if chapterData.EnduranceInfos[i].Id == characterId then
                return chapterData.EnduranceInfos[i].Use
            end
        end
        --找不到，说明体力还是满的，已使用0
        return 0
    end
    --获取某一章里的最大耐力（每个角色都一样）
    function XFubenExploreManager.GetMaxEndurance(chapterId)
        local chapterData = XFubenExploreConfigs.GetChapterData(chapterId)
        return chapterData.Endurance
    end

    --获取某一章的数据
    function XFubenExploreManager.GetChapterData(chapterId)
        for i = 1, #ExploreChapterData do
            if ExploreChapterData[i].Id == chapterId then
                return ExploreChapterData[i]
            end
        end

        local tempChapterData =         {
            EnduranceInfos = {},
            RewardStatus = 0,
            Id = chapterId,
            FinishNodes = {},
            UnlockEvents = {},
        }
        table.insert(ExploreChapterData, tempChapterData)
        --XLog.Error("Can not find chapter with id:", chapterId)
        return tempChapterData
    end

    --获取某一章所有节点的数据（处理后）
    function XFubenExploreManager.GetAllNodeData(chapterId)
        local tempList = {}
        for k, v in pairs(ExploreNodeData) do
            if v.tableData.ChapterId == chapterId then
                table.insert(tempList, v)
            end
        end
        return tempList
    end

    --获取某一关的数据(处理后)
    function XFubenExploreManager.GetNodeData(nodeId)
        return ExploreNodeData[nodeId]
    end

    --获取某一章探索率
    function XFubenExploreManager.GetExploreProgress(chapterId)
        local allLevelData = XFubenExploreConfigs.GetAllLevel(chapterId)
        local allPassLevelData = XFubenExploreManager.GetChapterData(chapterId)
        if allPassLevelData == nil then
            return 0
        else
            return #allPassLevelData.FinishNodes / #allLevelData
        end
    end

    --获取某一章的已打开的记录
    function XFubenExploreManager.GetChapterStoryText(chapterId)
        local allStoryText = XFubenExploreConfigs.GetChapterStoryText(chapterId)
        local tempList = {}
        for i = 1, #allStoryText do
            if allStoryText[i].UnlockNodeId == 0 or XFubenExploreManager.IsNodeFinish(chapterId, allStoryText[i].UnlockNodeId) then
                table.insert(tempList, allStoryText[i])
            end
        end
        return tempList
    end
    --获取当前选中的章节ID
    function XFubenExploreManager.GetCurChapterId()
        return CurSelectChapterId
    end

    --获取当前能打的最新章节ID
    function XFubenExploreManager.GetNewestChapterId()
        local curProgress = 1
        local allChapterData = XFubenExploreConfigs.GetExploreChapterCfg()
        for i = 1, #allChapterData do
            if XFubenExploreManager.GetExploreProgress(allChapterData[i].Id) ~= 1 then
                return allChapterData[i].Id
            end
        end
        return nil
    end

    --获取当前进入的关卡节点ID
    function XFubenExploreManager.GetCurNodeId()
        return CurNodeId
    end

    --获取当前进入的关卡消耗体力值
    function XFubenExploreManager:GetCurNodeEndurance()
        return XFubenExploreConfigs.GetLevel(XFubenExploreManager.GetCurNodeId()).CostEndurance
    end

    --获取当前进度的章节名
    function XFubenExploreManager.GetCurProgressName()
        local curProgress = 1
        local allChapterData = XFubenExploreConfigs.GetExploreChapterCfg()
        for i = 1, #allChapterData do
            if XFubenExploreManager.GetExploreProgress(allChapterData[i].Id) ~= 1 then
                return allChapterData[i].Name
            end
        end
        return nil
    end

    --某个buff的解锁进度
    function XFubenExploreManager.GetBuffUnlockProgress(buffInfo)
        local unlockNum = 0
        for k, v in pairs(buffInfo.UnlockEvent) do
            if XFubenExploreManager.IsBuffUnlockEvent(buffInfo, v) then
                unlockNum = unlockNum + 1
            end
        end
        return unlockNum / #buffInfo.UnlockEvent
    end

    --Get end
    --Set
    function XFubenExploreManager.SetNodeFinish(chapterId, nodeId)
        if XFubenExploreManager.IsNodeFinish(chapterId, nodeId) then
            return
        end
        local chapterData = XFubenExploreManager.GetChapterData(chapterId)
        local curNode = XFubenExploreManager.GetNodeData(nodeId)
        if chapterData ~= nil then
            table.insert(chapterData.FinishNodes, nodeId)
        else
            local tempChapterData =             {
                EnduranceInfos = {},
                RewardStatus = 0,
                Id = chapterId,
                FinishNodes = {},
                UnlockEvents = {},
            }
            table.insert(tempChapterData.FinishNodes, chapterId, nodeId)
            table.insert(ExploreChapterData, tempChapterData)
        end

        chapterData = XFubenExploreManager.GetChapterData(chapterId)
        if curNode.tableData.CostEndurance > 0 then
            for i = 1, #CurTeam.TeamData do
                local hasId = false
                for j = 1, #chapterData.EnduranceInfos do
                    if chapterData.EnduranceInfos[j].Id == CurTeam.TeamData[i] then
                        chapterData.EnduranceInfos[j].Use = chapterData.EnduranceInfos[j].Use + curNode.tableData.CostEndurance
                        hasId = true
                    end
                end
                if not hasId then
                    table.insert(chapterData.EnduranceInfos, { Id = CurTeam.TeamData[i], Use = curNode.tableData.CostEndurance })
                end
            end
        end
        XFubenExploreManager.InitNodeData()
    end

    function XFubenExploreManager.SetCurChapterId(id)
        CurSelectChapterId = id
    end

    function XFubenExploreManager.SetCurNodeId(id)
        CurNodeId = id
    end

    function XFubenExploreManager.SetCurTeam(team)
        CurTeam = team
    end
    --Set end
    --Is
    --某一关是否完成
    function XFubenExploreManager.IsNodeFinish(chapterId, nodeId)
        local chapterData = XFubenExploreManager.GetChapterData(chapterId)
        if chapterData ~= nil then
            for i = 1, #chapterData.FinishNodes do
                if chapterData.FinishNodes[i] == nodeId then
                    return true
                end
            end
        end
        --找不到，说明没完成
        return false
    end

    --检测是否有东西没领
    function XFubenExploreManager.IsRedPoint()
        for i = 1, #ExploreChapterData do
            if ExploreChapterData[i].RewardStatus == 0 and XFubenExploreManager.GetExploreProgress(ExploreChapterData[i].Id) == 1 then
                return true
            end
        end
        return false
    end

    --某章是否有奖励没领
    function XFubenExploreManager.IsChapterRedPoint(chapterId)
        local chapterData = XFubenExploreManager.GetChapterData(chapterId)
        if chapterData then
            return chapterData.RewardStatus == 0 and XFubenExploreManager.GetExploreProgress(chapterId) == 1
        else
            return false
        end
    end

    --某个buff是否解锁
    function XFubenExploreManager.IsBuffUnlock(buffInfo)
        local isUnlock = true
        for k, v in pairs(buffInfo.UnlockEvent) do
            if not XFubenExploreManager.IsBuffUnlockEvent(buffInfo, v) then
                isUnlock = false
            end
        end
        return isUnlock
    end

    --某个buff的某个条件是否满足
    function XFubenExploreManager.IsBuffUnlockEvent(buffInfo, eventId)
        local isUnlock = false
        local chapterData = XFubenExploreManager.GetChapterData(buffInfo.ChapterId)
        for k, v in pairs(chapterData.UnlockEvents) do
            if v == eventId then
                isUnlock = true
                break
            end
        end
        return isUnlock
    end
    --是否完成全部章节
    function XFubenExploreManager.IsFinishAll()
        if XFubenExploreManager.IsRedPoint() and XFubenExploreManager.GetCurProgressName() == nil then
            return true
        end
        return false
    end
    --Is end
    -- Network
    -- 完成剧情关卡请求
    function XFubenExploreManager.FinishNode(chapterId, nodeId, cb)
        XNetwork.Call("ExploreFinishNodeRequest", { Id = nodeId }, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            XFubenExploreManager.SetNodeFinish(chapterId, nodeId)
            cb()
        end)
    end

    -- 领取章节奖励
    function XFubenExploreManager.GetChapterReward(chapterId, cb)
        XNetwork.Call("ExploreGetRewardRequest", { Id = chapterId }, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            XFubenExploreManager.GetChapterData(chapterId).RewardStatus = 1
            if res.RewardGoodsList and #res.RewardGoodsList > 0 then
                XUiManager.OpenUiObtain(res.RewardGoodsList, nil, cb)
            end
        end)
    end
    --Network end
    --Handle
    function XFubenExploreManager.HandleExploreData(data)
        --清空数据
        ExploreChapterData = {}
        --赋值
        ExploreChapterData = data.ChapterDatas
        XFubenExploreManager.InitNodeData()
    end

    function XFubenExploreManager.HandlerFightResult(evt)
        if evt ~= nil and evt.IsWin then
            local stage = XDataCenter.FubenManager.GetStageInfo(evt.StageId)
            if stage.Type == XDataCenter.FubenManager.StageType.Explore then
                XFubenExploreManager.SetNodeFinish(XFubenExploreManager.GetCurChapterId(), XFubenExploreManager.GetCurNodeId())
            end
        end
    end

    function XFubenExploreManager.HandleExploreUnlockEvent(evt)
        local chapterData = XFubenExploreManager.GetChapterData(evt.Id)
        chapterData.UnlockEvents = evt.UnlockEvents
        XEventManager.DispatchEvent(XEventId.EVENT_FUBEN_EXPLORE_UPDATEBUFF)
    end

    --Handle end
    XFubenExploreManager.Init()
    return XFubenExploreManager
end

XRpc.NotifyExploreData = function(data)
    XDataCenter.FubenExploreManager.HandleExploreData(data)
end
XRpc.NotifyExploreUnlockEvent = function(data)
    XDataCenter.FubenExploreManager.HandleExploreUnlockEvent(data)
end