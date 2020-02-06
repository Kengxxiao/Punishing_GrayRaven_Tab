local TimeFormat = "MM/dd"
local CSXTextManagerGetText = CS.XTextManager.GetText

local XUiActivityBriefShop = XLuaUiManager.Register(XLuaUi, "UiActivityBriefShop")

function XUiActivityBriefShop:OnAwake()
    self.GridShop.gameObject:SetActiveEx(false)
    self.ShopBuy = XUiPanelShopItem.New(self.PanelShopItem, self, self.RootUi)
    self.AssetActivityPanel = XUiPanelActivityAsset.New(self.PanelActivityAsset, true)
    self:InitDynamicTable()
    self:InitPanels()
end

function XUiActivityBriefShop:OnStart(closeCb,base)
    self.CloseCb = closeCb
    self.Base = base
end

function XUiActivityBriefShop:OnEnable()
    if self.Base then
        self.Base.BasePane.gameObject:SetActiveEx(false)
    end
    local shopId = XDataCenter.ActivityBriefManager.GetActivityShopId()
    if shopId <= 0 then
        XLog.Error("ShopId not Exsit while trying to open UiActivityBriefBase, pls check ActivityBrief.tab!")
        return
    end
    XShopManager.GetShopInfo(shopId, function()
        self:UpdatePanels()
        self:RefreshBuy()
    end)
end

function XUiActivityBriefShop:InitPanels()
    self.ImgEmpty.gameObject:SetActiveEx(true)
    self.AssetActivityPanel.GameObject:SetActiveEx(false)
    self.BtnBack.CallBack = function()
        self:Close()
        if self.CloseCb then self.CloseCb() end
    end
end

function XUiActivityBriefShop:UpdatePanels()
    local shopGoods = XDataCenter.ActivityBriefManager.GetActivityShopGoods()
    local isEmpty = not next(shopGoods)
    self.ImgEmpty.gameObject:SetActiveEx(isEmpty)
    self.AssetActivityPanel.GameObject:SetActiveEx(not isEmpty)

    local shopId = XDataCenter.ActivityBriefManager.GetActivityShopId()
    local shopTimeInfo = XShopManager.GetShopTimeInfo(shopId)
    local leftTime = shopTimeInfo.ClosedLeftTime
    if leftTime > 0 then
        local timeStr = XUiHelper.GetTime(leftTime, XUiHelper.TimeFormatType.ACTIVITY)
        self.TxtTime.text = CSXTextManagerGetText("ActivityBriefShopLeftTime", timeStr)
        self.TxtTime.gameObject:SetActiveEx(true)
    else
        self.TxtTime.gameObject:SetActiveEx(false)
    end
end

function XUiActivityBriefShop:InitDynamicTable()
    self.DynamicTable = XDynamicTableNormal.New(self.PanelItemList)
    self.DynamicTable:SetProxy(XUiGridShop)
    self.DynamicTable:SetDelegate(self)
end

function XUiActivityBriefShop:UpdateDynamicTable()
    local shopGoods = XDataCenter.ActivityBriefManager.GetActivityShopGoods()
    self.ShopGoods = shopGoods
    self.DynamicTable:SetDataSource(shopGoods)
    self.DynamicTable:ReloadDataASync()
end

function XUiActivityBriefShop:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:Init(self)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local data = self.ShopGoods[index]
        grid:UpdataData(data)
    end
end

function XUiActivityBriefShop:UpdataBuy(data, cb)
    self.ShopBuy:ShowPanel(data, cb)
    self:PlayAnimation("ShopItemEnable")
end

function XUiActivityBriefShop:GetCurShopId()
    return XDataCenter.ActivityBriefManager.GetActivityShopId()
end

function XUiActivityBriefShop:RefreshBuy()
    local shopId = XDataCenter.ActivityBriefManager.GetActivityShopId()
    self.AssetActivityPanel:Refresh(XShopManager.GetShopShowIdList(shopId))
    self:UpdateDynamicTable()
end