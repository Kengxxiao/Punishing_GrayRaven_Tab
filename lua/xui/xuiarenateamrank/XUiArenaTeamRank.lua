local XUiArenaTeamRank = XLuaUiManager.Register(XLuaUi, "UiArenaTeamRank")

local XUiPanelTeamRank = require("XUi/XUiArenaTeamRank/XUiPanelTeamRank")
local XUiPanelRewardPreview = require("XUi/XUiArenaTeamRank/XUiPanelRewardPreview")

local ARENA_TEAM_RANK_PANEL_INDEX = {
    TEAM_RANK = 1,
    REWARD_PREVIEW = 2,
}

function XUiArenaTeamRank:OnAwake()
    self:AutoAddListener()
end

function XUiArenaTeamRank:OnStart(...)
    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.FreeGem, XDataCenter.ItemManager.ItemId.ActionPoint, XDataCenter.ItemManager.ItemId.Coin)

    self.TeamRankPanel = XUiPanelTeamRank.New(self.PanelTeamRank, self)
    self.RewardPreviewPanel = XUiPanelRewardPreview.New(self.PanelRewardPreview, self)

    self.PanelList = {}
    table.insert(self.PanelList, self.TeamRankPanel)
    table.insert(self.PanelList, self.RewardPreviewPanel)

    self.BtnList = {}
    table.insert(self.BtnList, self.BtnTeamRank)
    table.insert(self.BtnList, self.BtnRewardPreview)

    self.TabGroup = XUiTabBtnGroup.New(self.BtnList, function(index)
        self:RefreshSelectedPanel(index)
    end)

    -- 默认第一标签页
    self.TabGroup:SelectIndex(ARENA_TEAM_RANK_PANEL_INDEX.TEAM_RANK)
end

function XUiArenaTeamRank:AutoAddListener()
    self:RegisterClickEvent(self.BtnBack, self.OnBtnBackClick)
    self:RegisterClickEvent(self.BtnMainUi, self.OnBtnMainUiClick)
end

function XUiArenaTeamRank:OnBtnBackClick(eventData)
    self:Close()
end

function XUiArenaTeamRank:OnBtnMainUiClick(eventData)
    XLuaUiManager.RunMain()
end

function XUiArenaTeamRank:RefreshSelectedPanel(index)
    for i, panel in ipairs(self.PanelList) do
        if i == index then
            panel:Show()
        else
            panel:Hide()
        end
    end
end