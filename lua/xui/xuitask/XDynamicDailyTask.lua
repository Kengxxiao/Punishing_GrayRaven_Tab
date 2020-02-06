XDynamicDailyTask = XClass()

local PANEL_REWARD_COUNT = 1
local SECTION_LEVEL = 5

-- 每日任务为时间段的condition类型，除了这些类型其他任务有效时间都是一天
local TimePeriodConditionType = {
    [1] = 10102
}
local A_DAY = 24 * 60 * 60
local A_HOUR = 60 * 60
local A_MIN = 60

function XDynamicDailyTask:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RewardPanelList = {}
    
    XTool.InitUiObject(self)
    self.GridCommon.gameObject:SetActive(false)
    self.ImgComplete.gameObject:SetActive(false)
    self.PanelAnimation.gameObject:SetActive(true)

    self.BtnFinish.CallBack = function() self:OnBtnFinishClick() end
    self.BtnSkip.CallBack = function() self:OnBtnSkipClick() end
end

function XDynamicDailyTask:PlayAnimation()
    if self.IsAnimation then
        return 
    end
     
    self.IsAnimation = true
    self.GridTaskTimeline:PlayTimelineAnimation()
end

function XDynamicDailyTask:ResetData(data)
    local temp = XDataCenter.TaskManager.GetTaskTemplate(data.Id)
    self.Data = data
    
    local config = XDataCenter.TaskManager.GetTaskTemplate(self.Data.Id)
    self.tableData = config
    self.TxtTaskName.text = config.Title
    self.TxtTaskDescribe.text = config.Desc
    self.TxtSubTypeTip.text = config.Suffix or ""
    self.RImgTaskType:SetRawImage(config.Icon)
    self:UpdateProgress(self.Data)
    local rewards = XRewardManager.GetRewardList(config.RewardId)
    for i = 1, #self.RewardPanelList do
        self.RewardPanelList[i]:Refresh()
    end

    if rewards then
        for i = 1, #rewards do
            local panel = self.RewardPanelList[i]
            if not panel then
                if #self.RewardPanelList == 0 then
                    panel = XUiGridCommon.New(self.RootUi, self.GridCommon)
                else
                    local ui = CS.UnityEngine.Object.Instantiate(self.GridCommon)
                    ui.transform:SetParent(self.GridCommon.parent, false)
                    panel = XUiGridCommon.New(self.RootUi, ui)
                end
                table.insert(self.RewardPanelList, panel)
            end
    
            panel:Refresh(rewards[i])
        end
    end

    local isFinish = data.State == XDataCenter.TaskManager.TaskState.Finish
    self.ImgComplete.gameObject:SetActive(isFinish)
    self.PanelTime.gameObject:SetActive(not isFinish)
    if not isFinish then
        self:UpdateTimes()
    end
    if self.PanelAnimationGroup then
        self.PanelAnimationGroup.alpha = 1
    end
end

function XDynamicDailyTask:OnBtnFinishClick(...)
    local taskInfo = XDataCenter.TaskManager.GetTaskTemplate(self.Data.Id)
    local weaponCount = 0
    local chipCount = 0
    for i = 1, #self.RewardPanelList do
        local rewardsId = self.RewardPanelList[i].TemplateId
        if XDataCenter.EquipManager.IsClassifyEqualByTemplateId(rewardsId, XEquipConfig.Classify.Weapon) then
            weaponCount = weaponCount + 1
        elseif XDataCenter.EquipManager.IsClassifyEqualByTemplateId(rewardsId, XEquipConfig.Classify.Awareness) then
            chipCount = chipCount + 1
        end
    end
    if weaponCount > 0 and XDataCenter.EquipManager.CheckBagCount(weaponCount, XEquipConfig.Classify.Weapon) == false or
    chipCount > 0 and XDataCenter.EquipManager.CheckBagCount(chipCount, XEquipConfig.Classify.Awareness) == false then
        return
    end
    XDataCenter.TaskManager.FinishTask(self.Data.Id, function(rewardGoodsList)
        XUiManager.OpenUiObtain(rewardGoodsList)
    end)
end

function XDynamicDailyTask:OnBtnSkipClick(...)
    if XDataCenter.RoomManager.RoomData ~= nil then
        local title = CS.XTextManager.GetText("TipTitle")
        local cancelMatchMsg = CS.XTextManager.GetText("OnlineInstanceQuitRoom")
        XUiManager.DialogTip(title, cancelMatchMsg, XUiManager.DialogType.Normal, nil, function()
            XLuaUiManager.RunMain()
            local skipId = XDataCenter.TaskManager.GetTaskTemplate(self.Data.Id).SkipId
            XFunctionManager.SkipInterface(skipId)
        end)
    else
        local skipId = XDataCenter.TaskManager.GetTaskTemplate(self.Data.Id).SkipId
        XFunctionManager.SkipInterface(skipId)
    end
end

function XDynamicDailyTask:UpdateProgress(data)
    self.Data = data
    local config = XDataCenter.TaskManager.GetTaskTemplate(data.Id)
    if #config.Condition < 2 then--显示进度
        self.ImgProgress.transform.parent.gameObject:SetActive(true)
        self.TxtTaskNumQian.gameObject:SetActive(true)
        local result = config.Result > 0 and config.Result or 1
        XTool.LoopMap(self.Data.Schedule, function(key, pair)
            self.ImgProgress.fillAmount = pair.Value / result
            pair.Value = (pair.Value >= result) and result or pair.Value
            self.TxtTaskNumQian.text = pair.Value .. "/" .. result
        end)
    else
        self.ImgProgress.transform.parent.gameObject:SetActive(false)
        self.TxtTaskNumQian.gameObject:SetActive(false)
    end

    self.BtnFinish.gameObject:SetActive(false)
    self.BtnSkip.gameObject:SetActive(false)

    if self.Data.State == XDataCenter.TaskManager.TaskState.Achieved then
        self.BtnFinish.gameObject:SetActive(true)
    elseif self.Data.State ~= XDataCenter.TaskManager.TaskState.Achieved and self.Data.State ~= XDataCenter.TaskManager.TaskState.Finish then
        self.BtnSkip.gameObject:SetActive(true)

        local skipId = XDataCenter.TaskManager.GetTaskTemplate(self.Data.Id).SkipId
        if skipId == nil or skipId == 0 then
            self.BtnSkip:SetButtonState(CS.UiButtonState.Disable)
        else
            self.BtnSkip:SetButtonState(CS.UiButtonState.Normal)
        end
    end
end

function XDynamicDailyTask:UpdateTimes()
    if not self.Data then return end
    
    local taskId = self.Data.Id
    local taskTemplates = XDataCenter.TaskManager.GetTaskTemplate(taskId)
    if not taskTemplates then return end

    if XDataCenter.TaskManager.TaskType.Daily == taskTemplates.Type or XDataCenter.TaskManager.TaskType.DormDaily == taskTemplates.Type then
        self:UpdateDailyTime()

    elseif XDataCenter.TaskManager.TaskType.Weekly == taskTemplates.Type then
        self:UpdateWeeklyTime()

    elseif XDataCenter.TaskManager.TaskType.TimeLimit == taskTemplates.Type then
        if XTaskConfig.GetTimeLimitDailyTasksCheckTable()[taskId] then
            self:UpdateDailyTime()
        elseif XTaskConfig.GetTimeLimitWeeklyTasksCheckTable()[taskId] then
            self:UpdateWeeklyTime()
        else
            self.PanelTime.gameObject:SetActive(false)
        end
    else
        -- 不确定类型的默认每日
        self:UpdateDailyTime()
    end
end

function XDynamicDailyTask:UpdateDailyTime()
    local taskTemplates = XDataCenter.TaskManager.GetTaskTemplate(self.Data.Id)
    if not taskTemplates or not taskTemplates.Condition or not taskTemplates.Condition[1] then return end

    local conditionTemplates = XTaskConfig.GetTaskCondition(taskTemplates.Condition[1])
    if not conditionTemplates then return end

    local now = XTime.GetServerNowTimestamp()
    local today_0_oclock = XTime.GetTodayTime(0, 0, 0)
    local next_0_oclock = today_0_oclock + A_DAY
    local beginTime = today_0_oclock
    local endTime = next_0_oclock

    if self:IsTimePeriodCondition(conditionTemplates.Type) then
        -- 时间段限制
        beginTime = today_0_oclock + (conditionTemplates.Params[1] or 0)
        endTime = today_0_oclock + (conditionTemplates.Params[2] or 0)
    else
        if math.abs(now - today_0_oclock) <= A_HOUR * 5 then
            -- 5点以前
            beginTime = today_0_oclock - A_DAY + A_HOUR * 5 --昨天5点
            endTime = today_0_oclock + A_HOUR * 5           --今天5点
        else
            -- 5点之后
            beginTime = today_0_oclock + A_HOUR * 5         --今天5点
            endTime = next_0_oclock + A_HOUR * 5            --明天5点
        end
    end

    if now < beginTime then
        -- 距离开始
        self.PanelTime.gameObject:SetActive(true)
        local toatalSecond = beginTime - now
        if toatalSecond > A_HOUR then
            self.TxtTime.text = CS.XTextManager.GetText("TaskBeginHour", tostring(math.floor(toatalSecond/A_HOUR)))
        else
            self.TxtTime.text = CS.XTextManager.GetText("TaskBeginMin", tostring(math.ceil(toatalSecond/A_MIN)))
        end
        self.BtnSkip:SetDisable(true, false)
        self.BtnSkip:SetName(CS.XTextManager.GetText("TaskStateUnopen"))
        self.BtnSkip.gameObject:SetActive(true)
        self.BtnFinish.gameObject:SetActive(false)
    elseif now >= beginTime and now <= endTime then
        -- 剩余
        self.PanelTime.gameObject:SetActive(true)
        local toatalSecond = endTime - now
        if toatalSecond > A_HOUR then
            self.TxtTime.text = CS.XTextManager.GetText("TaskLeftHour", tostring(math.floor(toatalSecond/A_HOUR)))
        else
            self.TxtTime.text = CS.XTextManager.GetText("TaskLeftMin", tostring(math.ceil(toatalSecond/A_MIN)))
        end
        self.BtnSkip:SetDisable(false, true)
        self.BtnSkip:SetName(CS.XTextManager.GetText("TaskStateSkip"))
    else
        -- 超过
        self.BtnSkip:SetDisable(true, false)
        self.BtnSkip:SetName(CS.XTextManager.GetText("TaskStateOverdue"))
        self.BtnSkip.gameObject:SetActive(true)
        self.BtnFinish.gameObject:SetActive(false)
        self.PanelTime.gameObject:SetActive(false)
    end

    if self.Data.State ~= XDataCenter.TaskManager.TaskState.Achieved and self.Data.State ~= XDataCenter.TaskManager.TaskState.Finish then
        local skipId = XDataCenter.TaskManager.GetTaskTemplate(self.Data.Id).SkipId
        if skipId == nil or skipId == 0 then
            self.BtnSkip:SetButtonState(CS.UiButtonState.Disable)
        end
    end
end

function XDynamicDailyTask:UpdateWeeklyTime()
    self.PanelTime.gameObject:SetActive(true)

    local taskTemplates = XDataCenter.TaskManager.GetTaskTemplate(self.Data.Id)
    if not taskTemplates then return end

    local weekOfDay, epochTime = XDataCenter.TaskManager.GetWeeklyTaskRefreshTime()
    local needTime = XTime.GetNextWeekOfDayStartWithMon(weekOfDay, epochTime)
    if needTime > 0 then
        
        if needTime > A_DAY then
            self.TxtTime.text = CS.XTextManager.GetText("TaskLeftDay", tostring(math.floor(needTime / A_DAY)))
        elseif needTime > A_HOUR then
            self.TxtTime.text = CS.XTextManager.GetText("TaskLeftHour", tostring(math.floor(needTime / A_HOUR)))
        else
            self.TxtTime.text = CS.XTextManager.GetText("TaskLeftMin", tostring(math.ceil(needTime / A_MIN)))
        end
    else
        
        self.PanelTime.gameObject:SetActive(false)
    end
end

function XDynamicDailyTask:IsTimePeriodCondition(conditionType)
    for k, v in pairs(TimePeriodConditionType) do
        if conditionType == v then
            return true
        end
    end
    return false
end
