local Object = CS.UnityEngine.Object
local XUiPurchaseHKExchange = XClass()
local TextManager = CS.XTextManager
local Next = _G.next
local PurchaseManager
local XUiPurchaseHKExchangeListItem = require("XUi/XUiPurchase/XUiPurchaseHKExchangeListItem")
local XUiPurchaseHKExchangeTips = require("XUi/XUiPurchase/XUiPurchaseHKExchangeTips")

function XUiPurchaseHKExchange:Ctor(ui,uiroot)
    PurchaseManager = XDataCenter.PurchaseManager
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Uiroot = uiroot
    XTool.InitUiObject(self)
    self:Init()
end

-- 更新数据
function XUiPurchaseHKExchange:OnRefresh(uiType)
    local data = PurchaseManager.GetDatasByUiType(uiType)
    if not data then
        return
    end

    self.CurUitype = uiType
    self.GameObject:SetActive(true)
    if Next(data) ~= nil then
        table.sort(data, XUiPurchaseHKExchange.SortFun)
    end
    self.ListData = data
    self.DynamicTable:SetDataSource(data)
    self.DynamicTable:ReloadDataASync(1)
end

function XUiPurchaseHKExchange.SortFun(a,b)
    return a.Priority < b.Priority
end

function XUiPurchaseHKExchange:OnUpdate()
    if self.CurUitype then
        self:OnRefresh(self.CurUitype)
    end
end

function XUiPurchaseHKExchange:HidePanel()
    self.GameObject:SetActive(false)
end

function XUiPurchaseHKExchange:ShowPanel()
    self.GameObject:SetActive(true)
end

function XUiPurchaseHKExchange:Init()
    self:InitExchangeList()
    self.HKExchangeUI = XUiPurchaseHKExchangeTips.New(self.PaneHkExChangeTips,self)
    self.UpdateCb = function() self:OnUpdate() end
end

function XUiPurchaseHKExchange:InitExchangeList()
    self.DynamicTable = XDynamicTableNormal.New(self.Transform,self)
    self.DynamicTable:SetProxy(XUiPurchaseHKExchangeListItem)
    self.DynamicTable:SetDelegate(self)
end

function XUiPurchaseHKExchange:ReqBuy(id)
    PurchaseManager.PurchaseRequest(id,self.UpdateCb)
end

-- [监听动态列表事件]
function XUiPurchaseHKExchange:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:Init(self.Uiroot,self)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local data = self.ListData[index]
        grid:OnRefresh(data)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then
        local data = self.ListData[index]
        self.HKExchangeUI:OnRefresh(data)
    end
end

return XUiPurchaseHKExchange