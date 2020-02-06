local XUiGridWorkSlotState = XClass(XLuaBehaviour)

function XUiGridWorkSlotState:Ctor(rootUi, ui, hudType)
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
function XUiGridWorkSlotState:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiGridWorkSlotState:AutoInitUi()
    self.BtnComplete = XUiHelper.TryGetComponent(self.Transform, "BtnComplete", "Button")
    self.BtnAdd = XUiHelper.TryGetComponent(self.Transform, "BtnAdd", "Button")
    self.ImgJiantou = XUiHelper.TryGetComponent(self.Transform, "ImgJiantou", "Image")
end

function XUiGridWorkSlotState:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiGridWorkSlotState:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiGridWorkSlotState:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiGridWorkSlotState:AutoAddListener()
    self.AutoCreateListeners = {}
    XUiHelper.RegisterClickEvent(self, self.BtnComplete, self.OnBtnCompleteClick)
    XUiHelper.RegisterClickEvent(self, self.BtnAdd, self.OnBtnAddClick)
end
-- auto

function XUiGridWorkSlotState:OnBtnCompleteClick(...)
    local cb = self.Data.fClickComplete
    if cb then
        cb()
    end
end

function XUiGridWorkSlotState:OnBtnAddClick(...)
    local cb = self.Data.fClickAdd
    if cb then
        cb()
    end
end

function XUiGridWorkSlotState:Update()
    if (not XTool.UObjIsNil(self.FollowTarget) and not XTool.UObjIsNil(self.Camera)) then
        local followPos = self.FollowTarget.position
        if self.Data.Cfg then
            followPos = followPos + CS.UnityEngine.Vector3(self.Data.Cfg.HudX or 0,self.Data.Cfg.HudY or 0,0)
        end
        local viewportPos = self.Camera:WorldToViewportPoint(followPos)
        self.Transform.anchoredPosition = CS.UnityEngine.Vector2(viewportPos.x * XGlobalVar.UiDesignSize.Width, viewportPos.y * XGlobalVar.UiDesignSize.Height)
    end
end

function XUiGridWorkSlotState:SetMetaData(data)
    self.IsShow = true
    self.GameObject:SetActive(true)
    self.Data = data
    self:InitSizeAndScale()
    self:Refresh()
end

function XUiGridWorkSlotState:InitSizeAndScale()
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

function XUiGridWorkSlotState:SetFollowTarget(transform, camera)
    self.FollowTarget = transform
    self.Camera = camera
end

function XUiGridWorkSlotState:Refresh()
    local state = self.Data.State
    self.BtnComplete.gameObject:SetActive(false)
    self.BtnAdd.gameObject:SetActive(false)
    self.ImgJiantou.gameObject:SetActive(false)
    if state == XDataCenter.HostelManager.WorkSlotState.Idle then
        self.BtnAdd.gameObject:SetActive(true)
    elseif state == XDataCenter.HostelManager.WorkSlotState.Complete then
        self.BtnComplete.gameObject:SetActive(true)
    end
end

function XUiGridWorkSlotState:ShowJiantou()
    self.BtnComplete.gameObject:SetActive(false)
    self.BtnAdd.gameObject:SetActive(false)
    self.ImgJiantou.gameObject:SetActive(true)    
end

function XUiGridWorkSlotState:HideContent()
    self.BtnComplete.gameObject:SetActive(false)
    self.BtnAdd.gameObject:SetActive(false)
    self.ImgJiantou.gameObject:SetActive(false)  
end

function XUiGridWorkSlotState:Dispose()
    self.Data = nil
    self.FollowTarget = nil
    self.Camera = nil
end

function XUiGridWorkSlotState:Hide()
    self:Dispose()
    self.GameObject:SetActive(false)
    self.IsShow = false
    XHudManager.ReturnHud(self)
end

return XUiGridWorkSlotState
