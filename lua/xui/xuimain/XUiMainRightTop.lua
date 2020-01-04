local CSXTextManagerGetText = CS.XTextManager.GetText

local TipBatteryLeftTime = 3600 * 24 * 3    -- 限时血清道具提示时间
local TipBatteryRefreshGap = 30     -- 限时血清道具刷新间隔

XUiMainRightTop = XClass()

function XUiMainRightTop:Ctor(rootUi)
    self.LastTipBatteryRefreshTime = 0
    self.Transform = rootUi.PanelRightTop.gameObject.transform
    XTool.InitUiObject(self)
    self:UpdateBatteryLeftTimeTimer()
    self:UpdateNowTimeTimer() -- 先更新一次时间和电量
    self.BatteryTimeSchedule = CS.XScheduleManager.Schedule(function()
        self:UpdateNowTimeTimer()
        self:UpdateBatteryLeftTimeTimer()
    end, 1000, 0)
    XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.FreeGem, XDataCenter.ItemManager.ItemId.ActionPoint, XDataCenter.ItemManager.ItemId.Coin)
    --ClickEvent
    self.BtnSet.CallBack = function() self:OnBtnSet() end
    self.BtnMail.CallBack = function() self:OnBtnMail() end
    --RedPoint
    XRedPointManager.AddRedPointEvent(self.BtnMail.ReddotObj, self.OnCheckMailNews, self, { XRedPointConditions.Types.CONDITION_MAIN_MAIL })
end

function XUiMainRightTop:OnDestroy()
    CS.XScheduleManager.UnSchedule(self.BatteryTimeSchedule)
    self.LastTipBatteryRefreshTime = 0
end

--设置入口
function XUiMainRightTop:OnBtnSet()
    if not XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.SkipSetting) then
        return
    end
    XLuaUiManager.Open("UiSet", false)
end

--邮件入口
function XUiMainRightTop:OnBtnMail()
    XLuaUiManager.Open("UiMail")
end

--更新时间
function XUiMainRightTop:UpdateNowTimeTimer()
    if XTool.UObjIsNil(self.TxtPhoneTime) then return end
    self.TxtPhoneTime.text = os.date("%H:%M");
end

-- 限时血清道具提示
function XUiMainRightTop:UpdateBatteryLeftTimeTimer()
    if XTool.UObjIsNil(self.TxtBatteryLeftTime) then return end

    local nowTime = XTime.Now()
    if nowTime - self.LastTipBatteryRefreshTime < TipBatteryRefreshGap then
        return
    end
    self.LastTipBatteryRefreshTime = nowTime

    local leftTime = XDataCenter.ItemManager.GetBatteryMinLeftTime()
    if leftTime > 0 and leftTime <= TipBatteryLeftTime then
        self.TxtBatteryLeftTime.text = CSXTextManagerGetText("BatteryLeftTime", XUiHelper.GetTime(leftTime, XUiHelper.TimeFormatType.MAINBATTERY))
        self.TxtBatteryLeftTime.gameObject:SetActiveEx(true)
    else
        self.TxtBatteryLeftTime.gameObject:SetActiveEx(false)
    end
end

--邮件红点
function XUiMainRightTop:OnCheckMailNews(count)
    self.BtnMail:ShowReddot(count >= 0)
end