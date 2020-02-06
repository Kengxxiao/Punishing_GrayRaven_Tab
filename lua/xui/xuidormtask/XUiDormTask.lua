local XUiDormTask = XLuaUiManager.Register(XLuaUi, "UiDormTask")
local TextManager = CS.XTextManager
local PANEL_INDEX

function XUiDormTask:OnAwake()
    PANEL_INDEX = XTaskConfig.PANELINDEX
    self:InitBtnSound()
end

function XUiDormTask:OnStart(toggleType)
    local lastSelectTab = XDataCenter.TaskManager.GetNewPlayerHint(XDataCenter.TaskManager.DormTaskLastSelectTab, PANEL_INDEX.Story)
    self.CurToggleType = toggleType or lastSelectTab
    self:Init()
end

function XUiDormTask:OnEnable()
    self:CheckTogLockStatus()
    self.TabPanelGroup:SelectIndex(self.CurToggleType)
    XEventManager.AddEventListener(XEventId.EVENT_TASK_SYNC, self.OnTaskChangeSync, self)
end

function XUiDormTask:Init()
    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.FreeGem, XDataCenter.ItemManager.ItemId.ActionPoint, XDataCenter.ItemManager.ItemId.Coin)
    self.BtnBack.CallBack = function() self:Close() end
    self.BtnMainUi.CallBack = function() XLuaUiManager.RunMain() end

    self.BtnMoneyReward.gameObject:SetActiveEx(false)

    self.TogStory:SetNameByGroup(1,TextManager.GetText("DormTaskNText"))
    self.TogDaily:SetNameByGroup(1,TextManager.GetText("DormTaskDText"))

    self.TaskStoryModule = XUiPanelDormTaskStory.New(self.PanelTaskStory, self)
    self.TaskDailyModule = XUiPanelDormTaskDaily.New(self.PanelTaskDaily, self)

    self.TabList = {}
    table.insert(self.TabList, self.TogStory)
    table.insert(self.TabList, self.TogDaily)
    self.TabPanelGroup:Init(self.TabList, function(index) self:OnTaskPanelSelect(index) end)
    self:CheckTogLockStatus()
    local lastSelectTab = XDataCenter.TaskManager.GetNewPlayerHint(XDataCenter.TaskManager.DormTaskLastSelectTab, PANEL_INDEX.Story)
    self.CurToggleType = self.CurToggleType or lastSelectTab
    -- 红点
    self:AddRedPointEvent()
end

function XUiDormTask:CheckTogLockStatus()
    local dailyBtnStatus = XFunctionManager.JudgeCanOpen(XFunctionManager.FunctionName.TaskDay) and CS.UiButtonState.Normal or CS.UiButtonState.Disable
    self.TogDaily:SetButtonState(dailyBtnStatus)

    local dailyBtnStatus = XFunctionManager.JudgeCanOpen(XFunctionManager.FunctionName.TaskActivity) and CS.UiButtonState.Normal or CS.UiButtonState.Disable
    self.TogActivity:SetButtonState(dailyBtnStatus)

end

function XUiDormTask:OnTaskChangeSync()
    if self.CurToggleType == PANEL_INDEX.Story then
        self.TaskStoryModule:Refresh()
    elseif self.CurToggleType == PANEL_INDEX.Daily then
        self.TaskDailyModule:Refresh()
    end
end

function XUiDormTask:OnDisable()
    XEventManager.RemoveEventListener(XEventId.EVENT_TASK_SYNC, self.OnTaskChangeSync, self)
end

function XUiDormTask:OnDestroy()
    XDataCenter.TaskManager.UpdateViewCallback = nil
    self.TaskDailyModule:StopSchedule()
end

--添加点事件
function XUiDormTask:AddRedPointEvent()
    XRedPointManager.AddRedPointEvent(self.ImgStoryNewTag, self.RefreshStoryTabRedDot, self, { XRedPointConditions.Types.CONDITION_DORM_TASK}, XDataCenter.TaskManager.TaskType.DormNormal)
    self.DailyPointId = XRedPointManager.AddRedPointEvent(self.ImgDailyNewTag, self.RefreshDailyTabRedDot, self, { XRedPointConditions.Types.CONDITION_DORM_TASK }, XDataCenter.TaskManager.TaskType.DormDaily)
end

function XUiDormTask:CheckDailyTask()
    if self.DailyPointId then
        XRedPointManager.Check(self.DailyPointId, XDataCenter.TaskManager.TaskType.DormDaily)
    end
end

--剧情标签红点
function XUiDormTask:RefreshStoryTabRedDot(count)
    self.ImgStoryNewTag.gameObject:SetActive(count >= 0)
end

--日常标签红点
function XUiDormTask:RefreshDailyTabRedDot(count)
    self.ImgDailyNewTag.gameObject:SetActive(count >= 0)
end

function XUiDormTask:GetAutoKey(uiNode, eventName)
    if not uiNode then
        return
    end
    return eventName .. uiNode:GetHashCode()
end

function XUiDormTask:InitBtnSound()
    self.SpecialSoundMap = {}
    self.SpecialSoundMap[self:GetAutoKey(self.BtnBack, "onClick")] = XSoundManager.UiBasicsMusic.Return
    self.SpecialSoundMap[self:GetAutoKey(self.BtnMainUi, "onClick")] = XSoundManager.UiBasicsMusic.Return
end

function XUiDormTask:OnTaskPanelSelect(index)
    self.CurToggleType = index
    if index == PANEL_INDEX.Story then
        self.TaskDailyModule:HidePanel()
        self.TaskStoryModule:ShowPanel()
        XDataCenter.TaskManager.SaveNewPlayerHint(XDataCenter.TaskManager.DormTaskLastSelectTab, index)
        self:PlayAnimation("StoryQieHuan")

    elseif index == PANEL_INDEX.Daily then
        if not XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.TaskDay) then
            return
        end

        self.TaskStoryModule:HidePanel()
        self.TaskDailyModule:ShowPanel()
        XDataCenter.TaskManager.SaveNewPlayerHint(XDataCenter.TaskManager.DormTaskLastSelectTab, index)
        self:PlayAnimation("DailyQieHuan")
    end
end
