local XUiLoginNotice = XLuaUiManager.Register(XLuaUi, "UiLoginNotice")
local Json = require("XCommon/Json")

function XUiLoginNotice:OnAwake()
    self:InitAutoScript()
end


function XUiLoginNotice:OnStart(loginNotice)

    if not loginNotice or not loginNotice.HtmlUrl then
        return
    end

    local request = CS.XUriPrefixRequest.Get(loginNotice.HtmlUrl)
    CS.XRecord.Record("24030", "LoginNoticeRequestStart")
    CS.XTool.WaitCoroutine(request:SendWebRequest(), function()
        if request.isNetworkError or request.isHttpError then
            local msgTab = {}
            msgTab["error"] = tostring(request.error)
            local jsonstr = Json.encode(msgTab)
            CS.XRecord.Record("24001", "LoginNoticeError",jsonstr)
            return
        end

        if not request.downloadHandler then
            local msgTab = {}
            msgTab["error"] = "request.downloadHandler is nil"
            local jsonstr = Json.encode(msgTab)
            CS.XRecord.Record("24002", "LoginNoticeError",jsonstr)
            return
        end

        local html = request.downloadHandler.text
        CS.XWebView.LoadByHtml(self.PanelWebView.gameObject, html)
        CS.XRecord.Record("24003", "LoginNoticeSuccess")
    end)

    self.TxtTitle.text = loginNotice.Title
end


function XUiLoginNotice:OnEnable()
end


function XUiLoginNotice:OnDisable()
end


function XUiLoginNotice:OnDestroy()
end


function XUiLoginNotice:OnGetEvents()
    return {XEventId.EVENT_UIDIALOG_VIEW_ENABLE}
end


function XUiLoginNotice:OnNotify(evt,...)
    if evt == XEventId.EVENT_UIDIALOG_VIEW_ENABLE then
        self:Close()
    end
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiLoginNotice:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiLoginNotice:AutoInitUi()
    self.PanelWebView = self.Transform:Find("Animator/SafeAreaContentPane/PanelWebView")
    self.TxtTitle = self.Transform:Find("Animator/SafeAreaContentPane/TxtTitle"):GetComponent("Text")
    self.BtnClose = self.Transform:Find("Animator/SafeAreaContentPane/BtnClose"):GetComponent("Button")
    self.TxtClose = self.Transform:Find("Animator/SafeAreaContentPane/BtnClose/TxtClose"):GetComponent("Text")
end

function XUiLoginNotice:AutoAddListener()
    self:RegisterClickEvent(self.BtnClose, self.OnBtnCloseClick)
end
-- auto

function XUiLoginNotice:OnBtnCloseClick(eventData)
    self:Close()
end
