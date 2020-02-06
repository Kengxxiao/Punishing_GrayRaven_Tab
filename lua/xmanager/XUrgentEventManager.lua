XFubenUrgentEventManagerCreator = function()

    local XFubenUrgentEventManager = {}

    local TABLE_URGENT_EVENT = "Share/Fuben/UrgentEvent/UrgentEvent.tab"
    local UrgentEventCfg = {}
    local UrgentEventInfo = {}
    local UrgentEventData = {}

    local CheckUrgentEventTime = function()
        if next(UrgentEventData) then
            for _, v in pairs(UrgentEventData) do
                local now = XTime.GetServerNowTimestamp()
                local passedTime = now - v.Time
                local urgentCfg = XFubenUrgentEventManager.GetUrgentEventCfg(v.UrgentId)
                local remainTime = urgentCfg.Time - passedTime
                XCountDown.CreateTimer(tostring(v.UrgentId), remainTime, now)
            end
        else
            XCountDown.CreateTimer(XCountDown.GTimerName.UrgentEvent, 0)
        end
    end

    function XFubenUrgentEventManager.Init()
        UrgentEventCfg = XTableManager.ReadByIntKey(TABLE_URGENT_EVENT, XTable.XTableUrgentEvent, "Id")
    end

    function XFubenUrgentEventManager.GetUrgentEventCfg(urgentId)
        if UrgentEventCfg[urgentId] then
            return UrgentEventCfg[urgentId]
        end
    end

    function XFubenUrgentEventManager.InitStageInfo()
        for urgentId, urgentCfg in pairs(UrgentEventCfg) do
            for _, stageId in ipairs(urgentCfg.StageId) do
                local stageInfo = XDataCenter.FubenManager.GetStageInfo(stageId)
                stageInfo.SectionId = urgentId
                stageInfo.StageId = stageId
                stageInfo.Type = XDataCenter.FubenManager.StageType.Urgent
            end
        end
    end

    function XFubenUrgentEventManager.InitData(fubenUrgentEventData)
        XTool.LoopMap(fubenUrgentEventData.UrgentEventData, function(k, v)
            UrgentEventData[k] = v
        end)
        CheckUrgentEventTime()
    end

    function XFubenUrgentEventManager.GetMapIdByUrgentId(urgentId)
        return UrgentEventData[urgentId].StageId
    end

    function XFubenUrgentEventManager.GetUrgentList()
        local list = {}
        for urgentId, v in pairs(UrgentEventData) do
            if v.Activated then
                local urgentEventTemp = {
                    UrgentCfg = XFubenUrgentEventManager.GetUrgentEventCfg(urgentId),
                    UrgentInfo = v,
                    IsClose = false,
                    IsUrgentEvent = true,
                    Id = urgentId,
                    Type = XDataCenter.FubenManager.ChapterType.Urgent
                }
                table.insert(list, urgentEventTemp)
            end
        end
        return list
    end

    function XFubenUrgentEventManager.NotifyUrgentData(req)
        XTool.LoopMap(req.FubenUrgentEventData.UrgentEventData, function(k, v)
            UrgentEventData[k] = v
        end)
        CheckUrgentEventTime()
        XEventManager.DispatchEvent(XEventId.EVENT_URGENTEVENT_SYNC)
    end

    function XFubenUrgentEventManager.CheckPreFight(stage)
        local stageId = stage.StageId
        local stageInfo = XDataCenter.FubenManager.GetStageInfo(stageId)
        local urgentId = stageInfo.SectionId
        if stageId ~= XFubenUrgentEventManager.GetMapIdByUrgentId(urgentId) or XCountDown.GetRemainTime(tostring(urgentId)) <= 0 then
            local msg = CS.XTextManager.GetText("FubenNotTime")
            XUiManager.TipMsg(msg)
            CS.XUiManager.ViewManager:Pop()
            return false
        end
        return true
    end

    XFubenUrgentEventManager.Init()
    return XFubenUrgentEventManager
end

XRpc.NotifyUrgentData = function(req)
    XDataCenter.FubenUrgentEventManager.NotifyUrgentData(req)
end