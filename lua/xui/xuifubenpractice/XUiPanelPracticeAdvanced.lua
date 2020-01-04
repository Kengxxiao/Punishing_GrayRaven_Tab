XUiPanelPracticeAdvanced = XClass()

function XUiPanelPracticeAdvanced:Ctor(rootUi, ui)
    self.RootUi = rootUi
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)

    self:InitViews()
    self:AddBtnsListeners()
end

function XUiPanelPracticeAdvanced:AddBtnsListeners()
    self.BtnActDesc.CallBack = function() self:OnBtnActDescClick() end
end

function XUiPanelPracticeAdvanced:InitViews()
    self.AdvancedDetail = XPracticeConfigs.GetPracticeChapterDetailById(XPracticeConfigs.PracticeMode.Advanced)
    self.AdvancedChapter = XPracticeConfigs.GetPracticeChapterById(XPracticeConfigs.PracticeMode.Advanced)

    self.AdvancedChapterGO = self.PanelPrequelStages:LoadPrefab(self.AdvancedDetail.PracticeContentPrefab)
    local uiObj = self.AdvancedChapterGO.transform:GetComponent("UiObject")
    for i = 0, uiObj.NameList.Count - 1 do
        self[uiObj.NameList[i]] = uiObj.ObjList[i]
    end

    self.AdvancedStages = {}

    for i=1, #self.AdvancedChapter.StageId do
        local advancedStage = self.AdvancedContent:Find(string.format("Stage%d", i))
        if not advancedStage then
            XLog.Error("XUiPanelPracticeAdvance:InitViews() error: prefab no found a child name:" .. string.format("Stage%d", i))
            return 
        end
        local gridStageGO = advancedStage:LoadPrefab(self.AdvancedDetail.PracticeGridPrefab)
        self.AdvancedStages[i] = XUiPracticeBasicsStage.New(self.RootUi, gridStageGO, self)
    end

    -- 隐藏多余的组件
    local indexChapter = #self.AdvancedChapter.StageId + 1
    local extraStage = self.AdvancedContent:Find(string.format("Stage%d", indexChapter))
    while extraStage do
        extraStage.gameObject:SetActive(false)
        indexChapter = indexChapter + 1
        extraStage =  self.AdvancedContent:Find(string.format("Stage%d", indexChapter))
    end

end

function XUiPanelPracticeAdvanced:SetPanelActive(value)
    self.GameObject:SetActive(value)
    if value then
        self:ShowPanelDetail()
        self.RootUi:PlayAnimation("PanelAdvancedQieHuan")
    end
end

function XUiPanelPracticeAdvanced:OnBtnActDescClick(...)
    XUiManager.UiFubenDialogTip(CS.XTextManager.GetText("DormDes"), XPracticeConfigs.GetPracticeDescriptionById(XPracticeConfigs.PracticeMode.Advanced) or "")
end

function XUiPanelPracticeAdvanced:ShowPanelDetail()
    self.TxtMode.text = self.AdvancedDetail.Name

    self:UpdateNodes()
    self.RootUi:SwitchBg(XPracticeConfigs.PracticeMode.Advanced)
end

function XUiPanelPracticeAdvanced:UpdateNodes()
    for i = 1, #self.AdvancedChapter.StageId do
        local stageId = self.AdvancedChapter.StageId[i]
        self.AdvancedStages[i].GameObject:SetActive(true)
        self.AdvancedStages[i]:UpdateNode(stageId, XPracticeConfigs.PracticeMode.Advanced)
    end
    for i = #self.AdvancedChapter.StageId + 1, #self.AdvancedStages do
        self.AdvancedStages[i].GameObject:SetActive(false)
    end

    if self.AdvancedScrollRect then
        self.AdvancedScrollRect.horizontalNormalizedPosition = 0
    end
end

function XUiPanelPracticeAdvanced:PlayScrollViewMove(gridTransform)
    self.AdvancedScrollRect.movementType = CS.UnityEngine.UI.ScrollRect.MovementType.Unrestricted
    local gridRect = gridTransform:GetComponent("RectTransform")
    self.AdvancedViewport.raycastTarget = false
    local diffX = gridRect.localPosition.x + self.AdvancedContent.localPosition.x
    if diffX < XDataCenter.FubenMainLineManager.UiGridChapterMoveMinX or diffX > XDataCenter.FubenMainLineManager.UiGridChapterMoveMaxX then
        local tarPosX = XDataCenter.FubenMainLineManager.UiGridChapterMoveTargetX - gridRect.localPosition.x
        local tarPos = self.AdvancedContent.localPosition
        tarPos.x = tarPosX
        XLuaUiManager.SetMask(true)
        XUiHelper.DoMove(self.AdvancedContent, tarPos, XDataCenter.FubenMainLineManager.UiGridChapterMoveDuration, XUiHelper.EaseType.Sin, function()
            XLuaUiManager.SetMask(false)
        end)
    end
end

function XUiPanelPracticeAdvanced:OnPracticeDetailClose()
    self.AdvancedScrollRect.movementType = CS.UnityEngine.UI.ScrollRect.MovementType.Elastic
    self.AdvancedViewport.raycastTarget = true
end


return XUiPanelPracticeAdvanced