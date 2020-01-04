XDeviceObject = XClass()

DeviceCategory = {
    Device = 1,
    Slot = 2,
}

function XDeviceObject:Ctor(go, xRoomObj, cfg)
    self.GameObject = go
    self.Transform = go.transform
    self.Parent = xRoomObj

    self.DeviceCfg = cfg
    self.DeviceType = cfg.Id
    self.OpenUI = cfg.OpenUI

    if self.DeviceType > XDataCenter.HostelManager.FunctionDeviceType.Unknown and
            self.DeviceType < XDataCenter.HostelManager.FunctionDeviceType.FucEnd then
        self.Category = DeviceCategory.Device
        self.DeviceData = XDataCenter.HostelManager.GetFunctionDeviceData(self.DeviceType)
    else
        self.Category = DeviceCategory.Slot
        self.DeviceData = XDataCenter.HostelManager.GetWorkCharBySlot(self.DeviceType)
    end

    XSceneEntityManager.AddEntity(self.GameObject, self)

    self.GoInputHandler = self.Transform:GetComponent(typeof(CS.XGoInputHandler))
    if not XTool.UObjIsNil(self.GoInputHandler) then
        self.GoInputHandler:AddPointerClickListener(function(eventData) self:OnClick() end)
    end
end

function XDeviceObject:Dispose()
    XSceneEntityManager.RemoveEntity(self.GameObject)

    if not XTool.UObjIsNil(self.GoInputHandler) then
        self.GoInputHandler:RemoveAllListeners()
    end
    self.GoInputHandler = nil

    if self.HudId then
        local hud = XHudManager.GetDisplayHudByInstId(self.HudId)
        if hud then
            hud:Hide()
        end
    end
    self.HudId = nil

    self.GameObject = nil
    self.Parent = nil
    self.DeviceCfg = nil
    self.OpenUI = nil

    self.Category = nil
    self.DeviceData = nil
end

function XDeviceObject:OnClick()
    if self.Category == DeviceCategory.Slot then
        local state = XDataCenter.HostelManager.GetWorkSlotState(self.DeviceType)
        if state == XDataCenter.HostelManager.WorkSlotState.Lock then
            XUiManager.TipText("HostelWorkSlotLock")
            return
        end
    end
    if XDataCenter.HostelManager.IsInVisitFriendHostel() then
        self:ChangeViewToCurDevice()
        return
    else
        local fCloseCallBack = function()
            self.Parent:ChangeViewCurRoomView()
        end
        if self.DeviceType == XDataCenter.HostelManager.FunctionDeviceType.PowerStation then
            local curVlue = XDataCenter.HostelManager.GetPowerStationSaveElectric()
            if curVlue > 0 then
                XDataCenter.HostelManager.ReqCollectPowerStationElectric(function()
                    local rewards = {}
                    table.insert(rewards, { TemplateId = XDataCenter.ItemManager.ItemId.HostelElectric, Count = curVlue })

                    XUiManager.OpenUiObtain(rewards, nil, function()

                        --使用新UI打开
                        XLuaUiManager.Open(self.OpenUI, self.DeviceType, self, fCloseCallBack)

                        self:ChangeViewToCurDevice()

                    end)
                end)
                return
            else
                --使用新UI打开
                XLuaUiManager.Open(self.OpenUI, self.DeviceType, self, fCloseCallBack)
            end

        else

            --使用新UI打开
            XLuaUiManager.Open(self.OpenUI, fCloseCallBack)

        end
    end
    self:ChangeViewToCurDevice()
end

function XDeviceObject:ChangeViewToCurDevice()
    local cameraCtrl = XHomeSceneManager.GetSceneCameraController()
    if cameraCtrl then
        XCameraHelper.SetCameraTarget(cameraCtrl, self.GameObject.transform, 3)
        cameraCtrl:SetWorldOffset(CS.UnityEngine.Vector2.zero)
        cameraCtrl.AllowDrag = false
    end

    XHomeSceneManager.ChangeView(HomeSceneViewType.DeviceView)
end

function XDeviceObject:OnBeginDrag()
    --
end

function XDeviceObject:OnEndDrag()
    --
end

function XDeviceObject:OnDrag()
    --
end

function XDeviceObject:CheckShowHud()
    if self.Category == DeviceCategory.Device then
        if XDataCenter.HostelManager.IsInVisitFriendHostel() then
            --todo
        else
            if self.DeviceType == XDataCenter.HostelManager.FunctionDeviceType.PowerStation then
                self:ShowHud(UiHudType.DeviceState, { Type = self.DeviceType })
            end
        end
        --TODO
    elseif self.Category == DeviceCategory.Slot then
        if XDataCenter.HostelManager.IsInVisitFriendHostel() then
            return
        end
        local state, time = XDataCenter.HostelManager.GetWorkSlotState(self.DeviceType)
        if time and time > 0 then
            self:ShowHud(UiHudType.CoolTime, { Time = time, CallBack = function()
                self:CheckShowHud()
            end })
        else
            self:ShowHud(UiHudType.WorkSlotState, { State = state, Slot = self.DeviceType, fClickComplete = function()
                XDataCenter.HostelManager.ReqCollectSlotProduct(self.DeviceType, function(charId, rewards)
                    self:CheckShowHud()
                    --CS.XUiManager.DialogManager:Push("UiHostelMissionComplete", false, false, charId, rewards)
                    XLuaUiManager.Open("UiHostelMissionComplete", charId, rewards)
                end)
            end,
                                                    fClickAdd = function()
                                                        self:OnClick()
                                                    end })
        end
    end
end

function XDeviceObject:ShowHud(hudType, data)
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
    data.Cfg = XDataCenter.HostelManager.GetHudTemplate(hudType, self.DeviceType)
    hud:SetMetaData(data)
    local camera = XHomeSceneManager.GetSceneCamera()
    hud:SetFollowTarget(self.Transform, camera)
end

function XDeviceObject:GetDisplayHud()
    if self.HudId then
        return XHudManager.GetDisplayHudByInstId(self.HudId)
    else
        return nil
    end
end

function XDeviceObject:HideHud()
    if self.HudId then
        local hud = XHudManager.GetDisplayHudByInstId(self.HudId)
        if hud then
            hud:Hide()
        end
    end
    self.HudId = nil
end