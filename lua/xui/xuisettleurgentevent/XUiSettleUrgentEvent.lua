local XUiSettleUrgentEvent = XLuaUiManager.Register(XLuaUi, "UiSettleUrgentEvent")

function XUiSettleUrgentEvent:OnAwake()
    self:InitAutoScript()
end

function XUiSettleUrgentEvent:OnStart(urgentId)
    local urgentCfg = XDataCenter.FubenUrgentEventManager.GetUrgentEventCfg(urgentId)
    self.TxtUrgentDesc.color = XUiHelper.Hexcolor2Color(urgentCfg.BgColor)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiSettleUrgentEvent:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiSettleUrgentEvent:AutoInitUi()
    self.PanelUrgentInfo = self.Transform:Find("Animator/SafeAreaContentPane/PanelUrgentInfo")
    self.Panel = self.Transform:Find("Animator/SafeAreaContentPane/PanelUrgentInfo/Panel")
    self.PanelEffect = self.Transform:Find("Animator/SafeAreaContentPane/PanelUrgentInfo/Panel/PanelEffect")
    self.TxtUrgentDesc = self.Transform:Find("Animator/SafeAreaContentPane/PanelUrgentInfo/Panel/TxtUrgentDesc"):GetComponent("Text")
    self.BtnClose = self.Transform:Find("Animator/SafeAreaContentPane/PanelUrgentInfo/BtnClose"):GetComponent("Button")
    self.BtnGo = self.Transform:Find("Animator/SafeAreaContentPane/PanelUrgentInfo/BtnGo"):GetComponent("Button")
end

function XUiSettleUrgentEvent:AutoAddListener()
    self:RegisterClickEvent(self.BtnClose, self.OnBtnCloseClick)
    self:RegisterClickEvent(self.BtnGo, self.OnBtnGoClick)
end
-- auto
function XUiSettleUrgentEvent:OnBtnCloseClick(eventData)
    self:Close()
end

function XUiSettleUrgentEvent:OnBtnGoClick(eventData)
    -- 跳转到挑战界面
    XLuaUiManager.RunMain()
    XFunctionManager.SkipInterface(828)
end