local XUiHomeMain = XLuaUiManager.Register(XLuaUi, "UiHomeMain")

function XUiHomeMain:OnAwake()
    self:InitAutoScript()
end

function XUiHomeMain:OnStart(type)

    self.Type = type
    self:ChangeBtnList()
    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.Coin, XDataCenter.ItemManager.ItemId.HostelElectric, XDataCenter.ItemManager.ItemId.HostelMat)
    --CS.XUiManager.DialogManager:Pop()
    XLuaUiManager.Close("UiLoading")
    self:ShowMenu(false)
    --CS.XUiManager.UiModelCamera.gameObject:SetActive(false)
    self.PanelMain.gameObject:SetActive(false)--暂时屏蔽
    self.PanelAsset.gameObject:SetActive(false)--暂时屏蔽
end

function XUiHomeMain:OnEnable()
    self:ShowMenu(false)
end

function XUiHomeMain:OnDestroy()
    XHomeSceneManager.LeaveScene()
    --CS.XUiManager.UiModelCamera.gameObject:SetActive(true)
end

function XUiHomeMain:OnDisable()
    --
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiHomeMain:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiHomeMain:AutoInitUi()
    self.PanelBg = self.Transform:Find("FullScreenBackground/PanelBg")
    self.PanelMenu = self.Transform:Find("SafeAreaContentPane/PanelMenu")
    self.BtnVisitFriend = self.Transform:Find("SafeAreaContentPane/PanelMenu/BtnVisitFriend"):GetComponent("Button")
    self.BtnFuncArea = self.Transform:Find("SafeAreaContentPane/PanelMenu/BtnFuncArea"):GetComponent("Button")
    self.BtnFloorOne = self.Transform:Find("SafeAreaContentPane/PanelMenu/BtnFloorOne"):GetComponent("Button")
    self.BtnFloorTwo = self.Transform:Find("SafeAreaContentPane/PanelMenu/BtnFloorTwo"):GetComponent("Button")
    self.BtnFloorThree = self.Transform:Find("SafeAreaContentPane/PanelMenu/BtnFloorThree"):GetComponent("Button")
    self.PanelMain = self.Transform:Find("SafeAreaContentPane/PanelMain")
    self.BtnJumpMenu = self.Transform:Find("SafeAreaContentPane/PanelMain/BtnJumpMenu"):GetComponent("Button")
    self.BtnAssignChar = self.Transform:Find("SafeAreaContentPane/PanelMain/BtnAssignChar"):GetComponent("Button")
    self.PanelAsset = self.Transform:Find("SafeAreaContentPane/PanelAsset")
    self.PanelTool1 = self.Transform:Find("SafeAreaContentPane/PanelAsset/PanelTool1")
    self.PanelTool2 = self.Transform:Find("SafeAreaContentPane/PanelAsset/PanelTool2")
    self.PanelTool3 = self.Transform:Find("SafeAreaContentPane/PanelAsset/PanelTool3")
    self.PanelCharTopButton = self.Transform:Find("SafeAreaContentPane/PanelCharTopButton")
    self.BtnBack = self.Transform:Find("SafeAreaContentPane/PanelCharTopButton/BtnBack"):GetComponent("Button")
    self.BtnMainUi = self.Transform:Find("SafeAreaContentPane/PanelCharTopButton/BtnMainUi"):GetComponent("Button")
end

function XUiHomeMain:GetAutoKey(uiNode, eventName)
    if not uiNode then
        return
    end
    return eventName .. uiNode:GetHashCode()
end

function XUiHomeMain:RegisterListener(uiNode, eventName, func)
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
            XLog.Error("XUiHomeMain:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiHomeMain:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterClickEvent(self.BtnVisitFriend, self.OnBtnVisitFriendClick)
    self:RegisterClickEvent(self.BtnFuncArea, self.OnBtnFuncAreaClick)
    self:RegisterClickEvent(self.BtnFloorOne, self.OnBtnFloorOneClick)
    self:RegisterClickEvent(self.BtnFloorTwo, self.OnBtnFloorTwoClick)
    self:RegisterClickEvent(self.BtnFloorThree, self.OnBtnFloorThreeClick)
    self:RegisterClickEvent(self.BtnJumpMenu, self.OnBtnJumpMenuClick)
    self:RegisterClickEvent(self.BtnAssignChar, self.OnBtnAssignCharClick)
    self:RegisterClickEvent(self.BtnBack, self.OnBtnBackClick)
    self:RegisterClickEvent(self.BtnMainUi, self.OnBtnMainUiClick)
end
-- auto

function XUiHomeMain:OnBtnVisitFriendClick(...)

end

function XUiHomeMain:OnBtnFuncAreaClick(...)
    XHomeInfrastructureManager.EnterInfrastructure()
end

function XUiHomeMain:OnBtnFloorOneClick(...)

end

function XUiHomeMain:OnBtnFloorTwoClick(...)

end

function XUiHomeMain:OnBtnFloorThreeClick(...)

end

function XUiHomeMain:OnBtnJumpMenuClick(...)
    local show = not self.IsShowMenu
    self:ShowMenu(show)
end

function XUiHomeMain:OnBtnAssignCharClick(...)
    --
    --CS.XUiManager.ViewManager:Push("UiHostelRest", false, false)
    XLuaUiManager.Open("UiHostelRest")
    self:ShowMenu(false)
end

function XUiHomeMain:OnBtnBackClick(...)
    -- if not XHomeSceneManager.ChangeBackToOverView() then
    --     CS.XUiManager.ViewManager:Pop()
    -- end

    XHomeInfrastructureManager.ChangeCameraToScene()
    XLuaUiManager.RunMain()--临时返回主界面
end

function XUiHomeMain:OnBtnMainUiClick(...)
    XLuaUiManager.RunMain()
end

function XUiHomeMain:ShowMenu(show)
    show = show or false
    self.IsShowMenu = show
    self.PanelMenu.gameObject:SetActive(show)
end

function XUiHomeMain:ChangeBtnList()
    if self.Type == XDataCenter.HostelManager.SceneType.Function then
        self.BtnFuncArea.gameObject:SetActive(false)
    end
end
