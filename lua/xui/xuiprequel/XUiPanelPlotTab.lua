XUiPanelPlotTab = XClass()

local ANIPREQUELREGIONALSWITCH = "AniPrequelRegionalSwitch"

function XUiPanelPlotTab:Ctor(ui, rootUi, parent)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    self.ParentUi = parent
    self:InitAutoScript()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelPlotTab:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiPanelPlotTab:AutoInitUi()
    self.ScrollView = self.Transform:Find("ScrollView"):GetComponent("Scrollbar")
    self.UiContent = self.Transform:Find("ScrollView/Viewport/UiContent")
    self.BtnPrequelPlotTab = self.Transform:Find("ScrollView/Viewport/UiContent/BtnPrequelPlotTab")
    self.BtnPrequelGroup = self.UiContent:GetComponent("XUiButtonGroup")
end

function XUiPanelPlotTab:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelPlotTab:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelPlotTab:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelPlotTab:AutoAddListener()
end
-- auto

function XUiPanelPlotTab:UpdateTabs(coverDatas)
    self.Cover = coverDatas
    self.PrequelPlotTabs = self.PrequelPlotTabs or {}
    
    for i=1, #self.Cover.CoverVal.ChapterId do
        local plotTab = self.PrequelPlotTabs[i]
        if not plotTab then
            if i == 1 then
                self.PrequelPlotTabs[i] = self.BtnPrequelPlotTab:GetComponent("XUiButton")
            else
                local tabUi = CS.UnityEngine.Object.Instantiate(self.BtnPrequelPlotTab.gameObject)
                tabUi.transform:SetParent(self.UiContent, false)
                plotTab = tabUi.transform:GetComponent("XUiButton")
                tabUi:SetActive(true)
                table.insert(self.PrequelPlotTabs, i, plotTab)
            end
        end
        self:UpdatePlotTabStatus(self.PrequelPlotTabs[i], self.Cover.CoverVal.ChapterId[i])
    end

    for i=#self.Cover.CoverVal.ChapterId+1, #self.PrequelPlotTabs do
        self.PrequelPlotTabs[i].gameObject:SetActive(false)
    end
    self.BtnPrequelGroup:Init(self.PrequelPlotTabs, function(index) self:OnTabsClick(index) end)
end

function XUiPanelPlotTab:UpdatePlotTabStatus(tab, chapterId)
    local chapterData = XPrequelConfigs.GetPrequelChapterById(chapterId)
    tab:SetName(chapterData.ChapterName)

    -- 处理锁住+活动的情况
    tab:SetDisable(false, true)
    tab:ShowTag(false)

    -- 锁住，优先级较低
    if XDataCenter.PrequelManager.GetChapterLockStatus(chapterId) then
        tab:SetDisable(true, true)
        tab:ShowTag(false)
    end

    -- 活动
    if XDataCenter.PrequelManager.IsChapterInActivity(chapterId) then
        tab:SetDisable(false, true)
        tab:ShowTag(true)
    end
end

function XUiPanelPlotTab:SelectIndex(index, doNotAnim)
    if self.BtnPrequelGroup then
        self.BtnPrequelGroup:SelectIndex(index, false)
        self:OnTabsClick(index, doNotAnim)
    end
end

function XUiPanelPlotTab:OnTabsClick(index, doNotAnim)
    if not self.Cover then return end
    local currentChapterId = self.Cover.CoverVal.ChapterId[index]
    local isLock = XDataCenter.PrequelManager.GetChapterLockStatus(currentChapterId)
    local inActivity = XDataCenter.PrequelManager.IsChapterInActivity(currentChapterId)
    if isLock and (not inActivity) then 
        local msg = XDataCenter.PrequelManager.GetChapterUnlockDescription(currentChapterId)
        if msg then
            XUiManager.TipMsg(msg)
        end
        return 
    end

    if doNotAnim then
        self:OnTabSelected(index)
        return 
    end
    self:OnTabSelected(index)

    if not self.RootUi:IsRegionalAnimPlaying() then
        XUiHelper.PlayAnimation(self.RootUi, ANIPREQUELREGIONALSWITCH, nil, nil)
    end
end

-- [选中一个章节]
function XUiPanelPlotTab:OnTabSelected(index)
    self.ParentUi:OnChapterSelected(index)
end

return XUiPanelPlotTab
