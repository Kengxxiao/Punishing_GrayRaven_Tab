local XUiGridSuitDetail = require("XUi/XUiEquipAwarenessReplace/XUiGridSuitDetail")
local XUiPanelSuitDetailScroll = XClass()

function XUiPanelSuitDetailScroll:Ctor(rootUi,ui,gridTouchCb, gridReloadCb)
    self.RootUi = rootUi
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.GridTouchCb = gridTouchCb
    self.GridReloadCb = gridReloadCb
    XTool.InitUiObject(self)
    self:InitDynamicTable()
end

function XUiPanelSuitDetailScroll:InitDynamicTable()
    self.DynamicTable = XDynamicTableNormal.New(self.GameObject)
    self.DynamicTable:SetDelegate(self)
    self.DynamicTable:SetProxy(XUiGridSuitDetail)
end

function XUiPanelSuitDetailScroll:UpdateEquipGridList(suitIdList, _, selelctSite)
    self.SuitIdList = suitIdList or {}
    self.SelelctSite = selelctSite
    self.DynamicTable:SetDataSource(self.SuitIdList)
    self.DynamicTable:ReloadDataASync(#self.SuitIdList > 0 and 1 or -1)
end

function XUiPanelSuitDetailScroll:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:InitRootUi(self.RootUi)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local suitId = self.SuitIdList[index]
        grid:Refresh(suitId, nil, nil, true, self.SelelctSite)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then
        local suitId = self.SuitIdList[index]
        if self.GridTouchCb then
            self.GridTouchCb(suitId)
        end
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_RELOAD_COMPLETED then
        if self.GridReloadCb then
            self.GridReloadCb()
        end
    end
end

return XUiPanelSuitDetailScroll
