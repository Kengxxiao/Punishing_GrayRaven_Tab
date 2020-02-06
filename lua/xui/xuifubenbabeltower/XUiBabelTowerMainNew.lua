local XUiBabelTowerMainNew = XLuaUiManager.Register(XLuaUi, "UiBabelTowerMainNew")
local XUiGridBabelStageItem = require("XUi/XUiFubenBabelTower/XUiGridBabelStageItem")
local XUiBabelStageDifficultyDialog = require("XUi/XUiFubenBabelTower/XUiBabelStageDifficultyDialog")

function XUiBabelTowerMainNew:OnAwake()
    self:Init()

    XEventManager.AddEventListener(XEventId.EVENT_BABEL_STAGE_INFO_ASYNC, self.RefreshMainUi, self)
    XEventManager.AddEventListener(XEventId.EVENT_BABEL_ACTIVITY_STATUS_CHANGED, self.OnActivityStatusChanged, self)
end

function XUiBabelTowerMainNew:OnDestroy()

    XEventManager.RemoveEventListener(XEventId.EVENT_BABEL_STAGE_INFO_ASYNC, self.RefreshMainUi, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_BABEL_ACTIVITY_STATUS_CHANGED, self.OnActivityStatusChanged, self)
end

function XUiBabelTowerMainNew:Init()
    self.BtnBack.CallBack = function() self:OnBtnBackClick() end
    self.BtnMainUi.CallBack = function() self:OnBtnMainUiClick() end
    self.BtnAchievement.CallBack = function() self:OnBtnAchievementClick() end
    self.BtnHelp.CallBack = function() self:OnBtnHelpClick() end

    self.DifficultyDialog = XUiBabelStageDifficultyDialog.New(self.PanelDifficulty, self)

    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.FreeGem, XDataCenter.ItemManager.ItemId.ActionPoint, XDataCenter.ItemManager.ItemId.Coin)
end

function XUiBabelTowerMainNew:OnBeginDrag(eventData)
    self.PanelTaskList:OnBeginDrag(eventData)
    self.IsDraging = true
    self.PreY = self.PanelTaskList.verticalNormalizedPosition
end

function XUiBabelTowerMainNew:OnBtnBackClick()
    self:Close()
end

function XUiBabelTowerMainNew:OnBtnMainUiClick()
    XLuaUiManager.RunMain()
end

function XUiBabelTowerMainNew:OnBtnAchievementClick()
    -- 时间限制，不在活动期间不给打开
    if not self.CurrentActivityNo or not XDataCenter.FubenBabelTowerManager.IsInActivityTime(self.CurrentActivityNo) then
        XUiManager.TipMsg(CS.XTextManager.GetText("BabelTowerNoneOpen"))
        return
    end

    XLuaUiManager.Open("UiBabelTowerTask")
end

function XUiBabelTowerMainNew:OnBtnHelpClick()
    XUiManager.ShowHelpTip("BabelTower")
end

function XUiBabelTowerMainNew:OnActivityStatusChanged()
    if not XLuaUiManager.IsUiShow("UiBabelTowerMainNew") then return end
    local curActivityNo = XDataCenter.FubenBabelTowerManager.GetCurrentActivityNo()
    if not curActivityNo or not XDataCenter.FubenBabelTowerManager.IsInActivityTime(curActivityNo) then
        XUiManager.TipMsg(CS.XTextManager.GetText("BabelTowerNoneOpen"))
        XLuaUiManager.RunMain()
    end
end

function XUiBabelTowerMainNew:OnEnable()
    self:OnActivityStatusChanged()
end

function XUiBabelTowerMainNew:OnStart()
    self.CurrentActivityNo = XDataCenter.FubenBabelTowerManager.GetCurrentActivityNo()
    self.CurrentActivityMaxScore = XDataCenter.FubenBabelTowerManager.GetCurrentActivityMaxScore()
    self.CurrentActivityTemplate = XFubenBabelTowerConfigs.GetBabelTowerActivityTemplateById(self.CurrentActivityNo)
    if not self.CurrentActivityTemplate then 
        return 
    end
    self.DifficultyDialog.GameObject:SetActiveEx(false)
    self:RefreshMainUi()

    self.PanelAsset.gameObject:SetActiveEx(true)
    XRedPointManager.AddRedPointEvent(self.RedAchievement, self.RefreshAchievementTaskRedDot, self, {XRedPointConditions.Types.CONDITION_TASK_TYPE}, XDataCenter.TaskManager.TaskType.BabelTower)
end

function XUiBabelTowerMainNew:RefreshAchievementTaskRedDot(count)
    self.RedAchievement.gameObject:SetActive(count >= 0)
end

function XUiBabelTowerMainNew:RefreshMainUi()
    self:UpdateStageDetails()
    self:UpdateStageScores()
end

function XUiBabelTowerMainNew:UpdateStageScores()
    local curScore, maxScore = XDataCenter.FubenBabelTowerManager.GetCurrentActivityScores()
    self.TxtTotalLevel.text = curScore
    self.TxtName.text = XFubenBabelTowerConfigs.GetActivityName(self.CurrentActivityNo)
    self.TxtHighest.text = CS.XTextManager.GetText("BabelTowerCurMaxScore", maxScore)
end

function XUiBabelTowerMainNew:UpdateStageDetails()
    if not self.StageGridChapter then self.StageGridChapter = {} end

    for i = 1, #self.CurrentActivityTemplate.StageId do
        local curStageId = self.CurrentActivityTemplate.StageId[i]
        if not self.StageGridChapter[i] then
            local go = self.PanelStageContent:Find(string.format("Stage%d", i))
            table.insert(self.StageGridChapter, XUiGridBabelStageItem.New(go, self, curStageId))
        end
        self.StageGridChapter[i].GameObject:SetActiveEx(true)
        self.StageGridChapter[i]:UpdateStageInfo(curStageId)
    end

    for i = #self.CurrentActivityTemplate.StageId + 1, #self.StageGridChapter do
        self.StageGridChapter[i].GameObject:SetActiveEx(false)
    end
end

-- 关卡点击
function XUiBabelTowerMainNew:OnStageClick(stageId, grid)

    local isStageUnlock, desc = XDataCenter.FubenBabelTowerManager.IsBabelStageUnlock(stageId)
    if not isStageUnlock then
        XUiManager.TipMsg(desc)
        return 
    end
    self:PlayScrollViewMove(grid.Transform)
    grid:SetStageItemPress(true)
    self.DifficultyDialog:OpenStageDialog(stageId)
end

function XUiBabelTowerMainNew:PlayScrollViewMove(gridTransform)
    self.PanelTaskListScrollRect.movementType = CS.UnityEngine.UI.ScrollRect.MovementType.Unrestricted
    local gridRect = gridTransform:GetComponent("RectTransform")
    self.ViewPort.raycastTarget = false
    local diffX = gridRect.localPosition.x + self.PanelStageContent.localPosition.x
    if diffX < XDataCenter.FubenMainLineManager.UiGridChapterMoveMinX or diffX > XDataCenter.FubenMainLineManager.UiGridChapterMoveMaxX then
        local tarPosX = XDataCenter.FubenMainLineManager.UiGridChapterMoveTargetX - gridRect.localPosition.x
        local tarPos = self.PanelStageContent.localPosition
        tarPos.x = tarPosX
        XLuaUiManager.SetMask(true)
        XUiHelper.DoMove(self.PanelStageContent, tarPos, XDataCenter.FubenMainLineManager.UiGridChapterMoveDuration, XUiHelper.EaseType.Sin, function()
            XLuaUiManager.SetMask(false)
        end)
    end
    self.PanelAsset.gameObject:SetActiveEx(false)
end

function XUiBabelTowerMainNew:OnPanelDifficultyClose()
    self.PanelTaskListScrollRect.movementType = CS.UnityEngine.UI.ScrollRect.MovementType.Elastic
    self.ViewPort.raycastTarget = true
    if self.CurrentActivityTemplate and self.StageGridChapter then
        for i = 1, #self.CurrentActivityTemplate.StageId do
            if self.StageGridChapter[i] then
                self.StageGridChapter[i]:SetStageItemPress(false)
            end
        end
    end
    self.PanelAsset.gameObject:SetActiveEx(true)
end