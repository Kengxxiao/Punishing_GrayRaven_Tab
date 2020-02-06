local XUiPersonalInfo = XLuaUiManager.Register(XLuaUi, "UiPersonalInfo")

PersonalToggleType = {
    Info = 1,
    MsgBoard = 2,
}

function XUiPersonalInfo:OnAwake()
    self:InitAutoScript()
end

function XUiPersonalInfo:OnStart(personalInfo, closeCB)
    XDataCenter.PersonalInfoManager.AddPanelPersonalInfo(self)
    self.PersonalInfo = personalInfo
    self.CloseCB = closeCB
    self:InitView()
end

function XUiPersonalInfo:GetPanelMsgboard(...)
    if self.XUiPanelMsgBoard then
        return self.XUiPanelMsgBoard
    else
        XLog.Error("XUiPersonalInfo.XUiPanelMsgBoard in null!")
    end
end

function XUiPersonalInfo:InitView(...)
    self.PanelPersonalDetails.gameObject:SetActive(false)
    self.PanelMsgBoard.gameObject:SetActive(false)
    self.PanelJubao.gameObject:SetActive(false)
    self.XUiPanelPersonalDetails = XUiPanelPersonalDetails.New(self.PanelPersonalDetails, self)
    self.XUiPanelJubao = XUiPanelJubao.New(self.PanelJubao, self)
    self.XUiPanelMsgBoard = XUiPanelMsgBoard.New(self.PanelMsgBoard, self)
    self.TogMsgBoard.gameObject:SetActive(false)

    self.TogInfo.isOn = true
    self.TogMsgBoard.isOn = false
    self:OnTogInfoValueChanged(true)
end
-- auto
-- Automatic generation of code, forbid to edit
function XUiPersonalInfo:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiPersonalInfo:AutoInitUi()
    self.PanelTopBtn = self.Transform:Find("SafeAreaContentPane/PanelTopBtn")
    self.BtnBack = self.Transform:Find("SafeAreaContentPane/PanelTopBtn/BtnBack"):GetComponent("Button")
    self.BtnLeftToggle = self.Transform:Find("SafeAreaContentPane/BtnLeftToggle"):GetComponent("Button")
    self.TogMsgBoard = self.Transform:Find("SafeAreaContentPane/BtnLeftToggle/TogMsgBoard"):GetComponent("Toggle")
    self.TxtMsgBoard = self.Transform:Find("SafeAreaContentPane/BtnLeftToggle/TogMsgBoard/Background/TxtMsgBoard"):GetComponent("Text")
    self.TogInfo = self.Transform:Find("SafeAreaContentPane/BtnLeftToggle/TogInfo"):GetComponent("Toggle")
    self.TxtInfo = self.Transform:Find("SafeAreaContentPane/BtnLeftToggle/TogInfo/Background/TxtInfo"):GetComponent("Text")
    self.PanelPersonalDetails = self.Transform:Find("SafeAreaContentPane/PanelPersonalDetails")
    self.PanelMsgBoard = self.Transform:Find("SafeAreaContentPane/PanelMsgBoard")
    self.PanelJubao = self.Transform:Find("SafeAreaContentPane/PanelJubao")
end

function XUiPersonalInfo:GetAutoKey(uiNode, eventName)
    if not uiNode then
        return
    end
    return eventName .. uiNode:GetHashCode()
end

function XUiPersonalInfo:RegisterListener(uiNode, eventName, func)
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
            XLog.Error("XUiPersonalInfo:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiPersonalInfo:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterClickEvent(self.BtnBack, self.OnBtnBackClick)
    self:RegisterListener(self.TogMsgBoard, "onValueChanged", self.OnTogMsgBoardValueChanged)
    self:RegisterListener(self.TogInfo, "onValueChanged", self.OnTogInfoValueChanged)
end
-- auto

function XUiPersonalInfo:OnTogInfoValueChanged(code)
    --点击个人信息面板
    if not code then
        return
    end
    self.TxtInfo.gameObject:SetActive(false)
    self.TxtMsgBoard.gameObject:SetActive(true)
    self.XUiPanelMsgBoard:SetIsShow(false)
    self.XUiPanelPersonalDetails:Refresh(self.PersonalInfo)
end

function XUiPersonalInfo:OnTogMsgBoardValueChanged(code)
    --点击日记面板
    if not code then
        return
    end
    self.TxtInfo.gameObject:SetActive(true)
    self.TxtMsgBoard.gameObject:SetActive(false)
    self.XUiPanelPersonalDetails:SetIsShow(false)
    XDataCenter.PersonalInfoManager.GetDailys(self.PersonalInfo.PlayerData.Id, 1, function(...)
        self.XUiPanelMsgBoard:Refresh()
    end)
end

function XUiPersonalInfo:OnBtnBackClick(...)
    if self.CloseCB then
        self.CloseCB()
    end
    self:Close()
end

function XUiPersonalInfo:OnDestroy(...)
    XDataCenter.PersonalInfoManager.OnDispose()
end
