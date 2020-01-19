local XUiFubenChristmasMainLineChapter = XLuaUiManager.Register(XLuaUi, "UiFubenChristmasMainLineChapter")
local FESTIVAL_FIGHT_DETAIL = "UiFubenChristmasStageDetail"
local FESTIVAL_STORY_DETAIL = "UiStoryChristmasStageDetail"
local XUguiDragProxy = CS.XUguiDragProxy

function XUiFubenChristmasMainLineChapter:OnAwake()
    self:InitUiView()
    XEventManager.AddEventListener(XEventId.EVENT_ON_FESTIVAL_CHANGED, self.RefreshFestivalNodes, self)
end

function XUiFubenChristmasMainLineChapter:OnEnable()
    if self.PaneStageList and self.NeedReset then
        self.PaneStageList.movementType = CS.UnityEngine.UI.ScrollRect.MovementType.Elastic
    else
        self.NeedReset = true
    end

    if self.ChapterId == XFestivalActivityConfig.ActivityId.MainLine then
        XSoundManager.PlaySoundDoNotInterrupt(XSoundManager.UiBasicsMusic.UiActivity_Jidi_BGM)
    elseif self.ChapterId == XFestivalActivityConfig.ActivityId.NewYear then
        XSoundManager.PlaySoundDoNotInterrupt(XSoundManager.UiBasicsMusic.UiActivity_NewYear_BGM)
    end
end

function XUiFubenChristmasMainLineChapter:OnDestroy()
    self.IsOpenDetails = nil
    self:StopActivityTimer()
    XEventManager.RemoveEventListener(XEventId.EVENT_ON_FESTIVAL_CHANGED, self.RefreshFestivalNodes, self)
end

function XUiFubenChristmasMainLineChapter:InitUiView()
    self.BtnBack.CallBack = function() self:OnBtnBackClick() end
    self.BtnMainUi.CallBack = function() self:OnBtnMainUiClick() end
    self.BtnCloseDetail.CallBack = function() self:OnBntCloseDetailClick() end

end

function XUiFubenChristmasMainLineChapter:OnBtnBackClick()
    self:Close()
end

function XUiFubenChristmasMainLineChapter:OnBtnMainUiClick()
    XLuaUiManager.RunMain()
end

function XUiFubenChristmasMainLineChapter:OnStart(chapterId, defaultStageId)
    self.ChapterId = chapterId
    self.ChapterTemplate = XFestivalActivityConfig.GetFestivalById(self.ChapterId)
    self:SetUiData(self.ChapterTemplate)
    self.NeedReset = false

    if defaultStageId then
        self:OpenDefaultStage(defaultStageId)
    end
end

function XUiFubenChristmasMainLineChapter:OpenDefaultStage(stageId)
    if self.FestivalStageIds and self.FestivalStages then
        for i = 2, #self.FestivalStageIds do
            if self.FestivalStageIds[i] == stageId and self.FestivalStages[i] then
                self.FestivalStages[i]:OnBtnStageClick()
                break
            end
        end
    end
end

function XUiFubenChristmasMainLineChapter:SetUiData(chapterTemplate)

    -- 初始化prefab组件
    local chapterGameObject = self.PanelChapter:LoadPrefab(chapterTemplate.FubenPrefab)
    local uiObj = chapterGameObject.transform:GetComponent("UiObject")
    for i = 0, uiObj.NameList.Count - 1 do
        self[uiObj.NameList[i]] = uiObj.ObjList[i]
    end

    local dragProxy = self.PaneStageList:GetComponent(typeof(XUguiDragProxy))
    if not dragProxy then
        dragProxy = self.PaneStageList.gameObject:AddComponent(typeof(XUguiDragProxy))
    end
    dragProxy:RegisterHandler(handler(self, self.OnDragProxy))

    self.FestivalStageIds = self:GetFakeStages(chapterTemplate)
    -- 线条处理
    self:HandleStageLines()
    -- 关卡处理
    self:HandleStages()
    -- 彩蛋处理
    self:HandleEggStage()
    -- 界面信息
    self:SwitchFestivalBg(chapterTemplate)
    local now = XTime.Now()
    local endTimeSecond = CS.XDate.GetTime(chapterTemplate.EndTimeStr)
    self.TxtDay.text = XUiHelper.GetTime(endTimeSecond - now, XUiHelper.TimeFormatType.ACTIVITY)
    self:CreateActivityTimer(now, endTimeSecond)
    self.TxtChapterName.text = chapterTemplate.Name
    self.TxtChapter.text = (self.ChapterId >= 10) and self.ChapterId or string.format("0%d", self.ChapterId)
end

function XUiFubenChristmasMainLineChapter:HandleStages()
    self.FestivalStages = {}
    for i = 1, #self.FestivalStageIds do
        local itemStage = self.PanelStageContent:Find(string.format("Stage%d", i))
        if not itemStage then
            XLog.Error("XUiFubenChristmasMainLineChapter:HandleStages() error: prefab not found a child name:" .. string.format("Stage%d", i))
            return
        end
        -- 组件初始化
        itemStage.gameObject:SetActiveEx(true)
        self.FestivalStages[i] = XUiFestivalStageItem.New(self, itemStage)
        self.FestivalStages[i]:UpdateNode(self.ChapterTemplate.Id, self.FestivalStageIds[i])
    end
    self:UpdateNodeLines()
    -- 隐藏多余组件
    local indexStage = #self.FestivalStageIds + 1
    local extraStage = self.PanelStageContent:Find(string.format("Stage%d", indexStage))
    while extraStage do
        extraStage.gameObject:SetActiveEx(false)
        indexStage = indexStage + 1
        extraStage = self.PanelStageContent:Find(string.format("Stage%d", indexStage))
    end
end

function XUiFubenChristmasMainLineChapter:HandleStageLines()
    self.FestivalStageLine = {}
    for i = 1, #self.FestivalStageIds do
        local itemLine = self.PanelStageContent:Find(string.format("Line%d", i))
        if not itemLine then
            XLog.Error("XUiFubenChristmasMainLineChapter:SetUiData() error: prefab not found a child name:" .. string.format("Line%d", i))
            return
        end
        itemLine.gameObject:SetActiveEx(false)
        self.FestivalStageLine[i] = itemLine
    end

    -- 隐藏多余组件
    local indexLine = #self.FestivalStageIds + 1
    local extraLine = self.PanelStageContent:Find(string.format("Line%d", indexLine))
    while extraLine do
        extraLine.gameObject:SetActiveEx(false)
        indexLine = indexLine + 1
        extraLine = self.PanelStageContent:Find(string.format("Line%d", indexLine))
    end
end

-- 更新刷新
function XUiFubenChristmasMainLineChapter:RefreshFestivalNodes()
    if not self.ChapterTemplate or not self.FestivalStageIds then return end
    for i = 1, #self.FestivalStageIds do
        self.FestivalStages[i]:UpdateNode(self.ChapterTemplate.Id, self.FestivalStageIds[i])
    end
    self:UpdateNodeLines()
    -- 移动至ListView正确的位置
    if self.PanelStageContentSizeFitter then
        self.PanelStageContentSizeFitter:SetLayoutHorizontal()
    end
end

-- 更新节点线条
function XUiFubenChristmasMainLineChapter:UpdateNodeLines()
    if not self.ChapterTemplate or not self.FestivalStageIds then return end
    local stageLength = #self.FestivalStageIds
    for i = 2, stageLength do
        local isOpen, description = XDataCenter.FubenFestivalActivityManager.CheckFestivalStageOpen(self.FestivalStageIds[i])
        self:SetStageLineActive(i - 1, isOpen)
    end
    self:SetStageLineActive(1, false)
    self:SetStageLineActive(stageLength, false)
end

function XUiFubenChristmasMainLineChapter:SetStageLineActive(index, isActive)
    if self.FestivalStageLine[index] then
        self.FestivalStageLine[index].gameObject:SetActiveEx(isActive)
    end
end

function XUiFubenChristmasMainLineChapter:HandleEggStage()
    local eggStageIndex = 1
    local eggStageId = self.FestivalStageIds[eggStageIndex]
    if XDataCenter.FubenFestivalActivityManager.IsEgg(eggStageId) then
        -- 彩蛋处理
        local isUnlock, description = XDataCenter.FubenFestivalActivityManager.CheckFestivalStageOpen(eggStageId)
        self.FestivalStages[eggStageIndex].GameObject:SetActiveEx(isUnlock)
        local stageCfg = XDataCenter.FubenManager.GetStageCfg(eggStageId)
        if isUnlock and stageCfg then
            if stageCfg.PreStageId and stageCfg.PreStageId[1] then
                for i = 1, #self.FestivalStageIds do
                    if stageCfg.PreStageId[1] == self.FestivalStageIds[i] then
                        self.FestivalStages[eggStageIndex]:ResetItemPosition(self.FestivalStages[i].Transform.localPosition)
                        break
                    end
                end
            end
        end
    else
        -- 非彩蛋
        self.FestivalStages[eggStageIndex].GameObject:SetActiveEx(false)
    end
    self.FestivalStageLine[eggStageIndex].gameObject:SetActiveEx(false)
end

-- 选中关卡
function XUiFubenChristmasMainLineChapter:UpdateNodesSelect(stageId)
    local stageIds = self.FestivalStageIds
    for i = 1, #stageIds do
        if self.FestivalStages[i] then
            self.FestivalStages[i]:SetNodeSelect(stageIds[i] == stageId)
        end
    end
end

-- 取消选中
function XUiFubenChristmasMainLineChapter:ClearNodesSelect()
    for i = 1, #self.FestivalStageIds do
        if self.FestivalStages[i] then
            self.FestivalStages[i]:SetNodeSelect(false)
        end
    end
end

-- 没有彩蛋则增加一个假彩蛋
function XUiFubenChristmasMainLineChapter:GetFakeStages(chapterTemplate)
    local stageIds = {}
    for i = 1, #self.ChapterTemplate.StageId do
        stageIds[i] = self.ChapterTemplate.StageId[i]
    end
    if not XDataCenter.FubenFestivalActivityManager.IsEgg(stageIds[1]) then
        table.insert(stageIds, 1, stageIds[1])
    end
    return stageIds
end

-- 打开剧情，战斗详情
function XUiFubenChristmasMainLineChapter:OpenStageDetails(stageId, festivalId)
    self.IsOpenDetails = true
    local detailType = XDataCenter.FubenFestivalActivityManager.GetStageShowType(stageId)

    if detailType == XDataCenter.FubenFestivalActivityManager.StageFuben then
        self:OpenOneChildUi(FESTIVAL_FIGHT_DETAIL, self)
        self:FindChildUiObj(FESTIVAL_FIGHT_DETAIL):SetStageDetail(stageId, festivalId)
        if XLuaUiManager.IsUiShow(FESTIVAL_STORY_DETAIL) then
            self:FindChildUiObj(FESTIVAL_STORY_DETAIL):Close()
        end
    end

    if detailType == XDataCenter.FubenFestivalActivityManager.StageStory then
        self:OpenOneChildUi(FESTIVAL_STORY_DETAIL, self)
        self:FindChildUiObj(FESTIVAL_STORY_DETAIL):SetStageDetail(stageId, festivalId)
        if XLuaUiManager.IsUiShow(FESTIVAL_FIGHT_DETAIL) then
            self:FindChildUiObj(FESTIVAL_FIGHT_DETAIL):Close()
        end
    end

    self.PanelStageContentRaycast.raycastTarget = false
end

-- 关闭剧情，战斗详情
function XUiFubenChristmasMainLineChapter:CloseStageDetails()
    self.IsOpenDetails = false
    if XLuaUiManager.IsUiShow(FESTIVAL_STORY_DETAIL) then
        self:FindChildUiObj(FESTIVAL_STORY_DETAIL):Close()
    end

    if XLuaUiManager.IsUiShow(FESTIVAL_FIGHT_DETAIL) then
        self:FindChildUiObj(FESTIVAL_FIGHT_DETAIL):Close()
    end

    self.PanelStageContentRaycast.raycastTarget = true
    self:ClearNodesSelect()
    self.PaneStageList.movementType = CS.UnityEngine.UI.ScrollRect.MovementType.Elastic
end

function XUiFubenChristmasMainLineChapter:OnBntCloseDetailClick()
    self:CloseStageDetails()
end

function XUiFubenChristmasMainLineChapter:OnDragProxy(dragType)
    if self.IsOpenDetails and dragType == 0 then
        self:CloseStageDetails()
    end
end

function XUiFubenChristmasMainLineChapter:PlayScrollViewMove(gridTransform)
    self.PaneStageList.movementType = CS.UnityEngine.UI.ScrollRect.MovementType.Unrestricted
    local gridRect = gridTransform:GetComponent("RectTransform")
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
end

function XUiFubenChristmasMainLineChapter:EndScrollViewMove(currStageId)
    self.PaneStageList.movementType = CS.UnityEngine.UI.ScrollRect.MovementType.Elastic
end

-- 背景
function XUiFubenChristmasMainLineChapter:SwitchFestivalBg(festivalTemplate)
    if not festivalTemplate or not festivalTemplate.MainBackgound then return end
    self.RImgFestivalBg:SetRawImage(festivalTemplate.MainBackgound)
end

-- 计时器
function XUiFubenChristmasMainLineChapter:CreateActivityTimer(startTime, endTime)
    local time = XTime.Now()
    self:StopActivityTimer()
    self.ActivityTimer = CS.XScheduleManager.ScheduleForever(function(...)
        time = XTime.Now()
        if time > endTime then
            self:Close()
            return
        end
        self.TxtDay.text = XUiHelper.GetTime(endTime - time, XUiHelper.TimeFormatType.ACTIVITY)
    end, CS.XScheduleManager.SECOND, 0)
end

function XUiFubenChristmasMainLineChapter:StopActivityTimer()
    if self.ActivityTimer then
        CS.XScheduleManager.UnSchedule(self.ActivityTimer)
        self.ActivityTimer = nil
    end
end