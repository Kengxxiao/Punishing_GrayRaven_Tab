local XUiNoticeTips = XLuaUiManager.Register(XLuaUi, "UiNoticeTips")

local MoveSpeed = 100
local TextReservedWidth = 60
local HideIntervalTime = 3
local WaitTime = 3

function XUiNoticeTips:OnAwake()
    self:InitAutoScript()

    if not self.behaviour then
        self.behaviour = self.Transform.gameObject:AddComponent(typeof(CS.XLuaBehaviour))
        self.behaviour.LuaUpdate = function()
            if self.Update then
                self:Update()
            end
        end
    end
end

function XUiNoticeTips:OnStart()
    self:RefreshNoticeContent()

    self.TxtNoticeWidth = XUiHelper.CalcTextWidth(self.TxtNotice)
    self.PanelNoticeRect = self.PanelNotice.gameObject:GetComponent("RectTransform")
    self.PauseTime = 0
end

function XUiNoticeTips:RefreshNoticeContent()
    local noticeContent = XDataCenter.NoticeManager.GetTextNoticeContent()
    if not noticeContent then
        return
    end
    self.TxtNotice.text = noticeContent
end

function XUiNoticeTips:OnNotify(evt, ...)
    if evt == XEventId.EVENT_USER_LOGOUT then
        self:Close()
    elseif evt == XEventId.EVENT_NOTICE_CLOSE_TEXT_NOTICE then
        self:Close()
    end
end

function XUiNoticeTips:OnGetEvents()
    return {XEventId.EVENT_NOTICE_CLOSE_TEXT_NOTICE, XEventId.EVENT_USER_LOGOUT}
end

function XUiNoticeTips:GetEndPos()
    if self.EndPos then
        return self.EndPos
    end

    self.EndPos = CS.UnityEngine.Vector3((-self.PanelNoticeRect.sizeDelta.x / 2 - self.TxtNoticeWidth / 2), 0, 0)

    return self.EndPos
end

function XUiNoticeTips:GetBeginPos()
    local BeginPos
    if self.TxtNoticeWidth > self.PanelNoticeRect.sizeDelta.x then
        BeginPos = CS.UnityEngine.Vector3((self.TxtNoticeWidth - self.PanelNoticeRect.sizeDelta.x) / 2 + TextReservedWidth, 0, 0)
    else
        BeginPos = CS.UnityEngine.Vector3(0, 0, 0)
    end
    return BeginPos
end

function XUiNoticeTips:ResetTxtNoticePos()
    if not self.NeedReset then
        return false
    end

    XDataCenter.NoticeManager.AddTextNoticeCount()

    if not XDataCenter.NoticeManager.CheckTextNoticeInvalid() then
        return true
    end

    self:SetBgActive(true)

    self.TxtNotice.transform.localPosition = self:GetBeginPos()
    self.WaitTime = 0
    self.NeedReset = false

    self:RefreshNoticeContent()

    return false
end

function XUiNoticeTips:OnEnable()
    self.NeedReset = true
    self.IsInit = true

    if self:ResetTxtNoticePos() then
        self:Close()
    end
end

function XUiNoticeTips:Update()
    if not self.IsInit then
        return
    end

    if self:ResetTxtNoticePos() then
        self:Close()
        return
    end

    if XTool.UObjIsNil(self.TxtNotice) then
        self:Close()
        return
    end

    local timeInterval = CS.UnityEngine.Time.deltaTime
    if self.TxtNotice.transform.localPosition.x <= self:GetEndPos().x then
        if HideIntervalTime <= XDataCenter.NoticeManager.GetTextNoticeScrollInterval() then
            self:SetBgActive(false)
        end
        if self.PauseTime < XDataCenter.NoticeManager.GetTextNoticeScrollInterval() then
            self.PauseTime = self.PauseTime + timeInterval
            return
        end

        self.NeedReset = true
        self.PauseTime = 0
    end

    -- 公告刚出来静止一定时间再开始滚动
    if self.WaitTime < WaitTime then
        self.WaitTime = self.WaitTime + timeInterval
        return
    end

    self.TxtNotice.transform.localPosition = self.TxtNotice.transform.localPosition - CS.UnityEngine.Vector3(timeInterval * MoveSpeed, 0, 0)
end

function XUiNoticeTips:SetBgActive(flag)
    self.ImgBg.gameObject:SetActive(flag)
    self.BtnClose.gameObject:SetActive(flag)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiNoticeTips:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiNoticeTips:AutoInitUi()
    self.PanelNotice = self.Transform:Find("SafeAreaContentPane/PanelNotice")
    self.TxtNotice = self.Transform:Find("SafeAreaContentPane/PanelNotice/TxtNotice"):GetComponent("Text")
    self.ImgBg = self.Transform:Find("SafeAreaContentPane/ImgBg"):GetComponent("Image")
    self.BtnClose = self.Transform:Find("SafeAreaContentPane/BtnClose"):GetComponent("XUiButton")
end

function XUiNoticeTips:AutoAddListener()
    self.BtnClose.CallBack = function() self:OnBtnCloseClick() end
end
-- auto

function XUiNoticeTips:OnBtnCloseClick()
    XDataCenter.NoticeManager.ChangeTextNoticeHideCache()
    if XDataCenter.NoticeManager.CheckTextNoticeHideCache() then
        return
    end

    self:Close()
end

function XUiNoticeTips:OnDestroy()
    if not XTool.UObjIsNil(self.behaviour) then
        CS.UnityEngine.GameObject.Destroy(self.behaviour)
    end

    self.behaviour = nil
end
