local XUiGuildViewMember = XClass()
local XUiGridMemberItem = require("XUi/XUiGuild/XUiChildItem/XUiGridMemberItem")

function XUiGuildViewMember:Ctor(ui, uiRoot)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.UiRoot = uiRoot

    XTool.InitUiObject(self)
    self:InitChildView()
end

function XUiGuildViewMember:OnEnable()
    self.GameObject:SetActiveEx(true)
end

function XUiGuildViewMember:OnDisable()
    self.GameObject:SetActiveEx(false)
end

function XUiGuildViewMember:InitChildView()
    if not self.DynamicMemberTable then
        self.DynamicMemberTable = XDynamicTableNormal.New(self.MemberList.gameObject)
        self.DynamicMemberTable:SetProxy(XUiGridMemberItem)
    end

    self.DynamicMemberTable:SetDataSource({{},{},{},{},{},{},{},{}})
    self.DynamicMemberTable:ReloadDataASync()
end

function XUiGuildViewMember:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:Init(self.UiRoot)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
    
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then
       
    end
end

return XUiGuildViewMember