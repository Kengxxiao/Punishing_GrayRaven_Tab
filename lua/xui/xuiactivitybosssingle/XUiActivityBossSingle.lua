local stringGsub = string.gsub
local CsXTextManager = CS.XTextManager
local CsXScheduleManager = CS.XScheduleManager
local XUiGridActivityStageBanner = require("XUi/XUiActivityBossSingle/XUiGridActivityStageBanner")
local XUiActivityBossSingle = XLuaUiManager.Register(XLuaUi, "UiActivityBossSingle")

function XUiActivityBossSingle:OnAwake()
    self:InitAutoScript()
    self:InitDynamicTable()
    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.FreeGem, XDataCenter.ItemManager.ItemId.ActionPoint, XDataCenter.ItemManager.ItemId.Coin)
    self.BtnActDesc.gameObject:SetActiveEx(false)
end

function XUiActivityBossSingle:OnStart(sectionId)
    self.SectionId = sectionId
end

function XUiActivityBossSingle:OnEnable()
    XSoundManager.PlaySoundDoNotInterrupt(XSoundManager.UiBasicsMusic.UiActivity_Jidi_BGM)
    self:Refresh()
end

function XUiActivityBossSingle:OnDisable()
    self:DestroyActivityTimer()
end

function XUiActivityBossSingle:InitDynamicTable()
    self.DynamicTable = XDynamicTableNormal.New(self.PanelStageList)
    self.DynamicTable:SetProxy(XUiGridActivityStageBanner)
    self.DynamicTable:SetDelegate(self)
end

function XUiActivityBossSingle:RefreshDynamicTable()
    local sectionCfg = XFubenActivityBossSingleConfigs.GetSectionCfg(self.SectionId)
    self.ChallengeIds = sectionCfg.ChallengeId
    self.DynamicTable:SetDataSource(self.ChallengeIds)
    self.DynamicTable:ReloadDataASync()
end

function XUiActivityBossSingle:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:SetRootUi(self)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        grid:Refresh(self.ChallengeIds[index])
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then
        if XDataCenter.FubenActivityBossSingleManager.IsStatusEqualFightEnd() then
            XUiManager.TipText("ActivityBossSingleFightEnd")
            return
        end

        local challengeId = self.ChallengeIds[index]
        if not XDataCenter.FubenActivityBossSingleManager.IsChallengeUnlock(challengeId) then
            local preChallengeId = XDataCenter.FubenActivityBossSingleManager.GetPreChallengeId(self.SectionId, challengeId)
            local preStageId = XFubenActivityBossSingleConfigs.GetStageId(preChallengeId)
            local preStageCfg = XDataCenter.FubenManager.GetStageCfg(preStageId)
            XUiManager.TipMsg(CsXTextManager.GetText("FubenPreStage", preStageCfg.Name))
            return
        else
            local sectionCfg = XFubenActivityBossSingleConfigs.GetSectionCfg(self.SectionId)
            XLuaUiManager.Open("UiActivityBossSingleDetail", challengeId)
        end
    end
end

function XUiActivityBossSingle:CreateActivityTimer()
    self:DestroyActivityTimer()

    local time = XTime.Now()
    local fightEndTime = XDataCenter.FubenActivityBossSingleManager.GetFightEndTime()
    local activityEndTime = XDataCenter.FubenActivityBossSingleManager.GetActivityEndTime()
    local shopStr = CsXTextManager.GetText("ActivityBranchShopLeftTime")
    local fightStr = CsXTextManager.GetText("ActivityBranchFightLeftTime")

    if XDataCenter.FubenActivityBossSingleManager.IsStatusEqualFightEnd() then
        self.TxtResetDesc.text = shopStr
        self.TxtLeftTime.text = XUiHelper.GetTime(activityEndTime - time, XUiHelper.TimeFormatType.ACTIVITY)
    else
        self.TxtResetDesc.text = fightStr
        self.TxtLeftTime.text = XUiHelper.GetTime(fightEndTime - time, XUiHelper.TimeFormatType.ACTIVITY)
    end

    self.ActivityTimer = CsXScheduleManager.ScheduleForever(function(...)
        if XTool.UObjIsNil(self.TxtLeftTime) then
            self:DestroyActivityTimer()
            return
        end

        time = time + 1
        
        if XDataCenter.FubenActivityBossSingleManager.IsStatusEqualFightEnd() then
            local leftTime = activityEndTime - time
            if leftTime > 0 then
                self.TxtResetDesc.text = shopStr
                self.TxtLeftTime.text = XUiHelper.GetTime(leftTime, XUiHelper.TimeFormatType.ACTIVITY)
            else
                self:DestroyActivityTimer()
                XDataCenter.FubenActivityBossSingleManager.OnActivityEnd()
            end
        else
            local leftTime = fightEndTime - time
            if leftTime > 0 then
                self.TxtResetDesc.text = fightStr
                self.TxtLeftTime.text = XUiHelper.GetTime(leftTime, XUiHelper.TimeFormatType.ACTIVITY)
            else
                self:DestroyActivityTimer()
                self:CreateActivityTimer()
            end
        end
    end, CsXScheduleManager.SECOND, 0)
end

function XUiActivityBossSingle:DestroyActivityTimer()
    if self.ActivityTimer then
        CsXScheduleManager.UnSchedule(self.ActivityTimer)
        self.ActivityTimer = nil
    end
end

function XUiActivityBossSingle:Refresh()
    local sectionId = self.SectionId
    local sectionCfg = XFubenActivityBossSingleConfigs.GetSectionCfg(sectionId)

    self.TxtTitle.text = sectionCfg.ChapterName
    self.TxtSection.text = sectionCfg.Name
    self.TxtLevel.text = CsXTextManager.GetText("ActivityBranchLevelDes", sectionCfg.MinLevel, sectionCfg.MaxLevel)

    self:CreateActivityTimer()
    self:RefreshDynamicTable()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiActivityBossSingle:InitAutoScript()
    self:AutoAddListener()
end

function XUiActivityBossSingle:AutoAddListener()
    self:RegisterClickEvent(self.BtnActDesc, self.OnBtnActDescClick)
    self:RegisterClickEvent(self.BtnDrop, self.OnBtnDropClick)
    self:RegisterClickEvent(self.BtnShop, self.OnBtnShopClick)
    self:RegisterClickEvent(self.BtnBack, self.OnBtnBackClick)
    self:RegisterClickEvent(self.BtnMainUi, self.OnBtnMainUiClick)
end
-- auto
function XUiActivityBossSingle:OnBtnActDescClick(eventData)
    local sectionCfg = XFubenActivityBossSingleConfigs.GetSectionCfg(self.SectionId)
    local description = stringGsub(sectionCfg.Description, "\\n", "\n")
    XUiManager.UiFubenDialogTip("", description)
end

function XUiActivityBossSingle:OnBtnDropClick(eventData)
    local sectionCfgs = XFubenActivityBossSingleConfigs.GetSectionCfgs()
    local curSectionId = XDataCenter.FubenActivityBossSingleManager.GetCurSectionId()
    XLuaUiManager.Open("UiActivityBranchReward", sectionCfgs, curSectionId)
end

function XUiActivityBossSingle:OnBtnShopClick(eventData)
    if not XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.ShopCommon) then
        return
    end

    local sectionCfg = XFubenActivityBossSingleConfigs.GetSectionCfg(self.SectionId)
    XFunctionManager.SkipInterface(sectionCfg.SkipId)
end

function XUiActivityBossSingle:OnBtnBackClick(eventData)
    self:Close()
end

function XUiActivityBossSingle:OnBtnMainUiClick(eventData)
    XLuaUiManager.RunMain()
end