XAutoFightManagerCreator = function()
    local tableremove = table.remove
    local tableinsert = table.insert

    local Manager = {}

    local AutoFightCfgs = {}
    local TABLE_AUTO_FIGHT = "Share/Fuben/AutoFight.tab"

    local METHOD_NAME = {
        StartAutoFight = "StartAutoFightRequest",
        ObtainAutoFightRewards = "ObtainAutoFightRewardsRequest"
    }

    local State = {
        None = 0,
        Fighting = 1,
        Complete = 2
    }

    local Records = {}
    local RecordLookup
    local SyncInterval = 15
    local LastSyncTime = 0

    local timer
    local updateInterval = CS.XScheduleManager.SECOND

    local function Init()
        AutoFightCfgs = XTableManager.ReadByIntKey(TABLE_AUTO_FIGHT, XTable.XTableAutoFight, "Id")
    end

    local function GetConfig(autoFightId)
        return AutoFightCfgs[autoFightId]
    end

    local function GetRecordCount()
        return #Records
    end

    local function CreateTimer()
        timer = CS.XScheduleManager.ScheduleForever(function(timer)
            local now = XTime.Now()
            local cnt = 0
            for k, v in pairs(Records) do
                if now >= v.CompleteTime then
                    cnt = cnt + 1
                end
            end
            XEventManager.DispatchEvent(XEventId.EVENT_AUTO_FIGHT_CHANGE, cnt)
        end, updateInterval)
    end

    local RemoveTimer
    RemoveTimer = function()
        if timer then
            CS.XScheduleManager.UnSchedule(timer)
        end
        XEventManager.RemoveEventListener(XEventId.EVENT_USER_LOGOUT, RemoveTimer)
        XEventManager.RemoveEventListener(XEventId.EVENT_NETWORK_DISCONNECT, RemoveTimer)
    end

    local function UpdateRecords(records)
        Records = records
        RecordLookup = {}
        for k, v in pairs(Records) do
            RecordLookup[v.StageId] = v
        end
    end

    local function InitAutoFightData(records)
        UpdateRecords(records)
        CreateTimer()
        XEventManager.AddEventListener(XEventId.EVENT_USER_LOGOUT, RemoveTimer)
        XEventManager.AddEventListener(XEventId.EVENT_NETWORK_DISCONNECT, RemoveTimer)
    end

    local function CheckAutoFightAvailable(stageId)
        local stageCfg = XDataCenter.FubenManager.GetStageCfg(stageId)
        if not stageCfg or stageCfg.AutoFightId <= 0 then
            return XCode.FubenManagerAutoFightStageInvalid
        end

        local stageData = XDataCenter.FubenManager.GetStageData(stageId)
        if not stageData then
            return XCode.FubenManagerAutoFightStageInvalid
        end
        
        return XCode.Success
    end

    local function StartAutoFight(stageId, times, cb)
        XNetwork.Call(METHOD_NAME.StartAutoFight, { StageId = stageId, Times = times }, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            tableinsert(Records, res.Record)
            RecordLookup[res.Record.StageId] = res.Record
            XEventManager.DispatchEvent(XEventId.EVENT_AUTO_FIGHT_START, stageId)

            if cb then
                cb(res)
            end
        end)
    end

    local function GetRecords(cb)
        return Records
    end

    local function ObtainRewards(index, cb)
        local record = Records[index]
        if not record then
            XUiManager.TipCode(XCode.FubenManagerAutoFightIndexInvalid)
            return
        end

        local stageId = record.StageId

        local stageCfg = XDataCenter.FubenManager.GetStageCfg(stageId)
        local cardIds = record.CardIds
        local hasRobot = false
        if stageCfg.RobotId and #stageCfg.RobotId > 0 then
            hasRobot = true
            cardIds = {}
            for k, v in pairs(stageCfg.RobotId) do
                local charId = XRobotManager.GetCharaterId(v)
                tableinsert(cardIds, charId)
            end
        end

        XNetwork.Call(METHOD_NAME.ObtainAutoFightRewards, { Index = index - 1, StageId = stageId }, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            tableremove(Records, index)
            RecordLookup[stageId] = nil

            XEventManager.DispatchEvent(XEventId.EVENT_AUTO_FIGHT_REMOVE, stageId)

            if hasRobot then
                res.CharacterExp = 0
            end

            if cb then
                cb(res)
            end

            XLuaUiManager.Open("UiAutoFightReward", cardIds, res)
        end)
    end

    local function GetRecordByStageId(stageId)
        return RecordLookup and RecordLookup[stageId]
    end

    local function GetIndexByStageId(stageId)
        for k, v in pairs(Records) do
            if v.StageId == stageId then
                return k
            end
        end
        return 0
    end

    Manager.State = State

    Manager.Init = Init--()
    Manager.GetConfig = GetConfig--(autoFightId)
    Manager.GetRecordCount = GetRecordCount--()
    Manager.InitAutoFightData = InitAutoFightData--(records) --NotifyLogin
    Manager.CheckAutoFightAvailable = CheckAutoFightAvailable--(stageId)
    Manager.StartAutoFight = StartAutoFight--(stageId, times, cb(res = {Code, Record}))
    Manager.GetRecords = GetRecords--()
    Manager.ObtainRewards = ObtainRewards--(index, cb(res = {Code, TeamExp, CharacterExp, Rewards}))
    Manager.GetRecordByStageId = GetRecordByStageId--(stageId)
    Manager.GetIndexByStageId = GetIndexByStageId--(stageId)

    Manager.Init()

    return Manager
end