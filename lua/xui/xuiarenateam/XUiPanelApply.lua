local XUiPanelApply = XClass()

local XUiGridArenaTeamApply = require("XUi/XUiArenaTeam/XUiArenaTeamCommon/XUiGridArenaTeamApply")

function XUiPanelApply:Ctor(ui, rootUi)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)

    self.GridTeamApply.gameObject:SetActive(false)

    self.RootUi = rootUi
    self.IsShow = false
    self.GameObject:SetActive(false)

    self.DynamicTable = XDynamicTableNormal.New(self.SViewSingle.transform)
    self.DynamicTable:SetProxy(XUiGridArenaTeamApply)
    self.DynamicTable:SetDelegate(self)
end

function XUiPanelApply:Show()
    if self.IsShow then
        return
    end

    self.IsShow = true
    self.GameObject:SetActive(true)

    XEventManager.AddEventListener(XEventId.EVENT_ARENA_TEAM_APPLY_CHANGE, self.Refresh, self)
    XEventManager.AddEventListener(XEventId.EVENT_ARENA_TEAM_NEW_APPLY_ENTER, self.Refresh, self)
    self:Refresh()
end

function XUiPanelApply:Hide()
    if not self.IsShow then
        return
    end

    self.IsShow = false
    self.GameObject:SetActive(false)
    XEventManager.RemoveEventListener(XEventId.EVENT_ARENA_TEAM_APPLY_CHANGE, self.Refresh, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_ARENA_TEAM_NEW_APPLY_ENTER, self.Refresh, self)
end

function XUiPanelApply:Refresh()
    if not self.GameObject:Exist() then
        return
    end

    local func = function()
        self.DataList = XDataCenter.ArenaManager.GetApplyDataList()
        self.DynamicTable:SetTotalCount(#self.DataList)
        if #self.DataList > 0 then
            self.TxtNoApply.gameObject:SetActive(false)
            self.DynamicTable:ReloadDataASync(1)
        else
            self.TxtNoApply.gameObject:SetActive(true)
            self.DynamicTable:ReloadDataASync()
        end
    end

    XDataCenter.ArenaManager.RequestApplyData(func)
end

--动态列表事件
function XUiPanelApply:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local data = self.DataList[index]
        grid:ResetData(data, self.RootUi)
    end
end

return XUiPanelApply
