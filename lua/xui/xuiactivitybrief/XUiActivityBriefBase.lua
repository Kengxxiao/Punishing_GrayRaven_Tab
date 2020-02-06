local CSXTextManagerGetText = CS.XTextManager.GetText

local BgCount = 1
local BgPath = {
    [1] = CS.XGame.ClientConfig:GetString("UiActivityBriefBg1"),
    [2] = CS.XGame.ClientConfig:GetString("UiActivityBriefBg2"),
    [3] = CS.XGame.ClientConfig:GetString("UiActivityBriefBg3"),
    [4] = CS.XGame.ClientConfig:GetString("UiActivityBriefBg4"),
    [5] = CS.XGame.ClientConfig:GetString("UiActivityBriefBg5"),
}

local XUiActivityBriefBase = XLuaUiManager.Register(XLuaUi, "UiActivityBriefBase")

XUiActivityBriefBase.BtnTabIndex = {
    Entry = 1,
    Task = 2,
    Shop = 3,
    Draw = 4,
}

function XUiActivityBriefBase:OnAwake()
    self:AutoAddListener()
    XRedPointManager.AddRedPointEvent(self.BtnTask, self.OnCheckNewActivities, self, { XRedPointConditions.Types.CONDITION_ACTIVITY_BRIRF_TASK_FINISHED })
    XEventManager.AddEventListener(XEventId.EVENT_BRIEF_CHANGE_TAB, self.OnChangeTab, self)
    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.FreeGem, XDataCenter.ItemManager.ItemId.ActionPoint, XDataCenter.ItemManager.ItemId.Coin)
    self.BtnShop:ShowReddot(false)
    self.BtnDraw:ShowReddot(false)
end

function XUiActivityBriefBase:OnStart(tabIdx)
    self:InitLifetime()
    self.TabIdx = tabIdx
    --self:InitShopLeftTime()
    if not tabIdx then
        local animName = ""
        local firstOpen = XDataCenter.ActivityBriefManager.IsFirstOpen()
        if firstOpen then
            animName = "AnimEnable1"
            -- CS.XAudioManager.PlaySound(XSoundManager.UiBasicsMusic.UiActivityBrief_Anim)
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
    BgCount = 2
end

function XUiActivityBriefBase:PlayLoopBgAnime()
    self:PlayAnimation("BeijingLoop", function()
        if not self.GameObject.activeSelf then return end
        self:PlayAnimation("BeijingDisable", function()
            if not self.GameObject.activeSelf then return end
            self:AutoChangeBg()
            self:PlayAnimation("BeijingEnable", function()
                if not self.GameObject.activeSelf then return end
                self:PlayLoopBgAnime()
            end)
        end)
    end)
end

function XUiActivityBriefBase:AutoChangeBg()
    self.BgImage:SetRawImage(BgPath[BgCount])
    BgCount = BgCount + 1
    BgCount = BgCount > #BgPath and 1 or BgCount
end

function XUiActivityBriefBase:OnEnable()
    self.BtnTask:SetDisable(not XFunctionManager.JudgeCanOpen(XFunctionManager.FunctionName.Task))
    self.BtnShop:SetDisable(not XFunctionManager.JudgeCanOpen(XFunctionManager.FunctionName.ShopCommon))
    self.BtnDraw:SetDisable(not XDataCenter.GachaManager.CheckGachaIsOpenById(XDataCenter.ActivityBriefManager.GetActivityGachaId(), false))
    if not self.TabIdx then
        self.BasePane.gameObject:SetActiveEx(true)
        self.TabIdx = nil
    end
    self:PlayLoopBgAnime()
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
                self.BasePane.gameObject:SetActiveEx(true)
            else
                self:Close()
            end

        end,self)
    elseif tabIndex == self.BtnTabIndex.Shop then
        if not XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.ShopCommon) then
            return
        end
        self:OpenOneChildUi("UiActivityBriefShop", function()
            if not self.SkipFromOthers then
                self:OpenOneChildUi("UiActivityBriefEntry")
                self:PlayAnimationWithMask("AnimEnable2")
                self.BasePane.gameObject:SetActiveEx(true)
            else
                self:Close()
            end
        end,self)
    elseif tabIndex == self.BtnTabIndex.Draw then
        if not XDataCenter.GachaManager.CheckGachaIsOpenById(XDataCenter.ActivityBriefManager.GetActivityGachaId(), true) then
            return
        end
        local startCB = function()
            self.BasePane.gameObject:SetActiveEx(false)
        end
        local closeCB = function()
            if self.SkipFromOthers then
                self:Close()
                self.BasePane.gameObject:SetActiveEx(true)
            end
        end

        local Id = XDataCenter.ActivityBriefManager.GetActivityGachaId()
        local Ui = XDataCenter.ActivityBriefManager.GetActivityGachaUi()
        local Bg = XDataCenter.ActivityBriefManager.GetActivityGacha3DBg()
        XDataCenter.GachaManager.GetGachaInfoList(Id, function()
            XLuaUiManager.Open(Ui, Id, startCB, closeCB, Bg)

        end)
    end

    self.SelectedIndex = tabIndex
end

function XUiActivityBriefBase:InitLifetime()
    local nowTime = XTime.GetServerNowTimestamp()
    local taskBeginTime, taskEndTime = XDataCenter.ActivityBriefManager.GetActivityBriefTime()
    if taskBeginTime > nowTime or nowTime >= taskEndTime then
        self.TxtTaskTime.gameObject:SetActiveEx(false)
    else
        local timeStr = XUiHelper.GetTime(taskEndTime - nowTime, XUiHelper.TimeFormatType.ACTIVITY)
        self.TxtTaskTime.text = CSXTextManagerGetText("ActivityBriefLeftTime", timeStr)
        self.TxtTaskTime.gameObject:SetActiveEx(true)
    end
end

function XUiActivityBriefBase:InitShopLeftTime()
    if not XFunctionManager.JudgeCanOpen(XFunctionManager.FunctionName.ShopCommon) then
        return
    end
    self.TxtShopTime.gameObject:SetActiveEx(false)
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
    self.BtnDraw.CallBack = function() self:OnClickTabCallBack(self.BtnTabIndex.Draw) end
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