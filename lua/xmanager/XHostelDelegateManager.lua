XHostelDelegateManagerCreator = function()

    local XHostelDelegateManager = {}
    XHostelDelegateManager.FunctionDeviceType = {
        Unknown = -1,           --未知类型
        Electric = 1,       --电量
    }

    local TABLE_HOSTELDELEGATE_PATH = "Share/Hostel/HostelDelegate.tab"


    local HostelDelegateTemplate = {}
    local HostelDeviceDelegate = {}
    local HostelDelegateAssitPlayer = 0
    local HostelDelegateAssitPerPlayerCount = 0

    local table_insert = table.insert

    --玩家数据
    local AssistCountMap = {}
    local DelegataList = {}
    local DelegateReport = {}
    local FriendDelegateData = {} --好友的数据

    local PROTOCAL_REQUEST_NAME = {
        PublishDelegateRequest = "PublishDelegateRequest",
        FinishDelegateRequest = "FinishDelegateRequest",
        FriendHostelDelegateRequest = "FriendHostelDelegateRequest"
    }

    function XHostelDelegateManager.Init()
        HostelDelegateTemplate = XTableManager.ReadByIntKey(TABLE_HOSTELDELEGATE_PATH, XTable.XTableHostelDelegate, "DelegateType")
        for k,v in pairs(HostelDelegateTemplate) do
            local slotConfig = XDataCenter.HostelManager.GetFuncDeviceSlotTemplate(v.SlotType)
            if slotConfig then
                local deviceType = slotConfig.BelongType
                if not HostelDeviceDelegate[deviceType] then
                    HostelDeviceDelegate[deviceType] = {}
                end
                table_insert(HostelDeviceDelegate[deviceType],v.DelegateType)
            end
        end

        HostelDelegateAssitPlayer = CS.XGame.Config:GetInt("HostelDelegateAssitPlayer")
        HostelDelegateAssitPerPlayerCount = CS.XGame.Config:GetInt("HostelDelegateAssitPerPlayerCount")
    end
    ----------------配置处理-----------------------
    function XHostelDelegateManager.GetDelegateTemplateByType(delegateType)
        return HostelDelegateTemplate[delegateType]
    end

    function XHostelDelegateManager.GetDelegateListByDeviceType(deviceType)
        return HostelDeviceDelegate[deviceType]
    end

    ----------------模块逻辑-----------------------
    function XHostelDelegateManager.InitHostelDelegateData(hostelDelegate)
        if not hostelDelegate then
            return
        end

        XTool.LoopMap(hostelDelegate.AssistCountMap, function(key, value)
            AssistCountMap[key] = value
        end)

        XTool.LoopCollection(hostelDelegate.DelegataList, function(data)
            table_insert(DelegataList, data)
        end)

        XTool.LoopCollection(hostelDelegate.DelegateReport, function(data)
            table_insert(DelegateReport, data)
        end)
    end

    function XHostelDelegateManager.GetHostelDelegateCount(delegateType)
        local totalCount = 0
        local doneCount = 0
        for i,v in ipairs(DelegataList) do
            if v.DelegateType == delegateType then
                totalCount = totalCount + 1
                if v.IsDone then
                    doneCount = doneCount + 1
                end
            end
        end
        return totalCount, doneCount
    end

    function XHostelDelegateManager.SetDelegateDone(delegateType)
        for i,v in ipairs(DelegataList) do
            if v.DelegateType == delegateType and not v.IsDone then
                v.IsDone = true
            end
        end
    end

    function XHostelDelegateManager.GetDelegateReportList()
        return DelegateReport
    end

    -------------------消息通信--------------------------
    function XHostelDelegateManager.ReqPublishDelegate(delegateType, count, cb)
        XNetwork.Call(PROTOCAL_REQUEST_NAME.PublishDelegateRequest, {DelegateType = delegateType, Count = count}, function(response)
            if response.Code ~= XCode.Success then
                XUiManager.TipCode(response.Code)
                return
            end
            --TODO 直接保存个数
            -- XTool.LoopCollection(dataList.DelegataList, function(data)
            --     table_insert(DelegataList, data)
            -- end)
            if cb then
                cb()
            end
        end)
    end

    function XHostelDelegateManager.ReqFinishDelegate(playerId, delegateType, completeType, cb)
        XNetwork.Call(PROTOCAL_REQUEST_NAME.FinishDelegateRequest, {PlayerId = playerId, DelegateType = delegateType, CompleteType = completeType},
                function(response)
                    if response.Code ~= XCode.Success then
                        XUiManager.TipCode(response.Code)
                        return
                    end
                    if cb then
                        cb()
                    end
                end)
    end

    function XHostelDelegateManager.ReqFriendHostelDelegateData(playerId)
        XNetwork.Call(PROTOCAL_REQUEST_NAME.FriendHostelDelegateRequest, {PlayerId = playerId}, function(response)
            if response.Code ~= XCode.Success then
                XUiManager.TipCode(response.Code)
                return
            end

            XHostelDelegateManager.OnSyncFriendHostelDelegateList(playerId, response.Datas)
            if cb then
                cb()
            end
        end)
    end

    function XHostelDelegateManager.OnSyncDelegateReport(report)
        table_insert(DelegateReport, report)
    end

    function XHostelDelegateManager.OnSyncDelegateDateReset()
        AssistCountMap = {}
        DelegataList = {}
    end

    function XHostelDelegateManager.OnSyncAssistCount(playerId, count)
        AssistCountMap[playerId] = count
    end

    function XHostelDelegateManager.OnSyncDelegateDone(delegateType)
        XHostelDelegateManager.SetDelegateDone(delegateType)
    end

    function XHostelDelegateManager.OnSyncFriendHostelDelegateList(playerId, dataList)
        FriendDelegateData[playerId] = {}
        XTool.LoopCollection(dataList.DelegataList, function(data)
            table_insert(FriendDelegateData[playerId], data)
        end)
    end

    XHostelDelegateManager.Init()
    return XHostelDelegateManager
end

XRpc.NotifyDelegateReport = function(data)
    XDataCenter.HostelDelegateManager.OnSyncDelegateReport(data.Report)
end

XRpc.NotifyResetDelegateData = function()
    XDataCenter.HostelDelegateManager.OnSyncDelegateDateReset()
end

XRpc.NotifyAssistCount = function(data)
    XDataCenter.HostelDelegateManager.OnSyncAssistCount(data.AssistData.TargetId, data.AssistData.Count)
end

XRpc.NotifyDelegateDone = function(data)
    XDataCenter.HostelDelegateManager.OnSyncDelegateDone(data.DelegateType)
end

XRpc.NotifyFriendDelegateData = function(msg)
    XDataCenter.HostelDelegateManager.OnSyncFriendHostelDelegateList(msg.FriendId, msg.Datas)
end