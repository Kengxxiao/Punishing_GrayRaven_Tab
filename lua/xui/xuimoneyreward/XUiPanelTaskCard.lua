XUiPanelTaskCard = XClass()

function XUiPanelTaskCard:Ctor(ui, parent)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.GridList = {}
    self.Parent = parent
    self:InitAutoScript()
    self.GridCommon.gameObject:SetActive(false)
end

--激活
function XUiPanelTaskCard:SetActive(active)
    self.GameObject:SetActive(active)
end

--设置任务卡内容
function XUiPanelTaskCard:SetupTaskCard(taskCard)
    if not taskCard then
        return
    end

    self.BountyTask = taskCard

    local taskConfig = XDataCenter.BountyTaskManager.GetBountyTaskConfig(self.BountyTask.Id)
    if not taskConfig then
        XLog:Error("Error:BountyTask not exist!!! Id : %s", self.BountyTask.Id)
        return
    end

    self.TxtTitle.text = taskConfig.Name
    self.TxtDesc.text = taskConfig.Desc

    --self.Parent:SetUiSprite(self.ImgRoleIcon, taskConfig.RoleIcon)
    self.RImgRoleIcon:SetRawImage(taskConfig.RoleIcon)

    self.Parent:SetUiSprite(self.ImgIconQuality, taskConfig.DifficultLevelIconX, function()
        self.ImgIconQuality:SetNativeSize()
    end)

    local randomEventCfg = XDataCenter.BountyTaskManager.GetBountyTaskRandomEventConfig(self.BountyTask.EventId)
    self.TxtBuff.text = randomEventCfg.EventName

    local difficultStageCfg = XDataCenter.BountyTaskManager.GetBountyTaskDifficultStageConfig(self.BountyTask.DifficultStageId)
    self.TxtLevel.text = string.format(taskConfig.TextColor, difficultStageCfg.Name)

    self:SetupReward(self.BountyTask.RewardId)
end



--设置奖励
function XUiPanelTaskCard:SetupReward(rewardId)
    local rewards = XRewardManager.GetRewardList(rewardId)
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
                local ui = CS.UnityEngine.Object.Instantiate(self.GridCommon)
                grid = XUiGridCommon.New(self.Parent, ui)
                grid.Transform:SetParent(self.PanelReward, false)
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
function XUiPanelTaskCard:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiPanelTaskCard:AutoInitUi()
    self.ImgLevel = self.Transform:Find("ImgLevel"):GetComponent("Image")
    self.ImgBG = self.Transform:Find("ImgLevel/ImgBG"):GetComponent("Image")
    self.TxtLevel = self.Transform:Find("ImgLevel/ImgBG/TxtLevel"):GetComponent("Text")
    self.RImgRoleIcon = self.Transform:Find("ImgLevel/RImgRoleIcon"):GetComponent("RawImage")
    self.ImgIconQuality = self.Transform:Find("ImgLevel/ImgIconQuality"):GetComponent("Image")
    self.TxtTitle = self.Transform:Find("TxtTitle"):GetComponent("Text")
    self.TxtDesc = self.Transform:Find("TxtDesc"):GetComponent("Text")
    self.TxtBuff = self.Transform:Find("Image/TxtBuff"):GetComponent("Text")
    self.PanelReward = self.Transform:Find("PanelReward")
    self.GridCommon = self.Transform:Find("PanelReward/GridCommon")
    self.RImgIcon = self.Transform:Find("PanelReward/GridCommon/RImgIcon"):GetComponent("RawImage")
    self.PanelSite = self.Transform:Find("PanelReward/GridCommon/PanelSite")
    self.TxtSite = self.Transform:Find("PanelReward/GridCommon/PanelSite/TxtSite"):GetComponent("Text")
    self.BtnAccept = self.Transform:Find("BtnAccept"):GetComponent("Button")
end

function XUiPanelTaskCard:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelTaskCard:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelTaskCard:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelTaskCard:AutoAddListener()
    self:RegisterClickEvent(self.BtnAccept, self.OnBtnAcceptClick)
end
-- auto
function XUiPanelTaskCard:OnBtnClickClick(...)

end

--接受任务
function XUiPanelTaskCard:OnBtnAcceptClick(...)
    if not self.BountyTask then
        return
    end

    XDataCenter.BountyTaskManager.AcceptBountyTask(self.BountyTask.Id)
end

return XUiPanelTaskCard