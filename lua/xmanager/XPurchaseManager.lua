XPurchaseManagerCreator = function()
    local XPurchaseManager = {}
    local PurchaseRequest = {
        PurchaseGetDailyRewardReq = "PurchaseGetDailyRewardRequest",
        GetPurchaseListReq = "GetPurchaseListRequest", -- 采购列表请求
        PurchaseReq = "PurchaseRequest", -- 普通采购请求
    }

    local Next = _G.next
    local PurchaseInfosData = {}
    local PurchaseLbRedUiTypes = {}
    local AccumulatedData = {}
    local LBExpireIdKey = "LBExpireIdKey"
    local LBExpireIdDic = nil
    local IsYKShowConitnueBuy = false

    function XPurchaseManager.Init()
        XPurchaseManager.CurBuyIds = {}
        XPurchaseManager.GiftValidCb = function(uiTypeList, cb) XDataCenter.PurchaseManager.PurchaseGiftValidTimeCb(uiTypeList, cb) end
    end

    -- 按UiTypes取数据
    function XPurchaseManager.GetDatasByUiTypes(uitypes)
        local data = {}
        for _, uitype in pairs(uitypes) do
            table.insert(data, PurchaseInfosData[uitype] or {})
        end

        return data
    end

    -- 判断是否UiTypes都有数据
    function XPurchaseManager.IsHaveDataByUiTypes(uitypes)
        for _, uitype in pairs(uitypes) do
            if not PurchaseInfosData[uitype] then
                return false
            end
        end

        return true
    end

    -- 按UiType取数据
    function XPurchaseManager.GetDatasByUiType(uitype)
        local payuitypes = XPurchaseConfigs.GetPayUiTypes()
        if payuitypes[uitype] then
            return XPayConfigs.GetPayConfig()
        end
        return PurchaseInfosData[uitype]
    end

    function XPurchaseManager.ClearData()
        local uitypes = XPurchaseConfigs.GetYKUiTypes()
        local yktype = nil
        if uitypes and uitypes[1] then
            yktype = uitypes[1]
        end
        if yktype then
            local d = PurchaseInfosData[yktype]
            PurchaseInfosData = {}
            PurchaseInfosData[yktype] = d
        else
            PurchaseInfosData = {}
        end
    end

    -- RPC
    -- // 失效时间
    -- public int TimeToInvalid;
    -- 采购列表请求
    -- public List<XPurchaseClientInfo> PurchaseInfoList;
    function XPurchaseManager.GetPurchaseListRequest(uiTypeList, cb)
        XNetwork.Call(PurchaseRequest.GetPurchaseListReq, { UiTypeList = uiTypeList }, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            XPurchaseManager.HandlePurchaseData(uiTypeList, res.PurchaseInfoList)
            if cb then
                cb()
            end
            local lbcfg = XPurchaseConfigs.GetLBUiTypesDic()
            for _,v in pairs(uiTypeList)do
                if lbcfg[v] then
                    XEventManager.DispatchEvent(XEventId.EVENT_LB_UPDATE)
                    break
                end
            end
        end)
    end

    -- 处理返回的数据
    function XPurchaseManager.HandlePurchaseData(uiTypeList, purchaseInfoList)
        if not purchaseInfoList then
            return
        end

        for _, uiType in pairs(uiTypeList) do
            PurchaseInfosData[uiType] = {}
        end

        for _, v in pairs(purchaseInfoList) do
            if v.UiType then
                table.insert(PurchaseInfosData[v.UiType], v)
            end
        end
    end

    -- 普通采购请求
    -- public List<XRewardGoods> RewardList;
    function XPurchaseManager.PurchaseRequest(id, cb)
        XNetwork.Call(PurchaseRequest.PurchaseReq, { Id = id }, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            XPurchaseManager.CurBuyIds[id] = id
            if res.RewardList and res.RewardList[1] and Next(res.RewardList[1]) then
                XUiManager.OpenUiObtain(res.RewardList)
            else
                XUiManager.TipText("PurchaseLBBuySuccessTips")
            end

            XPurchaseManager.PurchaseSuccess(id, res.PurchaseInfo, res.NewPurchaseInfoList)
            if cb then
                cb()
            end

            XEventManager.DispatchEvent(XEventId.EVENT_LB_UPDATE)
            XEventManager.DispatchEvent(XEventId.EVENT_CARD_REFRESH_WELFARE_BTN)
        end)
    end

    -- 采购成功修正数据
    function XPurchaseManager.PurchaseSuccess(id, purchaseInfo, newPurchaseInfoList)
        XPurchaseManager.UpdateSingleData(id, purchaseInfo)
        if newPurchaseInfoList and Next(newPurchaseInfoList) then
            for _, v in pairs(newPurchaseInfoList) do
                if v and v.UiType then
                    local datas = PurchaseInfosData[v.UiType]
                    if not datas then
                        PurchaseInfosData[v.UiType] = {}
                    end
                    table.insert(PurchaseInfosData[v.UiType], v)
                end
            end
        end

        local LbExpireIds = XPurchaseManager.GetLbExpireIds()
        if XPurchaseManager.HaveNewPlayerHint(id) then
            LbExpireIds[id] = nil
            XPurchaseManager.SaveLBExpreIds(LbExpireIds)
        end
    end

    function XPurchaseManager.UpdateSingleData(id, purchaseInfo)
        local f = false
        for _, datas in pairs(PurchaseInfosData) do
            for _, data in pairs(datas) do
                if data.Id == id then
                    if (not purchaseInfo or Next(purchaseInfo) == nil) then
                        data.IsSelloutHide = true
                    elseif data.BuyLimitTimes == data.BuyTimes + 1 then
                        data.BuyTimes = data.BuyLimitTimes
                    else
                        XPurchaseManager.SetData(data, purchaseInfo)
                    end
                    f = true
                    break
                end
            end
            if f then
                break
            end
        end
    end

    function XPurchaseManager.SetData(data, purchaseInfo)
        if not purchaseInfo then
            data = nil
            return
        end

        data.TimeToUnShelve = purchaseInfo.TimeToUnShelve
        data.Tag = purchaseInfo.Tag
        data.Priority = purchaseInfo.Priority
        data.Icon = purchaseInfo.Icon
        data.DailyRewardRemainDay = purchaseInfo.DailyRewardRemainDay
        data.UiType = purchaseInfo.UiType
        data.ConsumeId = purchaseInfo.ConsumeId
        data.TimeToShelve = purchaseInfo.TimeToShelve
        data.BuyTimes = purchaseInfo.BuyTimes
        data.Desc = purchaseInfo.Desc
        data.RewardGoodsList = purchaseInfo.RewardGoodsList
        data.BuyLimitTimes = purchaseInfo.BuyLimitTimes
        data.ConsumeCount = purchaseInfo.ConsumeCount
        data.Name = purchaseInfo.Name
        data.TimeToInvalid = purchaseInfo.TimeToInvalid
        data.IsDailyRewardGet = purchaseInfo.IsDailyRewardGet
        data.Id = purchaseInfo.Id
        data.DailyRewardGoodsList = purchaseInfo.DailyRewardGoodsList
        data.FirstRewardGoods = purchaseInfo.FirstRewardGoods
        data.ExtraRewardGoods = purchaseInfo.ExtraRewardGoods
        data.ClientResetInfo = purchaseInfo.ClientResetInfo
        data.IsUseMail = purchaseInfo.IsUseMail or false
    end

    -- 领奖(月卡)
    function XPurchaseManager.PurchaseGetDailyRewardRequest(id, cb)
        XNetwork.Call(PurchaseRequest.PurchaseGetDailyRewardReq, { Id = id }, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            XPurchaseManager.GetRewardSuccess(id, res.PurchaseInfo)

            if cb then
                cb()
            end
            -- 设置月卡信息本地缓存
            XPurchaseManager.SetYKLoaclCache()

            XEventManager.DispatchEvent(XEventId.EVENT_CARD_REFRESH_WELFARE_BTN)
            XUiManager.OpenUiObtain(res.RewardList)
        end)
    end

    -- 领奖成功修正数据
    function XPurchaseManager.GetRewardSuccess(id, purchaseInfo)
        XPurchaseManager.UpdateSingleData(id, purchaseInfo)
    end

    -- 请求礼包数据
    function XPurchaseManager.LBInfoDataReq(cb)
        local uiTypeList = XPurchaseConfigs.GetLBUiTypesList()
        XPurchaseManager.GetPurchaseListRequest(uiTypeList, cb)
    end

    -- 请求月卡数据
    function XPurchaseManager.YKInfoDataReq(cb)
        local uiTypeList = XPurchaseConfigs.GetYKUiTypes()
        XPurchaseManager.GetPurchaseListRequest(uiTypeList, cb)
    end

    -- Get月卡数据
    function XPurchaseManager.GetYKInfoData()
        local data = {}
        local uiTypeList = XPurchaseConfigs.GetYKUiTypes()
        if uiTypeList and Next(uiTypeList) then
            for _,uitype in pairs(uiTypeList)do
                table.insert(data,XPurchaseManager.GetDatasByUiType(uitype))
            end
        end

        if not data[1] then
            return nil
        end

        if not data[1][1] then
            return nil
        end

        return data[1][1]
    end

    -- 是否已经买过了
    function XPurchaseManager.IsYkBuyed()
        local data = XPurchaseManager.GetYKInfoData()
        if not data then
            return false
        end

        return data.DailyRewardRemainDay > 0
    end

    function XPurchaseManager.FreeLBRed()
        if not XPurchaseManager.CurFreeRewardId or not Next(XPurchaseManager.CurFreeRewardId) then
            return false
        end

        if not XPurchaseManager.CurBuyIds or not Next(XPurchaseManager.CurBuyIds) then
            return true
        end

        for _,id in pairs(XPurchaseManager.CurFreeRewardId)do
            if not XPurchaseManager.CurBuyIds[id] then
                return true
            end
        end
        return false
    end

    -- Notify
    function XPurchaseManager.PurchaseDailyNotify(info)
        XPurchaseManager.CurFreeRewardId = {}
        if info and info.FreeRewardInfoList and Next(info.FreeRewardInfoList) then
            for _, v in pairs(info.FreeRewardInfoList)do
                XPurchaseManager.CurFreeRewardId[v.Id] = v.Id
            end
        end

        if info and info.ExpireInfoList and Next(info.ExpireInfoList) then
            XPurchaseManager:UpdatePurchaseGiftValidTime(info.ExpireInfoList)
        end

        -- 处理月卡红点
        if info and info.DailyRewardInfoList and Next(info.DailyRewardInfoList) then
            for _, v in pairs(info.DailyRewardInfoList) do
                if v.Id == XPurchaseConfigs.PurChaseCardId then
                    XDataCenter.PurchaseManager.YKInfoDataReq(function()
                        XEventManager.DispatchEvent(XEventId.EVENT_CARD_REFRESH_WELFARE_BTN)

                        -- 设置月卡信息本地缓存
                        XDataCenter.PurchaseManager.SetYKLoaclCache()
                        XEventManager.DispatchEvent(XEventId.EVENT_DAYLY_REFESH_RECHARGE_BTN)
                    end)
                end
            end
        end
    end

    function XPurchaseManager:UpdatePurchaseGiftValidTime(expireInfoList)
        local uiTypeList = XPurchaseConfigs.GetLBUiTypesList()
        if uiTypeList and Next(uiTypeList) ~= nil then
            XPurchaseManager.GetPurchaseListRequest(uiTypeList, function()
                XDataCenter.PurchaseManager.PurchaseGiftValidTimeCb(uiTypeList,expireInfoList)
            end)
        end
    end

    function XPurchaseManager.PurchaseGiftValidTimeCb(uiTypeList,expireInfoList)
        local datas = XPurchaseManager.GetDatasByUiTypes(uiTypeList)
        local f = false--是否有一个礼包重新买了。
        local count = 0
        local LbExpireIds = XPurchaseManager.GetLbExpireIds()
        if datas then
            for _, v0 in pairs(expireInfoList) do
                if XPurchaseConfigs.IsLBByPassID(v0.Id) then
                    for _, data in pairs(datas) do
                        for _, v1 in pairs(data) do
                            if v1.Id == v0.Id then
                                if v1.BuyTimes > 0 and v1.DailyRewardRemainDay > 0 then
                                    if XPurchaseManager.HaveNewPlayerHint(v0.Id) then
                                        LbExpireIds[v0.Id] = nil
                                    end
                                else
                                    if not XPurchaseManager.HaveNewPlayerHint(v0.Id) then
                                        LbExpireIds[v0.Id] = v0.Id
                                        count = count + 1
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        XPurchaseManager.SaveLBExpreIds(LbExpireIds)
        XPurchaseManager.ExpireCount = count

        -- local f = count == 0
        -- if not f then
        --     XEventManager.DispatchEvent(XEventId.EVENT_LB_EXPIRE_NOTIFY,count)
        -- end
    end

    function XPurchaseManager.HaveNewPlayerHint(id)
        if not id then
            return false
        end

        local ids = XPurchaseManager.GetLbExpireIds()
        return ids[id] ~= nil
    end

    function XPurchaseManager.SaveLBExpreIds(ids)
        if XPlayer.Id and ids then
            local idsstr = ""
            for k,v in pairs(ids) do
                if v then
                    idsstr = idsstr..v.."_"
                end
            end

            local key = string.format( "%s_%s", tostring(XPlayer.Id), LBExpireIdKey)
            CS.UnityEngine.PlayerPrefs.SetString(key, idsstr)
            CS.UnityEngine.PlayerPrefs.Save()
            LBExpireIdDic = nil
        end
    end

    function XPurchaseManager.GetLbExpireIds()
        if LBExpireIdDic then
            return LBExpireIdDic
        end

        if XPlayer.Id then
            LBExpireIdDic = {}
            local key = string.format( "%s_%s", tostring(XPlayer.Id), LBExpireIdKey)
            if CS.UnityEngine.PlayerPrefs.HasKey(key) then
                local str = CS.UnityEngine.PlayerPrefs.GetString(key) or ""
                for id in string.gmatch(str, "%d+") do
                    local v = tonumber(id)
                    LBExpireIdDic[v] = v
                end
            end
        end

        return LBExpireIdDic
    end

    -- 红点相关
    function XPurchaseManager.LBRedPoint()
        local uiTypeList = XPurchaseConfigs.GetLBUiTypesList()
        local datas = XPurchaseManager.GetDatasByUiTypes(uiTypeList)
        PurchaseLbRedUiTypes = {}
        if datas then
            local f = false
            for _, data in pairs(datas) do
                for _, v in pairs(data) do
                    if v and v.ConsumeCount == 0 then
                        local curtime = XTime.GetServerNowTimestamp()
                        if (v.BuyTimes == 0 or v.BuyTimes < v.BuyLimitTimes) and (v.TimeToShelve == 0 or v.TimeToShelve < curtime) and (v.TimeToUnShelve == 0 or v.TimeToUnShelve > curtime) then
                            f = true
                            PurchaseLbRedUiTypes[v.UiType] = v.UiType
                        end
                    end
                end
            end
            return f
        end

        return false
    end

    function XPurchaseManager.LBRedPointUiTypes()
        return PurchaseLbRedUiTypes
    end

    -- 累计充值相关
    function XPurchaseManager.NotifyAccumulatedPayData(info)
        if not info then
            return
        end
        AccumulatedData.PayId = info.PayId or 0--累计充值id
        AccumulatedData.PayMoney = info.PayMoney or 0--累计充值数量
        AccumulatedData.PayRewardIds = {}--已领取的奖励Id
        if info.PayRewardIds then
            for _,id in pairs(info.PayRewardIds) do
                AccumulatedData.PayRewardIds[id] = id
            end
        end
    end

    function XPurchaseManager.IsAccumulateEnterOpen()
        return AccumulatedData.PayId and AccumulatedData.PayId > 0 and XFunctionManager.JudgeOpen(XFunctionManager.FunctionName.PurchaseAdd) and not XFunctionManager.CheckFunctionFitter(XFunctionManager.FunctionName.PurchaseAdd)
    end

    function XPurchaseManager.NotifyAccumulatedPayMoney(info)
        if not info or not info.PayMoney or info.PayMoney < 0 or AccumulatedData.PayMoney > info.PayMoney then
            return
        end

        AccumulatedData.PayMoney = info.PayMoney
        XEventManager.DispatchEvent(XEventId.EVENT_ACCUMLATED_UPTATE)
    end

    -- 累计充值数量
    function XPurchaseManager.GetAccumlatedPayCount()
        return math.floor(AccumulatedData.PayMoney or 0)
    end

    -- 领取累计充值奖励
    function XPurchaseManager.GetAccumulatePayReq(payid,rewardid,cb)
        if not payid or not rewardid then
            return
        end

        XNetwork.Call("GetAccumulatePayRequest",{ PayId = payid,RewardId = rewardid},function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            AccumulatedData.PayRewardIds[rewardid] = rewardid
            local rewardGoodsList = res.RewardGoodsList
            if rewardGoodsList and Next(rewardGoodsList) then
                XUiManager.OpenUiObtain(rewardGoodsList)
                if cb then
                    cb(rewardGoodsList)
                end
            end
            XEventManager.DispatchEvent(XEventId.EVENT_ACCUMLATED_REWARD)
        end
        )
    end

    -- 奖励是否已经领过
    function XPurchaseManager.AccumlateRewardGeted(id)
        if not id then
           return false
        end

        return AccumulatedData.PayRewardIds[id] ~= nil
    end

    -- 取当前累计充值id
    function XPurchaseManager.GetAccumlatePayId()
        return AccumulatedData.PayId
    end

    -- 累计充值奖励
    function XPurchaseManager.GetAccumlatePayConfig()
        local id = AccumulatedData.PayId
        if not id or id <0 then
            return
        end

        return XPurchaseConfigs.GetAccumlatePayConfigById(id)
    end

    -- 累计充值奖励红点
    function XPurchaseManager.AccumlatePayRedPoint()
        local id = AccumulatedData.PayId
        if not id or id <0 then
            return false
        end

        local payconfig = XPurchaseConfigs.GetAccumlatePayConfigById(id)
        if payconfig then
            local rewardsId = payconfig.PayRewardId
            if rewardsId or Next(rewardsId) then
                for _,id in pairs(rewardsId) do
                    local payrewardconfig = XPurchaseConfigs.GetAccumlateRewardCofigById(id)
                    local count = AccumulatedData.PayMoney
                    if payrewardconfig and payrewardconfig.Money then
                        if payrewardconfig.Money <= count then
                            if not XPurchaseManager.AccumlateRewardGeted(id) then
                                return true
                            end
                        end
                    end
                end
            end
        end
        return false
    end

    function XPurchaseManager.PurchaseAddRewardState(id)
        if not id then
            return
        end

        local itemData = XPurchaseConfigs.GetAccumlateRewardCofigById(id)
        if not itemData then
            return
        end

        local money = itemData.Money
        local count = XPurchaseManager.GetAccumlatedPayCount()
        if count >= money then
            if not XPurchaseManager.AccumlateRewardGeted(id) then
                --能领，没有领。
                return XPurchaseConfigs.PurchaseRewardAddState.CanGet
            else
                --已经领
                return XPurchaseConfigs.PurchaseRewardAddState.Geted
            end
        else
            --不能领，钱不够。
            return XPurchaseConfigs.PurchaseRewardAddState.CanotGet
        end
    end

    -- 月卡继续购买红点相关
    function XPurchaseManager.SetYKLoaclCache()
        local data = XPurchaseManager.GetYKInfoData()
        if not data then
            return
        end

        local key = XPrefs.YKLoaclCachae .. tostring(XPlayer.Id)
        local count = 0
        if CS.UnityEngine.PlayerPrefs.HasKey(key) then
            count = CS.UnityEngine.PlayerPrefs.GetInt(key)
        else
            CS.UnityEngine.PlayerPrefs.SetInt(key, count)
        end

        if data.DailyRewardRemainDay and count ~= data.DailyRewardRemainDay then
            local continueBuyDays = XPurchaseConfigs.PurYKContinueBuyDays
            if data.DailyRewardRemainDay > continueBuyDays then
                CS.UnityEngine.PlayerPrefs.SetInt(key, data.DailyRewardRemainDay)
            end

            if count > 0 and data.DailyRewardRemainDay <= continueBuyDays then
                IsYKShowConitnueBuy = true
            else
                IsYKShowConitnueBuy = false
            end
        end
    end

    -- 检查是否显示购买月卡红点
    function XPurchaseManager.CheckYKContinueBuy()
        if not IsYKShowConitnueBuy then
            return IsYKShowConitnueBuy
        end

        local key = XPrefs.YKContinueBuy.. tostring(XPlayer.Id)
        if CS.UnityEngine.PlayerPrefs.HasKey(key) then
            local time = CS.UnityEngine.PlayerPrefs.GetString(key)
            local now = XTime.GetServerNowTimestamp()
            local todayFreshTime = XTime.GetSeverTodayFreshTime()
            local yesterdayFreshTime = XTime.GetSeverYesterdayFreshTime()
            local tempTime = now >= todayFreshTime and todayFreshTime or yesterdayFreshTime
            return tostring(tempTime) ~= time
        else
            return true
        end
    end

    -- 设置当日购买月卡红点已读
    function XPurchaseManager.SetYKContinueBuy()
        local key = XPrefs.YKContinueBuy.. tostring(XPlayer.Id)
        local now = XTime.GetServerNowTimestamp()
        local todayFreshTime = XTime.GetSeverTodayFreshTime()
        local yesterdayFreshTime = XTime.GetSeverYesterdayFreshTime()
        local tempTime = now >= todayFreshTime and todayFreshTime or yesterdayFreshTime
        CS.UnityEngine.PlayerPrefs.SetString(key, tostring(tempTime))

        local data = XPurchaseManager.GetYKInfoData()
        if not data then
            return
        end

        local cachaeKey = XPrefs.YKLoaclCachae .. tostring(XPlayer.Id)
        if data.DailyRewardRemainDay <= 0 then
            CS.UnityEngine.PlayerPrefs.SetInt(cachaeKey, data.DailyRewardRemainDay)
        end
    end

    XPurchaseManager.Init()
    return XPurchaseManager
end

XRpc.PurchaseDailyNotify = function(info)
    XDataCenter.PurchaseManager.PurchaseDailyNotify(info)
end

XRpc.NotifyAccumulatedPayData = function(info)
    XDataCenter.PurchaseManager.NotifyAccumulatedPayData(info)
end

XRpc.NotifyAccumulatedPayMoney = function(info)
    XDataCenter.PurchaseManager.NotifyAccumulatedPayMoney(info)
end
