XUiGridPrequelPlotTab = XClass()

function XUiGridPrequelPlotTab:Ctor(ui, rootUi, index)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    self.Index = index
    self:InitAutoScript()
    self.TogClick = self.Transform:GetComponent("Toggle")
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiGridPrequelPlotTab:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiGridPrequelPlotTab:AutoInitUi()
    self.PanelTabUnSelect = self.Transform:Find("PanelTabUnSelect")
    self.ImgUnSelect = self.Transform:Find("PanelTabUnSelect/ImgUnSelect"):GetComponent("Image")
    self.TxtUnSelectTitle = self.Transform:Find("PanelTabUnSelect/TxtUnSelectTitle"):GetComponent("Text")
    self.PanelTabSelect = self.Transform:Find("PanelTabSelect")
    self.ImgSelect = self.Transform:Find("PanelTabSelect/ImgSelect"):GetComponent("Image")
    self.TxtSelectTitle = self.Transform:Find("PanelTabSelect/TxtSelectTitle"):GetComponent("Text")
    self.PanelTabLock = self.Transform:Find("PanelTabLock")
    self.ImgUnSelectA = self.Transform:Find("PanelTabLock/ImgUnSelect"):GetComponent("Image")
    self.ImgLock = self.Transform:Find("PanelTabLock/ImgLock"):GetComponent("Image")
    self.TxtLockTitle = self.Transform:Find("PanelTabLock/TxtLockTitle"):GetComponent("Text")
    self.ImgNewCheckPoint = self.Transform:Find("ImgNewCheckPoint"):GetComponent("Image")
end

function XUiGridPrequelPlotTab:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiGridPrequelPlotTab:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiGridPrequelPlotTab:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiGridPrequelPlotTab:AutoAddListener()
end
-- auto

function XUiGridPrequelPlotTab:RegisterClick(clickEvent, clear)
    self:RegisterClickEvent(self.TogClick, function() clickEvent(self.Index) end, clear)
end

function XUiGridPrequelPlotTab:UpdateStates(chapterId)
    self.ChapterId = chapterId
    local chapterData = XPrequelConfigs.GetPrequelChapterById(chapterId)
    self.TxtUnSelectTitle.text = chapterData.ChapterName
    self.TxtSelectTitle.text = chapterData.ChapterName
    self.TxtLockTitle.text = chapterData.ChapterName

    -- 处理锁住+活动的情况
    self.PanelTabLock.gameObject:SetActive(false)
    self.ImgNewCheckPoint.gameObject:SetActive(false)

    -- 锁住，优先级较低
    if XDataCenter.PrequelManager.GetChapterLockStatus(chapterId) then
        self.PanelTabLock.gameObject:SetActive(true)
        self.ImgNewCheckPoint.gameObject:SetActive(false)
    end

    -- 活动
    if XDataCenter.PrequelManager.IsChapterInActivity(chapterId) then
        self.PanelTabLock.gameObject:SetActive(false)
        self.ImgNewCheckPoint.gameObject:SetActive(true)
    end
end

function XUiGridPrequelPlotTab:OnSelected(isSelect)
    self.PanelTabUnSelect.gameObject:SetActive(not isSelect)
    self.PanelTabSelect.gameObject:SetActive(isSelect)
end

function XUiGridPrequelPlotTab:OnLock()

end

return XUiGridPrequelPlotTab
