local XUiFubenBranchStageDetail = XLuaUiManager.Register(XLuaUi, "UiFubenBranchStageDetail")

function XUiFubenBranchStageDetail:OnAwake()
    self:InitAutoScript()
    self.GridCommon.gameObject:SetActive(false)
    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.FreeGem, XDataCenter.ItemManager.ItemId.ActionPoint, XDataCenter.ItemManager.ItemId.Coin)
end

function XUiFubenBranchStageDetail:OnStart(parent)
    self.GridList = {}
    self.Parent = parent
end

function XUiFubenBranchStageDetail:OnEnable()
    self.Parent.PanelAsset.gameObject:SetActiveEx(false)
end

function XUiFubenBranchStageDetail:OnDisable()
    self.Parent.PanelAsset.gameObject:SetActiveEx(true)
end

function XUiFubenBranchStageDetail:Refresh(stage)
    self.Stage = stage
    self:UpdateCommon()
    self:UpdateRewards()
end

function XUiFubenBranchStageDetail:UpdateCommon()
    local stageId = self.Stage.StageId
    local stageCfg = XDataCenter.FubenManager.GetStageCfg(stageId)
    local stageInfo = XDataCenter.FubenManager.GetStageInfo(stageId)
    local nanDuIcon = XDataCenter.FubenManager.GetDiccicultIcon(stageId)
    local maxChallengeNum = XDataCenter.FubenManager.GetStageMaxChallengeNums(stageId)
    local buyChallengeCount = XDataCenter.FubenManager.GetStageBuyChallengeCount(stageId)

    self.RImgNandu:SetRawImage(nanDuIcon)
    self.TxtTitle.text = self.Stage.Name
    self.TxtLevelVal.text = self.Stage.RecommandLevel
    self.TxtATNums.text = self.Stage.RequireActionPoint
    self.PanelNums.gameObject:SetActive(maxChallengeNum > 0)
    self.PanelNoLimitCount.gameObject:SetActive(maxChallengeNum <= 0)
    self.BtnAddNum.gameObject:SetActive(buyChallengeCount > 0)
    for i = 1, 3 do
        self["TxtActive" .. i].text = stageCfg.StarDesc[i]
    end

    if maxChallengeNum > 0 then
        local stageData = XDataCenter.FubenManager.GetStageData(stageId)
        local chanllengeNum = stageData and stageData.PassTimesToday or 0
        self.TxtAllNums.text = "/" .. maxChallengeNum
        self.TxtLeftNums.text = maxChallengeNum - chanllengeNum
    end

    local firstDrop = false
    if not stageInfo.Passed then
        local cfg = XDataCenter.FubenManager.GetStageLevelControl(stageId)
        if cfg and cfg.FirstRewardShow > 0 or self.Stage.FirstRewardShow > 0 then
            firstDrop = true
        end
    end
    self.TxtFirstDrop.gameObject:SetActive(firstDrop)
    self.TxtDrop.gameObject:SetActive(not firstDrop)
end

function XUiFubenBranchStageDetail:UpdateRewards()
    local stage = self.Stage
    local stageInfo = XDataCenter.FubenManager.GetStageInfo(stage.StageId)

    -- 获取显示奖励Id
    local rewardId = 0
    local IsFirst = false
    local cfg = XDataCenter.FubenManager.GetStageLevelControl(stage.StageId)
    if not stageInfo.Passed then
        rewardId = cfg and cfg.FirstRewardShow or stage.FirstRewardShow
        if cfg and cfg.FirstRewardShow > 0 or stage.FirstRewardShow > 0 then
            IsFirst = true
        end
    end
    if rewardId == 0 then
        rewardId = cfg and cfg.FinishRewardShow or stage.FinishRewardShow
    end
    if rewardId == 0 then
        for j = 1, #self.GridList do
            self.GridList[j].GameObject:SetActive(false)
        end
        return
    end

    local rewards = IsFirst and XRewardManager.GetRewardList(rewardId) or XRewardManager.GetRewardListNotCount(rewardId)
    if rewards then
        for i, item in ipairs(rewards) do
            local grid
            if self.GridList[i] then
                grid = self.GridList[i]
            else
                local ui = CS.UnityEngine.Object.Instantiate(self.GridCommon)
                grid = XUiGridCommon.New(self, ui)
                grid.Transform:SetParent(self.PanelDropContent, false)
                self.GridList[i] = grid
            end
            grid:Refresh(item)
            grid.GameObject:SetActive(true)
        end
    end

    local rewardsCount = 0
    if rewards then
        rewardsCount = #rewards
    end

    for j = 1, #self.GridList do
        if j > rewardsCount then
            self.GridList[j].GameObject:SetActive(false)
        end
    end
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiFubenBranchStageDetail:InitAutoScript()
    self:AutoAddListener()
end

function XUiFubenBranchStageDetail:AutoAddListener()
    self:RegisterClickEvent(self.BtnAddNum, self.OnBtnAddNumClick)
    self:RegisterClickEvent(self.BtnEnter, self.OnBtnEnterClick)
    self:RegisterClickEvent(self.BtnClose, self.OnBtnCloseClick)
end

function XUiFubenBranchStageDetail:OnBtnCloseClick(eventData)
    self:CloseWithAnimDisable()
end
-- auto
function XUiFubenBranchStageDetail:OnBtnAddNumClick(eventData)
    local challegeData = XDataCenter.FubenMainLineManager.GetStageBuyChallegeData(self.Stage.StageId)
    XLuaUiManager.Open("UiBuyAsset", 1, function()
        self:UpdateCommon()
    end, challegeData)
end

function XUiFubenBranchStageDetail:OnBtnEnterClick(eventData)
    local stage = self.Stage
    if XDataCenter.FubenManager.CheckPreFight(stage) then
        self.Parent:CloseStageDetail()
        XLuaUiManager.Open("UiNewRoomSingle", stage.StageId)
    end
end

function XUiFubenBranchStageDetail:CloseWithAnimDisable()
    self:PlayAnimation("AnimEnd", function()
        self:Close()
    end)
end