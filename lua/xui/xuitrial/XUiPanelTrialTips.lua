local XUiPanelTrialTips = XClass()

function XUiPanelTrialTips:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
    self:InitAutoScript()
end

function XUiPanelTrialTips:SetTrialType(trialtype)
    if trialtype == XDataCenter.TrialManager.TrialTypeCfg.TrialFor then
        self.ImgFor.gameObject:SetActive(true)
        self.ImgBackEnd.gameObject:SetActive(false)
        self.ImgBackEnd2.gameObject:SetActive(false)
    elseif trialtype == XDataCenter.TrialManager.TrialTypeCfg.TrialBackEnd then
        self.ImgFor.gameObject:SetActive(false)
        self.ImgBackEnd.gameObject:SetActive(true)
        self.ImgBackEnd2.gameObject:SetActive(false)
    else
        self.ImgFor.gameObject:SetActive(false)
        self.ImgBackEnd.gameObject:SetActive(false)
        self.ImgBackEnd2.gameObject:SetActive(true)
    end
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelTrialTips:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiPanelTrialTips:AutoInitUi()
    -- self.ImgFor = self.Transform:Find("ImgFor"):GetComponent("Image")
    -- self.ImgForIcon = self.Transform:Find("ImgFor/ImgForIcon"):GetComponent("Image")
    -- self.ImgBackEnd = self.Transform:Find("ImgBackEnd"):GetComponent("Image")
    -- self.ImgBackEndIcon = self.Transform:Find("ImgBackEnd/ImgBackEndIcon"):GetComponent("Image")
    -- self.ImgBackEnd2 = self.Transform:Find("ImgBackEnd2"):GetComponent("Image")
    -- self.ImgForIconA = self.Transform:Find("ImgBackEnd2/ImgForIcon"):GetComponent("Image")
end

function XUiPanelTrialTips:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelTrialTips:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelTrialTips:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelTrialTips:AutoAddListener()
end
-- auto

return XUiPanelTrialTips
