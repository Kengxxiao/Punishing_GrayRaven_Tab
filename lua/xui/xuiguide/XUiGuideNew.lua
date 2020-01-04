local XUiGuideNew = XLuaUiManager.Register(XLuaUi, "UiGuide")

function XUiGuideNew:OnAwake()
    self:AutoAddListener()
    self.PanelInfoRect = self.PanelInfo
    self.PanelWarning.gameObject:SetActive(false)
    self.BtnSkip.gameObject:SetActive(false)
    self.BtnPass.gameObject:SetActive(false)
    self.PanelInfo.gameObject:SetActive(false)

    self.LastClickTime = 0
    self.ContinueClickTimes = 0
    self.ClickInterval = 0.5
end

function XUiGuideNew:OnStart(targetImg, isWeakGuide, guideDesc, icon, name, callback, guideStep)

    self.Guide = self.BtnPanelMaskGuide:GetComponent("XGuide")
    if (not self.Guide) then
        self.Guide = self.BtnPanelMaskGuide.gameObject:AddComponent(typeof(CS.XGuide))
    end
    self.Guide:SetPass(false)
    self.Guide:SetTimeText(self.TxtTime)

    self.Callback = callback
    self.IsWeakGuide = isWeakGuide
    if targetImg then
        CS.XGuideEventPass.IsFightGuide = true

        self:ShowMark(true, true)
        self:ShowDialog(icon, name, guideDesc, 0)
        self:FocuOnFightPanel(targetImg)
    end

    CsXGameEventManager.Instance:RegisterEvent(CS.XEventId.EVENT_GUIDE_FIGHT_BTNDOWN, function(evt, args)
        if self.Callback and not self.IsWeakGuide then
            self.Callback()
            self.Callback = nil
        end
    end)

end

function XUiGuideNew:OnDestroy()
    CsXGameEventManager.Instance:RemoveEvent(XEventId.EVENT_GUIDE_FIGHT_BTNDOWN, function(evt, args)
        if self.Callback and not self.IsWeakGuide then
            self.Callback()
            self.Callback = nil
        end
    end)
end


-- auto
-- Automatic generation of code, forbid to edit
function XUiGuideNew:InitAutoScript()
    self:AutoInitUi()
end

function XUiGuideNew:AutoInitUi()
    self.PanelMaskAll = self.Transform:Find("FullScreenBackground/PanelMaskAll")
    self.BtnPanelMaskGuide = self.Transform:Find("FullScreenBackground/BtnPanelMaskGuide"):GetComponent("Button")
    self.BtnPass = self.Transform:Find("FullScreenBackground/BtnPanelMaskGuide/BtnPass"):GetComponent("Button")
    self.PanelInfo = self.Transform:Find("FullScreenBackground/BtnPanelMaskGuide/PanelInfo")
    self.PanelHead = self.Transform:Find("FullScreenBackground/BtnPanelMaskGuide/PanelInfo/PanelHead")
    self.ImgRole = self.Transform:Find("FullScreenBackground/BtnPanelMaskGuide/PanelInfo/PanelHead/FxUiguide005/ImgRole"):GetComponent("Image")
    self.PanelTime = self.Transform:Find("FullScreenBackground/BtnPanelMaskGuide/PanelInfo/PanelHead/PanelTime")
    self.TxtTime = self.Transform:Find("FullScreenBackground/BtnPanelMaskGuide/PanelInfo/PanelHead/PanelTime/TxtTime"):GetComponent("Text")
    self.PanelTxt = self.Transform:Find("FullScreenBackground/BtnPanelMaskGuide/PanelInfo/PanelTxt")
    self.TxtName = self.Transform:Find("FullScreenBackground/BtnPanelMaskGuide/PanelInfo/PanelTxt/TxtName"):GetComponent("Text")
    self.TxtDesc = self.Transform:Find("FullScreenBackground/BtnPanelMaskGuide/PanelInfo/PanelTxt/TxtDesc"):GetComponent("Text")
    self.PanelBtn = self.Transform:Find("SafeAreaContentPane/PanelBtn")
    self.BtnSkip = self.Transform:Find("SafeAreaContentPane/PanelBtn/BtnSkip"):GetComponent("Button")
    self.PanelWarning = self.Transform:Find("SafeAreaContentPane/PanelWarning")
    self.BtnConfrim = self.Transform:Find("SafeAreaContentPane/PanelWarning/BtnConfrim"):GetComponent("Button")
    self.BtnCancel = self.Transform:Find("SafeAreaContentPane/PanelWarning/BtnCancel"):GetComponent("Button")
end

function XUiGuideNew:AutoAddListener()
    self:RegisterClickEvent(self.BtnPanelMaskGuide, self.OnBtnPanelMaskGuideClick)
    self:RegisterClickEvent(self.BtnPass, self.OnBtnPassClick)
    self:RegisterClickEvent(self.BtnSkip, self.OnBtnSkipClick)
    self:RegisterClickEvent(self.BtnConfrim, self.OnBtnConfrimClick)
    self:RegisterClickEvent(self.BtnCancel, self.OnBtnCancelClick)
end
-- auto
function XUiGuideNew:OnBtnSkipClick(...)
    self.PanelWarning.gameObject:SetActive(true)
end

function XUiGuideNew:OnBtnConfrimClick(...)
    XDataCenter.GuideManager.ReqCompleteGuideGroup(function()
        XDataCenter.GuideManager.ResetGuide()
        XEventManager.DispatchEvent(XEventId.EVENT_FUNCTION_EVENT_COMPLETE)
    end)
end

function XUiGuideNew:CheckDouble()
    if XTime.Now() - self.LastClickTime > self.ClickInterval then
        self.ContinueClickTimes = 0
    else
        self.ContinueClickTimes = self.ContinueClickTimes + 1
    end

    if self.ContinueClickTimes == 3 then
        self.ContinueClickTimes = 0
        self.BtnSkip.gameObject:SetActive(true)
    end

    self.LastClickTime = XTime.Now()
end

function XUiGuideNew:OnBtnCancelClick(...)
    self.PanelWarning.gameObject:SetActive(false)
end

function XUiGuideNew:OnBtnPassClick(...)
    self.Guide:Reset()

    if self.Callback and not self.IsWeakGuide then
        self.Callback()
        self.Callback = nil
    end
end

function XUiGuideNew:OnBtnPanelMaskGuideClick(pointerEventData)
    if not XDataCenter.GuideManager.CheckIsFightGuide() and not CS.XGuideEventPass.IsFightGuide then
        self:CheckDouble()
    end

    CsXGameEventManager.Instance:Notify(CS.XEventId.EVENT_GUIDE_ANYCLICK)
end

--显示头像
function XUiGuideNew:ShowDialog(icon, name, content, pos)
    self.PanelInfo.gameObject:SetActive(true)
    self:SetUiSprite(self.ImgRole, icon)
    self.TxtName.text = name or ""
    self.TxtDesc.text = content

    if pos == 0 then
        self.PanelInfoRect.anchorMax = CS.UnityEngine.Vector2(0, 1)
        self.PanelInfoRect.anchorMin = CS.UnityEngine.Vector2(0, 1)
        self.PanelInfoRect.anchoredPosition = CS.UnityEngine.Vector2(500, -380)
    else
        self.PanelInfoRect.anchorMax = CS.UnityEngine.Vector2(1, 1)
        self.PanelInfoRect.anchorMin = CS.UnityEngine.Vector2(1, 1)
        self.PanelInfoRect.anchoredPosition = CS.UnityEngine.Vector2(-500, -380)
    end
end

--隐藏头像
function XUiGuideNew:HideDialog()
    self.PanelInfo.gameObject:SetActive(false)
end

--聚焦panel
function XUiGuideNew:FocuOnPanel(panel, eulerAngles, passEvent)
    eulerAngles = eulerAngles or CS.UnityEngine.Vector3.zero
    self.BtnPass.gameObject:SetActive(true)
    self.BtnPass.gameObject.transform.eulerAngles = eulerAngles
    self.Guide:SetTarget(panel)

    if not XTool.UObjIsNil(panel.gameObject) then
        CS.XGuideEventPass.Target = panel.gameObject
    end

    CS.XGuideEventPass.IsPassEvent = passEvent
    if self.AniGuideJiaoLoop then
        self.AniGuideJiaoLoop.gameObject:SetActive(false)
        self.AniGuideJiaoLoop.gameObject:SetActive(true)
    end
end

function XUiGuideNew:FocuOnFightPanel(panel)
    self.BtnPass.gameObject:SetActive(true)
    self.Guide:SetTarget(panel)
    CS.XGuideEventPass.Target = nil
end

--显示遮罩
function XUiGuideNew:ShowMark(isShowMask, isBlockRaycast)
    self.PanelMaskAll.gameObject:SetActive(isShowMask)
    self.BtnPanelMaskGuide.gameObject:SetActive(true)
    self.Guide:SetPass(not isShowMask)
end