local XUiGuildViewRecommendation = XClass()
local XUiGridRecommendationItem = require("XUi/XUiGuild/XUiChildItem/XUiGridRecommendationItem")

function XUiGuildViewRecommendation:Ctor(ui, uiRoot)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.UiRoot = uiRoot

    XTool.InitUiObject(self)
    self:InitChildView()
end

function XUiGuildViewRecommendation:OnEnable()
    self.GameObject:SetActiveEx(true)
end

function XUiGuildViewRecommendation:OnDisable()
    self.GameObject:SetActiveEx(false)
end

function XUiGuildViewRecommendation:InitChildView()
    if not self.DynamicTable then
        self.DynamicTable = XDynamicTableNormal.New(self.MemberList.gameObject)
        self.DynamicTable:SetProxy(XUiGridRecommendationItem)
    end

    self.DynamicTable:SetDataSource({{},{},{},{},{},{},{},{}})
    self.DynamicTable:ReloadDataASync()
end

function XUiGuildViewRecommendation:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:Init(self.UiRoot)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
    
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then
       
    end
end

return XUiGuildViewRecommendation