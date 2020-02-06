XUiPanelShopPeriod = XClass()

function XUiPanelShopPeriod:Ctor(ui, parent)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Parent = parent
    self:InitAutoScript()
    self.RefShopTime = nil
    self.CloseTimer = nil
end

function XUiPanelShopPeriod:InitAutoScript()
    XTool.InitUiObject(self)
    self:AutoAddListener()
end

function XUiPanelShopPeriod:AutoAddListener()
    self.BtnRefresh.CallBack = function()
        self:OnBtnRefreshClick()
    end
end
-- auto
function XUiPanelShopPeriod:OnBtnRefreshClick(...)
    XShopManager.RefreshShopGoods(self.ShopId, function()
        self:UpdateManualRefreshInfo()
        self.Parent:RefreshBuy(false)
    end)
    self.Parent:PlayAnimation("AnimQieHuan")
end

function XUiPanelShopPeriod:HidePanel()
    self.ShopId = nil
    self:RemoveTimer()
    if not XTool.UObjIsNil(self.GameObject) then
        self.GameObject:SetActiveEx(false)
    end
end

function XUiPanelShopPeriod:RemoveTimer()
    if self.Timer then
        CS.XScheduleManager.UnSchedule(self.Timer)
    end
end

function XUiPanelShopPeriod:ShowPanel(shopId)
    if shopId then
        self.ShopId = shopId
    end
    
    self:UpdateShopBuyInfo()
    self:UpdateManualRefreshInfo()
    self:RemoveTimer()
    self:ShowTimer()
    self:SetPanelActive()
    self.GameObject:SetActive(true)
end

function XUiPanelShopPeriod:UpdateManualRefreshInfo()
    local costInfo = XShopManager.GetManualRefreshCost(self.ShopId)
    if not costInfo or not costInfo.ManualResetTimesLimit then
        self.BtnRefresh.gameObject:SetActive(false)
        return
    end
    
    if costInfo.RefreshCostId and costInfo.RefreshCostId > 0 and
    costInfo.RefreshCostCount and costInfo.RefreshCostCount > 0 then
        self.TxtRefAsset.text = costInfo.RefreshCostCount
        self.RImgRef:SetRawImage(XDataCenter.ItemManager.GetItemIcon(costInfo.RefreshCostId))
        self.TxtRefAsset.gameObject:SetActive(true)
        self.RImgRef.gameObject:SetActive(true)
    else
        self.TxtRefAsset.gameObject:SetActive(false)
        self.RImgRef.gameObject:SetActive(false)
    end
    
    if costInfo.ManualResetTimesLimit == - 1 then
        self.TxtContent.gameObject:SetActive(false)
    else
        local leftTimes = costInfo.ManualResetTimesLimit - costInfo.ManualRefreshTimes
        self.TxtContent.text = CS.XTextManager.GetText("ShopResetTimes", leftTimes, costInfo.ManualResetTimesLimit)
        self.TxtContent.gameObject:SetActive(true)
    end
    self.BtnRefresh.gameObject:SetActive(true)
end

function XUiPanelShopPeriod:UpdateShopBuyInfo()
    local buyInfo = XShopManager.GetShopBuyInfo(self.ShopId)
    if not buyInfo then
        self.TxtAllLeftCout.gameObject:SetActive(false)
        return
    end
    
    if not buyInfo.BuyTimesLimit or buyInfo.BuyTimesLimit == 0 then
        self.TxtAllLeftCout.gameObject:SetActive(false)
    else
        local buyCount = buyInfo.TotalBuyTimes and buyInfo.BuyTimesLimit - buyInfo.TotalBuyTimes or buyInfo.BuyTimesLimit
        self.TxtAllLeftCout.text = CS.XTextManager.GetText("BuyCount", buyCount, buyInfo.BuyTimesLimit)
        self.TxtAllLeftCout.gameObject:SetActive(true)
    end
end

--开始倒计时时间
function XUiPanelShopPeriod:ShowTimer()
    self.TxtLeftTime.gameObject:SetActive(false)
    self.TxtRefreshTime.gameObject:SetActive(false)
    local timeInfo = XShopManager.GetShopTimeInfo(self.ShopId)
    
    if not timeInfo or not next(timeInfo) then
        return
    end
    
    local refreshFunc, closedFunc
    
    if timeInfo.RefreshLeftTime and timeInfo.RefreshLeftTime > 0 then
        refreshFunc = function()
            local dataTime = XUiHelper.GetTime(timeInfo.RefreshLeftTime, XUiHelper.TimeFormatType.SHOP)
            self.TxtRefreshTime.text = CS.XTextManager.GetText("ShopAutoRefresh") .. dataTime
            timeInfo.RefreshLeftTime = timeInfo.RefreshLeftTime - 1
            
            if timeInfo.RefreshLeftTime < 0 then
                refreshFunc = nil
            end
        end
    end
    
    if timeInfo.ClosedLeftTime and timeInfo.ClosedLeftTime > 0 then
        closedFunc = function()
            local dataTime = XUiHelper.GetTime(timeInfo.ClosedLeftTime, XUiHelper.TimeFormatType.SHOP)
            self.TxtLeftTime.text = CS.XTextManager.GetText("ActiveTime", dataTime)
            timeInfo.ClosedLeftTime = timeInfo.ClosedLeftTime - 1
            
            if timeInfo.ClosedLeftTime < 0 then
                closedFunc = nil
            end
        end		
    end
    
    if not refreshFunc and not closedFunc then
        return
    end
    
    if refreshFunc then
        refreshFunc()
        self.TxtRefreshTime.gameObject:SetActive(true)
    end
    
    if closedFunc then
        closedFunc()
        self.TxtLeftTime.gameObject:SetActive(true)
    end
    
    self.Timer = CS.XScheduleManager.Schedule(function()
        if timeInfo.ClosedLeftTime and not closedFunc then
            self:RemoveTimer()
            XShopManager.GetShopInfo(self.ShopId, function()
                    self.Parent:RefreshBuy(false)
            end)
            return
        end
        if timeInfo.RefreshLeftTime and not refreshFunc then
           self:RemoveTimer()
            XShopManager.GetShopInfo(self.ShopId, function()
                    self.Parent:RefreshBuy(false)
                    self:ShowTimer()
            end)
            return
        end
        
            
        if refreshFunc then
            refreshFunc()
        end
        
        if closedFunc then
            closedFunc()
        end
    end, 1000, 0, 0)
end

function XUiPanelShopPeriod:SetPanelActive()
    self.PanelTxt.gameObject:SetActive(self.TxtLeftTime.gameObject.activeSelf or self.TxtAllLeftCout.gameObject.activeSelf or self.TxtRefreshTime.gameObject.activeSelf or self.BtnRefresh.gameObject.activeSelf)
end