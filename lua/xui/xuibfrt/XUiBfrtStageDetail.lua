local XUiBfrtStageDetail = XLuaUiManager.Register(XLuaUi, "UiBfrtStageDetail")

local MAX_STAR = 3
local ANIMATION_OPEN = "UiBfrtStageDetailBegin"
local ANIMATION_END = "UiBfrtStageDetailEnd"

function XUiBfrtStageDetail:OnAwake()
    self:InitAutoScript()

    self.GridCommon.gameObject:SetActive(false)
    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.FreeGem, XDataCenter.ItemManager.ItemId.ActionPoint, XDataCenter.ItemManager.ItemId.Coin)
end

function XUiBfrtStageDetail:OnStart(fubenMainLineChapter)
    self.FubenMainLineChapter = fubenMainLineChapter
    self.GridList = {}
    
end

function XUiBfrtStageDetail:OnEnable()
    self:Refresh()

    -- 动画
    self.IsPlaying = true
    XUiHelper.StopAnimation()

    self:PlayAnimation(ANIMATION_OPEN, handler(self, function()
        self.IsPlaying = false
    end))

    -- XUiHelper.PlayAnimation(self, ANIMATION_OPEN, nil, handler(self, function()
    --     self.IsPlaying = false
    -- end))

    self.IsOpen = true
end

function XUiBfrtStageDetail:OnDisable()
    self.IsOpen = false
end

function XUiBfrtStageDetail:Refresh()
    self.ChapterOrderId = self.FubenMainLineChapter.ChapterOrderId
    self.Stage = self.FubenMainLineChapter.Stage
    self.BaseStageId = self.Stage.StageId
    self.StageInfo = XDataCenter.FubenManager.GetStageInfo(self.BaseStageId)
    self.IsPassed = XDataCenter.FubenManager.CheckStageIsPass(self.BaseStageId)
    self:UpdatePanelTargetList()
    self:UpdateRewards()
    self:UpdateDetailText()
    self:UpdateDifficulty()
    self:UpdateStageFightControl()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiBfrtStageDetail:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiBfrtStageDetail:AutoInitUi()
    self.Panellist = self.Transform:Find("SafeAreaContentPane/Panellist")
    self.PanelDropList = self.Transform:Find("SafeAreaContentPane/Panellist/PanelDropList")
    self.PanelDrop = self.Transform:Find("SafeAreaContentPane/Panellist/PanelDropList/PanelDrop")
    self.TxtDrop = self.Transform:Find("SafeAreaContentPane/Panellist/PanelDropList/PanelDrop/TxtDrop"):GetComponent("Text")
    self.TxtDropEn = self.Transform:Find("SafeAreaContentPane/Panellist/PanelDropList/PanelDrop/TxtDropEn"):GetComponent("Text")
    self.TxtFirstDrop = self.Transform:Find("SafeAreaContentPane/Panellist/PanelDropList/PanelDrop/TxtFirstDrop"):GetComponent("Text")
    self.PanelDropContent = self.Transform:Find("SafeAreaContentPane/Panellist/PanelDropList/DropList/Viewport/PanelDropContent")
    self.GridCommon = self.Transform:Find("SafeAreaContentPane/Panellist/PanelDropList/DropList/Viewport/PanelDropContent/GridCommon")
    self.PanelNoLimitCount = self.Transform:Find("SafeAreaContentPane/Panellist/PanelNoLimitCount")
    self.PanelNums = self.Transform:Find("SafeAreaContentPane/Panellist/PanelNums")
    self.TxtAllNums = self.Transform:Find("SafeAreaContentPane/Panellist/PanelNums/TxtAllNums"):GetComponent("Text")
    self.TxtLeftNums = self.Transform:Find("SafeAreaContentPane/Panellist/PanelNums/TxtLeftNums"):GetComponent("Text")
    self.BtnAddNum = self.Transform:Find("SafeAreaContentPane/Panellist/PanelNums/BtnAddNum"):GetComponent("Button")
    self.PanelBottom = self.Transform:Find("SafeAreaContentPane/Panellist/PanelBottom")
    self.TxtATNums = self.Transform:Find("SafeAreaContentPane/Panellist/PanelBottom/TxtATNums"):GetComponent("Text")
    self.BtnEnter = self.Transform:Find("SafeAreaContentPane/Panellist/PanelBottom/BtnEnter"):GetComponent("Button")
    self.PanelDesc = self.Transform:Find("SafeAreaContentPane/Panellist/PanelDesc")
    self.TxtTitle = self.Transform:Find("SafeAreaContentPane/Panellist/PanelDesc/TxtTitle"):GetComponent("Text")
    self.TxtLevelVal = self.Transform:Find("SafeAreaContentPane/Panellist/PanelDesc/TxtLevelVal"):GetComponent("Text")
    self.RImgNandu = self.Transform:Find("SafeAreaContentPane/Panellist/PanelDesc/RImgNandu"):GetComponent("RawImage")
    self.TxtDesc = self.Transform:Find("SafeAreaContentPane/Panellist/PanelDesc/TxtDesc"):GetComponent("Text")
    self.PanelTargetList = self.Transform:Find("SafeAreaContentPane/Panellist/PanelTargetList")
    self.GridStar1 = self.Transform:Find("SafeAreaContentPane/Panellist/PanelTargetList/GridStar1")
    self.TxtStarActive1 = self.Transform:Find("SafeAreaContentPane/Panellist/PanelTargetList/GridStar1/TxtStarActive1"):GetComponent("Text")
    self.GridStar2 = self.Transform:Find("SafeAreaContentPane/Panellist/PanelTargetList/GridStar2")
    self.TxtStarActive2 = self.Transform:Find("SafeAreaContentPane/Panellist/PanelTargetList/GridStar2/TxtStarActive2"):GetComponent("Text")
    self.GridStar3 = self.Transform:Find("SafeAreaContentPane/Panellist/PanelTargetList/GridStar3")
    self.TxtStarActive3 = self.Transform:Find("SafeAreaContentPane/Panellist/PanelTargetList/GridStar3/TxtStarActive3"):GetComponent("Text")
    self.PanelAsset = self.Transform:Find("SafeAreaContentPane/PanelAsset")
end

function XUiBfrtStageDetail:AutoAddListener()
    self:RegisterClickEvent(self.BtnAddNum, self.OnBtnAddNumClick)
    self:RegisterClickEvent(self.BtnEnter, self.OnBtnEnterClick)
end
-- auto
--初始化音效
function XUiBfrtStageDetail:OnBtnAddNumClick(...)
    local challegeData = XDataCenter.FubenMainLineManager.GetStageBuyChallegeData(self.BaseStageId)
    local func = function()
        self:UpdateDetailText()
    end
    XLuaUiManager.Open("UiBuyAsset", 1, func, challegeData)
end

function XUiBfrtStageDetail:OnBtnEnterClick(...)
    if self.IsPlaying then
        return
    end

    if self.BaseStageId == nil then
        XLog.Error("OnBtnEnterClick: Can not find baseStageId!")
        return
    end

    CsXGameEventManager.Instance:Notify(XEventId.EVENT_FUBEN_ENTERFIGHT, self.Stage)
end

function XUiBfrtStageDetail:UpdatePanelTargetList()
    for i = 1, MAX_STAR do
        self["TxtStarActive" .. i].text = self.Stage.StarDesc[i]
    end
end

function XUiBfrtStageDetail:UpdateRewards()
    local rewardId = 0
    local IsFirst = false
    local cfg = XDataCenter.FubenManager.GetStageLevelControl(self.BaseStageId)
    if self.IsPassed then
        rewardId = cfg and cfg.FinishRewardShow or self.Stage.FinishRewardShow
    else
        rewardId = cfg and cfg.FirstRewardShow or self.Stage.FirstRewardShow
        IsFirst = true
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

function XUiBfrtStageDetail:UpdateDetailText()
    local id = ""
    if self.ChapterOrderId then
        id = self.ChapterOrderId .. "-" .. XDataCenter.BfrtManager.GetGroupOrderIdByStageId(self.BaseStageId)
    end

    self.TxtTitle.text = id .. self.Stage.Name
    self.TxtLevelVal.text = self.Stage.RecommandLevel
    self.TxtDesc.text = self.Stage.Description
    self.TxtATNums.text = self.Stage.RequireActionPoint

    local chanllengeNum = XDataCenter.BfrtManager.GetGroupFinishCount(self.BaseStageId)
    local maxChallengeNum = XDataCenter.BfrtManager.GetGroupMaxChallengeNum(self.BaseStageId)
    local buyChallengeCount = XDataCenter.FubenManager.GetStageBuyChallengeCount(self.BaseStageId)

    self.PanelNums.gameObject:SetActive(maxChallengeNum > 0)
    self.PanelNoLimitCount.gameObject:SetActive(maxChallengeNum <= 0)
    self.BtnAddNum.gameObject:SetActive(buyChallengeCount > 0)

    if maxChallengeNum > 0 then
        self.TxtAllNums.text = "/" .. maxChallengeNum
        self.TxtLeftNums.text = maxChallengeNum - chanllengeNum
    end

    self.TxtFirstDrop.gameObject:SetActive(not self.IsPassed)
    self.TxtDrop.gameObject:SetActive(self.IsPassed)
end

function XUiBfrtStageDetail:UpdateDifficulty()
    local nanDuIcon = XDataCenter.FubenManager.GetDiccicultIcon(self.BaseStageId)
    self.RImgNandu:SetRawImage(nanDuIcon)
end

function XUiBfrtStageDetail:UpdateStageFightControl()
    --暂时屏蔽，后面可能要加回来
    if true then
        self.PanelStageFightControl.gameObject:SetActive(false)
        return
    end

    local stageInfo = self.StageInfo
    self.StageFightControl = self.StageFightControl or XUiStageFightControl.New(self.PanelStageFightControl, self.Stage.FightControlId)

    if not self.IsPassed and stageInfo.Unlock then
        self.StageFightControl.GameObject:SetActive(true)
        self.StageFightControl:UpdateInfo(self.Stage.FightControlId)
    else
        self.StageFightControl.GameObject:SetActive(false)
    end
end

function XUiBfrtStageDetail:Hide()
    if self.IsPlaying or not self.IsOpen then
        return
    end

    self.IsPlaying = true
    XUiHelper.StopAnimation()

    self:PlayAnimation(ANIMATION_END, handler(self, function()
        if XTool.UObjIsNil(self.GameObject) then
            return
        end
        self.IsPlaying = false
        self:Close()
    end))
    
    -- XUiHelper.PlayAnimation(self, ANIMATION_END, nil, handler(self, function()
    --     if XTool.UObjIsNil(self.GameObject) then
    --         return
    --     end
    --     self.IsPlaying = false
    --     self:Close()
    -- end))
    CsXGameEventManager.Instance:Notify(XEventId.EVENT_FUBEN_CLOSE_FUBENSTAGEDETAIL)
end