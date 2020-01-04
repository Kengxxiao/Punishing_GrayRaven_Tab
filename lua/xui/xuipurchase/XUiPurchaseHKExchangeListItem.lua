local XUiPurchaseHKExchangeListItem = XClass()
local TextManager = CS.XTextManager
local PurchaseManager
local ItemManager

function XUiPurchaseHKExchangeListItem:Ctor(ui,uiroot)
    PurchaseManager = XDataCenter.PurchaseManager
    ItemManager = XDataCenter.ItemManager
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Uiroot = uiroot
    XTool.InitUiObject(self)
end

-- 更新数据
function XUiPurchaseHKExchangeListItem:OnRefresh(itemdata)
    if not itemdata then
        return
    end

    self.ItemData = itemdata

    -- 直接获得的道具
    local rewardGoods = self.ItemData.RewardGoodsList or {}

    -- 额外获得
    local extraRewardGood = self.ItemData.ExtraRewardGoods or {}
    local extracount = extraRewardGood.Count or 0

    -- 首充获得物品
    local firstRewardGoods = self.ItemData.FirstRewardGoods or {}
    local firstcount = firstRewardGoods.Count or 0

    self.TxtName.text = self.ItemData.Desc
    self.RawImageConsu:SetRawImage(ItemManager.GetItemIcon(itemdata.ConsumeId))
    if itemdata.Icon then
        local assetpath = XPurchaseConfigs.GetIconPathByIconName(itemdata.Icon)
        if assetpath and assetpath.AssetPath then
            self.ImgIconDh:SetRawImage(assetpath.AssetPath)
        end
    end

    self.TxtHk.text = itemdata.ConsumeCount

    if extracount == 0 and firstcount == 0 then
        self.PanelFirstLabel.gameObject:SetActive(false)
        self.PanelNormalLabel.gameObject:SetActive(false)
    else
        local dircount = 0
        if rewardGoods[1] then
            dircount = rewardGoods[1].Count or 0
        end

        if self.ItemData.BuyTimes == 0 or firstcount > 0 then
            if firstcount == dircount then -- 首次购买而且双倍
                self.PanelFirstLabel.gameObject:SetActive(true)
                self.PanelNormalLabel.gameObject:SetActive(true)
                self.TxtFirst.text = TextManager.GetText("PurchasePayFirstGetText")
                if firstRewardGoods.TemplateId then
                    self.TxtNormal.text = TextManager.GetText("PurchaseFirstPayTips",firstcount,ItemManager.GetItemName(firstRewardGoods.TemplateId))
                end               
            else
                self.PanelFirstLabel.gameObject:SetActive(false)
                self.PanelNormalLabel.gameObject:SetActive(true)
                if firstRewardGoods.TemplateId then
                    self.TxtNormal.text = TextManager.GetText("PurchaseFirstPayTips",firstcount,ItemManager.GetItemName(firstRewardGoods.TemplateId))
                end
            end
        else
            self.PanelNormalLabel.gameObject:SetActive(false)
            self.PanelFirstLabel.gameObject:SetActive(false)
            if extracount > 0 and extraRewardGood.TemplateId then
                self.PanelNormalLabel.gameObject:SetActive(true)
                self.TxtNormal.text = TextManager.GetText("PurchasePayGetText",extracount,ItemManager.GetItemName(extraRewardGood.TemplateId))
            end
        end
    end
end

function XUiPurchaseHKExchangeListItem:Init(uiroot,parent)
    self.UiRoot = uiroot
    self.Parent = parent
end

return XUiPurchaseHKExchangeListItem