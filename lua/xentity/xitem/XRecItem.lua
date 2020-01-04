XRecItem = XClass(XItem)

local max = math.max
local min = math.min
local abs = math.abs

function XRecItem:Ctor(itemData, template)
    if template then
        self.Template = template
        self.Id = template.Id
    end

    self.NextRefreshTime = 0
    self:RefreshItem(itemData)
end

function XRecItem:GetRecMaxCount()
    if self.Id == XDataCenter.ItemManager.ItemId.ActionPoint then
        return XPlayerManager.GetMaxActionPoint(XPlayer.Level)
    else
        return self.Template.MaxCount
    end
end

function XRecItem:GetMaxCount()
    return self:GetRecMaxCount()
end

function XRecItem:RefreshCount()
    local now = XTime.Now()
    local second = now - self.RefreshTime
    if second < 0 then
        return
    end

    local recSecond = self.Template.RecSeconds[1]
    local recCount = self.Template.RecCount
    local addCount = XMath.ToMinInt(second / recSecond * recCount)
    local maxCount = max(self.Count, self:GetRecMaxCount())

    if addCount == 0 then
        return
    end

    local count = self.Count + addCount
    if count >= maxCount then
        count = maxCount
        self.RefreshTime = now
    elseif count <= 0 then
        count = 0
        self.RefreshTime = now
    else
        self.RefreshTime = self.RefreshTime + abs(addCount) * recSecond
    end

    self:SetCount(max(min(count, maxCount), 0))
end

function XRecItem:CheckRefreshTime()
    self.NextRefreshTime = XResetManager.GetNextResetTime(self.Template.RecType, self.RefreshTime, self.Template.RecSeconds, self.Template.RecDays)
end

function XRecItem:ResetCount()
    self.RefreshTime = XTime.Now()
    self:SetCount(max(min(self.Template.RecCount + self.Count, self.Template.MaxCount), 0))
    self:CheckRefreshTime()
end

function XRecItem:CheckCount()
    if self.Template.RecType == XResetManager.ResetType.Interval then
        self:RefreshCount()
    else
        if self.NextRefreshTime > 0 then
            if XTime.Now() >= self.NextRefreshTime then
                self:ResetCount()
            end

            return
        end

        self:CheckRefreshTime()

        local isReset, _ = CS.XReset.IsTime2Reset(self.Template.RecType, self.RefreshTime, self.Template.RecSeconds, self.Template.RecDays)
        if isReset then
            self:ResetCount()
        end
    end
end

function XRecItem:GetCount()
    self:CheckCount()
    return self.Count
end

function XRecItem:GetRefreshResidueSecond()
    if self.Count >= self:GetRecMaxCount() then
        return 0
    end

    local second = XTime.Now() - self.RefreshTime
    if second < 0 then
        return 0
    end

    return self.Template.RecSeconds[1] - second
end