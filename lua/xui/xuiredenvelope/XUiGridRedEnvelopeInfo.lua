local XUiGridRedEnvelopeInfo = XClass()

function XUiGridRedEnvelopeInfo:Ctor(ui, parent)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
    self:InitParent(parent)
end

function XUiGridRedEnvelopeInfo:InitParent(parent)
    self.Parent = parent
end

function XUiGridRedEnvelopeInfo:Refresh(info)
    local id = info.Id
    local count = info.ItemCount
    local itemId = info.ItemId
    local isLuckyBoy = info.IsLuckyBoy

    local headIcon, headEffect, name = "", "", ""
    if id == self.Parent.LeaderTemplateId then
        name = XPlayer.Name
        local playerHeadinfo = XPlayerManager.GetHeadPortraitInfoById(XPlayer.CurrHeadPortraitId)
        if playerHeadinfo then
            headIcon = playerHeadinfo.ImgSrc
            headEffect = playerHeadinfo.Effect
        end
    else
        local config = XRedEnvelopeConfigs.GetNpcConfig(id)
        headIcon = config.NpcHead
        name = config.NpcName
    end

    self.TxtName.text = name
    self.TxtNum.text = count
    self.PanelLucky.gameObject:SetActiveEx(isLuckyBoy)
    self.RImgIcon:SetRawImage(XDataCenter.ItemManager.GetItemIcon(itemId))
    self.RImgHead:SetRawImage(headIcon)

    if not XTool.UObjIsNil(self.PanelHeadEffect) then
        if headEffect then
            self.PanelHeadEffect.gameObject:LoadPrefab(headEffect)
            self.PanelHeadEffect.gameObject:SetActiveEx(true)
        else
            self.PanelHeadEffect.gameObject:SetActiveEx(false)
        end
    end
end

return XUiGridRedEnvelopeInfo
