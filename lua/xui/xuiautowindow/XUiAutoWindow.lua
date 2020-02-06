local XUiAutoWindow = XLuaUiManager.Register(XLuaUi, "UiAutoWindow")

function XUiAutoWindow:OnAwake()
    self:AddListener()
end

function XUiAutoWindow:OnStart(configId)
    self:SetInfo(configId)
end

function XUiAutoWindow:AddListener()
    self:RegisterClickEvent(self.BtnBack, self.OnBtnCloseClick)
    self:RegisterClickEvent(self.BtnGoto, self.OnBtnSkipClick)
end

function XUiAutoWindow:OnBtnCloseClick()
    self:Close()
    XDataCenter.AutoWindowManager.NextAutoWindow()
end

function XUiAutoWindow:OnBtnSkipClick()
    if self.ActiveOver then
        XUiManager.TipText("ActivityAlreadyOver")
        return
    end

    if self.Config.SkipURL and self.Config.SkipURL ~= nil then 
        CS.UnityEngine.Application.OpenURL(self.Config.SkipURL)
    elseif self.Config.SkipId and self.Config.SkipId ~= nil then
        XFunctionManager.SkipInterface(self.Config.SkipId)
    end

    XDataCenter.AutoWindowManager.StopAutoWindow()
    self:Close()
end

function XUiAutoWindow:SetInfo(configId) 
    self.Config = XAutoWindowConfigs.GetAutoWindowConfig(configId)
    self.RImgCharacterBig:SetRawImage(self.Config.CharacterIcon)
    self.RImgBg:SetRawImage(self.Config.BgIcon)

    local now = XTime.GetServerNowTimestamp()
    if now > self.Config.OpenTime and now <= self.Config.CloseTime then
        self:SetOpenInfo()
    elseif now <= self.Config.OpenTime then
        self:SetCloseInfo(now) 
    elseif now > self.Config.CloseTime then
        self:SetOverInfo(now) 
    end
end

-- 处理活动中
function XUiAutoWindow:SetOpenInfo()
    self.PanelNotOpen.gameObject:SetActive(false)
    self.PanelOpen.gameObject:SetActive(true)
    
    self.TxtOpenTitle.text = self.Config.OpenTitle
    self.TxtOpenTime.text = self.Config.OpenDesc
    local scale = (self.Config.SkipURL == nil and self.Config.SkipId <= 0) and CS.UnityEngine.Vector3.zero or CS.UnityEngine.Vector3.one
    self.BtnGoto.gameObject.transform.localScale = scale
end

-- 处理尚未开启活动
function XUiAutoWindow:SetCloseInfo(now)
    self.PanelNotOpen.gameObject:SetActive(true)
    self.PanelOpen.gameObject:SetActive(false)

    self.TxtTitle.text = self.Config.CloseTitle
    local format = "MM/dd"
    self.TxtOpenDay.text = XTime.TimestampToGameDateTimeString(self.Config.OpenTime, format)
    local leftTime = self.Config.OpenTime - now
    self.TxtLeftTime.text = XUiHelper.GetTime(leftTime, XUiHelper.TimeFormatType.CHALLENGE)
end

-- 处理活动结束
function XUiAutoWindow:SetOverInfo()
    self.ActiveOver = true
    self:SetOpenInfo()
end