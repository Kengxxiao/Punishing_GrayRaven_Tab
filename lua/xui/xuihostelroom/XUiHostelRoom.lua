local XUiHostelRoom = XLuaUiManager.Register(XLuaUi, "UiHostelRoom")

function XUiHostelRoom:OnAwake()
    self:InitAutoScript()
end

function XUiHostelRoom:OnStart()
    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.HostelElectric, XDataCenter.ItemManager.ItemId.HostelMat)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiHostelRoom:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiHostelRoom:AutoInitUi()
    self.PanelDeviceUpgradeInfo = self.Transform:Find("SafeAreaContentPane/PanelDeviceUpgradeInfo")
    self.PanelCharTopButton = self.Transform:Find("SafeAreaContentPane/PanelCharTopButton")
    self.BtnBack = self.Transform:Find("SafeAreaContentPane/PanelCharTopButton/BtnBack"):GetComponent("Button")
    self.BtnMainUi = self.Transform:Find("SafeAreaContentPane/PanelCharTopButton/BtnMainUi"):GetComponent("Button")
    self.PanelAsset = self.Transform:Find("SafeAreaContentPane/PanelAsset")
    self.PanelTool1 = self.Transform:Find("SafeAreaContentPane/PanelAsset/PanelTool1")
    self.ImgTool1 = self.Transform:Find("SafeAreaContentPane/PanelAsset/PanelTool1/ImgTool1"):GetComponent("Image")
    self.TxtTool1 = self.Transform:Find("SafeAreaContentPane/PanelAsset/PanelTool1/TxtTool1"):GetComponent("Text")
    self.PanelTool2 = self.Transform:Find("SafeAreaContentPane/PanelAsset/PanelTool2")
    self.ImgTool2 = self.Transform:Find("SafeAreaContentPane/PanelAsset/PanelTool2/ImgTool2"):GetComponent("Image")
    self.TxtTool2 = self.Transform:Find("SafeAreaContentPane/PanelAsset/PanelTool2/TxtTool2"):GetComponent("Text")
end

function XUiHostelRoom:GetAutoKey(uiNode, eventName)
    if not uiNode then
        return
    end
    return eventName .. uiNode:GetHashCode()
end

function XUiHostelRoom:RegisterListener(uiNode, eventName, func)
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
            XLog.Error("XUiHostelRoom:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiHostelRoom:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterListener(self.BtnBack, "onClick", self.OnBtnBackClick)
    self:RegisterListener(self.BtnMainUi, "onClick", self.OnBtnMainUiClick)
end
-- auto

function XUiHostelRoom:OnBtnBackClick(...)
    XHomeSceneManager.ChangeBackToOverView()
    XHomeInfrastructureManager.ChangeCameraToScene()
    --CS.XUiManager.ViewManager:Pop()
    self:Close()
end

function XUiHostelRoom:OnBtnMainUiClick(...)
    XLuaUiManager.RunMain()
end
