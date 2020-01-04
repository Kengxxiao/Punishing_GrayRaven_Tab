local XUiGuildViewChallenge = XClass()
local XUiGridChallengeItem = require("XUi/XUiGuild/XUiChildItem/XUiGridChallengeItem")

function XUiGuildViewChallenge:Ctor(ui, uiRoot)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.UiRoot = uiRoot

    XTool.InitUiObject(self)
    self:InitChildView()
end

function XUiGuildViewChallenge:OnEnable()
    self.GameObject:SetActiveEx(true)
end

function XUiGuildViewChallenge:OnDisable()
    self.GameObject:SetActiveEx(false)
end

function XUiGuildViewChallenge:InitChildView()
    if not self.DynamicChallengeTable then
        self.DynamicChallengeTable = XDynamicTableNormal.New(self.PanelChallenge.gameObject)
        self.DynamicChallengeTable:SetProxy(XUiGridChallengeItem)
    end

    self.DynamicChallengeTable:SetDataSource({{},{},{}})
    self.DynamicChallengeTable:ReloadDataASync()
end

function XUiGuildViewChallenge:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:Init(self.UiRoot)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
    
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then
       
    end
end

return XUiGuildViewChallenge