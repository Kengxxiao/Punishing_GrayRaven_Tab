local XUiArenaTeam = XLuaUiManager.Register(XLuaUi, "UiArenaTeam")

local XUiPanelMyTeam = require("XUi/XUiArenaTeam/XUiPanelMyTeam")
local XUiPanelHall = require("XUi/XUiArenaTeam/XUiPanelHall")
local XUiPanelApply = require("XUi/XUiArenaTeam/XUiPanelApply")
local XUiPanelInviteFriend = require("XUi/XUiArenaTeam/XUiPanelInviteFriend")

local ARENA_TEAM_PANEL_INDEX = {
    MY_TEAM = 1,
    HALL = 2,
    APPLY = 3,
    INVITE_FRIEND = 4,
}

function XUiArenaTeam:OnAwake()
    self:AutoAddListener()
    self.RedPointApplyId = XRedPointManager.AddRedPointEvent(self.BtnTabApply, self.OnCheckApplyData, self, { XRedPointConditions.Types.CONDITION_ARENA_APPLY })
end

function XUiArenaTeam:OnStart(...)
    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.FreeGem, XDataCenter.ItemManager.ItemId.ActionPoint, XDataCenter.ItemManager.ItemId.Coin)

    self.MyTeamPanel = XUiPanelMyTeam.New(self.PanelMyTeam, self)
    self.HallPanel = XUiPanelHall.New(self.PanelHall, self)
    self.ApplyPanel = XUiPanelApply.New(self.PanelApply, self)
    self.InviteFriendPanel = XUiPanelInviteFriend.New(self.PanelInviteFriend, self)

    self.PanelList = {}
    table.insert(self.PanelList, self.MyTeamPanel)
    table.insert(self.PanelList, self.HallPanel)
    table.insert(self.PanelList, self.ApplyPanel)
    table.insert(self.PanelList, self.InviteFriendPanel)

    self.BtnList = {}
    table.insert(self.BtnList, self.BtnTabMyTeam)
    table.insert(self.BtnList, self.BtnTabHall)
    table.insert(self.BtnList, self.BtnTabApply)
    table.insert(self.BtnList, self.BtnTabInvite)


    self.TeamTabGroup:Init(self.BtnList, function(index)
        self:RefreshSelectedPanel(index)
    end)

    -- 默认第一标签页
    self.TeamTabGroup:SelectIndex(ARENA_TEAM_PANEL_INDEX.MY_TEAM)
end

function XUiArenaTeam:AutoAddListener()
    self:RegisterClickEvent(self.BtnBack, self.OnBtnBackClick)
    self:RegisterClickEvent(self.BtnMainUi, self.OnBtnMainUiClick)
end

function XUiArenaTeam:OnBtnBackClick(eventData)
    self:Close()
end

function XUiArenaTeam:OnBtnMainUiClick(eventData)
    XLuaUiManager.RunMain()
end

function XUiArenaTeam:OnCheckApplyData(count)
    self.BtnTabApply:ShowReddot(count >= 0)
end

function XUiArenaTeam:RefreshSelectedPanel(index)
    for i, panel in ipairs(self.PanelList) do
        if i == index then
            panel:Show()
        else
            panel:Hide()
        end
    end
end

function XUiArenaTeam:JumpToHallPanel(index)
    self.TeamTabGroup:SelectIndex(ARENA_TEAM_PANEL_INDEX.HALL)
    if index then
        self.HallPanel.TypeTabGroup:SelectIndex(index)
    end
end