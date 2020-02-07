local XUiGridStage = require("XUi/XUiFubenMainLineChapter/XUiGridStage")

local XUiGridChapter = XClass()

local BFRT_ANIMATION_OPEN = "FubenStrongSh01Begin"
local BFRT_ANIMATION_END = "FubenStrongSh01End"
local MAX_STAGE_COUNT = 16

function XUiGridChapter:Ctor(rootUi, ui, autoChangeBgCb)
    self.RootUi = rootUi
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RectTransform = self.Transform:GetComponent("RectTransform")
    self.GridStageList = {}
    self.GridEggStageList = {}
    self.LineList = {}
    self:InitAutoScript()
    self.PanelStageContent = XUiHelper.TryGetComponent(self.Transform, "PaneStageList/ViewPort/PanelStageContent", "RectTransform")
    self.BoundSizeFitter = self.PanelStageContent:GetComponent("XBoundSizeFitter")
    self.ScrollRect = XUiHelper.TryGetComponent(self.Transform, "PaneStageList", "ScrollRect")

    --配置的格子位移超过某个阀值时，更换背景图片
    if autoChangeBgCb then
        self.AutoChangeBgCb = autoChangeBgCb
        local behaviour = self.GameObject:AddComponent(typeof(CS.XLuaBehaviour))
        if self.Update then
            behaviour.LuaUpdate = function() self:Update() end
        end
    end

    -- ScrollRect的点击和拖拽会触发关闭详细面板
    self:RegisterClickEvent(self.ScrollRect, handler(self, self.CancelSelect))
    local dragProxy = self.ScrollRect.gameObject:AddComponent(typeof(CS.XUguiDragProxy))
    dragProxy:RegisterHandler(handler(self, self.OnDragProxy))
    self:OnEnable()
end

function XUiGridChapter:InitAutoChangeBgComponents()
    local datumLinePrecent = XDataCenter.FubenActivityBranchManager.GetChapterDatumLinePrecent(self.Chapter.Id)
    if not datumLinePrecent or datumLinePrecent == 0 then return end

    --阀值为滚动容器去掉自适应扩展的padding宽度之后的实际宽度/2
    -- local padding = self.BoundSizeFitter.padding
    -- local contentWidth = self.PanelStageContent.rect.width
    -- local realWidth = contentWidth - padding.left - padding.right
    --阀值修改为可视区中心
    local viewPortRect = XUiHelper.TryGetComponent(self.Transform, "PaneStageList/ViewPort", "RectTransform")
    if not viewPortRect then return end
    local realWidth = viewPortRect.rect.width
    self.LimitPosX = realWidth * datumLinePrecent
end

function XUiGridChapter:RefreshAutoChangeBgStageIndex()
    if not self.LimitPosX then return end

    --关卡格子相对于阀值点的位置
    local stageIndex = XDataCenter.FubenActivityBranchManager.GetChapterMoveStageIndex(self.Chapter.Id)
    if not stageIndex or stageIndex == 0 then return end

    local stageParent = self.PanelStageContent.transform:Find("Stage" .. stageIndex):GetComponent("RectTransform")
    if XTool.UObjIsNil(stageParent) then
        XLog.Error("XUiGridChapter:RefreshAutoChangeBgStageIndex error:stage not exist,stageIndex is:" .. stageIndex)
        return
    end
    if not stageParent.gameObject.activeSelf then self.FirstSetBg = true return end
    self.StagePosX = stageParent.anchoredPosition.x

    --滚动容器移动距离
    local delta = self.PanelStageContent.anchoredPosition.x
    delta = self.StagePosX > self.LimitPosX and -delta or delta

    --标记是否满足超过阀值的条件
    self.AutoChangeBgFlag = self.StagePosX + delta > self.LimitPosX
    self.FirstSetBg = self.AutoChangeBgFlag
end

--配置的格子滑动位移超过某个阀值时触发一次回调
function XUiGridChapter:Update()
    if self.AutoChangeBgFlag == nil then return end

    local cbParamFlag = self.AutoChangeBgFlag--回调参数
    local delta = self.PanelStageContent.anchoredPosition.x--滚动容器移动距离
    local fitCondition = self.StagePosX + delta > self.LimitPosX--滑动距离条件判断

    --配置的格子在阀值左边还是右边
    local moveDirectLeft = self.StagePosX > self.LimitPosX
    if moveDirectLeft then
        cbParamFlag = not cbParamFlag
        delta = -delta
        fitCondition = not fitCondition
    end

    --滑动距离条件判断
    if fitCondition then
        if self.AutoChangeBgFlag then
            --位移正向超过阀值回调
            self.AutoChangeBgCb(cbParamFlag)
            self.AutoChangeBgFlag = false
        end
    else
        if not self.AutoChangeBgFlag then
            --位移反向超过阀值回调
            self.AutoChangeBgCb(cbParamFlag)
            self.AutoChangeBgFlag = true
        end
    end
end

function XUiGridChapter:OnDragProxy(dragType)
    if dragType == 0 then
        self:OnScrollRectBeginDrag()
    elseif dragType == 2 then
        self:OnScrollRectEndDrag()
    end
end

function XUiGridChapter:OnScrollRectBeginDrag()
    if self:CancelSelect() then
        self.ScrollRect.enabled = false
    end
end

function XUiGridChapter:OnScrollRectEndDrag()
    self.ScrollRect.enabled = true
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiGridChapter:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiGridChapter:AutoInitUi()
    self.SViewStageList = XUiHelper.TryGetComponent(self.Transform, "SViewStageList", "ScrollRect")
end

function XUiGridChapter:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiGridChapter:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiGridChapter:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiGridChapter:AutoAddListener()
    self:RegisterClickEvent(self.SViewStageList, self.OnSViewStageListClick)
end
-- auto
function XUiGridChapter:OnSViewStageListClick(eventData)

end

function XUiGridChapter:ScrollRectRollBack()
    -- 滚动容器回弹
    local width = self.RectTransform.rect.width
    local innerWidth = self.PanelStageContent.rect.width
    innerWidth = innerWidth < width and width or innerWidth
    local diff = innerWidth - width
    local tarPosX
    if self.PanelStageContent.localPosition.x < -width / 2 - diff then
        tarPosX = -width / 2 - diff
    elseif self.PanelStageContent.localPosition.x > -width / 2 then
        tarPosX = -width / 2
    else
        -- self.ScrollRect.movementType = CS.UnityEngine.UI.ScrollRect.MovementType.Unrestricted
        self.ScrollRect.movementType = CS.UnityEngine.UI.ScrollRect.MovementType.Elastic
        return false
    end

    self:PlayScrollViewMoveBack(tarPosX)
    return true
end

function XUiGridChapter:PlayScrollViewMoveBack(tarPosX)
    local tarPos = self.PanelStageContent.localPosition
    tarPos.x = tarPosX
    XLuaUiManager.SetMask(true)

    XUiHelper.DoMove(self.PanelStageContent, tarPos, XDataCenter.FubenMainLineManager.UiGridChapterMoveDuration, XUiHelper.EaseType.Sin, function()
        -- self.ScrollRect.movementType = CS.UnityEngine.UI.ScrollRect.MovementType.Unrestricted
        self.ScrollRect.movementType = CS.UnityEngine.UI.ScrollRect.MovementType.Elastic
        XLuaUiManager.SetMask(false)
    end)
end

function XUiGridChapter:GetGridByStageId(stageId)
    if self.NormalStageList then
        for k, v in pairs(self.NormalStageList) do
            if v == stageId then
                return self.GridStageList[k]
            end
        end
    end
    if self.EggStageList then
        for k, v in pairs(self.EggStageList) do
            if v == stageId then
                return self.GridEggStageList[k]
            end
        end
    end
end

function XUiGridChapter:GoToStage(stageId)
    local grid = self:GetGridByStageId(stageId)
    if not grid then
        return
    end
    local gridTf = grid.Parent.gameObject:GetComponent("RectTransform")
    local posX = self.PanelStageContent.localPosition.x
    posX = gridTf.localPosition.x - self.RectTransform.rect.width / 2
    self.ScrollRect.horizontalNormalizedPosition = 0
    local diff = (self.ScrollRect.content.rect.width - self.RectTransform.rect.width)
    self.ScrollRect.horizontalNormalizedPosition = posX / (1 * self.ScrollRect.content.rect.width - self.RectTransform.rect.width)
end

-- chapter 组件内容更新
function XUiGridChapter:UpdateChapterGrid(data)
    self.Chapter = data.Chapter
    self.HideStageCb = data.HideStageCb
    self.ShowStageCb = data.ShowStageCb
    self.EggStageList = {}
    self.NormalStageList = {}
    for k, v in pairs(data.StageList) do
        local stageCfg = XDataCenter.FubenManager.GetStageCfg(v)
        if self:IsEggStage(stageCfg) then
            local eggNum = self:GetEggNum(data.StageList, stageCfg)
            if eggNum ~= 0 then
                local egg = { Id = v, Num = eggNum }
                table.insert(self.EggStageList, egg)
            end
        else
            table.insert(self.NormalStageList, v)
        end
    end

    self:SetStageList()
    self:InitAutoChangeBgComponents()
    self:RefreshAutoChangeBgStageIndex()
end

-- 根据stageId选中
function XUiGridChapter:ClickStageGridByStageId(selectStageId)
    if not selectStageId then return end
    local IsEggStage = false
    local stageInfo = XDataCenter.FubenManager.GetStageInfo(selectStageId)
    if not stageInfo.IsOpen then return end

    local index = 0
    for i = 1, #self.NormalStageList do
        local stageId = self.NormalStageList[i]
        if selectStageId == stageId then
            index = i
            break
        end
    end
    for i = 1, #self.EggStageList do
        local stageId = self.EggStageList[i]
        if selectStageId == stageId then
            index = i
            IsEggStage = true
            break
        end
    end

    if index ~= 0 then
        if IsEggStage then
            self:ClickEggStageGridByIndex(index)
        else
            self:ClickStageGridByIndex(index)
        end
    end
end

function XUiGridChapter:GetEggNum(stageList, eggStageCfg)
    for k, v in pairs(stageList) do
        if v == eggStageCfg.PreStageId[1] then --1为1号前置关卡
            return k
        end
    end
    return 0
end

function XUiGridChapter:SetStageList()
    if self.NormalStageList == nil then
        XLog.Error("Chapter have no id " .. self.Chapter.ChapterId)
        return
    end

    -- 连线
    for i = 1, #self.NormalStageList - 1 do
        if not self.LineList[i] then
            local line = self.PanelStageContent.transform:Find("Line" .. i)
            self.LineList[i] = not XTool.UObjIsNil(line) and line
        end
    end

    -- 初始化副本显示列表，i作为order id，从1开始
    for i = 1, #self.NormalStageList do
        local stageId = self.NormalStageList[i]
        local stageCfg = XDataCenter.FubenManager.GetStageCfg(stageId)
        local stageInfo = XDataCenter.FubenManager.GetStageInfo(stageId)

        if stageInfo.IsOpen then
            local grid = self.GridStageList[i]
            if not grid then
                local uiName
                if stageInfo.Type == XDataCenter.FubenManager.StageType.ActivtityBranch then
                    uiName = "GridBranchStage"
                else
                    uiName = "GridStage"
                end
                uiName = uiName .. stageCfg.StageGridStyle

                local parent = self.PanelStageContent.transform:Find("Stage" .. i)
                local prefabName = CS.XGame.ClientConfig:GetString(uiName)
                local prefab = parent:LoadPrefab(prefabName)

                grid = XUiGridStage.New(self.RootUi, prefab, handler(self, self.ClickStageGrid), XFubenConfigs.FUBENTYPE_NORMAL)
                grid.Parent = parent
                self.GridStageList[i] = grid
            end

            grid:UpdateStageMapGrid(stageCfg, self.Chapter.OrderId)
            grid.Parent.gameObject:SetActive(true)

            self:SetLineActive(i, true)
        end
    end

    for i = 1, #self.EggStageList do
        local stageId = self.EggStageList[i].Id
        local stageCfg = XDataCenter.FubenManager.GetStageCfg(stageId)
        local stageInfo = XDataCenter.FubenManager.GetStageInfo(stageId)

        if stageInfo.IsOpen then
            if XDataCenter.FubenManager.GetUnlockHideStageById(stageId) then
                local grid = self.GridEggStageList[i]
                if not grid then
                    local uiName = "GridStageSquare"
                    local parentsParent = self.PanelStageContent.transform:Find("Stage" .. self.EggStageList[i].Num)
                    local parent = self.PanelStageContent.transform:Find("Stage" .. self.EggStageList[i].Num .. "/EggStage")
                    local prefabName = CS.XGame.ClientConfig:GetString(uiName)
                    local prefab = parent:LoadPrefab(prefabName)
                    grid = XUiGridStage.New(self.RootUi, prefab, handler(self, self.ClickStageGrid), XFubenConfigs.FUBENTYPE_NORMAL)
                    grid.Parent = parentsParent
                    self.GridEggStageList[i] = grid
                end
                grid:UpdateStageMapGrid(stageCfg, self.Chapter.OrderId)
            end
        end
    end

    local activeStageCount = #self.GridStageList
    for i = activeStageCount + 1, MAX_STAGE_COUNT do
        local parent = self.PanelStageContent.transform:Find("Stage" .. i)
        if parent then
            parent.gameObject:SetActive(false)
        end

        self:SetLineActive(i, false)
    end

    -- 移动至ListView正确的位置
    if self.BoundSizeFitter then
        self.BoundSizeFitter:SetLayoutHorizontal()
    end
end

function XUiGridChapter:SetLineActive(index, active)
    local line = self.LineList[index - 1]
    if line then
        line.gameObject:SetActive(active)
    end
end

-- 选中一个 stage grid
function XUiGridChapter:ClickStageGrid(grid)
    local curGrid = self.CurStageGrid
    if curGrid and curGrid.Stage.StageId == grid.Stage.StageId then
        return
    end

    local stageInfo = XDataCenter.FubenManager.GetStageInfo(grid.Stage.StageId)
    if not stageInfo.Unlock then
        XUiManager.TipMsg(XDataCenter.FubenManager.GetFubenOpenTips(grid.Stage.StageId))
        return
    end

    -- 取消上一个选择
    if curGrid then
        curGrid:SetStageActive()
    end

    -- 选中当前选择
    grid:SetStageSelect()

    grid:SetStoryStageSelect()
    -- 滚动容器自由移动
    self.ScrollRect.movementType = CS.UnityEngine.UI.ScrollRect.MovementType.Unrestricted

    -- 面板移动
    self:PlayScrollViewMove(grid)

    -- 选中回调
    if self.ShowStageCb then
        self.ShowStageCb(grid.Stage, grid.ChapterOrderId)
    end

    self.CurStageGrid = grid
end

-- 返回滚动容器是否动画回弹
function XUiGridChapter:CancelSelect()
    if not self.CurStageGrid then
        return false
    end
    self.CurStageGrid:SetStageActive()
    self.CurStageGrid:SetStoryStageActive()
    self.CurStageGrid = nil

    if self.HideStageCb then
        self.HideStageCb()
    end
    return self:ScrollRectRollBack()
end

function XUiGridChapter:PlayScrollViewMove(grid)
    -- 动画
    local gridTf = grid.Parent.gameObject:GetComponent("RectTransform")
    local diffX = gridTf.localPosition.x + self.PanelStageContent.localPosition.x
    if diffX < XDataCenter.FubenMainLineManager.UiGridChapterMoveMinX or diffX > XDataCenter.FubenMainLineManager.UiGridChapterMoveMaxX then
        local tarPosX = XDataCenter.FubenMainLineManager.UiGridChapterMoveTargetX - gridTf.localPosition.x
        local tarPos = self.PanelStageContent.localPosition
        tarPos.x = tarPosX
        XLuaUiManager.SetMask(true)
        XUiHelper.DoMove(self.PanelStageContent, tarPos, XDataCenter.FubenMainLineManager.UiGridChapterMoveDuration, XUiHelper.EaseType.Sin, function()
            XLuaUiManager.SetMask(false)
        end)
    end
end

function XUiGridChapter:IsEggStage(stageCfg)
    return stageCfg.StageType == XFubenConfigs.STAGETYPE_STORYEGG or stageCfg.StageType == XFubenConfigs.STAGETYPE_FIGHTEGG
end

-- 模拟点击一个关卡
function XUiGridChapter:ClickStageGridByIndex(index)
    local grid = self.GridStageList[index]
    self:ClickStageGrid(grid)
end

function XUiGridChapter:ClickEggStageGridByIndex(index)
    local grid = self.GridEggStageList[index]
    self:ClickStageGrid(grid)
end

function XUiGridChapter:Show()
    if self.GameObject.activeSelf == true then return end
    self.GameObject:SetActive(true)
end

function XUiGridChapter:Hide()
    if not self.GameObject:Exist() or self.GameObject.activeSelf == false then return end
    self.GameObject:SetActive(false)
end

function XUiGridChapter:OnEnable()
    if self.Enabled then
        return
    end
    if self.GridStageList then
        for k, v in pairs(self.GridStageList) do
            v:OnEnable()
        end
    end
    if self.GridEggStageList then
        for k, v in pairs(self.GridEggStageList) do
            v:OnEnable()
        end
    end
    self.Enabled = true
end

function XUiGridChapter:OnDisable()
    if not self.Enabled then
        return
    end
    if self.GridStageList then
        for k, v in pairs(self.GridStageList) do
            v:OnDisable()
        end
    end
    if self.GridEggStageList then
        for k, v in pairs(self.GridEggStageList) do
            v:OnDisable()
        end
    end
    self.Enabled = false
end

return XUiGridChapter