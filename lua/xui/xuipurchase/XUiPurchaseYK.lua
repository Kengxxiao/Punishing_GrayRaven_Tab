local XUiPurchaseYK = XClass()
local TextManager = CS.XTextManager
local PurchaseManager
local Next = _G.next
local XUiPurchaseYKListItem = require("XUi/XUiPurchase/XUiPurchaseYKListItem")
local XUiPurchaseLBTips = require("XUi/XUiPurchase/XUiPurchaseLBTips")
local BuyState = {
    CanBuy = 1,
    NotCanBuy = 2
}
local TotalCountLimit
local CountLimit

function XUiPurchaseYK:Ctor(ui, uiroot)
    PurchaseManager = XDataCenter.PurchaseManager
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.UiRoot = uiroot
    TotalCountLimit = CS.XGame.ClientConfig:GetInt("PurchaseYKTotalCount") or 1
    CountLimit = CS.XGame.ClientConfig:GetInt("PurchaseYKLimtCount") or 30
    XTool.InitUiObject(self)
    self:Init()
end

-- 更新数据
function XUiPurchaseYK:OnRefresh(uiType)
    local data = PurchaseManager.GetDatasByUiType(uiType)
    if not data or not data[1] then
        return
    end

    PurchaseManager.SetYKContinueBuy()
    self.CurUitype = uiType
    self.Data = data[1]
    self.GameObject:SetActive(true)
    self:SetData()
end

function XUiPurchaseYK:OnUpdate()
    -- 设置月卡信息本地缓存
    XDataCenter.PurchaseManager.SetYKLoaclCache()

    if self.CurUitype then
        self:OnRefresh(self.CurUitype)
    end
end

function XUiPurchaseYK:SetData()
    if self.Data.BuyTimes > 0 then
        local curlimitcount = math.ceil(self.Data.DailyRewardRemainDay / CountLimit)
        self.Txtlimit.text = TextManager.GetText("PurchaseYKBuyLimt",curlimitcount,TotalCountLimit)
        local clientResetInfo = self.Data.ClientResetInfo
        if clientResetInfo and clientResetInfo.DayCount >= self.Data.DailyRewardRemainDay and curlimitcount < TotalCountLimit then
            if self.Data.DailyRewardRemainDay > 0 then
                self.BtnYkBuy:SetName(TextManager.GetText("PurchaseYKBuyText2"))
            else
                local name = XDataCenter.ItemManager.GetItemName(self.Data.ConsumeId)
                self.BtnYkBuy:SetName(TextManager.GetText("PurchaseYKBuyText1",self.Data.ConsumeCount,name))
            end
            self.CurBuyState = BuyState.CanBuy
        else
            self.CurBuyState = BuyState.NotCanBuy
            self.BtnYkBuy:SetName(TextManager.GetText("PurchaseYKBuyText3"))
        end
        self.TxtSurplus.text = TextManager.GetText("PurchaseYKSurplusDay",self.Data.DailyRewardRemainDay)
    else
        self.Txtlimit.text = TextManager.GetText("PurchaseYKBuyLimt",0,TotalCountLimit)
        self.CurBuyState = BuyState.CanBuy
        local name = XDataCenter.ItemManager.GetItemName(self.Data.ConsumeId)
        self.BtnYkBuy:SetName(TextManager.GetText("PurchaseYKBuyText1",self.Data.ConsumeCount,name))
        self.TxtSurplus.text = TextManager.GetText("PurchaseYKSurplusDay",0)
    end


    self.TxtYuan.text = self.Data.ConsumeCount
    local rewardGoodsList = self.Data.RewardGoodsList or {}
    if Next(rewardGoodsList) ~= nil then
        local r = rewardGoodsList[1]
        self.TextPromptlyGet.text = TextManager.GetText("PurchaseYKGetTips",r.Count,XDataCenter.ItemManager.GetItemName(r.TemplateId))
    end

    local dailyrewardgoodslist = self.Data.DailyRewardGoodsList or {}
    if Next(dailyrewardgoodslist) ~= nil then
        local r = dailyrewardgoodslist[1]
        self.TextDayGet.text = self.Data.Desc--TextManager.GetText("PurchaseYKDayGet",30,r.Count,XDataCenter.ItemManager.GetItemName(r.TemplateId))
    end
    
    self.TxtCName.text = XDataCenter.ItemManager.GetItemName(self.Data.ConsumeId)
end

function XUiPurchaseYK:HidePanel()
    self.CurState = false
    self.GameObject:SetActive(false)
end

function XUiPurchaseYK:ShowPanel()
    self.GameObject:SetActive(true)
end

function XUiPurchaseYK:Init()
    self.BtnYkBuy.CallBack = function() self:OnBtnYkBuy() end
    self.BtnHelp.CallBack = function() self:OnBtnHelp() end
    self.BuyUITips = XUiPurchaseLBTips.New(self.PanelBuyTips,self.UiRoot)
    self.BuyCb = function() self:BuyReq() end
    self.UpdateCb = function() self:OnUpdate() end
    self.Txtlimit.gameObject:SetActive(true)
end

function XUiPurchaseYK:OnBtnYkBuy()
    if self.CurBuyState == BuyState.NotCanBuy then
        XUiManager.TipText("PurchaseNotBuy")
        return
    end

    self.BuyUITips:OnRefresh(self.Data,self.BuyCb)
end

function XUiPurchaseYK:OnBtnHelp()
    XUiManager.UiFubenDialogTip("", TextManager.GetText("PurchaseYKDes") or "")
end

function XUiPurchaseYK:BuyReq()
    if self.Data.BuyLimitTimes > 0 and self.Data.BuyTimes == self.Data.BuyLimitTimes then --卖完了，不管。
        XUiManager.TipText("PurchaseLiSellOut")
        return
    end

    if self.Data.TimeToShelve > 0 and self.Data.TimeToShelve > XTime.GetServerNowTimestamp() then --没有上架
        XUiManager.TipText("PurchaseBuyNotSet")
        return
    end
    
    if self.Data.TimeToUnShelve > 0 and self.Data.TimeToUnShelve < XTime.GetServerNowTimestamp() then --下架了
        XUiManager.TipText("PurchaseSettOff")
        return
    end

    if self.Data and self.Data.Id then
        self.BuyUITips:CloseTips()
        PurchaseManager.PurchaseRequest(self.Data.Id,self.UpdateCb)
    end
end
return XUiPurchaseYK