local XUiTask = XLuaUiManager.Register(XLuaUi, "UiTask")

local PANEL_INDEX = {
    Story = 1,
    Daily = 2,
    Weekly = 3,
    Activity = 4,
}

function XUiTask:OnAwake()
    self:InitBtnSound()
end

function XUiTask:OnStart(toggleType)

    local lastSelectTab = XDataCenter.TaskManager.GetNewPlayerHint(XDataCenter.TaskManager.TaskLastSelectTab, PANEL_INDEX.Story)
    self.CurToggleType = toggleType or lastSelectTab

    XEventManager.AddEventListener(XEventId.EVENT_FINISH_TASK, self.OnTaskChangeSync, self)
    XEventManager.AddEventListener(XEventId.EVENT_TASK_TAB_CHANGE, self.OnTaskChangeTab, self)
    XEventManager.AddEventListener(XEventId.EVENT_TASK_FINISH_FAIL, self.OnTaskChangeSync, self)

    self:Init()
    -- self.IsStartAnimation = true
end

function XUiTask:OnEnable()
    self:CheckTogLockStatus()
    self:CheckFunctionalFilter()
    self:SetupBountyTask()
    self:AddRedPointEvent()
    self.TabPanelGroup:SelectIndex(self.CurToggleType)
    self:PlayAnimation("AnimStartEnable")
    if self.TaskStoryModule then
        self.TaskStoryModule:RefreshCouse()
    end
end

function XUiTask:Init()
    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.FreeGem, XDataCenter.ItemManager.ItemId.ActionPoint, XDataCenter.ItemManager.ItemId.Coin)
    self.BtnBack.CallBack = function() self:Close() end
    self.BtnMainUi.CallBack = function() XLuaUiManager.RunMain() end


    self.BtnMoneyReward.gameObject:SetActiveEx(not XFunctionManager.CheckFunctionFitter(XFunctionManager.FunctionName.BountyTask))
    self.BtnMoneyReward.CallBack = function() self:OnBtnMoneyRewardClick() end

    self.TaskStoryModule = XUiPanelTaskStory.New(self.PanelTaskStory, self)
    self.TaskDailyModule = XUiPanelTaskDaily.New(self.PanelTaskDaily, self)
    self.TaskWeeklyModule = XUiPanelTaskWeekly.New(self.PanelTaskWeekly, self)
    self.TaskActivityModule = XUiPanelTaskActivity.New(self.PanelTaskActivity, self)

    self.TabList = {}
    table.insert(self.TabList, self.TogStory)
    table.insert(self.TabList, self.TogDaily)
    table.insert(self.TabList, self.TogWeekly)
    table.insert(self.TabList, self.TogActivity)
    self.TabPanelGroup:Init(self.TabList, function(index) self:OnTaskPanelSelect(index) end)
    local lastSelectTab = XDataCenter.TaskManager.GetNewPlayerHint(XDataCenter.TaskManager.TaskLastSelectTab, PANEL_INDEX.Story)
    self.CurToggleType = self.CurToggleType or lastSelectTab

    -- 红点
    self:AddRedPointEvent()
end

function XUiTask:CheckTogLockStatus()
    local dailyBtnStatus = XFunctionManager.JudgeCanOpen(XFunctionManager.FunctionName.TaskDay) and CS.UiButtonState.Normal or CS.UiButtonState.Disable
    self.TogDaily:SetButtonState(dailyBtnStatus)

    local weeklyBtnStatus = XFunctionManager.JudgeCanOpen(XFunctionManager.FunctionName.TaskWeekly) and CS.UiButtonState.Normal or CS.UiButtonState.Disable
    self.TogWeekly:SetButtonState(weeklyBtnStatus)

    local dailyBtnStatus = XFunctionManager.JudgeCanOpen(XFunctionManager.FunctionName.TaskActivity) and CS.UiButtonState.Normal or CS.UiButtonState.Disable
    self.TogActivity:SetButtonState(dailyBtnStatus)

end

function XUiTask:CheckFunctionalFilter()
    self.TogStory.gameObject:SetActiveEx(not XFunctionManager.CheckFunctionFitter(XFunctionManager.FunctionName.TaskStory))
    self.TogDaily.gameObject:SetActiveEx(not XFunctionManager.CheckFunctionFitter(XFunctionManager.FunctionName.TaskDay))
    self.TogWeekly.gameObject:SetActiveEx(not XFunctionManager.CheckFunctionFitter(XFunctionManager.FunctionName.TaskWeekly))
    self.TogActivity.gameObject:SetActiveEx(not XFunctionManager.CheckFunctionFitter(XFunctionManager.FunctionName.TaskActivity))
end

function XUiTask:OnTaskChangeSync()
    if self.CurToggleType == PANEL_INDEX.Story then
        self.TaskStoryModule:Refresh()
    elseif self.CurToggleType == PANEL_INDEX.Daily then
        self.TaskDailyModule:Refresh()
    elseif self.CurToggleType == PANEL_INDEX.Weekly then
        self.TaskWeeklyModule:Refresh()
    elseif self.CurToggleType == PANEL_INDEX.Activity then
        self.TaskActivityModule:Refresh()
    end
end

--赏金
function XUiTask:SetupBountyTask()
    local completeCount = XDataCenter.BountyTaskManager.GetBountyTaskCompletedCount()
    self.BtnMoneyReward.gameObject:SetActive(XFunctionManager.JudgeOpen(XFunctionManager.FunctionName.BountyTask))
    self.ImgCompleted.gameObject:SetActive(completeCount == XDataCenter.BountyTaskManager.MAX_BOUNTY_TASK_COUNT)
    self.ImgRedTag.gameObject:SetActive(XDataCenter.BountyTaskManager.CheckBountyTaskHasReward() or XDataCenter.BountyTaskManager.IsFirstTimeLoginInWeek())
end

function XUiTask:OnDisable()
    self.PreToggleType = nil
    self.TaskStoryModule:HidePanel()
    self.TaskDailyModule:HidePanel()
    self.TaskWeeklyModule:HidePanel()
end

function XUiTask:OnDestroy()
    XDataCenter.TaskManager.UpdateViewCallback = nil
    XEventManager.RemoveEventListener(XEventId.EVENT_FINISH_TASK, self.OnTaskChangeSync, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_TASK_TAB_CHANGE, self.OnTaskChangeTab, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_TASK_FINISH_FAIL, self.OnTaskChangeSync, self)
    self.TaskDailyModule:StopSchedule()
end

--添加点事件
function XUiTask:AddRedPointEvent()
    XRedPointManager.AddRedPointEvent(self.ImgStoryNewTag, self.RefreshStoryTabRedDot, self, { XRedPointConditions.Types.CONDITION_TASK_TYPE, XRedPointConditions.Types.CONDITION_TASK_COURSE }, XDataCenter.TaskManager.TaskType.Story)
    self.DailyPointId = XRedPointManager.AddRedPointEvent(self.ImgDailyNewTag, self.RefreshDailyTabRedDot, self, { XRedPointConditions.Types.CONDITION_TASK_TYPE }, XDataCenter.TaskManager.TaskType.Daily)
    XRedPointManager.AddRedPointEvent(self.ImgWeeklyNewTag, self.RefreshWeeklyTabRedDot, self, {XRedPointConditions.Types.CONDITION_TASK_TYPE}, XDataCenter.TaskManager.TaskType.Weekly)
    XRedPointManager.AddRedPointEvent(self.ImgActivetyNewTag, self.RefreshActivityTabRedDot, self, { XRedPointConditions.Types.CONDITION_TASK_TYPE }, XDataCenter.TaskManager.TaskType.Activity)
end

function XUiTask:CheckDailyTask()
    if self.DailyPointId then
        -- 主界面任务红点检查
        XEventManager.DispatchEvent(XEventId.EVENT_TASK_SYNC)

        -- 任务界面红点检查
        XRedPointManager.Check(self.DailyPointId, XDataCenter.TaskManager.TaskType.Daily)
    end
end

--剧情标签红点
function XUiTask:RefreshStoryTabRedDot(count)
    self.ImgStoryNewTag.gameObject:SetActive(count >= 0)
end

--日常标签红点
function XUiTask:RefreshDailyTabRedDot(count)
    self.ImgDailyNewTag.gameObject:SetActive(count >= 0)
end

-- 每周标签红点
function XUiTask:RefreshWeeklyTabRedDot(count)
    self.ImgWeeklyNewTag.gameObject:SetActive(count >= 0)
end

--活动标签红点
function XUiTask:RefreshActivityTabRedDot(count)
    self.ImgActivetyNewTag.gameObject:SetActive(count >= 0)
end

function XUiTask:GetAutoKey(uiNode, eventName)
    if not uiNode then
        return
    end
    return eventName .. uiNode:GetHashCode()
end

function XUiTask:OnBtnMoneyRewardClick(...)
    if not XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.BountyTask) then
        return
    end

    XDataCenter.BountyTaskManager.SetBountyTaskLastRefreshTime()
    --XDataCenter.BountyTaskManager.SetBountyTaskLastLoginTime()
    XLuaUiManager.Open("UiMoneyReward")
end

function XUiTask:InitBtnSound()
    self.SpecialSoundMap = {}
    self.SpecialSoundMap[self:GetAutoKey(self.BtnBack, "onClick")] = XSoundManager.UiBasicsMusic.Return
    self.SpecialSoundMap[self:GetAutoKey(self.BtnMainUi, "onClick")] = XSoundManager.UiBasicsMusic.Return
end

function XUiTask:OnTaskChangeTab(index)
    self.TabPanelGroup:SelectIndex(index)
end

function XUiTask:OnTaskPanelSelect(index)
    if self.PreToggleType == index then
        return
    end

    if self.IsFirstAnimation == nil then
        self.IsFirstAnimation = true
    else
        self.IsFirstAnimation = false
    end

    self.PreToggleType = index
    self.CurToggleType = index
    if index == PANEL_INDEX.Story then
        if XFunctionManager.CheckFunctionFitter(XFunctionManager.FunctionName.TaskStory) then
            self.TaskStoryModule:HidePanel()
            return
        end

        self.TaskDailyModule:HidePanel()
        self.TaskWeeklyModule:HidePanel()
        self.TaskActivityModule:HidePanel()
        self.TaskStoryModule:ShowPanel(self.IsFirstAnimation)

        XDataCenter.TaskManager.SaveNewPlayerHint(XDataCenter.TaskManager.TaskLastSelectTab, index)
        self:PlayAnimation("TaskStoryQieHuan")

    elseif index == PANEL_INDEX.Daily then
        if XFunctionManager.CheckFunctionFitter(XFunctionManager.FunctionName.TaskDay) then
            self.TaskDailyModule:HidePanel()
            return
        end

        if not XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.TaskDay) then
            return
        end

        self.TaskStoryModule:HidePanel()
        self.TaskWeeklyModule:HidePanel()
        self.TaskActivityModule:HidePanel()
        self.TaskDailyModule:ShowPanel(self.IsFirstAnimation)
        XDataCenter.TaskManager.SaveNewPlayerHint(XDataCenter.TaskManager.TaskLastSelectTab, index)

        self:PlayAnimation("TaskDailyQieHuan", function()
            self.TaskDailyModule:UpdateActiveness()
        end)

    elseif index == PANEL_INDEX.Weekly then
        if XFunctionManager.CheckFunctionFitter(XFunctionManager.FunctionName.TaskWeekly) then
            self.TaskWeeklyModule:HidePanel()
            return
        end

        if not XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.TaskWeekly) then
            return
        end

        self.TaskDailyModule:HidePanel()
        self.TaskStoryModule:HidePanel()
        self.TaskActivityModule:HidePanel()
        self.TaskWeeklyModule:ShowPanel()
        XDataCenter.TaskManager.SaveNewPlayerHint(XDataCenter.TaskManager.TaskLastSelectTab, index)
        self:PlayAnimation("TaskWeeklyQieHuan")

    elseif index == PANEL_INDEX.Activity then
        if XFunctionManager.CheckFunctionFitter(XFunctionManager.FunctionName.TaskActivity) then
            self.TaskActivityModule:HidePanel()
            return
        end

        if not XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.TaskActivity) then
            return
        end

        self.TaskDailyModule:HidePanel()
        self.TaskStoryModule:HidePanel()
        self.TaskWeeklyModule:HidePanel()
        self.TaskActivityModule:ShowPanel()
        XDataCenter.TaskManager.SaveNewPlayerHint(XDataCenter.TaskManager.TaskLastSelectTab, index)
        self:PlayAnimation("TaskActivityQieHuan")
    end
end
