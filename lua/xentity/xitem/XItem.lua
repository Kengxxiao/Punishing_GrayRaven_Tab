XItem = XClass()

local Default = {
    Id = 0,
    Count = 0,
    BuyTimes = 0,
    RefreshTime = 0,
    CreateTime = 0,
}

function XItem:Ctor(itemData, template)
    for key in pairs(Default) do
        self[key] = Default[key]
    end

    if template then
        self.Template = template
        self.Id = template.Id
    end

    self:RefreshItem(itemData)
end

function XItem:RefreshItem(itemData)
    if not itemData then
        return 
    end

    if itemData.Count then
        self:SetCount(itemData.Count)
    end

    if itemData.BuyTimes then
        self:SetBuyTimes(itemData.BuyTimes)
    end
    
    if itemData.RefreshTime then
        self.RefreshTime = itemData.RefreshTime
    end

    if itemData.CreateTime then
        self.CreateTime = itemData.CreateTime
    end
end

function XItem:SetCount(count)
    if self.Count == count then
        return 
    end
    
    self.Count = count

    XEventManager.DispatchEvent(XEventId.EVENT_ITEM_COUNT_UPDATE_PREFIX .. self.Id, self.Id, self.Count)
end

function XItem:SetBuyTimes(buyTimes)
    if buyTimes == self.BuyTimes then
        return
    end

    self.BuyTimes = buyTimes

    XEventManager.DispatchEvent(XEventId.EVENT_ITEM_BUYTIEMS_UPDATE_PREFIX .. self.Id, self.Id, self.BuyTimes)
end

function XItem:GetCount()
    return self.Count
end

function XItem:GetMaxCount()
    return self.Template.MaxCount
end