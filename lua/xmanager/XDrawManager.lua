XDrawManagerCreator = function()

    local XDrawManager = {}

    local tableInsert = table.insert
    local tableSort = table.sort

    local GET_DRAW_DATA_INTERVAL = 15

    local DrawGroupInfos = {}
    local DrawInfos = {}
    local LastGetGroupInfoTime = 0
    local LastGetDropInfoTimes = {}

    local DrawPreviews = {}
    local DrawCombinations = {}
    local DrawProbs = {}
    local DrawGroupRule = {}
    local DrawShow = {}
    local DrawShowCharacter = {}
    local DrawCamera = {}
    local DrawTabs = {}
    local DrawActivityCount = 0
    local CurSelectTabInfo = nil

    XDrawManager.DrawEventType = {Normal = 0, NewHand = 1, Activity = 2, OldActivity = 3}

    function XDrawManager.Init()
        DrawCombinations = XDrawConfigs.GetDrawCombinations()
        DrawGroupRule = XDrawConfigs.GetDrawGroupRule()
        DrawShow = XDrawConfigs.GetDrawShow()
        DrawShowCharacter = XDrawConfigs.GetDrawShowCharacter()
        DrawCamera = XDrawConfigs.GetDrawCamera()
        DrawTabs = XDrawConfigs.GetDrawTabs()
        DrawPreviews = XDrawConfigs.GetDrawPreviews()
        DrawProbs = XDrawConfigs.GetDrawProbs()
    end

    function XDrawManager.GetDrawPreview(drawId)
        return DrawPreviews[drawId]
    end

    function XDrawManager.GetDrawCombination(drawId)
        return DrawCombinations[drawId]
    end

    function XDrawManager.GetDrawProb(drawId)
        return DrawProbs[drawId]
    end

    function XDrawManager.GetDrawGroupRule(groupId)
        return DrawGroupRule[groupId]
    end

    function XDrawManager.GetDrawShow(type)
        return DrawShow[type - 1]
    end

    function XDrawManager.GetDrawCamera(id)
        return DrawCamera[id]
    end

    function XDrawManager.GetDrawInfo(drawId)
        return DrawInfos[drawId]
    end

    function XDrawManager.GetDrawShowCharacter(id)
        return DrawShowCharacter[id]
    end

    function XDrawManager.GetDrawInfoListByGroupId(groupId)
        local list = {}
        for _, info in pairs(DrawInfos) do
            if info.GroupId == groupId then
                tableInsert(list, info)
            end
        end

        tableSort(list, function(a, b)
            return a.Id < b.Id
        end)

        return list
    end

    function XDrawManager.GetUseDrawInfoByGroupId(groupId)
        local groupInfo = DrawGroupInfos[groupId]
        if groupInfo.UseDrawId > 0 then
            return XDrawManager.GetDrawInfo(groupInfo.UseDrawId)
        else
            local list = XDrawManager.GetDrawInfoListByGroupId(groupId)
            return list[1]
        end
    end

    function XDrawManager.GetDrawGroupInfoByGroupId(groupId)
        return DrawGroupInfos[groupId]
    end

    -- 查询相关begin --
    function XDrawManager.GetDrawGroupInfos()
        local list = {}

        for _, v in pairs(DrawGroupInfos) do
            tableInsert(list, v)
        end

        tableSort(list, function(a, b)
            return a.Priority > b.Priority
        end)
        --检测如果有过期的，下次请求跳过时间间隔检测
        for k, v in pairs(list) do
            if v.EndTime > 0 and v.EndTime - XTime.Now() <= 0 then
                LastGetGroupInfoTime = 0
                CurSelectTabInfo = nil
            end
        end
        return list
    end

    function XDrawManager.UpdateDrawGroupInfos(groupInfoList)
        DrawGroupInfos = {}

        local isExpired = true

        for _, info in pairs(groupInfoList) do
            DrawGroupInfos[info.Id] = info
            DrawGroupInfos[info.Id].BottomTimes = DrawGroupInfos[info.Id].MaxBottomTimes - DrawGroupInfos[info.Id].BottomTimes
            if CurSelectTabInfo then
                if info.Id == CurSelectTabInfo.Id then
                    isExpired = false
                end
            end
        end

        if isExpired then
            CurSelectTabInfo = nil
        end
    end

    function XDrawManager.UpdateDrawInfos(drawInfoList)
        --每次更新一组info之前清空之前相同GroupId的信息
        local deleteKey = {}
        for k, v in pairs(DrawInfos) do
            if v.GroupId == drawInfoList[1].GroupId then
                deleteKey[k] = true
            end
        end
        for k, v in pairs(deleteKey) do
            DrawInfos[k] = nil
        end

        for _, info in pairs(drawInfoList) do
            XDrawManager.UpdateDrawInfo(info)
        end
    end

    function XDrawManager.UpdateDrawInfo(drawInfo)
        DrawInfos[drawInfo.Id] = drawInfo
        DrawInfos[drawInfo.Id].BottomTimes = DrawInfos[drawInfo.Id].MaxBottomTimes - DrawInfos[drawInfo.Id].BottomTimes
    end
    -- 查询相关end --
    -- 消息相关begin --
    function XDrawManager.GetDrawInfoList(dropId, cb)
        local now = XTime.Now()
        if LastGetDropInfoTimes[dropId] and now - LastGetDropInfoTimes[dropId] <= GET_DRAW_DATA_INTERVAL then
            cb()
            return
        end
        XNetwork.Call("DrawGetDrawInfoListRequest", { GroupId = dropId }, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end
            XDrawManager.UpdateDrawInfos(res.DrawInfoList)
            LastGetDropInfoTimes[dropId] = now
            cb()
        end)
    end

    function XDrawManager.GetDrawGroupList(cb)
        local now = XTime.Now()
        if now - LastGetGroupInfoTime <= GET_DRAW_DATA_INTERVAL then
            cb()
            return
        end

        XNetwork.Call("DrawGetDrawGroupListRequest", nil, function(res)
            XDrawManager.UpdateDrawGroupInfos(res.DrawGroupInfoList)
            LastGetGroupInfoTime = now
            cb()
        end)
    end

    --==============================--
    --desc: 打乱奖励顺序，防止因规则造成顺序可循
    --@rewardGoodsList: 奖励列表
    --@return 处理后奖励列表
    --==============================--
    local function UpsetRewardGoodsList(rewardGoodsList)
        local list = {}

        local len = #rewardGoodsList
        if len <= 1 then
            return rewardGoodsList
        end

        for i = 1, len do
            local index = math.random(1, len)
            if index ~= i then
                local tmp = rewardGoodsList[i]
                rewardGoodsList[i] = rewardGoodsList[index]
                rewardGoodsList[index] = tmp
            end
        end

        return rewardGoodsList
    end

    function XDrawManager.DrawCard(drawId, count, cb)
        XNetwork.Call("DrawDrawCardRequest", { DrawId = drawId, Count = count }, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end
            XDrawManager.UpdateDrawInfo(res.ClientDrawInfo)
            XDrawManager.UpdateDrawGroupByInfo(res.ClientDrawInfo)
            cb(res.ClientDrawInfo, res.RewardGoodsList)
        end)
    end

    function XDrawManager.SaveDrawAimId(drawId,groupId)--保存狙击目标
        XNetwork.Call("DrawSetUseDrawIdRequest", { DrawId = drawId }, function(res)
                if res.Code ~= XCode.Success then
                    XUiManager.TipCode(res.Code)
                    return
                end
                XDrawManager.GetDrawGroupInfoByGroupId(groupId).UseDrawId = drawId
            end)
    end
    -- 消息相关end --
    -- Wind --
    function XDrawManager.GetDrawTab(tabID)
        for _, tab in pairs(DrawTabs) do
            if tab.Id == tabID then
                return tab
            end
        end
        XLog.Error("Error Draw tabID!" .. tabID)
        return nil
    end

    function XDrawManager.GetCurSelectTabInfo()
        return CurSelectTabInfo
    end

    function XDrawManager.SetCurSelectTabInfo(info)
        CurSelectTabInfo = info
    end

    function XDrawManager.UpdateDrawGroupByInfo(clientDrawInfo)
        for k, v in pairs(DrawGroupInfos) do
            if v.UseDrawId == clientDrawInfo.Id then
                v.BottomTimes = clientDrawInfo.MaxBottomTimes - clientDrawInfo.BottomTimes
            end
        end
    end

    function XDrawManager.UpdateDrawActivityCount(count)
        DrawActivityCount = count
    end

    function XDrawManager.CheakDrawActivityCount()
        return DrawActivityCount > 0
    end
    -- WindEnd --

    XDrawManager.Init()
    return XDrawManager
end


XRpc.NotifyActivityDrawGroupCount = function (data)
    XDataCenter.DrawManager.UpdateDrawActivityCount(data.Count)
    XEventManager.DispatchEvent(XEventId.EVENT_DRAW_ACTIVITYCOUNT_CHANGE)
end