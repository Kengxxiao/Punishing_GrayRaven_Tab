local next = next
local tableInsert = table.insert

local TagTextPrefix = "NoticeTag"

local HtmlMap = {}

local BTN_INDEX = {
    First = 1,
    Second = 2,
}

local XUiGameNotice = XLuaUiManager.Register(XLuaUi, "UiGameNotice")

function XUiGameNotice:OnStart(rootUi, selectIdx, type)
    self.RootUi = rootUi
    self.HttpTextures = {}
    self.HtmlIndexDic = {}
    self.TabBtns = {}
    self.RequestMap = {}
    self.Type = type
end

function XUiGameNotice:OnDisable()
    self.CurUrl = nil
    if self.WebViewPanel then
        CS.UnityEngine.Object.DestroyImmediate(self.WebViewPanel.gameObject)
        self.WebViewPanel = nil
    end

    self:ClearTabBtns()
end

function XUiGameNotice:OnEnable()
    self:UpdateLeftTabBtns(nil, self.Type)
    self:OnSelectedTog()
end

function XUiGameNotice:OnDestroy()
    for index, httpTexture in pairs(self.HttpTextures) do
        if httpTexture:Exist() then
            CS.UnityEngine.Object.Destroy(httpTexture)
            self.HttpTextures[index] = nil
        end
    end
end

function XUiGameNotice:OnGetEvents()
    return { XEventId.EVENT_UIDIALOG_VIEW_ENABLE, XEventId.EVENT_NOTICE_TYPE_CHANAGE }
end

function XUiGameNotice:OnNotify(evt, ...)
    if evt == XEventId.EVENT_UIDIALOG_VIEW_ENABLE then
        self.RootUi:Close()
    elseif evt == XEventId.EVENT_NOTICE_TYPE_CHANAGE then
        local arg = {...}
        self:UpdateLeftTabBtns(nil, arg[1])
        self:OnSelectedTog()
    end
end

function XUiGameNotice:GetCertainBtnModel(index, hasChild, pos, totalNum)
    if index == BTN_INDEX.First then
        if hasChild then
            return self.BtnFirstHasSnd
        else
            return self.BtnFirst
        end
    elseif index == BTN_INDEX.Second then
        if totalNum == 1 then
           return self.BtnSecondAll 
        end

        if pos == 1 then
            return self.BtnSecondTop
        elseif pos == totalNum then
            return self.BtnSecondBottom
        else
            return self.BtnSecond
        end
    end
end

function XUiGameNotice:ClearTabBtns()
    if not self.TabBtns then
        return
    end

    for _, v in pairs(self.TabBtns) do
        CS.UnityEngine.GameObject.Destroy(v.gameObject)
    end

    self.TabBtns = {}
end

function XUiGameNotice:UpdateLeftTabBtns(selectIdx, type)
    self.NoticeMap = XDataCenter.NoticeManager.GetInGameNoticeMap(type)
    local noticeInfos = self.NoticeMap
    if not noticeInfos then return end

    self:ClearTabBtns()
    local btnIndex = 0
    local firstRedPointIndex

    --一级标题
    for groupIndex, data in ipairs(noticeInfos) do
        local htmlList = data.Content
        local totalNum = #htmlList

        local btnModel = self:GetCertainBtnModel(BTN_INDEX.First, totalNum > 1)
        local btn = CS.UnityEngine.Object.Instantiate(btnModel)
        btn.transform:SetParent(self.PanelNoticeTitleBtnGroup.transform, false)
        btn.gameObject:SetActiveEx(true)
        btn:SetName(data.Title)

        if not data.Tag or data.Tag == 0 then
            btn:ShowTag(false)
        else
            local txtTag = btn.transform:Find("Tag/ImgTag/Text"):GetComponent("Text")
            txtTag.text = CS.XTextManager.GetText(TagTextPrefix .. data.Tag)
            btn:ShowTag(true)
        end

        local uiButton = btn:GetComponent("XUiButton")
        tableInsert(self.TabBtns, uiButton)
        btnIndex = btnIndex + 1

        --二级标题
        local needRedPoint = false
        local firstIndex = btnIndex
        local onlyOne = totalNum == 1
        for htmlIndex, htmlCfg in ipairs(htmlList) do
            needRedPoint = XDataCenter.NoticeManager.CheckHasRedPoint(data, htmlIndex)
            if needRedPoint and not firstRedPointIndex then
                firstRedPointIndex = btnIndex
            end
            if not onlyOne then
                local btnModel = self:GetCertainBtnModel(BTN_INDEX.Second, nil, htmlIndex, totalNum)
                local btn = CS.UnityEngine.Object.Instantiate(btnModel)
                btn:SetName(htmlCfg.Title)
                btn.transform:SetParent(self.PanelNoticeTitleBtnGroup.transform, false)

                local uiButton = btn:GetComponent("XUiButton")
                uiButton.SubGroupIndex = firstIndex
                tableInsert(self.TabBtns, uiButton)
                btnIndex = btnIndex + 1

                if needRedPoint then
                    uiButton:ShowReddot(true)
                else
                    uiButton:ShowReddot(false)
                end
            end

            local indexInfo = {
                HtmlReadKey = XDataCenter.NoticeManager.GetGameNoticeReadDataKey(data, htmlIndex),
                HtmlUrl = htmlCfg.Url,
                HtmlUrlSlave = htmlCfg.UrlSlave,
                GroupIndex = groupIndex
            }
            self.HtmlIndexDic[btnIndex] = indexInfo
        end

        uiButton:ShowReddot(needRedPoint)
    end

    local selectIndex = selectIdx or firstRedPointIndex or 1
    self.PanelNoticeTitleBtnGroup:Init(self.TabBtns, function(index) self:OnSelectedTog(index) end)
    self.PanelNoticeTitleBtnGroup:SelectIndex(selectIndex, false)
    self.SelectIndex = selectIndex
end

function XUiGameNotice:OnSelectedTog(index)
    if self.SelectIndex and self.SelectIndex == index then return end
    index = index or self.SelectIndex
    self.SelectIndex = index

    local indexInfo = self.HtmlIndexDic[index]
    if not indexInfo or not next(indexInfo) then
        return
    end

    --刷新右边UI
    self:UpdateWebView(indexInfo.HtmlUrl)

    --取消小红点
    XDataCenter.NoticeManager.ChangeInGameNoticeReadStatus(indexInfo.HtmlReadKey, true)
    local uiButton = self.TabBtns[index]
    uiButton:ShowReddot(false)

    --判断一级按钮小红点
    local subGroupIndex = uiButton.SubGroupIndex
    if subGroupIndex and self.TabBtns[subGroupIndex] then
        local needRed = false
        for _, btn in pairs(self.TabBtns) do
            if btn.SubGroupIndex and btn.SubGroupIndex == subGroupIndex
            and btn.ReddotObj.activeSelf then
                needRed = true
                break
            end
        end
        if not needRed then
            self.TabBtns[subGroupIndex]:ShowReddot(false)
        end
    end
end

function XUiGameNotice:ShowHtml()
    CS.XTool.WaitNativeCoroutine(CS.UnityEngine.WaitForEndOfFrame(), function()
        if self.WebViewPanel then
            CS.UnityEngine.Object.DestroyImmediate(self.WebViewPanel.gameObject)
            self.WebViewPanel = nil
        end

        if XTool.UObjIsNil(self.PanelWebView) then
            return
        end

        local html = HtmlMap[self.CurUrl]
        if not html then
            return
        end

        self.WebViewPanel = CS.UnityEngine.Object.Instantiate(self.PanelWebView, self.PanelWebView.parent)
        CS.XWebView.LoadByHtml(self.WebViewPanel.gameObject, html)
    end)
end

function XUiGameNotice:UpdateWebView(url)
    if self.CurUrl == url then
        return
    end

    self.CurUrl = url

    if HtmlMap[url] then
        self:ShowHtml()
        return
    end

    local request = CS.XUriPrefixRequest.Get(url)
    self.RequestMap[request] = url

    CS.XTool.WaitCoroutine(request:SendWebRequest(), function()
        if request.isNetworkError or request.isHttpError then
            return
        end

        local requestUrl = self.RequestMap[request]
        HtmlMap[requestUrl] = request.downloadHandler.text

        self:ShowHtml()

        self.RequestMap[request] = nil
        request:Dispose()
    end)

end
