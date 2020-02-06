local XUiGuildViewRank = XClass()

local XUiGridWelfareItem = require("XUi/XUiGuild/XUiChildItem/XUiGridWelfareItem")

function XUiGuildViewRank:Ctor(ui, uiRoot)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.UiRoot = uiRoot

    XTool.InitUiObject(self)
    self:InitChildView()
end

function XUiGuildViewRank:OnEnable()
    self.GameObject:SetActiveEx(true)
end

function XUiGuildViewRank:OnDisable()
    self.GameObject:SetActiveEx(false)
end

function XUiGuildViewRank:InitChildView()
    if not self.DynamicWelfareTable then
        self.DynamicWelfareTable = XDynamicTableNormal.New(self.PanelWelfare.gameObject)
        self.DynamicWelfareTable:SetProxy(XUiGridWelfareItem)
    end

    self.DynamicWelfareTable:SetDataSource({{},{},{},{}})
    self.DynamicWelfareTable:ReloadDataASync()
end

function XUiGuildViewRank:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:Init(self.UiRoot)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
    
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then
       
    end
end

return XUiGuildViewRank