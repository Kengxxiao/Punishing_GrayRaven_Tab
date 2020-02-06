local XUiHostelDeviceUpgrading = XUiManager.Register("UiHostelDeviceUpgrading")
local table_insert = table.insert
-- auto
-- Automatic generation of code, forbid to edit
function XUiHostelDeviceUpgrading:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiHostelDeviceUpgrading:AutoInitUi()
    self.PanelFuncUpgrading = self.Transform:Find("SafeAreaContentPane/PanelFuncUpgrading")
    self.TxtSysName = self.Transform:Find("SafeAreaContentPane/PanelFuncUpgrading/TxtSysName"):GetComponent("Text")
    self.TxtUpgradeLeftTime = self.Transform:Find("SafeAreaContentPane/PanelFuncUpgrading/TxtUpgradeLeftTime"):GetComponent("Text")
    self.PanelCharTopButton = self.Transform:Find("SafeAreaContentPane/PanelCharTopButton")
    self.BtnBack = self.Transform:Find("SafeAreaContentPane/PanelCharTopButton/BtnBack"):GetComponent("Button")
end

function XUiHostelDeviceUpgrading:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiHostelDeviceUpgrading:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiHostelDeviceUpgrading:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiHostelDeviceUpgrading:AutoAddListener()
    self.AutoCreateListeners = {}
    XUiHelper.RegisterClickEvent(self, self.BtnBack, self.OnBtnBackClick)
end
-- auto

function XUiHostelDeviceUpgrading:OnOpen(type,funcBackUpgarding)
    self:InitAutoScript()
    self.CurFuncType = type
    self.FuncBackUpgarding = funcBackUpgarding
    local behaviour = self.GameObject:AddComponent(typeof(CS.XLuaBehaviour))
    behaviour.LuaUpdate = function() self:Update() end
    self:UpdateView()
end

function XUiHostelDeviceUpgrading:OnBtnBackClick(...)
    CS.XUiManager.DialogManager:Pop()
    if self.FuncBackUpgarding then
        self.FuncBackUpgarding()
    end
end

function XUiHostelDeviceUpgrading:UpdateView()
    local deveice = XDataCenter.HostelManager.GetFunctionDeviceData(self.CurFuncType)
    if not deveice then return end
    local nextConfig = XDataCenter.HostelManager.GetHostelFunctionDeviceLevelTempalte(self.CurFuncType,deveice.Level + 1)
    if not nextConfig then return end
    self.TxtSysName.text = nextConfig.Name
    if deveice.UpgradeBeginTime > 0 then
        self.EndUpgradTime = deveice.UpgradeBeginTime + nextConfig.CostTime
    end
end

function XUiHostelDeviceUpgrading:Update()
    if self.EndUpgradTime and self.EndUpgradTime > 0 then
        local curTime = XTime.GetServerNowTimestamp()
        local leftTime = self.EndUpgradTime - curTime
        if leftTime < 0 then
            leftTime = 0
        end
        self.TxtUpgradeLeftTime.text = XUiHelper.GetTime(leftTime, XUiHelper.TimeFormatType.SHOP)
    end
end