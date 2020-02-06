local XUiFubenChristmasStageDetail = XLuaUiManager.Register(XLuaUi, "UiFubenChristmasStageDetail")

function XUiFubenChristmasStageDetail:OnAwake()
    self.StarGridList = {}
    self.CommonGridList = {}
    self.GridList = {}

    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.FreeGem, XDataCenter.ItemManager.ItemId.ActionPoint)
    self:InitStarPanels()
    self.BtnEnter.CallBack = function() self:OnBtnEnterClick() end
end

function XUiFubenChristmasStageDetail:InitStarPanels()
    for i = 1, 3 do
        self.StarGridList[i] = XUiGridStageStar.New(self[string.format("GridStageStar%d", i)])
    end
end

function XUiFubenChristmasStageDetail:OnStart(rootUi)
    self.RootUi = rootUi
end

function XUiFubenChristmasStageDetail:SetStageDetail(stageId)
    self.StageId = stageId

    local stageCfg = XDataCenter.FubenManager.GetStageCfg(self.StageId)
    local stageInfo = XDataCenter.FubenManager.GetStageInfo(self.StageId)

    local maxChallengeNum = XDataCenter.FubenManager.GetStageMaxChallengeNums(self.StageId)
    
    local isLimitCount = maxChallengeNum > 0
    self.PanelNums.gameObject:SetActiveEx(isLimitCount)
    self.PanelNoLimitCount.gameObject:SetActiveEx(not isLimitCount)
    -- 有次数限制
    if isLimitCount then
        self.TxtAllNums.text = string.format("/%d", maxChallengeNum)
        self.TxtLeftNums.text = maxChallengeNum - XDataCenter.FubenFestivalActivityManager.GetFestivalStageChallengeCount(self.StageId)
    end

    self.TxtTitle.text = stageCfg.Name
    for i = 1, 3 do
        self.StarGridList[i]:Refresh(stageCfg.StarDesc[i], stageInfo.StarsMap[i])
    end

    self.ImgCostIcon:SetRawImage(XDataCenter.ItemManager.GetItemIcon(XDataCenter.ItemManager.ItemId.ActionPoint))
    self.TxtATNums.text = stageCfg.RequireActionPoint or 0

    self:UpdateRewards()
end

function XUiFubenChristmasStageDetail:UpdateRewardTitle(isFirstDrop)
    self.TxtDrop.gameObject:SetActive(not isFirstDrop)
    self.TxtFirstDrop.gameObject:SetActive(isFirstDrop)
end

function XUiFubenChristmasStageDetail:UpdateRewards()
    if not self.StageId then return end
    local stageId = self.StageId
    local stageCfg = XDataCenter.FubenManager.GetStageCfg(stageId)
    local stageInfo = XDataCenter.FubenManager.GetStageInfo(stageId)

    local rewardId = stageCfg.FinishRewardShow
    local IsFirst = false
    -- 首通有没有填
    local controlCfg = XDataCenter.FubenManager.GetStageLevelControl(stageId)
    -- 有首通
    if not stageInfo.Passed then
        if controlCfg and controlCfg.FirstRewardShow > 0 then
            rewardId = controlCfg.FirstRewardShow
            IsFirst = true
        elseif stageCfg.FirstRewardShow > 0 then
            rewardId = stageCfg.FirstRewardShow
            IsFirst = true
        end
    end
    -- 没首通
    if not IsFirst then
        if controlCfg and controlCfg.FinishRewardShow > 0 then
            rewardId = controlCfg.FinishRewardShow
        else
            rewardId = stageCfg.FinishRewardShow
        end
    end
    self:UpdateRewardTitle(IsFirst)

    local rewards = {}
    if rewardId > 0 then
        rewards = IsFirst and XRewardManager.GetRewardList(rewardId) or XRewardManager.GetRewardListNotCount(rewardId)
    end

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

function XUiFubenChristmasStageDetail:OnBtnEnterClick()
    if not self.StageId then
        XLog.Error("XUiFubenChristmasStageDetail:OnBtnEnterClick error: stageId error " .. tostring(self.StageId))
        return
    end
    local stageId = self.StageId
    local stageCfg = XDataCenter.FubenManager.GetStageCfg(stageId)
    if not stageCfg then
        XLog.Error("XUiFubenChristmasStageDetail:OnBtnEnterClick error: stageId error " .. tostring(stageId))
        return
    end

    local passedCounts = XDataCenter.FubenFestivalActivityManager.GetFestivalStageChallengeCount(stageId)
    local maxChallengeNum = XDataCenter.FubenManager.GetStageMaxChallengeNums(stageId)
    if maxChallengeNum > 0 and passedCounts >= maxChallengeNum then
        XUiManager.TipMsg(CS.XTextManager.GetText("FubenChallengeCountNotEnough"))
        return 
    end

    local stageCfg = XDataCenter.FubenManager.GetStageCfg(self.StageId)
    if XDataCenter.FubenManager.CheckPreFight(stageCfg) then
        if self.RootUi then
            self.RootUi:ClearNodesSelect()
        end
        XLuaUiManager.Open("UiNewRoomSingle", stageCfg.StageId)
        self:Close()
    end
end

function XUiFubenChristmasStageDetail:CloseDetailWithAnimation()
    self:PlayAnimation("AnimDisableEnd", function()
        self:Close()
    end)
end
