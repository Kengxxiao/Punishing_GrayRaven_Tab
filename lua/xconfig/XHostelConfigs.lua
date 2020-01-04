XHostelConfigs = XHostelConfigs or {}

local tableInsert = table.insert
local pairs = pairs

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
local MaxCharacterVitality = 0    


local FuncFindInList = function(tList, value)
    for i, v in ipairs(tList) do
        if v == value then
            return true
        end
    end
    return false
end

function XHostelConfigs.Init()
    local rooms = XTableManager.ReadByIntKey(TABLE_HOSTEL_ROOM_NODE_PATH, XTable.XTableHostelRoomNode, "Id")
    for _, config in pairs(rooms) do
        local sceneTab = SceneToHostelRoomNodeMap[config.Scene]
        if not sceneTab then
            sceneTab = {}
            SceneToHostelRoomNodeMap[config.Scene] = sceneTab
        end

        sceneTab[config.Id] = config
    end

    local configs = XTableManager.ReadByIntKey(TABLE_HOSTEL_DEVICE_NODE_PATH, XTable.XTableHostelDeviceNode, "Id")
    for _, config in pairs(configs) do
        local sceneTab = SceneToHostelDeviceNodeMap[config.Scene]
        if not sceneTab then
            sceneTab = {}
            SceneToHostelDeviceNodeMap[config.Scene] = sceneTab
        end

        local roomTab = sceneTab[config.RoomType]
        if not roomTab then
            roomTab = {}
            sceneTab[config.RoomType] = roomTab
        end

        roomTab[config.Id] = config
    end

    local hudConfigs = XTableManager.ReadByIntKey(TABLE_HOSTEL_HUD_PATH, XTable.XTableHostelHud, "Id")
    for _, config in pairs(hudConfigs) do
        local hudTypeMap = HostelHudTemplate[config.HudType]
        if not hudTypeMap then
            hudTypeMap = {}
            HostelHudTemplate[config.HudType] = hudTypeMap
        end
        hudTypeMap[config.DeviceType] = config
    end

    MaxCharacterVitality = CS.XGame.Config:GetInt("MaxCharacterVitality")

    HostelRoomTemplate = XTableManager.ReadByIntKey(TABLE_HOSTELROOM_PATH, XTable.XTableHostelRoom, "Id")
    for k, v in pairs(HostelRoomTemplate) do
        if not HostelRoomFloorList[v.Floor] then
            HostelRoomFloorList[v.Floor] = {}
        end
        HostelRoomFloorList[v.Floor][k] = v
    end

    local totalFuncDeviceData = XTableManager.ReadByIntKey(TABLE_HOSTEL_FUNCDEVICE_PATH, XTable.XTableFunctionDevice, "Id")
    for k, v in pairs(totalFuncDeviceData) do
        if not FunctionDeviceLvlTemplate[v.Type] then
            FunctionDeviceLvlTemplate[v.Type] = {}
        end
        FunctionDeviceLvlTemplate[v.Type][v.Level] = v
        if v.BelongType and v.BelongType ~= 0 then
            if not FunctionDeviceSubType[v.BelongType] then
                FunctionDeviceSubType[v.BelongType] = {}
            end
            local tTypeList = FunctionDeviceSubType[v.BelongType]
            if not FuncFindInList(tTypeList, v.Type) then
                tableInsert(tTypeList, v.Type)
            end
        end
    end

    HostelRestTemplate = XTableManager.ReadByIntKey(TABLE_HOSTEL_REST_PATH, XTable.XTableHostelRest, "Floor")
    for floor, _ in pairs(HostelRestTemplate) do
        if floor > HostelMaxFloor then
            HostelMaxFloor = floor
        end
    end

    XHostelConfigs.HostelMaxFloor = HostelMaxFloor
    XHostelConfigs.MaxCharacterVitality = MaxCharacterVitality
end

function XHostelConfigs.GetSceneToHostelRoomNodeMap()
    return SceneToHostelRoomNodeMap
end

function XHostelConfigs.GetSceneToHostelDeviceNodeMap()
    return SceneToHostelDeviceNodeMap
end

function XHostelConfigs.GetHostelRoomTemplate()
    return HostelRoomTemplate
end

function XHostelConfigs.GetHostelRoomFloorList()
    return HostelRoomFloorList
end

function XHostelConfigs.GetFunctionDeviceLvlTemplate()
    return FunctionDeviceLvlTemplate
end

function XHostelConfigs.GetFunctionDeviceSubType()
    return FunctionDeviceSubType
end

function XHostelConfigs.GetHostelRestTemplate()
    return HostelRestTemplate
end

function XHostelConfigs.GetHostelHudTemplate()
    return HostelHudTemplate
end