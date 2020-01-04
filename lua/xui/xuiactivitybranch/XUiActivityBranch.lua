local stringGsub = string.gsub
local CsXTextManagerGetText = CS.XTextManager.GetText
local TimeFormat = "yyyy-MM-dd"
local CSXDateFormatTime = CS.XDate.FormatTime
local CsXScheduleManager = CS.XScheduleManager
local XUiGridChapter = require("XUi/XUiFubenMainLineChapter/XUiGridChapter")
local ChildDetailUi = "UiFubenBranchStageDetail"

local XUiActivityBranch = XLuaUiManager.Register(XLuaUi, "UiActivityBranch")

function XUiActivityBranch:OnAwake()
    self:InitAutoScript()
    self.BtnActDesc.gameObject:SetActiveEx(false)
    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.FreeGem, XDataCenter.ItemManager.ItemId.ActionPoint, XDataCenter.ItemManager.ItemId.Coin)
end

function XUiActivityBranch:OnStart(sectionId, difficultType, stageId)
    self.SectionId = sectionId
    self.DefaultStageId = stageId
    self.ChapterList = {}
    if difficultType then
        XDataCenter.FubenActivityBranchManager.SelectDifficult(difficultType == XDataCenter.FubenActivityBranchManager.BranchType.Difficult)
    end

    self.AnimBeijingEnable = self:FindGameObject("AnimBeijingEnable") --这个timeline影响了透明度还原，要强制打断
    self.AnimBeijingDisable = self:FindGameObject("AnimBeijingDisable") --这个timeline影响了透明度还原，要强制打断
end

function XUiActivityBranch:OnEnable()
    XSoundManager.PlaySoundDoNotInterrupt(XSoundManager.UiBasicsMusic.UiActivity_Jidi_BGM)
    self:Refresh()
end

function XUiActivityBranch:OnDisable()
    self:DestroyActivityTimer()
end

function XUiActivityBranch:Refresh()
    local sectionId = self.SectionId
    local sectionCfg = XFubenActivityBranchConfigs.GetSectionCfg(sectionId)
    local chapterId = XDataCenter.FubenActivityBranchManager.GetCurChapterId(sectionId)

    local chapterCfg = XFubenActivityBranchConfigs.GetChapterCfg(chapterId)
    local isSelectDifficult = XDataCenter.FubenActivityBranchManager.IsSelectDifficult()

    self.TxtTitle.text = chapterCfg.Name
    self.TxtSection.text = sectionCfg.Name
    self.TxtLevel.text = CsXTextManagerGetText("ActivityBranchLevelDes", sectionCfg.MinLevel, sectionCfg.MaxLevel)
    self.RImgBg1:SetRawImage(chapterCfg.Bg1)
    self.RImgBg2:SetRawImage(chapterCfg.Bg2)
    self.BtnSwitch2Fight.gameObject:SetActiveEx(not isSelectDifficult)
    self.BtnSwitch2Regional.gameObject:SetActiveEx(isSelectDifficult)
    self.ImgLock.gameObject:SetActiveEx(not XDataCenter.FubenActivityBranchManager.CheckActivityCondition(sectionId))

    self:CreateActivityTimer()
    self:RefreshChapterList()
end

function XUiActivityBranch:RefreshChapterList()
    local chapterId = XDataCenter.FubenActivityBranchManager.GetCurChapterId(self.SectionId)
    local chapterCfg = XFubenActivityBranchConfigs.GetChapterCfg(chapterId)
    local data = {
        Chapter = chapterCfg,
        StageList = chapterCfg.StageId,
        HideStageCb = handler(self, self.CloseStageDetailCb),
        ShowStageCb = handler(self, self.ShowStageDetail),
    }

    local prefabName = chapterCfg.Prefab
    local grid = self.ChapterList[prefabName]
    if not grid or XTool.UObjIsNil(grid.GameObject) then
        local go = self.PanelActivityBranchStages:LoadPrefab(prefabName)
        if not XTool.UObjIsNil(go) then
            local autoChangeBgCb = function(autoChangeBgFlag)
                self.RImgBg1.gameObject:SetActiveEx(true)
                self.RImgBg2.gameObject:SetActiveEx(true)
                if autoChangeBgFlag then
                    self:PlayAnimationWithMask("AnimBeijingDisable")
                else
                    self:PlayAnimationWithMask("AnimBeijingEnable")
                end
                CS.XAudioManager.PlaySound(XSoundManager.UiBasicsMusic.UiActivityBranch_SwitchBg)
            end
            grid = XUiGridChapter.New(self, go, autoChangeBgCb)
            self.ChapterList[prefabName] = grid
        end
    end

    grid.FirstAnim = true
    grid:UpdateChapterGrid(data)

    -- 初始背景图片透明度设置
    local isSelectDifficult = XDataCenter.FubenActivityBranchManager.IsSelectDifficult()
    local fitCondition = grid.FirstSetBg
    if isSelectDifficult or fitCondition then
        self.RImgBg1.gameObject:SetActiveEx(true)
        self.AnimBeijingEnable:SetActiveEx(false)
        self.AnimBeijingEnable:SetActiveEx(true)
        self.RImgBg1.color = CS.UnityEngine.Color(1, 1, 1, 1)
    else
        self.RImgBg1.gameObject:SetActiveEx(false)
    end
    if not isSelectDifficult and not fitCondition then
        self.RImgBg2.gameObject:SetActiveEx(true)
        self.AnimBeijingDisable:SetActiveEx(false)
        self.AnimBeijingDisable:SetActiveEx(true)
        self.RImgBg2.color = CS.UnityEngine.Color(1, 1, 1, 1)
    else
        self.RImgBg2.gameObject:SetActiveEx(false)
    end

    -- 默认选中
    if self.DefaultStageId then
        grid:ClickStageGridByStageId(self.DefaultStageId)
        self.DefaultStageId = nil
    end

    self.CurGrid = grid
end

function XUiActivityBranch:ShowStageDetail(stage, chapterOrderId)
    if XDataCenter.FubenActivityBranchManager.IsStatusEqualFightEnd() then
        XUiManager.TipText("ActivityBranchFightEnd")
        return
    end

    self:OpenOneChildUi(ChildDetailUi, self)
    self:FindChildUiObj(ChildDetailUi):Refresh(stage)
end

function XUiActivityBranch:CloseStageDetailCb()
    if XLuaUiManager.IsUiShow(ChildDetailUi) then
        self:FindChildUiObj(ChildDetailUi):CloseWithAnimDisable()
    end
end

function XUiActivityBranch:CloseStageDetail()
    if self.CurGrid then
        self.CurGrid:CancelSelect()
    end
end

function XUiActivityBranch:CreateActivityTimer()
    self:DestroyActivityTimer()

    local time = XTime.Now()
    local fightEndTime = XDataCenter.FubenActivityBranchManager.GetFightEndTime()
    local activityEndTime = XDataCenter.FubenActivityBranchManager.GetActivityEndTime()
    local shopStr = CsXTextManagerGetText("ActivityBranchShopLeftTime")
    local fightStr = CsXTextManagerGetText("ActivityBranchFightLeftTime")

    if XDataCenter.FubenActivityBranchManager.IsStatusEqualFightEnd() then
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

        if XDataCenter.FubenActivityBranchManager.IsStatusEqualFightEnd() then
            local leftTime = activityEndTime - time
            if leftTime > 0 then
                self.TxtResetDesc.text = shopStr
                self.TxtLeftTime.text = XUiHelper.GetTime(leftTime, XUiHelper.TimeFormatType.ACTIVITY)
            else
                self:DestroyActivityTimer()
                XDataCenter.FubenActivityBranchManager.OnActivityEnd()
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

function XUiActivityBranch:DestroyActivityTimer()
    if self.ActivityTimer then
        CsXScheduleManager.UnSchedule(self.ActivityTimer)
        self.ActivityTimer = nil
    end
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiActivityBranch:InitAutoScript()
    self:AutoAddListener()
end

function XUiActivityBranch:AutoAddListener()
    self:RegisterClickEvent(self.BtnBack, self.OnBtnBackClick)
    self:RegisterClickEvent(self.BtnMainUi, self.OnBtnMainUiClick)
    self:RegisterClickEvent(self.BtnActDesc, self.OnBtnActDescClick)
    self:RegisterClickEvent(self.BtnSwitch2Fight, self.OnBtnSwitch2FightClick)
    self:RegisterClickEvent(self.BtnSwitch2Regional, self.OnBtnSwitch2RegionalClick)
    self:RegisterClickEvent(self.BtnDrop, self.OnBtnDropClick)
    self:RegisterClickEvent(self.BtnShop, self.OnBtnShopClick)
    self:RegisterClickEvent(self.BtnCloseDetail, self.OnBtnCloseDetailClick)
end
-- auto
function XUiActivityBranch:OnBtnBackClick(eventData)
    if XLuaUiManager.IsUiShow(ChildDetailUi) then
        self:CloseStageDetail()
    else
        self:Close()
    end
end

function XUiActivityBranch:OnBtnCloseDetailClick(eventData)
    self:CloseStageDetail()
end

function XUiActivityBranch:OnBtnMainUiClick(eventData)
    XLuaUiManager.RunMain()
end

function XUiActivityBranch:OnBtnActDescClick(eventData)
    local chapterId = XDataCenter.FubenActivityBranchManager.GetCurChapterId(self.SectionId)
    local chapterCfg = XFubenActivityBranchConfigs.GetChapterCfg(chapterId)
    local description = stringGsub(chapterCfg.Description, "\\n", "\n")
    XUiManager.UiFubenDialogTip("", description)
end

function XUiActivityBranch:OnBtnSwitch2FightClick(eventData)
    if not XDataCenter.FubenActivityBranchManager.IsStatusEqualChallengeBegin() then
        local chanllengeBeginTime = XDataCenter.FubenActivityBranchManager.GetActivityChallengeBeginTime()
        local timeStr = CSXDateFormatTime(chanllengeBeginTime, TimeFormat)
        local desc = CsXTextManagerGetText("ActivityBranchChallengeBeginTime", timeStr)
        XUiManager.TipError(desc)
        return
    end

    local ret, desc = XDataCenter.FubenActivityBranchManager.CheckActivityCondition(self.SectionId)
    if not ret then
        XUiManager.TipError(desc)
        return
    end

    XDataCenter.FubenActivityBranchManager.SelectDifficult(true)
    self:CloseStageDetail()
    self:Refresh()
    CS.XAudioManager.PlaySound(XSoundManager.UiBasicsMusic.UiActivityBranch_SwitchBg)
    self:PlayAnimationWithMask("BranchStagesQieHuan")
end

function XUiActivityBranch:OnBtnSwitch2RegionalClick(eventData)
    XDataCenter.FubenActivityBranchManager.SelectDifficult(false)
    self:CloseStageDetail()
    self:Refresh()
    CS.XAudioManager.PlaySound(XSoundManager.UiBasicsMusic.UiActivityBranch_SwitchBg)
    self:PlayAnimationWithMask("BranchStagesQieHuan")
end

function XUiActivityBranch:OnBtnDropClick(eventData)
    local sectionCfgs = XFubenActivityBranchConfigs.GetSectionCfgs()
    local curSectionId = XDataCenter.FubenActivityBranchManager.GetCurSectionId()
    XLuaUiManager.Open("UiActivityBranchReward", sectionCfgs, curSectionId)
end

function XUiActivityBranch:OnBtnShopClick(eventData)
    if not XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.ShopCommon) then
        return
    end

    local sectionCfg = XFubenActivityBranchConfigs.GetSectionCfg(self.SectionId)
    XFunctionManager.SkipInterface(sectionCfg.SkipId)
end