XPayHeroAgent = XClass(XPayAgent)

local Application = CS.UnityEngine.Application
local Platform = Application.platform
local RuntimePlatform = CS.UnityEngine.RuntimePlatform

local function TipPayFail()
    local text = CS.XTextManager.GetText("PayFail")
    XUiManager.DialogTip("", text, XUiManager.DialogType.OnlySure)
    XEventManager.DispatchEvent(XEventId.EVNET_FAIL_PAY)
end

local function PayAndroid(self, productKey, cpOrderId, goodsId, cb)
    -- -- 测试充值
    -- XLog.Error("安卓进行充值")
    XHeroSdkManager.Pay(productKey, cpOrderId, goodsId, function (err, info)
        -- XLog.Error("productKey"..tostring(productKey))
        -- XLog.Error("cpOrderId"..tostring(cpOrderId))
        -- XLog.Error("goodsId"..tostring(goodsId))
        -- XLog.Error("错误err")
        -- XLog.Error(err)
        -- XLog.Error("信息info")
        -- XLog.Error(info)
        if err then
            TipPayFail()
            return
        end
        
        self:OnPaySuccess({
            ProductKey = productKey,
            OrderId = cpOrderId,
            GoodsId = goodsId,
            PlayerId = XPlayer.Id
        })

        if cb then
            cb()
        end
    end)
end

local function PayIOS(self, productKey, cpOrderId, goodsId)
    -- -- 测试充值
    -- XLog.Error("IOS进行充值")
    -- XLog.Error("productKey"..tostring(productKey))
    -- XLog.Error("cpOrderId"..tostring(cpOrderId))
    -- XLog.Error("goodsId"..tostring(goodsId))
    XHeroSdkManager.Pay(productKey, cpOrderId, goodsId)
end

function XPayHeroAgent:Ctor(playerId)
    if Platform == RuntimePlatform.Android then
        self.Pay = PayAndroid
    elseif Platform == RuntimePlatform.IPhonePlayer then
        XHeroSdkManager.RegisterIOSCallback(function(err, orderId) 
            self:OnIOSPayCallback(err, orderId)
        end)

        self.Pay = PayIOS
    else
        XLog.error("XPayHeroAgent Ctor: unsupport platform, platform is ", Platform)
    end
end

-- function XPayHeroAgent:OnPaySuccess(order)
--     XPayHeroAgent.Super.OnPaySuccess(self, order)
-- end

-- function XPayHeroAgent:OnDealSuccess(orderList)
--     XPayHeroAgent.Super.OnDealSuccess(self, orderList)
--     self:UpdateOrderCheckTimes()
-- end

function XPayHeroAgent:OnIOSPayCallback(err, orderId)
    if err then
        TipPayFail()
        return
    end

    self:OnPaySuccess({
        OrderId = orderId,
        PlayerId = XPlayer.Id
    })
end