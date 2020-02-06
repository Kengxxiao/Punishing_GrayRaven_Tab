--local XUiGuide = XLuaUiManager.Register(XLuaUi, "UiGuide", CsXUiType.Guide, CsXUiResType.Bundle, false)
local XUiGuide = {}
function XUiGuide:OnAwake()
    self:InitAutoScript()
    self.PanelInfoRect = self.PanelInfo.gameObject:GetComponent("RectTransform")
end

function XUiGuide:OnEnable()
   -- CsXUguiEventListener.GuideHandle = Handler(self,self.GuideHandle)
end


function XUiGuide:OnDisable()
   -- CsXUguiEventListener.GuideHandle = nil
end

function XUiGuide:GuideHandle(pointerEventData)
    -- if self.TargetImg and self.TargetImg.gameObject == pointerEventData.selectedObject then
    --  --   self:OnBtnPassClick()
    --     return true
    -- elseif self.TargetImg and self.TargetImg.gameObject ~= pointerEventData.selectedObject then
    --     XLog.Debug(" XUiGuide:GuideHandle : ".. pointerEventData.selectedObject.name)
    -- --    self:OnBtnPassClick()
    --     return false
    -- end

    -- self:OnBtnPassClick()
    -- XLog.Debug(" XUiGuide:GuideHandle : ".. pointerEventData.selectedObject.name)

    return true
end

function XUiGuide:OnStart(targetImg, isWeakGuide, guideDesc, icon, name, callback, guideStep)
    XEventManager.AddEventListener(XEventId.EVENT_GUIDE_REQ_OPEN_SUCCESS, self.HandlerReqOpenGuideSuccess, self)

    self.Guide = self.BtnPanelMaskGuide:GetComponent("XGuide")
    if (not self.Guide) then
        self.Guide = self.BtnPanelMaskGuide.gameObject:AddComponent(typeof(CS.XGuide))
    end

    self:SetupContent(targetImg, isWeakGuide, guideDesc, icon, name, callback, guideStep)
end

function XUiGuide:SetupContent(targetImg, isWeakGuide, guideDesc, icon, name, callback, guideStep)
    self.PanelMaskAll.gameObject:SetActive(XDataCenter.GuideManager.CheckIsReqOpenGuide())
    self.BtnPanelMaskGuide.gameObject:SetActive(true)
    self.PanelHead.gameObject:SetActive(false)

    self.GuideStep = nil
    self.TargetImg = targetImg
    self.IsWeakGuide = isWeakGuide
    self.GuideText = guideDesc
    self.Icon = icon
    self.CharName = name
    self.Callback = callback

    self:SetPanel()

    if (guideStep) then
        self.GuideStep = guideStep
        local findTargetFunc = function(target)
            self.TargetImg = target
            self.IsWeakGuide = isWeakGuide
            self.GuideText = guideDesc
            self.Icon = icon
            self.CharName = name
            self.Callback = callback
            self:SetPanel()
        end
        XDataCenter.GuideManager.GetGuideTarget(guideStep, findTargetFunc)
    end
    self.PanelWarning.gameObject:SetActive(false)
    self.BtnSkip.gameObject:SetActive(false)

    self.LastClickTime = 0
    self.ContinueClickTimes = 0
    self.ClickInterval = 0.5
end

function XUiGuide:HandlerReqOpenGuideSuccess(isReq)
    self.PanelMaskAll.gameObject:SetActive(isReq)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiGuide:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiGuide:AutoInitUi()
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

function XUiGuide:AutoAddListener()
    self:RegisterClickEvent(self.BtnPanelMaskGuide, self.OnBtnPanelMaskGuideClick)
    self:RegisterClickEvent(self.BtnPass, self.OnBtnPassClick)
    self:RegisterClickEvent(self.BtnSkip, self.OnBtnSkipClick)
    self:RegisterClickEvent(self.BtnConfrim, self.OnBtnConfrimClick)
    self:RegisterClickEvent(self.BtnCancel, self.OnBtnCancelClick)
end
-- auto

function XUiGuide:OnBtnSkipClick(...)
    self.PanelWarning.gameObject:SetActive(true)
end

function XUiGuide:OnBtnConfrimClick(...)
    XDataCenter.GuideManager.TriggerGuide(0)
    self.PanelWarning.gameObject:SetActive(false)
end

function XUiGuide:OnBtnCancelClick(...)
    self.PanelWarning.gameObject:SetActive(false)
end

function XUiGuide:OnBtnPassClick(...)
    if (self.Callback) then
        self.Callback()
    end
end

function XUiGuide:OnBtnPanelMaskGuideClick(...)
    if (self.IsWeakGuide) then
        --CS.XUiManager.GuideManager:Pop()
        self:Close()
    else
        -- 强引导，无目标，点击关闭，进入下一步
        if ((not self.GuideStep and self.TargetImg == nil) or
                (self.GuideStep and #self.GuideStep.Target <= 0)) then
            self:OnBtnPassClick()
        end

        if not XDataCenter.GuideManager.CheckIsFightGuide() then
            self:CheckDouble()
        end
    end
end

function XUiGuide:CheckDouble()
    if XTime.GetServerNowTimestamp() - self.LastClickTime > self.ClickInterval then
        self.ContinueClickTimes = 0
    else
        self.ContinueClickTimes = self.ContinueClickTimes + 1
    end

    if self.ContinueClickTimes == 2 then
        self.ContinueClickTimes = 0
        self.BtnSkip.gameObject:SetActive(true)
    end

    self.LastClickTime = XTime.GetServerNowTimestamp()
end

function XUiGuide:SetPanel()
    --self.IsWeakGuide --= self.GuideStep.Mask == 0
    self.Guide:SetPass(self.IsWeakGuide)
    self.Guide:SetTarget(self.TargetImg)
    self.Guide:SetTimeText(self.TxtTime)
    self.BtnPass.gameObject:SetActive(self.TargetImg ~= nil)

    if (self.Icon ~= nil and self.Icon ~= "") then
        self.PanelHead.gameObject:SetActive(true)
        self:SetUiSprite(self.ImgRole, self.Icon)
    else
        self.PanelHead.gameObject:SetActive(false)
    end

    if (self.GuideText == nil or self.GuideText == "") then
        self.PanelTxt.gameObject:SetActive(false)
        self.PanelHead.gameObject:SetActive(false)
    else
        self.PanelTxt.gameObject:SetActive(true)
        self.TxtName.text = self.CharName or ""
        self.TxtDesc.text = self.GuideText
    end

    if self.GuideStep then
        if self.GuideStep.IconPos == 0 then
            self.PanelInfoRect.anchorMax = CS.UnityEngine.Vector2(0, 1) 
            self.PanelInfoRect.anchorMin = CS.UnityEngine.Vector2(0, 1) 
            self.PanelInfoRect.anchoredPosition =  CS.UnityEngine.Vector2(500,-380) 
        else
            self.PanelInfoRect.anchorMax = CS.UnityEngine.Vector2(1, 1) 
            self.PanelInfoRect.anchorMin = CS.UnityEngine.Vector2(1, 1) 
            self.PanelInfoRect.anchoredPosition =  CS.UnityEngine.Vector2(-500,-380) 
        end
    end
end

function XUiGuide:HideArrow()
    for _, arrow in ipairs(self.ArrowList) do
        arrow.gameObject:SetActive(false)
    end
end

function XUiGuide:ShowArrow(index)
    self:HideArrow()
    if (index >= 1 and index <= 4) then
        self.ArrowList[index].gameObject:SetActive(true)
    end
end

function XUiGuide:OnDestroy()
    XEventManager.RemoveEventListener(XEventId.EVENT_GUIDE_REQ_OPEN_SUCCESS, self.HandlerReqOpenGuideSuccess, self)
    XTipManager.Execute()
end

function XUiGuide:OnDisable()
    XEventManager.RemoveEventListener(XEventId.EVENT_GUIDE_REQ_OPEN_SUCCESS, self.HandlerReqOpenGuideSuccess, self)
    XTipManager.Execute()
end