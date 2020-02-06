local CSXTextManagerGetText = CS.XTextManager.GetText

local MailWillFullCount = CS.XGame.ClientConfig:GetInt("MailWillFullCount") --邮箱将满
local TipTimeLimitItemsLeftTime = CS.XGame.ClientConfig:GetInt("TipTimeLimitItemsLeftTime")    -- 限时道具提示时间
local TipBatteryLeftTime = CS.XGame.ClientConfig:GetInt("TipBatteryLeftTime")    -- 限时血清道具提示时间
local TipBatteryRefreshGap = 30     -- 限时血清道具刷新间隔

XUiMainRightTop = XClass()

function XUiMainRightTop:Ctor(rootUi)
    self.LastTipBatteryRefreshTime = 0
    self.Transform = rootUi.PanelRightTop.gameObject.transform
    XTool.InitUiObject(self)
    self:UpdateTimeLimitItemTipTimer()
    self:UpdateNowTimeTimer() -- 先更新一次时间和电量
    self.BatteryTimeSchedule = CS.XScheduleManager.Schedule(function()
        self:UpdateNowTimeTimer()
        self:UpdateTimeLimitItemTipTimer()
    end, 1000, 0)
    XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.FreeGem, XDataCenter.ItemManager.ItemId.ActionPoint, XDataCenter.ItemManager.ItemId.Coin)
    --ClickEvent
    self.BtnSet.CallBack = function() self:OnBtnSet() end
    self.BtnMail.CallBack = function() self:OnBtnMail() end
    --RedPoint
    XRedPointManager.AddRedPointEvent(self.BtnMail.ReddotObj, self.OnCheckMailNews, self, { XRedPointConditions.Types.CONDITION_MAIN_MAIL })

    XEventManager.AddEventListener(XEventId.EVENT_TIMELIMIT_ITEM_USE, function()
        self.LastTipBatteryRefreshTime = 0
    end)

    --Filter
    self:CheckFilterFunctions()
end

--事件监听
function XUiMainRightTop:OnNotify(evt, ...)
    if evt == XEventId.EVENT_MAIL_COUNT_CHEAK then
        self:OnCheckMailWillFull()
    end
end

function XUiMainRightTop:OnEnable()
    self.LastTipBatteryRefreshTime = 0
    self:OnCheckMailWillFull()
end

function XUiMainRightTop:OnDestroy()
    CS.XScheduleManager.UnSchedule(self.BatteryTimeSchedule)
end

function XUiMainRightTop:CheckFilterFunctions()
    self.BtnSet.gameObject:SetActiveEx(not XFunctionManager.CheckFunctionFitter(XFunctionManager.FunctionName.SkipSetting))
    self.BtnMail.gameObject:SetActiveEx(not XFunctionManager.CheckFunctionFitter(XFunctionManager.FunctionName.Mail))
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
    self.TxtPhoneTime.text = XTime.TimestampToGameDateTimeString(XTime.GetServerNowTimestamp(), "HH:mm")
end

-- 限时道具提示
function XUiMainRightTop:UpdateTimeLimitItemTipTimer()
    local nowTime = XTime.GetServerNowTimestamp()
    if nowTime - self.LastTipBatteryRefreshTime < TipBatteryRefreshGap then
        return
    end
    self.LastTipBatteryRefreshTime = nowTime

    -- 血清道具
    if not XTool.UObjIsNil(self.TxtBatteryLeftTime) then
        local leftTime = XDataCenter.ItemManager.GetBatteryMinLeftTime()
        if leftTime > 0 and leftTime <= TipBatteryLeftTime then
            self.TxtBatteryLeftTime.text = CSXTextManagerGetText("BatteryLeftTime", XUiHelper.GetTime(leftTime, XUiHelper.TimeFormatType.MAINBATTERY))
            self.TxtBatteryLeftTime.gameObject:SetActiveEx(true)
        else
            self.TxtBatteryLeftTime.gameObject:SetActiveEx(false)
        end
    end

    --背包道具
    if not XTool.UObjIsNil(self.TxtItemLeftTime) then
        local leftTime = XDataCenter.ItemManager.GetTimeLimitItemsMinLeftTime()
        if leftTime > 0 and leftTime <= TipTimeLimitItemsLeftTime then
            local timeStr = XUiHelper.GetBagTimeLimitTimeStrAndBg(leftTime)
            self.TxtItemLeftTime.text = CSXTextManagerGetText("TimeLimitItemLeftTime", timeStr)
            self.TxtItemLeftTime.gameObject:SetActiveEx(true)
        else
            self.TxtItemLeftTime.gameObject:SetActiveEx(false)
        end
    end
end

--邮件红点
function XUiMainRightTop:OnCheckMailNews(count)
    self.BtnMail:ShowReddot(count >= 0)
end

--邮件将满
function XUiMainRightTop:OnCheckMailWillFull()
    local count = XDataCenter.MailManager.GetMailCount()
    self.TxtMailWillFull.gameObject:SetActiveEx(count >= MailWillFullCount)
end