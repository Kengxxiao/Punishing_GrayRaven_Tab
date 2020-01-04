XRoomObject = XClass()

function XRoomObject:Ctor(go, parent, cfg)
    self.GameObject = go
    self.Transform = go.transform
    self.Parent = parent

    self.RoomType = cfg.Id
    self.DeviceList = {}

    local curScene = XHomeSceneManager.GetCurrentScene()
    local device_map = XDataCenter.HostelManager.GetSceneDeviceNodeMap(cfg.Scene, cfg.Id)
    if device_map ~= nil then
        for _, device_cfg in pairs(device_map) do
            if not string.IsNilOrEmpty(device_cfg.Path) then
                local deviceGo = curScene.GameObject.transform:Find(device_cfg.Path).gameObject
                local device = XDeviceObject.New(deviceGo, self, device_cfg)
                --local uiWidget = deviceGo.gameObject:AddComponent(typeof(CS.XUiWidget))
                --uiWidget:AddPointerClickListener(XSceneEventHandler.OnSceneObjectClick)
                --uiWidget:AddBeginDragListener(XSceneEventHandler.OnBeginDrag)
                --uiWidget:AddEndDragListener(XSceneEventHandler.OnEndDrag)
                table.insert(self.DeviceList, device)
            end
        end
    end

    XSceneEntityManager.AddEntity(self.GameObject, self)
    self:CheckShowHud()
end

function XRoomObject:Dispose()
    XSceneEntityManager.RemoveEntity(self.GameObject)
    for _, device in ipairs(self.DeviceList) do
        device:Dispose()
    end
    self:HideRoomCurHud()
    self.DeviceList = nil

    self.GameObject = nil
    self.Parent = nil
end

function XRoomObject:CheckShowHud()
    local state = XDataCenter.HostelManager.GetFuncDeviceUpgradeState(self.RoomType)
    if state == XDataCenter.HostelManager.DeviceUpgradeState.Upgrading or state == XDataCenter.HostelManager.DeviceUpgradeState.Complete then
        self:ShowHud(UiHudType.RoomUpgrade,{Type = self.RoomType})
    end
end

function XRoomObject:OnClick()
    self:ChangeViewCurRoomView()
    --CS.XUiManager.ViewManager:Push("UiHostelRoom", false, false)
    XLuaUiManager.Open("UiHostelRoom")
    local state = XDataCenter.HostelManager.GetFuncDeviceUpgradeState(self.RoomType)
    if state == XDataCenter.HostelManager.DeviceUpgradeState.Complete then
        self:HideRoomCurHud()
        XDataCenter.HostelManager.ComfirmFuncDeviceUpgrade(self.RoomType, function ()
            CS.XUiManager.DialogManager:Push("UiHostelDeviceUpgradeResult", false, false, self.RoomType)
        end)
    end  
end

function XRoomObject:ChangeViewCurRoomView()
    if XDataCenter.HostelManager.IsInVisitFriendHostel() then
        return
    else
        local state = XDataCenter.HostelManager.GetFuncDeviceUpgradeState(self.RoomType)
        if state == XDataCenter.HostelManager.DeviceUpgradeState.Upgrading then
            return
        end        
    end
    local cameraCtrl = XHomeSceneManager.GetSceneCameraController()
    if cameraCtrl then
        XCameraHelper.SetCameraTarget(cameraCtrl, self.GameObject.transform, 8)
        cameraCtrl:SetWorldOffset(CS.UnityEngine.Vector2.zero)
        cameraCtrl.AllowDrag = false
    end

    XHomeSceneManager.ChangeView(HomeSceneViewType.RoomView)

    for _, device in ipairs(self.DeviceList) do
        device:CheckShowHud()
    end
end

function XRoomObject:OnBeginDrag()
    --
end

function XRoomObject:OnEndDrag()
    --
end

function XRoomObject:OnDrag()
    --
end

function XRoomObject:ShowHud(hudType, data)
    local hud = nil
    if self.HudId then
        local oldHud = XHudManager.GetDisplayHudByInstId(self.HudId)
        if oldHud then
            if oldHud.HudType == hudType then
                hud = oldHud
            else
                oldHud:Hide()
            end
        end
    end

    if not hud then
        hud = XHudManager.GetHud(hudType)
        self.HudId = hud.InstId
    end
    data.Cfg = XDataCenter.HostelManager.GetHudTemplate(hudType,self.RoomType)
    hud:SetMetaData(data)
    local camera = XHomeSceneManager.GetSceneCamera()
    hud:SetFollowTarget(self.Transform, camera)
end

function XRoomObject:HideRoomCurHud()
    if self.HudId then
        local hud = XHudManager.GetDisplayHudByInstId(self.HudId)
        if hud then
            hud:Hide()
        end
        self.HudId = nil
    end
end

function XRoomObject:GetDisplayHud()
    if self.HudId then
        return XHudManager.GetDisplayHudByInstId(self.HudId)
    else
        return nil
    end
end

function XRoomObject:HideDeviceHud()
    for _, device in ipairs(self.DeviceList) do
        device:HideHud()
    end 
end