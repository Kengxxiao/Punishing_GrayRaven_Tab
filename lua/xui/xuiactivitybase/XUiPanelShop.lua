local CSXTextManagerGetText = CS.XTextManager.GetText
local CSXDateGetTime = CS.XDate.GetTime
local CSXDateFormatTime = CS.XDate.FormatTime

local XUiPanelShop = XClass()

function XUiPanelShop:Ctor(ui, rootUi)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    XTool.InitUiObject(self)

    self.AssetActivityPanel = XUiPanelActivityAsset.New(self.PanelActivityAsset)
    self.ItemActivity = XUiPanelItemList.New(self.PanelItemActivity, self, self.RootUi)
    self.ShopBuy = XUiPanelShopItem.New(self.PanelShopItem, self, self.RootUi)
end

function XUiPanelShop:OnDestroy()
    self:RemoveTimer()
end

function XUiPanelShop:Refresh(activityCfg)
    if not activityCfg then return end

    local format = "yyyy-MM-dd HH:mm"
    local beginTime = CSXDateGetTime(activityCfg.BeginTime)
    local endTime = CSXDateGetTime(activityCfg.EndTime)
    local beginTimeStr = CSXDateFormatTime(beginTime, format)
    local endTimeStr = CSXDateFormatTime(endTime, format)
    self.TxtContentTimeShop.text = beginTimeStr .. "~" .. endTimeStr
    self.TxtContentTitleShop.text = activityCfg.ActivityTitle

    self.PanelShopInformation.gameObject:SetActive(false)

    self.ShopId = activityCfg.Params[1]
    XShopManager.ClearBaseInfoData()
    XShopManager.GetBaseInfo(function()
        self:UpdateShopInfo()
    end)
end

function XUiPanelShop:UpdateShopInfo(isNotSync)
    local shopId = self.ShopId
    XShopManager.GetShopInfo(shopId, function()
        self:UpdateBuyInfo()
        self:UpdateManualRefreshInfo()
        self:UpdateTimeInfo()
        self.AssetActivityPanel:Refresh(XShopManager.GetShopShowIdList(shopId))
        self.ItemActivity:ShowPanel(shopId, isNotSync)
    end)
end

function XUiPanelShop:UpdateManualRefreshInfo()
    local costInfo = XShopManager.GetManualRefreshCost(self.ShopId)
    if not costInfo or not costInfo.ManualResetTimesLimit then
        self.BtnRefresh.gameObject:SetActive(false)
        self.TxtRefreshFrequency.gameObject:SetActive(false)
        return
    end

    if costInfo.RefreshCostId and costInfo.RefreshCostId > 0 and
    costInfo.RefreshCostCount and costInfo.RefreshCostCount > 0 then
        self.TxtAmount.text = "X " .. costInfo.RefreshCostCount
        self.RImgIconProp:SetRawImage(XDataCenter.ItemManager.GetItemIcon(costInfo.RefreshCostId))
        self.TxtAmount.gameObject:SetActive(true)
        self.RImgIconProp.gameObject:SetActive(true)
    else
        self.TxtAmount.gameObject:SetActive(false)
        self.RImgIconProp.gameObject:SetActive(false)
    end

    local manualResetTimesLimit = costInfo.ManualResetTimesLimit
    if manualResetTimesLimit == -1 then
        self.TxtRefreshFrequency.gameObject:SetActive(false)
    else
        local leftTimes = manualResetTimesLimit - costInfo.ManualRefreshTimes
        self.TxtRefreshFrequency.text = leftTimes .. "/" .. manualResetTimesLimit
        self.TxtRefreshFrequency.gameObject:SetActive(true)
        self.PanelShopInformation.gameObject:SetActive(true)
    end

    self.BtnRefresh.gameObject:SetActive(true)
end

--购买次数信息
function XUiPanelShop:UpdateBuyInfo()
    local buyInfo = XShopManager.GetShopBuyInfo(self.ShopId)
    if buyInfo then
        local buyTimes = buyInfo.TotalBuyTimes
        local limitTimes = buyInfo.BuyTimesLimit
        if limitTimes > 0 then
            local buyCount = buyTimes and limitTimes - buyTimes or limitTimes
            self.TxtAllLeftCout.text = CSXTextManagerGetText("BuyCount", buyCount, limitTimes)
            self.TxtBuyFrequency.gameObject:SetActive(true)
            self.PanelShopInformation.gameObject:SetActive(true)
        else
            self.TxtBuyFrequency.gameObject:SetActive(false)
        end
    else
        self.TxtBuyFrequency.gameObject:SetActive(false)
    end
end

function XUiPanelShop:UpdateTimeInfo()
    self:RemoveTimer()
    self.TxtLeftTime.gameObject:SetActive(false)
    self.TxtRefreshTime.gameObject:SetActive(false)

    local timeInfo = XShopManager.GetShopTimeInfo(self.ShopId)
    if not timeInfo or not next(timeInfo) then
        return
    end

    local refreshFunc, closedFunc

    local leftTime = timeInfo.RefreshLeftTime
    if leftTime and leftTime > 0 then
        refreshFunc = function()
            local dataTime = XUiHelper.GetTime(leftTime, XUiHelper.TimeFormatType.SHOP)
            self.TxtRefreshTime.text = CSXTextManagerGetText("ShopAutoRefresh") .. dataTime
            leftTime = leftTime - 1

            if leftTime < 0 then
                refreshFunc = nil
            end
        end
    end

    local closedLeftTime = timeInfo.ClosedLeftTime
    if closedLeftTime and closedLeftTime > 0 then
        closedFunc = function()
            local dataTime = XUiHelper.GetTime(closedLeftTime, XUiHelper.TimeFormatType.SHOP)
            self.TxtLeftTime.text = CSXTextManagerGetText("ActiveTime", dataTime)
            closedLeftTime = closedLeftTime - 1

            if closedLeftTime < 0 then
                closedFunc = nil
            end
        end
    end

    if refreshFunc then
        refreshFunc()
        self.TxtRefreshTime.gameObject:SetActive(true)
        self.PanelShopInformation.gameObject:SetActive(true)
    end

    if closedFunc then
        closedFunc()
        self.TxtLeftTime.gameObject:SetActive(true)
        self.PanelShopInformation.gameObject:SetActive(true)
    end

    self.Timer = CS.XScheduleManager.Schedule(function()
        if not refreshFunc and not closedFunc then
            self:RemoveTimer()
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

function XUiPanelShop:RemoveTimer()
    if self.Timer then
        CS.XScheduleManager.UnSchedule(self.Timer)
    end
end

function XUiPanelShop:GetCurShopId()
    return self.ShopId
end

function XUiPanelShop:RefreshBuy()
    local shopId = self.ShopId
    self.AssetActivityPanel:Refresh(XShopManager.GetShopShowIdList(shopId))
    self:UpdateShopInfo(true)
end

function XUiPanelShop:UpdataBuy(data, cb)
    self.ShopBuy:ShowPanel(data, cb)
end

return XUiPanelShop