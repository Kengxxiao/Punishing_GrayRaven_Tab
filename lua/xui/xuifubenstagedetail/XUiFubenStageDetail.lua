local XUiFubenStageDetail = XLuaUiManager.Register(XLuaUi, "UiFubenStageDetail")

local MAX_STAR = 3
local ANIMATION_OPEN = "AniFubenStageDetail"
local ANIMATION_END = "AniFubenStageDetailEnd"

function XUiFubenStageDetail:OnAwake()
    self:InitAutoScript()
end

function XUiFubenStageDetail:OnStart(stage,cb)
    if cb then
        self.CallBack = cb
    end
    self.Stage = stage
    self.StarGridList = {}
    self.GridList = {}
    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.FreeGem, XDataCenter.ItemManager.ItemId.ActionPoint, XDataCenter.ItemManager.ItemId.Coin)
end

function XUiFubenStageDetail:OnEnable()
    -- self.ChapterOrderId = self.FubenMainLineChapter.ChapterOrderId
    self.IsShow = true
    self.IsPlaying = false
    self.StarItemsList = { self.GridStar1, self.GridStar2, self.GridStar3 }
    self.GridCommonItem = self.Transform:Find("SafeAreaContentPane/PanelDropList/DropList/Viewport/PanelDropContent/GridCommon")
    self.GridCommonItem.gameObject:SetActive(false)

    self:PlayAnimation(ANIMATION_OPEN)
    --XUiHelper.PlayAnimation(self, ANIMATION_OPEN)

    self:UpdatePanelTargetList()
    self:UpdateRewards()
    self:UpdateDetailText()
    self:UpdateDifficulty()
    self:UpdateStageFightControl()--更新战力限制提示
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiFubenStageDetail:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiFubenStageDetail:AutoInitUi()
    self.PanelNoLimitCount = self.Transform:Find("SafeAreaContentPane/PanelNoLimitCount")
    self.PanelTargetList = self.Transform:Find("SafeAreaContentPane/PanelTargetList")
    self.GridStar3 = self.Transform:Find("SafeAreaContentPane/PanelTargetList/GridStar3")
    self.ImgStarB = self.Transform:Find("SafeAreaContentPane/PanelTargetList/GridStar3/ImgStar"):GetComponent("Image")
    self.GridStar2 = self.Transform:Find("SafeAreaContentPane/PanelTargetList/GridStar2")
    self.ImgStarA = self.Transform:Find("SafeAreaContentPane/PanelTargetList/GridStar2/ImgStar"):GetComponent("Image")
    self.TxtStarActiveB = self.Transform:Find("SafeAreaContentPane/PanelTargetList/GridStar2/TxtStarActive"):GetComponent("Text")
    self.GridStar1 = self.Transform:Find("SafeAreaContentPane/PanelTargetList/GridStar1")
    self.ImgStar = self.Transform:Find("SafeAreaContentPane/PanelTargetList/GridStar1/ImgStar"):GetComponent("Image")
    self.PanelDropList = self.Transform:Find("SafeAreaContentPane/PanelDropList")
    self.PanelDrop = self.Transform:Find("SafeAreaContentPane/PanelDropList/PanelDrop")
    self.TxtDrop = self.Transform:Find("SafeAreaContentPane/PanelDropList/PanelDrop/TxtDrop"):GetComponent("Text")
    self.TxtDropEn = self.Transform:Find("SafeAreaContentPane/PanelDropList/PanelDrop/TxtDropEn"):GetComponent("Text")
    self.TxtFirstDrop = self.Transform:Find("SafeAreaContentPane/PanelDropList/PanelDrop/TxtFirstDrop"):GetComponent("Text")
    self.PanelDropContent = self.Transform:Find("SafeAreaContentPane/PanelDropList/DropList/Viewport/PanelDropContent")
    self.PanelNums = self.Transform:Find("SafeAreaContentPane/PanelNums")
    self.TxtAllNums = self.Transform:Find("SafeAreaContentPane/PanelNums/TxtAllNums"):GetComponent("Text")
    self.BtnAddNum = self.Transform:Find("SafeAreaContentPane/PanelNums/BtnAddNum"):GetComponent("Button")
    self.TxtLeftNums = self.Transform:Find("SafeAreaContentPane/PanelNums/TxtLeftNums"):GetComponent("Text")
    self.PanelDesc = self.Transform:Find("SafeAreaContentPane/PanelDesc")
    self.RImgNandu = self.Transform:Find("SafeAreaContentPane/PanelDesc/RImgNandu"):GetComponent("RawImage")
    self.TxtTitle = self.Transform:Find("SafeAreaContentPane/PanelDesc/TxtTitle"):GetComponent("Text")
    self.TxtLevelVal = self.Transform:Find("SafeAreaContentPane/PanelDesc/TxtLevelVal"):GetComponent("Text")
    self.TxtDesc = self.Transform:Find("SafeAreaContentPane/PanelDesc/TxtDesc"):GetComponent("Text")
    self.PanelBottom = self.Transform:Find("SafeAreaContentPane/PanelBottom")
    self.TxtATNums = self.Transform:Find("SafeAreaContentPane/PanelBottom/TxtATNums"):GetComponent("Text")
    self.BtnEnter = self.Transform:Find("SafeAreaContentPane/PanelBottom/BtnEnter"):GetComponent("Button")
    self.PanelAsset = self.Transform:Find("SafeAreaContentPane/PanelAsset")
    self.BtnClose = self.Transform:Find("SafeAreaContentPane/BtnClose"):GetComponent("Button")
end

function XUiFubenStageDetail:AutoAddListener()
    self:RegisterClickEvent(self.BtnAddNum, self.OnBtnAddNumClick)
    self:RegisterClickEvent(self.BtnEnter, self.OnBtnEnterClick)
    self:RegisterClickEvent(self.BtnClose, self.OnBtnCloseClick)
end
-- auto
--初始化音效
function XUiFubenStageDetail:OnBtnCloseClick(...)
    if self.IsPlaying then
        return
    end
    CsXGameEventManager.Instance:Notify(XEventId.EVENT_FUBEN_CLOSE_FUBENSTAGEDETAIL)
    self:PlayHideAnimation()
    if self.CallBack then
        self.CallBack()
    end
end

function XUiFubenStageDetail:OnBtnAddNumClick()
    local challegeData = XDataCenter.FubenMainLineManager.GetStageBuyChallegeData(self.Stage.StageId)
    local func = function()
        self:UpdateDetailText()
    end
    --CS.XUiManager.ViewManager:Push("UiBuyAsset", true, false, 1, func, challegeData)
    XLuaUiManager.Open("UiBuyAsset", 1, func, challegeData)
end

function XUiFubenStageDetail:OnBtnEnterClick()
    if self.IsPlaying then
        return
    end

    if self.Stage == nil then
        XLog.Error("OnBtnEnterClick: Can not find stage!")
        return
    end

    CsXGameEventManager.Instance:Notify(XEventId.EVENT_FUBEN_ENTERFIGHT, self.Stage)
end

function XUiFubenStageDetail:UpdatePanelTargetList()
    local stage = self.Stage
    for i = 1, MAX_STAR do
        local grid = self.StarGridList[i]
        if not grid then
            local item = self.StarItemsList[i]
            grid = XUiGridFubenStageDetailStar.New(item)
            self.StarGridList[i] = grid
        end
        grid:Refresh(stage.StarDesc[i])
    end
end

function XUiFubenStageDetail:UpdateRewards()
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
                local ui = CS.UnityEngine.Object.Instantiate(self.GridCommonItem)
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

function XUiFubenStageDetail:UpdateDetailText()
    self.TxtTitle.text = self.Stage.Name
    self.TxtLevelVal.text = self.Stage.RecommandLevel
    self.TxtDesc.text = self.Stage.Description
    self.TxtATNums.text = XDataCenter.FubenManager.GetStageActionPointConsume(self.Stage.StageId)
    self.PanelNums.gameObject:SetActive(false)
    self.PanelNoLimitCount.gameObject:SetActive(true)
    
    local stageData = XDataCenter.FubenManager.GetStageData(self.Stage.StageId)
    local stageInfo = XDataCenter.FubenManager.GetStageInfo(self.Stage.StageId)
    
    -- 是否首通奖励显示
    local firstDrop = false
    if not stageInfo.Passed then
        local cfg = XDataCenter.FubenManager.GetStageLevelControl(self.Stage.StageId)
        if cfg and cfg.FirstRewardShow > 0 or self.Stage.FirstRewardShow > 0 then
            firstDrop = true
        end
    end
    self.TxtFirstDrop.gameObject:SetActive(firstDrop)
    self.TxtDrop.gameObject:SetActive(not firstDrop)
end


function XUiFubenStageDetail:OldUpdateDetailText()
    local id = ""
    if self.ChapterOrderId then
        id = self.ChapterOrderId .. "-" .. self.Stage.OrderId
    end

    self.TxtTitle.text = id .. self.Stage.Name
    self.TxtLevelVal.text = self.Stage.RecommandLevel
    self.TxtDesc.text = self.Stage.Description
    self.TxtATNums.text = XDataCenter.FubenManager.GetStageActionPointConsume(self.Stage.StageId)

    local stageData = XDataCenter.FubenManager.GetStageData(self.Stage.StageId)
    local stageInfo = XDataCenter.FubenManager.GetStageInfo(self.Stage.StageId)

    if stageInfo.Type == XDataCenter.FubenManager.StageType.Mainline then
        local chanllengeNum = stageData and stageData.PassTimesToday or 0
        self.PanelNums.gameObject:SetActive(self.Stage.MaxChallengeNums > 0)
        self.PanelNoLimitCount.gameObject:SetActive(self.Stage.MaxChallengeNums <= 0)

        if self.Stage.MaxChallengeNums > 0 then
            self.TxtAllNums.text = "/" .. self.Stage.MaxChallengeNums
            self.TxtLeftNums.text = self.Stage.MaxChallengeNums - chanllengeNum
        end
    elseif stageInfo.Type == XDataCenter.FubenManager.StageType.Daily then
        local sectionCfg = XDataCenter.FubenDailyManager.GetDailySection(stageInfo.DailySectionId)
        local sectionData = XDataCenter.FubenDailyManager.GetDailySectionData(stageInfo.DailySectionId)
        local chanllengeNum = sectionData and sectionData.PassTimesToday or 0
        self.PanelNums.gameObject:SetActive(sectionCfg.DefaultChallengeCount > 0)
        self.PanelNoLimitCount.gameObject:SetActive(sectionCfg.DefaultChallengeCount <= 0)

        self.BtnAddNum.gameObject:SetActive(false)
        if sectionCfg.DefaultChallengeCount > 0 then
            self.TxtAllNums.text = "/" .. sectionCfg.DefaultChallengeCount
            self.TxtLeftNums.text = sectionCfg.DefaultChallengeCount - chanllengeNum
        end
    elseif stageInfo.Type == XDataCenter.FubenManager.StageType.Activity then
    elseif stageInfo.Type == XDataCenter.FubenManager.StageType.Resource then
        self.PanelNoLimitCount.gameObject:SetActive(false)
        self.BtnAddNum.gameObject:SetActive(false)
        local leftNum = XDataCenter.FubenResourceManager.GetSectionDataByTypeId(stageInfo.ResourceType).LeftCount
        self.TxtAllNums.text = "/" .. XDataCenter.FubenResourceManager.GetSectionDataByTypeId(stageInfo.ResourceType).MaxCount
        self.TxtLeftNums.text = leftNum
    elseif stageInfo.Type == XDataCenter.FubenManager.StageType.Urgent then
        self.PanelNums.gameObject:SetActive(false)
        self.PanelNoLimitCount.gameObject:SetActive(true)
    end

    -- 是否首通奖励显示
    local firstDrop = false
    if not stageInfo.Passed then
        local cfg = XDataCenter.FubenManager.GetStageLevelControl(self.Stage.StageId)
        if cfg and cfg.FirstRewardShow > 0 or self.Stage.FirstRewardShow > 0 then
            firstDrop = true
        end
    end
    self.TxtFirstDrop.gameObject:SetActive(firstDrop)
    self.TxtDrop.gameObject:SetActive(not firstDrop)
end

function XUiFubenStageDetail:UpdateDifficulty()
    local nanDuIcon = XDataCenter.FubenManager.GetDiccicultIcon(self.Stage.StageId)
    self.RImgNandu:SetRawImage(nanDuIcon)
end

function XUiFubenStageDetail:UpdateStageFightControl()
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

function XUiFubenStageDetail:HideEnterBtn()
    if self.BtnEnter then
        self.BtnEnter.gameObject:SetActive(false)
    end
end

function XUiFubenStageDetail:ShowEnterBtn()
    if self.BtnEnter then
        self.BtnEnter.gameObject:SetActive(true)
    end
end

function XUiFubenStageDetail:PlayHideAnimation(callback)
    XUiHelper.StopAnimation()
    self.IsPlaying = true

    local End = function()
        if XTool.UObjIsNil(self.GameObject) then
            return
        end

        self.IsShow = false
        self.IsPlaying = false

        self:Close()

        if callback then
            callback(self)
        end
    end

    self:PlayAnimation(ANIMATION_END, End)
    --XUiHelper.PlayAnimation(self, ANIMATION_END, nil, End)
end

function XUiFubenStageDetail:ActiveSelf()
    return self.IsShow
end