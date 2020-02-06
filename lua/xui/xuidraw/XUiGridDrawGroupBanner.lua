local XUiGridDrawGroupBanner = XClass()

function XUiGridDrawGroupBanner:Ctor(ui, info, father)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Info = info
    self.NeedCountDown = false
    self.UiDrawMain = father
    self:InitAutoScript()
    self:SetUpCountDown()
    self:SetUpBottomTimes()
    self:SetUpTransformBtn()
    self:SetNewHandHint()
end
function XUiGridDrawGroupBanner:SetNewHandHint()
    if self.Info.Type == XDataCenter.DrawManager.DrawEventType.NewHand then
        if self.Info.MaxBottomTimes == XDataCenter.DrawManager.GetDrawGroupRule(self.Info.Id).NewHandBottomCount then
            self:ShowPanelNewHand(true)
        else
            self:ShowPanelNewHand(false)
        end
    else
        self:ShowPanelNewHand(false)
    end
end
-- auto
-- Automatic generation of code, forbid to edit
function XUiGridDrawGroupBanner:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiGridDrawGroupBanner:AutoInitUi()
    self.BtnClick = XUiHelper.TryGetComponent(self.Transform, "BtnClick", "Button")
    self.BtnTransform = XUiHelper.TryGetComponent(self.Transform, "BtnTransform", "Button")
    self.PanelNewHand = self.Transform:Find("PanelNewHand")
end

function XUiGridDrawGroupBanner:GetAutoKey(uiNode, eventName)
    if not uiNode then
        return
    end
    return eventName .. uiNode:GetHashCode()
end

function XUiGridDrawGroupBanner:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then
        return
    end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiGridDrawGroupBanner:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiGridDrawGroupBanner:AutoAddListener()
    self.AutoCreateListeners = {}
    XUiHelper.RegisterClickEvent(self, self.BtnClick, self.OnBtnClickClick)
    XUiHelper.RegisterClickEvent(self, self.BtnTransform, self.OnBtnTransformClick)
end
-- auto

function XUiGridDrawGroupBanner:OnBtnClickClick(...)
    XDataCenter.DrawManager.GetDrawInfoList(self.Info.Id, function()
        self.UiDrawMain.GameObject:PlayLegacyAnimation("UiDrawMainEnd",function()
            XLuaUiManager.Open(self.Info.UiPrefab, self.Info.Id, nil, self.Info.UiBackGround)
        end)
    end)
end

function XUiGridDrawGroupBanner:OnBtnTransformClick(...)
    if #self.Info.TransformSuitList > 0 then
        XLuaUiManager.Open("UiAwarenessTfChoice", self.Info.TransformSuitList, self.Info.EndTime)
    end
end

function XUiGridDrawGroupBanner:UpdateBanner(info)
    self.Info = info
    self.NeedCountDown = false
    self:SetUpCountDown()
    self:SetUpBottomTimes()
end

function XUiGridDrawGroupBanner:SetUpCountDown()
    self.TxtCountDownShort = XUiHelper.TryGetComponent(self.Transform, "TxtCountDownShort", "Text")
    self.TxtCountDown = XUiHelper.TryGetComponent(self.Transform, "TxtCountDown", "Text")
    if self.TxtCountDownShort then
        self.TxtCountDownShort.gameObject:SetActive(false)
    end
    if self.TxtCountDown then
        self.TxtCountDown.gameObject:SetActive(false)
    end
    if self.Info.EndTime > 0 then
        local remainTime = self.Info.EndTime - XTime.GetServerNowTimestamp()
        XCountDown.CreateTimer(self.GameObject.name, remainTime)
        XCountDown.BindTimer(self.GameObject, self.GameObject.name, function(v, oldV)
            if self.TxtCountDownShort then
                self.TxtCountDownShort.text = CS.XTextManager.GetText("DrawResetTimeShort", XUiHelper.GetTime(v, XUiHelper.TimeFormatType.DRAW))
                self.TxtCountDownShort.gameObject:SetActive(true)
            elseif self.TxtCountDown then
                self.TxtCountDown.text = CS.XTextManager.GetText("DrawCardResetTime", XUiHelper.GetTime(v, XUiHelper.TimeFormatType.DRAW))
                self.TxtCountDown.gameObject:SetActive(true)
            end
        end)
        self.NeedCountDown = true
    end
end

function XUiGridDrawGroupBanner:RemoveCountDown()
    if self.NeedCountDown then
        XCountDown.RemoveTimer(self.GameObject.name)
    end
end

function XUiGridDrawGroupBanner:SetUpBottomTimes()
    self.TxtBottomTimes = XUiHelper.TryGetComponent(self.Transform, "TxtBottomTimes", "Text")
    if self.TxtBottomTimes then
        if self.Info.BottomTimes > 0 then
            self.TxtBottomTimes.text = CS.XTextManager.GetText("DrawBottomTimes", self.Info.BottomTimes)
            self.TxtBottomTimes.gameObject:SetActive(true)
        else
            self.TxtBottomTimes.gameObject:SetActive(false)
        end
    end
end

function XUiGridDrawGroupBanner:SetUpTransformBtn()
    if self.BtnTransform then
        if #self.Info.TransformSuitList > 0 then
            self.BtnTransform.gameObject:SetActive(true)
        else
            self.BtnTransform.gameObject:SetActive(false)
        end
    end
end

function XUiGridDrawGroupBanner:ShowPanelNewHand(IsShow)
    if self.PanelNewHand then
        self.PanelNewHand.gameObject:SetActiveEx(IsShow)
    end
end

return XUiGridDrawGroupBanner
