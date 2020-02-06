---
--- 宿舍家具对象
---
local TEST_FURNITURE_NAME = "Furniture003"  --Test
local XSceneObject = require("XHome/XSceneObject")

local XHomeFurnitureObj = XClass(XSceneObject)
local Vector3 = CS.UnityEngine.Vector3
local V3O = Vector3.one
local V3Z = Vector3.zero
local WallNum = 4

function XHomeFurnitureObj:Ctor(data, room)
    self.Data = data
    self.Room = room
    self.ConfirmGridX = self.Data.GridX
    self.ConfirmGridY = self.Data.GridY
    self.ConfirmRotate = self.Data.RotateAngle
    self.CfgId = self.Data.CfgId
    self.GridOffset = CS.XGame.ClientConfig:GetFloat("DormGroundGridMeshHighOffset")

    self.OnWallFixGridPos = {}
    self.OnWallFixGridPos[0] = Vector3(0, 0.5 * XHomeDormManager.GetMapTall() * XHomeDormManager.GetCeilSize(), 0.5 * XHomeDormManager.GetMapHeight() * XHomeDormManager.GetCeilSize() - self.GridOffset)
    self.OnWallFixGridPos[1] = Vector3(0.5 * XHomeDormManager.GetMapWidth() * XHomeDormManager.GetCeilSize() - self.GridOffset, 0.5 * XHomeDormManager.GetMapTall() * XHomeDormManager.GetCeilSize(), 0)
    self.OnWallFixGridPos[2] = Vector3(0, 0.5 * XHomeDormManager.GetMapTall() * XHomeDormManager.GetCeilSize(), -0.5 * XHomeDormManager.GetMapHeight() * XHomeDormManager.GetCeilSize() + self.GridOffset)
    self.OnWallFixGridPos[3] = Vector3(-0.5 * XHomeDormManager.GetMapWidth() * XHomeDormManager.GetCeilSize() + self.GridOffset, 0.5 * XHomeDormManager.GetMapTall() * XHomeDormManager.GetCeilSize(), 0)

    self.InteractInfoList = {}
    self.InterGos = {}
    self.Cfg = XFurnitureConfigs.GetFurnitureTemplateById(self.Data.CfgId)
    if self.Cfg then
        self.PlaceType = XFurnitureConfigs.GetFurniturePlaceType(self.Cfg.TypeId)
    end

    self.HomePlatType = nil
    if self.PlaceType == XFurniturePlaceType.OnGround then
        self.HomePlatType = XFurnitureConfigs.HomePlatType.Ground
    elseif self.PlaceType == XFurniturePlaceType.OnWall then
        self.HomePlatType = XFurnitureConfigs.HomePlatType.Wall
    end
    self:SetPos(self.ConfirmGridX, self.ConfirmGridY, self.ConfirmRotate)

    self.IsSelected = false
    self.IsMapBlock = false
    self.IsFurnitureBlock = false
    self.IsColliderBlock = false

    self.IsShowGlow = false
    self.IsAddDragComponent = false
    self.AninationIndex = 0
end

function XHomeFurnitureObj:Dispose()
    XHomeFurnitureObj.Super.Dispose(self)

    self:HideAttrTag()


    if not XTool.UObjIsNil(self.GridComponent) then
        CS.XGridManager.Instance:FreeGrid(self.GridComponent)
    end
    self.GridComponent = nil

    if not XTool.UObjIsNil(self.GoInputHandler) then
        self.GoInputHandler:RemoveAllListeners()
    end
    self.GoInputHandler = nil

    if self.NavMeshSurface and self.NavMeshSurface:Exist() then
        self.NavMeshSurface:RemoveData()
    end

end

function XHomeFurnitureObj:GetWallEffectsByRot(rot)
    return self.WallEffects and self.WallEffects[rot] or nil
end

function XHomeFurnitureObj:GetFurntiureEffect()
    return self.EffectComp
end

function XHomeFurnitureObj:OnLoadComplete()
    self.Colliders = {}
    local list = self.GameObject:GetComponentsInChildren(typeof(CS.UnityEngine.Collider))
    for i = 0, list.Length - 1 do
        table.insert(self.Colliders, list[i])
    end

    self.Effect = self.Transform:Find("Effect")
    if not XTool.UObjIsNil(self.Effect) then
        self.EffectComp = self.Effect:GetComponent(typeof(CS.XPrefabLoader))
    end

    self.WallEffects = {}
    for i=1, WallNum do
        local wallIndex = tostring(i - 1)
        local wallEffect = self.Transform:Find(string.format("WallEffect%s", wallIndex))
        if wallEffect then
            self.WallEffects[wallIndex] = {}

            local effectIndex = 1
            local subEffect = self.Transform:Find(string.format("WallEffect%s/Effect%d", wallIndex, effectIndex))
            if not XTool.UObjIsNil(subEffect) then
                self.SubEffectComp = subEffect:GetComponent(typeof(CS.XPrefabLoader))
            end
            while (self.SubEffectComp)
            do
                table.insert( self.WallEffects[wallIndex], effectIndex, self.SubEffectComp)
                effectIndex = effectIndex + 1
                subEffect = self.Transform:Find(string.format("WallEffect%s/Effect%d", wallIndex, effectIndex))
                if not XTool.UObjIsNil(subEffect) then
                    self.SubEffectComp = subEffect:GetComponent(typeof(CS.XPrefabLoader))
                else
                    self.SubEffectComp = nil
                end
            end
        end
    end
    
    if self.PlaceType == XFurniturePlaceType.Ceiling then
        self.GameObject:SetLayerRecursively(CS.UnityEngine.LayerMask.NameToLayer(HomeSceneLayerMask.Block))
    else
        self.GameObject:SetLayerRecursively(CS.UnityEngine.LayerMask.NameToLayer(HomeSceneLayerMask.Device))
    end

    self.GoInputHandler = self.Transform:GetComponent(typeof(CS.XGoInputHandler))
    if not XTool.UObjIsNil(self.GoInputHandler) then
        self.GoInputHandler:AddPointerClickListener(function(eventData)
            self:OnClick()
        end)
    end

    self:SetData(self.Data)

    if self.PlaceType == XFurniturePlaceType.Ground then
        self.NavMeshSurface = CS.XNavMeshUtility.SetNavMeshSurfaceAndBuild(self.GameObject) --self.GameObject:AddComponent(typeof(CS.UnityEngine.AI.NavMeshSurface))
    elseif self.PlaceType ~= XFurniturePlaceType.Wall then
        self.NavMeshObstacle = CS.XNavMeshUtility.AddNavMeshObstacle(self.GameObject)
    end

    self.Animator = self.GameObject:GetComponent(typeof(CS.UnityEngine.Animator))

    if XTool.UObjIsNil(self.Animator) then
        self.Animator = self.GameObject:AddComponent(typeof(CS.UnityEngine.Animator))
    end
end

function XHomeFurnitureObj:SetData(data)
    self.Data = data
    self.ConfirmGridX = self.Data.GridX
    self.ConfirmGridY = self.Data.GridY
    self.ConfirmRotate = self.Data.RotateAngle

    self:SetPos(self.ConfirmGridX, self.ConfirmGridY, self.ConfirmRotate)
end

function XHomeFurnitureObj:GetData()
    return self.ConfirmGridX, self.ConfirmGridY, self.ConfirmRotate
end

function XHomeFurnitureObj:GetXHomePlatType()
    if self.Cfg == nil then
        return
    end

    if self.Cfg.LocateType ~= XFurnitureConfigs.HomeLocateType.Replace then
        if self.Cfg.Model == TEST_FURNITURE_NAME then
            -- Test
            local scale = self.Transform.localScale
            self.Transform.localScale = Vector3(self.Cfg.Width, scale.y, self.Cfg.Height)
        end
    end

    return XFurnitureConfigs.LocateTypeToXHomePlatType(self.Cfg.LocateType)
end

function XHomeFurnitureObj:GetSize()
    if self.Cfg == nil then
        return 0, 0
    end

    return self.Cfg.Width, self.Cfg.Height
end

-- 检测是否可在该位置摆放
function XHomeFurnitureObj:CheckCanLocate()
    return not self.IsMapBlock and not self.IsFurnitureBlock and not self.IsColliderBlock
end

-- 设置家具位置
function XHomeFurnitureObj:SetPos(x, y, rotate)
    self.GridX = x
    self.GridY = y
    self.RotateAngle = rotate

    if XTool.UObjIsNil(self.Transform) then
        return
    end
    if self.Cfg == nil then
        return
    end

    if self.PlaceType == XFurniturePlaceType.Ground or
    self.PlaceType == XFurniturePlaceType.Wall or
    self.PlaceType == XFurniturePlaceType.Ceiling then
        --地板、墙、天花板为固定
        self.GridX = 0
        self.GridY = 0
        self.RotateAngle = 0
    elseif self.PlaceType == XFurniturePlaceType.OnWall then
        -- 摆放在墙上的家具
        local platCfgId = 0
        local plat = XDataCenter.DormManager.GetRoomPlatId(self.Room.Data.Id, CS.XHomePlatType.Wall)
        if plat ~= nil then
            platCfgId = plat.ConfigId
        end

        -- 检测是否有家具阻挡
        self.IsFurnitureBlock = XHomeDormManager.CheckRoomFurnitureBlock(self.Room.Data.Id, self.Data.Id, self.GridX, self.GridY, self.Cfg.Width, self.Cfg.Height, CS.XHomePlatType.Wall, self.RotateAngle)
        -- 检测地表是否有障碍阻挡
        local isBlock, pos = XHomeDormManager.CheckMultiBlock(platCfgId, self.GridX, self.GridY, self.Cfg.Width, self.Cfg.Height, CS.XHomePlatType.Wall, self.RotateAngle)

        -- 合并两种阻挡
        self.IsMapBlock = isBlock

        pos = self.Room.Transform.localToWorldMatrix:MultiplyPoint(pos)
        self.Transform.position = pos
        self.Transform.localEulerAngles = Vector3(0, self.RotateAngle * 90, 0)

    elseif self.PlaceType == XFurniturePlaceType.OnGround then
        --摆放在地板上家具
        if self.Cfg.LocateType ~= XFurnitureConfigs.HomeLocateType.Replace then
            if self.Cfg.Model == TEST_FURNITURE_NAME then
                -- Test
                local scale = self.Transform.localScale
                self.Transform.localScale = Vector3(self.Cfg.Width, scale.y, self.Cfg.Height)
            end
        end

        local platCfgId = 0
        local plat = XDataCenter.DormManager.GetRoomPlatId(self.Room.Data.Id, CS.XHomePlatType.Ground)
        if plat ~= nil then
            platCfgId = plat.ConfigId
        end

        -- 检测是否有家具阻挡
        self.IsFurnitureBlock = XHomeDormManager.CheckRoomFurnitureBlock(self.Room.Data.Id, self.Data.Id, self.GridX, self.GridY, self.Cfg.Width, self.Cfg.Height, CS.XHomePlatType.Ground, self.RotateAngle)
        -- 检测地表是否有障碍阻挡
        local isBlock, pos = XHomeDormManager.CheckMultiBlock(platCfgId, self.GridX, self.GridY, self.Cfg.Width, self.Cfg.Height, CS.XHomePlatType.Ground, self.RotateAngle)
        -- 合并两种阻挡
        self.IsMapBlock = isBlock

        pos = self.Room.Transform.localToWorldMatrix:MultiplyPoint(pos)
        self.Transform.position = pos
        self.Transform.localEulerAngles = Vector3(0, self.RotateAngle * 90, 0)
        
    end

    self.IsColliderBlock = XHomeDormManager.CheckRoomFurnitureCollider(self, self.Room.Data.Id)

    self:ShowSelectGrid()
end

-- 生成家具交互信息
function XHomeFurnitureObj:GenerateInteractInfo(roomMap)
    if not roomMap then
        return
    end

    self.InteractInfoList = {}
    local posList = XFurnitureConfigs.GetFurnitureInteractPosList(self.Cfg.InteractPos)
    for k, pos in ipairs(posList) do
        local gridPos, isValid = XHomeDormManager.GetInteractGridPos(self.ConfirmGridX, self.ConfirmGridY, self.Cfg.Width, self.Cfg.Height, pos.x, pos.y, self.ConfirmRotate)
        local block = roomMap:GetGridInfo(gridPos.x, gridPos.y)

        local info = {}
        info.Index = k
        info.GridPos = gridPos
        if isValid and (block <= ((1 << 1) - 1)) then
            info.UsedType = XFurnitureInteractUsedType.None
        else
            info.UsedType = XFurnitureInteractUsedType.Block
        end


        local stayPoint = self.GameObject:FindGameObject("StayPos" .. tostring(k))
        local interactPoint = self.GameObject:FindGameObject("Interactpos" .. tostring(k))

        if not XTool.UObjIsNil(stayPoint) then
            local stayPos = stayPoint.transform.position
            local stayIsInBound = XHomeDormManager.WorldPosCheckIsInBound(stayPos, self.Room.Transform)
            if stayIsInBound then
                info.StayType = XFurnitureInteractUsedType.None
            else
                info.StayType = XFurnitureInteractUsedType.Block
            end
        end

        info.StayPos = stayPoint
        info.InteractPos = interactPoint
        table.insert(self.InteractInfoList, info)
    end

    return self.InteractInfoList
end

-- 获取家具交互点信息
function XHomeFurnitureObj:GetInteractInfoList()
    if not self.InteractInfoList or _G.next(self.InteractInfoList) == nil then
        local roomMap = CS.XRoomMapInfo.GenerateMap(self.CfgId)
        self:GenerateInteractInfo(roomMap)
    end

    return self.InteractInfoList
end

-- 设置家具交互点信息
function XHomeFurnitureObj:SetInteractInfoGo()
    if self.IsSetInterGo then
        if _G.next(self.InterGos) then
            for _,v in pairs(self.InterGos)do
                if v then
                    v.gameObject:SetActive(true)
                end
            end
            return
        end
    end

    local intergo = self.Room.FurnitureRoot.gameObject:FindGameObject("InterPosIcon")
    if not intergo then
        return
    end
    local infos = self:GetInteractInfoList()
    for k,v in pairs(infos)do
        local itemobj = CS.UnityEngine.Object.Instantiate(intergo,v.InteractPos.transform)
        itemobj.transform.localPosition = Vector3(0,0.1,0)
        itemobj.transform.localRotation = CS.UnityEngine.Quaternion.Euler(90,0,0)
        itemobj.gameObject:SetActive(true)
        self.InterGos[k] = itemobj
    end
    self.IsSetInterGo = true
end

function XHomeFurnitureObj:HideInteractInfoGo()
    if self.IsSetInterGo and self.InterGos then
        for _,v in pairs(self.InterGos)do
            if v then
                v.gameObject:SetActive(false)
            end
        end
    end
end

function XHomeFurnitureObj:GetInteractInfoGo()
    return self.InterGos
end

-- 获取最近家具交互点信息
function XHomeFurnitureObj:GetNearAvailableInteract(position)
    local interactInfo = nil
    local lastDistance = 0

    for _, info in ipairs(self.InteractInfoList) do
        if info.UsedType == XFurnitureInteractUsedType.None or info.UsedType == XFurnitureInteractUsedType.Block then

            local distance = Vector3.Distance(position, info.StayPos.transform.position)
            if lastDistance <= 0 or distance < lastDistance then
                interactInfo = info
                lastDistance = distance
            end
        end
    end

    return interactInfo
end

-- 获取家具交互点信息
function XHomeFurnitureObj:GetAvailableInteract()
    for _, info in ipairs(self.InteractInfoList) do
        if info.UsedType == XFurnitureInteractUsedType.None or info.UsedType == XFurnitureInteractUsedType.Block then
            if info.StayType and info.StayType ~= XFurnitureInteractUsedType.Block then 
                return info
            end
        end
    end

    return nil
end

-- 通过构造体ID获取交互中的家具交互点信息
function XHomeFurnitureObj:GetInteractById(characterId)
    if not self.InteractInfoList then 
        return nil
    end

    for i, v in ipairs(self.InteractInfoList) do
        if (v.UsedType & XFurnitureInteractUsedType.Character) > 0 and characterId == v.CharacterId then
            return v
        end
    end

    return nil
end

-- 检测交互点是否能交互
function XHomeFurnitureObj:CheckCanInteract(gridX, gridY)
    for _, info in ipairs(self.InteractInfoList) do
        if info.GridPos.x == gridX and info.GridPos.y == gridY then
            return info.UsedType == XFurnitureInteractUsedType.None
        end
    end

    return false
end

-- 获取交互点
function XHomeFurnitureObj:GetInteract(gridX, gridY)
    for _, info in ipairs(self.InteractInfoList) do
        if info.GridPos.x == gridX and info.GridPos.y == gridY then
            return info
        end
    end

    return nil
end

-- 显示占位网格
function XHomeFurnitureObj:ShowFixGrid(isShow, rotate)
    if not isShow then
        if not XTool.UObjIsNil(self.WallFixGridComponents) then
            self.WallFixGridComponents.gameObject:SetActive(false)
        end

        if not XTool.UObjIsNil(self.GroundFixGridComponent) then
            self.GroundFixGridComponent.gameObject:SetActive(false)
        end
        return
    end

    if not self.PlaceType or self.PlaceType == XFurniturePlaceType.Ceiling or
    self.PlaceType == XFurniturePlaceType.OnGround or
    self.PlaceType == XFurniturePlaceType.OnWall then
        return
    end

    if self.PlaceType == XFurniturePlaceType.Ground then
        local w = XHomeDormManager.GetMapWidth()
        local h = XHomeDormManager.GetMapHeight()

        if XTool.UObjIsNil(self.GroundFixGridComponent) then
            self.GroundFixGridComponent = CS.XGridManager.Instance:GetGrid(h, w, false, XHomeDormManager.GetCeilSize())
            local fixtransform = self.GroundFixGridComponent.transform
            fixtransform.eulerAngles = self.Transform.eulerAngles

            fixtransform.position = self.Transform.position + Vector3(0, self.GridOffset, 0)
        end

        self.GroundFixGridComponent.gameObject:SetActive(true)

        local so = XHomeDormManager.GetGridColorSO(GridColorType.Default)
        self.GroundFixGridComponent:SetGridColorInfo(so.Asset)
    elseif self.PlaceType == XFurniturePlaceType.Wall then
        if not rotate then
            return
        end

        local mapWidth, mapHeight
        local rot = rotate % 2
        if rot == 0 then
            mapWidth = XHomeDormManager.GetMapWidth()
            mapHeight = XHomeDormManager.GetMapTall()
        else
            mapWidth = XHomeDormManager.GetMapHeight()
            mapHeight = XHomeDormManager.GetMapTall()
        end

        if XTool.UObjIsNil(self.WallFixGridComponents) then
            self.WallFixGridComponents = CS.XGridManager.Instance:GetGrid(mapHeight, mapWidth, true, XHomeDormManager.GetCeilSize())
        end

        local fixtransform = self.WallFixGridComponents.transform
        local offset = self.OnWallFixGridPos[rotate]
        fixtransform.position = self.Transform.position + offset
        fixtransform.eulerAngles = self.Transform.eulerAngles + Vector3(0, 90 * rotate, 0)

        self.WallFixGridComponents.gameObject:SetActive(true)

        local so = XHomeDormManager.GetGridColorSO(GridColorType.Default)
        self.WallFixGridComponents:SetGridColorInfo(so.Asset)
    end
end

-- 显示选中网格
function XHomeFurnitureObj:ShowSelectGrid()
    if self.IsSelected and not self.IsAddDragComponent then
        if not XTool.UObjIsNil(self.GoInputHandler) then
            self.GoInputHandler:AddDragListener(function(eventData)
                self:OnDrag(eventData)
            end)
            self.IsAddDragComponent = true
        end
    end
    if not self.IsSelected and self.IsAddDragComponent then
        if not XTool.UObjIsNil(self.GoInputHandler) then
            self.GoInputHandler:RemoveDragListener()
        end
        self.IsAddDragComponent = false
    end

    local isBlock = not self:CheckCanLocate()
    if not self.IsSelected then
        if not XTool.UObjIsNil(self.GridComponent) then
            self.GridComponent.gameObject:SetActive(false)
        end
        if not XTool.UObjIsNil(self.FurniturePlaceHolder) then
            self.FurniturePlaceHolder.gameObject:SetActive(false)
        end
        return
    end

    if not self.PlaceType then
        return
    end

    if self.PlaceType == XFurniturePlaceType.OnGround then
        local rot = self.RotateAngle % 2
        local w, h
        if rot == 0 then
            w = self.Cfg.Width
            h = self.Cfg.Height
        else
            w = self.Cfg.Height
            h = self.Cfg.Width
        end

        local left = self.GridX
        local right = XHomeDormManager.GetMapWidth() - self.GridX - w
        local up = XHomeDormManager.GetMapHeight() - self.GridY - h
        local down = self.GridY

        if left < 0 then
            left = 0
        end
        if right < 0 then
            right = 0
        end
        if up < 0 then
            up = 0
        end
        if down < 0 then
            down = 0
        end

        if XTool.UObjIsNil(self.GridComponent) then
            self.GridComponent = CS.XGridManager.Instance:GetCrossGrid(h, w, left, right,
            up, down, false, XHomeDormManager.GetCeilSize())
            self.GridComponent.gameObject.name = "GridComponent"
            self.GridComponent.transform.localEulerAngles = Vector3.zero
            self.GridComponent.transform.localScale = Vector3.one
        else
            self.GridComponent.gameObject:SetActive(true)
            self.GridComponent:GenerateCrossGrid(h, w, left, right, up, down, false, XHomeDormManager.GetCeilSize())
        end

        local so
        if isBlock then
            so = XHomeDormManager.GetGridColorSO(GridColorType.Red)
        else
            so = XHomeDormManager.GetGridColorSO(GridColorType.Blue)
        end
        self.GridComponent:SetGridColorInfo(so.Asset)
        self.GridComponent.transform.position = self.Transform.position + Vector3(0, self.GridOffset, 0)


        --家具的占位网格
        -- if XTool.UObjIsNil(self.FurniturePlaceHolder) then
        --     self.FurniturePlaceHolder = CS.XGridManager.Instance:GetCrossGrid(h + 1, w + 1, 0, 0,
        --     0, 0, false, XHomeDormManager.GetCeilSize())
        --     self.FurniturePlaceHolder.gameObject.name = "FurniturePlaceHolder"
        --     self.FurniturePlaceHolder.transform.localEulerAngles = Vector3.zero
        --     self.FurniturePlaceHolder.transform.localScale = Vector3.one
        -- else
        --     self.FurniturePlaceHolder.gameObject:SetActive(true)
        --     self.FurniturePlaceHolder:GenerateCrossGrid(h + 1, w + 1, 0, 0, 0, 0, false, XHomeDormManager.GetCeilSize())
        -- end
        -- self.FurniturePlaceHolder.transform:SetParent(self.GridComponent.transform,false)
        -- local so = XHomeDormManager.GetGridColorSO(GridColorType.Green)
        -- self.FurniturePlaceHolder:SetGridColorInfo(so.Asset)
        -- self.FurniturePlaceHolder.transform.position = self.Transform.position + Vector3(0, self.GridOffset, 0)

    elseif self.PlaceType == XFurniturePlaceType.OnWall then
        local w = self.Cfg.Width
        local h = self.Cfg.Height

        local mapWidth, mapHeight
        local rot = self.RotateAngle % 2
        if rot == 0 then
            mapWidth = XHomeDormManager.GetMapWidth()
            mapHeight = XHomeDormManager.GetMapTall()
        else
            mapWidth = XHomeDormManager.GetMapHeight()
            mapHeight = XHomeDormManager.GetMapTall()
        end

        local left = self.GridX
        local right = mapWidth - self.GridX - w
        local up = mapHeight - self.GridY - h
        local down = self.GridY

        if left < 0 then
            left = 0
        end
        if right < 0 then
            right = 0
        end
        if up < 0 then
            up = 0
        end
        if down < 0 then
            down = 0
        end

        if XTool.UObjIsNil(self.GridComponent) then
            self.GridComponent = CS.XGridManager.Instance:GetCrossGrid(h, w, left, right,
            up, down, true, XHomeDormManager.GetCeilSize())
            self.GridComponent.gameObject.name = "GridComponent"
            self.GridComponent.transform.localEulerAngles = Vector3.zero
            self.GridComponent.transform.localScale = Vector3.one
        else
            self.GridComponent.gameObject:SetActive(true)
            self.GridComponent:GenerateCrossGrid(h, w, left, right,
            up, down, true, XHomeDormManager.GetCeilSize())
        end

        local offset
        if self.RotateAngle == 0 then
            offset = Vector3(0, 0, -0.01 - self.GridOffset)
        elseif self.RotateAngle == 1 then
            offset = Vector3(-0.01 - self.GridOffset, 0, 0)
        elseif self.RotateAngle == 2 then
            offset = Vector3(0, 0, 0.01 + self.GridOffset)
        elseif self.RotateAngle == 3 then
            offset = Vector3(0.01 + self.GridOffset, 0, 0)
        end
        self.GridComponent.transform.position = self.Transform.position + Vector3(0, 0.5 * h * XHomeDormManager.GetCeilSize(), 0) + offset
        self.GridComponent.transform.eulerAngles = self.Transform.eulerAngles

        local so
        if isBlock then
            so = XHomeDormManager.GetGridColorSO(GridColorType.Red)
        else
            so = XHomeDormManager.GetGridColorSO(GridColorType.Blue)
        end
        self.GridComponent:SetGridColorInfo(so.Asset)

        --家具的占位网格
        -- if XTool.UObjIsNil(self.FurniturePlaceHolder) then
        --     self.FurniturePlaceHolder = CS.XGridManager.Instance:GetCrossGrid(h + 1, w + 1, 0, 0,
        --     0, 0, true, XHomeDormManager.GetCeilSize())
        --     self.FurniturePlaceHolder.gameObject.name = "FurniturePlaceHolder"
        --     self.FurniturePlaceHolder.transform.localScale = Vector3.one
        -- else
        --     self.FurniturePlaceHolder.gameObject:SetActive(true)
        --     self.FurniturePlaceHolder:GenerateCrossGrid(h + 1, w + 1, 0, 0, 0, 0, true, XHomeDormManager.GetCeilSize())
        -- end
        -- self.FurniturePlaceHolder.transform:SetParent(self.GridComponent.transform,false)
        -- local so = XHomeDormManager.GetGridColorSO(GridColorType.Green)
        -- self.FurniturePlaceHolder:SetGridColorInfo(so.Asset)
        -- self.FurniturePlaceHolder.transform.localPosition = Vector3.zero
    end
end

-- 获取家具位置
function XHomeFurnitureObj:GetPos()
    return self.GridX, self.GridY, self.RotateAngle
end

-- 恢复家具位置
function XHomeFurnitureObj:RevertPosition()
    self.IsSelected = false
    self:SetPos(self.ConfirmGridX, self.ConfirmGridY, self.ConfirmRotate)
end

-- 收纳家具
function XHomeFurnitureObj:Storage(isMulti)
    self.IsSelected = false
    self.InteractInfoList = {}
    self.GameObject:SetActive(false)
    if not XTool.UObjIsNil(self.GridComponent) then
        CS.XGridManager.Instance:FreeGrid(self.GridComponent)
    end
    self.GridComponent = nil

    if not isMulti then
        XHomeDormManager.RemoveFurniture(self.Room.Data.Id, self)
    end
    CsXGameEventManager.Instance:Notify(XEventId.EVENT_FURNITURE_ONDRAGITEM_CHANGED, true, self.Data.Id)

    self:Dispose()
    self:HideInteractInfoGo()
end

-- 确定放置家具
function XHomeFurnitureObj:LocateFurniture()
    self.ConfirmGridX = self.GridX
    self.ConfirmGridY = self.GridY
    self.ConfirmRotate = self.RotateAngle

    self.IsSelected = false
    self:ShowSelectGrid()

    XHomeDormManager.AddFurniture(self.Room.Data.Id, self)

    self:ShowAttrTag()
    CsXGameEventManager.Instance:Notify(XEventId.EVENT_FURNITURE_ONDRAGITEM_CHANGED, false, self.Data.Id)
end

function XHomeFurnitureObj:CancelSelect()
    --TODO
    self:ShowSelectGrid()
end

-- 点击家具
function XHomeFurnitureObj:OnClick()
    if self.PlaceType == XFurniturePlaceType.Ground or
    self.PlaceType == XFurniturePlaceType.Wall or
    self.PlaceType == XFurniturePlaceType.Ceiling then
        return
    end

    if self.IsDrag then
        self.IsDrag = false
        return
    end

    if XHomeDormManager.CheckSelectedFurniture() then
        return
    end

    if not self.IsSelected then
        self:PlayClickAnimation()
    end

    CsXGameEventManager.Instance:Notify(XEventId.EVENT_CLICKFURNITURE_ONROOM, self.Data.Id)
    XHomeDormManager.FireClickFurnitureCallback(self)
    self:ShowSelectGrid()
end

-- 拖动家具
function XHomeFurnitureObj:OnDrag(eventData)
    if self.PlaceType == XFurniturePlaceType.Ground or
    self.PlaceType == XFurniturePlaceType.Wall or
    self.PlaceType == XFurniturePlaceType.Ceiling then
        return
    end

    if not self.IsSelected then
        return false
    end

    self.IsDrag = true

    local pos = eventData.position
    return self:AdjustPosition(pos)
end

function XHomeFurnitureObj:GetCenterPosition()
    if self.CenterObj then
        return self.CenterObj.position
    else
        self.CenterObj = self.Transform:Find("CenterPos")
        if self.CenterObj then
            return self.CenterObj.position
        else
            return self.Transform.position
        end
    end
end

-- 调整家具位置
function XHomeFurnitureObj:AdjustPosition(screenPos)
    if self.Cfg == nil then
        return false
    end

    local camera = XHomeSceneManager.GetSceneCamera()
    if XTool.UObjIsNil(camera) then
        return false
    end

    local ray = camera:ScreenPointToRay(Vector3(screenPos.x, screenPos.y, 0))
    local layerMask = CS.UnityEngine.LayerMask.GetMask("HomeSurface")
    if (layerMask) then
        local ret, hit = ray:RayCast(layerMask)
        if ret then
            local width = self.Cfg.Width
            local height = self.Cfg.Height
            if self.PlaceType == XFurniturePlaceType.OnGround then
                local rot = self.RotateAngle % 2
                if rot == 1 then
                    width = self.Cfg.Height
                    height = self.Cfg.Width
                end
            end
            local gridPos, rotate = XHomeDormManager.GetGridPosByWorldPos(hit.point, hit.transform, width, height)
            self:SetPos(gridPos.x, gridPos.y, self.RotateAngle)
        end
    end
    self:SetInteractInfoGo()

    return true
end

-- 播放家具交互动画
function XHomeFurnitureObj:PlayInteractAnimation(characterId)
    if not characterId then
        return
    end

    local animationName = XFurnitureConfigs.GetDormFurnitureAnimationByCharId(self.Data.CfgId, characterId)
    if not animationName then
        return
    end

    self.Animator:Play(animationName)
end

-- 播放家具点击动画
function XHomeFurnitureObj:PlayClickAnimation()
    local animationType = XFurnitureConfigs.GetOnceAnimationType(self.Data.CfgId)
    if animationType == XFurnitureConfigs.FurnitureAnimationType.None then
        return
    end

    local animationName = XFurnitureConfigs.GetOnceAnimationName(self.Data.CfgId)
    if not animationName then
        return
    end

    -- 判断是否在和构造体交互
    for i, v in ipairs(self.InteractInfoList) do
        if (v.UsedType & XFurnitureInteractUsedType.Character) > 0 then
            return
        end
    end

    if animationType == XFurnitureConfigs.FurnitureAnimationType.Once then
        self.Animator:Play(animationName)
    elseif animationType == XFurnitureConfigs.FurnitureAnimationType.Repeat then
        if self.AninationIndex >= #animationName then
            self.AninationIndex = 0
        end

        self.AninationIndex = self.AninationIndex + 1
        self.Animator:Play(animationName[self.AninationIndex])
    end
end

-- 检测家具碰撞
function XHomeFurnitureObj:CheckFurnitureCollision(x, y, width, height, type, rotate)
    local homePlatType = XFurnitureConfigs.LocateTypeToXHomePlatType(self.Cfg.LocateType)

    -- 1.不同地表的物体，永不相交
    if homePlatType ~= type then
        return false
    end

    -- 2.墙上
    if type == CS.XHomePlatType.Wall then
        if rotate ~= self.ConfirmRotate then
            -- 2.1不在同一面墙，永不相交
            return false
        end

        -- 2.2检测两个正矩形碰撞
        local deltaX = x - self.ConfirmGridX
        local deltaY = y - self.ConfirmGridY

        if (deltaX > 0 and deltaX >= self.Cfg.Width) or (deltaX < 0 and deltaX <= -width) or
        (deltaY > 0 and deltaY >= self.Cfg.Height) or (deltaY < 0 and deltaY <= -height) then
            return false
        end
    end

    -- 3.地板上
    if type == CS.XHomePlatType.Ground then
        local deltaX = x - self.ConfirmGridX
        local deltaY = y - self.ConfirmGridY

        local rot1 = self.ConfirmRotate % 2
        local w1, h1
        if rot1 == 0 then
            w1 = self.Cfg.Width
            h1 = self.Cfg.Height
        else
            w1 = self.Cfg.Height
            h1 = self.Cfg.Width
        end

        local rot2 = rotate % 2
        local w2, h2
        if rot2 == 0 then
            w2 = width
            h2 = height
        else
            w2 = height
            h2 = width
        end

        -- 3.1旋转后，检测正矩形碰撞
        if (deltaX > 0 and deltaX >= w1) or (deltaX < 0 and deltaX <= -w2) or
        (deltaY > 0 and deltaY >= h1) or (deltaY < 0 and deltaY <= -h2) then
            return false
        end
    end

    return true
end

function XHomeFurnitureObj:RayCastSelected(isSelect)
    if self.IsShowGlow == isSelect then
        return
    end

    if isSelect then
        CS.XMaterialContainerHelper.AddRoomRim(self.GameObject)
    else
        CS.XMaterialContainerHelper.RemoveRoomRim(self.GameObject)
    end

    self.IsShowGlow = isSelect
end

function XHomeFurnitureObj:ShowAttrTag(attrIndex)
    if not attrIndex then
        attrIndex = XHomeDormManager.FurnitureShowAttrType
    end


    if attrIndex > 0 then
        local furnitureData = XDataCenter.FurnitureManager.GetFurnitureById(self.Data.Id)
        local furnitureType = XDataCenter.FurnitureManager.GetFurnitureConfigByUniqueId(self.Data.Id).TypeId

        local attrValue = 0
        local quality = 2
        local max = attrValue
        local min = 0
        if attrIndex == XFurnitureConfigs.AttrType.AttrAll then
            attrValue = furnitureData:GetScore()
            quality,max,min = XFurnitureConfigs.GetFurnitureTotalAttrLevel(furnitureType, attrValue)
        else
            attrValue = furnitureData:GeAttrtScore(attrIndex, furnitureData.AttrList[attrIndex])
            quality,max,min = XFurnitureConfigs.GetFurnitureSingleAttrLevel(furnitureType, attrIndex, attrValue)
        end



        local offset = self.Cfg.AttrTagY
        local color = XFurnitureConfigs.FurnitureAttrTagColor[quality] or XFurnitureConfigs.FurnitureAttrTagColor[1]
        local level = XFurnitureConfigs.FurnitureAttrLevel[quality] or XFurnitureConfigs.FurnitureAttrLevel[1]
        local desc = string.format("<color=%s><size=30>%s%d</size></color>", color, level, attrValue)

        CsXGameEventManager.Instance:Notify(XEventId.EVENT_DORM_FURNITURE_ATTR_TAG_DETAIL,self.Room.Data.Id,self.Data.Id,self.Transform,desc, attrValue / max,color,offset)
    else
        CsXGameEventManager.Instance:Notify(XEventId.EVENT_DORM_FURNITURE_HIDE_ATTR_TAG_DETAIL,self.Data.Id)
    end

end


function XHomeFurnitureObj:HideAttrTag()
    CsXGameEventManager.Instance:Notify(XEventId.EVENT_DORM_FURNITURE_HIDE_ATTR_TAG_DETAIL,self.Data.Id)
end

function XHomeFurnitureObj:OnStateChange(state)
    if state == "Enter" then
        self:ShowAttrTag()
        self:ShowFurnitureEffect()
        self:EnableBoxColliders()
    else
        self:HideAttrTag()
        self:HideFurnitureEffect()
        self:DisableBoxColliders()
    end
end

function XHomeFurnitureObj:ShowFurnitureEffect()
    if self.EffectComp and self.EffectComp.GameObject then
        self.EffectComp.GameObject:SetActiveEx(true)
    end
end

function XHomeFurnitureObj:HideFurnitureEffect()
    if self.EffectComp and self.EffectComp.GameObject then
        self.EffectComp.GameObject:SetActiveEx(false)
    end
end

function XHomeFurnitureObj:EnableBoxColliders()
    for k, v in pairs(self.Colliders or {}) do
        v.enabled = true
    end
end

function XHomeFurnitureObj:DisableBoxColliders()
    for k, v in pairs(self.Colliders or {}) do
        v.enabled = false
    end
end

return XHomeFurnitureObj