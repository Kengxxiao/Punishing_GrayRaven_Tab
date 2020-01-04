XUiPanelChallengeChapter = XClass()

function XUiPanelChallengeChapter:Ctor(ui, rootUi)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    self:InitAutoScript()
    self.BoundSizeFitter = self.UiContent:GetComponent("XBoundSizeFitter")
    self.GridChallangeList = {}
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelChallengeChapter:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiPanelChallengeChapter:AutoInitUi()
    self.GridChallengeItem = self.Transform:Find("GridChallengeItem")
    self.SViewChallange = self.Transform:Find("SViewChallange"):GetComponent("ScrollRect")
    self.UiContent = self.Transform:Find("SViewChallange/Viewport/UiContent")
end

function XUiPanelChallengeChapter:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelChallengeChapter:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelChallengeChapter:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelChallengeChapter:AutoAddListener()
end
-- auto


function XUiPanelChallengeChapter:UpdateChallengeGrid(data)
    self.ChallengeStageDataList = data
    local index = 0
    for i=1, #self.ChallengeStageDataList do
        local grid = self.GridChallangeList[i]
        if not grid then
            local cell = self.UiContent.transform:Find(string.format("GridChallengeItem%d", i))
            if not cell then
                XLog.Error("XUiPanelChallengeChapter:UpdateChallengeGrid error: prefab not found a child name : " .. string.format("GridChallengeItem%d", i))
            end
            grid = XUiGridChallengeItem.New(cell, self.RootUi, i, function(idx) self:OnChallengeItemClick(idx) end)
            self.GridChallangeList[i] = grid
        end

        grid:UpdateChallengeGridInfo(self.ChallengeStageDataList[i])
        grid.GameObject:SetActive(true)
        index = i
    end

    index = index + 1
    local hideGrid = self.UiContent.transform:Find(string.format("GridChallengeItem%d", index))
    while hideGrid do
        hideGrid.gameObject:SetActive(false)
        index = index + 1
        hideGrid = self.UiContent.transform:Find(string.format("GridChallengeItem%d", index))
    end

    -- [跳到最后开放的位置]
    if self.SViewChallange then
        self.SViewChallange.horizontalNormalizedPosition = 1
    end
end

function XUiPanelChallengeChapter:OnChallengeItemClick(i)
    local grid = self.GridChallangeList[i]
    if not grid then return end
    self:PlayScrollViewMove(grid)
end

function XUiPanelChallengeChapter:OnPrequelDetailClosed()
    self.SViewChallange.movementType = CS.UnityEngine.UI.ScrollRect.MovementType.Elastic
end

function XUiPanelChallengeChapter:PlayScrollViewMove(grid)
    -- 跟主线一样的动画
    self.SViewChallange.movementType = CS.UnityEngine.UI.ScrollRect.MovementType.Unrestricted
    local gridRect = grid.GameObject:GetComponent("RectTransform")
    local diffX = gridRect.localPosition.x + self.UiContent.localPosition.x
    if diffX < XDataCenter.FubenMainLineManager.UiGridChapterMoveMinX or diffX > XDataCenter.FubenMainLineManager.UiGridChapterMoveMaxX then
        local tarPosX = XDataCenter.FubenMainLineManager.UiGridChapterMoveTargetX - gridRect.localPosition.x
        local tarPos = self.UiContent.localPosition
        tarPos.x = tarPosX
        XLuaUiManager.SetMask(true)
        XUiHelper.DoMove(self.UiContent, tarPos, XDataCenter.FubenMainLineManager.UiGridChapterMoveDuration, XUiHelper.EaseType.Sin, function()
            XLuaUiManager.SetMask(false)
        end)
    end
end

function XUiPanelChallengeChapter:UpdateItems()
    for i=1, #self.ChallengeStageDataList do
        if self.GridChallangeList[i] then
            self.GridChallangeList[i]:UpdateAutoFightStatus()
        end
    end
end


function XUiPanelChallengeChapter:Show()
    if self.GameObject.activeSelf == true then return end
    self.GameObject:SetActive(true)
end

function XUiPanelChallengeChapter:Hide()
    if self.GameObject.activeSelf == false then return end
    self.GameObject:SetActive(false)
end

return XUiPanelChallengeChapter
