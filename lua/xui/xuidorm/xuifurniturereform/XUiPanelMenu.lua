local XUiPanelMenu = XClass(XLuaBehaviour)

function XUiPanelMenu:Ctor(rootUi, ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi

    self.IsNew = false
    self.IsFollowMouse = false
    self.IsShow = false
    self.Furniture = nil

    XTool.InitUiObject(self)
    self.BtnCancel.CallBack = function() self:OnBtnCancelClick() end
    self.BtnStorage.CallBack = function() self:OnBtnStorageClick() end
    self.BtnRotate.CallBack = function() self:OnBtnRotateClick() end
    self.BtnOk.CallBack = function() self:OnBtnOkClick() end
    self.BtnBuild.CallBack = function() self:OnBtnBuildClick() end
end

function XUiPanelMenu:Update()
    if not self.Furniture then
        self:ShowButtons(false)
        return
    end

    if XTool.UObjIsNil(self.Furniture.GameObject) then
        self:ShowButtons(false)
        return
    end

    local camera = XHomeSceneManager.GetSceneCamera()
    if XTool.UObjIsNil(camera) then
        self:ShowButtons(false)
        return
    end

    self:ShowButtons(true)
    if self.IsFollowMouse then
        local screenPoint
        if CS.UnityEngine.Application.platform == CS.UnityEngine.RuntimePlatform.WindowsEditor or
        CS.UnityEngine.Application.platform == CS.UnityEngine.RuntimePlatform.WindowsPlayer then
            if CS.UnityEngine.Input.GetMouseButtonUp(0) then
                self.IsFollowMouse = false
            end
            screenPoint = CS.UnityEngine.Vector2(CS.UnityEngine.Input.mousePosition.x, CS.UnityEngine.Input.mousePosition.y)
        else
            if CS.UnityEngine.Input.touches.Length > 0 then
                screenPoint = CS.UnityEngine.Input.GetTouch(0).position
            else
                self.IsFollowMouse = false
            end
        end
        if screenPoint then
            self.Furniture:AdjustPosition(screenPoint)
        end
    end

    local viewportPos = camera:WorldToViewportPoint(self.Furniture:GetCenterPosition())
    self.Transform.anchoredPosition = CS.UnityEngine.Vector2((viewportPos.x-0.5) * CS.UnityEngine.Screen.width, (viewportPos.y-0.5) * CS.UnityEngine.Screen.height)
    
end

-- 显示该面板
function XUiPanelMenu:Show(show)
    if self.IsShow == show then
        return
    end

    XHomeDormManager.SetSelectedFurniture(show)
    self.IsShow = show
    self.GameObject:SetActive(show)
    if show then
        XHomeDormManager.SetRoomInteractInfo(self.RootUi.RoomId)
        self.RootUi:OnShowBlockGrids()
    else
        XHomeDormManager.HideRoomInteractInfo(self.RootUi.RoomId)
        self.RootUi:OnHideBlockGrids()
    end
end

-- 显示菜单按钮
function XUiPanelMenu:ShowButtons(show)
    self.BtnCancel.gameObject:SetActive(show)
    self.BtnStorage.gameObject:SetActive(show)
    self.BtnRotate.gameObject:SetActive(show)
    self.BtnOk.gameObject:SetActive(show)
end

-- 设置该面板的家具对象
function XUiPanelMenu:SetFurniture(furniture, isFollowMouse, isNew, isOutOfLimit)
    if furniture then
        furniture.IsSelected = true
        self.IsFollowMouse = isFollowMouse
        local x, y, rotate = furniture:GetPos()
        local type = furniture:GetXHomePlatType()
        local w, h = furniture:GetSize()
        XHomeDormManager.LockCollider(rotate)
        if furniture.PlaceType == XFurniturePlaceType.OnWall then
            furniture.Room.Wall:ShowFixGrid(true, rotate)
        elseif furniture.PlaceType == XFurniturePlaceType.OnGround then
            furniture.Room.Ground:ShowFixGrid(true)
        end

        --TODO Test
        XHomeDormManager.AttachSurfaceToRoom(furniture.Room.Data.Id)
        XHomeDormManager.ShowSurface(type)
    else
        if self.Furniture then
            self.Furniture.IsSelected = false
        end
        local type = self.Furniture:GetXHomePlatType()
    end

    self.IsNew = isNew
    self.Furniture = furniture
    self.IsOutOfLimit = isOutOfLimit
    self:Show(furniture ~= nil)
end

-- 取消
function XUiPanelMenu:OnBtnCancelClick(...)
    if self.Furniture.PlaceType == XFurniturePlaceType.OnWall then
        self.Furniture.Room.Wall:ShowFixGrid(false)
    elseif self.Furniture.PlaceType == XFurniturePlaceType.OnGround then
        self.Furniture.Room.Ground:ShowFixGrid(false)
    end

    if self.IsNew then
        self.Furniture:Storage()
    else
        self.Furniture:RevertPosition()
    end

    self.RootUi:ShowFurnitureMenu(nil)
    XHomeDormManager.UnlockCollider()
end

-- 收纳
function XUiPanelMenu:OnBtnStorageClick(...)
    if self.Furniture.PlaceType == XFurniturePlaceType.OnWall then
        self.Furniture.Room.Wall:ShowFixGrid(false)
    elseif self.Furniture.PlaceType == XFurniturePlaceType.OnGround then
        self.Furniture.Room.Ground:ShowFixGrid(false)
    end
    self.Furniture:Storage()
    self.RootUi:ShowFurnitureMenu(nil)
    XHomeDormManager.UnlockCollider()
end

-- 旋转
function XUiPanelMenu:OnBtnRotateClick(...)
    if self.Furniture.PlaceType == XFurniturePlaceType.OnGround then
        local x, y, rotate = self.Furniture:GetPos()
        rotate = rotate + 1
        rotate = rotate % 4
        self.Furniture:SetPos(x, y, rotate)
    end
end

-- 创建
function XUiPanelMenu:OnBtnBuildClick(...)

    if XDataCenter.FurnitureManager.IsFurnitureCreatePosFull() then
        XUiManager.TipText("FurnitureBuildingListFull")
        return
    end

    XLuaUiManager.Open("UiFurnitureCreate",self.Furniture.Cfg.TypeId)
end

-- 确定
function XUiPanelMenu:OnBtnOkClick(...)
    if not self.Furniture:CheckCanLocate() then
        XUiManager.TipError(CS.XTextManager.GetText("FurniturePlaceNotCorrect"))
        return
    end
    if self.IsOutOfLimit then
        XUiManager.TipError(CS.XTextManager.GetText("FurnitureOutOfLimit"))
        return
    end
    if self.Furniture.PlaceType == XFurniturePlaceType.OnWall then
        self.Furniture.Room.Wall:ShowFixGrid(false)
    elseif self.Furniture.PlaceType == XFurniturePlaceType.OnGround then
        self.Furniture.Room.Ground:ShowFixGrid(false)
    end
    self.Furniture:LocateFurniture()
    self.RootUi:ShowFurnitureMenu(nil)

    XHomeDormManager.UnlockCollider()
end

return XUiPanelMenu
