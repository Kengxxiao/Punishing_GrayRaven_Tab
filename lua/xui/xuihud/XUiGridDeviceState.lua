local XUiGridDeviceState = XClass(XLuaBehaviour)

function XUiGridDeviceState:Ctor(rootUi, ui, hudType)
    self.RootUi = rootUi
    self.InstId = 0
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.IsShow = false
    self.HudType = hudType
    self.IsInViewPort = true

    self:InitAutoScript()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiGridDeviceState:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiGridDeviceState:AutoInitUi()
    self.TxtDesc = XUiHelper.TryGetComponent(self.Transform, "ImageTextBg/TxtDesc", "Text")
    self.ImgIcon = XUiHelper.TryGetComponent(self.Transform, "ImgIcon", "Image")
    self.BtnOk = XUiHelper.TryGetComponent(self.Transform, "BtnOk", "Button")
end

function XUiGridDeviceState:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiGridDeviceState:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiGridDeviceState:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiGridDeviceState:AutoAddListener()
    self.AutoCreateListeners = {}
    XUiHelper.RegisterClickEvent(self, self.BtnOk, self.OnBtnOkClick)
end
-- auto

function XUiGridDeviceState:Update()
    if (not XTool.UObjIsNil(self.FollowTarget) and not XTool.UObjIsNil(self.Camera)) then
        if self.IsInViewPort then
            local followPos = self.FollowTarget.position
            if self.Data.Cfg then
                followPos = followPos + CS.UnityEngine.Vector3(self.Data.Cfg.HudX or 0,self.Data.Cfg.HudY or 0,0)
            end
            local viewportPos = self.Camera:WorldToViewportPoint(followPos)
            self.Transform.anchoredPosition = CS.UnityEngine.Vector2(viewportPos.x * XGlobalVar.UiDesignSize.Width, viewportPos.y * XGlobalVar.UiDesignSize.Height)
        end
        self:Refresh()
    end
end

function XUiGridDeviceState:OnBtnOkClick(...)
    if self.DeviceType == XDataCenter.HostelManager.FunctionDeviceType.PowerStation then
        local curVlue = XDataCenter.HostelManager.GetPowerStationSaveElectric()
        if curVlue > 0 then
            XDataCenter.HostelManager.ReqCollectPowerStationElectric(function ()
                local rewards = {}
                table.insert(rewards, {TemplateId = XDataCenter.ItemManager.ItemId.HostelElectric, Count = curVlue})
                XUiManager.OpenUiObtain(rewards)
            end)
        end
    end
end

function XUiGridDeviceState:SetMetaData(data)
    self.GameObject:SetActive(true)
    self.IsShow = true
    self.Data = data
    self:InitSizeAndScale()
    self.DeviceType = data.Type
    self.Func = data.Func
    self.DeviceConfig = XDataCenter.HostelManager.GetFuncDeviceCurLvlTemplate(self.DeviceType)
    if self.DeviceType == XDataCenter.HostelManager.FunctionDeviceType.PowerStation then
        self.RootUi:SetUiSprite(self.ImgIcon, XDataCenter.ItemManager.GetItemIcon(XDataCenter.ItemManager.ItemId.HostelElectric))
    end
end

function XUiGridDeviceState:InitSizeAndScale()
    if not self.Data.Cfg then
        return
    end
    local cfgHei = self.Data.Cfg.HudHeight or 0
    local cfgWid = self.Data.Cfg.HudWidth or 0
    local cfgScale = self.Data.Cfg.HudScale or 0
    local sizeX = (cfgWid > 0) and cfgWid or self.Transform.sizeDelta.x
    local sizeY = (cfgHei > 0) and cfgHei or self.Transform.sizeDelta.y
    self.Transform.sizeDelta = CS.UnityEngine.Vector2(sizeX,sizeY)    
    local scale = (cfgScale > 0) and cfgScale or 1
    self.Transform.localScale = CS.UnityEngine.Vector3(scale,scale,scale) 
end

function XUiGridDeviceState:SetFollowTarget(transform, camera)
    self.FollowTarget = transform
    self.Camera = camera
end

function XUiGridDeviceState:Refresh()
    if self.DeviceType == XDataCenter.HostelManager.FunctionDeviceType.PowerStation then
        local curVlue = XDataCenter.HostelManager.GetPowerStationSaveElectric()
        local isRoomView = XHomeSceneManager.GetCurrentView() == HomeSceneViewType.RoomView
        self:SetInViewPort(curVlue > 0 and isRoomView)
        if curVlue >= self.DeviceConfig.FunctionParam[3] then
            self.TxtDesc.text = CS.XTextManager.GetText("HostelFullElectric")
        else
            self.TxtDesc.text = curVlue.."/"..self.DeviceConfig.FunctionParam[3]
        end
    else

    end
end

function XUiGridDeviceState:Dispose()
    self.DeviceType = nil
    self.FollowTarget = nil
    self.Camera = nil
end

function XUiGridDeviceState:Hide()
    self:Dispose()
    self.IsShow = false
    self.GameObject:SetActive(false)
    XHudManager.ReturnHud(self)
end

function XUiGridDeviceState:SetInViewPort(value)
    self.IsInViewPort = value
    if not value then
        self.Transform.anchoredPosition = CS.UnityEngine.Vector2(10000,10000)
    end
end

return XUiGridDeviceState
