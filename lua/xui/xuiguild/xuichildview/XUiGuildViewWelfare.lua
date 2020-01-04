local XUiGuildViewWelfare = XClass()

local XUiGridWelfareItem = require("XUi/XUiGuild/XUiChildItem/XUiGridWelfareItem")

function XUiGuildViewWelfare:Ctor(ui, uiRoot)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.UiRoot = uiRoot

    XTool.InitUiObject(self)
    self:InitChildView()
end

function XUiGuildViewWelfare:OnEnable()
    self.GameObject:SetActiveEx(true)
end

function XUiGuildViewWelfare:OnDisable()
    self.GameObject:SetActiveEx(false)
end

function XUiGuildViewWelfare:InitChildView()
    if not self.DynamicWelfareTable then
        self.DynamicWelfareTable = XDynamicTableNormal.New(self.PanelWelfare.gameObject)
        self.DynamicWelfareTable:SetProxy(XUiGridWelfareItem)
    end

    self.DynamicWelfareTable:SetDataSource({{},{},{},{}})
    self.DynamicWelfareTable:ReloadDataASync()
end

function XUiGuildViewWelfare:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:Init(self.UiRoot)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
    
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then
       
    end
end

return XUiGuildViewWelfare