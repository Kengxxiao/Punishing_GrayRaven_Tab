local XUiPurchasePay = XClass()
local TextManager = CS.XTextManager
local PurchaseManager
local Next = _G.next
local XUiPurchasePayListItem = require("XUi/XUiPurchase/XUiPurchasePayListItem")
local TabExConfig

function XUiPurchasePay:Ctor(ui,uiroot,tab)
    PurchaseManager = XDataCenter.PurchaseManager
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Uiroot = uiroot
    self.Tab = tab
    TabExConfig = XPurchaseConfigs.TabExConfig
    XTool.InitUiObject(self)
    self:Init()
end

-- 更新数据
function XUiPurchasePay:OnRefresh(uiType)
    local data = PurchaseManager.GetDatasByUiType(uiType) or {}
    self.GameObject:SetActive(true)
    self.Len = #data or 0
    if Next(data) then
        table.sort(data, XUiPurchasePay.SortFun)
    end
    self.ListData = data
    self.DynamicTable:SetDataSource(data)
    self.DynamicTable:ReloadDataASync(1)
    if self.Tab == TabExConfig.Sample then
        self.Uiroot:PlayAnimation("PanelPurchaseBig")
    else
        self.Uiroot:PlayAnimation("PanelPurchaseSmall")
    end
end

function XUiPurchasePay.SortFun(a,b)
    return a.Amount < b.Amount
end

function XUiPurchasePay:HidePanel()
    self.GameObject:SetActive(false)
    self.CurState = false
    self.PanelPurchase.gameObject:SetActive(false)
end

function XUiPurchasePay:ShowPanel()
    self.GameObject:SetActive(true)
end

function XUiPurchasePay:InitList()
    self.DynamicTable = XDynamicTableNormal.New(self.SviewRecharge)
    self.DynamicTable:SetProxy(XUiPurchasePayListItem)
    self.DynamicTable:SetDelegate(self)
end

function XUiPurchasePay:Init()
    self:InitList()
    self.BtnBuy.CallBack = function() self:OnBtnBuyClick() end
end

function XUiPurchasePay:OnBtnBuyClick()
    XDataCenter.PayManager.Pay(self.BuyKey)
end

function XUiPurchasePay:OnBuySuccessCB()
    self.BuyKey = nil
    XUiManager.TipText("PurchaseBuySuccessTips", XUiManager.UiTipType.Success)
end
-- [监听动态列表事件]
function XUiPurchasePay:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:Init(self)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local data = self.ListData[index]
        grid:OnRefresh(data)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then
        grid:OnClick()
        self:SetListItemState(index)
        if self.CurItemIndex ~= index or self.CurState == false then
            self.CurItemIndex = index
            self.CurState = true
            self.PanelPurchase.gameObject:SetActive(true)
        else
            self.CurState = false
            self.PanelPurchase.gameObject:SetActive(false)
        end
        
        local data = self.ListData[index] or {}
        local price = data.Amount or ""
        local name = data.Name or ""
        self.BuyKey = data.Key
        self.TxtTips.text = TextManager.GetText("PusrchaseBuyTips",price,name)
    end
end

function XUiPurchasePay:SetListItemState(index)
    for i = 1,self.Len do
        local item = self.DynamicTable:GetGridByIndex(i)
        if item and i ~= index then
            item:OnSeleState(false)
        end
    end
end

return XUiPurchasePay