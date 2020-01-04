XUiGridFurniture = XClass()

function XUiGridFurniture:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform

    XTool.InitUiObject(self)
    self.GridAttributePool = {}
    self.GridAttribute.gameObject:SetActive(false)
end

function XUiGridFurniture:Init(rootUi, parent)
    self.RootUi = rootUi
    self.Parent = parent
    --初始化家具属性
    self.PointerDownPosition = nil
    self.UiFurnitureScore = XUiFurnitureScore.New(self.RootUi, self.PanelFurnitureScore)

    self.BtnItemWidget = self.BtnItem:GetComponent("XUiWidget")
    self.BtnItemWidget:AddPointerDownListener(function(data) self:OnBtnItemPointerDown(data) end)
    self.BtnItemWidget:AddDragListener(function(data) self:OnBtnItemOnDrag(data) end)
    self.BtnItemWidget:AddPointerClickListener(function(data) self:OnBtnItemClick(data) end)

    self.BtnItemWidget:AddBeginDragListener(function(data) self:OnBtnItemOnBeginDrag(data) end)
    self.BtnItemWidget:AddEndDragListener(function(data) self:OnBtnItemOnEndDrag(data) end)
end

-- 按下家具item
function XUiGridFurniture:OnBtnItemPointerDown(data)
    self.PointerDownPosition = data.position.y

    XHomeDormManager.AttachSurfaceToRoom(self.RootUi.RoomId)

    if not self.Data then
        return
    end

    local cfg = XFurnitureConfigs.GetFurnitureTemplateById(self.Data.ConfigId)
    if not cfg then
        return
    end

    local type = XFurnitureConfigs.LocateTypeToXHomePlatType(cfg.LocateType)
    XHomeDormManager.ShowSurface(type)
end

function XUiGridFurniture:OnBtnItemOnBeginDrag(data)
    self.IsDraging = true
    self.Parent:OnBeginDrag(data)
end

function XUiGridFurniture:OnBtnItemOnEndDrag(data)
    self.IsDraging = false
    self.Parent:OnEndDrag(data)
end

-- 拖动家具item
function XUiGridFurniture:OnBtnItemOnDrag(data)
    if not self.PointerDownPosition then
        return
    end
    self.Parent:OnDrag(data)
    if data.position.y - self.PointerDownPosition < self.Parent.ControlLimit then
        return
    end

    if not self.Data then
        return
    end
    local cfg = XFurnitureConfigs.GetFurnitureTemplateById(self.Data.ConfigId)
    if not cfg then
        return
    end
    if cfg.LocateType == XFurnitureConfigs.HomeLocateType.Replace then
        -- 改造
    else
        -- 家具
        local camera = XHomeSceneManager.GetSceneCamera()
        if not XTool.UObjIsNil(camera) then
            local ray = camera:ScreenPointToRay(CS.UnityEngine.Vector3(data.position.x, data.position.y, 0))
            local layerMask = CS.UnityEngine.LayerMask.GetMask("HomeSurface")
            if (layerMask) then
                local ret, hit = ray:RayCast(layerMask)
                if ret then
                    self.PointerDownPosition = nil
                    local gridPos, rotate = XHomeDormManager.GetGridPosByWorldPos(hit.point, hit.transform, cfg.Width, cfg.Height)
                    self.Furniture = XHomeDormManager.CreateFurniture(self.RootUi.RoomId, self.Data, gridPos, rotate)
                    if not self.Furniture then
                        return
                    end
                    self.RootUi:ShowFurnitureMenu(self.Furniture, true, true)
                end
            end
        end
    end
end

function XUiGridFurniture:GetWallWidthAndHeightByRotate(rotateAngle)
    local mapWidth, mapHeight
    local rot = rotateAngle % 2
    if rot == 0 then
        mapWidth = XHomeDormManager.GetMapWidth()
        mapHeight = XHomeDormManager.GetMapTall()
    else
        mapWidth = XHomeDormManager.GetMapHeight()
        mapHeight = XHomeDormManager.GetMapTall()
    end
    return mapWidth, mapHeight
end

-- 点击家具item
function XUiGridFurniture:OnBtnItemClick(data)

    if self.IsDraging then
        return 
    end
    local cfg = XFurnitureConfigs.GetFurnitureTemplateById(self.Data.ConfigId)
    if not cfg then
        return
    end

    -- 墙上的，初始化墙上位置数据
    local pos = {}
    pos.x = 15
    pos.y = 15
    local rotate = 0
    if cfg.LocateType == XFurnitureConfigs.HomeLocateType.LocateWall then
        rotate = XHomeDormManager.DormistoryGetFarestWall(self.RootUi.RoomId) - 1
        local wallWidth, wallHeight = self:GetWallWidthAndHeightByRotate(rotate)
        pos.x = math.floor(wallWidth / 2 - cfg.Width / 2)
        pos.y = math.floor(wallHeight / 2 - cfg.Height / 2)
    end

    self.Furniture = XHomeDormManager.CreateFurniture(self.RootUi.RoomId, self.Data, pos, rotate)
    if not self.Furniture then
        return
    end
    self.Furniture:SetInteractInfoGo()
    if cfg.LocateType == XFurnitureConfigs.HomeLocateType.Replace then
        -- 改造
        XHomeDormManager.ReplaceSurface(self.RootUi.RoomId, self.Furniture)
    else
        -- 家具
        self.RootUi:ShowFurnitureMenu(self.Furniture, false, true)
        self.Furniture:ShowSelectGrid()
    end
end

--更新表现
function XUiGridFurniture:UpdateData(data)
    if not data then
        return
    end

    local baseData = XFurnitureConfigs.GetFurnitureBaseTemplatesById(data.ConfigId)
    self.TxtName.text = baseData.Name
    self.ImgIcon:SetRawImage(XDataCenter.FurnitureManager.GetFurnitureIconById(data.Id, XDormConfig.DormDataType.Self))
    self.Data = data

    self:UpdateAttributeItems()
end

function XUiGridFurniture:UpdateAttributeItems()
    local attributes = {}
    for k, v in pairs(self.Data.AttrList) do
        attributes[k] = {
            Id = k,
            Val = v,
            FurnitureId = self.Data.Id
        }
    end

    XUiHelper.CreateTemplates(self.RootUi, self.GridAttributePool, attributes, XUiGridAttribute.New, self.GridAttribute, self.PanelFurnitureScore, XUiGridAttribute.Init)
    for i = 1, #attributes do
        self.GridAttributePool[i].GameObject:SetActive(true)
    end
end

return XUiGridFurniture