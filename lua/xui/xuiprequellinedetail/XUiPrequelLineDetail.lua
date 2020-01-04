local XUiPrequelLineDetail = XLuaUiManager.Register(XLuaUi, "UiPrequelLineDetail")

local PANELPREQUELDETAILEND = "PanelPrequelDetailEnd"
local PANELPREQUELDETAILBEGIN = "PanelPrequelDetailBegin"

function XUiPrequelLineDetail:OnAwake()
    self:InitAutoScript()
    self.StartGridList = {}
    self.GridList = {}
    self.GridCommon.gameObject:SetActive(false)
    self:InitStarPanels()

    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.FreeGem, XDataCenter.ItemManager.ItemId.ActionPoint, XDataCenter.ItemManager.ItemId.Coin)
    self.BtnMask.gameObject:SetActive(false)
end

function XUiPrequelLineDetail:InitStarPanels()
    self.GridStarList = {}
    for i = 1, 3 do
        local ui = self.Transform:Find(string.format("SafeAreaContentPane/PanelPrequelDetail/PanelTargetList/GridStageStar%d", i))
        ui.gameObject:SetActive(true)
        local grid = XUiGridStageStar.New(ui)
        self.GridStarList[i] = grid
    end
end


function XUiPrequelLineDetail:OnStart()

end

function XUiPrequelLineDetail:Refresh(stage)
    self.PrequelStage = stage
    XUiHelper.PlayAnimation(self, PANELPREQUELDETAILBEGIN, function()
        self:RefreshDetail(self.PrequelStage)
    end, nil)
end


function XUiPrequelLineDetail:OnEnable()
    self:AddListeners()
end


function XUiPrequelLineDetail:OnDisable()
    self:RemoveListeners()
end


function XUiPrequelLineDetail:OnDestroy()
end


function XUiPrequelLineDetail:OnGetEvents()
    return nil
end


function XUiPrequelLineDetail:OnNotify(evt, ...)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPrequelLineDetail:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiPrequelLineDetail:AutoInitUi()
    self.PanelPrequelDetail = self.Transform:Find("SafeAreaContentPane/PanelPrequelDetail")
    self.PanelAsset = self.Transform:Find("SafeAreaContentPane/PanelPrequelDetail/PanelAsset")
    self.PanelNums = self.Transform:Find("SafeAreaContentPane/PanelPrequelDetail/PanelNums")
    self.TxtAllNums = self.Transform:Find("SafeAreaContentPane/PanelPrequelDetail/PanelNums/TxtAllNums"):GetComponent("Text")
    self.TxtLeftNums = self.Transform:Find("SafeAreaContentPane/PanelPrequelDetail/PanelNums/TxtLeftNums"):GetComponent("Text")
    self.BtnAddNum = self.Transform:Find("SafeAreaContentPane/PanelPrequelDetail/PanelNums/BtnAddNum"):GetComponent("Button")
    self.PanelDesc = self.Transform:Find("SafeAreaContentPane/PanelPrequelDetail/PanelDesc")
    self.TxtTitle = self.Transform:Find("SafeAreaContentPane/PanelPrequelDetail/PanelDesc/TxtTitle"):GetComponent("Text")
    self.TxtLevelVal = self.Transform:Find("SafeAreaContentPane/PanelPrequelDetail/PanelDesc/TxtLevelVal"):GetComponent("Text")
    self.RImgNandu = self.Transform:Find("SafeAreaContentPane/PanelPrequelDetail/PanelDesc/RImgNandu"):GetComponent("RawImage")
    self.TxtDesc = self.Transform:Find("SafeAreaContentPane/PanelPrequelDetail/PanelDesc/TxtDesc"):GetComponent("Text")
    self.PanelNoLimitCount = self.Transform:Find("SafeAreaContentPane/PanelPrequelDetail/PanelNoLimitCount")
    self.PanelTargetList = self.Transform:Find("SafeAreaContentPane/PanelPrequelDetail/PanelTargetList")
    self.GridStageStar = self.Transform:Find("SafeAreaContentPane/PanelPrequelDetail/PanelTargetList/GridStageStar")
    self.PanelDropList = self.Transform:Find("SafeAreaContentPane/PanelPrequelDetail/PanelDropList")
    self.PanelDrop = self.Transform:Find("SafeAreaContentPane/PanelPrequelDetail/PanelDropList/PanelDrop")
    self.TxtDrop = self.Transform:Find("SafeAreaContentPane/PanelPrequelDetail/PanelDropList/PanelDrop/TxtDrop"):GetComponent("Text")
    self.TxtDropEn = self.Transform:Find("SafeAreaContentPane/PanelPrequelDetail/PanelDropList/PanelDrop/TxtDropEn"):GetComponent("Text")
    self.TxtFirstDrop = self.Transform:Find("SafeAreaContentPane/PanelPrequelDetail/PanelDropList/PanelDrop/TxtFirstDrop"):GetComponent("Text")
    self.PanelDropContent = self.Transform:Find("SafeAreaContentPane/PanelPrequelDetail/PanelDropList/DropList/Viewport/PanelDropContent")
    self.GridCommon = self.Transform:Find("SafeAreaContentPane/PanelPrequelDetail/PanelDropList/DropList/Viewport/PanelDropContent/GridCommon")
    self.PanelBottom = self.Transform:Find("SafeAreaContentPane/PanelPrequelDetail/PanelBottom")
    self.TxtATNums = self.Transform:Find("SafeAreaContentPane/PanelPrequelDetail/PanelBottom/TxtATNums"):GetComponent("Text")
    self.BtnEnter = self.Transform:Find("SafeAreaContentPane/PanelPrequelDetail/PanelBottom/BtnEnter"):GetComponent("Button")
    self.PanelAutoFightButton = self.Transform:Find("SafeAreaContentPane/PanelPrequelDetail/PanelBottom/PanelAutoFightButton")
    self.BtnEnterB = self.Transform:Find("SafeAreaContentPane/PanelPrequelDetail/PanelBottom/PanelAutoFightButton/BtnEnterB"):GetComponent("Button")
    self.BtnAutoFight = self.Transform:Find("SafeAreaContentPane/PanelPrequelDetail/PanelBottom/PanelAutoFightButton/BtnAutoFight"):GetComponent("Button")
    self.ImgAutoFighting = self.Transform:Find("SafeAreaContentPane/PanelPrequelDetail/PanelBottom/PanelAutoFightButton/ImgAutoFighting"):GetComponent("Image")
    self.BtnAutoFightComplete = self.Transform:Find("SafeAreaContentPane/PanelPrequelDetail/PanelBottom/PanelAutoFightButton/BtnAutoFightComplete"):GetComponent("Button")
    self.BtnMask = self.Transform:Find("SafeAreaContentPane/BtnMask"):GetComponent("Button")
end

function XUiPrequelLineDetail:AutoAddListener()
    self:RegisterClickEvent(self.BtnAddNum, self.OnBtnAddNumClick)
    self:RegisterClickEvent(self.BtnEnter, self.OnBtnEnterClick)
    self:RegisterClickEvent(self.BtnEnterB, self.OnBtnEnterBClick)
    self:RegisterClickEvent(self.BtnAutoFight, self.OnBtnAutoFightClick)
    self:RegisterClickEvent(self.BtnAutoFightComplete, self.OnBtnAutoFightCompleteClick)
    self:RegisterClickEvent(self.BtnMask, self.OnBtnMaskClick)
end
-- auto
function XUiPrequelLineDetail:OnBtnMaskClick(eventData)
    XUiHelper.PlayAnimation(self, PANELPREQUELDETAILEND, nil, function()
        self:OnPrequelDetailClose()
    end)

end

function XUiPrequelLineDetail:OnPrequelDetailClose()
    XEventManager.DispatchEvent(XEventId.EVENT_NOTICE_PREQUELDETAIL_CLOSE)
    self:Close()
end

function XUiPrequelLineDetail:OnBtnAddNumClick(eventData)

end

function XUiPrequelLineDetail:OnBtnEnterClick(eventData)
    if not self.PrequelStage then
        XLog.Error("XUiPrequelLineDetail:OnBtnEnterClick error: stageId error " .. tostring(self.PrequelStage))
        return
    end
    local stageId = self.PrequelStage
    local stageCfg = XDataCenter.FubenManager.GetStageCfg(stageId)
    if not stageCfg then
        XLog.Error("XUiPrequelLineDetail:OnBtnEnterClick error: stageId error " .. tostring(stageId))
        return
    end

    local csInfo = XDataCenter.PrequelManager.GetUnlockChallengeStagesByStageId(stageId)
    local maxChallengeNum = XDataCenter.FubenManager.GetStageMaxChallengeNums(stageId)
    if csInfo and maxChallengeNum == csInfo.Count then
        XUiManager.TipMsg(CS.XTextManager.GetText("FubenChallengeCountNotEnough"))
        return 
    end

    if XDataCenter.FubenManager.OpenRoomSingle(stageCfg) then
        self:OnPrequelDetailClose()
    end
end

function XUiPrequelLineDetail:OnBtnEnterBClick(eventData)
    self:OnBtnEnterClick(eventData)
end

function XUiPrequelLineDetail:OnBtnAutoFightClick(eventData)
    if self.PrequelStage then
        XLuaUiManager.Open("UiAutoFightDialog", self.PrequelStage)
    end
end

function XUiPrequelLineDetail:OnBtnAutoFightCompleteClick(eventData)
    if self.PrequelStage then
        local index = XDataCenter.AutoFightManager.GetIndexByStageId(self.PrequelStage)
        XDataCenter.AutoFightManager.ObtainRewards(index)
    end
end

function XUiPrequelLineDetail:RefreshDetail(stage)
    local stageId = stage
    local stageCfg = XDataCenter.FubenManager.GetStageCfg(stageId)
    self.TxtTitle.text = stageCfg.Name
    self.TxtLevelVal.text = stageCfg.RecomandLevel or 1
    self.TxtDesc.text = stageCfg.Description
    self.TxtATNums.text = stageCfg.RequireActionPoint

    local stageInfo = XDataCenter.FubenManager.GetStageInfo(stageId)

    local challengeNum = stageData and stageData.PassTimesToday or 0

    local csInfo = XDataCenter.PrequelManager.GetUnlockChallengeStagesByStageId(stageId)
    local maxChallengeNum = XDataCenter.FubenManager.GetStageMaxChallengeNums(stage)

    if csInfo == nil then--剧情支线
        self.PanelNoLimitCount.gameObject:SetActive(maxChallengeNum <= 0)
        self.PanelNums.gameObject:SetActive(maxChallengeNum > 0)
        self.TxtAllNums.text = string.format("/%d", maxChallengeNum)
        self.TxtLeftNums.text = maxChallengeNum
    else--挑战
        self.PanelNoLimitCount.gameObject:SetActive(false)
        self.PanelNums.gameObject:SetActive(true)
        self.TxtAllNums.text = string.format("/%d", maxChallengeNum)
        self.TxtLeftNums.text = maxChallengeNum - csInfo.Count
    end
    self.BtnAddNum.gameObject:SetActive(false)

    for i = 1, 3 do
        self.GridStarList[i]:Refresh(stageCfg.StarDesc[i], stageInfo.StarsMap[i])
    end

    local nanDuIcon = XDataCenter.FubenManager.GetDiccicultIcon(stageId)
    self.RImgNandu:SetRawImage(nanDuIcon)

    self:UpdateRewards()
end

function XUiPrequelLineDetail:UpdateRewards()
    if not self.PrequelStage then return end
    local stageId = self.PrequelStage
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

    local showAutoFightBtn = false
    if stageCfg.AutoFightId > 0 then
        
        local autoFightRecord = XDataCenter.AutoFightManager.GetRecordByStageId(stageId)

        if autoFightRecord then
            local now = XTime.Now()
            if now >= autoFightRecord.CompleteTime then
                self:SetAutoFightStatus(XDataCenter.AutoFightManager.State.Complete)
            else
                self:SetAutoFightStatus(XDataCenter.AutoFightManager.State.Fighting)
            end
            showAutoFightBtn = true
        else
            local autoFightAvaliable = XDataCenter.AutoFightManager.CheckAutoFightAvailable(stageId) == XCode.Success
            if autoFightAvaliable then
                self:SetAutoFightStatus(XDataCenter.AutoFightManager.State.None)
                showAutoFightBtn = true
            end
        end
    end
    self:SetAutoFightActive(showAutoFightBtn)
end

function XUiPrequelLineDetail:SetAutoFightActive(value)
    self.PanelAutoFightButton.gameObject:SetActive(value)
    self.BtnEnter.gameObject:SetActive(not value)
end

function XUiPrequelLineDetail:SetAutoFightStatus(value)
    local state = XDataCenter.AutoFightManager.State
    self.BtnAutoFight.gameObject:SetActive(value == state.None)
    self.ImgAutoFighting.gameObject:SetActive(value == state.Fighting)
    self.BtnAutoFightComplete.gameObject:SetActive(value == state.Complete)
end

function XUiPrequelLineDetail:UpdateRewardTitle(isFirstDrop)
    self.TxtDrop.gameObject:SetActive(not isFirstDrop)
    self.TxtDropEn.gameObject:SetActive(not isFirstDrop)
    self.TxtFirstDrop.gameObject:SetActive(isFirstDrop)
end

function XUiPrequelLineDetail:OnAutoFightStart(stageId)
    if self.PrequelStage and self.PrequelStage == stageId then
        self:OnBtnMaskClick()
    end
end

function XUiPrequelLineDetail:OnAutoFightRemove(stageId)
    if self.PrequelStage and self.PrequelStage == stageId then
        self:SetAutoFightStatus(XDataCenter.AutoFightManager.State.None)
    end
end

function XUiPrequelLineDetail:OnAutoFightComplete(stageId)
    if self.PrequelStage and self.PrequelStage == stageId then
        self:SetAutoFightStatus(XDataCenter.AutoFightManager.State.Complete)
    end
end

function XUiPrequelLineDetail:AddListeners()
    XEventManager.AddEventListener(XEventId.EVENT_AUTO_FIGHT_START, self.OnAutoFightStart, self)
    XEventManager.AddEventListener(XEventId.EVENT_AUTO_FIGHT_REMOVE, self.OnAutoFightRemove, self)
    XEventManager.AddEventListener(XEventId.EVENT_AUTO_FIGHT_COMPLETE, self.OnAutoFightComplete, self)
end

function XUiPrequelLineDetail:RemoveListeners()
    XEventManager.RemoveEventListener(XEventId.EVENT_AUTO_FIGHT_START, self.OnAutoFightStart, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_AUTO_FIGHT_REMOVE, self.OnAutoFightRemove, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_AUTO_FIGHT_COMPLETE, self.OnAutoFightComplete, self)
end