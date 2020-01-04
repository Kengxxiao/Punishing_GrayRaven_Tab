XUiPanelChapterDz = XClass()

function XUiPanelChapterDz:Ctor(ui, rootUi)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    self:InitAutoScript()

    self.ChapterDynamicTable = XDynamicTableNormal.New(self.PanelChapterDz)
    self.ChapterDynamicTable:SetProxy(XUiGridChapterDz)
    self.ChapterDynamicTable:SetDelegate(self)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelChapterDz:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiPanelChapterDz:AutoInitUi()
    self.PanelChapterDz = self.Transform:Find("PanelChapterDz")
    self.PanelChapterContent = self.Transform:Find("PanelChapterDz/Viewport/PanelChapterContent")
    self.GridChapterDz = self.Transform:Find("PanelChapterDz/Viewport/GridChapterDz")
end

function XUiPanelChapterDz:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelChapterDz:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelChapterDz:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelChapterDz:AutoAddListener()
end
-- auto

--动态列表事件
function XUiPanelChapterDz:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:InitRoot(self.RootUi)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        if self.Covers[index] then
            grid:RefreshDatas(self.Covers[index])
        end
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then
        self.CurrentCover = self.Covers[index]
        self:OnChapterCoverClick(grid, self.CurrentCover)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_RELOAD_COMPLETED then
        XEventManager.DispatchEvent(XEventId.EVENT_GUIDE_STEP_OPEN_EVENT)
    end
end

-- 章节点击事件
function XUiPanelChapterDz:OnChapterCoverClick(grid, coverData)
    -- 跳转到新界面
    XLuaUiManager.Open("UiPrequel", coverData)
end

-- 设置数据
function XUiPanelChapterDz:SetupCoverDatas(defaultCoverId, defaultChapterId)
    self.Covers = XDataCenter.PrequelManager.GetListCovers()
    self.ChapterDynamicTable:SetDataSource(self.Covers)
    self.ChapterDynamicTable:ReloadDataASync()
    
    if defaultCoverId then
        self:OnOpenCoverById(defaultCoverId, defaultChapterId)
    end
end

function XUiPanelChapterDz:OnOpenCoverById(coverId, defaultChapterId)
    if self.Covers then
        local index = 0
        for k, v in pairs(self.Covers) do
            if v.CoverId == coverId then
                index = k
                break
            end
        end
        if self.Covers[index] then
            if self.Covers[index].IsAllChapterLock and (not self.Covers[index].IsActivity) then 
                XUiManager.TipMsg(XDataCenter.PrequelManager.GetChapterUnlockDescription(self.Covers[index].ShowChapter))
                return 
            end
            self.CurrentCover = self.Covers[index]
            XLuaUiManager.Open("UiPrequel", self.CurrentCover, nil, defaultChapterId)
        end
    end
end

function XUiPanelChapterDz:OnCoverChanged(infos)
end

return XUiPanelChapterDz
