local XUiPurchaseLB = XClass()
local TextManager = CS.XTextManager
local PurchaseManager
local Next = _G.next
local XUiPurchaseLBListItem = require("XUi/XUiPurchase/XUiPurchaseLBListItem")
local XUiPurchaseLBTips = require("XUi/XUiPurchase/XUiPurchaseLBTips")
local CurrentSchedule = nil

function XUiPurchaseLB:Ctor(ui,uiroot)
    PurchaseManager = XDataCenter.PurchaseManager
    self.CurState = false
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Uiroot = uiroot
    self.TimeFuns = {}
    self.TimeSaveFuns = {}
    XTool.InitUiObject(self)
    self.SellOutList = {}--买完了
    self.SellingList = {}--在上架中
    self.SellOffList = {}--下架了
    self.SellWaitList = {}--待上架中
    self:Init()
end

-- 先分类后排序
function XUiPurchaseLB:OnSortFun(data)
    self.SellOutList = {}--买完了
    self.SellingList = {}--在上架中
    self.SellOffList = {}--下架了
    self.SellWaitList = {}--待上架中
    self.ListData = {}

    local curtime = XTime.GetServerNowTimestamp()
    for _,v in pairs(data)do
        if v and not v.IsSelloutHide then
            if v.TimeToUnShelve > 0 and v.TimeToUnShelve <= curtime then--下架了
                table.insert(self.SellOffList,v)
            elseif v.TimeToShelve > 0 and v.TimeToShelve > curtime then--待上架中
                table.insert(self.SellWaitList,v)
            elseif v.BuyTimes > 0 and v.BuyLimitTimes > 0 and v.BuyTimes >= v.BuyLimitTimes then--买完了
                table.insert(self.SellOutList,v)
            else                                                       --在上架中,还能买。
                table.insert(self.SellingList,v)
            end
        end
    end

    --在上架中,还能买。
    if Next(self.SellingList) then
        table.sort(self.SellingList, XUiPurchaseLB.SortByPriority)
        for _,v in pairs(self.SellingList) do
            table.insert(self.ListData, v)
        end
    end

    --待上架中
    if Next(self.SellWaitList) then
        table.sort(self.SellWaitList, XUiPurchaseLB.SortByPriority)
        for _,v in pairs(self.SellWaitList) do
            table.insert(self.ListData, v)
        end
    end

    --买完了
    if Next(self.SellOutList) then
        table.sort(self.SellOutList, XUiPurchaseLB.SortByPriority)
        for _,v in pairs(self.SellOutList) do
            table.insert(self.ListData, v)
        end
    end

    --下架了
    if Next(self.SellOffList) then
        table.sort(self.SellOffList, XUiPurchaseLB.SortByPriority)
        for _,v in pairs(self.SellOffList) do
            table.insert(self.ListData, v)
        end
    end

end

function XUiPurchaseLB.SortByPriority(a,b)
    return a.Priority < b.Priority
end

function XUiPurchaseLB:StartLBTimer()
    if self.IsStart then
        return 
    end

    self.IsStart = true
    CurrentSchedule = CS.XScheduleManager.Schedule(function() self:UpdateLBTimer()end, 1000, 0)
end

function XUiPurchaseLB:UpdateLBTimer()
    if Next(self.TimeFuns) then
        for _,timerfun in pairs(self.TimeFuns)do
            if timerfun then
                timerfun()
            end
        end
        return
    end
    self:DestoryTimer()
end

function XUiPurchaseLB:RemoveTimerFun(id)
    self.TimeFuns[id] = nil
end

function XUiPurchaseLB:RecoverTimerFun(id)
    self.TimeFuns[id] = self.TimeSaveFuns[id]
    if self.TimeFuns[id] then
        self.TimeFuns[id](true)
    end
    self.TimeSaveFuns[id] = nil
end

function XUiPurchaseLB:RegisterTimerFun(id,fun,isSave)
    if not isSave then
        self.TimeFuns[id] = fun
        return
     end

    self.TimeSaveFuns[id] = self.TimeFuns[id]
    self.TimeFuns[id] = fun

end

-- 更新数据
function XUiPurchaseLB:OnRefresh(uiType)
    local data = PurchaseManager.GetDatasByUiType(uiType)
    if not data then
        return
    end

    self.CurUitype = uiType
    self.GameObject:SetActive(true)
    if Next(data) ~= nil then
        self:OnSortFun(data)
    end
    self.TimeFuns = {}
    self.TimeSaveFuns = {}
    self.DynamicTable:SetDataSource(self.ListData)
    self.DynamicTable:ReloadDataASync(1)
    self:StartLBTimer()
end

function XUiPurchaseLB:OnUpdate()
    if self.CurUitype then
        self:OnRefresh(self.CurUitype)
    end
end

function XUiPurchaseLB:HidePanel()
    self:DestoryTimer()
    self.GameObject:SetActive(false)
end

function XUiPurchaseLB:ShowPanel()
    self.GameObject:SetActive(true)
end

function XUiPurchaseLB:DestoryTimer()
    if CurrentSchedule then
        self.IsStart = false
        CS.XScheduleManager.UnSchedule(CurrentSchedule)
        CurrentSchedule = nil
    end
end

function XUiPurchaseLB:Init()
    self:InitList()
    self.BuyUITips = XUiPurchaseLBTips.New(self.PanelBuyTips,self.Uiroot,self)
    self.BuyCb = function() self:BuyReq() end
    self.UpdateCb = function() self:OnUpdate() end
end

function XUiPurchaseLB:InitList()
    self.DynamicTable = XDynamicTableNormal.New(self.Transform)
    self.DynamicTable:SetProxy(XUiPurchaseLBListItem)
    self.DynamicTable:SetDelegate(self)
end

-- [监听动态列表事件]
function XUiPurchaseLB:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:Init(self.Uiroot,self)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local data = self.ListData[index]
        grid:OnRefresh(data)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then
        local data = self.ListData[index]
        if not data then
            return 
        end

        self.CurData = data
        self.BuyUITips:OnRefresh(data,self.BuyCb)
    end
end

function XUiPurchaseLB:BuyReq()
    if self.CurData.BuyLimitTimes > 0 and self.CurData.BuyTimes == self.CurData.BuyLimitTimes then --卖完了，不管。
        XUiManager.TipText("PurchaseLiSellOut")
        return
    end

    if self.CurData.TimeToShelve > 0 and self.CurData.TimeToShelve > XTime.GetServerNowTimestamp() then --没有上架
        XUiManager.TipText("PurchaseBuyNotSet")
        return
    end
    
    if self.CurData.TimeToUnShelve > 0 and self.CurData.TimeToUnShelve < XTime.GetServerNowTimestamp() then --下架了
        XUiManager.TipText("PurchaseSettOff")
        return
    end

    if self.CurData.TimeToInvalid > 0 and self.CurData.TimeToInvalid < XTime.GetServerNowTimestamp() then --失效了
        XUiManager.TipText("PurchaseSettOff")
        return
    end

    if self.CurData and self.CurData.Id then
        self.BuyUITips:CloseTips()
        PurchaseManager.PurchaseRequest(self.CurData.Id,self.UpdateCb)
    end
end
return XUiPurchaseLB