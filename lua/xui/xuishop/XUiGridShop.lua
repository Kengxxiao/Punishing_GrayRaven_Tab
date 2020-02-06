XUiGridShop = XClass()

function XUiGridShop:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
    self:InitAutoScript()
    self.PanelPrice = {
        self.PanelPrice1,
        self.PanelPrice2,
        self.PanelPrice3
    }
    self.Timer = nil
end

function XUiGridShop:Init(parent, rootUi)
    self.Parent = parent
    self.RootUi = rootUi or parent
    self.Grid = XUiGridCommon.New(self.RootUi, self.GridCommon)
end

function XUiGridShop:OnRecycle(parent)
    self:RemoveTimer()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiGridShop:InitAutoScript()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiGridShop:GetAutoKey(uiNode, eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiGridShop:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end
    
    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiGridShop:RegisterListener: func is not a function")
        end
        
        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end
        
        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiGridShop:AutoAddListener()
    self.AutoCreateListeners = {}
    XUiHelper.RegisterClickEvent(self, self.BtnCondition, self.OnBtnConditionClick)
    XUiHelper.RegisterClickEvent(self, self.BtnBuy, self.OnBtnBuyClick)
end
-- auto
function XUiGridShop:OnBtnConditionClick(...)
    if self.ConditionDesc then
        XUiManager.TipError(self.ConditionDesc)
    end
end

function XUiGridShop:OnBtnBuyClick(...)
    self.Parent:UpdataBuy(self.Data, function()
        self:RefreshSellOut()
        self:RefreshOnSales()
        self:RefreshPrice()
        self:RefreshBuyCount()
    end)
end

function XUiGridShop:UpdataData(data)
    self.Data = data
    self:RefreshCondition()
    self:RefreshCommon()
    self:RefreshOnSales()
    self:RefreshPrice()
    self:RemoveTimer()
    self:RefreshSellOut()
    self:RefreshBuyCount()
    self:RefreshTimer(self.Data.SelloutTime)
end

function XUiGridShop:RefreshBuyCount()
    if not self.ImgLimitLable then
        return
    end
    
    if not self.TxtLimitLable then
        return
    end
    
    if self.Data.BuyTimesLimit <= 0 then
        self.TxtLimitLable.gameObject:SetActive(false)
        self.ImgLimitLable.gameObject:SetActive(false)
    else
        local buynumber = self.Data.BuyTimesLimit - self.Data.TotalBuyTimes
        if self.Data.AutoResetType == XShopManager.GoodsResetType.Hours or self.Data.AutoResetType == XShopManager.GoodsResetType.Not then
            self.TxtLimitLable.text = CS.XTextManager.GetText("CanBuy", buynumber)
        end
        if self.Data.AutoResetType == XShopManager.GoodsResetType.Day then
            self.TxtLimitLable.text = CS.XTextManager.GetText("DayCanBuy", buynumber)
        end
        if self.Data.AutoResetType == XShopManager.GoodsResetType.Week then
            self.TxtLimitLable.text = CS.XTextManager.GetText("WeekCanBuy", buynumber)
        end
        if self.Data.AutoResetType == XShopManager.GoodsResetType.Month then
            self.TxtLimitLable.text = CS.XTextManager.GetText("MonthCanBuy", buynumber)
        end
        if not self.Data.AutoResetType then
            self.TxtLimitLable.text = CS.XTextManager.GetText("CanBuy", buynumber)
        end
        self.TxtLimitLable.gameObject:SetActive(true)
        self.ImgLimitLable.gameObject:SetActive(true)
    end
end

function XUiGridShop:RefreshCondition()
    if not self.BtnCondition then return end
    self.BtnCondition.gameObject:SetActive(false)
    self.ConditionDesc = nil
    local conditonIds = self.Data.ConditionIds
    if not conditonIds or #conditonIds <= 0 then return end
    
    for _, id in pairs(conditonIds) do
        local ret, desc = XConditionManager.CheckCondition(id)
        if not ret then
            self.BtnCondition.gameObject:SetActive(true)
            self.ConditionDesc = desc
            return
        end
    end
end

function XUiGridShop:RefreshSellOut()
    if not self.ImgSellOut then
        return
    end
    
    if self.Data.BuyTimesLimit <= 0 then
        self.ImgSellOut.gameObject:SetActive(false)
    else
        if self.Data.TotalBuyTimes >= self.Data.BuyTimesLimit then
            self.ImgSellOut.gameObject:SetActive(true)
        else
            self.ImgSellOut.gameObject:SetActive(false)
        end
    end
end


function XUiGridShop:RemoveTimer()
    if self.Timer then
        CS.XScheduleManager.UnSchedule(self.Timer)
        self.Timer = nil
    end
end

function XUiGridShop:RefreshCommon()
    if self.RImgType then
        self.RImgType.gameObject:SetActive(false)
    end
    
    local rewardGoods = self.Data.RewardGoods
    self.Grid:Refresh(self.Data.RewardGoods, nil, true)
end

function XUiGridShop:RefreshPrice()
    local panelCount = #self.PanelPrice
    for i = 1, panelCount do
        self.PanelPrice[i].gameObject:SetActive(false)
    end
    
    local index = 1
    for id, count in pairs(self.Data.ConsumeList) do
        if index > panelCount then
            return
        end
        
        if self["TxtOldPrice" .. index] then
            if self.Sales == 100 then
                self["TxtOldPrice" .. index].gameObject:SetActive(false)
            else
                self["TxtOldPrice" .. index].text = count.Count
                self["TxtOldPrice" .. index].gameObject:SetActive(true)
            end
        end
        
        if self["RImgPrice" .. index] and self["RImgPrice" .. index]:Exist() then
            local icon = XDataCenter.ItemManager.GetItemIcon(count.Id)
            if icon ~= nil then
                self["RImgPrice" .. index]:SetRawImage(icon)
            end
        end
        
        if self["TxtNewPrice" .. index] then
            local needCount = math.floor(count.Count * self.Sales / 100)
            self["TxtNewPrice" .. index].text = needCount
            if XDataCenter.ItemManager.GetItem(count.Id).Count < needCount then
                self["TxtNewPrice" .. index].color = CS.UnityEngine.Color(1, 0, 0)
            else
                self["TxtNewPrice" .. index].color = CS.UnityEngine.Color(0, 0, 0)
            end
        end
        
        self.PanelPrice[index].gameObject:SetActive(true)
        index = index + 1
    end
end

function XUiGridShop:RefreshOnSales()
    self.OnSales = {}
    self.OnSalesLongTest = {}
    XTool.LoopMap(self.Data.OnSales, function(k, sales)
        self.OnSales[k] = sales
        table.insert(self.OnSalesLongTest, sales)	
    end)
    
    self.Sales = 100
    
    if #self.OnSalesLongTest ~= 0 then
        local sortedKeys = {}
        for k, v in pairs(self.OnSales) do
            table.insert(sortedKeys, k)
        end
        table.sort(sortedKeys)
        
        for i = 1, #sortedKeys do
            if self.Data.TotalBuyTimes >= sortedKeys[i] - 1 then
                self.Sales = self.OnSales[sortedKeys[i]]
            end
        end
    end
    self:RefreshPanelSale()
end

function XUiGridShop:RefreshPanelSale()
    local hideSales = false
    if self.TxtSaleRate then
        if self.Data.Tags == XShopManager.ShopTags.DisCount then
            if self.Sales < 100 then
                self.TxtSaleRate.text = self.Sales / 10 .. CS.XTextManager.GetText("Snap")
            else
                hideSales = true
            end
        end
        if self.Data.Tags == XShopManager.ShopTags.TimeLimit then
            self.TxtSaleRate.text = CS.XTextManager.GetText("TimeLimit")
        end
        if self.Data.Tags == XShopManager.ShopTags.Recommend then
            self.TxtSaleRate.text = CS.XTextManager.GetText("Recommend")
        end
        if self.Data.Tags == XShopManager.ShopTags.HotSale then
            self.TxtSaleRate.text = CS.XTextManager.GetText("HotSell")
        end
        if self.Data.Tags == XShopManager.ShopTags.Not or hideSales then
            self.TxtSaleRate.gameObject:SetActive(false)
            self.TxtSaleRate.gameObject.transform.parent.gameObject:SetActive(false)
        else
            self.TxtSaleRate.gameObject:SetActive(true)
            self.TxtSaleRate.gameObject.transform.parent.gameObject:SetActive(true)
            
        end
    end
end

function XUiGridShop:RefreshTimer(time)
    if not self.ImgLeftTime then
        return
    end
    
    if not self.TxtLeftTime then
        return
    end
    
    if time <= 0 then
        self.TxtLeftTime.gameObject:SetActive(false)
        self.ImgLeftTime.gameObject:SetActive(false)
        return
    end
    
    self.TxtLeftTime.gameObject:SetActive(true)
    self.ImgLeftTime.gameObject:SetActive(true)
    
    local leftTime = XShopManager.GetLeftTime(time)
    
    local func = function()
        leftTime = leftTime > 0 and leftTime or 0
        local dataTime = XUiHelper.GetTime(leftTime, XUiHelper.TimeFormatType.SHOP)
        self.TxtLeftTime.text = CS.XTextManager.GetText("TimeSoldOut", dataTime)
        
        if leftTime <= 0 then
            self:RemoveTimer()
            if self.ImgSellOut then
                self.ImgSellOut.gameObject:SetActive(true)
            end
        end
    end
    
    func()
    
    self.Timer = CS.XScheduleManager.Schedule(function(...)
        leftTime = leftTime - 1
        func()
    end, 1000, 0, 0)
end 