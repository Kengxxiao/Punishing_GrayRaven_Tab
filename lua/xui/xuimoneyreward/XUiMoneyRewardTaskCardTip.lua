local XUiMoneyRewardTaskCardTip = XLuaUiManager.Register(XLuaUi, "UiMoneyRewardTaskCardTip")

function XUiMoneyRewardTaskCardTip:OnAwake()
    self:InitAutoScript()
end

function XUiMoneyRewardTaskCardTip:OnStart(taskCard, parent)

    --self.Parent = parent
    self.GridList = {}
    self.BountyTask = taskCard
    self:SetupTaskCard()

    self.Transform:PlayLegacyAnimation("MoneyRewardTaskCardTipBegin")
end

--设置任务卡内容
function XUiMoneyRewardTaskCardTip:SetupTaskCard()
    if not self.BountyTask then
        return
    end

    local taskConfig = XDataCenter.BountyTaskManager.GetBountyTaskConfig(self.BountyTask.Id)
    if not taskConfig then
        XLog:Error("Error:BountyTask not exist!!! Id : %s", self.BountyTask.Id)
        return
    end

    self.TxtTitle.text = taskConfig.Name
    self.TxtDesc.text = taskConfig.Desc

    self.RImgRoleIcon:SetRawImage(taskConfig.RoleIcon)
    self:SetUiSprite(self.ImgQuality,taskConfig.DifficultLevelIconX, function()
        self.ImgQuality:SetNativeSize()
    end)

    local randomEventCfg = XDataCenter.BountyTaskManager.GetBountyTaskRandomEventConfig(self.BountyTask.EventId)
    self.TxtBuff.text = randomEventCfg.EventName

    local difficultStageCfg = XDataCenter.BountyTaskManager.GetBountyTaskDifficultStageConfig(self.BountyTask.DifficultStageId)
    self.TxtLevel.text = string.format(taskConfig.TextColor, difficultStageCfg.Name)

    self:SetupReward(self.BountyTask.RewardId)
end

--设置奖励
function XUiMoneyRewardTaskCardTip:SetupReward(rewardId)
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
                grid = XUiGridCommon.New(self, ui)
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
function XUiMoneyRewardTaskCardTip:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiMoneyRewardTaskCardTip:AutoInitUi()
    self.PanelContent = self.Transform:Find("SafeAreaContentPane/PanelContent")
    self.ImgLevel = self.Transform:Find("SafeAreaContentPane/PanelContent/ImgLevel"):GetComponent("Image")
    self.ImgBG = self.Transform:Find("SafeAreaContentPane/PanelContent/ImgLevel/ImgBG"):GetComponent("Image")
    self.TxtLevel = self.Transform:Find("SafeAreaContentPane/PanelContent/ImgLevel/ImgBG/TxtLevel"):GetComponent("Text")
    self.RImgRoleIcon = self.Transform:Find("SafeAreaContentPane/PanelContent/ImgLevel/RImgRoleIcon"):GetComponent("RawImage")
    self.ImgQuality = self.Transform:Find("SafeAreaContentPane/PanelContent/ImgLevel/ImgQuality"):GetComponent("Image")
    self.TxtTitle = self.Transform:Find("SafeAreaContentPane/PanelContent/TxtTitle"):GetComponent("Text")
    self.TxtDesc = self.Transform:Find("SafeAreaContentPane/PanelContent/TxtDesc"):GetComponent("Text")
    self.TxtBuff = self.Transform:Find("SafeAreaContentPane/PanelContent/Image/TxtBuff"):GetComponent("Text")
    self.PanelReward = self.Transform:Find("SafeAreaContentPane/PanelContent/PanelReward")
    self.GridCommon = self.Transform:Find("SafeAreaContentPane/PanelContent/PanelReward/GridCommon")
    self.RImgIcon = self.Transform:Find("SafeAreaContentPane/PanelContent/PanelReward/GridCommon/RImgIcon"):GetComponent("RawImage")
    self.PanelSite = self.Transform:Find("SafeAreaContentPane/PanelContent/PanelReward/GridCommon/PanelSite")
    self.TxtSite = self.Transform:Find("SafeAreaContentPane/PanelContent/PanelReward/GridCommon/PanelSite/TxtSite"):GetComponent("Text")
    self.BtnBg = self.Transform:Find("FullScreenBackground/BtnBg"):GetComponent("Button")
end

function XUiMoneyRewardTaskCardTip:AutoAddListener()
    self:RegisterClickEvent(self.BtnBg, self.OnBtnBgClick)
end
-- auto
function XUiMoneyRewardTaskCardTip:OnBtnBgClick(...)
    --CS.XUiManager.ViewManager:Pop()
    self:Close()
end