local XUiPanelTeamRank = XClass()

local XUiGridArenaTeamRank = require("XUi/XUiArenaTeamRank/ArenaTeamRankCommon/XUiGridArenaTeamRank")

function XUiPanelTeamRank:Ctor(ui, rootUi)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    XTool.InitUiObject(self)

    self.GridArenaTeamRank.gameObject:SetActive(false)

    self.IsShow = false
    self.GameObject:SetActive(false)

    self.MyTeamRank = XUiGridArenaTeamRank.New(self.PanelArenaSelfTeamRank)

    self.DynamicTable = XDynamicTableNormal.New(self.SViewRank.transform)
    self.DynamicTable:SetProxy(XUiGridArenaTeamRank)
    self.DynamicTable:SetDelegate(self)
end

function XUiPanelTeamRank:Show()
    if self.IsShow then
        return
    end

    self.IsShow = true
    self.GameObject:SetActive(true)

    XEventManager.AddEventListener(XEventId.EVENT_ARENA_REFRESH_TEAM_RANK_INFO, self.Refresh, self)

    self:Refresh()
end

function XUiPanelTeamRank:Hide()
    if not self.IsShow then
        return
    end

    self.IsShow = false
    self.GameObject:SetActive(false)

    XEventManager.RemoveEventListener(XEventId.EVENT_ARENA_REFRESH_TEAM_RANK_INFO, self.Refresh, self)
end

function XUiPanelTeamRank:Refresh()
    if not self.GameObject:Exist() then
        return
    end

    local challengeCfg = XDataCenter.ArenaManager.GetTeamRankChallengeCfg()
    if not challengeCfg then
        return
    end
    local arenaCfg = XArenaConfigs.GetArenaLevelCfgByLevel(challengeCfg.ArenaLv)

    self.TxtArenaName.text = challengeCfg.Name
    self.RImgArenaLevel:SetRawImage(arenaCfg.Icon)
    self.TxtTime.text = XDataCenter.ArenaManager.GetArenaTeamRankTime()
    self.TxtLevelRegion.text = challengeCfg.MinLv .. "-" .. challengeCfg.MaxLv

    local rank, totalRank, myTeamInfo = XDataCenter.ArenaManager.GetMyTeamRankAndData()
    self.MyTeamRank:ResetData(rank, myTeamInfo, self.RootUi, totalRank)

    self.DataList = XDataCenter.ArenaManager.GetTeamRankList() or {}
    self.DynamicTable:SetTotalCount(#self.DataList)
    if #self.DataList > 0 then
        self.DynamicTable:ReloadDataASync(1)
    else
        self.DynamicTable:ReloadDataASync()
    end
end

--动态列表事件
function XUiPanelTeamRank:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local data = self.DataList[index]
        grid:ResetData(index, data, self.RootUi)
    end
end

return XUiPanelTeamRank
