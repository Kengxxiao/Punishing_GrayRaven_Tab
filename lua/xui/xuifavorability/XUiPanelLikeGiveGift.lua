XUiPanelLikeGiveGift = XClass()

local Default_Min_Num = 1

function XUiPanelLikeGiveGift:Ctor(ui, uiRoot)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.UiRoot = uiRoot
    XTool.InitUiObject(self)
    self:InitUiAfterAuto()
end

function XUiPanelLikeGiveGift:InitUiAfterAuto()
    
    self:InitBtnLongClicks()

    self.BtnIncrease.CallBack = function() self:OnBtnIncreaseClick() end
    self.BtnDecrease.CallBack = function() self:OnBtnDecreaseClick() end
    self.BtnMax.CallBack = function() self:OnBtnMaxClick() end
    self.BtnUse.CallBack = function() self:OnBtnUseClick() end
    self.BtnGo.CallBack = function() self:OnBtnGoClick() end

end

function XUiPanelLikeGiveGift:InitBtnLongClicks()
    XUiButtonLongClick.New(self.BtnLongIncrease, 200, self, nil, self.OnIncreaseLongCB, nil, false)
    XUiButtonLongClick.New(self.BtnLongDecrease, 200, self, nil, self.OnDecreaseLongCB, nil, false)
end

function XUiPanelLikeGiveGift:OnIncreaseLongCB()
    self:OnCountIncrease()
end

function XUiPanelLikeGiveGift:OnDecreaseLongCB()
    self:OnCountDecrease()
end

function XUiPanelLikeGiveGift:OnRefresh()
    self:RefreshDatas()
end

function XUiPanelLikeGiveGift:RefreshDatas()
    self.CurTrustItem = nil
    local trustItems = self:FilterTrustItems(XFavorabilityConfigs.GetAllCharacterSendGift())
    table.sort(trustItems, XDataCenter.FavorabilityManager.SortTrustItems)
    self:UpdateTrustItemList(trustItems)
    self:UpdateBottomByClickItem()
    self:UpdateTextCount(0)
end

function XUiPanelLikeGiveGift:FilterTrustItems(items)
    local characterId = self.UiRoot:GetCurrFavorabilityCharacter()
    local trustItems = {}
    for k, v in pairs(items) do
        local count = XDataCenter.ItemManager.GetCount(v.Id)
        if count > 0 then
            v.IsFavourWeight = self:IsContains(v.FavorCharacterId, characterId) and 1 or 0
            v.TrustItemQuality = XDataCenter.ItemManager.GetItemQuality(v.Id)
            table.insert(trustItems, v)
        end
    end
    return trustItems
end

function XUiPanelLikeGiveGift:ResetSelectStatus()
    for k, v in pairs(self.TrustItemList or {}) do
        v.IsSelect = false
    end
end

-- [刷先礼物ListView]
function XUiPanelLikeGiveGift:UpdateTrustItemList(trustItemList)
    if not trustItemList then
        XLog.Warning("XUiPanelLikeGiveGift:UpdateTrustItemList error: trustItemList is nil")
    end

    self.TrustItemList = trustItemList
    self:ResetSelectStatus()

    if not self.DynamicTableTrustItem then
        self.DynamicTableTrustItem = XDynamicTableNormal.New(self.SViewGiftList.gameObject)
        self.DynamicTableTrustItem:SetProxy(XUiGridLikeSendGiftItem)
        self.DynamicTableTrustItem:SetDelegate(self)
    end

    local isZero = self:IsZeroGift(self.TrustItemList)
    self.SViewGiftList.gameObject:SetActive(not isZero)
    self.PanelEmpty.gameObject:SetActive(isZero)
    if not isZero then
        self.DynamicTableTrustItem:SetDataSource(self.TrustItemList)
        self.DynamicTableTrustItem:ReloadDataASync()
    end
end

function XUiPanelLikeGiveGift:IsZeroGift(itemList)
    for k, itemData in pairs(itemList or {}) do
        local itemNum = XDataCenter.ItemManager.GetCount(itemData.Id)
        if itemNum > 0 then
            return false
        end
    end
    return true
end

-- [监听动态列表事件]
function XUiPanelLikeGiveGift:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:Init(self.UiRoot)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local data = self.TrustItemList[index]
        if not data then return end
        grid:OnRefresh(self.TrustItemList[index], index)

    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then
        if self:ChekMaxFavorability() then return end

        self.CurTrustItem = self.TrustItemList[index]

        if not self.CurTrustItem then return end
        self:UpdateSelectStatus(index)
        
        self:OnItemClick(self.CurTrustItem, index)
    end
end

function XUiPanelLikeGiveGift:UpdateSelectStatus(index)
    for i=1, #self.TrustItemList do
        local item = self.TrustItemList[i]
        if i == index then
            item.IsSelect = not item.IsSelect
        else
            item.IsSelect = false
        end
        local grid = self.DynamicTableTrustItem:GetGridByIndex(i)
        if grid then
            grid:OnRefresh(item, i)  
        end
    end
end

function XUiPanelLikeGiveGift:OnItemClick(trustItem, index)
    self:UpdateBottomByClickItem()
end

function XUiPanelLikeGiveGift:UpdateBottomByClickItem()
    if not self.CurTrustItem then 
        self:HideNumBtns()
        self:UpdateTextCount(0)
        return 
    end
    local playerCount = XDataCenter.ItemManager.GetCount(self.CurTrustItem.Id)
    if playerCount < Default_Min_Num or (not self.CurTrustItem.IsSelect) then
        self:HideNumBtns()
        self:UpdateTextCount(0)
    else
        self:ShowNumBtns()
        self:UpdateTextCount(Default_Min_Num)
    end
end

function XUiPanelLikeGiveGift:UpdateTextCount(count)
    self.CurrentCount = count
    self.TxtNum.text = self.CurrentCount
    CsXGameEventManager.Instance:Notify(XEventId.EVENT_FAVORABILITY_ON_GIFT_CHANGED, self.CurTrustItem, self.CurrentCount)
end

function XUiPanelLikeGiveGift:OnBtnUseClick(eventData)
    if self:ChekMaxFavorability() then return end

    if not self.CurTrustItem then
        XUiManager.TipMsg(CS.XTextManager.GetText("FavorabilityChooseAGift"))
        return 
    end

    if self.CurrentCount <= 0 then
        return 
    end
    local characterId = self.UiRoot:GetCurrFavorabilityCharacter()
    local characterName = XCharacterConfigs.GetCharacterName(characterId)
    local trustLv = XDataCenter.FavorabilityManager.GetCurrCharacterFavorabilityLevel(characterId)
    local curExp = tonumber(XDataCenter.FavorabilityManager.GetCurrCharacterExp(characterId))
    local isFavor = self:IsContains(self.CurTrustItem.FavorCharacterId, characterId)
    local favorExp = isFavor and self.CurTrustItem.FavorExp or self.CurTrustItem.Exp
    local args = {}
    args.CharacterId = characterId
    args.CharacterName = characterName
    args.ItemId = self.CurTrustItem.Id
    args.ItemNum = self.CurrentCount
    args.Exp = favorExp
    XDataCenter.FavorabilityManager.OnSendCharacterGift(args, function()
        self.UiRoot:UpdateExpFillAmount(trustLv, curExp, args.ItemNum * args.Exp)
        self:RefreshDatas()
    end)

end

function XUiPanelLikeGiveGift:OnBtnGoClick()
    XLuaUiManager.Open("UiEquipStrengthenSkip", XDataCenter.FavorabilityManager.GetFavorabilitySkipIds())
end

function XUiPanelLikeGiveGift:IsContains(container, item)
    for k, v in pairs(container or {}) do
        if v == item then
            return true
        end
    end
    return false
end

function XUiPanelLikeGiveGift:OnBtnIncreaseClick(eventData)
    self:OnCountIncrease()
end

function XUiPanelLikeGiveGift:OnCountIncrease()
    if not self.CurTrustItem then
        XUiManager.TipMsg(CS.XTextManager.GetText("FavorabilityChooseAGift"))
        return 
    end

    local playerCount = XDataCenter.ItemManager.GetCount(self.CurTrustItem.Id)
    if self.CurrentCount >= playerCount then
        return 
    end

    local count = self:GetMaxCountByItem(self.CurTrustItem)
    if self.CurrentCount >= count then
        XUiManager.TipMsg(CS.XTextManager.GetText("FavorabilityMaxGiftNum"))
        return 
    end

    self:UpdateTextCount(self.CurrentCount + 1)
end

function XUiPanelLikeGiveGift:OnBtnDecreaseClick(eventData)
    self:OnCountDecrease()
end

function XUiPanelLikeGiveGift:OnCountDecrease()
    if not self.CurTrustItem then
        XUiManager.TipMsg(CS.XTextManager.GetText("FavorabilityChooseAGift"))
        return 
    end
    if self.CurrentCount <= Default_Min_Num then
        return 
    end
    
    self:UpdateTextCount(self.CurrentCount - 1)
end

function XUiPanelLikeGiveGift:GetMaxCountByItem(trustItem)
    local characterId = self.UiRoot:GetCurrFavorabilityCharacter()
    local isFavor = self:IsContains(trustItem.FavorCharacterId, characterId)
    local favorExp = isFavor and trustItem.FavorExp or trustItem.Exp
    local curExp = tonumber(XDataCenter.FavorabilityManager.GetCurrCharacterExp(characterId))
    local trustLv = XDataCenter.FavorabilityManager.GetCurrCharacterFavorabilityLevel(characterId)
    local maxTrustLv = XFavorabilityConfigs.GetMaxFavorabilityLevel(characterId)
    local levelUpDatas = XFavorabilityConfigs.GetTrustExpById(characterId)

    if trustLv >= maxTrustLv then return 0 end
    local totalNeedExp = 0
    for i=trustLv, maxTrustLv-1 do
        if i == trustLv then
            totalNeedExp = totalNeedExp + levelUpDatas[i].Exp - curExp
        else
            totalNeedExp = totalNeedExp + levelUpDatas[i].Exp
        end
    end
    
    local count = math.modf(totalNeedExp / favorExp)
    count = (totalNeedExp % favorExp == 0) and count or count + 1
    return count
end

function XUiPanelLikeGiveGift:OnBtnMaxClick(eventData)
    if not self.CurTrustItem then
        XUiManager.TipMsg(CS.XTextManager.GetText("FavorabilityChooseAGift"))
        return 
    end

    local playerCount = XDataCenter.ItemManager.GetCount(self.CurTrustItem.Id)
    local count = self:GetMaxCountByItem(self.CurTrustItem)
    if self.CurrentCount >= count then
        XUiManager.TipMsg(CS.XTextManager.GetText("FavorabilityMaxGiftNum"))
        return 
    end
    playerCount = (playerCount > count) and count or playerCount
    
    self:UpdateTextCount(playerCount)
end

function XUiPanelLikeGiveGift:HideNumBtns()
    self.TxtNum.gameObject:SetActive(false)
    self.BtnIncrease.gameObject:SetActive(false)
    self.BtnDecrease.gameObject:SetActive(false)
    self.BtnMax.gameObject:SetActive(false)
    self.BtnUse.gameObject:SetActive(false)
end

function XUiPanelLikeGiveGift:ShowNumBtns()
    self.TxtNum.gameObject:SetActive(true)
    self.BtnIncrease.gameObject:SetActive(true)
    self.BtnDecrease.gameObject:SetActive(true)
    self.BtnMax.gameObject:SetActive(true)
    self.BtnUse.gameObject:SetActive(true)
end

function XUiPanelLikeGiveGift:SetViewActive(isActive)
    self.GameObject:SetActive(isActive)
    if isActive then
        self:RefreshDatas()
    end
end

function XUiPanelLikeGiveGift:ChekMaxFavorability()
    local characterId = self.UiRoot:GetCurrFavorabilityCharacter()
    local isMax = XDataCenter.FavorabilityManager.IsMaxFavorabilityLevel(characterId)
    if isMax then
        XUiManager.TipMsg(CS.XTextManager.GetText("FavorabilityMaxLevel"))
        return true
    end
    return false
end

return XUiPanelLikeGiveGift
