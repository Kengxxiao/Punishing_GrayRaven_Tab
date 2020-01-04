local MAX_DIFFICULT_NUM = 5

local tableInsert = table.insert

local XUiActivityBossSingleDetail = XLuaUiManager.Register(XLuaUi, "UiActivityBossSingleDetail")

function XUiActivityBossSingleDetail:OnAwake()
    self:InitAutoScript()
    self.GridCommon.gameObject:SetActive(false)
    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.FreeGem, XDataCenter.ItemManager.ItemId.ActionPoint, XDataCenter.ItemManager.ItemId.Coin)
end

function XUiActivityBossSingleDetail:OnStart(challengeId)
    self.ChallengeId = challengeId
    self.GridList = {}
    XEventManager.AddEventListener(XEventId.EVENT_ENTER_FIGHT, self.OnBtnBackClick, self)

    self:Refresh(self.ChallengeId)
end

function XUiActivityBossSingleDetail:OnDestroy()
    XEventManager.RemoveEventListener(XEventId.EVENT_ENTER_FIGHT, self.OnBtnBackClick, self)
end

function XUiActivityBossSingleDetail:Refresh(challengeId)
    self.ChallengeId = challengeId
    self:InitCommon()
    self:InitRewards()
end

function XUiActivityBossSingleDetail:InitCommon()
    local challengeId = self.ChallengeId
    local stageId = XFubenActivityBossSingleConfigs.GetStageId(challengeId)
    local stageCfg = XDataCenter.FubenManager.GetStageCfg(stageId)
    local nanDuIcon = XDataCenter.FubenManager.GetDiccicultIcon(stageId)
    local maxChallengeNum = XDataCenter.FubenManager.GetStageMaxChallengeNums(stageId)
    local buyChallengeCount = XDataCenter.FubenManager.GetStageBuyChallengeCount(stageId)
    local challengeResCfg = XFubenActivityBossSingleConfigs.GetChallengeResCfg(challengeId)

    self.RImgNandu:SetRawImage(nanDuIcon)
    self.TxtTitle.text = stageCfg.Name
    self.TxtLevelVal.text = stageCfg.RecommandLevel
    self.TxtATNums.text = stageCfg.RequireActionPoint
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
    if not XDataCenter.FubenActivityBossSingleManager.IsChallengePassed(self.ChallengeId) then
        local cfg = XDataCenter.FubenManager.GetStageLevelControl(stageId)
        if cfg and cfg.FirstRewardShow > 0 or stageCfg.FirstRewardShow > 0 then
            firstDrop = true
        end
    end
    self.TxtFirstDrop.gameObject:SetActive(firstDrop)
    self.TxtDrop.gameObject:SetActive(not firstDrop)

    self.RImgBg:SetRawImage(challengeResCfg.BgPath)
end

function XUiActivityBossSingleDetail:InitRewards()
    local stageId = XFubenActivityBossSingleConfigs.GetStageId(self.ChallengeId)
    local stageCfg = XDataCenter.FubenManager.GetStageCfg(stageId)

    -- 获取显示奖励Id
    local rewardId = 0
    local IsFirst = false
    local cfg = XDataCenter.FubenManager.GetStageLevelControl(stageCfg.StageId)
    if not XDataCenter.FubenActivityBossSingleManager.IsChallengePassed(self.ChallengeId) then
        rewardId = cfg and cfg.FirstRewardShow or stageCfg.FirstRewardShow
        if cfg and cfg.FirstRewardShow > 0 or stageCfg.FirstRewardShow > 0 then
            IsFirst = true
        end
    end
    if rewardId == 0 then
        rewardId = cfg and cfg.FinishRewardShow or stageCfg.FinishRewardShow
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
function XUiActivityBossSingleDetail:InitAutoScript()
    self:AutoAddListener()
end

function XUiActivityBossSingleDetail:AutoAddListener()
    self:RegisterClickEvent(self.BtnAddNum, self.OnBtnAddNumClick)
    self:RegisterClickEvent(self.BtnEnter, self.OnBtnEnterClick)
    self:RegisterClickEvent(self.BtnBack, self.OnBtnBackClick)
    self:RegisterClickEvent(self.BtnMainUi, self.OnBtnMainUiClick)
end
-- auto
function XUiActivityBossSingleDetail:OnBtnAddNumClick(eventData)
    local stageId = XFubenActivityBossSingleConfigs.GetStageId(self.ChallengeId)
    local challegeData = XDataCenter.FubenMainLineManager.GetStageBuyChallegeData(stageId)
    XLuaUiManager.Open("UiBuyAsset", 1, function()
        self:InitCommon()
    end, challegeData)
end

function XUiActivityBossSingleDetail:OnBtnEnterClick(eventData)
    local stageId = XFubenActivityBossSingleConfigs.GetStageId(self.ChallengeId)
    XLuaUiManager.Open("UiNewRoomSingle", stageId)
    self:Close()
end

function XUiActivityBossSingleDetail:OnBtnBackClick(eventData)
    if not self.GameObject.activeSelf then
        self:Close()
        return
    end
    self:PlayAnimation("AnimOnDisable",function ()
        self:Close()
    end)
end

function XUiActivityBossSingleDetail:OnBtnMainUiClick(eventData)
    XLuaUiManager.RunMain()
end