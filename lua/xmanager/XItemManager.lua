XItemManagerCreator = function()

    local XItemManager = {}

    local tableInsert = table.insert
    local tableRemove = table.remove
    local tableSort = table.sort

    local Items = {}                                -- 所有道具数据
    local RecItemIds = {}                           -- 恢复类道具
    local SuppliesItems = {}                        -- 补给类道具
    local BuyAssetTemplates = {}                    -- 购买资源配置表
    local BuyAssetDailyLimit = {}                   -- 购买资源每日限制
    local ItemTemplates = {}
    local ItemFirstGetCheckTable = {}
    local RedEnvelopeInfos = {}                      -- 红包道具使用记录

    local BuyAssetCoinBase    = 0
    local BuyAssetCoinMul    = 0
    local BuyAssetCoinCritProb = 0
    local BuyAssetCoinCritMul = 0

    -- item 参数下表
    local PARAM_ACTIONPOINT_INTERVAL = 1
    local PARAM_ACTIONPOINT_NUM = 2

    local RecTimer

    XItemManager.ItemId = {
        Coin = 1,
        FreeGem = 2,
        PaidGem = 3,
        ActionPoint = 4,
        TeamExp = 7,
        SkillPoint = 12,
        DailyActiveness = 13,
        WeeklyActiveness = 14,
        HostelElectric = 15,
        HostelMat = 16,
        OnlineBossTicket = 17,
        BountyTaskExp = 18,
        DormCoin = 30,
        FurnitureCoin = 31,
        BaseEquipCoin = 300,
        HongKa = 5,
        DormEnterIcon = 36,
        AndroidHongKa = 8,
        IosHongKa = 10,
    }

    --时效性道具初始时间计算方式
    XItemManager.TimelinessType = {
        Invalid = 0,
        FromConfig = 1, --通过配置
        AfterGet = 2, --获取后
        Batch = 3, --按时间分批次
    }

    --礼包类型
    XItemManager.GiftItemUseType = {
        Reward = 1,
        Drop = 2,
        OptionalReward = 3,
        RedEnvelope = 4,
    }

    --特殊补给道具
    XItemManager.SuppliesItemType = {
        Battery = 90000,
    }

    XItemManager.SubType_1 = {
        Reward = 1,
    }

    XItemManager.SUBTYPE_EXP = 2

    local METHOD_NAME = {
        Sell = "ItemSellRequest",
        Use = "ItemUseRequest",
        BuyAsset = "ItemBuyAssetRequest",
    }

    local DEFAULT_SORT_CMP = function(a, b)
        --溢出排序
        local aIsCanConvert = XItemManager.IsCanConvert(a.Id)
        local bIsCanConvert = XItemManager.IsCanConvert(b.Id)
        if aIsCanConvert ~= bIsCanConvert then
            return aIsCanConvert
        end

        --可使用排序
        local aIsUseable = XItemManager.IsUseable(a.Id)
        local bIsUseable = XItemManager.IsUseable(b.Id)
        if aIsUseable ~= bIsUseable then
            return aIsUseable
        end

        --时效性排序
        local aIsTimeLimit = XItemManager.IsTimeLimit(a.Id)
        local bIsTimeLimit = XItemManager.IsTimeLimit(b.Id)
        if aIsTimeLimit ~= bIsTimeLimit then
            return aIsTimeLimit
        end

        if a.Template.Quality ~= b.Template.Quality then
            return a.Template.Quality > b.Template.Quality
        end

        if a.Template.Priority ~= b.Template.Priority then
            return a.Template.Priority > b.Template.Priority
        end

        if a.Count ~= b.Count then
            return a.Count > b.Count
        end

        return false
    end

    function XItemManager.Init()
        ItemTemplates = XItemConfigs.GetItemTemplates()
        BuyAssetDailyLimit = XItemConfigs.GetBuyAssetDailyLimit()
        BuyAssetTemplates = XItemConfigs.GetBuyAssetTemplates()
        BuyAssetCoinBase    = CS.XGame.Config:GetInt("BuyAssetCoinBase")
        BuyAssetCoinMul    = CS.XGame.Config:GetInt("BuyAssetCoinMul")
        BuyAssetCoinCritProb = CS.XGame.Config:GetInt("BuyAssetCoinCritProb")
        BuyAssetCoinCritMul = CS.XGame.Config:GetInt("BuyAssetCoinCritMul")

        XEventManager.AddEventListener(XEventId.EVENT_USER_LOGOUT, function()
            if RecTimer then
                CS.XScheduleManager.UnSchedule(RecTimer)
            end
        end)

        XItemManager.InitAllItems()
    end

    function XItemManager.InitAllItems()
        Items = {}
        for id, template in pairs(ItemTemplates) do
            local item
            if template.RecType == XResetManager.ResetType.NoNeed then
                item = XItem.New(nil, template)
            else
                item = XRecItem.New(nil, template)
                tableInsert(RecItemIds, id)
            end
            if template.SubTypeParams[1] == XItemManager.SubType_1.Reward and template.SubTypeParams[3] == XItemManager.SuppliesItemType.Battery then
                if not SuppliesItems[XItemManager.SuppliesItemType.Battery] then
                    SuppliesItems[XItemManager.SuppliesItemType.Battery] = {}
                end
                tableInsert(SuppliesItems[XItemManager.SuppliesItemType.Battery], item.Id)
            end
            Items[item.Id] = item
        end
    end

    function XItemManager.AddItemListener()
        RecTimer = CS.XScheduleManager.ScheduleForever(function()
            for _, id in pairs(RecItemIds) do
                Items[id]:CheckCount()
            end
        end, CS.XScheduleManager.SECOND, 0)
    end

    function XItemManager.InitItemData(items)
        for _, itemData in pairs(items) do
            if Items[itemData.Id] then
                Items[itemData.Id]:RefreshItem(itemData)
                ItemFirstGetCheckTable[itemData.Id] = true
            else
                XLog.Error("XItemManager.InitItemData error:id is not match,id = " .. itemData.Id)
            end
        end

        XItemManager.AddItemListener()
    end

    function XItemManager.InitItemRecycle(list)
        -- 回收道具时限表
        if not list then return end
        for id, itemRecycleList in pairs(list) do
            Items[id].ItemRecycleList = itemRecycleList
        end
    end

    function XItemManager.InitBatchItemRecycle(data)
        if not data or not next(data) then return end
        XItemManager.NotifyBatchItemRecycle(data)
    end

    -- 获取数据
    function XItemManager.GetItemTemplate(id)
        local tab = ItemTemplates[id]
        if tab == nil then
            XLog.Error("XItemManager.GetItemTemplate error: can not found table, id = " .. id)
        end
        return tab
    end

    function XItemManager.GetItemQuality(id)
        local tab = ItemTemplates[id]
        if tab == nil then
            XLog.Error("XItemManager.GetItemQuality error: can not found table, id = " .. id)
            return
        end
        return tab.Quality
    end

    function XItemManager.GetItemPriority(id)
        local tab = ItemTemplates[id]
        if tab == nil then
            XLog.Error("XItemManager.GetItemPriority error: can not found table, id = " .. id)
            return
        end
        return tab.Priority
    end

    function XItemManager.GetItemBigIcon(id)
        local tab = XItemManager.GetItemTemplate(id)
        if tab == nil then
            XLog.Error("XItemManager.GetItemBigIcon error: can not found table, id = " .. id)
            return
        end

        return tab.BigIcon
    end

    function XItemManager.GetItemIcon(id)
        local tab = XItemManager.GetItemTemplate(id)
        if tab == nil then
            XLog.Error("XItemManager.GetItemIcon error: can not found table, id = " .. id)
            return nil
        end

        return tab.Icon
    end

    function XItemManager.GetItemDescription(id)
        local tab = XItemManager.GetItemTemplate(id)
        if tab == nil then
            XLog.Error("XItemManager.GetItemDescription error: can not found table, id = " .. id)
            return
        end

        return tab.Description
    end

    function XItemManager.GetItemWorldDesc(id)
        local tab = XItemManager.GetItemTemplate(id)
        if tab == nil then
            XLog.Error("XItemManager.GetItemWorldDesc error: can not found table, id = " .. id)
            return
        end

        return tab.WorldDesc
    end

    function XItemManager.GetItemSkipIdParams(id)
        local tab = XItemManager.GetItemTemplate(id)
        if tab == nil then
            XLog.Error("XItemManager.GetItemSkipIdParams error: can not found table, id = " .. id)
            return
        end

        return tab.SkipIdParams
    end

    function XItemManager.GetBuyAssetTemplate(targetId, times, notTipError)
        local template = BuyAssetTemplates[targetId]

        if template == nil then
            local tipError = not notTipError and XLog.Error("XItemManager.GetBuyAssetTemplate error: can not found table, id = " .. targetId .. ", times = " .. times)
            return
        end

        local config = template[1]
        for i = 1, #template do
            if template[i].Times > times then
                return config
            end
            config = template[i]
        end

        return config
    end

    function XItemManager.GetRedEnvelopeCertainNpcItemCount(activityId, npcId, itemId)
        local count = 0

        local redEnvelope = RedEnvelopeInfos[activityId]
        if not redEnvelope then
            return count
        end

        local reward = redEnvelope[npcId]
        count = reward and reward[itemId] or count

        return count
    end

    function XItemManager.GetItem(id)
        if (id == XItemManager.ItemId.FreeGem or id == XItemManager.ItemId.PaidGem) then
            local freeGem = Items[XItemManager.ItemId.FreeGem]
            local paidGem = Items[XItemManager.ItemId.PaidGem]

            local mergeGem = XItem.New(nil, freeGem.Template)
            mergeGem.Count = mergeGem.Count + freeGem.Count + paidGem.Count

            return mergeGem
        else
            return Items[id]
        end
    end

    function XItemManager.GetCount(id)
        if (id == XItemManager.ItemId.FreeGem or id == XItemManager.ItemId.PaidGem) then
            return Items[XItemManager.ItemId.FreeGem]:GetCount() +
            Items[XItemManager.ItemId.PaidGem]:GetCount()
        end
        return Items[id] and Items[id]:GetCount() or 0
    end

    function XItemManager.GetMaxCount(id)
        return Items[id] and Items[id]:GetMaxCount() or 0
    end

    function XItemManager.GetItemsByTypes(types)
        local result = {}

        for i = 1, #types do
            local items = XItemManager.GetItemsByType(types[i])
            for i = 1, #items do
                tableInsert(result, items[i])
            end
        end

        tableSort(result, DEFAULT_SORT_CMP)

        return result
    end

    function XItemManager.GetItemsByType(itemType)
        local list = {}

        for _, item in pairs(Items) do
            if item.Template.ItemType == itemType and item:GetCount() > 0 then
                tableInsert(list, item)
            end
        end

        return list
    end

    function XItemManager.GetCardExpItems()
        local list = XItemManager.GetItemsByType(XItemConfigs.ItemType.CardExp)
        tableSort(list, function(a, b)
            return a.Template.Exp < b.Template.Exp
        end)
        return list
    end

    function XItemManager.GetCharExp(id, type)
        local template = XItemManager.GetItemTemplate(id)
        return template.GetExp(type)
    end

    function XItemManager.GetEquipExp(id, subType)
        local template = XItemManager.GetItemTemplate(id)
        local exp = template.GetExp(subType)
        local money = template.Cost
        return { Exp = exp, Money = money }
    end

    function XItemManager.GetTeamExp(id)
        local PARAM_EXP = 1
        local template = XItemManager.GetItemTemplate(id)
        return template.SubTypeParams[PARAM_EXP]
    end

    function XItemManager.GetBuyAssetInfo(targetId)
        if not targetId then
            return
            XLog.Error("XItemManager.GetBuyAssetInfo : targetId is nil")
        end

        -- 获取购买次数
        local times = 0
        if Items[targetId] then
            times = Items[targetId].BuyTimes or 0
        end

        -- 检查是否达到每日上限,读表
        local dayLimit = BuyAssetDailyLimit[targetId]
        local template = nil
        if dayLimit and dayLimit > 0 and times >= dayLimit then
            template = XItemManager.GetBuyAssetTemplate(targetId, dayLimit)
        else
            template = XItemManager.GetBuyAssetTemplate(targetId, times + 1)
        end


        local targetCount = template.GainCount

        -- 计算消耗量
        if targetId == XItemManager.ItemId.Coin then
            targetCount = (BuyAssetCoinBase + XPlayer.Level * BuyAssetCoinMul) * targetCount
        end

        -- 返回
        return {
            LeftTimes = dayLimit > 0 and dayLimit - times or nil,
            TargetId = targetId,
            TargetCount = targetCount,
            ConsumeId = template.ConsumeId,
            ConsumeCount = template.ConsumeCount,
        }
    end

    function XItemManager.GetCanSellItemsByTypes(types)
        local result = {}

        for i = 1, #types do
            local items = XItemManager.GetItemsByType(types[i])
            for i = 1, #items do
                if XItemManager.IsCanSell(items[i].Id) then
                    tableInsert(result, items[i])
                end
            end
        end

        tableSort(result, DEFAULT_SORT_CMP)

        return result
    end

    function XItemManager.GetCanConvertItemsByTypes(types)
        local result = {}

        for i = 1, #types do
            local items = XItemManager.GetItemsByType(types[i])
            for i = 1, #items do
                if XItemManager.IsCanConvert(items[i].Id) then
                    tableInsert(result, items[i])
                end
            end
        end

        tableSort(result, DEFAULT_SORT_CMP)

        return result
    end

    --获得出售道具获得的奖励信息
    function XItemManager.GetSellReward(id, count)
        local reward = {}

        if not id then return reward end
        count = count or 1

        local tab = XItemManager.GetItemTemplate(id)
        local templateId = tab.SellForId
        if templateId > 0 then
            reward.TemplateId = templateId
            reward.Count = tab.SellForCount * count
        end

        return reward
    end

    function XItemManager.GetSelectGiftRewardId(id)
        local template = XItemManager.GetItemTemplate(id)
        return template.RewardId
    end

    function XItemManager.GetItemName(id)
        local template = XItemManager.GetItemTemplate(id)
        if not template then
            return nil
        end
        return template.Name
    end

    function XItemManager.GetDailyActiveness()
        return XItemManager.GetItem(XItemManager.ItemId.DailyActiveness)
    end

    function XItemManager.GetWeeklyActiveness()
        return XItemManager.GetItem(XItemManager.ItemId.WeeklyActiveness)
    end

    function XItemManager.IsCanSell(id)
        if XItemManager.IsTimeLimitBatch(id) then return false end  --时效批次性道具不可出售
        local template = XItemManager.GetItemTemplate(id)
        return template.SellForId > 0 and template.SellForCount > 0
    end

    function XItemManager.IsUseable(id)
        local template = XItemManager.GetItemTemplate(id)
        return template.ItemType == XItemConfigs.ItemType.Gift
    end

    -- 是否溢出（碎片是否可转化）
    function XItemManager.IsCanConvert(id)
        local template = XItemManager.GetItemTemplate(id)
        if template.ItemType ~= XItemConfigs.ItemType.Fragment then
            return false
        end

        --角色已经满级
        local characterId = XCharacterConfigs.GetCharcterIdByFragmentItemId(id)
        local charcter = XDataCenter.CharacterManager.GetCharacter(characterId)
        return charcter and XDataCenter.CharacterManager.IsMaxQuality(charcter)
    end

    -- 背包材料
    function XItemManager.IsBagMaterial(id)
        local template = XItemManager.GetItemTemplate(id)
        local itemType = template.ItemType
        for _, materialType in pairs(XItemConfigs.Materials) do
            if itemType == materialType then return true end
        end
        return false
    end

    -- 时效性道具
    function XItemManager.IsTimeLimit(id)
        local template = XItemManager.GetItemTemplate(id)
        return template.TimelinessType > XItemManager.TimelinessType.Invalid
    end

    -- 时效分批次性道具
    function XItemManager.IsTimeLimitBatch(id)
        local template = XItemManager.GetItemTemplate(id)
        return template.TimelinessType == XItemManager.TimelinessType.Batch
    end

    -- 可选礼包
    function XItemManager.IsSelectGift(id)
        if not XItemManager.IsUseable(id) then return false end
        local template = XItemManager.GetItemTemplate(id)
        return template.GiftType == XItemManager.GiftItemUseType.OptionalReward
    end

    -- 红包
    function XItemManager.IsRedEnvelope(id)
        if not XItemManager.IsUseable(id) then return false end
        local template = XItemManager.GetItemTemplate(id)
        return template.GiftType == XItemManager.GiftItemUseType.RedEnvelope
    end

    -- 检查数据
    function XItemManager.CheckItemCount(item, count)
        return item and item:GetCount() >= count
    end

    function XItemManager.CheckItemCountById(id, count)
        local item = XItemManager.GetItem(id)
        return XItemManager.CheckItemCount(item, count)
    end

    function XItemManager.CheckItemsCount(items)
        for _, item in pairs(items) do
            if not XItemManager.CheckItemCountById(item.Id, item.Count) then
                return false
            end
        end
        return true
    end

    function XItemManager.CheckItemType(item, type)
        return item.Template.ItemType == type
    end

    -- 修改数据
    function XItemManager.CreateItem(itemData)
        local template = XItemManager.GetItemTemplate(itemData.Id)
        if template == nil then
            XLog.Error("XItemManager.CreateItem : template not exist, id = " .. itemData.Id)
        end

        local item
        if template.RecType == XResetManager.ResetType.NoNeed then
            item = XItem.New(itemData, template)
        else
            item = XRecItem.New(itemData, template)
        end

        Items[item.Id] = item
        return item
    end

    function XItemManager.SetItemCount(id, count, validTime)
        local item = Items[id]
        if not item then
            item = XItemManager.CreateItem(id, count, validTime, 0)
        end
        item:SetCount(count)
        return item
    end

    function XItemManager.SetItemCountDelta(id, delta, validTime)
        local item = Items[id]
        if item then
            XItemManager.SetItemCount(id, item.Count + delta, validTime)
        else
            XItemManager.SetItemCount(id, delta, validTime)
        end
    end

    -- 回收相关
    function XItemManager.GetRecycleLeftTime(id)
        local leftTime = 0

        local startTime
        local item = XItemManager.GetItem(id)
        if item.Template.TimelinessType == XItemManager.TimelinessType.FromConfig then
            startTime = CS.XDate.GetTime(item.Template.StartTime)
        elseif item.Template.TimelinessType == XItemManager.TimelinessType.AfterGet then
            startTime = item.CreateTime
        end

        if startTime then
            local endTime = startTime + item.Template.Duration
            leftTime = endTime - XTime.Now()
        end

        return leftTime
    end

    -- 此接口只检测回收类型 XItemManager.TimelinessType.FromConfig/XItemManager.TimelinessType.AfterGet
    -- XItemManager.TimelinessType.Batch类型回收时间列表需手动检查
    function XItemManager.IsTimeOver(id)
        if XItemManager.IsTimeLimit(id) then
            local leftTime = XItemManager.GetRecycleLeftTime(id)
            if leftTime and leftTime <= 0 then
                return true
            end
        end

        return false
    end

    -- 服务端交互
    function XItemManager.PackItemList(items)
        local rpcData = {}
        for id, count in pairs(items) do
            local data = {}
            data.Id = id
            data.Count = count
            tableInsert(rpcData, data)
        end

        return rpcData
    end

    function XItemManager.Use(id, recycleTime, count, callback, rewardIds)
        local req = { Id = id, RecycleTime = recycleTime, Count = count, SelectRewardIds = rewardIds }
        XNetwork.Call(METHOD_NAME.Use, req, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            if callback then
                callback(res.RewardGoodsList)
            end

            if XItemManager.IsTimeLimit(id) then
                XEventManager.DispatchEvent(XEventId.EVENT_TIMELIMIT_ITEM_USE, id)
            end
            CsXGameEventManager.Instance:Notify(XEventId.EVENT_ITEM_USE, id)
        end)
    end

    function XItemManager.Sell(datas, callback)
        XMessagePack.MarkAsTable(datas)
        local req = { SellItems = datas }
        XNetwork.Call(METHOD_NAME.Sell, req, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            else
                if callback then
                    callback(res.ObtainItems)
                end
            end
        end)
    end

    function XItemManager.BuyAsset(targetId, callback, failCallback, times)
        local req = { ItemId = targetId, Times = times }
        XNetwork.Call(METHOD_NAME.BuyAsset, req, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                if failCallback then
                    failCallback()
                end

                return
            end

            if res.IsCrit then
                -- XLog.Debug("XItemManager.BuyAsset Crit!")
            end

            if callback then
                callback(targetId, res.Count, res.IsCrit)
            end

            XEventManager.DispatchEvent(XEventId.EVENT_ITEM_BUYASSET, targetId)
        end)
    end

    -- 角色需要的基础属性
    function XItemManager.GetCoinsNum()
        return Items[XItemManager.ItemId.Coin]:GetCount()
    end

    function XItemManager.GetTotalGemsNum()
        return Items[XItemManager.ItemId.FreeGem]:GetCount() + Items[XItemManager.ItemId.PaidGem]:GetCount()
    end

    function XItemManager.GetActionPointsNum()
        return Items[XItemManager.ItemId.ActionPoint]:GetCount()
    end

    function XItemManager.GetMaxActionPoints()
        return XPlayerManager.GetMaxActionPoint(XPlayer.Level)
    end

    function XItemManager.GetActionPointsRefreshResidueSecond()
        return Items[XItemManager.ItemId.ActionPoint]:GetRefreshResidueSecond()
    end

    function XItemManager.GetSkillPointNum()
        return Items[XItemManager.ItemId.SkillPoint]:GetCount()
    end

    function XItemManager.GetBatterys()
        local tmp = {}
        for k, v in pairs(SuppliesItems[XItemManager.SuppliesItemType.Battery]) do
            if Items[v] then
                tableInsert(tmp, Items[v])
            end
        end
        return XItemManager.ConvertToGridData(tmp)
    end

    function XItemManager.GetCurBatterys()
        local CurBatterys = {}

        local nowTime = XTime.Now()
        for k, v in pairs(XItemManager.GetBatterys()) do
            local item = v.Data
            if item:GetCount() > 0 then
                local recycleBatch = v.RecycleBatch
                if recycleBatch then
                    if recycleBatch.RecycleTime > nowTime then
                        tableInsert(CurBatterys, v)
                    end
                elseif not XItemManager.IsTimeOver(item.Id) then
                    tableInsert(CurBatterys, v)
                end
            end
        end

        tableSort(CurBatterys, function(a, b)
            local aTemplate = a.Data.Template
            local bTemplate = b.Data.Template
            if aTemplate.TimelinessType == bTemplate.TimelinessType then
                return aTemplate.Priority > bTemplate.Priority
            else
                return aTemplate.TimelinessType and aTemplate.TimelinessType > bTemplate.TimelinessType
            end
        end)

        return CurBatterys
    end

    function XItemManager.GetBatteryMinLeftTime()
        local minLeftTime = 0

        local nowTime = XTime.Now()
        local batterys = XItemManager.GetBatterys()
        for _, v in pairs(batterys) do
            local itemId = v.Data.Id
            if XItemManager.IsTimeLimit(itemId) then
                local recycleBatch = v.RecycleBatch
                if recycleBatch then
                    if recycleBatch.RecycleCount > 0 then
                        local leftTime = recycleBatch.RecycleTime - nowTime
                        leftTime = leftTime > 0 and leftTime or 0
                        if minLeftTime == 0 or minLeftTime > leftTime then
                            minLeftTime = leftTime
                        end
                    end
                else
                    if v.Data:GetCount() > 0 and not XItemManager.IsTimeOver(itemId) then
                        local leftTime = XItemManager.GetRecycleLeftTime(itemId)
                        if leftTime then
                            if minLeftTime == 0 or minLeftTime > leftTime then
                                minLeftTime = leftTime
                            end
                        end
                    end
                end
            end
        end

        return minLeftTime
    end

    function XItemManager.GetTimeLimitItemsMinLeftTime()
        local minLeftTime = 0

        local nowTime = XTime.Now()
        for _, v in pairs(Items) do
            local itemId = v.Id
            if XItemManager.IsTimeLimit(itemId) and v:GetCount() > 0 and XItemManager.IsBagMaterial(itemId) then
                local itemRecycleList = v.ItemRecycleList
                if itemRecycleList then
                    for _, recycleBatch in pairs(itemRecycleList) do
                        if recycleBatch.RecycleCount > 0 then
                            local leftTime = recycleBatch.RecycleTime - nowTime
                            leftTime = leftTime > 0 and leftTime or 0
                            if minLeftTime == 0 or minLeftTime > leftTime then
                                minLeftTime = leftTime
                            end
                        end
                    end
                else
                    if not XItemManager.IsTimeOver(itemId) then
                        local leftTime = XItemManager.GetRecycleLeftTime(itemId)
                        if leftTime then
                            if minLeftTime == 0 or minLeftTime > leftTime then
                                minLeftTime = leftTime
                            end
                        end
                    end
                end
            end
        end

        return minLeftTime
    end

    function XItemManager.CheakBatteryIsHave()
        for k, v in pairs(XItemManager.GetBatterys()) do
            if v.Data:GetCount() > 0 then
                return true
            end
        end
        return false
    end

    function XItemManager.CheakBatteryIsHaveById(id)
        for k, v in pairs(XItemManager.GetBatterys()) do
            if v.Data:GetCount() > 0 and v.Data.Id == id then
                return true
            end
        end
        return false
    end

    function XItemManager.DoNotEnoughBuyAsset(useItemId, useItemCount, buyCount, callBack, errorTxt)
        local ownItemCount = XDataCenter.ItemManager.GetItem(useItemId).Count
        local lackItemCount = useItemCount * buyCount - ownItemCount
        if lackItemCount > 0 then
            local template = XDataCenter.ItemManager.GetBuyAssetTemplate(useItemId, 0, true)
            if template ~= nil then
                if BuyAssetTemplates[useItemId] and #BuyAssetTemplates[useItemId] > 1 then
                    XItemManager.SelectBuyAssetType(useItemId, callBack, nil, 1)
                else
                    lackItemCount = math.ceil(lackItemCount / template.GainCount)
                    XItemManager.SelectBuyAssetType(useItemId, callBack, nil, lackItemCount)
                end
            else
                XUiManager.TipError(CS.XTextManager.GetText(errorTxt))
            end
            return false
        end
        return true
    end

    function XItemManager.SelectBuyAssetType(useItemId, callBack, challegeCountData, buyAmount)
        if useItemId == XDataCenter.ItemManager.ItemId.ActionPoint and
        XDataCenter.ItemManager.CheakBatteryIsHave() then
            XLuaUiManager.OpenWithCallback("UiUsePackage", function()
                XLuaUiManager.Remove("UiActivityBase")
            end, useItemId, callBack, challegeCountData, buyAmount)
        else
            XLuaUiManager.OpenWithCallback("UiBuyAsset", function()
                XLuaUiManager.Remove("UiActivityBase")
            end, useItemId, callBack, challegeCountData, buyAmount)
        end
    end

    function XItemManager.NotifyItemDataList(data)
        local list = data.ItemDataList
        if not list then
            return
        end
        for _, data in pairs(list) do
            local id = data.Id

            if not Items[id] then
                Items[id] = XItemManager.CreateItem(data)
            else
                Items[id]:RefreshItem(data)
            end

            if not ItemFirstGetCheckTable[id] then
                ItemFirstGetCheckTable[id] = true
            end
        end

        -- 回收道具时限表
        local list = data.ItemRecycleDict
        if not list then return end
        for id, itemRecycleList in pairs(list) do
            Items[id].ItemRecycleList = itemRecycleList
        end
    end

    function XItemManager.GetMaxCount(id)
        if id == XItemManager.ItemId.ActionPoint then
            return XItemManager.GetMaxActionPoints()
        else
            local template = XItemManager.GetItemTemplate(id)
            if template then
                if template.MaxCount <= 0 then
                    return XMath.IntMax() -- int.MaxValue，和服务端相同
                else
                    return template.MaxCount
                end
            else
                return -1
            end
        end
    end

    function XItemManager.ConvertToGridData(originDatas)
        local bagDatas = {}
        for i = 1, #originDatas do
            local data = originDatas[i]
            if data.Count > 0 then
                -- 按限时道具到期时间拆分（优先）
                if XItemManager.IsTimeLimitBatch(data.Id) then
                    local gridCount = data.ItemRecycleList
                    for index, info in ipairs(data.ItemRecycleList) do
                        if info.RecycleCount > 0 then
                            local gridData = {}
                            gridData.Data = data
                            gridData.GridIndex = index
                            gridData.RecycleBatch = info
                            tableInsert(bagDatas, gridData)
                        end
                    end
                    -- 按最大堆叠数拆分
                elseif data.Template.GridCount <= 0 then
                    local gridData = {}
                    gridData.Data = data
                    gridData.GridIndex = 1
                    tableInsert(bagDatas, gridData)
                else
                    local gridCount = math.ceil(data.Count / data.Template.GridCount)
                    for j = 1, gridCount do
                        local gridData = {}
                        gridData.Data = data
                        gridData.GridIndex = j
                        tableInsert(bagDatas, gridData)
                    end
                end
            end
        end
        return bagDatas
    end

    function XItemManager.NotifyItemBuyTiems(data)
        XItemManager.OnSyncBuyTimes(data.TargetId, data.Times)
    end

    -------------------------道具事件相关-------------------------
    --==============================--
    --desc: 道具数量变化监听
    --@ids: 道具id或者道具id列表
    --@func: 事件回调
    --@ui: ui节点
    --@obj: UI对象，可为空
    --==============================--
    function XItemManager.AddCountUpdateListener(ids, func, ui, obj)
        if type(ids) == "number" then
            if ids == XItemManager.ItemId.FreeGem or ids == XItemManager.ItemId.PaidGem then
                ids = { XItemManager.ItemId.FreeGem, XItemManager.ItemId.PaidGem }
            else
                ids = { ids }
            end
        end


        for _, id in pairs(ids) do
            if not Items[id] then
                XLog.Error("XItemManager.AddCountUpdateListener Error: unknown item, id is " .. id)
                return
            end
        end

        if not ui then
            XLog.Error("XItemManager.AddCountUpdateListener Error: ui can not be null")
            return
        end

        for _, id in pairs(ids) do
            XEventManager.BindEvent(ui, XEventId.EVENT_ITEM_COUNT_UPDATE_PREFIX .. id, func, obj)
        end
    end

    --==============================--
    --desc: 购买次数变化监听
    --@ids: 道具id或者道具id列表
    --@func: 事件回调
    --@ui: ui节点
    --@obj: UI对象，可为空
    --==============================--
    function XItemManager.AddBuyTimesUpdateListener(ids, func, ui, obj)
        if type(ids) == "number" then
            if ids == XItemManager.ItemId.FreeGem or ids == XItemManager.ItemId.PaidGem then
                ids = { XItemManager.ItemId.FreeGem, XItemManager.ItemId.PaidGem }
            else
                ids = { ids }
            end
        end

        for _, id in pairs(ids) do
            if not Items[id] then
                XLog.Error("XItemManager.AddBuyTimesUpdateListener Error: unknown item, id is " .. id)
                return
            end
        end

        if not ui then
            XLog.Error("XItemManager.AddBuyTimesUpdateListener Error: ui can not be null")
            return
        end

        for _, id in pairs(ids) do
            XEventManager.BindEvent(ui, XEventId.EVENT_ITEM_BUYTIEMS_UPDATE_PREFIX .. id, func, obj)
        end
    end

    -- 已被回收道具，在下次打开背包时弹出信息
    local RecycleItemList = {
        RecycleItems = {},
        RewardGoodsList = {},
    }

    function XItemManager.GetRecycleItemList()
        if not next(RecycleItemList.RecycleItems) then return end
        return RecycleItemList
    end

    function XItemManager.ResetRecycleItemList()
        RecycleItemList = {
            RecycleItems = {},
            RewardGoodsList = {},
        }
    end

    function XItemManager.NotifyItemRecycle(data)
        if not next(data.RecycleIds) then return end

        for _, id in pairs(data.RecycleIds) do
            tableInsert(RecycleItemList.RecycleItems, { Id = id, Count = XDataCenter.ItemManager.GetCount(id) })
            Items[id] = nil
        end

        for _, v in pairs(data.RewardGoodsList) do
            tableInsert(RecycleItemList.RewardGoodsList, v)
        end

        CsXGameEventManager.Instance:Notify(XEventId.EVENT_ITEM_RECYCLE)
    end

    function XItemManager.NotifyBatchItemRecycle(data)
        if not next(data.ItemRecycleList) then return end

        for _, recycleInfo in pairs(data.ItemRecycleList) do
            local id = recycleInfo.Id
            tableInsert(RecycleItemList.RecycleItems, { Id = id, Count = recycleInfo.RecycleCount })

            local item = Items[id]
            local itemRecycleList = item and item.ItemRecycleList
            if itemRecycleList then
                for k, v in pairs(itemRecycleList) do
                    if v.RecycleTime == recycleInfo.RecycleTime then
                        tableRemove(itemRecycleList, k)
                        break
                    end
                end

                if not next(itemRecycleList) then
                    Items[id] = nil
                end
            end
        end

        CsXGameEventManager.Instance:Notify(XEventId.EVENT_ITEM_RECYCLE)
    end

    function XItemManager.NotifyAllRedEnvelope(data)
        if not next(data.Envelopes) then return end

        RedEnvelopeInfos = {}
        for _, envelope in pairs(data.Envelopes) do
            local activityId = envelope.ActivityId
            RedEnvelopeInfos[activityId] = RedEnvelopeInfos[activityId] or {}

            local npcId = envelope.NpcId
            RedEnvelopeInfos[activityId][npcId] = RedEnvelopeInfos[activityId][npcId] or {}

            local rewards = envelope.Rewards
            for _, reward in pairs(rewards) do
                local itemId = reward.ItemId
                local itemCount = reward.ItemCount
                local oldCount = RedEnvelopeInfos[activityId][npcId][itemId] or 0
                RedEnvelopeInfos[activityId][npcId][itemId] = oldCount + itemCount
            end
        end
    end

    function XItemManager.NotifyRedEnvelopeUse(data)
        local envelopeId = data.EnvelopeId
        if not envelopeId or not XItemManager.IsRedEnvelope(envelopeId) then return end

        local envelopes = data.Envelopes
        if not next(envelopes) then return end

        for _, envelope in pairs(envelopes) do
            local activityId = envelope.ActivityId
            RedEnvelopeInfos[activityId] = RedEnvelopeInfos[activityId] or {}

            local npcId = envelope.NpcId
            RedEnvelopeInfos[activityId][npcId] = RedEnvelopeInfos[activityId][npcId] or {}

            local itemId = envelope.ItemId
            local itemCount = envelope.ItemCount
            local oldCount = RedEnvelopeInfos[activityId][npcId][itemId] or 0
            RedEnvelopeInfos[activityId][npcId][itemId] = oldCount + itemCount
        end

        XLuaUiManager.Open("UiRedEnvelope", envelopeId, envelopes)
    end
    -------------------------道具事件相关-------------------------
    XItemManager.Init()
    return XItemManager
end

XRpc.NotifyItemDataList = function(data)
    XDataCenter.ItemManager.NotifyItemDataList(data)
end

XRpc.NotifyItemBuyTiems = function(data)
    XDataCenter.ItemManager.NotifyItemBuyTiems(data)
end

XRpc.NotifyItemRecycle = function(data)
    XDataCenter.ItemManager.NotifyItemRecycle(data)
end

XRpc.NotifyBatchItemRecycle = function(data)
    XDataCenter.ItemManager.NotifyBatchItemRecycle(data)
end

XRpc.NotifyAllRedEnvelope = function(data)
    XDataCenter.ItemManager.NotifyAllRedEnvelope(data)
end

XRpc.NotifyRedEnvelopeUse = function(data)
    XDataCenter.ItemManager.NotifyRedEnvelopeUse(data)
end