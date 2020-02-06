local XUiFubenMainLineDetail = XLuaUiManager.Register(XLuaUi, "UiFubenMainLineDetail")

function XUiFubenMainLineDetail:OnAwake()
    self:InitAutoScript()
    self.GridStageStar.gameObject:SetActive(false)
    self.GridCommon.gameObject:SetActive(false)
    self:InitStarPanels()
end

function XUiFubenMainLineDetail:OnStart(rootUi)
    self.GridList = {}
    self.RootUi = rootUi
    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.FreeGem, XDataCenter.ItemManager.ItemId.ActionPoint, XDataCenter.ItemManager.ItemId.Coin)
end

function XUiFubenMainLineDetail:OnEnable()
    -- 动画
    self.IsPlaying = true
    self:PlayAnimation("AnimBegin", handler(self, function()
        self.IsPlaying = false
    end))

    self:AddEventListener()
    self.IsOpen = true

    self:Refresh(self.RootUi.Stage)
end

function XUiFubenMainLineDetail:OnDisable()
    self:RemoveEventListener()
    self.IsOpen = false
end

function XUiFubenMainLineDetail:InitStarPanels()
    self.GridStarList = {}
    for i = 1, 3 do
        local ui = self.Transform:Find("SafeAreaContentPane/PanelDetail/PanelTargetList/GridStageStar" .. i)
        ui.gameObject:SetActive(true)
        local grid = XUiGridStageStar.New(ui)
        self.GridStarList[i] = grid
    end
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiFubenMainLineDetail:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiFubenMainLineDetail:AutoInitUi()
    -- self.PanelDetail = self.Transform:Find("SafeAreaContentPane/PanelDetail")
    -- self.PanelAsset = self.Transform:Find("SafeAreaContentPane/PanelDetail/PanelAsset")
    -- self.PanelNums = self.Transform:Find("SafeAreaContentPane/PanelDetail/PanelNums")
    -- self.TxtAllNums = self.Transform:Find("SafeAreaContentPane/PanelDetail/PanelNums/TxtAllNums"):GetComponent("Text")
    -- self.TxtLeftNums = self.Transform:Find("SafeAreaContentPane/PanelDetail/PanelNums/TxtLeftNums"):GetComponent("Text")
    -- self.BtnAddNum = self.Transform:Find("SafeAreaContentPane/PanelDetail/PanelNums/BtnAddNum"):GetComponent("Button")
    -- self.PanelDesc = self.Transform:Find("SafeAreaContentPane/PanelDetail/PanelDesc")
    -- self.TxtTitle = self.Transform:Find("SafeAreaContentPane/PanelDetail/PanelDesc/TxtTitle"):GetComponent("Text")
    -- self.RImgNandu = self.Transform:Find("SafeAreaContentPane/PanelDetail/PanelDesc/RImgNandu"):GetComponent("RawImage")
    -- self.TxtDesc = self.Transform:Find("SafeAreaContentPane/PanelDetail/PanelDesc/TxtDesc"):GetComponent("Text")
    -- self.PanelNoLimitCount = self.Transform:Find("SafeAreaContentPane/PanelDetail/PanelNoLimitCount")
    -- self.PanelTargetList = self.Transform:Find("SafeAreaContentPane/PanelDetail/PanelTargetList")
    -- self.GridStageStar = self.Transform:Find("SafeAreaContentPane/PanelDetail/PanelTargetList/GridStageStar")
    -- self.PanelDropList = self.Transform:Find("SafeAreaContentPane/PanelDetail/PanelDropList")
    -- self.PanelDrop = self.Transform:Find("SafeAreaContentPane/PanelDetail/PanelDropList/PanelDrop")
    -- self.TxtDrop = self.Transform:Find("SafeAreaContentPane/PanelDetail/PanelDropList/PanelDrop/TxtDrop"):GetComponent("Text")
    -- self.TxtDropEn = self.Transform:Find("SafeAreaContentPane/PanelDetail/PanelDropList/PanelDrop/TxtDropEn"):GetComponent("Text")
    -- self.TxtFirstDrop = self.Transform:Find("SafeAreaContentPane/PanelDetail/PanelDropList/PanelDrop/TxtFirstDrop"):GetComponent("Text")
    -- self.PanelDropContent = self.Transform:Find("SafeAreaContentPane/PanelDetail/PanelDropList/DropList/Viewport/PanelDropContent")
    -- self.GridCommon = self.Transform:Find("SafeAreaContentPane/PanelDetail/PanelDropList/DropList/Viewport/PanelDropContent/GridCommon")
    -- self.PanelBottom = self.Transform:Find("SafeAreaContentPane/PanelDetail/PanelBottom")
    -- self.TxtATNums = self.Transform:Find("SafeAreaContentPane/PanelDetail/PanelBottom/TxtATNums"):GetComponent("Text")
    -- self.BtnEnter = self.Transform:Find("SafeAreaContentPane/PanelDetail/PanelBottom/BtnEnter"):GetComponent("Button")
    -- self.PanelAutoFightButton = self.Transform:Find("SafeAreaContentPane/PanelDetail/PanelBottom/PanelAutoFightButton")
    -- self.BtnEnterB = self.Transform:Find("SafeAreaContentPane/PanelDetail/PanelBottom/PanelAutoFightButton/BtnEnterB"):GetComponent("Button")
    -- self.BtnAutoFight = self.Transform:Find("SafeAreaContentPane/PanelDetail/PanelBottom/PanelAutoFightButton/BtnAutoFight"):GetComponent("Button")
    -- self.ImgAutoFighting = self.Transform:Find("SafeAreaContentPane/PanelDetail/PanelBottom/PanelAutoFightButton/ImgAutoFighting"):GetComponent("Image")
    -- self.BtnAutoFightComplete = self.Transform:Find("SafeAreaContentPane/PanelDetail/PanelBottom/PanelAutoFightButton/BtnAutoFightComplete"):GetComponent("Button")
end

function XUiFubenMainLineDetail:AutoAddListener()
    self:RegisterClickEvent(self.BtnAddNum, self.OnBtnAddNumClick)
    self:RegisterClickEvent(self.BtnEnter, self.OnBtnEnterClick)
    self:RegisterClickEvent(self.BtnEnterB, self.OnBtnEnterBClick)
    self:RegisterClickEvent(self.BtnAutoFight, self.OnBtnAutoFightClick)
    self:RegisterClickEvent(self.BtnAutoFightComplete, self.OnBtnAutoFightCompleteClick)
end
-- auto
function XUiFubenMainLineDetail:OnBtnEnterBClick(eventData)
    self:OnBtnEnterClick(eventData)
end

function XUiFubenMainLineDetail:OnBtnAutoFightClick(eventData)
    XLuaUiManager.Open("UiAutoFightDialog", self.Stage.StageId)
end

function XUiFubenMainLineDetail:OnBtnAutoFightCompleteClick(eventData)
    local index = XDataCenter.AutoFightManager.GetIndexByStageId(self.Stage.StageId)
    XDataCenter.AutoFightManager.ObtainRewards(index)
end

function XUiFubenMainLineDetail:OnBtnCloseClick(eventData)
    self:Hide()
end

function XUiFubenMainLineDetail:OnBtnAddNumClick(eventData)
    local challegeData = XDataCenter.FubenMainLineManager.GetStageBuyChallegeData(self.Stage.StageId)
    XLuaUiManager.Open("UiBuyAsset", 1, function()
        self:UpdateCommon()
    end, challegeData)
end

function XUiFubenMainLineDetail:OnBtnClickClick(eventData)

end

function XUiFubenMainLineDetail:OnBtnEnterClick(eventData)
    if self.IsPlaying then
        return
    end

    if self.Stage == nil then
        XLog.Error("XUiFubenMainLineDetail.OnBtnEnterClick: Can not find stage!")
        return
    end

    CsXGameEventManager.Instance:Notify(XEventId.EVENT_FUBEN_ENTERFIGHT, self.Stage)
end

function XUiFubenMainLineDetail:Hide()
    if self.IsPlaying or not self.IsOpen then
        return
    end

    self.IsPlaying = true
    self:PlayAnimation("AnimEnd", handler(self, function()
        if XTool.UObjIsNil(self.GameObject) then
            return
        end
        self.IsPlaying = false
        self:Close()
    end))
    CsXGameEventManager.Instance:Notify(XEventId.EVENT_FUBEN_CLOSE_FUBENSTAGEDETAIL)
end

function XUiFubenMainLineDetail:Refresh(stage)
    self.Stage = stage or self.Stage
    self:UpdateCommon()
    self:UpdateRewards()
    self:UpdateDifficulty()
    self:UpdateStageFightControl()--更新战力限制提示
end

function XUiFubenMainLineDetail:UpdateCommon()
    local stageCfg = XDataCenter.FubenManager.GetStageCfg(self.Stage.StageId)
    local stageInfo = XDataCenter.FubenManager.GetStageInfo(self.Stage.StageId)
    local chapterOrderId = XDataCenter.FubenMainLineManager.GetChapterOrderIdByStageId(self.Stage.StageId)
    self.TxtTitle.text = chapterOrderId .. "-" .. stageInfo.OrderId .. self.Stage.Name
    self.TxtDesc.text = self.Stage.Description
    self.TxtATNums.text = self.Stage.RequireActionPoint

    local maxChallengeNum = XDataCenter.FubenManager.GetStageMaxChallengeNums(self.Stage.StageId)
    local buyChallengeCount = XDataCenter.FubenManager.GetStageBuyChallengeCount(self.Stage.StageId)

    self.PanelNums.gameObject:SetActive(maxChallengeNum > 0)
    self.PanelNoLimitCount.gameObject:SetActive(maxChallengeNum <= 0)
    self.BtnAddNum.gameObject:SetActive(buyChallengeCount > 0)
    local showAutoFightBtn = false
    if stageCfg.AutoFightId > 0 then
        local record = XDataCenter.AutoFightManager.GetRecordByStageId(self.Stage.StageId)
        if record then
            local now = XTime.GetServerNowTimestamp()
            if now >= record.CompleteTime then
                self:SetAutoFightState(XDataCenter.AutoFightManager.State.Complete)
            else
                self:SetAutoFightState(XDataCenter.AutoFightManager.State.Fighting)
            end
            showAutoFightBtn = true
        else
            local autoFightAvailable = XDataCenter.AutoFightManager.CheckAutoFightAvailable(self.Stage.StageId) == XCode.Success
            if autoFightAvailable then
                self:SetAutoFightState(XDataCenter.AutoFightManager.State.None)
                showAutoFightBtn = true
            end
        end
    end
    self:SetAutoFightActive(showAutoFightBtn)

    if maxChallengeNum > 0 then
        local stageData = XDataCenter.FubenManager.GetStageData(self.Stage.StageId)
        local chanllengeNum = stageData and stageData.PassTimesToday or 0
        self.TxtAllNums.text = "/" .. maxChallengeNum
        self.TxtLeftNums.text = maxChallengeNum - chanllengeNum
    end

    local firstDrop = false
    if not stageInfo.Passed then
        local cfg = XDataCenter.FubenManager.GetStageLevelControl(self.Stage.StageId)
        if cfg and cfg.FirstRewardShow > 0 or self.Stage.FirstRewardShow > 0 then
            firstDrop = true
        end
    end
    self.TxtFirstDrop.gameObject:SetActive(firstDrop)
    self.TxtDrop.gameObject:SetActive(not firstDrop)

    for i = 1, 3 do
        self.GridStarList[i]:Refresh(self.Stage.StarDesc[i], stageInfo.StarsMap[i])
    end
end

function XUiFubenMainLineDetail:UpdateDifficulty()
    local nanDuIcon = XDataCenter.FubenManager.GetDiccicultIcon(self.Stage.StageId)
    --赏金任务
    local IsBountyTaskPreFight, task = XDataCenter.BountyTaskManager.CheckBountyTaskPreFight(self.Stage.StageId)
    if IsBountyTaskPreFight then
        local config = XDataCenter.BountyTaskManager.GetBountyTaskConfig(task.Id)
        nanDuIcon = config.StageIcon
    end
    self.RImgNandu:SetRawImage(nanDuIcon)
end

function XUiFubenMainLineDetail:UpdateRewards()
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

function XUiFubenMainLineDetail:UpdateStageFightControl()
    local stageInfo = XDataCenter.FubenManager.GetStageInfo(self.Stage.StageId)
    if self.StageFightControl == nil then
        self.StageFightControl = XUiStageFightControl.New(self.PanelStageFightControl, self.Stage.FightControlId)
    end
    if not stageInfo.Passed and stageInfo.Unlock then
        self.StageFightControl.GameObject:SetActive(true)
        self.StageFightControl:UpdateInfo(self.Stage.FightControlId)
    else
        self.StageFightControl.GameObject:SetActive(false)
    end
end

function XUiFubenMainLineDetail:SetAutoFightActive(value)
    self.PanelAutoFightButton.gameObject:SetActive(value)
    self.BtnEnter.gameObject:SetActive(not value)
end

function XUiFubenMainLineDetail:SetAutoFightState(value)
    local state = XDataCenter.AutoFightManager.State
    self.BtnAutoFight.gameObject:SetActive(value == state.None)
    self.ImgAutoFighting.gameObject:SetActive(value == state.Fighting)
    self.BtnAutoFightComplete.gameObject:SetActive(value == state.Complete)
end

function XUiFubenMainLineDetail:OnAutoFightStart(stageId)
    if self.Stage.StageId == stageId then
        self.ParentUi:CloseStageDetail()
    end
end

function XUiFubenMainLineDetail:OnAutoFightRemove(stageId)
    if self.Stage.StageId == stageId then
        self:SetAutoFightState(XDataCenter.AutoFightManager.State.None)
    end
end

function XUiFubenMainLineDetail:OnAutoFightComplete(stageId)
    if self.Stage.StageId == stageId then
        self:SetAutoFightState(XDataCenter.AutoFightManager.State.Complete)
    end
end

function XUiFubenMainLineDetail:AddEventListener()
    XEventManager.AddEventListener(XEventId.EVENT_AUTO_FIGHT_START, self.OnAutoFightStart, self)
    XEventManager.AddEventListener(XEventId.EVENT_AUTO_FIGHT_REMOVE, self.OnAutoFightRemove, self)
    XEventManager.AddEventListener(XEventId.EVENT_AUTO_FIGHT_COMPLETE, self.OnAutoFightComplete, self)
end

function XUiFubenMainLineDetail:RemoveEventListener()
    XEventManager.RemoveEventListener(XEventId.EVENT_AUTO_FIGHT_START, self.OnAutoFightStart, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_AUTO_FIGHT_REMOVE, self.OnAutoFightRemove, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_AUTO_FIGHT_COMPLETE, self.OnAutoFightComplete, self)
end