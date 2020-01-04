XUiGridNewbieTaskItem = XClass()

function XUiGridNewbieTaskItem:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    
    XTool.InitUiObject(self)
    self.BtnCollect.CallBack = function() self:OnBtnCollectClick() end
    self.BtnSkip.CallBack = function() self:OnBtnSkipClick() end

    self.RewardPanelList = {}
end

function XUiGridNewbieTaskItem:Init(rootUi)
    self.RootUi = rootUi
end

function XUiGridNewbieTaskItem:OnBtnCollectClick(eventData)
    if not self.NewbieTaskInfo then return end
    local templateTask = XDataCenter.TaskManager.GetTaskTemplate(self.NewbieTaskInfo)
    local stateTask = XDataCenter.TaskManager.GetTaskDataById(self.NewbieTaskInfo)

    if stateTask.State ~= XDataCenter.TaskManager.TaskState.Achieved then
        return 
    end

    local weaponCount = 0
    local chipCount = 0
    for i=1, #self.RewardPanelList do
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

    XDataCenter.TaskManager.FinishTask(stateTask.Id, function(rewards)
        XUiManager.OpenUiObtain(rewards, nil, function(...)
            self.RootUi:OnTaskChangeSync()
        end, nil)
    end)
end

function XUiGridNewbieTaskItem:OnBtnSkipClick(eventData)

    local templateTaskData = XDataCenter.TaskManager.GetTaskTemplate(self.NewbieTaskInfo)
    local stateTaskData = XDataCenter.TaskManager.GetTaskDataById(self.NewbieTaskInfo)
    if not templateTaskData then return end

    if stateTaskData.State ~= XDataCenter.TaskManager.TaskState.Achieved then
        XFunctionManager.SkipInterface(templateTaskData.SkipId)
    end
end

function XUiGridNewbieTaskItem:OnRefreshDatas(newbieTaskInfo)
    self.NewbieTaskInfo = newbieTaskInfo
    local templateTaskData = XDataCenter.TaskManager.GetTaskTemplate(newbieTaskInfo)
    local stateTaskData = XDataCenter.TaskManager.GetTaskDataById(newbieTaskInfo)

    self.TxtTitle.text = templateTaskData.Desc
    local result = templateTaskData.Result > 0 and templateTaskData.Result or 1
    XTool.LoopMap(stateTaskData.Schedule, function(key, pair)
        pair.Value = pair.Value > result and result or pair.Value
        self.TxtProgress.text = string.format("%d/%d", pair.Value, result)
    end)

    self:UpdateBtns()
    self:UpdateRewards()
end

function XUiGridNewbieTaskItem:UpdateBtns()
    if self.NewbieTaskInfo == nil then return end
    local stateTaskData = XDataCenter.TaskManager.GetTaskDataById(self.NewbieTaskInfo)
    self.BtnCollect.gameObject:SetActive(false)
    self.BtnSkip.gameObject:SetActive(false)
    if stateTaskData.State == XDataCenter.TaskManager.TaskState.Achieved then--可领取
        self.BtnCollect.gameObject:SetActive(true)
    elseif stateTaskData.State ~= XDataCenter.TaskManager.TaskState.Finish and stateTaskData.State ~= XDataCenter.TaskManager.TaskState.Invalid then--跳转
        self.BtnSkip.gameObject:SetActive(true)
    end
end

function XUiGridNewbieTaskItem:UpdateRewards()
    if self.NewbieTaskInfo == nil then return end
    local templateTaskData = XDataCenter.TaskManager.GetTaskTemplate(self.NewbieTaskInfo)
    local stateTaskData = XDataCenter.TaskManager.GetTaskDataById(self.NewbieTaskInfo)
    local rewards = XRewardManager.GetRewardList(templateTaskData.RewardId)
    if not rewards then return end
    local rewardCount = #rewards
    
    for i=1, rewardCount do
        local panel = self.RewardPanelList[i]
        if not panel then
            local ui = CS.UnityEngine.Object.Instantiate(self.PanelReward)
            ui.transform:SetParent(self.UiContent, false)
            ui.gameObject:SetActive(true)
            ui.gameObject.name = string.format("PanelReward%d", i)
            panel = XUiGridCommon.New(self.RootUi, ui)
            table.insert(self.RewardPanelList, i, panel)
        end
        
    end
    for i=1, #self.RewardPanelList do
        self.RewardPanelList[i].GameObject:SetActive(i <= rewardCount)
        if i <= rewardCount then
            self.RewardPanelList[i]:Refresh(rewards[i])
        end
    end
end

return XUiGridNewbieTaskItem
