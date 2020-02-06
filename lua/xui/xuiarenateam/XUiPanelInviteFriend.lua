local XUiPanelInviteFriend = XClass()

local XUiGridArenaTeamSingle = require("XUi/XUiArenaTeam/XUiArenaTeamCommon/XUiGridArenaTeamSingle")

function XUiPanelInviteFriend:Ctor(ui, rootUi)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
    self.GridTeamSingle.gameObject:SetActive(false)

    self.RootUi = rootUi
    self.IsShow = false
    self.GameObject:SetActive(false)

    self.DynamicTable = XDynamicTableNormal.New(self.SViewSingle.transform)
    self.DynamicTable:SetProxy(XUiGridArenaTeamSingle)
    self.DynamicTable:SetDelegate(self)
end

function XUiPanelInviteFriend:Show()
    if self.IsShow then
        return
    end

    self.IsShow = true
    self.GameObject:SetActive(true)

    self:Refresh()
end

function XUiPanelInviteFriend:Hide()
    if not self.IsShow then
        return
    end

    self.IsShow = false
    self.GameObject:SetActive(false)
end

function XUiPanelInviteFriend:Refresh()
    XDataCenter.ArenaManager.RequestFriendArenaInfo(function()
        self.DataList = XDataCenter.ArenaManager.GetArenaFriendList()
        self.DynamicTable:SetTotalCount(#self.DataList)
        if #self.DataList > 0 then
            self.TxtNoApply.gameObject:SetActive(false)
            self.DynamicTable:ReloadDataASync(1)
        else
            self.TxtNoApply.gameObject:SetActive(true)
            self.DynamicTable:ReloadDataASync()
        end
    end)

    self.TxtTips.text = CS.XTextManager.GetText("ArenaTeamInvitTip")
end

--动态列表事件
function XUiPanelInviteFriend:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local data = self.DataList[index]
        grid:ResetData(data, self.RootUi)
    end
end

return XUiPanelInviteFriend
