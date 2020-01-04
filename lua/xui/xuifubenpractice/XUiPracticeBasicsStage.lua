XUiPracticeBasicsStage = XClass()

function XUiPracticeBasicsStage:Ctor(rootUi, ui, parent)
    self.RootUi = rootUi
    self.Parent = parent
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    
    XTool.InitUiObject(self)
    self:AddBtnsListeners()
end

function XUiPracticeBasicsStage:AddBtnsListeners()
    self.AutoCreateListeners = {}
    self:RegisterListener(self.BtnStage, "onClick", self.OnBtnStageClick)
end

function XUiPracticeBasicsStage:RegisterListener(uiNode, eventName, func)
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

function XUiPracticeBasicsStage:SetNormalStage(isLock, stageId)
    
    self.PanelStageNormal.gameObject:SetActive(not isLock)
    if not isLock then
        local stageCfg = XDataCenter.FubenManager.GetStageCfg(stageId)
        self.TxtFightNameNor.text = stageCfg.Name
        self.RImgFightActiveNor:SetRawImage(stageCfg.Icon)
    end

end

function XUiPracticeBasicsStage:SetLockStage(isLock, stageId, stageMode)
    self.PanelStageLock.gameObject:SetActive(isLock)
    if isLock and stageMode == XPracticeConfigs.PracticeMode.Character then
        local stageCfg = XDataCenter.FubenManager.GetStageCfg(stageId)
        self.TxtFightNameLock.text = stageCfg.Name
        self.RImgFightActiveLock:SetRawImage(stageCfg.Icon)
    end
end

function XUiPracticeBasicsStage:SetPassStage(isPass)
    self.PanelStagePass.gameObject:SetActive(isPass)
end

function XUiPracticeBasicsStage:UpdateNode(stageId, stageMode)
    self.StageId = stageId
    self.StageMode = stageMode
    local stageInfo = XDataCenter.FubenManager.GetStageInfo(stageId)
    if self.StageMode == XPracticeConfigs.PracticeMode.Basics then
        self.IsLock = stageInfo.IsOpen ~= true
    else
        local isOpen, description = XDataCenter.PracticeManager.CheckPracticeStageOpen(stageId)
        self.IsLock = not isOpen
    end

    self:SetNormalStage(self.IsLock, stageId)
    self:SetLockStage(self.IsLock, stageId, stageMode)
    self:SetPassStage(stageInfo.Passed)
end

function XUiPracticeBasicsStage:OnBtnStageClick(...)
    if not self.StageId then return end
    local stageInfo = XDataCenter.FubenManager.GetStageInfo(self.StageId)
    if self.IsLock then
        local _, description = XDataCenter.PracticeManager.CheckPracticeStageOpen(self.StageId)
        XUiManager.TipMsg(description)
    else
        if self.Parent then
            self.Parent:PlayScrollViewMove(self.Transform.parent)
        end
        self.RootUi:OpenStageDetail(self.StageId)
    end
end


return XUiPracticeBasicsStage