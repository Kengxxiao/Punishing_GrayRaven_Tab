local XUiGridCoolTime = XClass(XLuaBehaviour)

local RemainTimerName = "XUiGridCoolTime_RemainTimer"

function XUiGridCoolTime:Ctor(rootUi, ui, hudType)
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
function XUiGridCoolTime:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiGridCoolTime:AutoInitUi()
    self.TxtTime = XUiHelper.TryGetComponent(self.Transform, "TxtTime", "Text")
end

function XUiGridCoolTime:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiGridCoolTime:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiGridCoolTime:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiGridCoolTime:AutoAddListener()
    self.AutoCreateListeners = {}
end
-- auto

function XUiGridCoolTime:Update()
    if (not XTool.UObjIsNil(self.FollowTarget) and not XTool.UObjIsNil(self.Camera)) then
        local followPos = self.FollowTarget.position
        if self.Data.Cfg then
            followPos = followPos + CS.UnityEngine.Vector3(self.Data.Cfg.HudX or 0,self.Data.Cfg.HudY or 0,0)
        end
        local viewportPos = self.Camera:WorldToViewportPoint(followPos)
        self.Transform.anchoredPosition = CS.UnityEngine.Vector2(viewportPos.x * XGlobalVar.UiDesignSize.Width, viewportPos.y * XGlobalVar.UiDesignSize.Height)
    end
end

function XUiGridCoolTime:SetMetaData(data)
    self.IsShow = true
    self.GameObject:SetActive(true)
    self.Data = data
    self:InitSizeAndScale()
    self.RemainTime = data.Time
    self.TimeOutCb = data.CallBack
    self:InitTime()
end

function XUiGridCoolTime:InitSizeAndScale()
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

function XUiGridCoolTime:SetFollowTarget(transform, camera)
    self.FollowTarget = transform
    self.Camera = camera
end

function XUiGridCoolTime:Refresh()
    --
end

function XUiGridCoolTime:GetTimerName()
    if not self.TimerName then
        self.TimerName = RemainTimerName..self.InstId
    end
    return self.TimerName
end

function XUiGridCoolTime:Dispose()
    XCountDown.RemoveTimer(self:GetTimerName())
    self.RemainTime = nil
    self.FollowTarget = nil
    self.Camera = nil
end

function XUiGridCoolTime:Hide()
    self:Dispose()
    self.IsShow = false
    self.GameObject:SetActive(false)
    XHudManager.ReturnHud(self)
end

function XUiGridCoolTime:InitTime()
    XCountDown.CreateTimer(self:GetTimerName(), self.RemainTime)
    XCountDown.BindTimer(self, self:GetTimerName(), function(v)
        if v > 0 then
            if not XTool.UObjIsNil(self.TxtTime) then
                self.TxtTime.text = XUiHelper.GetTime(v, XUiHelper.TimeFormatType.HOSTEL)
            end
        else
            if not XTool.UObjIsNil(self.TxtTime) then
                self.TxtTime.text = ""
            end
            self:Hide()
            if self.TimeOutCb then
                self.TimeOutCb()
            end
        end
    end)
end

return XUiGridCoolTime
