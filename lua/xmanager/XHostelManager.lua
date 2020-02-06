XHostelManagerCreator = function()

    local XHostelManager = {}
    XHostelManager.FunctionDeviceType = {
        Unknown = -1,           --未知类型
        MainComputer = 1,       --主电脑
        PowerStation = 2,       --发电站
        Factory = 3,            --工厂
        FucEnd = 4,

        PowerSlotA = 201,        -- 发电站槽位A
        PowerSlotB = 202,        -- 发电站槽位B
        PowerSlotC = 203,        -- 发电站槽位C

        FactorySlotA = 301,
        FactorySlotB = 302,
        FactorySlotC = 303,
        FactorySlotD = 304,
        FactorySlotE = 305,
        FactorySlotF = 306,
    }

    XHostelManager.WorkSlotState = {
        Unknown = -1,
        Lock = 1,
        Idle = 2,
        Working = 3,
        Complete = 4,
    }

    XHostelManager.DeviceUpgradeState = {
        Unknown = -1,
        Normal = 1,
        Upgrading = 2,
        Complete = 3,
    }

    XHostelManager.SceneType = {
        Unknown = -1,
        Function = 1,   --功能放场景
    }


    local TABLE_HOSTELROOM_PATH = "Share/Hostel/HostelRoom.tab"
    local TABLE_HOSTEL_FUNCDEVICE_PATH = "Share/Hostel/FunctionDevice.tab"
    local TABLE_HOSTEL_REST_PATH = "Share/Hostel/HostelRest.tab"
    local TABLE_HOSTEL_ROOM_NODE_PATH = "Client/Hostel/HostelRoomNode.tab"
    local TABLE_HOSTEL_DEVICE_NODE_PATH = "Client/Hostel/HostelDeviceNode.tab"
    local TABLE_HOSTEL_HUD_PATH = "Client/Hostel/HostelHud.tab"

    local SceneToHostelRoomNodeMap = {}
    local SceneToHostelDeviceNodeMap = {}
    local HostelRoomTemplate = {}
    local HostelRoomFloorList = {}
    local FunctionDeviceLvlTemplate = {}
    local FunctionDeviceSubType = {}
    local HostelRestTemplate = {}
    local HostelHudTemplate = {}
    local HostelMaxFloor = 0
    local MaxCharacterVitality = 0              --

    local HostelFloorData = {}
    local HostelFuncDeviceData = {}
    local PowerStationData = {}
    local WorkSlotDate = {}

    local PROTOCAL_REQUEST_NAME = {
        RestCharacterRequest = "RestCharacterRequest",
        UnrestCharacterRequest = "UnrestCharacterRequest",
        UpgradeFunctionDeviceRequest = "UpgradeFunctionDeviceRequest",
        ConfirmFunctionDeviceUpgradeRequest = "ConfirmFunctionDeviceUpgradeRequest",
        CollectElectricRequest = "CollectElectricRequest",
        CollectSlotProductRequest = "CollectSlotProductRequest",
        WorkInFunctionDeviceRequest = "WorkInFunctionDeviceRequest",
    }

    local table_insert = table.insert


    function XHostelManager.Init()
        SceneToHostelRoomNodeMap = XHostelConfigs.GetSceneToHostelRoomNodeMap()
        SceneToHostelDeviceNodeMap = XHostelConfigs.GetSceneToHostelDeviceNodeMap()
        HostelRoomTemplate = XHostelConfigs.GetHostelRoomTemplate()
        HostelRoomFloorList = XHostelConfigs.GetHostelRoomFloorList()
        FunctionDeviceLvlTemplate = XHostelConfigs.GetFunctionDeviceLvlTemplate()
        FunctionDeviceSubType = XHostelConfigs.GetFunctionDeviceSubType()
        HostelRestTemplate = XHostelConfigs.GetHostelRestTemplate()
        HostelHudTemplate = XHostelConfigs.GetHostelHudTemplate()

        HostelMaxFloor = XHostelConfigs.HostelMaxFloor
        MaxCharacterVitality = XHostelConfigs.MaxCharacterVitality
    end
    
    ----------------配置处理-----------------------
    function XHostelManager.GetHostelRoomTemplate(templateId)
        return HostelRoomTemplate[templateId]
    end

    function XHostelManager.GetHostelFloorRoomListTemplate(floor)
        return HostelRoomFloorList[floor]
    end

    function XHostelManager.GetSceneRoomNodeMap(scene)
        return SceneToHostelRoomNodeMap[scene]
    end

    function XHostelManager.GetSceneDeviceNodeMap(scene, id)
        return SceneToHostelDeviceNodeMap[scene][id]
    end

    function XHostelManager.GetHostelFunctionDeviceLevelTempalte(type, level)
        if not FunctionDeviceLvlTemplate[type] then
            return
        end
        return FunctionDeviceLvlTemplate[type][level]
    end

    function XHostelManager.GetFuncDeviceSlotTemplate(slot)
        return XHostelManager.GetHostelFunctionDeviceLevelTempalte(slot,1)
    end

    function XHostelManager.GetHostelRestTemplate(floor)
        return HostelRestTemplate[floor]
    end

    function XHostelManager.GetHostelFloorRestCount(floor)
        return HostelRestTemplate[floor].RestCharCount
    end

    function XHostelManager.GetHostelMaxFloor()
        return HostelMaxFloor
    end

    function XHostelManager.GetMaxCharacterVitality()
        return MaxCharacterVitality
    end

    function XHostelManager.GetFunctionDeviceSubTypeList(type)
        return FunctionDeviceSubType[type]
    end

    function XHostelManager.GetWorkSlotWorkTime(slot)
        local slotCfg = XHostelManager.GetFuncDeviceSlotTemplate(slot)
        if not slotCfg then
            return 0
        end
        if slotCfg.BelongType == XHostelManager.FunctionDeviceType.PowerStation then
            return slotCfg.FunctionParam[1] * slotCfg.FunctionParam[3]
        elseif slotCfg.BelongType == XHostelManager.FunctionDeviceType.Factory then
            return slotCfg.FunctionParam[1]
        end
    end

    function XHostelManager.GetHudTemplate(hudType, deviceType)
        if not HostelHudTemplate[hudType] then
            return
        end
        return HostelHudTemplate[hudType][deviceType]
    end

    ----------------模块逻辑-----------------------
    function XHostelManager.InitHostelData(hostelData)
        if not hostelData then
            return
        end
        XTool.LoopMap(hostelData.FloorData, function(key, value)
            HostelFloorData[key] = {}
            HostelFloorData[key].RoomList = {}
            HostelFloorData[key].RestCharList = {}
            XTool.LoopCollection(value.RoomList, function(roomdata)
                table_insert(HostelFloorData[key].RoomList, roomdata)
            end)
            XTool.LoopCollection(value.RestCharList, function(restdata)
                table_insert(HostelFloorData[key].RestCharList, restdata)
            end)
        end)

        XTool.LoopMap(hostelData.FunctionDeviceData, function(key, value)
            HostelFuncDeviceData[key] = value
        end)

        PowerStationData.CurSaveElectric = hostelData.PowerStationData.CurSaveElectric
        XTool.LoopMap(hostelData.WorkSlotDate, function(key,data)
            WorkSlotDate[key] = data
        end)
    end

    function XHostelManager.ResetCharWorkData(XHostelCharWorkData)
        XHostelCharWorkData.CharacterId = 0
        XHostelCharWorkData.BeginTime = 0
        XHostelCharWorkData.LastCalcTime = 0
    end

    function XHostelManager.GetFuncDeviceUpgradeTime(type)
        if not HostelFuncDeviceData[type] then
            return
        end
        return HostelFuncDeviceData[type].UpgradeBeginTime
    end

    function XHostelManager.GetFunctionDeviceLevel(type)
        if not HostelFuncDeviceData[type] then
            return
        end
        return HostelFuncDeviceData[type].Level
    end

    function XHostelManager.GetFunctionDeviceData(type)
        return HostelFuncDeviceData[type]
    end

    function XHostelManager.IsFuncDeviceUpgrading(type)
        local data = HostelFuncDeviceData[type]
        if not data then return false end
        return data.UpgradeBeginTime ~= 0
    end

    function XHostelManager.GetFuncDeviceUpgradeState(type)
        local deveice = XHostelManager.GetFunctionDeviceData(type)
        if not deveice or deveice.UpgradeBeginTime == 0 then
            return XHostelManager.DeviceUpgradeState.Normal
        end
        local nextConfig = XHostelManager.GetHostelFunctionDeviceLevelTempalte(type,deveice.Level + 1)
        if not nextConfig then
            return XHostelManager.DeviceUpgradeState.Unknown
        end
        local endUpgradTime = deveice.UpgradeBeginTime + nextConfig.CostTime
        local curTime = XTime.GetServerNowTimestamp()
        if curTime >= endUpgradTime then
            return XHostelManager.DeviceUpgradeState.Complete
        else
            return XHostelManager.DeviceUpgradeState.Upgrading,endUpgradTime - curTime
        end
    end

    function XHostelManager.GetFuncDeviceCurLvlTemplate(type)
        local level = XHostelManager.GetFunctionDeviceLevel(type)
        if not level then return end
        return XHostelManager.GetHostelFunctionDeviceLevelTempalte(type,level)
    end

    function XHostelManager.IsHostelFloorOpen(floor)
        if HostelFloorData[floor] then
            return true
        end
        return false
    end

    function XHostelManager.IsFloorBuildRoomFull(floor)
        local configList = XHostelManager.GetHostelFloorRoomListTemplate(floor)
        local roomList = XHostelManager.GetFloorRoomList(floor)
        if not configList or not roomList then
            return false
        end
        return #configList == #roomList
    end

    function XHostelManager.GetFloorData(floor)
        return HostelFloorData[floor]
    end

    function XHostelManager.GetFloorRoomList(floor)
        if not HostelFloorData[floor] then
            return
        end
        return HostelFloorData[floor].RoomList
    end

    function XHostelManager.GetFloorRestDataList(floor)
        if not HostelFloorData[floor] then
            return
        end
        return HostelFloorData[floor].RestCharList
    end

    function XHostelManager.GetAllRestCharDataList()
        local tCharList = {}
        for _, data in pairs(HostelFloorData) do
            for i,v in ipairs(data.RestCharList) do
                table_insert(tCharList,v)
            end
        end
        return tCharList
    end

    function XHostelManager.IsCharacterInRest(charId)
        for floor, floorData in pairs(HostelFloorData) do
            for i,v in ipairs(floorData.RestCharList) do
                if v.CharacterId == charId then
                    return true,floor
                end
            end
        end
        return false
    end

    function XHostelManager.IsCharacterInWork(charId)
        for k,v in pairs(WorkSlotDate) do
            if v.CharacterId == charId then
                return true
            end
        end
        return false
    end

    function XHostelManager.GetHostelRestData(floor, slot)
        local restCharList = XHostelManager.GetFloorRestDataList(floor)
        if not restCharList then return end
        for i,v in ipairs(restCharList) do
            if v.Slot == slot then
                return v
            end
        end
    end

    function XHostelManager.SetHostelRestData(floor, XRestCharData)
        local floorData = XHostelManager.GetFloorData(floor)
        if not floorData then return end
        if not floorData.RestCharList then
            floorData.RestCharList = {}
        end
        for i,v in ipairs(floorData.RestCharList) do
            if v.Slot == XRestCharData.Slot then
                floorData.RestCharList[i] = XRestCharData
                return
            end
        end
        table_insert(floorData.RestCharList,XRestCharData)
    end

    function XHostelManager.ResetHostelRestData(floor, slot)
        local floorData = XHostelManager.GetFloorData(floor)
        if not floorData then return end
        if not floorData.RestCharList then
            floorData.RestCharList = {}
        end
        for i,v in ipairs(floorData.RestCharList) do
            if v.Slot == slot then
                XHostelManager.ResetCharWorkData(v)
                return
            end
        end
    end

    --------------------工作槽位-----------------------

    function XHostelManager.CheckWorkSlotIsEmpty(slot)
        local workChar = WorkSlotDate[slot]
        if not workChar or workChar.CharacterId == 0 then
            return true
        end
        return false
    end

    function XHostelManager.CheckWorkSlotIsIdle(slot)
        local workChar = WorkSlotDate[slot]
        if workChar and workChar.BeginTime > 0 then
            return false
        end
        return true
    end

    function XHostelManager.GetWorkCharBySlot(slot)
        return WorkSlotDate[slot]
    end

    function XHostelManager.SetWorkSlotData(workChar)
        WorkSlotDate[workChar.Slot] = workChar
    end

    function XHostelManager.ResetWorkSlotData(slot)
        local workChar = WorkSlotDate[slot]
        if not workChar then
            return
        end
        XHostelManager.ResetCharWorkData(workChar)
    end

    function XHostelManager.GetDevieWorkSlotPruduct(slotType)
        local slotCfg = XHostelManager.GetFuncDeviceSlotTemplate(slotType)
        if not slotCfg then
            return 0,0
        end
        local deviceCfg = XHostelManager.GetFuncDeviceCurLvlTemplate(slotCfg.BelongType)
        if not deviceCfg then
            return 0,0
        end
        if slotCfg.BelongType == XHostelManager.FunctionDeviceType.PowerStation then
            Id = XDataCenter.ItemManager.ItemId.HostelElectric
            count = (slotCfg.FunctionParam[1]) * (slotCfg.FunctionParam[4] + deviceCfg.FunctionParam[4])
        elseif slotCfg.BelongType == XHostelManager.FunctionDeviceType.Factory then
            Id = slotCfg.FunctionParam[3]
            count = deviceCfg.FunctionParam[1] + slotCfg.FunctionParam[4]
        end
        return Id, count
    end

    function XHostelManager.GetWorkSlotState(slot)
        local slotCfg = XHostelManager.GetFuncDeviceSlotTemplate(slot)
        if not slotCfg then
            return XHostelManager.WorkSlotState.Unknown
        end
        if slotCfg.ConditionId ~= 0 and not XConditionManager.CheckCondition(slotCfg.ConditionId) then
            return XHostelManager.WorkSlotState.Lock
        end
        local workChar = WorkSlotDate[slot]
        if not workChar or (workChar.CharacterId == 0 and workChar.BeginTime == 0 ) then
            return XHostelManager.WorkSlotState.Idle
        end
        if workChar.BeginTime > 0 then
            local curTime = XTime.GetServerNowTimestamp()
            local workTime = workChar.BeginTime + XHostelManager.GetWorkSlotWorkTime(slot)
            if workTime <= curTime then
                if slotCfg.BelongType == XHostelManager.FunctionDeviceType.PowerStation then
                    return XHostelManager.WorkSlotState.Idle
                else
                    return XHostelManager.WorkSlotState.Complete
                end
            else
                return XHostelManager.WorkSlotState.Working, workTime - curTime
            end
        end
        return XHostelManager.WorkSlotState.Unknown
    end

    function XHostelManager.GetCurDeviceWorkSlot(deviceType)
        local slotList = XHostelManager.GetFunctionDeviceSubTypeList(deviceType)
        local slotOpenList = {}
        for _,ty in ipairs(slotList) do
            local slotConfig = XHostelManager.GetFuncDeviceSlotTemplate(ty)
            if slotConfig then
                if slotConfig.ConditionId == 0 or XConditionManager.CheckCondition(slotConfig.ConditionId) then
                    table_insert(slotOpenList,ty)
                end
            end
        end
        return slotOpenList
    end

    function XHostelManager.CalcDeviceSlotLevel(deviceType,deviceLevel)
        local slotList = XHostelManager.GetFunctionDeviceSubTypeList(deviceType)
        local slotCount = 0
        local slotOpenList = {}
        for _,ty in ipairs(slotList) do
            local slotConfig = XHostelManager.GetFuncDeviceSlotTemplate(ty)
            if slotConfig and deviceLevel then
                local open = false
                local conditon = XConditionManager.GetConditionTemplate(slotConfig.ConditionId)
                if not conditon then
                    open = true
                elseif conditon.Type == 20101 and conditon.Params[1] == deviceType and deviceLevel >= conditon.Params[2] then
                    open = true
                elseif XConditionManager.CheckCondition(slotConfig.ConditionId) then
                    open = true
                end
                if open then
                    table_insert(slotOpenList,ty)
                end
            end
        end
        return slotOpenList
    end

    ---------------------发电站----------------------
    function XHostelManager.GetPowerStationSaveElectric()
        return PowerStationData.CurSaveElectric
    end

    --------------------访问他人宿舍--------------
    function XHostelManager.IsInVisitFriendHostel()
        return false
    end

    -------------------消息通讯--------------------------
    function XHostelManager.ReqRestCharacter(charId, floor, slot, cb)
        XNetwork.Call(PROTOCAL_REQUEST_NAME.RestCharacterRequest, {CharacterId = charId, FloorId = floor, Slot = slot}, function(response)
            if response.Code ~= XCode.Success then
                XUiManager.TipCode(response.Code)
                return
            end
            XHostelManager.SetHostelRestData(floor, response.RestChar)
            if response.ChangeFloor and response.ChangeFloor > 0 then
                XHostelManager.SetHostelRestData(response.ChangeFloor, response.ChangeData)
            end
            if cb then
                cb()
            end
        end)
    end

    function XHostelManager.ReqUnRestCharacter(floor, slot, cb)
        XNetwork.Call(PROTOCAL_REQUEST_NAME.UnrestCharacterRequest, {FloorId = floor, Slot = slot}, function(response)
            if response.Code ~= XCode.Success then
                XUiManager.TipCode(response.Code)
                return
            end
            XHostelManager.ResetHostelRestData(floor, slot)
            if cb then
                cb()
            end
        end)
    end

    function XHostelManager.ReqFuncDeviceUpgrade(type, cb)
        XNetwork.Call(PROTOCAL_REQUEST_NAME.UpgradeFunctionDeviceRequest, {Type = type}, function(response)
            if response.Code ~= XCode.Success then
                XUiManager.TipCode(response.Code)
                return
            end
            HostelFuncDeviceData[response.DeviceData.Type] = response.DeviceData
            if cb then
                cb()
            end
        end)
    end

    function XHostelManager.ComfirmFuncDeviceUpgrade(type, cb)
        XNetwork.Call(PROTOCAL_REQUEST_NAME.ConfirmFunctionDeviceUpgradeRequest, {Type = type}, function(response)
            if response.Code ~= XCode.Success then
                XUiManager.TipCode(response.Code)
                return
            end
            HostelFuncDeviceData[response.DeviceData.Type] = response.DeviceData
            if cb then
                cb()
            end
        end)
    end

    function XHostelManager.ReqCollectPowerStationElectric(cb)
        XNetwork.Call(PROTOCAL_REQUEST_NAME.CollectElectricRequest, nil, function(response)
            if response.Code ~= XCode.Success then
                XUiManager.TipCode(response.Code)
                return
            end
            PowerStationData.CurSaveElectric = 0
            if cb then
                cb()
            end
        end)
    end

    function XHostelManager.ReqWorkInFunctionDevice(charId, slot, cb)
        XNetwork.Call(PROTOCAL_REQUEST_NAME.WorkInFunctionDeviceRequest, {CharId = charId, Slot = slot}, function(response)
            if response.Code ~= XCode.Success then
                XUiManager.TipCode(response.Code)
                return
            end
            local slotConfig =  XHostelManager.GetFuncDeviceSlotTemplate(slot)
            if not slotConfig then
                return
            end
            XHostelManager.SetWorkSlotData(response.WorkChar)
            if cb then
                cb()
            end
        end)
    end

    function XHostelManager.ReqCollectSlotProduct(slot, cb)
        cb = cb or function() end
        XNetwork.Call(PROTOCAL_REQUEST_NAME.CollectSlotProductRequest, {Slot = slot}, function(response)
            if response.Code ~= XCode.Success then
                XUiManager.TipCode(response.Code)
                return
            end

            local charId = XHostelManager.GetWorkCharBySlot(slot).CharacterId
            XHostelManager.ResetWorkSlotData(slot)
            cb(charId, response.Rewards)
        end)
    end

    function XHostelManager.OnSyncPowerStationSaveElectric(saveElectric)
        PowerStationData.CurSaveElectric = saveElectric
    end

    function XHostelManager.OnSyncCharacterWorkData(workChar)
        WorkSlotDate[workChar.Slot] = workChar
    end

    function XHostelManager.OnSyncFunctionDeviceData(XDeviceData)
        HostelFuncDeviceData[XDeviceData.Type] = XDeviceData
    end

    XHostelManager.Init()
    return XHostelManager
end

XRpc.NotifyPowerStationSaveElectric = function(data)
    XDataCenter.HostelManager.OnSyncPowerStationSaveElectric(data.SaveElectric)
end

XRpc.NotifyCharacterWorkData = function(data)
    XDataCenter.HostelManager.OnSyncCharacterWorkData(data.WorkChar)
end

XRpc.NotifyFunctionDeviceData = function(data)
    XDataCenter.HostelManager.OnSyncFunctionDeviceData(data.DeviceData)
end