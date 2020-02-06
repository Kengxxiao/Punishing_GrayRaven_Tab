XPayManagerCreator = function()
    local Application = CS.UnityEngine.Application
    local Platform = Application.platform
    local RuntimePlatform = CS.UnityEngine.RuntimePlatform
    local PayAgent = nil

    local XPayManager = {}
    local IsGetFirstRechargeReward  -- 是否领取首充奖励
    local IsFirstRecharge           -- 是否首充

    local METHOD_NAME = {
        Initiated = "PayInitiatedRequest",
        CheckResult = "PayCheckResultRequest",
        GetFirstPayReward = "GetFirstPayRewardRequest", -- 获取首充奖励
    }

    local function IsSupportPay()
        return Application.isMobilePlatform or
                (Platform == RuntimePlatform.WindowsPlayer or Platform == RuntimePlatform.WindowsEditor)
    end

    local function InitAgent()
        if Platform == RuntimePlatform.Android then
            PayAgent = XPayHeroAgent.New(XPlayer.Id)
        elseif Platform == RuntimePlatform.IPhonePlayer then
            PayAgent = XPayHeroAgent.New(XPlayer.Id)
        elseif Platform == RuntimePlatform.WindowsPlayer or Platform == RuntimePlatform.WindowsEditor then
            PayAgent = XPayAgent.New(XPlayer.Id)
        else
            -- XLog.Debug("XPayManager InitAgent info: nonsupport platform, platform is ", Platform)
        end
    end

    local function DoInit()
        XEventManager.AddEventListener(XEventId.EVENT_LOGIN_SUCCESS, function() 
            InitAgent()
        end)
    end

    local DoPay = function (productKey, cpOrderId, goodsId)
        PayAgent:Pay(productKey, cpOrderId, goodsId)
    end

    function XPayManager.Pay(productKey)
        if not IsSupportPay() or not PayAgent then
            -- XLog.Debug("XPayManager Pay info: nonsupport platform, platform is ", Platform)
            return
        end

        local template = XPayConfigs.GetPayTemplate(productKey)
        if not template then
            return
        end

        XNetwork.Call(METHOD_NAME.Initiated, {Key = productKey}, function (res) 
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end
            --BDC
            CS.XHeroBdcAgent.BdcCreateOrder(template.GoodsId, productKey, XTime.GetServerNowTimestamp(), res.GameOrder)
            DoPay(productKey, res.GameOrder, template.GoodsId)
        end)
    end

    -- 领取首充奖励请求
    function XPayManager.GetFirstPayRewardReq(cb)
        XNetwork.Call(METHOD_NAME.GetFirstPayReward, nil, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end
            
            IsGetFirstRechargeReward = true
            if cb then
                cb()
            end
            XUiManager.OpenUiObtain(res.RewardList)
            XEventManager.DispatchEvent(XEventId.EVENT_CARD_REFRESH_WELFARE_BTN)
        end)
    end

    function XPayManager.GetFirstRecharge()
        return IsFirstRecharge
    end

    function XPayManager.GetFirstRechargeReward()
        return IsGetFirstRechargeReward
    end

    -- 是否首充奖励领取
    function XPayManager.IsGotFirstReCharge()
        local isRecharge = XPayManager.GetFirstRecharge()
        if not isRecharge then 
            return true
        end
    
        local isGot = XPayManager.GetFirstRechargeReward()
        return isGot
    end

    -- 是否月卡奖励领取
    function XPayManager.IsGotCard()
        local isBuy = XDataCenter.PurchaseManager.IsYkBuyed()
        if not isBuy then 
            return true
        end
    
        local data = XDataCenter.PurchaseManager.GetYKInfoData()
        return data.IsDailyRewardGet
    end

    function XPayManager.NotifyPayResult(data)
        if not data then return end

        IsFirstRecharge = XPayConfigs.CheckFirstPay(data.TotalPayMoney)
        local orderList = data.DealGameOrderList
        -- 测试充值
        -- XLog.Error("充值结果回调--orderList--Begin")
        -- XLog.Error(orderList)
        -- XLog.Error("充值结果回调--orderList--End")
        if not orderList or #orderList == 0 then
            return
        end

        -- XLog.Error("充值结果回调--PayAgent:OnDealSuccess(orderList)")
        PayAgent:OnDealSuccess(orderList)
        XEventManager.DispatchEvent(XEventId.EVENT_CARD_REFRESH_WELFARE_BTN)
    end

    function XPayManager.NotifyPayInfo(data)
        if not data then return end

        IsGetFirstRechargeReward = data.IsGetFirstPayReward
        IsFirstRecharge = XPayConfigs.CheckFirstPay(data.TotalPayMoney)
    end

    DoInit()

    return XPayManager
end

XRpc.NotifyPayResult = function(data)
    -- 测试充值
    -- XLog.Error("充值结果回调--data--Begin")
    -- XLog.Error(data)
    -- XLog.Error("充值结果回调--data--End")
    XDataCenter.PayManager.NotifyPayResult(data)
end

XRpc.NotifyPayInfo = function(data)
    XDataCenter.PayManager.NotifyPayInfo(data)
end