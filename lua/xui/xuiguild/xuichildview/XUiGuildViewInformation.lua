local XUiGuildViewInformation = XClass()
local MainType = {
    Info = 1,
    Admin = 2,
}

local XUiGuildMainInfo = require("XUi/XUiGuild/XUiChildView/XUiGuildMainInfo")
local XUiGuildAdministration = require("XUi/XUiGuild/XUiChildView/XUiGuildAdministration")
local XUiGridChannelItem = require("XUi/XUiGuild/XUiChildItem/XUiGridChannelItem")

function XUiGuildViewInformation:Ctor(ui, uiRoot)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.UiRoot = uiRoot
    XTool.InitUiObject(self)
    self:InitChildView()
end

function XUiGuildViewInformation:OnEnable()
    self.GameObject:SetActiveEx(true)
end

function XUiGuildViewInformation:OnDisable()
    self.GameObject:SetActiveEx(false)
end

function XUiGuildViewInformation:InitChildView()
    self.tabViews = {}
    self.tabViews[MainType.Info] = XUiGuildMainInfo.New(self.PanelInformation, self)
    self.tabViews[MainType.Admin] = XUiGuildAdministration.New(self.PanelAdministration, self)

    self.mainTabs = {}
    self.mainTabs[MainType.Info] = self.BtnInformation
    self.mainTabs[MainType.Admin] = self.BtnAdministration
    self.PanelRightBtn:Init(self.mainTabs, function(index) self:OnMainTypeClick(index) end)
    self.PanelRightBtn:SelectIndex(MainType.Info)

    -- Gift
    -- self.ImgProgress
    -- self.TextProgressValue
    -- self.TextNumber
    -- self.PaneBox

    -- Channel
    self:InitChannelView()

end

function XUiGuildViewInformation:InitChannelView()
    if not self.DynamicChannelTable then
        self.DynamicChannelTable = XDynamicTableIrregular.New(self.ScrollChannel)
        self.DynamicChannelTable:SetProxy("XUiGridChannelItem", XUiGridChannelItem, self.GridChannelItem.gameObject)
        self.DynamicChannelTable:SetDelegate(self)
    end
    -- self.DynamicChannelTable:SetDataSource(self.DataList)
    -- self.DynamicChannelTable:ReloadDataASync()
end

function XUiGuildViewInformation:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:Init(self.UiRoot)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then
    end
end

function XUiGuildViewInformation:GetProxyType(index)
    return "XUiGridChannelItem"
end

function XUiGuildViewInformation:OnMainTypeClick(index)
    if self.LastSelect and self.tabViews[self.LastSelect] then
        self.tabViews[self.LastSelect]:OnDisable()
    end
    self.tabViews[index]:OnEnable()
    self.LastSelect = index
end

return XUiGuildViewInformation