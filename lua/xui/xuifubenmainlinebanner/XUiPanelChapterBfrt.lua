local XUiGridChapterBfrt = require("XUi/XUiFubenMainLineBanner/XUiGridChapterBfrt")

local XUiPanelChapterBfrt = XClass()

function XUiPanelChapterBfrt:Ctor(ui, rootUi)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi

    XTool.InitUiObject(self)
    self:InitDynamicTable()
end

function XUiPanelChapterBfrt:InitDynamicTable()
    self.ChapterDynamicTable = XDynamicTableNormal.New(self.GameObject)
    self.ChapterDynamicTable:SetProxy(XUiGridChapterBfrt)
    self.ChapterDynamicTable:SetDelegate(self)
end

--动态列表事件
function XUiPanelChapterBfrt:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        if self.ChapterIds[index] then
            grid:RefreshDatas(self.ChapterIds[index])
        end
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then
        self:OnChapterCoverClick(self.ChapterIds[index])
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_RELOAD_COMPLETED then
        XEventManager.DispatchEvent(XEventId.EVENT_GUIDE_STEP_OPEN_EVENT)
    end
end

-- 章节点击事件
function XUiPanelChapterBfrt:OnChapterCoverClick(chapterId)
    local chapterCfg = XDataCenter.BfrtManager.GetChapterCfg(chapterId)
    self.RootUi:PushUi(function()
        XLuaUiManager.Open("UiFubenMainLineChapter", chapterCfg, nil, true)
    end)
end

-- 设置数据
function XUiPanelChapterBfrt:SetupBfrtChpaters()
    self.ChapterIds = self.ChapterIds or XDataCenter.BfrtManager.GetChapterList()
    self.ChapterDynamicTable:SetDataSource(self.ChapterIds)
    self.ChapterDynamicTable:ReloadDataASync()
end

return XUiPanelChapterBfrt