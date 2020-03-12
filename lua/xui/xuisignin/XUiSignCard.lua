local XUiSignCard = XClass()

function XUiSignCard:Ctor(ui, rootUi)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi

    XTool.InitUiObject(self)
    self:InitAddListen()
end

function XUiSignCard:OnHide()
    XEventManager.RemoveEventListener(XEventId.EVENT_CARD_REFRESH_WELFARE_BTN, self.Refresh, self)
end

function XUiSignCard:OnShow()
    XEventManager.AddEventListener(XEventId.EVENT_CARD_REFRESH_WELFARE_BTN, self.Refresh, self)
end

function XUiSignCard:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiSignCard:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiSignCard:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiSignCard:InitAddListen()
    self:RegisterClickEvent(self.BtnSkip, self.OnBtnSkipClick)
    self:RegisterClickEvent(self.BtnHelp, self.OnBtnHelpClick)
    self:RegisterClickEvent(self.BtnContinue, self.OnBtnContinueClick)
    self:RegisterClickEvent(self.BtnGet, self.OnBtnGetClick)
end

function XUiSignCard:OnBtnSkipClick()
    XDataCenter.AutoWindowManager.StopAutoWindow()
    XLuaUiManager.Open("UiPurchase", XPurchaseConfigs.TabsConfig.YK, false)
end

function XUiSignCard:OnBtnHelpClick()
    XUiManager.UiFubenDialogTip("", self.Config.Description or "")
end

function XUiSignCard:OnBtnContinueClick()
    XDataCenter.AutoWindowManager.StopAutoWindow()
    XLuaUiManager.Open("UiPurchase", XPurchaseConfigs.TabsConfig.YK, false)
end

function XUiSignCard:OnBtnGetClick()
    XDataCenter.PurchaseManager.YKInfoDataReq(function()
        local data = XDataCenter.PurchaseManager.GetYKInfoData()
        if not data then
            return
        end

        if data.IsDailyRewardGet then
            XUiManager.TipText("ChallengeRewardIsGetted")
        else
            XDataCenter.PurchaseManager.PurchaseGetDailyRewardRequest(data.Id, function()
                self:RefreshGet()
            end)
        end
    end)
end

function XUiSignCard:Refresh(configId)
    XDataCenter.PurchaseManager.YKInfoDataReq(function()
        if not configId then
            configId = self.ConfigId
        end
        self.ConfigId = configId

        self.PanelBuy.gameObject:SetActive(false)
        self.PanelGet.gameObject:SetActive(false)

        self.Config = XSignInConfigs.GetSignCardConfig(configId)
        local isBuy = XDataCenter.PurchaseManager.IsYkBuyed()
        if isBuy then
            self:RefreshGet()
        else
            self:RefreshBuy()
        end
        XEventManager.DispatchEvent(XEventId.EVENT_SING_IN_OPEN_BTN, true)
    end)
end

function XUiSignCard:RefreshBuy()
    self.PanelBuy.gameObject:SetActive(true)
end

function XUiSignCard:RefreshGet()
    local data = XDataCenter.PurchaseManager.GetYKInfoData()
    if not data then
        return
    end

    self.TxtLeftDay.text = data.DailyRewardRemainDay
    self.BtnContinue.gameObject:SetActive(data.DailyRewardRemainDay < self.Config.CanBuyDay)
    if data.IsDailyRewardGet then
        self.BtnGet:SetButtonState(CS.UiButtonState.Disable)
    else
        self.BtnGet:SetButtonState(CS.UiButtonState.Normal)
    end

    self.PanelGet.gameObject:SetActive(true)
end

return XUiSignCard