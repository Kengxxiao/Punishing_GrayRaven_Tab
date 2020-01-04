local XUiPanelRewardPreview = XClass()

local XUiGridArenaTeamReward = require("XUi/XUiArenaTeamRank/ArenaTeamRankCommon/XUiGridArenaTeamReward")

function XUiPanelRewardPreview:Ctor(ui, rootUi)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    XTool.InitUiObject(self)

    self.GridArenaTeamReward.gameObject:SetActive(false)

    self.IsShow = false
    self.GameObject:SetActive(false)

    self.DynamicTable = XDynamicTableNormal.New(self.SViewTeamReward.transform)
    self.DynamicTable:SetProxy(XUiGridArenaTeamReward)
    self.DynamicTable:SetDelegate(self)
end

function XUiPanelRewardPreview:Show()
    if self.IsShow then
        return
    end

    self.IsShow = true
    self.GameObject:SetActive(true)

    self:Refresh()
end

function XUiPanelRewardPreview:Hide()
    if not self.IsShow then
        return
    end

    self.IsShow = false
    self.GameObject:SetActive(false)
end

function XUiPanelRewardPreview:Refresh()
    local challengId = XDataCenter.ArenaManager.GetCurChallengeId()
    self.DataList = XArenaConfigs.GetTeamRankRewardCfgList(challengId)

    self.DynamicTable:SetTotalCount(#self.DataList)
    if #self.DataList > 0 then
        self.DynamicTable:ReloadDataASync(1)
    else
        self.DynamicTable:ReloadDataASync()
    end
end

--动态列表事件
function XUiPanelRewardPreview:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local data = self.DataList[index]
        grid:ResetData(data, self.RootUi)
    end
end

return XUiPanelRewardPreview
