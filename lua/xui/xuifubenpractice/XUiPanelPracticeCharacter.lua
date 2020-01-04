XUiPanelPracticeCharacter = XClass()

function XUiPanelPracticeCharacter:Ctor(rootUi, ui)
    self.RootUi = rootUi
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)

    self:InitViews()
    self:AddBtnsListeners()
end

function XUiPanelPracticeCharacter:AddBtnsListeners()
    self.BtnActDesc.CallBack = function() self:OnBtnActDescClick() end
end


function XUiPanelPracticeCharacter:InitViews()
    self.CharacterDetail = XPracticeConfigs.GetPracticeChapterDetailById(XPracticeConfigs.PracticeMode.Character)
    self.CharacterChapter = XPracticeConfigs.GetPracticeChapterById(XPracticeConfigs.PracticeMode.Character)

    self.CharacterChapterGO = self.PanelPrequelStages:LoadPrefab(self.CharacterDetail.PracticeContentPrefab)
    local uiObj = self.CharacterChapterGO.transform:GetComponent("UiObject")
    for i = 0, uiObj.NameList.Count - 1 do
        self[uiObj.NameList[i]] = uiObj.ObjList[i]
    end

    self.CharacterStages = {}
    for i=1, #self.CharacterChapter.StageId do
        local characterStage = self.CharacterContent:Find(string.format( "Stage%d", i))
        if not characterStage then
            XLog.Error("XUiPanelPracticeChapter:InitViews() error: prefab no found a child name:" .. string.format("Stage%d", i))
            return 
        end
        local gridStageGO = characterStage:LoadPrefab(self.CharacterDetail.PracticeGridPrefab)
        self.CharacterStages[i] = XUiPracticeBasicsStage.New(self.RootUi, gridStageGO, self)
    end

    local indexChapter = #self.CharacterChapter.StageId + 1
    local extraStage = self.CharacterContent:Find(string.format("Stage%d", indexChapter))
    while extraStage do
        extraStage.gameObject:SetActive(false)
        indexChapter = indexChapter + 1
        extraStage = self.CharacterContent:Find(string.format("Stage%d", indexChapter))
    end
end

function XUiPanelPracticeCharacter:SetPanelActive(value)
    self.GameObject:SetActive(value)
    if value then
        self:ShowPanelDetail()
        self.RootUi:PlayAnimation("PanelCharacterQieHuan")
    end
end

function XUiPanelPracticeCharacter:OnBtnActDescClick(...)
    XUiManager.UiFubenDialogTip(CS.XTextManager.GetText("DormDes"), XPracticeConfigs.GetPracticeDescriptionById(XPracticeConfigs.PracticeMode.Character) or "")
end

function XUiPanelPracticeCharacter:ShowPanelDetail()
    self.TxtMode.text = self.CharacterDetail.Name

    self:UpdateNodes()
    self.RootUi:SwitchBg(XPracticeConfigs.PracticeMode.Character)
end

function XUiPanelPracticeCharacter:SortCharacterChapterStages(stageIds)
    local sortedNodes = {}
    for k, stageId in pairs(stageIds) do
        local stageInfo = XDataCenter.FubenManager.GetStageInfo(stageId)
        local isOpen, description = XDataCenter.PracticeManager.CheckPracticeStageOpen(stageId)
        local weight = 3
        if stageInfo.Passed then
            -- 已通关
            weight = 3
        elseif isOpen then
            -- 可打未通过
            weight = 1
        else
            -- 未解锁
            weight = 2
        end
        table.insert(sortedNodes, {
            StageId = stageId,
            Weight = weight
        })
    end
    table.sort(sortedNodes, function(nodeA, nodeB)
        if nodeA.Weight == nodeB.Weight then
            return nodeA.StageId < nodeB.StageId
        else
            return nodeA.Weight < nodeB.Weight
        end
    end)
    return sortedNodes
end

function XUiPanelPracticeCharacter:UpdateNodes()
    self.Nodes = self:SortCharacterChapterStages(self.CharacterChapter.StageId)

    for i = 1, #self.Nodes do
        local node = self.Nodes[i]
        self.CharacterStages[i].GameObject:SetActive(true)
        self.CharacterStages[i]:UpdateNode(node.StageId, XPracticeConfigs.PracticeMode.Character)
    end

    for i = #self.Nodes + 1, #self.CharacterStages do
        self.CharacterStages[i].GameObject:SetActive(false)
    end

    if self.CharacterScrollRect then
        self.CharacterScrollRect.horizontalNormalizedPosition = 0
    end
end

function XUiPanelPracticeCharacter:PlayScrollViewMove(gridTransform)
    self.CharacterScrollRect.movementType = CS.UnityEngine.UI.ScrollRect.MovementType.Unrestricted
    local gridRect = gridTransform:GetComponent("RectTransform")
    self.CharacterViewport.raycastTarget = false
    local diffX = gridRect.localPosition.x + self.CharacterContent.localPosition.x
    if diffX < XDataCenter.FubenMainLineManager.UiGridChapterMoveMinX or diffX > XDataCenter.FubenMainLineManager.UiGridChapterMoveMaxX then
        local tarPosX = XDataCenter.FubenMainLineManager.UiGridChapterMoveTargetX - gridRect.localPosition.x
        local tarPos = self.CharacterContent.localPosition
        tarPos.x = tarPosX
        XLuaUiManager.SetMask(true)
        XUiHelper.DoMove(self.CharacterContent, tarPos, XDataCenter.FubenMainLineManager.UiGridChapterMoveDuration, XUiHelper.EaseType.Sin, function()
            XLuaUiManager.SetMask(false)
        end)
    end
end

function XUiPanelPracticeCharacter:OnPracticeDetailClose()
    self.CharacterScrollRect.movementType = CS.UnityEngine.UI.ScrollRect.MovementType.Elastic
    self.CharacterViewport.raycastTarget = true
end

return XUiPanelPracticeCharacter