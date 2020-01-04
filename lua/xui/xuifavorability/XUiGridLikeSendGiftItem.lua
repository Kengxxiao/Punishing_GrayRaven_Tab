XUiGridLikeSendGiftItem = XClass()

function XUiGridLikeSendGiftItem:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
end

function XUiGridLikeSendGiftItem:Init(uiRoot)
    self.UiRoot = uiRoot
end

function XUiGridLikeSendGiftItem:ResetSelect()
    self:OnSelect(false)    
end

function XUiGridLikeSendGiftItem:OnRefresh(trustItemData, index)  
    self.TrustItem = trustItemData
    local characterId = self.UiRoot:GetCurrFavorabilityCharacter()
    self.RImgIcon:SetRawImage(XDataCenter.ItemManager.GetItemIcon(trustItemData.Id))
    self.ImgFlag.gameObject:SetActive(self:IsContains(trustItemData.FavorCharacterId, characterId))
    local giftQuality = XDataCenter.ItemManager.GetItemQuality(trustItemData.Id)
    self.UiRoot:SetUiSprite(self.ImgIconBg, XFavorabilityConfigs.GetQualityIconByQuality(giftQuality))
    self.TxtGridCount.text = XDataCenter.ItemManager.GetCount(trustItemData.Id)
    self:OnSelect()
end

function XUiGridLikeSendGiftItem:IsContains(container, item)
    for k, v in pairs(container or {}) do
        if v == item then
            return true
        end
    end
    return false
end

function XUiGridLikeSendGiftItem:OnSelect()
    if self.TrustItem then
        self.ImgSelect.gameObject:SetActive(self.TrustItem.IsSelect)
    end
end



return XUiGridLikeSendGiftItem
