local XUiHostelDelegateReporter = XUiManager.Register("UiHostelDelegateReporter")

function XUiHostelDelegateReporter:OnOpen()
    self:InitAutoScript()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiHostelDelegateReporter:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiHostelDelegateReporter:AutoInitUi()
    self.PanelBg = self.Transform:Find("FullScreenBackground/PanelBg")
    self.PanelTopButton = self.Transform:Find("SafeAreaContentPane/PanelTopButton")
    self.BtnBack = self.Transform:Find("SafeAreaContentPane/PanelTopButton/BtnBack"):GetComponent("Button")
    self.PanelLeft = self.Transform:Find("SafeAreaContentPane/PanelLeft")
    self.PanelReport = self.Transform:Find("SafeAreaContentPane/PanelLeft/PanelReport")
    self.BtnReport = self.Transform:Find("SafeAreaContentPane/PanelLeft/PanelReport/BtnReport"):GetComponent("Button")
    self.TxtReleaseCount = self.Transform:Find("SafeAreaContentPane/PanelLeft/PanelReport/TxtReleaseCount"):GetComponent("Text")
    self.TxtCompleteCount = self.Transform:Find("SafeAreaContentPane/PanelLeft/PanelReport/TxtCompleteCount"):GetComponent("Text")
    self.PanelRight = self.Transform:Find("SafeAreaContentPane/PanelRight")
    self.SViewReporter = self.Transform:Find("SafeAreaContentPane/PanelRight/SViewReporter"):GetComponent("ScrollRect")
    self.PanelContent = self.Transform:Find("SafeAreaContentPane/PanelRight/SViewReporter/Viewport/PanelContent")
    self.GridDelegateReporter = self.Transform:Find("SafeAreaContentPane/PanelRight/SViewReporter/Viewport/PanelContent/GridDelegateReporter")
end

function XUiHostelDelegateReporter:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiHostelDelegateReporter:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiHostelDelegateReporter:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiHostelDelegateReporter:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterListener(self.BtnBack, "onClick", self.OnBtnBackClick)
    self:RegisterListener(self.BtnReport, "onClick", self.OnBtnReportClick)
end
-- auto

function XUiHostelDelegateReporter:OnBtnBackClick(...)

end

function XUiHostelDelegateReporter:OnBtnReportClick(...)

end
