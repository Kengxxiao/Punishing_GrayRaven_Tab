local CSXTextManagerGetText = CS.XTextManager.GetText

local XUiActivityBriefBase = XLuaUiManager.Register(XLuaUi, "UiActivityBriefBase")

XUiActivityBriefBase.BtnTabIndex = {
    Entry = 1,
    Task = 2,
    Shop = 3,
}

function XUiActivityBriefBase:OnAwake()
    self:AutoAddListener()
    XRedPointManager.AddRedPointEvent(self.BtnTask, self.OnCheckNewActivities, self, { XRedPointConditions.Types.CONDITION_ACTIVITY_BRIRF_TASK_FINISHED })
    XEventManager.AddEventListener(XEventId.EVENT_BRIEF_CHANGE_TAB, self.OnChangeTab, self)
    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.FreeGem, XDataCenter.ItemManager.ItemId.ActionPoint, XDataCenter.ItemManager.ItemId.Coin)
end

function XUiActivityBriefBase:OnStart(tabIdx)
    self:InitTaskLeftTime()
    self:InitShopLeftTime()
    if not tabIdx then
        local animName = ""
        local firstOpen = XDataCenter.ActivityBriefManager.IsFirstOpen()
        if firstOpen then
            animName = "AnimEnable1"
            XDataCenter.ActivityBriefManager.SetNotFirstOpen()
        else
            animName = "AnimEnable2"
        end

        self:PlayAnimationWithMask(animName)
        self:OpenOneChildUi("UiActivityBriefEntry", firstOpen)
        self.SkipFromOthers = nil
    else
        self:OnClickTabCallBack(tabIdx)
        self.SkipFromOthers = true
    end
end

function XUiActivityBriefBase:OnEnable()
    XSoundManager.PlaySoundDoNotInterrupt(XSoundManager.UiBasicsMusic.UiActivity_Jidi_BGM)
    self.BtnTask:SetDisable(not XFunctionManager.JudgeCanOpen(XFunctionManager.FunctionName.Task))
    self.BtnShop:SetDisable(not XFunctionManager.JudgeCanOpen(XFunctionManager.FunctionName.ShopCommon))
end

function XUiActivityBriefBase:OnDestroy()
    XEventManager.RemoveEventListener(XEventId.EVENT_BRIEF_CHANGE_TAB, self.OnChangeTab, self)
end

function XUiActivityBriefBase:OnCheckNewActivities(count)
    self.BtnTask:ShowReddot(count >= 0)
end

function XUiActivityBriefBase:OnChangeTab(tabIdx)
    self:OnClickTabCallBack(tabIdx)
end

function XUiActivityBriefBase:OnClickTabCallBack(tabIndex)
    if not tabIndex then
        return
    end

    if tabIndex == self.BtnTabIndex.Task then
        if not XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.Task) then
            return
        end
        self:OpenOneChildUi("UiActivityBriefTask", function()
            if not self.SkipFromOthers then
                self:OpenOneChildUi("UiActivityBriefEntry")
                self:PlayAnimationWithMask("AnimEnable2")
            else
                self:Close()
            end
        end)
    elseif tabIndex == self.BtnTabIndex.Shop then
        if not XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.ShopCommon) then
            return
        end
        self:OpenOneChildUi("UiActivityBriefShop", function()
            if not self.SkipFromOthers then
                self:OpenOneChildUi("UiActivityBriefEntry")
                self:PlayAnimationWithMask("AnimEnable2")
            else
                self:Close()
            end
        end)
    end

    self.SelectedIndex = tabIndex
end

function XUiActivityBriefBase:InitTaskLeftTime()
    local nowTime = XTime.Now()
    local taskBeginTime, taskEndTime = XDataCenter.ActivityBriefManager.GetActivityTaskTime()
    if taskBeginTime > nowTime or nowTime >= taskEndTime then
        self.TxtTaskTime.gameObject:SetActiveEx(false)
    else
        local timeStr = XUiHelper.GetTime(taskEndTime - nowTime, XUiHelper.TimeFormatType.ACTIVITY)
        self.TxtTaskTime.text = CSXTextManagerGetText("ActivityBriefLeftTime", timeStr)
        self.TxtTaskTime.gameObject:SetActiveEx(true)
    end
end

function XUiActivityBriefBase:InitShopLeftTime()
    self.TxtShopTime.gameObject:SetActiveEx(false)
    if not XFunctionManager.JudgeCanOpen(XFunctionManager.FunctionName.ShopCommon) then
        return
    end

    local shopId = XDataCenter.ActivityBriefManager.GetActivityShopId()
    if shopId <= 0 then
        XLog.Error("ShopId not Exsit while trying to open UiActivityBriefBase, pls check ActivityBrief.tab!")
        return
    end
    XShopManager.ClearBaseInfoData()
    XShopManager.GetBaseInfo(function()
        XShopManager.GetShopInfo(shopId, function()
            local shopTimeInfo = XShopManager.GetShopTimeInfo(shopId)
            local leftTime = shopTimeInfo.ClosedLeftTime
            if leftTime > 0 then
                local timeStr = XUiHelper.GetTime(leftTime, XUiHelper.TimeFormatType.ACTIVITY)
                self.TxtShopTime.text = CSXTextManagerGetText("ActivityBriefLeftTime", timeStr)
                self.TxtShopTime.gameObject:SetActiveEx(true)
            end
        end, true)
    end)
end

function XUiActivityBriefBase:AutoAddListener()
    self:RegisterClickEvent(self.BtnBack, self.OnBtnBackClick)
    self:RegisterClickEvent(self.BtnMainUi, self.OnBtnMainUiClick)
    self:RegisterClickEvent(self.BtnDetail, self.OnBtnDetailClick)
    self.BtnTask.CallBack = function() self:OnClickTabCallBack(self.BtnTabIndex.Task) end
    self.BtnShop.CallBack = function() self:OnClickTabCallBack(self.BtnTabIndex.Shop) end
end

function XUiActivityBriefBase:OnBtnBackClick(eventData)
    self:Close()
end

function XUiActivityBriefBase:OnBtnMainUiClick(eventData)
    XLuaUiManager.RunMain()
end

function XUiActivityBriefBase:OnBtnDetailClick(eventData)
    XLuaUiManager.Open("UiActivityBase")
end