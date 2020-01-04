local XUiPurchaseHKExchangeTips = XClass()
local TextManager = CS.XTextManager
local PurchaseManager
local ItemManager
local Next = _G.next

function XUiPurchaseHKExchangeTips:Ctor(ui,parent)
    PurchaseManager = XDataCenter.PurchaseManager
    ItemManager = XDataCenter.ItemManager
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Parent = parent
    XTool.InitUiObject(self)
end

-- 更新数据
function XUiPurchaseHKExchangeTips:OnRefresh(data)
    self:InitAdd()
    self.GameObject:SetActive(true)
    self.Parent.Uiroot:PlayAnimation("HkExChangeTipsEnable")
    self.ItemData = data
    self.TxtConsumeName.text = ItemManager.GetItemName(data.ConsumeId)
    self.TxtConsumeCount.text = data.ConsumeCount
    self.TxtTargetName.text = data.Name
    -- 直接获得的道具
    local rewardGoods = data.RewardGoodsList or {}
    -- 首充获得物品
    local firstRewardGoods = data.FirstRewardGoods or {}
    -- 额外获得
    local extraRewardGoods = data.ExtraRewardGoods or {}

    local count = 0
    if rewardGoods[1] then
        count = rewardGoods[1].Count
        self.TxtTargetName.text = ItemManager.GetItemName(rewardGoods[1].TemplateId)
    end

    if Next(extraRewardGoods) ~= nil then
        count = count + extraRewardGoods.Count
    end

    if Next(firstRewardGoods) ~= nil then
        count = count + firstRewardGoods.Count
    end

    self.TxtTargetCount.text = count
end

function XUiPurchaseHKExchangeTips:ReqBuy()
    self:PlayAnimation()
    -- self:Hide()
    if self.ItemData and self.ItemData.Id then
        self.Parent:ReqBuy(self.ItemData.Id)
    end
end

function XUiPurchaseHKExchangeTips:PlayAnimation()
    self.Parent.Uiroot:PlayAnimation("HkExChangeTipsDisable",function()self:Hide()end)
end

function XUiPurchaseHKExchangeTips:Hide()
    self.GameObject:SetActive(false)
end

function XUiPurchaseHKExchangeTips:InitAdd()
    local closefun = function()self:PlayAnimation()end
    self.BtnCancel.CallBack = closefun
    self.BtnCloseBg.CallBack = closefun
    self.BtnConfirm.CallBack = function()self:ReqBuy()end
end

return XUiPurchaseHKExchangeTips