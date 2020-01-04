XUiPanelRegional = XClass()

function XUiPanelRegional:Ctor(ui, rootUi)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    self:InitAutoScript()
    self.CurrentPrequelGrid = nil
    self.LastPrequelPrefabName = ""
    self.PrequelGridList = {}
    self.PrequelGridAsset = {}
    self.PlotTab = XUiPanelPlotTab.New(self.PanelPlotTab, self.RootUi, self)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelRegional:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiPanelRegional:AutoInitUi()
    self.PanelRegional = self.Transform:Find("PanelRegional")
    self.PanelPrequelStages = self.Transform:Find("PanelRegional/PanelPrequelStages")
    self.TxtMode = self.Transform:Find("PanelRegional/ImageLine/TxtMode"):GetComponent("Text")
    self.TxtProgress = self.Transform:Find("PanelRegional/ImageLine/TxtProgress"):GetComponent("Text")
    self.PanelLeft = self.Transform:Find("PanelRegional/PanelLeft")
    self.PanelPlotTab = self.Transform:Find("PanelRegional/PanelLeft/PanelPlotTab")
    self.BtnSwitch2Fight = self.Transform:Find("PanelRegional/PanelLeft/BtnSwitch2Fight"):GetComponent("Button")
    self.ImgLock = self.Transform:Find("PanelRegional/PanelLeft/BtnSwitch2Fight/ImgLock"):GetComponent("Image")
    self.PanelBottom = self.Transform:Find("PanelRegional/PanelBottom")
    self.PanelJundu = self.Transform:Find("PanelRegional/PanelBottom/PanelJundu")
    self.ImgJindu = self.Transform:Find("PanelRegional/PanelBottom/PanelJundu/ImgJindu"):GetComponent("Image")
    self.ImgLingqu = self.Transform:Find("PanelRegional/PanelBottom/PanelJundu/ImgLingqu"):GetComponent("Image")
    self.BtnTreasure = self.Transform:Find("PanelRegional/PanelBottom/PanelJundu/BtnTreasure"):GetComponent("Button")
    self.PanelNum = self.Transform:Find("PanelRegional/PanelBottom/PanelNum")
    self.TxtBfrtTaskTotalNum = self.Transform:Find("PanelRegional/PanelBottom/PanelNum/TxtBfrtTaskTotalNum"):GetComponent("Text")
    self.TxtBfrtTaskFinishNum = self.Transform:Find("PanelRegional/PanelBottom/PanelNum/TxtBfrtTaskFinishNum"):GetComponent("Text")
    self.ImgRedProgress = self.Transform:Find("PanelRegional/PanelBottom/PanelNum/ImgRedProgress")
    self.BtnActDesc = self.Transform:Find("PanelRegional/BtnActDesc"):GetComponent("Button")
end

function XUiPanelRegional:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelRegional:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelRegional:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelRegional:AutoAddListener()
    self:RegisterClickEvent(self.BtnSwitch2Fight, self.OnBtnSwitch2FightClick)
    self:RegisterClickEvent(self.BtnTreasure, self.OnBtnTreasureClick)
    self:RegisterClickEvent(self.BtnActDesc, self.OnBtnActDescClick)
end
-- auto

function XUiPanelRegional:OnBtnSwitch2FightClick(eventData)
    if not self.CurrentCover then
        return 
    end
    -- 检查条件
    if self.CurrentCover.CoverVal.ChallengeCondition > 0 then
        local rect, desc = XConditionManager.CheckCondition(self.CurrentCover.CoverVal.ChallengeCondition)
        if not rect then
            XUiManager.TipMsg(desc)
            return 
        end
    end

    self.RootUi:Switch2Challenge(self.CurrentCover)
end

function XUiPanelRegional:OnBtnTreasureClick(eventData)
    if not self.CurrentSelectedChapterId then
        return 
    end
    self.RootUi:Switch2RewardList(self.CurrentSelectedChapterId)
end

function XUiPanelRegional:OnBtnActDescClick(eventData)
    if self.CurrentCover and self.CurrentSelectIdx then
        local chapterId = self.CurrentCover.CoverVal.ChapterId[self.CurrentSelectIdx]
        local chapterInfo = XPrequelConfigs.GetPrequelChapterInfoById(chapterId)
        local description = string.gsub(chapterInfo.ChapterDescription, "\\n", "\n")
        XUiManager.UiFubenDialogTip("", description)
    end
end

function XUiPanelRegional:InitPlotTab()
    self.PlotTab:UpdateTabs(self.CurrentCover)
    local defaultIndex = XDataCenter.PrequelManager.GetSelectableChaperIndex(self.CurrentCover) or 1
    local skipChpater = self.RootUi:GetDefaultChapter()
    local isSkipChapterInActivity = (skipChpater ~= nil) and XDataCenter.PrequelManager.IsChapterInActivity(skipChpater) or false
    
    local skipIndex = XDataCenter.PrequelManager.GetIndexByChapterId(self.CurrentCover, skipChpater)
    self.CurrentSelectIdx = self.CurrentSelectIdx or defaultIndex
    if isSkipChapterInActivity then
        local skipDescription = XDataCenter.PrequelManager.GetChapterUnlockDescription(skipChpater)
        -- 活动内、已解锁
        if skipDescription == nil then
            self.CurrentSelectIdx = self.CurrentSelectIdx or skipIndex or defaultIndex
        end
    end
    self.PlotTab:SelectIndex(self.CurrentSelectIdx, false)
end

function XUiPanelRegional:OnRefresh(coverData)
    self.CurrentCover = coverData
    self:InitPlotTab()
end

function XUiPanelRegional:UpdateCurrentTab()
    if self.CurrentSelectIdx then
        self:OnChapterSelected(self.CurrentSelectIdx)
    end
end

function XUiPanelRegional:UpdateRewardView()
    if self.CurrentCover and self.CurrentSelectIdx then
        local chapterId = self.CurrentCover.CoverVal.ChapterId[self.CurrentSelectIdx]
        self.ImgRedProgress.gameObject:SetActive(XDataCenter.PrequelManager.CheckRewardAvaliable(chapterId))
        local totalNum, finishedNum = self:GetRewardTotalNumAndFinishNum(chapterId)
        self.TxtBfrtTaskTotalNum.text = totalNum
        self.TxtBfrtTaskFinishNum.text = finishedNum
        self.ImgJindu.fillAmount = finishedNum / totalNum * 1.0
    end
end

function XUiPanelRegional:UpdateCover()
    XEventManager.DispatchEvent(XEventId.EVENT_NOTICE_SELECTCOVER_CHANGE, {Cover = self.CurrentCover, Index = self.CurrentSelectIdx})
end

function XUiPanelRegional:OnChapterSelected(index)
    self.CurrentSelectIdx = index

    local chapterId = self.CurrentCover.CoverVal.ChapterId[index]
    self.ChapterDatas = XPrequelConfigs.GetPrequelChapterById(chapterId)
    self.CurrentSelectedChapterId = chapterId
    local prefabName = XPrequelConfigs.GetPrequelChapterById(chapterId).PrefabName
    if not prefabName or prefabName == "" then
        XLog.Error("XUiPanelRegional:OnChapterSelected error : prefabName not found " .. tostring(prefabName))
        return 
    end

    local asset = self.PanelPrequelStages:LoadPrefab(prefabName)
    if asset == nil or (not asset:Exist()) then
        XLog.Error("当前prefab不存在：" .. tostring(prefabName))
        return 
    end
    if self.LastPrequelPrefabName ~= prefabName then
        local grid = XUiPanelPrequelChapter.New(asset, self.RootUi)
        grid.Transform:SetParent(self.PanelPrequelStages, false)
        self.CurrentPrequelGrid = grid
        self.LastPrequelPrefabName = prefabName
    end
    self.CurrentPrequelGrid:UpdatePrequelGrid(self.ChapterDatas.StageId)
    self.CurrentPrequelGrid:Show()

    local finishedNum, totalNum = XDataCenter.PrequelManager.GetChapterProgress(chapterId)
    self.TxtProgress.text = XPrequelConfigs.GetRegionalProgress(finishedNum, totalNum)
    local totalNum, finishedNum = self:GetRewardTotalNumAndFinishNum(chapterId)
    self.TxtBfrtTaskTotalNum.text = totalNum
    self.TxtBfrtTaskFinishNum.text = finishedNum
    self.ImgRedProgress.gameObject:SetActive(XDataCenter.PrequelManager.CheckRewardAvaliable(chapterId))
    self.ImgJindu.fillAmount = finishedNum / totalNum * 1.0
    if self.CurrentCover.CoverVal.ChallengeCondition > 0 then
        local rect = XConditionManager.CheckCondition(self.CurrentCover.CoverVal.ChallengeCondition)
        self.ImgLock.gameObject:SetActive(not rect)
    else
        self.ImgLock.gameObject:SetActive(false)
    end
end

function XUiPanelRegional:GetRewardTotalNumAndFinishNum(chapterId)
    local totalNum = 0
    local finishNum = 0
    local chapterCfg = XPrequelConfigs.GetPrequelChapterById(chapterId)
    for _, stageId in pairs(chapterCfg and chapterCfg.StageId or {}) do
        local stageCfg = XDataCenter.FubenManager.GetStageCfg(stageId)
        if stageCfg.FirstRewardShow > 0 then
            totalNum = totalNum + 1
            if XDataCenter.PrequelManager.IsRewardStageCollected(stageId) then
                finishNum = finishNum + 1
            end
        end
    end
    return totalNum, finishNum
end

return XUiPanelRegional
