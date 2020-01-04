local Object = CS.UnityEngine.Object
local XUiPurchaseHK = XClass()
local TextManager = CS.XTextManager
local PurchaseManager
local TabConfig = {
    Exchange = 1,
    Shop = 2
}
local XUiPurchaseHKShop = require("XUi/XUiPurchase/XUiPurchaseHKShop")
local XUiPurchaseHKExchange = require("XUi/XUiPurchase/XUiPurchaseHKExchange")

function XUiPurchaseHK:Ctor(ui)
    PurchaseManager = XDataCenter.PurchaseManager
    self.CurState = false
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Uiroot = uiroot
    XTool.InitUiObject(self)
    self:Init()
end

-- 更新数据
function XUiPurchaseHK:OnRefresh(data)
    --测试
    data = {}
    if not data then
        return
    end

    self.Data = data
    self:TabSkip(TabConfig.Exchange)
    self.Tabgroup:SelectIndex(TabConfig.Exchange)
end

function XUiPurchaseHK:Init()
    local tabBtns = {}
    local tabText = { TextManager.GetText("PurchaseYKExChangeTab"), TextManager.GetText("PurchaseYKShopTab") }
    self.Tabgroup = self.PanelHkdhTabGroup:GetComponent("XUiButtonGroup")
    for k, v in pairs(tabText) do
        local btn = Object.Instantiate(self.BtnHkTab)
        btn.gameObject:SetActive(true)
        btn.transform:SetParent(self.PanelHkdhTabGroup.transform, false)
        local btncs = btn:GetComponent("XUiButton")
        btncs:SetName(v)
        tabBtns[k] = btncs
    end
    self.Tabgroup:Init(tabBtns, function(tab) self:TabSkip(tab) end)

    self.TabEnterSkip = {}
    self.TabEnterSkip[TabConfig.Exchange] = function() self:OpenExchange() end
    self.TabEnterSkip[TabConfig.Shop] = function() self:OpenHKShop() end

    self.LuaUIs = {}
    self.LuaUIs[TabConfig.Exchange] = XUiPurchaseHKExchange.New(self.PanelDh)
    self.LuaUIs[TabConfig.Shop] = XUiPurchaseHKShop.New(self.PanelHksd)
end

function XUiPurchaseHK:TabSkip(tab)
    if tab == self.CurTab then
        return 
    end

    self.CurTab = tab

    if self.TabEnterSkip[tab] then
        self.TabEnterSkip[tab]()
    end
end

-- 黑卡商店
function XUiPurchaseHK:OpenHKShop()
    local data = PurchaseManager.GetHKShopData()
    if data then
        -- return
    end

    self.PanelDh.gameObject:SetActive(false)
    self.PanelHksd.gameObject:SetActive(true)
    self.LuaUIs[TabConfig.Shop]:OnRefresh(data)
end

-- 兑换
function XUiPurchaseHK:OpenExchange()
    local data = PurchaseManager.GetHKDHData()
    if not data then
        -- return 
    end

    self.PanelDh.gameObject:SetActive(true)
    self.PanelHksd.gameObject:SetActive(false)
    self.LuaUIs[TabConfig.Exchange]:OnRefresh(data) 
end

return XUiPurchaseHK