---
--- 宿舍房间对象
---
local XSceneObject = require("XHome/XSceneObject")

local XHomeRoomObj = XClass(XSceneObject)

local XHomeFurnitureObj = require("XHome/XDorm/XHomeFurnitureObj")
local XHomeCharObj = require("XHome/XDorm/XHomeCharObj")
local ROOM_DEFAULT_SO_PATH = CS.XGame.ClientConfig:GetString("RoomDefaultSoPath")
local DormManager
local DisplaySetType
local WallNum = 4
local ROOM_FAR_CLIP_PLANE = 25

local Bounds = CS.UnityEngine.Bounds

function XHomeRoomObj:Ctor(data, facadeGo)
    DormManager = XDataCenter.DormManager
    DisplaySetType = XDormConfig.VisitDisplaySetType

    self.Data = data

    if not XTool.UObjIsNil(facadeGo) then
        self.FacadeGo = CS.UnityEngine.GameObject.Instantiate(facadeGo)
        if not XTool.UObjIsNil(self.FacadeGo) then
            self.RoomUnlockGo = self.FacadeGo:Find("@Unlock").gameObject
            self.RoomLockGo = self.FacadeGo:Find("@Lock").gameObject
        end
    end

    self.IsSelected = false
    self.IsCanSave = true

    self.SurfaceRoot = nil
    self.CharacterRoot = nil
    self.FurnitureRoot = nil

    self.Ground = nil
    self.Wall = nil
    self.Ceiling = nil

    self.WallFurnitureList = {}
    self.GroundFurnitureList ={}
    self.WallDithers = {}
    self.CharacterList = {}
end

function XHomeRoomObj:Dispose()
    self:RemoveLastWallEffectDither(self.Wall)
    XHomeRoomObj.Super.Dispose(self)

    if not XTool.UObjIsNil(self.GoInputHandler) then
        self.GoInputHandler:RemoveAllListeners()
    end
    self.GoInputHandler = nil
    self.RoomMap = nil
    self.InteractList = nil
end

function XHomeRoomObj:OnLoadComplete(loadtype)
    if not XTool.UObjIsNil(self.FacadeGo) then
        self.FacadeGo:SetParent(self.Transform, false)
        self.FacadeGo.localPosition = CS.UnityEngine.Vector3.zero
        self.FacadeGo.localEulerAngles = CS.UnityEngine.Vector3.zero
        self.FacadeGo.localScale = CS.UnityEngine.Vector3.one
    end

    self.SurfaceRoot = self.Transform:Find("@Surface")
    self.CharacterRoot = self.Transform:Find("@Character")
    self.FurnitureRoot = self.Transform:Find("@Furniture")

    self.SurfaceRoot.gameObject:SetActive(false)
    self.FurnitureRoot.gameObject:SetActive(false)
    self.CharacterRoot.gameObject:SetActive(false)

    self.GoInputHandler = self.Transform:GetComponent(typeof(CS.XGoInputHandler))
    if not XTool.UObjIsNil(self.GoInputHandler) then
        self.GoInputHandler:AddPointerClickListener(function(eventData) self:OnClick() end)
    end


    self:SetData(self.Data,loadtype)
end

--显示属性标签
function XHomeRoomObj:OnShowFurnitureAttr(evt,args)


    local room = XHomeDormManager.GetRoom(self.Data.Id)

    if room  and XHomeDormManager.IsInRoom(self.Data.Id) then
        for k,v in pairs(room.GroundFurnitureList) do
            v:ShowAttrTag(args[0])
        end

        for k,v in pairs(room.WallFurnitureList) do

            for _, furniture in pairs(v) do
                furniture:ShowAttrTag(args[0])
            end
        end
    end
end

--隐藏属性标签
function XHomeRoomObj:OnHideFurnitureAttr(...)

    if self.GroundFurnitureList then
        for k,v in pairs(self.GroundFurnitureList) do
            v:HideAttrTag()
        end
    end
end

-- 设置房间数据
function XHomeRoomObj:SetData(data,loadtype)
    self.Data = data
    self.CurLoadType = loadtype

    local isUnlock = self.Data:WhetherRoomUnlock()
    if not XTool.UObjIsNil(self.RoomLockGo) then
        self.RoomLockGo:SetActive(not isUnlock)
    end
    if not XTool.UObjIsNil(self.RoomUnlockGo) then
        self.RoomUnlockGo:SetActive(isUnlock)
    end

    self:CleanRoom()
    self:CleanCharacter()
    self:LoadFurniture()
    self:LoadCharacter()

    self:GenerateRoomMap()
end

-- 获取房间数据
function XHomeRoomObj:GetData()
    local roomData = XHomeRoomData.New(self.Data.Id)

    roomData:SetPlayerId(self.Data:GetPlayerId())
    roomData:SetRoomUnlock(self.Data:WhetherRoomUnlock())

    if self.Wall then
        roomData:AddFurniture(self.Wall.Data.Id, self.Wall.Data.CfgId)
    end

    if self.Ground then
        roomData:AddFurniture(self.Ground.Data.Id, self.Ground.Data.CfgId)
    end

    if self.Ceiling then
        roomData:AddFurniture(self.Ceiling.Data.Id, self.Ceiling.Data.CfgId)
    end

    for _, furniture in pairs(self.GroundFurnitureList) do
        local x, y, rotate = furniture:GetData()
        roomData:AddFurniture(furniture.Data.Id, furniture.Data.CfgId, x, y, rotate)
    end

    for _, v in pairs(self.WallFurnitureList) do
        for _, furniture in pairs(v) do
            local x, y, rotate = furniture:GetData()
            roomData:AddFurniture(furniture.Data.Id, furniture.Data.CfgId, x, y, rotate)
        end
    end

    return roomData
end

-- 设置房间光照信息
function XHomeRoomObj:SetIllumination()
    if not self.Ceiling then
        return
    end

    if not self.Ceiling.Cfg then
        return
    end

    local soPath = self.Ceiling.Cfg.IlluminationSO
    if not self.Ceiling.Cfg.IlluminationSO or string.len(self.Ceiling.Cfg.IlluminationSO) <= 0 then
        soPath = ROOM_DEFAULT_SO_PATH
    end
    XHomeSceneManager.SetGlobalIllumSO(soPath)
end

-- 重置房间摆设,增加参数，重置完再刷数据
function XHomeRoomObj:RevertRoom()
    self:CleanRoom()
    self:LoadFurniture()
    self:SetIllumination()
    self:GenerateRoomMap()
end

-- 收起房间家具，增加参数，收起完再刷数据，如果有构造体需要回收利用。
function XHomeRoomObj:CleanRoom()
    self:CleanGroudFurinture()
    self:CleanWallFurniture()
    CsXGameEventManager.Instance:Notify(XEventId.EVENT_FURNITURE_CLEANROOM)
end


function XHomeRoomObj:CleanWallFurniture()
    if self.WallFurnitureList then
        for _, v in pairs(self.WallFurnitureList) do
            for i, furniture in pairs(v) do
                furniture:Storage(false)
            end
        end
    end
    self.WallFurnitureList = {}
end

function XHomeRoomObj:CleanGroudFurinture()
    if self.GroundFurnitureList then
        for _, furniture in pairs(self.GroundFurnitureList) do
            furniture:Storage(false)
        end
    end
    self.GroundFurnitureList ={}
end

function XHomeRoomObj:CleanCharacter()
    self:SetCharacterExit()
end

-- 加载家具
function XHomeRoomObj:LoadFurniture()

    self:RemoveWallDither()
    local furnitureList = self.Data:GetFurnitureDic()
    for i, data in pairs(furnitureList) do
        local furnitureCfg = XFurnitureConfigs.GetFurnitureTemplateById(data.ConfigId)
        if furnitureCfg then

            local furnitureData = XDataCenter.FurnitureManager.GetFurnitureById(data.Id,self.CurLoadType)
            local furniture = XHomeDormManager.CreateFurniture(self.Data.Id, furnitureData, { x = data.GridX, y = data.GridY }, data.RotateAngle)

            if furniture then
                if furniture.PlaceType == XFurniturePlaceType.Wall then
                    --墙体
                    self:UpdateWallDither(self.Wall, furniture)
                    if self.Wall then
                        self.Wall:Storage()
                    end
                    self.Wall = furniture
                elseif furniture.PlaceType == XFurniturePlaceType.Ground then
                    --地板
                    if self.Ground then
                        self.Ground:Storage()
                    end
                    self.Ground = furniture
                elseif furniture.PlaceType == XFurniturePlaceType.Ceiling then
                    --天花板
                    if self.Ceiling then
                        self.Ceiling:Storage()
                    end
                    self.Ceiling = furniture
                elseif furniture.PlaceType == XFurniturePlaceType.OnWall then
                    --墙上家具
                    local dic = self.WallFurnitureList[tostring(data.RotateAngle)]
                    if not dic then
                        dic = {}
                        self.WallFurnitureList[tostring(data.RotateAngle)] = dic
                    end
                    dic[furniture.Data.Id] = furniture
                else
                    --地上家具
                    self.GroundFurnitureList[furniture.Data.Id] = furniture
                end
                CsXGameEventManager.Instance:Notify(XEventId.EVENT_FURNITURE_ONDRAGITEM_CHANGED, false, furniture.Data.Id)
            end
        end
    end

    self:UpdateWallListRender()
end


--获取所有家具
function XHomeRoomObj:GetAllFurnitureCongfig()
    local configs = {}
    --天花板
    if self.Ceiling and self.Ceiling.Cfg then
        table.insert(configs,self.Ceiling.Cfg)
    end

    --地板
    if self.Ground and self.Ground.Cfg then
        table.insert(configs,self.Ground.Cfg)
    end

    --墙
    if self.Wall and self.Wall.Cfg then
        table.insert(configs,self.Wall.Cfg)
    end

    --地上家具
    for k,v in pairs(self.GroundFurnitureList) do
        table.insert(configs,v.Cfg)
    end

    --挂饰
    for k,v in pairs(self.WallFurnitureList) do
        for _, furniture in pairs(v) do
            table.insert(configs,furniture.Cfg)
        end
    end

    return configs
end

-- 设置家具交互点Go
function XHomeRoomObj:SetInteractInfoGo()
    for _, v in pairs(self.GroundFurnitureList)do
        if v then
            v:SetInteractInfoGo()
        end
    end
end

-- 隐藏家具交互点Go
function XHomeRoomObj:HideInteractInfoGo()
    for _, v in pairs(self.GroundFurnitureList)do
        if v then
            v:HideInteractInfoGo()
        end
    end
end

-- 加载构造体
function XHomeRoomObj:LoadCharacter()
    local characterList = self.Data:GetCharacter()

    for i, data in ipairs(characterList) do
        XHomeCharManager.PreLoadHomeCharacterById(data.CharacterId)
    end
end

-- 更换基础装修
function XHomeRoomObj:ReplaceSurface(furniture)
    if furniture.PlaceType == XFurniturePlaceType.Wall then
        self:RemoveWallDither()
        if self.Wall then
            self.Wall:Storage()
        end
        self:UpdateWallDither(self.Wall, furniture)
        self.Wall = furniture

        for _, v in pairs(self.WallFurnitureList) do
            for _, data in pairs(v) do
                local cfg =  XFurnitureConfigs.GetFurnitureTemplateById(data.Data.CfgId)
                if cfg then
                    local homePlatType = XFurnitureConfigs.LocateTypeToXHomePlatType(cfg.LocateType)
                    if homePlatType == nil then
                        return
                    end

                    local platCfgId = 0
                    local plat = XDataCenter.DormManager.GetRoomPlatId(self.Data.Id, homePlatType)
                    if plat ~= nil then
                        platCfgId = plat.ConfigId
                    end

                    -- 检测是否有家具阻挡
                    local x, y, rot = data:GetData()
                    if self:CheckFurnitureBlock(data.Data.Id, x, y, cfg.Width, cfg.Height, homePlatType, rot) then
                        self.IsCanSave = false
                        break
                    end
                end
            end
        end

        self:UpdateWallListRender()

    elseif furniture.PlaceType == XFurniturePlaceType.Ground then
        if self.Ground then
            self.Ground:Storage()
        end
        self.Ground = furniture
        for _, data in pairs(self.GroundFurnitureList) do
            local cfg =  XFurnitureConfigs.GetFurnitureTemplateById(data.Data.CfgId)
            if cfg then
                local homePlatType = XFurnitureConfigs.LocateTypeToXHomePlatType(cfg.LocateType)
                if homePlatType == nil then
                    return
                end

                local platCfgId = 0
                local plat = XDataCenter.DormManager.GetRoomPlatId(self.Data.Id, homePlatType)
                if plat ~= nil then
                    platCfgId = plat.ConfigId
                end

                -- 检测是否有家具阻挡
                local x, y, rot = data:GetData()
                if self:CheckFurnitureBlock(data.Data.Id, x, y, cfg.Width, cfg.Height, homePlatType, rot) then
                    self.IsCanSave = false
                    break
                end
            end
        end
    elseif furniture.PlaceType == XFurniturePlaceType.Ceiling then
        if self.Ceiling then
            self.Ceiling:Storage()
        end
        self.Ceiling = furniture
        self:SetIllumination()
    end

    CsXGameEventManager.Instance:Notify(XEventId.EVENT_FURNITURE_ONDRAGITEM_CHANGED, false, furniture.Data.Id)
end

-- 添加家具
function XHomeRoomObj:AddFurniture(furniture)
    local old
    if furniture.PlaceType == XFurniturePlaceType.OnGround then
        old = self.GroundFurnitureList[furniture.Data.Id]
        if not old then
            self.GroundFurnitureList[furniture.Data.Id] = furniture
        end
    elseif furniture.PlaceType == XFurniturePlaceType.OnWall then
        for _, v in pairs(self.WallFurnitureList) do
            old = v[furniture.Data.Id]
            if old then
                local x, y, rot = old:GetData()
                self.WallDithers[tostring(rot)]:AddRenderer(furniture.GameObject)
                self.WallDithers[tostring(rot)]:AddStateChangeListener(furniture.GameObject,handler(furniture,furniture.OnStateChange))
                break
            end
        end

        if not old then
            local x, y, rot = furniture:GetData()
            local temp = self.WallFurnitureList[tostring(rot)]
            if not temp then
                temp = {}
                self.WallFurnitureList[tostring(rot)] = temp
            end

            temp[furniture.Data.Id] = furniture
            self.WallDithers[tostring(rot)]:AddRenderer(furniture.GameObject)
            self.WallDithers[tostring(rot)]:AddStateChangeListener(furniture.GameObject,handler(furniture,furniture.OnStateChange))
        end
    end
end

-- 移除家具
function XHomeRoomObj:RemoveFurniture(furniture)
    if furniture.PlaceType == XFurniturePlaceType.OnGround then
        self.GroundFurnitureList[furniture.Data.Id] = nil
    elseif furniture.PlaceType == XFurniturePlaceType.OnWall then
        local x, y, rot = furniture:GetData()
        local temp = self.WallFurnitureList[tostring(rot)]
        if temp then
            if temp[furniture.Data.Id] then
                self.WallDithers[tostring(rot)]:RemoveRenderer(temp[furniture.Data.Id].GameObject)
                self.WallDithers[tostring(rot)]:RemoveStateChangeListener(temp[furniture.Data.Id].GameObject)

            end
            temp[furniture.Data.Id] = nil
        end
    end
end

-- 选中房间
function XHomeRoomObj:SetSelected(isSelected, shouldProcessOutside, onFinishEnterRoom)
    self.IsSelected = isSelected
    if isSelected then
        self.GameObject:SetActive(true)
    end
    local cb = function()
        if XTool.UObjIsNil(self.GameObject) then
            return
        end

        self.SurfaceRoot.gameObject:SetActive(isSelected)
        self.FurnitureRoot.gameObject:SetActive(isSelected)
        self.CharacterRoot.gameObject:SetActive(isSelected)

        if not XTool.UObjIsNil(self.FacadeGo) then
            self.FacadeGo.gameObject:SetActive(not isSelected)
        end

        if shouldProcessOutside then
            XHomeDormManager.ShowOrHideOutsideRoom(self.Data.Id, not isSelected)
        end

        if onFinishEnterRoom then
            onFinishEnterRoom()
        end
    end

    if isSelected then
        self:SetIllumination()
        self:SetCharacterBorn()
        local func = function()
            cb()
            XHomeSceneManager.ChangeView(HomeSceneViewType.RoomView)
        end

        XLuaUiManager.Open("UiBlackScreen", self.Transform, "Room", func)
        local camera = XHomeSceneManager.GetSceneCamera()
        if not XTool.UObjIsNil(camera) then
            camera.farClipPlane = ROOM_FAR_CLIP_PLANE
        end
        XEventManager.DispatchEvent(XEventId.EVENT_DORM_ROOM, self.Data.Id)
        CsXGameEventManager.Instance:RegisterEvent(XEventId.EVENT_DORM_FURNITURE_ATTR_TAG,handler(self,self.OnShowFurnitureAttr))

    else
        CS.XScheduleManager.ScheduleOnce(function()
            cb()
        end, 150)
        self:SetCharacterExit()

        CsXGameEventManager.Instance:RemoveEvent(XEventId.EVENT_DORM_FURNITURE_ATTR_TAG, handler(self,self.OnShowFurnitureAttr))

        self:OnHideFurnitureAttr()
    end
end

--进入房间角色出生
function XHomeRoomObj:SetCharacterBorn()
    local characterList = self.Data:GetCharacter()
    if characterList == nil then
        return
    end

    for i, data in ipairs(characterList) do
        if data and data.CharacterId then
            if (not self.Data:IsSelfData()) or (not XDataCenter.DormManager.IsWorking(data.CharacterId)) then
                local charObj = XHomeCharManager.SpawnHomeCharacter(data.CharacterId, self.CharacterRoot)
                charObj:SetData(data,self.Data:IsSelfData())
                charObj:Born(self.RoomMap, self)
                table.insert(self.CharacterList, charObj)
            end
        end
    end
end

--退出房间
function XHomeRoomObj:SetCharacterExit()
    if self.CharacterList == nil then
        return
    end

    for k, v in ipairs(self.CharacterList) do
        v:ExitRoom()
    end
end

--添加构造体
function XHomeRoomObj:AddCharacter(dormtoryId, characterId)
    if dormtoryId ~= self.Data.Id then
        return
    end

    local data = self.Data:GetCharacterById(characterId)
    if (not self.Data:IsSelfData()) or (not XDataCenter.DormManager.IsWorking(data.CharacterId)) then
        local charObj = XHomeCharManager.SpawnHomeCharacter(characterId, self.CharacterRoot)
        charObj:SetData(data,self.Data:IsSelfData())

        if self.IsSelected then
            table.insert(self.CharacterList, charObj)
            charObj:Born(self.RoomMap, self)
        end
    end
end

--移除构造体
function XHomeRoomObj:RemoveCharacter(dormtoryId, characterId)
    if dormtoryId ~= self.Data.Id then
        return
    end

    if not self.IsSelected then
        return
    end

    local charObj = nil
    local index = -1
    for k, v in ipairs(self.CharacterList) do

        if v.Id == characterId then
            charObj = v
            index = k
            break
        end
    end

    if not charObj then
        return
    end


    charObj:ExitRoom()
    table.remove(self.CharacterList, index)
end


-- 点击房间
function XHomeRoomObj:OnClick()
    if not self.Data:WhetherRoomUnlock() then
        --未解锁，先激活
        local cfg = XDormConfig.GetDormitoryCfgById(self.Data.Id)
        local name = XDataCenter.ItemManager.GetItemName(cfg.ConsumeItemId)
        local title = CS.XTextManager.GetText("TipTitle")
        local count = cfg.ConsumeItemCount
        local des = CS.XTextManager.GetText("DormActiveTips", count, name)
        XUiManager.DialogTip(title, des, XUiManager.DialogType.Normal, nil, function() DormManager.RequestDormitoryActive(self.Data.Id) end)
        return
    end

    -- 已激活，进入房间
    if XLuaUiManager.IsUiShow("UiDormSecond") then
        return
    end
    XLuaUiManager.Open("UiDormSecond", DisplaySetType.MySelf, self.Data.Id)
    XHomeDormManager.SetSelectedRoom(self.Data.Id, true)

end

-- 生成地图信息及家具交互点信息
function XHomeRoomObj:GenerateRoomMap()
    if not self.Ground then
        return
    end

    --房间动态地图信息
    self.RoomMap = CS.XRoomMapInfo.GenerateMap(self.Ground.Data.CfgId)
    if self.GroundFurnitureList then
        for _, furniture in pairs(self.GroundFurnitureList) do
            if furniture.Cfg then
                local x, y, rotate = furniture:GetData()
                -- 家具
                self.RoomMap:SetFurnitureInfo(x, y, furniture.Cfg.Width, furniture.Cfg.Height, rotate)
                -- 交互点
                local posList = XFurnitureConfigs.GetFurnitureInteractPosList(furniture.Cfg.InteractPos)
                for _, pos in ipairs(posList) do
                    self.RoomMap:SetFurnitureInteractionInfo(x, y, furniture.Cfg.Width, furniture.Cfg.Height, pos.x, pos.y, rotate)
                end
            end
        end
    end

    --有效交互点列表
    self.InteractList = {}
    if self.GroundFurnitureList then
        for _, furniture in pairs(self.GroundFurnitureList) do
            if furniture.Cfg then
                local list = furniture:GenerateInteractInfo(self.RoomMap)
                for _, info in ipairs(list) do
                    if (info.UsedType & XFurnitureInteractUsedType.Block) <= 0 then
                        local interactInfo = {}
                        interactInfo.GridPos = info.GridPos
                        interactInfo.StayPosGo = info.StayPos
                        interactInfo.InteractPosGo = info.InteractPos
                        interactInfo.Furniture = furniture
                        table.insert(self.InteractList, interactInfo)
                    end
                end
            end
        end
    end
end

-- 检测家具阻挡
function XHomeRoomObj:CheckFurnitureBlock(furnitureId, x, y, width, height, type, rotate)
    local isBlock = false

    for _, furniture in pairs(self.GroundFurnitureList) do
        if furnitureId ~= furniture.Data.Id and furniture:CheckCanLocate() and furniture:CheckFurnitureCollision(x, y, width, height, type, rotate) then
            isBlock = true
            break
        end
    end

    if not isBlock then
        for _, v in pairs(self.WallFurnitureList) do
            for _, furniture in pairs(v) do
                if furnitureId ~= furniture.Data.Id and furniture:CheckCanLocate() and furniture:CheckFurnitureCollision(x, y, width, height, type, rotate) then
                    isBlock = true
                    break
                end
            end

            if isBlock then
                break
            end
        end
    end

    local blockCfgId = 0
    if type == CS.XHomePlatType.Ground and self.Ground then
        blockCfgId = self.Ground.Data.CfgId
    elseif type == CS.XHomePlatType.Wall and self.Wall then
        blockCfgId = self.Wall.Data.CfgId
    end

    local block, pos = XHomeDormManager.CheckMultiBlock(blockCfgId, x, y, width, height, type, rotate)
    if not isBlock then
        isBlock = block
    end

    return isBlock, pos
end

-- 移除所有墙饰的dither
function XHomeRoomObj:RemoveWallDither()
    if self.Wall and self.WallDithers then
        for rotate, v in pairs(self.WallFurnitureList) do
            local wallDitherIndex = tostring(rotate)
            for _, furniture in pairs(v) do
                if self.WallDithers[wallDitherIndex] then
                    self.WallDithers[wallDitherIndex]:RemoveRenderer(furniture.GameObject)
                    self.WallDithers[wallDitherIndex]:RemoveStateChangeListener(furniture.GameObject)
                end
            end
        end
    end
end

-- 更新dither
function XHomeRoomObj:UpdateWallDither(lastWall, curWall)

    self:RemoveLastWallEffectDither(lastWall)
    if curWall then
        for i=1, WallNum do
            local ditherKey = tostring(i - 1)
            self.WallDithers[ditherKey] = curWall.Transform:Find(ditherKey):GetComponent(typeof(CS.XRoomWallDither))

            local wallEffects = curWall:GetWallEffectsByRot(ditherKey)
            if wallEffects then
                for j=1, #wallEffects do
                    local wallEffectObj = wallEffects[j].gameObject
                    if not XTool.UObjIsNil(wallEffectObj) then
                        self.WallDithers[ditherKey]:AddStateChangeListener(wallEffectObj, function(state)
                            self:OnWallEffectDitherChange(state, wallEffectObj)
                        end)
                    end
                end
            end
        end
    end
end

function XHomeRoomObj:RemoveLastWallEffectDither(wall)
    if not wall then return end
    for i=1, WallNum do
        local ditherKey = tostring(i - 1)

        if self.WallDithers[ditherKey] then
            local wallEffects = wall:GetWallEffectsByRot(ditherKey)
            if wallEffects then
                for j=1, #wallEffects do
                    local wallEffectObj = wallEffects[j].gameObject
                    if not XTool.UObjIsNil(wallEffectObj) then
                        self.WallDithers[ditherKey]:RemoveStateChangeListener(wallEffectObj)
                    end
                end
            end
        end
    end
end

-- 墙特效
function XHomeRoomObj:OnWallEffectDitherChange(state, effectObj)
    if state == "Enter" then
        effectObj:SetActiveEx(true)
    else
        effectObj:SetActiveEx(false)
    end
end

-- 给所有墙饰添加render,换墙操作
function XHomeRoomObj:UpdateWallListRender()

    if self.WallFurnitureList then
        for rotate, v in pairs(self.WallFurnitureList) do
            local wallDitherIndex = tostring(rotate)
            for _, furniture in pairs(v) do
                if self.WallDithers[wallDitherIndex] then
                    self.WallDithers[wallDitherIndex]:AddStateChangeListener(furniture.GameObject,handler(furniture,furniture.OnStateChange))
                    self.WallDithers[wallDitherIndex]:AddRenderer(furniture.GameObject)
                end
            end
        end
    end

end

-- 家具碰撞检测
function XHomeRoomObj:CheckFurnituresCollider(checkFurniture)
    if not checkFurniture then
        return false
    end

    for _, collider in pairs(checkFurniture.Colliders) do
        if not XTool.UObjIsNil(collider) then
            for _, furniture in pairs(self.GroundFurnitureList or {}) do
                if furniture ~= checkFurniture then
                    for _, furnitureCollider in pairs(furniture.Colliders or {}) do
                        if collider ~= furnitureCollider and collider.bounds:Intersects(furnitureCollider.bounds) then
                            return true
                        end
                    end
                end
            end

            for _, furnitureList in pairs(self.WallFurnitureList or {}) do
                for _, furniture in pairs(furnitureList) do
                    if furniture ~= checkFurniture then
                        for _, furnitureCollider in pairs(furniture.Colliders or {}) do
                            if collider ~= furnitureCollider and collider.bounds:Intersects(furnitureCollider.bounds)  then
                                return true
                            end
                        end
                    end
                end
            end

            if self.Ceiling then
                if checkFurniture ~= self.Ceiling then
                    for _, furnitureCollider in pairs(self.Ceiling.Colliders or {}) do
                        if collider ~= furnitureCollider and collider.bounds:Intersects(furnitureCollider.bounds) then
                            return true
                        end
                    end
                end
            end
        end
    end

    return false
end

function XHomeRoomObj:CheckColliderIntersectByBounds(colliderSrc, colliderDsc)
    local boundSrc = Bounds(colliderSrc.center + colliderSrc.transform.position, colliderSrc.size)
    local boundDsc = Bounds(colliderDsc.center + colliderDsc.transform.position, colliderDsc.size)
    return boundSrc:Intersects(boundDsc)
end

return XHomeRoomObj