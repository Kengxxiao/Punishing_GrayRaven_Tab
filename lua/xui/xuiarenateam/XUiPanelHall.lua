local XUiPanelHall = XClass()

local XUiGridArenaTeam = require("XUi/XUiArenaTeam/XUiArenaTeamCommon/XUiGridArenaTeam")
local XUiGridArenaTeamSingle = require("XUi/XUiArenaTeam/XUiArenaTeamCommon/XUiGridArenaTeamSingle")

local ARENA_HALL_TAB = {
    TEAM = 1,
    SINGLE = 2,
}

function XUiPanelHall:Ctor(ui, rootUi)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
    self:AutoAddListener()

    self.GridTeam.gameObject:SetActive(false)
    self.GridTeamSingle.gameObject:SetActive(false)

    self.RootUi = rootUi
    self.IsShow = false
    self.GameObject:SetActive(false)

    self.DynamicTeamTable = XDynamicTableNormal.New(self.SViewTeam.transform)
    self.DynamicTeamTable:SetProxy(XUiGridArenaTeam)
    self.DynamicTeamTable:SetDelegate(self)

    self.DynamicSingleTable = XDynamicTableNormal.New(self.SViewSingle.transform)
    self.DynamicSingleTable:SetProxy(XUiGridArenaTeamSingle)
    self.DynamicSingleTable:SetDelegate(self)

    self.BtnList = {}
    table.insert(self.BtnList, self.BtnTabTeam)
    table.insert(self.BtnList, self.BtnTabSingle)

    self.TypeTabGroup:Init(self.BtnList, function(index)
        self:RefreshSelectedPanel(index)
    end)
end

function XUiPanelHall:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelHall:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelHall:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelHall:AutoAddListener()
    self:RegisterClickEvent(self.BtnRefresh, self.OnBtnRefreshClick)
end

function XUiPanelHall:OnBtnRefreshClick(eventData)
    --TODO
    if self.SelectedIndex == ARENA_HALL_TAB.TEAM then
        XDataCenter.ArenaManager.RequestHallTeamList()
    else
        XDataCenter.ArenaManager.RequestHallPlayerList()
    end
end

function XUiPanelHall:Show()
    if self.IsShow then
        return
    end

    self.IsShow = true
    self.GameObject:SetActive(true)

    self.TypeTabGroup:SelectIndex(ARENA_HALL_TAB.TEAM)
end

function XUiPanelHall:Hide()
    if not self.IsShow then
        return
    end

    self.IsShow = false
    self.GameObject:SetActive(false)
end

--动态列表事件
function XUiPanelHall:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local data = self.DataList[index]
        grid:ResetData(data, self.RootUi)
    end
end

function XUiPanelHall:Refresh()
    local func = function()
        self.TxtNoPlayer.gameObject:SetActive(false)
        self.TxtNoTeam.gameObject:SetActive(false)
        
        if self.SelectedIndex == ARENA_HALL_TAB.TEAM then
            self.DataList = XDataCenter.ArenaManager.GetHallTeamList()

            self.DynamicTeamTable:SetTotalCount(#self.DataList)
            if #self.DataList > 0 then
                self.TxtNoTeam.gameObject:SetActive(false)
                self.DynamicTeamTable:ReloadDataASync(1)
            else
                self.TxtNoTeam.gameObject:SetActive(true)
                self.DynamicTeamTable:ReloadDataASync()
            end
        else
            self.DataList = XDataCenter.ArenaManager.GetHallPlayerList()

            self.DynamicSingleTable:SetTotalCount(#self.DataList)
            if #self.DataList > 0 then
                self.TxtNoPlayer.gameObject:SetActive(false)
                self.DynamicSingleTable:ReloadDataASync(1)
            else
                self.TxtNoPlayer.gameObject:SetActive(true)
                self.DynamicSingleTable:ReloadDataASync()
            end
        end
    end

    if self.SelectedIndex == ARENA_HALL_TAB.TEAM then
        XDataCenter.ArenaManager.RequestHallTeamList(func)
    else
        XDataCenter.ArenaManager.RequestHallPlayerList(func)
    end
end

function XUiPanelHall:RefreshSelectedPanel(index)
    self.SelectedIndex = index
    if index == ARENA_HALL_TAB.TEAM then
        self.SViewTeam.gameObject:SetActive(true) 
        self.SViewSingle.gameObject:SetActive(false)
    else
        self.SViewTeam.gameObject:SetActive(false)
        self.SViewSingle.gameObject:SetActive(true)
    end
    self:Refresh()
end

return XUiPanelHall
