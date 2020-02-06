XUiMainRightBottom = XClass()

function XUiMainRightBottom:Ctor(rootUi)
    self.Transform = rootUi.PanelRightBottom.gameObject.transform
    XTool.InitUiObject(self)
    --ClickEvent
    self.BtnMember.CallBack = function() self:OnBtnMember() end
    self.BtnBag.CallBack = function() self:OnBtnBag() end
    self.BtnStore.CallBack = function() self:OnBtnStore() end
    self.BtnRecharge.CallBack = function() self:OnBtnRecharge() end
    --RedPoint
    XRedPointManager.AddRedPointEvent(self.BtnMember.ReddotObj, self.OnCheckMemberNews, self, { XRedPointConditions.Types.CONDITION_MAIN_MEMBER })
    -- XRedPointManager.AddRedPointEvent(self.BtnRecharge.ReddotObj, self.OnCheckRechargeNews, self, { XRedPointConditions.Types.CONDITION_PURCHASE_RED })
    
    --Filter
    self:CheckFilterFunctions()
end

function XUiMainRightBottom:OnEnable()
    -- 充值红点
    -- XDataCenter.PurchaseManager.LBInfoDataReq()
    self:OnCheckRechargeNews()
    XRedPointManager.CheckByNode(self.BtnMember.ReddotObj)
    --商店
    local isOpen = XFunctionManager.JudgeCanOpen(XFunctionManager.FunctionName.ShopCommon)
    or XFunctionManager.JudgeCanOpen(XFunctionManager.FunctionName.ShopActive)
    self.BtnStore:SetDisable(not isOpen)

    XEventManager.AddEventListener(XEventId.EVENT_DAYLY_REFESH_RECHARGE_BTN, self.OnCheckRechargeNews, self)
end

function XUiMainRightBottom:OnDisable()
    XEventManager.RemoveEventListener(XEventId.EVENT_DAYLY_REFESH_RECHARGE_BTN, self.OnCheckRechargeNews, self)
end

function XUiMainRightBottom:CheckFilterFunctions()
    self.BtnMember.gameObject:SetActiveEx(not XFunctionManager.CheckFunctionFitter(XFunctionManager.FunctionName.Character))
    self.BtnBag.gameObject:SetActiveEx(not XFunctionManager.CheckFunctionFitter(XFunctionManager.FunctionName.Bag))
    self.BtnStore.gameObject:SetActiveEx(not XFunctionManager.CheckFunctionFitter(XFunctionManager.FunctionName.ShopCommon)
    and not XFunctionManager.CheckFunctionFitter(XFunctionManager.FunctionName.ShopActive))
    self.BtnRecharge.gameObject:SetActiveEx(not XFunctionManager.CheckFunctionFitter(XFunctionManager.FunctionName.SkipRecharge))
end

--成员入口
function XUiMainRightBottom:OnBtnMember()
    if not XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.Character) then
        return
    end
    XLuaUiManager.Open("UiCharacter")
end

--仓库入口
function XUiMainRightBottom:OnBtnBag()
    if not XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.Bag) then
        return
    end
    XLuaUiManager.Open("UiBag")
end

--商店入口
function XUiMainRightBottom:OnBtnStore()
    if XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.ShopCommon)
    or XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.ShopActive) then
        XLuaUiManager.Open("UiShop", XShopManager.ShopType.Common)
    end
end

--充值入口
function XUiMainRightBottom:OnBtnRecharge()
    XLuaUiManager.Open("UiPurchase", XPurchaseConfigs.TabsConfig.LB)
end

--成员红点
function XUiMainRightBottom:OnCheckMemberNews(count)
    self.BtnMember:ShowReddot(count >= 0)
end

--充值红点
function XUiMainRightBottom:OnCheckRechargeNews()
    local f = XDataCenter.PurchaseManager.FreeLBRed() or XDataCenter.PurchaseManager.AccumlatePayRedPoint() or XDataCenter.PurchaseManager.CheckYKContinueBuy()
    self.BtnRecharge:ShowReddot(f)
end