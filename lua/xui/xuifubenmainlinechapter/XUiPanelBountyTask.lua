XUiPanelBountyTask = XClass()

function XUiPanelBountyTask:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
end

--激活
function XUiPanelBountyTask:SetActive(active)
    self.GameObject:SetActive(active)
end

function XUiPanelBountyTask:SetupContent(taskData)
    self.PanelComplete.gameObject:SetActive(false)
    self.PanelStart.gameObject:SetActive(false)

    self.BountyTask = taskData

    if self.BountyTask == nil then
        return 
    end


     --根据状态显示按钮状态
    if self.BountyTask.Status == XDataCenter.BountyTaskManager.BountyTaskStatus.AcceptReward or self.BountyTask.Status == XDataCenter.BountyTaskManager.BountyTaskStatus.Complete then
        self.PanelComplete.gameObject:SetActive(true)
    else
        self.PanelStart.gameObject:SetActive(true)
    end

    local taskConfig = XDataCenter.BountyTaskManager.GetBountyTaskConfig(self.BountyTask.Id)
    if not taskConfig then
        XLog:Error("Error:BountyTask not exist!!! Id : %s", self.BountyTask.Id)
        return
    end

    self.DifficultStageCfg = XDataCenter.BountyTaskManager.GetBountyTaskDifficultStageConfig(self.BountyTask.DifficultStageId)
    self.TxtLevel.text = string.format(taskConfig.TextColor,self.DifficultStageCfg.Name)
end

--设置任务数据
function XUiPanelBountyTask:SetupTask()
    if not self.BountyTask then
        return
    end

    self.BtnGet.gameObject:SetActive(false)
    self.BtnGo.gameObject:SetActive(false)
    self.PanelTask.gameObject:SetActive(true)

    --根据状态显示按钮状态
    if self.BountyTask.Status == XDataCenter.BountyTaskManager.BountyTaskStatus.AcceptReward then
        self.PanelDone.gameObject:SetActive(true)
    elseif self.BountyTask.Status == XDataCenter.BountyTaskManager.BountyTaskStatus.Complete then
        self.BtnGet.gameObject:SetActive(true)
    else
        self.BtnGo.gameObject:SetActive(true)
    end

    local taskConfig = XDataCenter.BountyTaskManager.GetBountyTaskConfig(self.BountyTask.Id)
    if not taskConfig then
        XLog:Error("Error:BountyTask not exist!!! Id : %s", self.BountyTask.Id)
        return
    end

    self.DifficultStageCfg = XDataCenter.BountyTaskManager.GetBountyTaskDifficultStageConfig(self.BountyTask.DifficultStageId)

    self.TxtLevel.text = self.DifficultStageCfg.Name
    self.Parent:SetUiSprite(self.ImgPic, taskConfig.MonsterIcon, function()
          self.ImgPic:SetNativeSize()
        end)
    self:SetupReward(self.BountyTask.RewardId)
end


-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelBountyTask:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiPanelBountyTask:AutoInitUi()
    self.PanelStart = self.Transform:Find("PanelStart")
    self.BtnSkip = self.Transform:Find("PanelStart/BtnSkip"):GetComponent("Button")
    self.TxtLevel = self.Transform:Find("PanelStart/TxtLevel"):GetComponent("Text")
    self.PanelComplete = self.Transform:Find("PanelComplete")
    self.BtnBountyTask = self.Transform:Find("PanelComplete/BtnBountyTask"):GetComponent("Button")
end

function XUiPanelBountyTask:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiPanelBountyTask:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiPanelBountyTask:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiPanelBountyTask:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterListener(self.BtnSkip, "onClick", self.OnBtnSkipClick)
    self:RegisterListener(self.BtnBountyTask, "onClick", self.OnBtnBountyTaskClick)
end
-- auto

--跳轉
function XUiPanelBountyTask:OnBtnSkipClick(...)
    if not self.BountyTask then
        return
    end
    
   XDataCenter.FubenManager.GoToCurrentMainLine(self.BountyTask.DifficultStageId)
end

--去任务界面
function XUiPanelBountyTask:OnBtnBountyTaskClick(...)
    --CS.XUiManager.ViewManager:Push("UiMoneyReward", false, false)
    XLuaUiManager.Open("UiMoneyReward")
end

return XUiPanelBountyTask
