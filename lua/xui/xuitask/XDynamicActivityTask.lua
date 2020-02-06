XDynamicActivityTask = XClass()

function XDynamicActivityTask:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RewardPanelList = {}
    
    XTool.InitUiObject(self)
    self.GridCommon.gameObject:SetActiveEx(false)
    self.ImgComplete.gameObject:SetActiveEx(false)
    self.PanelAnimation.gameObject:SetActiveEx(true)

    self.BtnFinish.CallBack = function() self:OnBtnFinishClick() end
end

function XDynamicActivityTask:PlayAnimation()
    if self.IsAnimation then
        return 
    end
     
    self.IsAnimation = true
    self.GridTaskTimeline:PlayTimelineAnimation()
end

function XDynamicActivityTask:ResetData(data)
    self.Data = data
    local temp = XDataCenter.TaskManager.GetTaskTemplate(self.Data.Id)
    local config = XDataCenter.TaskManager.GetTaskTemplate(self.Data.Id)
    self.tableData = config
    self.TxtTaskDescribe.text = config.Desc
    self.RImgTaskType:SetRawImage(config.Icon)
    if self.Data.PointId then
        local itemIcon = XDataCenter.ItemManager.GetItemIcon(self.Data.PointId)
        self.ImgIcon:SetRawImage(itemIcon)
    end
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

    local isFinish = self.Data.State == XDataCenter.TaskManager.TaskState.Finish
    self.ImgComplete.gameObject:SetActiveEx(isFinish)
    if self.PanelAnimationGroup then
        self.PanelAnimationGroup.alpha = 1
    end
end

function XDynamicActivityTask:OnBtnFinishClick(...)
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

function XDynamicActivityTask:UpdateProgress(data)
    self.RImgTaskType.gameObject:SetActiveEx(data.IsMark)
    self.RImgTaskTypeNa.gameObject:SetActiveEx(not data.IsMark)
    self.BtnFinish.gameObject:SetActiveEx(false)
    if self.Data.State == XDataCenter.TaskManager.TaskState.Achieved then
        self.BtnFinish.gameObject:SetActiveEx(true)
    end
end
