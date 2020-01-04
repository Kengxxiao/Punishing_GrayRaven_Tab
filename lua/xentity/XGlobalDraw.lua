XGlobalDraw = XClass()

local Default = {
    Id = 0,
    IsActivity = false,
    DrawName = "",
    DrawType = 0,
    DrawId = 0,
    ActivityTime = {},
    Desc = "",
    UseItemId = 0,
    UseItemCount = 0,
    LimitCountParam = {},
    PrimaryStorage = {},
    ExtraStorage = {},
    BtnCount = {},
    Banner = "",
    ProbabilityId = {},
    RuleId = {},
    TicketId = 0,
    TicketCount = 0,
    Discount = {},
    DiscountTime = {},
    ContentItems = {},
}

function XGlobalDraw:Ctor(data)
    for key in pairs(Default) do
        self[key] = Default[key]
    end
    self:Update(data)
end

function XGlobalDraw:Update(data)
    self.Id = data.DrawTrunkId and data.DrawTrunkId or 0
    self.IsActivity = not data.IsDefault
    self.DrawName = data.DrawName
    self.DrawType = data.DrawType and data.DrawType or 0
    self.DrawId = data.DrawId and data.DrawId or 0
    self.ActivityTime = {}
    self.ActivityTime.StartTime = data.Time.StartTime
    self.ActivityTime.EndTime = data.Time.EndTime
    self.Desc = data.Desc
    self.UseItemId = data.UseItemId and data.UseItemId or 0
    self.UseItemCount = data.UseItemCount and data.UseItemCount or 0
    
    self.LimitCountParam = {}
    XTool.LoopCollection(data.LimintCountParam, function(param)
        table.insert(self.LimitCountParam, param)
    end)
    
    self.PrimaryStorage = {}
    XTool.LoopMap(data.PrimaryIdsMap, function(key, value)
        self.PrimaryStorage[key] = value
    end)
    self.ExtraStorage = {}
    XTool.LoopMap(data.ExtraIdsMap, function(key, value)
        self.ExtraStorage[key] = value
    end)

    self.BtnCount = {}
    XTool.LoopCollection(data.BtnCount, function(count)
        table.insert(self.BtnCount, count)
    end)

    self.Banner = {}
    local bans = string.Split(data.Banner, "|")
    for i, ban in ipairs(bans) do
        table.insert(self.Banner, ban)
    end

    self.ProbabilityId = string.Split(data.ProbabilityId, "|")
    self.RuleId = string.Split(data.RuleId, "|")
    self.TicketId = data.TicketId and data.TicketId or 0
    self.TicketCount = data.TicketCount and data.TicketCount or 0

    self.Discount = {}
    XTool.LoopCollection(data.Discount, function(count)
        table.insert(self.Discount, count)
    end)
    
    self.DiscountTime = {}
    if (data.DiscountTime) then
        self.DiscountTime.StartTime = data.DiscountTime.StartTime
        self.DiscountTime.EndTime = data.DiscountTime.EndTime
    else
        self.DiscountTime.StartTime = 0
        self.DiscountTime.EndTime = 0
    end

    local upNewInfos = string.Split(data.ContentItems, "|")
    self.ContentItems = {}
    for i, upNewInfo in ipairs(upNewInfos) do
        local infos = string.Split(upNewInfo, "_")
        if (#infos >= 3) then
            local info = {}
            info.itemId = tonumber(infos[1])
            info.up = tonumber(infos[2])
            info.new = tonumber(infos[3])
            table.insert(self.ContentItems, info)
        end
    end
end

