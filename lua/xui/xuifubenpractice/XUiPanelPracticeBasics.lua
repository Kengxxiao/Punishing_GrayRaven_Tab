XUiPanelPracticeBasics = XClass()
local XUguiDragProxy = CS.XUguiDragProxy

function XUiPanelPracticeBasics:Ctor(rootUi, ui)
    self.RootUi = rootUi
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
    
    self:InitViews()
    self:AddBtnsListeners()
end

function XUiPanelPracticeBasics:AddBtnsListeners()
    self.BtnActDesc.CallBack = function() self:OnBtnActDescClick() end
end



function XUiPanelPracticeBasics:InitViews()
    self.BasicsDetail = XPracticeConfigs.GetPracticeChapterDetailById(XPracticeConfigs.PracticeMode.Basics)
    self.BasicsChapter = XPracticeConfigs.GetPracticeChapterById(XPracticeConfigs.PracticeMode.Basics)

    self.BasicsChapterGO = self.PanelPracticeStages:LoadPrefab(self.BasicsDetail.PracticeContentPrefab)
    local uiObj = self.BasicsChapterGO.transform:GetComponent("UiObject")

    for i = 0, uiObj.NameList.Count - 1 do
        self[uiObj.NameList[i]] = uiObj.ObjList[i]
    end

    self.BasicsStages = {}
    self.BasicsLines = {}

    for i=1, #self.BasicsChapter.StageId do
        local basicsStage = self.BasicsContent:Find(string.format("Stage%d", i))
        if not basicsStage then
            XLog.Error("XUiPanelPracticeBasics:InitViews() error: prefab not found a child name:" .. string.format("Stage%d", i))
            return 
        end
        local gridStageGO = basicsStage:LoadPrefab(self.BasicsDetail.PracticeGridPrefab)
        self.BasicsStages[i] = XUiPracticeBasicsStage.New(self.RootUi, gridStageGO, self)
        if i ~= #self.BasicsChapter.StageId then
            self.BasicsLines[i] = self.BasicsContent:Find(string.format("Line%d", i))
            if not self.BasicsLines[i] then
                XLog.Error("XUiPanelPracticeBasics:InitViews() error: prefab not found a child name:" .. string.format("Line%d", i))
                return
            end
        end
    end

    -- 隐藏多余的组件
    local indexChapter = #self.BasicsChapter.StageId + 1
    local extraStage = self.BasicsContent:Find(string.format("Stage%d", indexChapter))
    while extraStage do
        extraStage.gameObject:SetActive(false)
        indexChapter = indexChapter + 1
        extraStage = self.BasicsContent:Find(string.format("Stage%d", indexChapter))
    end

    local indexLine = #self.BasicsChapter.StageId
    local extraLine = self.BasicsContent:Find(string.format("Line%d", indexLine))
    while extraLine do
        extraLine.gameObject:SetActive(false)
        indexLine = indexLine + 1
        extraLine = self.BasicsContent:Find(string.format("Line%d", indexLine))
    end

    local dragProxy = self.BasicsScrollRect:GetComponent(typeof(XUguiDragProxy))
    if not dragProxy then
        dragProxy = self.BasicsScrollRect.gameObject:AddComponent(typeof(XUguiDragProxy))
    end
    dragProxy:RegisterHandler(handler(self, self.OnDragProxy))
end

function XUiPanelPracticeBasics:OnDragProxy(dragType)
    if dragType == 0 then
        self.RootUi:CloseStageDetail()
    end
end

function XUiPanelPracticeBasics:SetPanelActive(value)
    self.GameObject:SetActive(value)
    if value then
        self:ShowPanelDetail()
        self.RootUi:PlayAnimation("PanelBasicsQieHuan")
    end
end

function XUiPanelPracticeBasics:OnBtnActDescClick(...)
    XUiManager.UiFubenDialogTip("", XPracticeConfigs.GetPracticeDescriptionById(XPracticeConfigs.PracticeMode.Basics) or "")
end

function XUiPanelPracticeBasics:ShowPanelDetail()
    self.TxtMode.text = self.BasicsDetail.Name

    self:UpdateNodes()
    self.RootUi:SwitchBg(XPracticeConfigs.PracticeMode.Basics)
end

function XUiPanelPracticeBasics:UpdateNodes()
    for i = 1, #self.BasicsChapter.StageId do
        local stageId = self.BasicsChapter.StageId[i]
        -- 是否开始
        local stageInfo = XDataCenter.FubenManager.GetStageInfo(stageId)
        local stageCfg = XDataCenter.FubenManager.GetStageCfg(stageId)

        if stageInfo.Unlock then
            -- 显示
            self:UpdateBasicsLine(i, true)
            self.BasicsStages[i].GameObject:SetActive(true)
            self.BasicsStages[i].Transform.parent.gameObject:SetActive(true)
            self.BasicsStages[i]:UpdateNode(stageId, XPracticeConfigs.PracticeMode.Basics)
        else
            local isActive = false
            for _, preStageId in pairs(stageCfg.PreStageId) do
                local preStageInfo = XDataCenter.FubenManager.GetStageInfo(preStageId)
                if preStageInfo.Passed then
                    -- 显示
                    self:UpdateBasicsLine(i, true)
                    self.BasicsStages[i].GameObject:SetActive(true)
                    self.BasicsStages[i].Transform.parent.gameObject:SetActive(true)
                    self.BasicsStages[i]:UpdateNode(stageId, XPracticeConfigs.PracticeMode.Basics)
                    isActive = true
                    break
                end
            end

            if not isActive then
                -- 隐藏
                self:UpdateBasicsLine(i, false)
                self.BasicsStages[i].GameObject:SetActive(false)
                self.BasicsStages[i].Transform.parent.gameObject:SetActive(false)
            end
        
        end

    end

    if self.BasicsScrollRect then
        self.BasicsScrollRect.horizontalNormalizedPosition = 1
    end
end

function XUiPanelPracticeBasics:UpdateBasicsLine(index, isActive)
    if self.BasicsLines[index - 1] then
        self.BasicsLines[index - 1].gameObject:SetActive(isActive)
    end
end
 
function XUiPanelPracticeBasics:PlayScrollViewMove(gridTransform)
    self.BasicsScrollRect.movementType = CS.UnityEngine.UI.ScrollRect.MovementType.Unrestricted
    local gridRect = gridTransform:GetComponent("RectTransform")
    self.BasicsViewPort.raycastTarget = false
    local diffX = gridRect.localPosition.x + self.BasicsContent.localPosition.x
    if diffX < XDataCenter.FubenMainLineManager.UiGridChapterMoveMinX or diffX > XDataCenter.FubenMainLineManager.UiGridChapterMoveMaxX then
        local tarPosX = XDataCenter.FubenMainLineManager.UiGridChapterMoveTargetX - gridRect.localPosition.x
        local tarPos = self.BasicsContent.localPosition
        tarPos.x = tarPosX
        XLuaUiManager.SetMask(true)
        XUiHelper.DoMove(self.BasicsContent, tarPos, XDataCenter.FubenMainLineManager.UiGridChapterMoveDuration, XUiHelper.EaseType.Sin, function()
            XLuaUiManager.SetMask(false)
        end)
    end
end

function XUiPanelPracticeBasics:OnPracticeDetailClose()
    self.BasicsScrollRect.movementType = CS.UnityEngine.UI.ScrollRect.MovementType.Elastic
    self.BasicsViewPort.raycastTarget = true
end
    

return XUiPanelPracticeBasics