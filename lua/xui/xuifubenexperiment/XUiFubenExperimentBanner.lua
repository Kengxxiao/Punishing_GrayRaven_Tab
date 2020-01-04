XUiFubenExperimentBanner = XClass()
function XUiFubenExperimentBanner:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.IsLock = false
    self.IsShowPass = false
    self.LockText = ""
end

function XUiFubenExperimentBanner:Init(index, callback)
    self.Index = index
    self.Callback = callback
    self:InitUiObjects()
    self.TrialLevelInfo = {}
end

function XUiFubenExperimentBanner:InitUiObjects()
    XTool.InitUiObject(self)
    self.AutoCreateListeners = {}
    self:RegisterListener(self.BtnModelSwitch, "onClick", self.OnBtnModelSwitchClick)
    self:RegisterListener(self.BtnEnter, "onClick", self.OnBtnEnter)
end

function XUiFubenExperimentBanner:RegisterListener(uiNode, eventName, func)
    if not uiNode then return end
    local key = eventName .. uiNode:GetHashCode()
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end
    
    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiBtnTab:RegisterListener: func is not a function")
        end
        
        listener = function(...)
            func(self, ...)
        end
        
        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiFubenExperimentBanner:OnBtnModelSwitchClick(...)
    if self.TrialLevelInfo.Type == XDataCenter.FubenExperimentManager.TrialLevelType.Switch then
        if self.CurType == XDataCenter.FubenExperimentManager.TrialLevelType.Signle then
            self.CurType = XDataCenter.FubenExperimentManager.TrialLevelType.Mult
        else
            self.CurType = XDataCenter.FubenExperimentManager.TrialLevelType.Signle
        end
        self:UpdateType()
    end
end

function XUiFubenExperimentBanner:OnBtnEnter(...)
    self:CheakLock()
    if self.IsLock then
        XUiManager.TipError(self.LockText)
       return 
    end
    self.Callback(self.Index, self.CurType)
end

function XUiFubenExperimentBanner:UpdateBanner(trialLevelInfo)
    self.TrialLevelInfo = trialLevelInfo
    if self.TrialLevelInfo.Type ~= XDataCenter.FubenExperimentManager.TrialLevelType.Switch then
        self.BtnModelSwitch.gameObject:SetActiveEx(false)
    else
        self.BtnModelSwitch.gameObject:SetActiveEx(true)
    end
    self.TxtLevelName.text = trialLevelInfo.Name
    self.CurType = trialLevelInfo.Type
    self.Back:SetRawImage(trialLevelInfo.Ico)
    self:UpdateType()
    self:CheakLock()
    self:CheakShowPass()
end

function XUiFubenExperimentBanner:UpdateType()
    if self.CurType == XDataCenter.FubenExperimentManager.TrialLevelType.Signle then
        self.ModelIconSingle.gameObject:SetActiveEx(true)
        self.ModelIconTeam.gameObject:SetActiveEx(false)
        self.ImageSingle.gameObject:SetActiveEx(true)
        self.ImageTeam.gameObject:SetActiveEx(false)
    else
        self.ModelIconSingle.gameObject:SetActiveEx(false)
        self.ModelIconTeam.gameObject:SetActiveEx(true)
        self.ImageSingle.gameObject:SetActiveEx(false)
        self.ImageTeam.gameObject:SetActiveEx(true)
    end
end

function XUiFubenExperimentBanner:CheakLock()
    local conditionIds = XDataCenter.FubenExperimentManager.GetStageCondition(self.TrialLevelInfo.Id)
    local ret = true
    local desc = ""
    for k,v in pairs(conditionIds) do
        if v ~= 0 then
            ret,desc  = XConditionManager.CheckCondition(v)
            if not ret then
                break
            end
        end
    end
    self.IsLock = not ret
    self.PaenlLock.gameObject:SetActiveEx(not ret)
    self.TxtLock.text = desc
    self.LockText = desc
end

function XUiFubenExperimentBanner:CheakShowPass()
    local showPass = XDataCenter.FubenExperimentManager.GetStageShowPass(self.TrialLevelInfo.Id)
    local finishExperimentIds = XDataCenter.FubenExperimentManager.GetFinishExperimentIds()
    self.PanelUse.gameObject:SetActiveEx(false)
    
    for k,v in pairs(finishExperimentIds) do
        if v == self.TrialLevelInfo.Id then
            self.PanelUse.gameObject:SetActiveEx(showPass ~= nil and showPass > 0)
        end
    end
end