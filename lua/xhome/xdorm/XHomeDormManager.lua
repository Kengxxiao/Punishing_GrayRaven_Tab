---
--- 宿舍管理器
--- 管理场景上对象
---
XHomeDormManager = XHomeDormManager or {}

local XHomeRoomObj = require("XHome/XDorm/XHomeRoomObj")
local XHomeFurnitureObj = require("XHome/XDorm/XHomeFurnitureObj")

-- 格子颜色了类型
GridColorType = {
    Default = 1,
    Green = 2,
    Red = 3,
    Interact = 4,
    Blue = 5,
}

local GRID_COLOR_PATH =
{
    Default =CS.XGame.ClientConfig:GetString("HomeGridColorDefaultAssetUrl"),
    Green = CS.XGame.ClientConfig:GetString("HomeGridColorGreenAssetUrl"),
    Red = CS.XGame.ClientConfig:GetString("HomeGridColorRedAssetUrl"),
    Interact = CS.XGame.ClientConfig:GetString("HomeGridColorInteractAssetUrl"),
    Blue = CS.XGame.ClientConfig:GetString("HomeGridColorBlueAssetUrl")
}

local IsSelf = false
local InDormitoryScene = false

local GridColorSoDic = {}
local ResourceCacheDic = {}

local MapResource = nil
local MapTransform = nil
local GroundRoot = nil
local WallRoot = nil
local HomeMapManager = nil  --房间地图配置管理器

local RoomFacade = nil  --房间外墙模板
local RoomRoot = nil
local RoomDic = {}

local TallBuilding = nil

local CurSelectedRoom = nil

local IsSelectedFurniture = false
local ClickFurnitureCallback = nil

XHomeDormManager.DormBgm = {}
XHomeDormManager.FurnitureShowAttrType = -1

local FurnitureMiniorType = {
    Ground = 1,
    Wall = 2,
    Ceiling = 3,
    BigFurniture = 4,
    SmallFurniture = 5,
    DecorateFurniture = 6,
    PetFurniture = 7,
}

local RecordRoomPutup = {}
-- 初始化场景
local function InitScene(go, datas,dormDataType, onFinishLoadScene,isenterroom)
    CS.XGridManager.Instance:Init()

    --场景全局光照
    XHomeSceneManager.SetGlobalIllumSO(CS.XGame.ClientConfig:GetString("HomeSceneSoAssetUrl"))

    --格子颜色信息资源
    for key, path in pairs(GRID_COLOR_PATH) do
        local resource = CS.XResourceManager.Load(path)
        if resource then
            GridColorSoDic[GridColorType[key]] = resource
        end
    end

    TallBuilding = go.transform:Find("GroupBase/@TallBuilding")
    RoomFacade = go.transform:Find("@RoomFacade")
    RoomRoot = go.transform:Find("@Room")
    if not XTool.UObjIsNil(RoomRoot) then
        XHomeDormManager.LoadRooms(datas, dormDataType)
    end

    local camera = XHomeSceneManager.GetSceneCamera()
    HomeMapManager:SetCamera(camera)

    if dormDataType == XDormConfig.DormDataType.Self then
        XLuaUiManager.OpenWithCallback("UiDormMain", function()
            XLuaUiManager.Open("UiDormComponent")

            if onFinishLoadScene then
                onFinishLoadScene()
            end
            if isenterroom then
                XLuaUiManager.Open("UiDormSecond", XDormConfig.VisitDisplaySetType.MySelf, XHomeDormManager.DormitoryId)
            end
        end)
    else
        if not XLuaUiManager.IsUiLoad("UiDormSecond") then
            local visit = XDormConfig.VisitDisplaySetType.Stranger
            if XDataCenter.SocialManager.CheckIsFriend(XHomeDormManager.TargetId) then
                visit = XDormConfig.VisitDisplaySetType.MyFriend
            end
            XLuaUiManager.OpenWithCallback("UiDormSecond", function()
                XLuaUiManager.Close("UiLoading")
            end,visit,XHomeDormManager.DormitoryId)
        end
    end

    XHomeCharManager.Init()
    InDormitoryScene = true
end

-- 移除场景
local function RemoveScene()
    InDormitoryScene = false
    CS.XGridManager.Instance:Clear()
    for _, v in pairs(GridColorSoDic) do
        if v then
            v:Release()
        end
    end
    GridColorSoDic = {}

    XLuaUiManager.Close("UiDormComponent")

    RoomFacade = nil
    RoomRoot = nil
    for _, room in pairs(RoomDic) do
        room:Dispose()
    end
    RoomDic = {}
    CurSelectedRoom = nil

    HomeMapManager = nil
    GroundRoot = nil
    WallRoot = nil
    if not XTool.UObjIsNil(MapTransform) then
        CS.UnityEngine.GameObject.Destroy(MapTransform.gameObject)
    end
    MapTransform = nil
    if MapResource then
        MapResource:Release()
    end
    MapResource = nil

    for k, v in pairs(ResourceCacheDic) do
        CS.XResourceManager.Unload(v)
    end
    ResourceCacheDic = {}
end

-- 初始化地表地图
local function InitSurfaceMap(model)
    MapTransform = model.transform
    GroundRoot = MapTransform:Find("@GroundRoot")
    WallRoot = MapTransform:Find("@WallRoot")
    MapTransform:SetParent(nil)
    MapTransform.gameObject:SetActive(false)
    HomeMapManager = model:GetComponent("XHomeMapManager")
    HomeMapManager:Init()
end

-- 进入宿舍
function XHomeDormManager.EnterDorm(targetId, dormitoryId, isSele, onFinishLoadScene, onFinishEnterRoom)
    local isSelf = true
    local dormDataType = XDormConfig.DormDataType.Self
    XHomeDormManager.TargetId = targetId
    XHomeDormManager.DormitoryId = dormitoryId

    if targetId and targetId ~= XPlayer.Id then
        isSelf = false
        dormDataType = XDormConfig.DormDataType.Target
    end

    local cb = function()
        IsSelf = isSelf

        local datas = XDataCenter.DormManager.GetDormitoryData(dormDataType)

        local onLoadCompleteCb = function(go)
            go.gameObject:SetActive(true)
            InitScene(go, datas,dormDataType, onFinishLoadScene,isSele)
            
            if dormitoryId and isSele then
                -- if not XLuaUiManager.IsUiLoad("UiDormSecond") then
                --     if not isSelf then
                --         XLuaUiManager.Open("UiDormSecond", XDormConfig.VisitDisplaySetType.MyFriend, dormitoryId)
                --     else
                --         XLuaUiManager.Open("UiDormSecond", XDormConfig.VisitDisplaySetType.MySelf, dormitoryId)
                --     end
                -- end
                XHomeDormManager.SetSelectedRoom(dormitoryId, true, nil, onFinishEnterRoom)
            end
        end

        XDataCenter.DormManager.RequestDormitoryDormEnter()

        MapResource = CS.XResourceManager.Load(CS.XGame.ClientConfig:GetString("HomeMapAssetUrl"))
        local model = CS.UnityEngine.Object.Instantiate(MapResource.Asset)
        InitSurfaceMap(model)

        --XHomeSceneManager.SetSceneType(CS.XSceneType.Dormitory)
        CS.XGlobalIllumination.SetSceneType(CS.XSceneType.Dormitory)
        XHomeSceneManager.EnterScene("sushe003",CS.XGame.ClientConfig:GetString("SuShe003"), onLoadCompleteCb, RemoveScene)

    end

    -- if not XDataCenter.DormManager.IsFirstTotal then
    --     if isSelf then
    --         XDataCenter.DormManager.RequestDormitoryData(cb)
    --     else
    --         XDataCenter.DormManager.RequestDormitoryData()
    
    --         local charId = XDataCenter.DormManager.GetVisitorDormitoryCharacterId()
    --         XDataCenter.DormManager.RequestDormitoryVisit(targetId, dormitoryId, charId, cb)
    --     end
    -- else
    --     cb()
    -- end
    if isSelf then
        if not XDataCenter.DormManager.IsFirstTotal then
            XDataCenter.DormManager.RequestDormitoryData(cb)
        else
            cb()
        end
    else
        XDataCenter.DormManager.RequestDormitoryData()    
        local charId = XDataCenter.DormManager.GetVisitorDormitoryCharacterId()
        XDataCenter.DormManager.RequestDormitoryVisit(targetId, dormitoryId, charId, cb)
    end
end

--获取房间信息
function XHomeDormManager.GetRoom(roomId)
    if not RoomDic then
        return nil
    end

    return RoomDic[roomId]
end

--设置房间交互信息GameObject
function XHomeDormManager.SetRoomInteractInfo(roomId)
    local interactPosGos = {}
    local room = XHomeDormManager.GetRoom(roomId)
    if room then
        room:SetInteractInfoGo()
    end
end

--隐藏房间交互信息GameObject
function XHomeDormManager.HideRoomInteractInfo(roomId)
    local interactPosGos = {}
    local room = XHomeDormManager.GetRoom(roomId)
    if room then
        room:HideInteractInfoGo()
    end
end

-- 加载宿舍房间
function XHomeDormManager.LoadRooms(datas, loadtype)
    if datas == nil then
        return
    end

    local id = nil

    for _, data in pairs(datas) do
        local room = RoomDic[data.Id]
        if not room then
            local room_trans = RoomRoot:Find("@Room_" .. data.Id)
            local room_trans_Putup = room_trans:Find("@Hud")
            if not XTool.UObjIsNil(room_trans) then
                room = XHomeRoomObj.New(data, RoomFacade)
                RoomDic[data.Id] = room
                room:SetModel(room_trans.gameObject,loadtype)
                RecordRoomPutup[data.Id] = room_trans_Putup
            end
        else
            room:SetData(data, loadtype)
        end

        if not id then
            id = data.Id
        end
    end

    XHomeSceneManager.ChangeView(HomeSceneViewType.OverView)
end

function XHomeDormManager.GetRoomsPutup(dormid)
    return RecordRoomPutup[dormid]
end

-- 将地图网格挂到指定房间根节点
function XHomeDormManager.AttachSurfaceToRoom(roomId)
    if not roomId then
        MapTransform.gameObject:SetActive(false)
    end

    local room = RoomDic[roomId]
    if room and not XTool.UObjIsNil(room.Transform) then
        local groundSurface = GroundRoot:GetComponentInChildren(typeof(CS.XHomeSurface))
        if not XTool.UObjIsNil(groundSurface) then
            groundSurface.ConfigId = room.Ground.Data.CfgId
        end

        -- 4个
        local wallSurface = WallRoot:GetComponentInChildren(typeof(CS.XHomeSurface))
        if not XTool.UObjIsNil(wallSurface) then
            wallSurface.ConfigId = room.Wall.Data.CfgId
        end

        MapTransform:SetParent(room.Transform, false)
        MapTransform.localPosition = CS.UnityEngine.Vector3.zero;
        MapTransform.localRotation = CS.UnityEngine.Quaternion.identity
        MapTransform.localScale = CS.UnityEngine.Vector3.one

        MapTransform.gameObject:SetActive(true)
    end
end

--锁定墙体碰撞盒
function XHomeDormManager.LockCollider(rotate)
    if XTool.UObjIsNil(HomeMapManager) then
        return
    end
    HomeMapManager:LockCollider(rotate)
end


function XHomeDormManager.OnShowBlockGrids(platType,gridOffset,rotate)
    if XTool.UObjIsNil(HomeMapManager) then
        return
    end

    local so = XHomeDormManager.GetGridColorSO(GridColorType.Red)
    HomeMapManager:OnShowBlockGrids(platType,gridOffset,so.Asset,rotate)
end

function XHomeDormManager.OnHideBlockGrids(platType,rotate)
    if XTool.UObjIsNil(HomeMapManager) then
        return
    end
    
    HomeMapManager:OnHideBlockGrids(platType,rotate)
end

--解锁墙体碰撞盒
function XHomeDormManager.UnlockCollider()
    if XTool.UObjIsNil(HomeMapManager) then
        return
    end
    HomeMapManager:UnlockCollider()
end

--获取家具交互点格子坐标
function XHomeDormManager.GetInteractGridPos(furnitureX, furnitureY, width, height, x, y, rotate)
    if XTool.UObjIsNil(HomeMapManager) then
        return
    end

    -- 返回（格子坐标；该坐标是否在房间地图内）
    return HomeMapManager:GetInteractGridPos(furnitureX, furnitureY, width, height, x, y, rotate)
end

-- 获取地图格子边长
function XHomeDormManager.GetCeilSize()
    if XTool.UObjIsNil(HomeMapManager) then
        return 0
    end
    return HomeMapManager.CeilSize
end

-- 获取地图宽
function XHomeDormManager.GetMapWidth()
    if XTool.UObjIsNil(HomeMapManager) then
        return 0
    end
    return HomeMapManager.MapSize.x
end

-- 获取地图高
function XHomeDormManager.GetMapHeight()
    if XTool.UObjIsNil(HomeMapManager) then
        return 0
    end
    return HomeMapManager.MapSize.y
end

-- 获取地图墙高
function XHomeDormManager.GetMapTall()
    if XTool.UObjIsNil(HomeMapManager) then
        return 0
    end
    return HomeMapManager.MapSize.z
end

-- 获取格子颜色SO
function XHomeDormManager.GetGridColorSO(gridColorType)
    return GridColorSoDic[gridColorType]
end

-- 显示地表网格
function XHomeDormManager.ShowSurface(type)
    if XTool.UObjIsNil(MapTransform) then
        return
    end

    if type == CS.XHomePlatType.Ground then
        GroundRoot.gameObject:SetActive(true)
        WallRoot.gameObject:SetActive(false)
    elseif type == CS.XHomePlatType.Wall then
        GroundRoot.gameObject:SetActive(false)
        WallRoot.gameObject:SetActive(true)
    end
end

-- 收起房间全部家具
function XHomeDormManager.CleanRoom(roomId)
    local room = RoomDic[roomId]
    if not room then
        return
    end

    room:CleanRoom()
end

-- 重置房间
function XHomeDormManager.RevertRoom(roomId)
    local room = RoomDic[roomId]
    if not room then
        return
    end

    room:RevertRoom()
end

function XHomeDormManager.RevertOnWall(roomId)
    local room = RoomDic[roomId]
    if not room then
        return
    end

    room:CleanWallFurniture()
end

-- 重置当前宿舍光照
function XHomeDormManager.SetIllumination()
    if CurSelectedRoom then
        CurSelectedRoom:SetIllumination()
    end
end

-- 保存房间摆设
function XHomeDormManager.SaveRoomModification(roomId, cb)
    local room = RoomDic[roomId]
    if not room then
        return
    end

    --TODO 请求服务器修改房间摆设
    XDataCenter.DormManager.RequestDecorationRoom(roomId, room, cb)
end

-- 创建家具
function XHomeDormManager.CreateFurniture(roomId, furnitureData, gridPos, rotate)
    if not furnitureData then
        return
    end

    local room = RoomDic[roomId]
    if not room then
        return nil
    end

    local data = {}
    data.Id = furnitureData.Id
    data.CfgId = furnitureData.ConfigId
    data.GridX = gridPos.x
    data.GridY = gridPos.y
    data.RotateAngle = rotate

    local furniture = XHomeFurnitureObj.New(data, room)
    local root
    if furniture.Cfg.LocateType == XFurnitureConfigs.HomeLocateType.Replace then
        root = room.SurfaceRoot
    else
        root = room.FurnitureRoot
    end

    furniture:LoadModel(furniture.Cfg.Model, root)

    if room.Data:IsSelfData() then
        XHomeDormManager.ReplaceFurnitureMaterial(furniture, furnitureData.Id, XDormConfig.DormDataType.Self)
        XHomeDormManager.ReplaceFurnitureFx(furniture, furnitureData.Id, XDormConfig.DormDataType.Self)
    else
        XHomeDormManager.ReplaceFurnitureMaterial(furniture, furnitureData.Id, XDormConfig.DormDataType.Target)
        XHomeDormManager.ReplaceFurnitureFx(furniture, furnitureData.Id, XDormConfig.DormDataType.Target)
    end

    return furniture
end

function XHomeDormManager.ReplaceFurnitureMaterial(furniture, furnitureId, dormDataType)
    local materialPath = XDataCenter.FurnitureManager.GetFurnitureMaterial(furnitureId,dormDataType)
    if not materialPath then
        return
    end
    local targetMaterial = ResourceCacheDic[materialPath]
    if not targetMaterial then
        targetMaterial = CS.XResourceManager.Load(materialPath)
        ResourceCacheDic[materialPath] = targetMaterial
    end
    CS.XMaterialContainerHelper.ReplaceDormMat(furniture.GameObject, targetMaterial.Asset)
end

function XHomeDormManager.ReplaceFurnitureFx(furniture, furnitureId, dormDataType)
    local fxPath = XDataCenter.FurnitureManager.GetFurnitureFx(furnitureId,dormDataType)
    if not fxPath then
        return
    end

    local effect = furniture.Transform:Find("Effect")
    if not effect then return end
    effect.gameObject:LoadPrefab(fxPath)
end

-- 更换基础装修
function XHomeDormManager.ReplaceSurface(roomId, furniture)
    local room = RoomDic[roomId]
    if not room then
        return nil
    end

    room:ReplaceSurface(furniture)
end

-- 往房间中加入家具
function XHomeDormManager.AddFurniture(roomId, furniture)
    local room = RoomDic[roomId]
    if not room then
        return nil
    end

    room:AddFurniture(furniture)
end

-- 从房间中移除家具
function XHomeDormManager.RemoveFurniture(roomId, furniture)
    local room = RoomDic[roomId]
    if not room then
        return nil
    end

    room:RemoveFurniture(furniture)
end

-- 选中指定房间
function XHomeDormManager.SetSelectedRoom(roomId, isSelected, isvistor, onFinishEnterRoom)
    CS.XMirrorManager.Instance:SetDormLayer(isSelected, CS.UnityEngine.LayerMask.GetMask(HomeSceneLayerMask.Device))
    local room = RoomDic[roomId]
    if not room then
        return nil
    end

    if CurSelectedRoom then
        if CurSelectedRoom.Data.Id == room.Data.Id then
            CurSelectedRoom:SetCharacterExit()
            CurSelectedRoom:SetSelected(isSelected, true, onFinishEnterRoom)
            if isvistor then
                CurSelectedRoom = nil
            end
            XHomeSceneManager.SetGlobalIllumSO(CS.XGame.ClientConfig:GetString("HomeSceneSoAssetUrl"))
            return
        end

        CurSelectedRoom:SetSelected(false, nil, onFinishEnterRoom)
    end

    room:SetSelected(isSelected, true, onFinishEnterRoom)
    if isSelected then
        CurSelectedRoom = room
    end
end

function XHomeDormManager.CharacterExit(roomId)
    local room = RoomDic[roomId]
    if not room then
        return 
    end
    room:SetCharacterExit()
end

-- 显示或隐藏指定房间的外部景物
function XHomeDormManager.ShowOrHideOutsideRoom(baseRoomId, isShowOutside)
    -- 场景上高楼
    if not XTool.UObjIsNil(TallBuilding) then
        TallBuilding.gameObject:SetActive(isShowOutside)
    end

    -- 其他房间
    for id, room in pairs(RoomDic) do
        if id ~= baseRoomId then
            room.GameObject:SetActive(isShowOutside)
        end
    end
end

-- 显示构造体详情时 显示隐藏指定房间的外部景物
function XHomeDormManager.ShowOrHideBuilding(isShowOutside)
    -- 场景上高楼
    if not XTool.UObjIsNil(TallBuilding) then
        TallBuilding.gameObject:SetActive(isShowOutside)
    end
end

-- 设置选中家具
function XHomeDormManager.SetSelectedFurniture(selected)
    IsSelectedFurniture = selected
end

-- 检测当前是否选中家具
function XHomeDormManager.CheckSelectedFurniture()
    return IsSelectedFurniture
end

-- 设置点击家具回调
function XHomeDormManager.SetClickFurnitureCallback(cb)
    ClickFurnitureCallback = cb
end

-- 调用点击家具回调
function XHomeDormManager.FireClickFurnitureCallback(furniture)
    if ClickFurnitureCallback then
        ClickFurnitureCallback(furniture)
    end
end

-- 检测家具是否被阻挡
function XHomeDormManager.CheckRoomFurnitureBlock(roomId, furnitureId, x, y, width, height, type, rotate)
    local room = RoomDic[roomId]
    if room then
        return room:CheckFurnitureBlock(furnitureId, x, y, width, height, type, rotate)
    end

    return true, CS.UnityEngine.Vector3.zero
end

-- 检测家具碰撞
function XHomeDormManager.CheckRoomFurnitureCollider(furniture, roomId)
    local room = RoomDic[roomId]
    return room:CheckFurnituresCollider(furniture) or false
end

-- 获取本地坐标
function XHomeDormManager.GetLocalPosByGrid(x, y, type, rotate)
    if not XTool.UObjIsNil(HomeMapManager) then
        return HomeMapManager:GetLocalPosByGrid(x, y, type, rotate)
    end
end

-- 检测地图是否有阻挡
function XHomeDormManager.CheckMultiBlock(blockCfgId, x, y, width, height, type, rotate)
    if not XTool.UObjIsNil(HomeMapManager) then
        return HomeMapManager:CheckMultiBlock(blockCfgId, x, y, width, height, type, rotate)
    end
end

-- 世界坐标转地板格子坐标
function XHomeDormManager.WorldPosToGroundGridPos(worldPos, roomTransform)
    if XTool.UObjIsNil(HomeMapManager) then
        return CS.UnityEngine.Vector2.zero, 0
    end

    local localPos = roomTransform.worldToLocalMatrix:MultiplyPoint(worldPos)
    local gridPos = HomeMapManager:GetGridPosByLocal(localPos, CS.XHomePlatType.Ground, 0, 1, 1)

    return gridPos
end

-- 检测世界坐标是否在地图边界
function XHomeDormManager.WorldPosCheckIsInBound(worldPos, roomTransform)
    if XTool.UObjIsNil(HomeMapManager) then
        return false
    end

    local localPos = roomTransform.worldToLocalMatrix:MultiplyPoint(worldPos)
    local gridPos = HomeMapManager:GetGridPosByLocal(localPos, CS.XHomePlatType.Ground, 0)
    local valid = HomeMapManager:CheckIsInBound(CS.XHomePlatType.Ground, gridPos.x, gridPos.y, 0)
    return valid
end

-- 获取格子坐标
function XHomeDormManager.GetGridPosByWorldPos(worldPos, transform, width, height)
    if XTool.UObjIsNil(HomeMapManager) then
        return CS.UnityEngine.Vector3.zero, 0
    end

    local type, rotate
    local name = transform.name
    if name == "@Ground" then
        type = CS.XHomePlatType.Ground
        rotate = 0
    elseif name == "@Wall01" then
        type = CS.XHomePlatType.Wall
        rotate = 0
    elseif name == "@Wall02" then
        type = CS.XHomePlatType.Wall
        rotate = 1
    elseif name == "@Wall03" then
        type = CS.XHomePlatType.Wall
        rotate = 2
    elseif name == "@Wall04" then
        type = CS.XHomePlatType.Wall
        rotate = 3
    end

    local localPos = HomeMapManager.transform.worldToLocalMatrix:MultiplyPoint(worldPos)
    local gridPos = HomeMapManager:GetGridPosByLocal(localPos, type, rotate, width, height)

    return gridPos, rotate
end

-- 获取某个宿舍，某类型家具的数量
function XHomeDormManager.GetFurnitureNumsByRoomAndMinor(roomId, minorType)

    local room = RoomDic[roomId]
    if not room then
        return 0
    end

    local roomData = room:GetData()

    if minorType == FurnitureMiniorType.Ground then
        return 1
    elseif minorType == FurnitureMiniorType.Wall then
        return 1
    elseif minorType == FurnitureMiniorType.Ceiling then
        return 1
    end

    local furnitureList = roomData:GetFurnitureDic()
    local totalNum = 0
    for k, v in pairs(furnitureList) do
        local furnitureTemplate = XFurnitureConfigs.GetFurnitureTemplateById(v.ConfigId)
        local furnitureMinorType = XFurnitureConfigs.GetFurnitureTypeById(furnitureTemplate.TypeId)
        if minorType == furnitureMinorType.MinorType then
            totalNum = totalNum + 1
        end
    end
    return totalNum
end

-- 获取某个宿舍，某类型家具的容量
function XHomeDormManager.GetFurnitureCapacityByRoomANdMinor(roomId, minorType)
    local roomTemplate = XDormConfig.GetDormitoryCfgById(roomId)

    if minorType == FurnitureMiniorType.Ground or minorType == FurnitureMiniorType.Wall or minorType == FurnitureMiniorType.Ceiling then
        return 1
    elseif minorType == FurnitureMiniorType.BigFurniture then
        return roomTemplate.BigFurnitureCapacity or 0
    elseif minorType == FurnitureMiniorType.SmallFurniture then
        return roomTemplate.SmallFurnitureCapacity or 0
    elseif minorType == FurnitureMiniorType.DecorateFurniture then
        return roomTemplate.DecorateCapacity or 0
    elseif minorType == FurnitureMiniorType.PetFurniture then
        return roomTemplate.PetCapacity or 0
    else
        return 0
    end
end

function XHomeDormManager.GetFurnitureScoresByRoomData(roomData,dormDataType)
    local furnitureIdList = {}
    local totalScore = 0
    local attrList = {
        [1] = 0,
        [2] = 0,
        [3] = 0,
    }

    if not roomData then
        return totalScore, attrList
    end

    local furnitureList = roomData:GetFurnitureDic()
    for k, v in pairs(furnitureList) do
        table.insert(furnitureIdList, {
            furnitureId = v.Id
        })

    end
    local curdormDataType = XDormConfig.DormDataType.Target
    if not dormDataType then
        curdormDataType = XDormConfig.DormDataType.Self
    end
    for k, v in pairs(furnitureIdList) do
        totalScore = totalScore + XDataCenter.FurnitureManager.GetFurnitureScore(v.furnitureId,curdormDataType)
        attrList[1] = attrList[1] + XDataCenter.FurnitureManager.GetFurnitureRedScore(v.furnitureId,curdormDataType)
        attrList[2] = attrList[2] + XDataCenter.FurnitureManager.GetFurnitureYellowScore(v.furnitureId,curdormDataType)
        attrList[3] = attrList[3] + XDataCenter.FurnitureManager.GetFurnitureBlueScore(v.furnitureId,curdormDataType)
    end

    return {
        TotalScore = totalScore,
        AttrList = attrList
    }
end

function XHomeDormManager.GetFurnitureScoresByUnsaveRoom(roomId)
    local room = RoomDic[roomId]
    local totalScore = 0
    local attrList = {
        [1] = 0,
        [2] = 0,
        [3] = 0,
    }
    if not room then
        return {
            TotalScore = totalScore,
            AttrList = attrList
        }
    end

    local roomData = XDataCenter.DormManager.GetRoomDataByRoomId(roomId)

    return XHomeDormManager.GetFurnitureScoresByRoomData(roomData)
end

-- 获取
function XHomeDormManager.GetFurnitureScoresByRoomId(roomId)
    local room = RoomDic[roomId]
    local totalScore = 0
    local attrList = {
        [1] = 0,
        [2] = 0,
        [3] = 0,
    }
    if not room then
        return {
            TotalScore = totalScore,
            AttrList = attrList
        }
    end

    local roomData = room:GetData()

    return XHomeDormManager.GetFurnitureScoresByRoomData(roomData)
end

-- 获取宿舍内3D坐标 对应2D坐标
function XHomeDormManager.GetWorldToViewPoint(roomId, pos)
    local room = RoomDic[roomId]
    local camera = XHomeSceneManager.GetSceneCamera()

    if not room or not camera then
        XLog.Error("XHomeDormManager.GetWorldToViewPoint error room is null, id is " .. roomId)
        return CS.UnityEngine.Vector3.zero
    end

    local screenPos = camera:WorldToViewportPoint(pos)
    screenPos.x = screenPos.x * CsXUiManager.RealScreenWidth
    screenPos.y = screenPos.y * CsXUiManager.RealScreenHeight

    return screenPos
end

function XHomeDormManager.GetFurnitureFromList(id, furntiureList)
    if not furntiureList then
        return nil
    end
    for k, v in pairs(furntiureList) do
        if v.Id == id then
            return v
        end
    end
    return nil
end


-- 是否需要保存宿舍, 宿舍任何物品稍微有改动则需要提示玩家保存
function XHomeDormManager.IsNeedSave(roomId)
    local room = RoomDic[roomId]
    if not room then
        return false
    end

    local lastSaveData = XDataCenter.DormManager.GetRoomDataByRoomId(roomId)
    local currentData = room:GetData()

    -- 家具(数量不一致，或者位置、角度不一致，提示保存)
    local lastFurnitureList = lastSaveData:GetFurnitureDic()
    local currentFurnitureList = currentData:GetFurnitureDic()

    local lastFurnitureNum = XHomeDormManager.GetFurnitureNumsByDic(lastFurnitureList)
    local currentFurnitureNum = XHomeDormManager.GetFurnitureNumsByDic(currentFurnitureList)
    if lastFurnitureNum ~= currentFurnitureNum then
        return true
    end

    for k, v in pairs(lastFurnitureList) do
        local currentFurniture = currentFurnitureList[v.Id]
        if currentFurniture == nil then
            return true
        end
        -- 地板，天花板，墙
        if XDataCenter.FurnitureManager.IsFurnitureMatchType(v.Id, XFurnitureConfigs.HomeSurfaceBaseType.Ground) then
            if v.Id ~= room.Ground.Data.Id then
                return true
            end
        elseif XDataCenter.FurnitureManager.IsFurnitureMatchType(v.Id, XFurnitureConfigs.HomeSurfaceBaseType.Ceiling) then
            if v.Id ~= room.Ceiling.Data.Id then
                return true
            end
        elseif XDataCenter.FurnitureManager.IsFurnitureMatchType(v.Id, XFurnitureConfigs.HomeSurfaceBaseType.Wall) then
            if v.Id ~= room.Wall.Data.Id then
                return true
            end
        else
            if v.ConfigId ~= currentFurniture.ConfigId or v.GridX ~= currentFurniture.GridX or v.GridY ~= currentFurniture.GridY or v.RotateAngle ~= currentFurniture.RotateAngle then
                return true
            end
        end

    end

    return false
end

function XHomeDormManager.GetFurnitureNumsByDic(furnitureDic)
    local totalNum = 0
    if not furnitureDic then
        return totalNum
    end
    for k, v in pairs(furnitureDic) do
        totalNum = totalNum + 1
    end
    return totalNum
end

-- 获取单个房间
function XHomeDormManager.GetSingleDormByRoomId(roomId)
    local room = RoomDic[roomId]
    return room
end

function XHomeDormManager.DormistoryGetFarestWall(dormitoryId)
    local room = XHomeDormManager.GetSingleDormByRoomId(dormitoryId)
    local totalWallNums = 4
    local wallPositions = {}

    for i = 1, totalWallNums do
        wallPositions[i] = room.Transform:Find(string.format("HomeMapManager(Clone)/@WallRoot/@Wall0%d", i)).position
    end

    local camera = XHomeSceneManager.GetSceneCamera()
    if not camera then
        return 1
    end

    local cameraPosition = camera.transform.position
    local maxWallIndex = 1
    local maxWallDistance = 0

    for k, wallPos in pairs(wallPositions) do
        local distance = CS.UnityEngine.Vector3.Distance(cameraPosition, wallPos)
        if distance > maxWallDistance then
            maxWallIndex = k
            maxWallDistance = distance
        end
    end

    return maxWallIndex
end

-- 是否在宿舍场景里
function XHomeDormManager.InDormScene()
    return InDormitoryScene
end

-- 是否在宿舍某个房间里
function XHomeDormManager.InAnyRoom()
    return CurSelectedRoom ~= nil and CurSelectedRoom.IsSelected
end

-- 获取当前在宿舍某个房间的id
function XHomeDormManager.GetCurrentRoomId()
    if CurSelectedRoom and CurSelectedRoom.IsSelected then
        return CurSelectedRoom.Data.Id
    end
    return nil
end

-- 是否在宿舍某个房间里(房间id为roomId)
function XHomeDormManager.IsInRoom(roomId)
    if CurSelectedRoom == nil then return false end
    if roomId and CurSelectedRoom.Data and CurSelectedRoom.Data.Id == roomId then
        return CurSelectedRoom.IsSelected
    end
    return false
end