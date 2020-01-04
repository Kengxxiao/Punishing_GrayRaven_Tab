local XUiPurchasePayListItem = XClass()
local TextManager = CS.XTextManager
local PurchaseManager
local Next = _G.next

function XUiPurchasePayListItem:Ctor(ui,uiroot)
    PurchaseManager = XDataCenter.PurchaseManager
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Uiroot = uiroot
    XTool.InitUiObject(self)
    self.PanelLabel.gameObject:SetActive(false)
end

function XUiPurchasePayListItem:Init(uiroot,parent)
    self.UiRoot = uiroot
    self.Parent = parent
end

-- 更新数据
function XUiPurchasePayListItem:OnRefresh(itemdata)
    if not itemdata then
        return
    end

    self.ItemData = itemdata
    self.CurState = false
    self:SetSeleState(false)
    self:SetData()
end

function XUiPurchasePayListItem:SetData()
    self.TxtCzsl.text = self.ItemData.Name
    self.TxtContent.text = self.ItemData.Desc
    if self.ItemData.Icon then
        local assetpath = XPurchaseConfigs.GetIconPathByIconName(self.ItemData.Icon)
        if assetpath and assetpath.AssetPath then
            self.ImgCz:SetRawImage(assetpath.AssetPath,function()self.ImgCz:SetNativeSize()end)
        end
    end

    self.TxtYuan.text = self.ItemData.Amount
    
    -- -- 直接获得的道具
    -- local rewardGoods = self.ItemData.RewardGoodsList or {}

    -- -- 额外获得
    -- local extraRewardGood = self.ItemData.ExtraRewardGood or {}
    -- local extracount = extraRewardGood.Count or 0

    -- -- 首充获得物品
    -- local firstRewardGoods = self.ItemData.FirstRewardGoods or {}
    -- local firstcount = firstRewardGoods.Count or 0

    -- if extracount == 0 and firstcount == 0 then
    --     self.PanelLabel.gameObject:SetActive(false)
    -- else
    --     self.PanelLabel.gameObject:SetActive(true)
    --     local dircount = #rewardGoods or 0
    --     if self.ItemData.BuyTimes == 0 and firstcount == dircount then -- 首次购买而且双倍
    --         self.TxtGet.text = TextManager.GetText("PurchasePayFirstGetText")
    --     else
    --         self.TxtGet.text = TextManager.GetText("PurchasePayGetText",extracount,XDataCenter.ItemManager.GetItemName(extraRewardGood.TemplateId))
    --     end
    -- end
end

function XUiPurchasePayListItem:OnSeleState(state)
    if self.CurState == state then
        return
    end

    self.CurState = state
    self:SetSeleState(state)
end

function XUiPurchasePayListItem:SetSeleState(state)
    self.ImgSelectCz.gameObject:SetActive(state)
end

function XUiPurchasePayListItem:OnClick()
    self.CurState = not self.CurState
    self:SetSeleState(self.CurState)
end

return XUiPurchasePayListItem