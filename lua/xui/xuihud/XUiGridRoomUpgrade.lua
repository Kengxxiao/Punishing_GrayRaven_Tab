local XUiGridRoomUpgrade = XClass(XLuaBehaviour)

local RemainTimerName = "XUiGridRoomUpgrade_RemainTimer"

function XUiGridRoomUpgrade:Ctor(rootUi, ui, hudType)
    self.RootUi = rootUi
    self.InstId = 0
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.IsShow = false
    self.HudType = hudType

    self:InitAutoScript()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiGridRoomUpgrade:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiGridRoomUpgrade:AutoInitUi()
    self.PanelUpgrading = XUiHelper.TryGetComponent(self.Transform, "PanelUpgrading", nil)
    self.TxtTime = XUiHelper.TryGetComponent(self.Transform, "PanelUpgrading/TxtTime", "Text")
    self.PanelComplete = XUiHelper.TryGetComponent(self.Transform, "PanelComplete", nil)
end

function XUiGridRoomUpgrade:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiGridRoomUpgrade:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiGridRoomUpgrade:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiGridRoomUpgrade:AutoAddListener()
    self.AutoCreateListeners = {}
end
-- auto

function XUiGridRoomUpgrade:Update()
    if (not XTool.UObjIsNil(self.FollowTarget) and not XTool.UObjIsNil(self.Camera)) then
        local followPos = self.FollowTarget.position
        if self.Data.Cfg then
            followPos = followPos + CS.UnityEngine.Vector3(self.Data.Cfg.HudX or 0,self.Data.Cfg.HudY or 0,0)
        end
        local viewportPos = self.Camera:WorldToViewportPoint(followPos)
        self.Transform.anchoredPosition = CS.UnityEngine.Vector2(viewportPos.x * XGlobalVar.UiDesignSize.Width, viewportPos.y * XGlobalVar.UiDesignSize.Height)
    end
end

function XUiGridRoomUpgrade:SetMetaData(data)
    self.IsShow = true
    self.GameObject:SetActive(true)
    self.Data = data
    self:InitSizeAndScale()
    self:InitTime()
end

function XUiGridRoomUpgrade:InitSizeAndScale()
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

function XUiGridRoomUpgrade:SetFollowTarget(transform, camera)
    self.FollowTarget = transform
    self.Camera = camera
end

function XUiGridRoomUpgrade:Refresh()
    --
end

function XUiGridRoomUpgrade:Dispose()
    XCountDown.RemoveTimer(RemainTimerName)
    self.Data = nil
    self.State = nil
    self.FollowTarget = nil
    self.Camera = nil
end

function XUiGridRoomUpgrade:Hide()
    self:Dispose()
    self.State = XDataCenter.HostelManager.DeviceUpgradeState.Normal
    self.GameObject:SetActive(false)
    XHudManager.ReturnHud(self)
end

function XUiGridRoomUpgrade:InitTime()
    local state, remainTime = XDataCenter.HostelManager.GetFuncDeviceUpgradeState(self.Data.Type)
    self.State = state

    if not XTool.UObjIsNil(self.PanelUpgrading) then
        self.PanelUpgrading.gameObject:SetActive(state == XDataCenter.HostelManager.DeviceUpgradeState.Upgrading)
    end

    if not XTool.UObjIsNil(self.PanelComplete) then
        self.PanelComplete.gameObject:SetActive(state == XDataCenter.HostelManager.DeviceUpgradeState.Complete)
    end

    if state == XDataCenter.HostelManager.DeviceUpgradeState.Complete then
        return
    end

    XCountDown.CreateTimer(RemainTimerName, remainTime)
    XCountDown.BindTimer(self, RemainTimerName, function(v)
        if not XTool.UObjIsNil(self.PanelUpgrading) then
            self.PanelUpgrading.gameObject:SetActive(v > 0)
        end

        if not XTool.UObjIsNil(self.PanelComplete) then
            self.PanelComplete.gameObject:SetActive(v <= 0)
        end

        if v > 0 then
            if not XTool.UObjIsNil(self.TxtTime) then
                self.TxtTime.text = XUiHelper.GetTime(v, XUiHelper.TimeFormatType.HOSTEL)
            end
            self.State = XDataCenter.HostelManager.DeviceUpgradeState.Upgrading
        else
            if not XTool.UObjIsNil(self.TxtTime) then
                self.TxtTime.text = ""
            end
            self.State = XDataCenter.HostelManager.DeviceUpgradeState.Complete
        end
    end)
end

return XUiGridRoomUpgrade
