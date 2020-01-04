XUiPanelMissionGrid = XClass()

function XUiPanelMissionGrid:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.GridList = {}
    self:InitAutoScript()
    self.Timer = nil
    self.ShowCompletedAnimation = false
    self.TxtTimeRect = self.TxtTime.gameObject:GetComponent("RectTransform")
    self.GridCommonA.gameObject:SetActive(false)
end

function XUiPanelMissionGrid:OnRecycle()
    self:StopTimer()
end

function XUiPanelMissionGrid:StartTimer()
    if self.Timer then
        self:StopTimer()
    end

    self.Timer = CS.XScheduleManager.ScheduleForever(function()
        self:UpdateTime()
    end, CS.XScheduleManager.SECOND)
end

function XUiPanelMissionGrid:StopTimer()
    if self.Timer then
        CS.XScheduleManager.UnSchedule(self.Timer)
        self.Timer = nil
    end
end

function XUiPanelMissionGrid:UpdateTime()
    if not self.TaskData or not self.TaskData.Task then
        return
    end

    local curTime = XTime.Now()
    local completeTime = self.TaskData.Task.UtcFinishTime

    if not self.TxtTime:Exist() then
        return
    end

    local offset = completeTime - curTime
    if offset > 0 then
        self.TxtTime.text = CS.XDate.GetTimeString(offset)
    else
        self.TxtTime.text = "00:00:00"
        self:StopTimer()
    end
end

function XUiPanelMissionGrid:PlayCompletedAnimation(cb)
    XUiHelper.PlayAnimation(self.GameObject, "AniMissionTaskComplete", cb)
end

function XUiPanelMissionGrid:Init(parent)
    self.Parent = parent
    self.MainRewardGrid = XUiGridCommon.New(self.Parent, self.GridCommon)
end

function XUiPanelMissionGrid:SetupContent(taskData)


    if not taskData then
        return
    end

    self.TaskData = taskData
    self:SetupBaseInfo()
    self:SetupTask()
end

function XUiPanelMissionGrid:SetupTask()

    self:StopTimer()

    if self.TaskData.Status == XDataCenter.TaskForceManager.TaskForceTaskStatus.Normal then
        return
    end

    local task = self.TaskData.Task
    if not task then
        return
    end

    self.BtnFinish.gameObject:SetActive(task.Status == XDataCenter.TaskForceManager.TaskForceTaskStatus.Complete)
    self.PanelStop.gameObject:SetActive(task.Status == XDataCenter.TaskForceManager.TaskForceTaskStatus.Accept)

    if task.Status == XDataCenter.TaskForceManager.TaskForceTaskStatus.Accept then
        self:UpdateTime()
        self:StartTimer()
    elseif task.Status == XDataCenter.TaskForceManager.TaskForceTaskStatus.Complete then
        self.TxtTime.text = "00:00:00"
    end
end

--设置基础信息
function XUiPanelMissionGrid:SetupBaseInfo()
    local taskCfg = self.TaskData.TaskCfg
    if not taskCfg then
        return
    end
    self.TxtName.text = taskCfg.Name
    self.TxtTime.text = CS.XDate.GetTimeString(taskCfg.Duration)
    self.TxtTimeRect.anchoredPosition = CS.UnityEngine.Vector2(0, -16.2)

    self.BtnSend.gameObject:SetActive(self.TaskData.Task.Status == XDataCenter.TaskForceManager.TaskForceTaskStatus.Normal)
    self.BtnFinish.gameObject:SetActive(false)
    self.PanelStop.gameObject:SetActive(false)
    --self.BtnTimeGo.gameObject:SetActive(false)

    self.Parent:SetUiSprite(self.ImgQuality, CS.XGame.ClientConfig:GetString("MissionQuality"..taskCfg.Quality))

    self:SetupReward(taskCfg.ShowId, taskCfg.RewardId)
end

--设置奖励
function XUiPanelMissionGrid:SetupReward(mainRewardId, rewardId)

    --顯示奖励
    local rewards = XRewardManager.GetRewardList(mainRewardId)
    if self.MainRewardGrid then
        self.MainRewardGrid:Refresh(rewards[1])
        self.MainRewardGrid.TxtCount.gameObject:SetActive(false)
    end

    rewards = XRewardManager.GetRewardList(rewardId)
    if not rewards then
        return
    end

    --显示的奖励
    local start = 0
    if rewards then
        for i, item in ipairs(rewards) do
            start = i
            local grid = nil
            if self.GridList[i] then
                grid = self.GridList[i]
            else
                local ui = CS.UnityEngine.Object.Instantiate(self.GridCommonA)
                grid = XUiGridCommon.New(self.Parent, ui)
                grid.Transform:SetParent(self.PanelLayoutReward, false)
                self.GridList[i] = grid
            end
            grid:Refresh(item)
            grid.GameObject:SetActive(true)
        end
    end

    for j = start + 1, #self.GridList do
        self.GridList[j].GameObject:SetActive(false)
    end
end


-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelMissionGrid:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiPanelMissionGrid:AutoInitUi()
    self.PanelTime = self.Transform:Find("PanelTime")
    self.TxtTime = self.Transform:Find("PanelTime/TxtTime"):GetComponent("Text")
    self.PanelRaward = self.Transform:Find("PanelRaward")
    self.PanelScrollView = self.Transform:Find("PanelRaward/PanelScrollView")
    self.PanelLayoutReward = self.Transform:Find("PanelRaward/PanelScrollView/Viewport/PanelLayoutReward")
    self.GridCommonA = self.Transform:Find("PanelRaward/PanelScrollView/Viewport/PanelLayoutReward/GridCommon")
    self.PanelMainReward = self.Transform:Find("PanelMainReward")
    self.GridCommon = self.Transform:Find("PanelMainReward/GridCommon")
    self.PanelBase = self.Transform:Find("PanelBase")
    self.BtnFinish = self.Transform:Find("PanelBase/BtnFinish"):GetComponent("Button")
    self.PanelReceive = self.Transform:Find("PanelBase/BtnFinish/PanelReceive")
    self.BtnSend = self.Transform:Find("PanelBase/BtnSend"):GetComponent("Button")
    self.PanelStop = self.Transform:Find("PanelBase/PanelStop")
    self.BtnTimeGo = self.Transform:Find("PanelBase/PanelStop/BtnTimeGo"):GetComponent("Button")
    self.BtnStop = self.Transform:Find("PanelBase/PanelStop/BtnStop"):GetComponent("Button")
    self.PanelTitle = self.Transform:Find("PanelTitle")
    self.ImgQuality = self.Transform:Find("PanelTitle/ImgQuality"):GetComponent("Image")
    self.TxtName = self.Transform:Find("PanelTitle/TxtName"):GetComponent("Text")
end

function XUiPanelMissionGrid:GetAutoKey(uiNode, eventName)
    if not uiNode then
        return
    end
    return eventName .. uiNode:GetHashCode()
end

function XUiPanelMissionGrid:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then
        return
    end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiPanelMissionGrid:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiPanelMissionGrid:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterListener(self.BtnFinish, "onClick", self.OnBtnFinishClick)
    self:RegisterListener(self.BtnSend, "onClick", self.OnBtnSendClick)
    self:RegisterListener(self.BtnTimeGo, "onClick", self.OnBtnTimeGoClick)
    self:RegisterListener(self.BtnStop, "onClick", self.OnBtnStopClick)
end
-- auto
function XUiPanelMissionGrid:OnBtnTimeGoClick(...)
    if not self.TaskData then
        return
    end

    local task = self.TaskData.Task
    if not task then
        return
    end

    if task.Status ~= XDataCenter.TaskForceManager.TaskForceTaskStatus.Accept then
        return
    end

    --CS.XUiManager.ViewManager:Push("UiMissionAddSpeedTip",true, false,self.TaskData)
    XLuaUiManager.Open("UiMissionAddSpeedTip", self.TaskData)

end

function XUiPanelMissionGrid:OnBtnFinishClick(...)
    if not self.TaskData then
        return
    end

    local task = self.TaskData.Task
    if not task then
        return
    end

    if task.Status ~= XDataCenter.TaskForceManager.TaskForceTaskStatus.Complete then
        return
    end

    XDataCenter.TaskForceManager.AcceptTaskForceRewardRequest(task.TaskId, function(result)
        --CS.XUiManager.ViewManager:Push("UiMissionCompleted",true,false,result,task.Members[1])
        XLuaUiManager.Open("UiMissionCompleted", result, task.Members[1])
    end)
end

function XUiPanelMissionGrid:OnBtnSendClick(...)
    --CS.XUiManager.ViewManager:Push("UiMissionTeam", false, false,self.TaskData)
    XLuaUiManager.Open("UiMissionTeam", self.TaskData)
end

function XUiPanelMissionGrid:OnBtnStopClick(...)
    if not self.TaskData then
        return
    end

    local task = self.TaskData.Task
    if not task then
        return
    end

    if task.Status ~= XDataCenter.TaskForceManager.TaskForceTaskStatus.Accept then
        return
    end

    XUiManager.DialogTip(CS.XTextManager.GetText("MissionTeamCountTipTile"), CS.XTextManager.GetText("MissionGiveupTaskContent"), XUiManager.DialogType.Normal, nil, function()
        XDataCenter.TaskForceManager.GiveUpTaskForceTaskRequest(task.TaskId)
    end)
end

return XUiPanelMissionGrid