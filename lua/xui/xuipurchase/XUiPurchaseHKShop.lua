local Object = CS.UnityEngine.Object
local XUiPurchaseHKShop = XClass()
local TextManager = CS.XTextManager
local PurchaseManager
local XUiPurchaseHKShopListItem = require("XUi/XUiPurchase/XUiPurchaseHKShopListItem")
local XUiPurchaseLBTips = require("XUi/XUiPurchase/XUiPurchaseLBTips")

function XUiPurchaseHKShop:Ctor(ui,uiroot)
    PurchaseManager = XDataCenter.PurchaseManager
    self.CurState = false
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Uiroot = uiroot
    XTool.InitUiObject(self)
    self:Init()
end

-- 更新数据
function XUiPurchaseHKShop:OnRefresh(uiType)
    local data = PurchaseManager.GetDatasByUiType(uiType)
    if not data then
        return
    end

    self.CurUitype = uiType
    self.GameObject:SetActive(true)
    self.ListData = data
    self.DynamicTable:SetDataSource(data)
    self.DynamicTable:ReloadDataASync(1)
end

function XUiPurchaseHKShop:OnUpdate()
    if self.CurUitype then
        self:OnRefresh(self.CurUitype)
    end
end

function XUiPurchaseHKShop:HidePanel()
    self.GameObject:SetActive(false)
end

function XUiPurchaseHKShop:ShowPanel()
    self.GameObject:SetActive(true)
end

function XUiPurchaseHKShop:Init()
    self:InitShopList()
    self.BuyUITips = XUiPurchaseLBTips.New(self.PanelBuyTips,self.Uiroot,self)
    self.BuyCb = function() self:BuyReq() end
    self.UpdateCb = function() self:OnUpdate() end
end

function XUiPurchaseHKShop:InitShopList()
    self.DynamicTable = XDynamicTableNormal.New(self.Transform)
    self.DynamicTable:SetProxy(XUiPurchaseHKShopListItem)
    self.DynamicTable:SetDelegate(self)
end

-- [监听动态列表事件]
function XUiPurchaseHKShop:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:Init(self.Uiroot,self)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local data = self.ListData[index]
        grid:OnRefresh(data)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then
        self.CurData = self.ListData[index]
        self.BuyUITips:OnRefresh(self.CurData,self.BuyCb)
    end
end

function XUiPurchaseHKShop:BuyReq()
    if self.CurData.BuyLimitTimes > 0 and self.CurData.BuyTimes == self.CurData.BuyLimitTimes then --卖完了，不管。
        XUiManager.TipText("PurchaseLiSellOut")
        return
    end

    if self.CurData.TimeToShelve > 0 and self.CurData.TimeToShelve > XTime.Now() then --没有上架
        XUiManager.TipText("PurchaseBuyNotSet")
        return
    end
    
    if self.CurData.TimeToUnShelve > 0 and self.CurData.TimeToUnShelve < XTime.Now() then --下架了
        XUiManager.TipText("PurchaseSettOff")
        return
    end

    if self.CurData and self.CurData.Id then
        self.BuyUITips:CloseTips()
        PurchaseManager.PurchaseRequest(self.CurData.Id,self.UpdateCb)
    end
end

return XUiPurchaseHKShop