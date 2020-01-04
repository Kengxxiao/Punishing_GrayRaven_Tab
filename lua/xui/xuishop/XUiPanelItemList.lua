XUiPanelItemList = XClass()

function XUiPanelItemList:Ctor(ui, parent,rootUi)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Ui = ui
    self.Parent = parent
	self.RootUi = rootUi or parent
    self.GoodsList = {}
    self.GoodsContainer = {}
    self:SetCountUpdateListener()
    self:Init()
end

function XUiPanelItemList:SetCountUpdateListener()
    XDataCenter.ItemManager.AddCountUpdateListener(XDataCenter.ItemManager.ItemId.FreeGem, function() self:RefreshGoodsPrice() end, self.Ui)
    XDataCenter.ItemManager.AddCountUpdateListener(XDataCenter.ItemManager.ItemId.Coin,function() self:RefreshGoodsPrice() end, self.Ui)
end

function XUiPanelItemList:RefreshGoodsPrice()
    for k,v in pairs(self.DynamicTable:GetGrids()) do
        v:RefreshPrice()
    end
end

function XUiPanelItemList:Init()
    XTool.InitUiObject(self)
    self.DynamicTable = XDynamicTableNormal.New(self.Transform)
    self.DynamicTable:SetProxy(XUiGridShop)
    self.DynamicTable:SetDelegate(self)
end

function XUiPanelItemList:GetAutoKey(uiNode, eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiPanelItemList:HidePanel()
    self.GameObject:SetActive(false)
end

function XUiPanelItemList:ShowPanel(id, IsNotSync)
    self.GameObject:SetActive(true)
    if not IsNotSync then 
        self.GoodsList = XShopManager.GetShopGoodsList(id)
    end
    
    self:ShowGoods()
    self.DynamicTable:SetDataSource(self.GoodsList)
    
    if not IsNotSync then 
        self.DynamicTable:ReloadDataASync(1)
    end
end


--动态列表事件
function XUiPanelItemList:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:Init(self.Parent,self.RootUi)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local data = self.GoodsList[index]
        grid:UpdataData(data)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_RECYCLE then
        grid:OnRecycle()
    end
end

--初始化列表
function XUiPanelItemList:ShowGoods()
    --商品数量显示
    if not self.GoodsList or #self.GoodsList <= 0 then
        self.TxtDesc.gameObject:SetActive(true)
        self.TxtHint.text = CS.XTextManager.GetText("ShopNoGoodsDesc")
    else
        self.TxtDesc.gameObject:SetActive(false)
        self.TxtHint.text = ""
    end

    --self:UpdataGoods()
end

--更新商品信息
function XUiPanelItemList:UpdataGoods(goodsId)
    for k, v in pairs(self.GoodsList) do
        if v.Id == goodsId then
            local grid = self.DynamicTable:GetGridByIndex(k)
            grid:UpdataData(v)
        end
    end
end


