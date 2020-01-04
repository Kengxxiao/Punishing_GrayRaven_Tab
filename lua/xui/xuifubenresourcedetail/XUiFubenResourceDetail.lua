
local XUiFubenResourceDetail = XLuaUiManager.Register(XLuaUi, "UiFubenResourceDetail")

local MAX_STAR = 3
local ANIMATION_OPEN = "AniFubenResourceDetailBegin"
local ANIMATION_END = "AniFubenResourceDetailEnd"

function XUiFubenResourceDetail:OnAwake()
    self:InitAutoScript()
end


function XUiFubenResourceDetail:OnStart(params)
    self.Params = params

    self.IsPlaying = false
    self.Stage = nil

    self.StarItemsList = { self.GridStar1, self.GridStar2, self.GridStar3 }
    self.StarGridList = {}
    self.GridList = {}
    self.GridCommonItem = self.Transform:Find("SafeAreaContentPane/PanelDropList/DropList/Viewport/PanelDropContent/GridCommon")
    self.GridCommonItem.gameObject:SetActive(false)
    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.FreeGem, XDataCenter.ItemManager.ItemId.ActionPoint, XDataCenter.ItemManager.ItemId.Coin)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiFubenResourceDetail:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiFubenResourceDetail:AutoInitUi()
    self.BtnClose = self.Transform:Find("SafeAreaContentPane/BtnClose"):GetComponent("Button")
    self.PanelDropList = self.Transform:Find("SafeAreaContentPane/PanelDropList")
    self.PanelDrop = self.Transform:Find("SafeAreaContentPane/PanelDropList/PanelDrop")
    self.TxtDrop = self.Transform:Find("SafeAreaContentPane/PanelDropList/PanelDrop/TxtDrop"):GetComponent("Text")
    self.TxtDropEn = self.Transform:Find("SafeAreaContentPane/PanelDropList/PanelDrop/TxtDropEn"):GetComponent("Text")
    self.PanelDropContent = self.Transform:Find("SafeAreaContentPane/PanelDropList/DropList/Viewport/PanelDropContent")
    self.GridCommon = self.Transform:Find("SafeAreaContentPane/PanelDropList/DropList/Viewport/PanelDropContent/GridCommon")
    self.PanelNums = self.Transform:Find("SafeAreaContentPane/PanelNums")
    self.TxtAllNums = self.Transform:Find("SafeAreaContentPane/PanelNums/TxtAllNums"):GetComponent("Text")
    self.TxtLeftNums = self.Transform:Find("SafeAreaContentPane/PanelNums/TxtLeftNums"):GetComponent("Text")
    self.BtnAddNum = self.Transform:Find("SafeAreaContentPane/PanelNums/BtnAddNum"):GetComponent("Button")
    self.PanelBottom = self.Transform:Find("SafeAreaContentPane/PanelBottom")
    self.TxtATNums = self.Transform:Find("SafeAreaContentPane/PanelBottom/TxtATNums"):GetComponent("Text")
    self.BtnEnter = self.Transform:Find("SafeAreaContentPane/PanelBottom/BtnEnter"):GetComponent("Button")
    self.PanelDesc = self.Transform:Find("SafeAreaContentPane/PanelDesc")
    self.TxtTitle = self.Transform:Find("SafeAreaContentPane/PanelDesc/TxtTitle"):GetComponent("Text")
    self.TxtLevelVal = self.Transform:Find("SafeAreaContentPane/PanelDesc/TxtLevelVal"):GetComponent("Text")
    self.RImgNandu = self.Transform:Find("SafeAreaContentPane/PanelDesc/RImgNandu"):GetComponent("RawImage")
    self.TxtDesc = self.Transform:Find("SafeAreaContentPane/PanelDesc/TxtDesc"):GetComponent("Text")
    self.PanelTargetList = self.Transform:Find("SafeAreaContentPane/PanelTargetList")
    self.TxtActive3 = self.Transform:Find("SafeAreaContentPane/PanelTargetList/TxtActive3"):GetComponent("Text")
    self.TxtActive2 = self.Transform:Find("SafeAreaContentPane/PanelTargetList/TxtActive2"):GetComponent("Text")
    self.TxtActive1 = self.Transform:Find("SafeAreaContentPane/PanelTargetList/TxtActive1"):GetComponent("Text")
    self.PanelAsset = self.Transform:Find("SafeAreaContentPane/PanelAsset")
    self.PanelItem = self.Transform:Find("SafeAreaContentPane/PanelItem")
    self.PanelFubenTab = self.Transform:Find("SafeAreaContentPane/PanelItem/PanelFubenTab")
    self.PanelBg = self.Transform:Find("SafeAreaContentPane/PanelBg")
end

function XUiFubenResourceDetail:AutoAddListener()
    self:RegisterClickEvent(self.BtnClose, self.OnBtnCloseClick)
    self:RegisterClickEvent(self.BtnAddNum, self.OnBtnAddNumClick)
    self:RegisterClickEvent(self.BtnEnter, self.OnBtnEnterClick)
end
-- auto

function XUiFubenResourceDetail:GetAutoKey(uiNode, eventName)
    if not uiNode then
        return
    end
    return eventName .. uiNode:GetHashCode()
end

function XUiFubenResourceDetail:OnBtnCloseClick(...)
    if self.IsPlaying then
        return
    end

    XUiHelper.StopAnimation()
    self.IsPlaying = true
    local End = function()
        if XTool.UObjIsNil(self.GameObject) then
            return
        end
        self.GameObject:SetActive(false)
        self.IsPlaying = false

        self:Close()
        
        if self.Params and self.Params.closeCb then
            self.Params.closeCb()
        end
    end
    XUiHelper.PlayAnimation(self, ANIMATION_END, nil, End)
end

function XUiFubenResourceDetail:OnBtnAddNumClick()
    local challegeData = XDataCenter.FubenMainLineManager.GetStageBuyChallegeData(self.Stage.StageId)
    local func = function()
        self:UpdateDetailText()
    end
    XLuaUiManager.Open("UiBuyAsset",1, func, challegeData)
end

function XUiFubenResourceDetail:OnBtnEnterClick()
    if self.Stage == nil then
        XLog.Error("OnBtnEnterClick: Can not find stage!")
        return
    end

    self:Close()

    if self.Params and self.Params.fightCb then
        self.Params.fightCb(self.Stage)
    end
end

-- 初始化 stage detail Ui
function XUiFubenResourceDetail:InitStageDetail(chapterOrderId, stage, data)
    self.ChapterOrderId = chapterOrderId
    self.Stage = stage

    self.FocusPanelTab = XUiPanelFubenTab.New(self, self.PanelFubenTab)
    self.FocusPanelTab:SetData(data)

    self:UpdateRewards()
    self:UpdateDetailText()
    self:UpdateDifficulty()
end

function XUiFubenResourceDetail:UpdateRewards()
    local stage = self.Stage
    local stageInfo = XDataCenter.FubenManager.GetStageInfo(stage.StageId)
    local rewardId = 0
    local IsFirst = false
    if stageInfo.Passed then
        -- 判断副本玩家等级调控
        local cfg = XDataCenter.FubenManager.GetStageLevelControl(stage.StageId)
        rewardId = cfg and cfg.FinishRewardShow or stage.FinishRewardShow
    else
        -- 判断副本玩家等级调控
        local cfg = XDataCenter.FubenManager.GetStageLevelControl(stage.StageId)
        rewardId = cfg and cfg.FirstRewardShow or stage.FirstRewardShow
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

function XUiFubenResourceDetail:UpdateDetailText()
    self.TxtTitle.text = self.Stage.Name
    self.TxtLevelVal.text = self.Stage.RecommandLevel
    self.TxtDesc.text = self.Stage.Description
    self.TxtATNums.text = self.Stage.RequireActionPoint

    local stageData = XDataCenter.FubenManager.GetStageData(self.Stage.StageId)
    local stageInfo = XDataCenter.FubenManager.GetStageInfo(self.Stage.StageId)

    local leftNum = XDataCenter.FubenResourceManager.GetSectionDataByTypeId(stageInfo.ResourceType).LeftCount
    self.TxtAllNums.text = "/" .. XDataCenter.FubenResourceManager.GetSectionDataByTypeId(stageInfo.ResourceType).MaxCount
    self.TxtLeftNums.text = leftNum


    local cfg = XDataCenter.FubenManager.GetStageCfg(self.Stage.StageId)
    for i = 1, 3 do
        self["TxtActive" .. i].text = cfg.StarDesc[i] or ""
    end
end

function XUiFubenResourceDetail:UpdateDifficulty()
    local nanDuIcon = XDataCenter.FubenManager.GetDiccicultIcon(self.Stage.StageId)
    self.RImgNandu:SetRawImage(nanDuIcon)
end

function XUiFubenResourceDetail:HideEnterBtn()
    if self.BtnEnter then
        self.BtnEnter.gameObject:SetActive(false)
    end
end

function XUiFubenResourceDetail:ShowEnterBtn()
    if self.BtnEnter then
        self.BtnEnter.gameObject:SetActive(true)
    end
end

function XUiFubenResourceDetail:Show()
    XUiHelper.StopAnimation()

    self:ResetSize()
    
    self.IsPlaying = true
    self.GameObject:SetActive(true)

    local End = function()
        self.IsPlaying = false
    end
    XUiHelper.PlayAnimation(self, ANIMATION_OPEN, nil, End)
end


function XUiFubenResourceDetail:OnEnable()
    local data = XDataCenter.FubenResourceManager.GetSectionDataByTypeId(self.Params.typeId or 1)
    local stageCfg = XDataCenter.FubenManager.GetStageCfg(data.StageId)

    self:Show()
    self:InitStageDetail(stageCfg.OrderId, stageCfg, data)

    self:UpdateRewards()
    self:UpdateDetailText()
end

function XUiFubenResourceDetail:ResetSize()
    self.PanelAsset.transform.localScale  = CS.UnityEngine.Vector3.one
    self.PanelTargetList.transform.localScale  = CS.UnityEngine.Vector3.one
    self.PanelDesc.transform.localScale  = CS.UnityEngine.Vector3.one
    self.PanelBottom.transform.localScale  = CS.UnityEngine.Vector3.one
    self.PanelNums.transform.localScale  = CS.UnityEngine.Vector3.one
    self.PanelDropList.transform.localScale  = CS.UnityEngine.Vector3.one
    self.PanelBg.transform.localScale  = CS.UnityEngine.Vector3.one
end


