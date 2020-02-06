local next = next
local XUiActivityBase = XLuaUiManager.Register(XLuaUi, "UiActivityBase")

XUiActivityBase.BtnTabIndex = {
    Activity = 1,
    Notice = 2,
    ActivityNotice = 3,
}

XUiActivityBase.GameNoticeType = {
    ActivityNotice = 0,
    Notice = 1,
}

function XUiActivityBase:OnAwake()
    self:InitAutoScript()

    local tabGroup = {
        self.BtnActivity,
        self.BtnGameNotice,
        self.BtnActivityNotice,
    }
    self.PanelType:Init(tabGroup, function(tabIndex) self:OnClickTabCallBack(tabIndex) end)
    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.FreeGem, XDataCenter.ItemManager.ItemId.ActionPoint, XDataCenter.ItemManager.ItemId.Coin)

    XRedPointManager.AddRedPointEvent(self.BtnActivity, self.OnCheckNewActivities, self, { XRedPointConditions.Types.CONDITION_ACTIVITY_NEW_ACTIVITIES })
    XRedPointManager.AddRedPointEvent(self.BtnGameNotice, self.OnCheckNewGameNotices, self, { XRedPointConditions.Types.CONDITION_ACTIVITY_NEW_NOTICES })
    XRedPointManager.AddRedPointEvent(self.BtnActivityNotice, self.OnCheckNewActivityNotices, self, { XRedPointConditions.Types.CONDITION_ACTIVITY_NEW_ACTIVITY_NOTICES })
end

function XUiActivityBase:OnGetEvents()
    return { XEventId.EVENT_UIDIALOG_VIEW_ENABLE }
end

function XUiActivityBase:OnNotify(evt, ...)
    if evt == XEventId.EVENT_UIDIALOG_VIEW_ENABLE then
        self:Close()
    end
end

function XUiActivityBase:OnCheckNewGameNotices(count)
    self.BtnGameNotice:ShowReddot(count >= 0)
end

function XUiActivityBase:OnCheckNewActivities(count)
    self.BtnActivity:ShowReddot(count >= 0)
end

function XUiActivityBase:OnCheckNewActivityNotices(count)
    self.BtnActivityNotice:ShowReddot(count >= 0)
end

function XUiActivityBase:OnStart(skipIndex, subSkipIndex)
    local defaultSelectIndex = skipIndex
    self.SubSkipIndex = subSkipIndex

    self.ActivityGroupInfos = XDataCenter.ActivityManager.GetActivityGroupInfos()

    local HaveGameNotice = XDataCenter.NoticeManager.CheckHaveNotice(XUiActivityBase.GameNoticeType.Notice)
    local HaveActivityNotice = XDataCenter.NoticeManager.CheckHaveNotice(XUiActivityBase.GameNoticeType.ActivityNotice)
    local HaveActivity =  next(self.ActivityGroupInfos)

    if HaveActivity then
        defaultSelectIndex = defaultSelectIndex or XUiActivityBase.BtnTabIndex.Activity
    elseif HaveActivityNotice then
        defaultSelectIndex = defaultSelectIndex or XUiActivityBase.BtnTabIndex.ActivityNotice
    else
        defaultSelectIndex = defaultSelectIndex or XUiActivityBase.BtnTabIndex.Notice
    end

    self.BtnGameNotice:SetDisable(not HaveGameNotice)
    self.BtnActivityNotice:SetDisable(not HaveActivityNotice)

    if defaultSelectIndex then
        self.PanelType:SelectIndex(defaultSelectIndex)
    end
end

function XUiActivityBase:InitAutoScript()
    self:AutoAddListener()
end

function XUiActivityBase:AutoAddListener()
    self:RegisterClickEvent(self.BtnBack, self.OnBtnBackClick)
    self:RegisterClickEvent(self.BtnMainUi, self.OnBtnMainUiClick)
end

function XUiActivityBase:OnBtnBackClick(eventData)
    self:Close()
end

function XUiActivityBase:OnBtnMainUiClick(eventData)
    XLuaUiManager.RunMain()
end

function XUiActivityBase:OnClickTabCallBack(tabIndex)
    if self.SelectedIndex and self.SelectedIndex == tabIndex then
        return
    end

    if tabIndex == XUiActivityBase.BtnTabIndex.Activity then
        self:OpenOneChildUi("UiActivityBaseChild", self.ActivityGroupInfos, self.SubSkipIndex)
        self.SubSkipIndex = nil
    elseif tabIndex == XUiActivityBase.BtnTabIndex.Notice then
        if not XDataCenter.NoticeManager.CheckHaveNotice(XUiActivityBase.GameNoticeType.Notice) then
            XUiManager.TipText("NoInGameNotice")
            return
        end

        if not XLuaUiManager.IsUiShow("UiGameNotice") then
            self:OpenOneChildUi("UiGameNotice", self, self.SubSkipIndex, XUiActivityBase.GameNoticeType.Notice)
        else
            CsXGameEventManager.Instance:Notify(XEventId.EVENT_NOTICE_TYPE_CHANAGE, XUiActivityBase.GameNoticeType.Notice)
        end
        self.SubSkipIndex = nil
    elseif tabIndex == XUiActivityBase.BtnTabIndex.ActivityNotice then
        if not XDataCenter.NoticeManager.CheckHaveNotice(XUiActivityBase.GameNoticeType.ActivityNotice) then
            XUiManager.TipText("NoActivities")
            return
        end

        if not XLuaUiManager.IsUiShow("UiGameNotice") then
            self:OpenOneChildUi("UiGameNotice", self, self.SubSkipIndex, XUiActivityBase.GameNoticeType.ActivityNotice)
        else
            CsXGameEventManager.Instance:Notify(XEventId.EVENT_NOTICE_TYPE_CHANAGE, XUiActivityBase.GameNoticeType.ActivityNotice)
        end
        self.SubSkipIndex = nil
    end

    self.SelectedIndex = tabIndex
end