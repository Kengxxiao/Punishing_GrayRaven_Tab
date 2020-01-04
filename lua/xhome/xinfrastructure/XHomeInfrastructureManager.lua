---
--- 基建管理器
---(管理基建场景对象)
---

XHomeInfrastructureManager = XHomeInfrastructureManager or {}

local RoomType = {
    Dormitory = 4, --基地装备
}

local RoomRoot = nil
local RoomList = {}

-- 初始化场景
local function InitScene(sceneRootGo)
    XLuaUiManager.Open("UiHomeMain", XDataCenter.HostelManager.SceneType.Function)

    RoomRoot = sceneRootGo.transform:Find("GroupTerrain")
    local room_map = XDataCenter.HostelManager.GetSceneRoomNodeMap("RoomDomitory")
    for id, cfg in pairs(room_map) do
        local go = sceneRootGo.transform:Find(cfg.Path).gameObject
        local room = XRoomObject.New(go, RoomRoot, cfg)
        if cfg.Id == RoomType.Dormitory then
            local baseEquipRedPoint = sceneRootGo.transform:Find(cfg.Path .. "/redPoint")
            if not XTool.UObjIsNil(baseEquipRedPoint) then
                baseEquipRedPoint.gameObject:SetActive(XDataCenter.BaseEquipManager.CheckBaseEquipHint())
            end
            room:OnClick()--临时屏蔽其它模块
        end
        table.insert(RoomList, room)
    end
end

-- 移除场景
local function RemoveScene()
    for _, room in ipairs(RoomList) do
        room:Dispose()
    end
    RoomList = {}

    if not XTool.UObjIsNil(RoomRoot) then
        CS.UnityEngine.GameObject.Destroy(RoomRoot.gameObject)
    end
    RoomRoot = nil
end

-- 进入基建
function XHomeInfrastructureManager.EnterInfrastructure()
    --XHomeSceneManager.EnterScene("RoomDomitory", CS.XGame.ClientConfig:GetString("RoomDomitoryAssetUrl"), InitScene, RemoveScene)
end

function XHomeInfrastructureManager.ChangeCameraToScene()
    for i, room in ipairs(RoomList) do
        room:HideDeviceHud()
        room:CheckShowHud()
    end
end