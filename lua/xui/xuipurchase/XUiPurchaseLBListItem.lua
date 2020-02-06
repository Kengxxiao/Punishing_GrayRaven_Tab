local XUiPurchaseLBListItem = XClass()
local TextManager = CS.XTextManager
local PurchaseManager
local RestTypeConfig
local Next = _G.next
local UpdateTimerTypeEnum = {
    SettOff = 1,
    SettOn = 2
}
function XUiPurchaseLBListItem:Ctor(ui, uiroot)
    PurchaseManager = XDataCenter.PurchaseManager
    RestTypeConfig = XPurchaseConfigs.RestTypeConfig
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Uiroot = uiroot
    XTool.InitUiObject(self)
    self.TimerUpdataCb = function(isrecover) self:UpdataTimer(isrecover) end
end

-- 更新数据
function XUiPurchaseLBListItem:OnRefresh(itemdata)
    if not itemdata then
        return
    end

    self.ItemData = itemdata
    self:SetData()
end

function XUiPurchaseLBListItem:Init(uiroot, parent)
    self.UiRoot = uiroot
    self.Parent = parent
end

function XUiPurchaseLBListItem:SetData()
    if self.ItemData.Icon then
        local assetpath = XPurchaseConfigs.GetIconPathByIconName(self.ItemData.Icon)
        if assetpath and assetpath.AssetPath then
            self.ImgIconLb:SetRawImage(assetpath.AssetPath, function() self.ImgIconLb:SetNativeSize() end)
        end
    end
    self.TxtName.text = self.ItemData.Name
    self.ImgSellout.gameObject:SetActive(false)
    self.TxtUnShelveTime.gameObject:SetActive(false)
    self.Parent:RemoveTimerFun(self.ItemData.Id)
    self.RetimeSec = 0
    local curtime = XTime.GetServerNowTimestamp()

    local consumeCount = self.ItemData.ConsumeCount or 0
    if consumeCount == 0 then -- 免费的
        self.TxtHk.gameObject:SetActive(false)
        self.TxtFree.gameObject:SetActive(true)
        self.RedPoint.gameObject:SetActive(PurchaseManager.LBRedPoint())
    else
        self.RedPoint.gameObject:SetActive(false)
        self.TxtFree.gameObject:SetActive(false)
        self.TxtHk.gameObject:SetActive(true)
        local path = XDataCenter.ItemManager.GetItemIcon(self.ItemData.ConsumeId)
        if path then
            self.RawConsumeImage:SetRawImage(path)
        end
        self.TxtHk.text = self.ItemData.ConsumeCount or ""
    end

    local tag = self.ItemData.Tag
    if tag > 0 then
        self.PanelLabel.gameObject:SetActive(true)
        self.TxtTagDes.text = XPurchaseConfigs.GetTagDes(tag)
        --local path = XPurchaseConfigs.GetTagBgPath(tag)
        --if path then
        --    self.UiRoot:SetUiSprite(self.ImgTagBg,path)
        --end
        --path = XPurchaseConfigs.GetTagEffectPath(tag)
        --if path then
        --   self.FxGo.AssetName = path
        --    self.FxGo.Prefab = self.FxGo.gameObject:LoadPrefab(path)
        --    self.FxGo.gameObject:SetActive(true)
        --end
    else
        self.PanelLabel.gameObject:SetActive(false)
    end

    -- 上架时间
    if self.ItemData.TimeToShelve > 0 and curtime < self.ItemData.TimeToShelve then
        self.RetimeSec = self.ItemData.TimeToShelve - XTime.GetServerNowTimestamp()
        if self.RetimeSec > 0 then--大于0，注册。
            self.UpdateTimerType = UpdateTimerTypeEnum.SettOn
            self.Parent:RegisterTimerFun(self.ItemData.Id, function() self:UpdataTimer() end)
        else
            self.Parent:RemoveTimerFun(self.ItemData.Id)
        end
        self.TxtPutawayTime.gameObject:SetActive(true)
        self.TxtHk.gameObject:SetActive(false)
        self.TxtFree.gameObject:SetActive(false)
        self.TxtQuota.gameObject:SetActive(true)
        self.TxtPutawayTime.text = TextManager.GetText("PurchaseSetOnTime", XUiHelper.GetTime(self.RetimeSec, XUiHelper.TimeFormatType.PURCHASELB))
        self:SetBuyDes()
        return
    end

    -- 达到限购次数
    if self.ItemData.BuyLimitTimes and self.ItemData.BuyLimitTimes > 0 and self.ItemData.BuyTimes == self.ItemData.BuyLimitTimes then
        self.TxtPutawayTime.gameObject:SetActive(false)
        self.ImgSellout.gameObject:SetActive(true)
        self.TxtSetOut.text = TextManager.GetText("PurchaseSettOut")
        self.TxtFree.gameObject:SetActive(false)
        self.TxtQuota.gameObject:SetActive(false)
        self.TxtHk.gameObject:SetActive(false)
        return
    end


    self.TxtQuota.gameObject:SetActive(true)
    self:SetBuyDes()

    --有失效时间只显示失效时间。
    -- 失效时间
    self.TxtPutawayTime.gameObject:SetActive(false)
    if self.ItemData.TimeToInvalid and self.ItemData.TimeToInvalid > 0 then
        self.RetimeSec = self.ItemData.TimeToInvalid - XTime.GetServerNowTimestamp()
        if self.RetimeSec > 0 then--大于0，注册。
            self.UpdateTimerType = UpdateTimerTypeEnum.SettOff
            self.Parent:RegisterTimerFun(self.ItemData.Id, self.TimerUpdataCb)
            self.TxtUnShelveTime.gameObject:SetActive(true)
            self.TxtUnShelveTime.text = TextManager.GetText("PurchaseSetOffTime", XUiHelper.GetTime(self.RetimeSec, XUiHelper.TimeFormatType.PURCHASELB))
        else
            self.Parent:RemoveTimerFun(self.ItemData.Id)
            self.TxtUnShelveTime.gameObject:SetActive(false)
            self.ImgSellout.gameObject:SetActive(true)
            self.TxtSetOut.text = TextManager.GetText("PurchaseLBSettOff")
        end
        return
    end

    -- 下架时间
    if self.ItemData.TimeToUnShelve > 0 then
        if curtime < self.ItemData.TimeToUnShelve then
            self.RetimeSec = self.ItemData.TimeToUnShelve - XTime.GetServerNowTimestamp()
            if self.RetimeSec > 0 then--大于0，注册。
                self.UpdateTimerType = UpdateTimerTypeEnum.SettOff
                self.Parent:RegisterTimerFun(self.ItemData.Id, self.TimerUpdataCb)
                self.TxtUnShelveTime.gameObject:SetActive(true)
                self.TxtUnShelveTime.text = TextManager.GetText("PurchaseSetOffTime", XUiHelper.GetTime(self.RetimeSec, XUiHelper.TimeFormatType.PURCHASELB))
            else
                self.Parent:RemoveTimerFun(self.ItemData.Id)
                self.TxtUnShelveTime.gameObject:SetActive(false)
            end
        else
            self.ImgSellout.gameObject:SetActive(true)
            self.TxtUnShelveTime.text = ""
            self.TxtSetOut.text = TextManager.GetText("PurchaseLBSettOff")
        end
    else
        self.TxtUnShelveTime.gameObject:SetActive(false)
    end
end

function XUiPurchaseLBListItem:SetBuyDes()
    local clientResetInfo = self.ItemData.ClientResetInfo or {}
    if Next(clientResetInfo) == nil then
        if self.ItemData.BuyLimitTimes > 0 then
            self.TxtQuota.text = TextManager.GetText("PurchaseLimitBuy", self.ItemData.BuyTimes, self.ItemData.BuyLimitTimes)
        else
            self.TxtQuota.text = ""
        end
        return
    end

    local textKey = ""
    if clientResetInfo.ResetType == RestTypeConfig.Interval then
        self.TxtQuota.text = TextManager.GetText("PurchaseRestTypeInterval", clientResetInfo.DayCount, self.ItemData.BuyTimes, self.ItemData.BuyLimitTimes)
        return
    elseif clientResetInfo.ResetType == RestTypeConfig.Day then
        textKey = "PurchaseRestTypeDay"
    elseif clientResetInfo.ResetType == RestTypeConfig.Week then
        textKey = "PurchaseRestTypeWeek"
    elseif clientResetInfo.ResetType == RestTypeConfig.Moonth then
        textKey = "PurchaseRestTypeMonth"
    end
    self.TxtQuota.text = TextManager.GetText(textKey, self.ItemData.BuyTimes, self.ItemData.BuyLimitTimes)
end

-- 更新倒计时
function XUiPurchaseLBListItem:UpdataTimer(isrecover)
    if self.ItemData.TimeToInvalid == 0 and self.ItemData.TimeToUnShelve == 0 and self.ItemData.TimeToShelve == 0 then
        return
    end

    if isrecover then
        if self.UpdateTimerType == UpdateTimerTypeEnum.SettOff then
            if self.ItemData.TimeToInvalid > 0 then
                self.RetimeSec = self.ItemData.TimeToInvalid - XTime.GetServerNowTimestamp()
            else
                self.RetimeSec = self.ItemData.TimeToUnShelve - XTime.GetServerNowTimestamp()
            end
        else
            self.RetimeSec = self.ItemData.TimeToShelve - XTime.GetServerNowTimestamp()
        end
    else
        self.RetimeSec = self.RetimeSec - 1
    end

    if self.RetimeSec <= 0 then
        self.Parent:RemoveTimerFun(self.ItemData.Id)
        if self.UpdateTimerType == UpdateTimerTypeEnum.SettOff then
            self.ImgSellout.gameObject:SetActive(true)
            self.TxtUnShelveTime.text = ""
            self.TxtSetOut.text = TextManager.GetText("PurchaseLBSettOff")
            return
        end

        self.TxtPutawayTime.text = ""
        return
    end

    if self.UpdateTimerType == UpdateTimerTypeEnum.SettOff then
        self.TxtUnShelveTime.text = TextManager.GetText("PurchaseSetOffTime", XUiHelper.GetTime(self.RetimeSec, XUiHelper.TimeFormatType.PURCHASELB))
        return
    end

    self.TxtPutawayTime.text = TextManager.GetText("PurchaseSetOnTime", XUiHelper.GetTime(self.RetimeSec, XUiHelper.TimeFormatType.PURCHASELB))
end
return XUiPurchaseLBListItem