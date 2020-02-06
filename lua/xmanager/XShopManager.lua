local pairs = pairs
local table = table
local tableInsert = table.insert
local tableSort = table.sort

XShopManager = XShopManager or {}

local SYNC_SHOP_SECOND = 5
local SYNC_BASE_INFO_SECOND = 5

local ShopBaseInfosTemplates = {}            -- Tap显示信息(普通+活动)
local LastSyncShopTimes = {}               -- 商店刷新时间
local LastSyncBaseInfoTime = 0             -- 商店基础信息同步时间

local ShopBaseInfoDict = {}             -- 商店基础信息
local ShopDict = {}                     -- 商店详细信息
local ShopGroup = {}

local METHOD_NAME = {
    GetShopInfo = "GetShopInfoRequest",
    RefreshShop = "RefreshShopRequest",
    GetShopBaseInfo = "GetShopBaseInfoRequest",
    Buy = "BuyRequest",
}

XShopManager.ShopType = {
    Common = 1,                  -- 普通商店
    Activity = 2,                -- 活动商店
    Dorm = 101,
    Boss = 102,
    Arena = 103,
    
}

XShopManager.ShopTags = {
    Not = 0,                    --无
    HotSale = 1,                --热销
    Recommend = 2,              --推荐
    TimeLimit = 3,              --限时
    DisCount = 4,               --打折    
}

XShopManager.GoodsResetType = {
    Not = 0,                    --不刷新
    Hours = 1,                  --每(几)小时
    Day = 2,                    --每日
    Week = 3,                   --每周
    Month = 4,                  --每月
}

XShopManager.SecondTagType = {
    Top = 0,                    --顶部
    Mid = 1,                  --中间
    Btm = 2,                    --底部
    All = 3,                   --唯一
}

function XShopManager.ClearBaseInfoData()
    ShopBaseInfoDict = {}
end

function XShopManager.GetShopBaseInfoByType(type)
    local list = {}
    for _, info in pairs(ShopBaseInfoDict) do
        if info.Type == type then
            tableInsert(list, info)
        end
    end
    
    tableSort(list, function(a, b)
        if a.SecondType == b.SecondType then
            return a.Priority > b.Priority
        else
            return a.SecondType < b.SecondType
        end
    end)
    
    return list
end

function XShopManager.GetShopBaseInfoByTypeAndTag(type)
    local tmp = {}
    local list = {}
    local tagList = {}
    local shopGroup = XShopManager.GetShopGroup()
    
    for _, info in pairs(ShopBaseInfoDict) do
        if info.Type == type then
            tableInsert(tmp, info)
        end
    end
    
    tableSort(tmp, function(a, b)
        if a.SecondType == b.SecondType then
            return a.Priority > b.Priority
        else
            return a.SecondType < b.SecondType
        end
    end)
    
    for k, v in pairs(tmp) do
        local tagData = {}
        if v.SecondType > 0 then
            if shopGroup[v.SecondType] then
                if not tagList[v.SecondType] then
                    for i, d in pairs(v) do
                        tagData[i] = d
                    end
                    tagData.Id = 0
                    tagData.SecondType = 0
                    tagData.Name = shopGroup[v.SecondType].TagName
                    tagData.IsHasSnd = true
                    tableInsert(list, tagData)
                    tagList[v.SecondType] = v.SecondType
                end
            else
                v.SecondType = 0
                v.IsHasSnd = false
            end
        else
            v.IsHasSnd = false
        end
        tableInsert(list, v)
    end
    
    for k, v in pairs(list) do
        if v.SecondType > 0 then
            if list[k - 1].SecondType == 0 then
                v.SecondTagType = XShopManager.SecondTagType.Top
            else
                v.SecondTagType = XShopManager.SecondTagType.Mid
            end
            
            if list[k + 1] then
                if list[k + 1].SecondType == 0 then
                    if v.SecondTagType == XShopManager.SecondTagType.Mid then
                        v.SecondTagType = XShopManager.SecondTagType.Btm
                    else
                        v.SecondTagType = XShopManager.SecondTagType.All
                    end
                end
            else
               if v.SecondTagType == XShopManager.SecondTagType.Mid then
                    v.SecondTagType = XShopManager.SecondTagType.Btm
               else
                    v.SecondTagType = XShopManager.SecondTagType.All
               end
            end
        end
    end
    
    
    return list
end

function XShopManager.GetShopType(shopId)
    local info = ShopBaseInfoDict[shopId]
    if not info then
        XLog.Error("XShopManager.GetShopType error: can not found info, id is " .. shopId)
        return
    end
    
    return info.Type
end

function XShopManager.GetShopShowIdList(shopId)
    local info = ShopDict[shopId]
    if not info then
        XLog.Error("XShopManager.GetShopShowIdList error: can not found info, id is " .. shopId)
        return	
    end

    local list = {}
    if info.ShowIds and #info.ShowIds > 0 then
        list = info.ShowIds
    end
    
    return list
end

function XShopManager.GetManualRefreshCost(shopId)
    local shop = ShopDict[shopId]
    if not shop then
        XLog.Error("XShopManager.GetManualRefreshCost error: can not found shop, id is " .. shopId)
        return
    end
    
    local costInfo = {}
    if shop.RefreshCostId and shop.RefreshCostId > 0 then
        costInfo.RefreshCostId = shop.RefreshCostId
        costInfo.RefreshCostCount = shop.RefreshCostCount
    end
    
    if shop.ManualResetTimesLimit and shop.ManualResetTimesLimit ~= 0 then
        costInfo.ManualRefreshTimes = shop.ManualRefreshTimes
        costInfo.ManualResetTimesLimit = shop.ManualResetTimesLimit
    end
    
    return costInfo
end

function XShopManager.GetShopBuyInfo(shopId)
    local shop = ShopDict[shopId]
    if not shop then
        XLog.Error("XShopManager.GetShopBuyInfo error: can not found shop, id is " .. shopId)
        return
    end
    
    return {
        TotalBuyTimes = shop.TotalBuyTimes,
        BuyTimesLimit = shop.BuyTimesLimit
    }
end

function XShopManager.GetShopLeftBuyTimes(shopId)
    local shop = ShopDict[shopId]
    if not shop then
        XLog.Error("XShopManager.GetShopBuyInfo error: can not found shop, id is " .. shopId)
        return
    end
    
    local buyTimesLimit = shop.BuyTimesLimit
    if not buyTimesLimit or buyTimesLimit <= 0 then
        return
    end
    
    local totalBuyTimes = shop.TotalBuyTimes and shop.TotalBuyTimes or 0
    
    return buyTimesLimit - totalBuyTimes
end

function XShopManager.GetShopTimeInfo(shopId)
    local shop = ShopDict[shopId]
    if not shop then
        XLog.Error("XShopManager.GetShopTimeInfo error: can not found shop, id is " .. shopId)
        return
    end
    
    local info = {}
    local now = XTime.GetServerNowTimestamp()
    
    if shop.RefreshTime and shop.RefreshTime > 0 then
        info.RefreshLeftTime = shop.RefreshTime > now and shop.RefreshTime - now or 0
    end
    
    if shop.ClosedTime and shop.ClosedTime > 0 then
        info.ClosedLeftTime = shop.ClosedTime > now and shop.ClosedTime - now or 0
    end
    
    return info
end

function XShopManager.GetLeftTime(endTime)
    return endTime > 0 and endTime - XTime.GetServerNowTimestamp() or endTime
end

function XShopManager.IsShopExist(shopId)
    return ShopBaseInfoDict[shopId] ~= nil
end

function XShopManager.GetShopGoodsList(shopId)
    local shop = ShopDict[shopId]
    if not shop then
        XLog.Error("XShopManager.GetShopGoodsList error: can not found shop, id is " .. shopId)
        return
    end
    
    local list = {}
    for _, goods in pairs(shop.GoodsList) do
        local IsLock = false
        for k, v in pairs(goods.ConditionIds) do
            local ret, desc = XConditionManager.CheckCondition(v)
            if not ret then
                IsLock = true
                break
            end
        end
        
        if not(IsLock and goods.IsHideWhenConditionLimit) then
            tableInsert(list, goods)
        end
    end
    
    --排序优先级
    tableSort(list, function(a, b)
        -- 是否卖光
        if a.BuyTimesLimit > 0 or b.BuyTimesLimit > 0 then
            -- 如果商品有次数限制，并且达到次数限制，则判断为售罄
            local isSellOutA = a.BuyTimesLimit == a.TotalBuyTimes and a.BuyTimesLimit > 0
            local isSellOutB = b.BuyTimesLimit == b.TotalBuyTimes and b.BuyTimesLimit > 0
            if isSellOutA ~= isSellOutB then
                return isSellOutB
            end
        end
            
        --是否条件受限
        local IsLockA = false
        local IsLockB = false
        for k, v in pairs(a.ConditionIds) do
            local ret, desc = XConditionManager.CheckCondition(v)
            if not ret then
                IsLockA = true
                break
            end
        end
        for k, v in pairs(b.ConditionIds) do
            local ret, desc = XConditionManager.CheckCondition(v)
            if not ret then
                IsLockB = true
                break
            end
        end
        if IsLockA ~= IsLockB then
            return IsLockB
        end	
            
        -- 是否限时
        if a.SelloutTime ~= b.SelloutTime then
            if a.SelloutTime > 0 and b.SelloutTime > 0 then
                return a.SelloutTime < b.SelloutTime
            elseif a.SelloutTime > 0 and b.SelloutTime <= 0 then
                return XShopManager.GetLeftTime(a.SelloutTime) > 0
            elseif a.SelloutTime <= 0 and b.SelloutTime > 0 then
                return XShopManager.GetLeftTime(b.SelloutTime) < 0
            end
        end
       
        if a.Tags ~= b.Tags and a.Tags ~= 0 and b.Tags ~= 0 then
            return a.Tags < b.Tags
        end
        
        if a.Priority ~= b.Priority then
            return a.Priority > b.Priority
        end
    end)
    return list
end

function XShopManager.GetDefaultShopId()
    local list = XShopManager.GetShopBaseInfoByTypeAndTag(XShopManager.ShopType.Common)
    return list[1].Id
end

local function AddBuyTimes(shopId, goodsId, count)
    local shop = ShopDict[shopId]
    if not shop then
        XLog.Error("XShopManager AddBuyTimes Error: can not found shop, shopId is " .. shopId)
        return
    end
    
    shop.TotalBuyTimes = shop.TotalBuyTimes + count
    
    for _, goods in pairs(shop.GoodsList) do
        if goods.Id == goodsId then
            goods.TotalBuyTimes = goods.TotalBuyTimes + count
            break
        end
    end
end

local function SetShop(shop)
    ShopDict[shop.Id] = shop
    LastSyncShopTimes[shop.Id] = XTime.GetServerNowTimestamp()
end

local function SetShopBaseInfoList(shopBaseInfoList)
    LastSyncBaseInfoTime = XTime.GetServerNowTimestamp()
    for _, info in pairs(shopBaseInfoList) do
        ShopBaseInfoDict[info.Id] = info
    end
end

function XShopManager.GetShopInfo(shopId, cb, pleaseDoNotTip)
    local now = XTime.GetServerNowTimestamp()
    local syscTime = LastSyncShopTimes[shopId]
    
    if syscTime and now - syscTime < SYNC_SHOP_SECOND then
        if cb then
            cb()
            return
        end
    end
    
    XNetwork.Call(METHOD_NAME.GetShopInfo, {Id = shopId}, function(res)
        if res.Code ~= XCode.Success then
            if not pleaseDoNotTip then
                XUiManager.TipCode(res.Code)
            end
            return
        end
        SetShop(res.ClientShop)
        if cb then cb() end
    end)
end

local function CheckResfreshShopLimit(shopId)
    local shop = ShopDict[shopId]
    if not shop then
        XUiManager.TipCode(XCode.ShopManagerShopNotExist)
        return false
    end
    
    if shop.BuyTimesLimit and shop.BuyTimesLimit > 0 then
        if shop.TotalBuyTimes >= shop.BuyTimesLimit then
            XUiManager.TipCode(XCode.ShopManagerShopNotBuyTimes)
            return false
        end
    end
    
    if shop.ManualResetTimesLimit and shop.ManualResetTimesLimit >= 0 then
        if shop.ManualRefreshTimes >= shop.ManualResetTimesLimit then
            XUiManager.TipError(CS.XTextManager.GetText("DifferentRefreshTimes"))
            return false
        end
    end
    
    if shop.RefreshCostId and shop.RefreshCostId > 0 then
        if shop.RefreshCostCount > XDataCenter.ItemManager.GetItem(shop.RefreshCostId):GetCount() then
            XUiManager.TipError(CS.XTextManager.GetText("RefreshShopItemNotEnough"))
            return false
        end
    end
    return true
end

function XShopManager.RefreshShopGoods(shopId, cb)
    if not CheckResfreshShopLimit(shopId) then
        return
    end
    
    XNetwork.Call(METHOD_NAME.RefreshShop, {Id = shopId}, function(res)
        if res.Code ~= XCode.Success then
            XUiManager.TipCode(res.Code)
            return
        end
        SetShop(res.ClientShop)
        if cb then cb() end
    end)
end

function XShopManager.GetBaseInfo(cb)
    XNetwork.Call(METHOD_NAME.GetShopBaseInfo, nil, function(res)
        SetShopBaseInfoList(res.ShopBaseInfoList)
        if cb then cb() end
    end)
end

function XShopManager.BuyShop(shopId, goodsId, count, cb)
    local req = {ShopId = shopId, GoodsId = goodsId, Count = count}
    XNetwork.Call(METHOD_NAME.Buy, req, function(res)
        if res.Code ~= XCode.Success then
            XUiManager.TipCode(res.Code)
            return
        end
        AddBuyTimes(shopId, goodsId, count)
        cb()
    end)
end

function XShopManager.GetShopGroup()
    ShopGroup = XShopConfigs.GetShopGroupTemplate()
    return ShopGroup
end

function XShopManager.GetShopTypeDatas()
    local typeData = XShopConfigs.GetShopTypeNameTemplate()
    return typeData
end

function XShopManager.GetShopTypeDataById(id)
    local typeData = XShopConfigs.GetShopTypeNameTemplate()
    return typeData[id]
end
