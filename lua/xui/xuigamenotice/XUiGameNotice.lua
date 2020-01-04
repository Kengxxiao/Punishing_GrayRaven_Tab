local next = next
local tableInsert = table.insert

local TagTextPrefix = "NoticeTag"
local HtmlContent = {}
local XUiGameNotice = XLuaUiManager.Register(XLuaUi, "UiGameNotice")

function XUiGameNotice:OnStart(rootUi, selectIdx, type)
    self.RootUi = rootUi
    self.HttpTextures = {}
    self.HtmlIndexDic = {}
    self.TabBtns = {}
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

    self.BtnFirst.gameObject:SetActive(true)
    self.BtnSecond.gameObject:SetActive(true)

    --一级标题
    for groupIndex, data in ipairs(noticeInfos) do
        local btn = CS.UnityEngine.Object.Instantiate(self.BtnFirst)
        btn.transform:SetParent(self.PanelNoticeTitleBtnGroup.transform, false)
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
        local htmlList = data.Content
        local onlyOne = #htmlList == 1
        for htmlIndex, htmlCfg in ipairs(htmlList) do
            needRedPoint = XDataCenter.NoticeManager.CheckHasRedPoint(data, htmlIndex)
            if needRedPoint and not firstRedPointIndex then
                firstRedPointIndex = btnIndex
            end
            if not onlyOne then
                local btn = CS.UnityEngine.Object.Instantiate(self.BtnSecond)
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
    self.BtnSecond.gameObject:SetActive(false)
    self.BtnFirst.gameObject:SetActive(false)

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
    self:UpdateWebView(indexInfo.HtmlUrl, indexInfo.HtmlUrlSlave)

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

function XUiGameNotice:ShowHtml(html)
    if self.WebViewPanel then
        CS.UnityEngine.Object.DestroyImmediate(self.WebViewPanel.gameObject)
        self.WebViewPanel = nil
    end

    if XTool.UObjIsNil(self.PanelWebView) then
        return
    end

    self.WebViewPanel = CS.UnityEngine.Object.Instantiate(self.PanelWebView, self.PanelWebView.parent)
    CS.XWebView.LoadByHtml(self.WebViewPanel.gameObject, html)
end

function XUiGameNotice:UpdateWebView(url, urlSlave)
    if self.CurUrl == url then
        return
    end
    self.CurUrl = url

    local htmlCache = HtmlContent[self.CurUrl]

    if htmlCache then
        self:ShowHtml(htmlCache)
        return
    end

    local request = CS.XUriPrefixRequest.Get(self.CurUrl)
    CS.XTool.WaitCoroutine(request:SendWebRequest(), function()
        if request.isNetworkError or request.isHttpError then
            return
        end

        local html = request.downloadHandler.text
        if not self.CurUrl or not HtmlContent then
            return
        end
        
        HtmlContent[self.CurUrl] = html
        CS.XTool.WaitNativeCoroutine(CS.UnityEngine.WaitForEndOfFrame(), function()
            self:ShowHtml(html)
            request:Dispose()
        end)
    end)
end
