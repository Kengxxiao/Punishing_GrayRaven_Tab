XUiPanelActive = XClass()

function XUiPanelActive:Ctor(ui,rootUi,index,parent)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.rootUi = rootUi
    self.Parent = parent
    self.index = index
    XTool.InitUiObject(self)
    self.BtnActive.CallBack = function() self:OnBtnActiveClick() end
end

function XUiPanelActive:Refresh()
    
end

function XUiPanelActive:UpdateActiveness(dailyActiveness,dActiveness)
    if dailyActiveness <= dActiveness then
        self.rootUi:SetUiSprite(self.BtnActive.image, CS.XGame.ClientConfig:GetString("TaskDailyActiveReach"..self.index))
        self.PanelEffect.gameObject:SetActive(not XPlayer.IsGetDailyActivenessReward(self.index))
        self.ImgRe.gameObject:SetActive(XPlayer.IsGetDailyActivenessReward(self.index))
    else
        self.rootUi:SetUiSprite(self.BtnActive.image, CS.XGame.ClientConfig:GetString("TaskDailyActiveNotReach"..self.index))
        self.PanelEffect.gameObject:SetActive(false)
        self.ImgRe.gameObject:SetActive(false)
    end
    
    self.TxtValue.text = dailyActiveness
end

function XUiPanelActive:OnBtnActiveClick()
    self:TouchDailyRewardBtn(self.index)
end

function XUiPanelActive:TouchDailyRewardBtn(index)
    local activeness = XDataCenter.ItemManager.GetDailyActiveness().Count
    local dActiveness = XTaskConfig.GetDailyActiveness()
    local rewardIds = XTaskConfig.GetDailyActivenessRewardIds()
    local data = XRewardManager.GetRewardList(rewardIds[index])
    
    if activeness >= dActiveness[index] then
        XDataCenter.TaskManager.GetActivenessReward(index, rewardIds[index], XDataCenter.TaskManager.ActiveRewardType.Daily, function ()
            self.Parent:UpdateActiveness()
        end)
    else
        XUiManager.OpenUiTipReward(data, CS.XTextManager.GetText("DailyActiveRewardTitle"))
    end
   
end

return XUiPanelActive
