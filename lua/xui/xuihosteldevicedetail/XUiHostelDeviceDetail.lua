local XUiHostelDeviceDetail = XLuaUiManager.Register(XLuaUi, "UiHostelDeviceDetail")

local table_insert = table.insert
-- auto
-- Automatic generation of code, forbid to edit
function XUiHostelDeviceDetail:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiHostelDeviceDetail:AutoInitUi()
    self.PanelCharTopButton = self.Transform:Find("SafeAreaContentPane/PanelCharTopButton")
    self.BtnBack = self.Transform:Find("SafeAreaContentPane/PanelCharTopButton/BtnBack"):GetComponent("Button")
    self.BtnMainUi = self.Transform:Find("SafeAreaContentPane/PanelCharTopButton/BtnMainUi"):GetComponent("Button")
    self.PanelDeviceUpgradeInfo = self.Transform:Find("SafeAreaContentPane/PanelDeviceUpgradeInfo")
    self.PanelDeviceUpgradeMain = self.Transform:Find("SafeAreaContentPane/PanelDeviceUpgradeMain")
    self.PanelBtnInfo = self.Transform:Find("SafeAreaContentPane/PanelDeviceUpgradeMain/PanelBtnInfo")
    self.BtnShowInfo = self.Transform:Find("SafeAreaContentPane/PanelDeviceUpgradeMain/PanelBtnInfo/BtnShowInfo"):GetComponent("Button")
    self.PanelSysInfo = self.Transform:Find("SafeAreaContentPane/PanelDeviceUpgradeMain/ContentInfo/PanelSysInfo")
    self.PanelFixInfo = self.Transform:Find("SafeAreaContentPane/PanelDeviceUpgradeMain/ContentInfo/PanelSysInfo/PanelFixInfo")
    self.TxtFunctionDeviceName = self.Transform:Find("SafeAreaContentPane/PanelDeviceUpgradeMain/ContentInfo/PanelSysInfo/PanelFixInfo/TxtFunctionDeviceName"):GetComponent("Text")
    self.PanelFunctionContent = self.Transform:Find("SafeAreaContentPane/PanelDeviceUpgradeMain/ContentInfo/PanelSysInfo/PanelFunctionContent")
    self.GridFunctionContenItem = self.Transform:Find("SafeAreaContentPane/PanelDeviceUpgradeMain/ContentInfo/PanelSysInfo/PanelFunctionContent/GridFunctionContenItem")
    self.PanelSysDes = self.Transform:Find("SafeAreaContentPane/PanelDeviceUpgradeMain/ContentInfo/PanelSysDes")
    self.TxtSysDes = self.Transform:Find("SafeAreaContentPane/PanelDeviceUpgradeMain/ContentInfo/PanelSysDes/TxtSysDes"):GetComponent("Text")
    self.PanelUpInfo = self.Transform:Find("SafeAreaContentPane/PanelDeviceUpgradeMain/PanelUpInfo")
    self.ImgCost = self.Transform:Find("SafeAreaContentPane/PanelDeviceUpgradeMain/PanelUpInfo/ImgCost"):GetComponent("Image")
    self.TxtCostCount = self.Transform:Find("SafeAreaContentPane/PanelDeviceUpgradeMain/PanelUpInfo/TxtCostCount"):GetComponent("Text")
    self.TxtCostTime = self.Transform:Find("SafeAreaContentPane/PanelDeviceUpgradeMain/PanelUpInfo/TxtCostTime"):GetComponent("Text")
    self.BtnIntoUpgrade = self.Transform:Find("SafeAreaContentPane/PanelDeviceUpgradeMain/BtnIntoUpgrade"):GetComponent("Button")
    self.BtnQuest = self.Transform:Find("SafeAreaContentPane/PanelDeviceUpgradeMain/BtnQuest"):GetComponent("Button")
    self.PanelAsset = self.Transform:Find("SafeAreaContentPane/PanelAsset")
    self.PanelTool1 = self.Transform:Find("SafeAreaContentPane/PanelAsset/PanelTool1")
    self.ImgTool1 = self.Transform:Find("SafeAreaContentPane/PanelAsset/PanelTool1/ImgTool1"):GetComponent("Image")
    self.TxtTool1 = self.Transform:Find("SafeAreaContentPane/PanelAsset/PanelTool1/TxtTool1"):GetComponent("Text")
    self.PanelTool2 = self.Transform:Find("SafeAreaContentPane/PanelAsset/PanelTool2")
    self.ImgTool2 = self.Transform:Find("SafeAreaContentPane/PanelAsset/PanelTool2/ImgTool2"):GetComponent("Image")
    self.TxtTool2 = self.Transform:Find("SafeAreaContentPane/PanelAsset/PanelTool2/TxtTool2"):GetComponent("Text")
    self.ImgBg = self.Transform:Find("FullScreenBackground/ImgBg"):GetComponent("Image")
end

function XUiHostelDeviceDetail:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiHostelDeviceDetail:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiHostelDeviceDetail:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiHostelDeviceDetail:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterListener(self.BtnBack, "onClick", self.OnBtnBackClick)
    self:RegisterListener(self.BtnMainUi, "onClick", self.OnBtnMainUiClick)
    self:RegisterListener(self.BtnShowInfo, "onClick", self.OnBtnShowInfoClick)
    self:RegisterListener(self.BtnIntoUpgrade, "onClick", self.OnBtnIntoUpgradeClick)
    self:RegisterListener(self.BtnQuest, "onClick", self.OnBtnQuestClick)
end
-- auto

function XUiHostelDeviceDetail:OnOpen(type,deveiceObj,fCloseCallBack)
    self:InitAutoScript()
    self.AssetPanel =  XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.HostelElectric, XDataCenter.ItemManager.ItemId.HostelMat)
    self.GridFunctionContenItem.gameObject:SetActive(false)
    self.UiContentList = {}
    self.CurFuncType = type
    self.FCloseCallBack = fCloseCallBack
    local funcBackUpgarding = function ()
        XHomeSceneManager.ChangeBackToOverView()
        XHomeInfrastructureManager.ChangeCameraToScene()
    end
    self.PanelUpgardeInfo = XUiPanelDeviceUpgradeInfo.New(self, self.PanelDeviceUpgradeInfo,type,funcBackUpgarding)
    self.PanelUpgardeInfo:SetActive(false)
    self.ImgBg.gameObject:SetActive(false)
    self:UpdateView()
end

function XUiHostelDeviceDetail:OnBtnBackClick(...)
    if self.PanelUpgardeInfo.GameObject.activeSelf then
        self.PanelUpgardeInfo:SetActive(false)
        self.ImgBg.gameObject:SetActive(false)
        self.PanelDeviceUpgradeMain.gameObject:SetActive(true)
    else
        self.FCloseCallBack()
        CS.XUiManager.ViewManager:Pop()
    end
end

function XUiHostelDeviceDetail:OnBtnMainUiClick(...)
    XLuaUiManager.RunMain()
end

function XUiHostelDeviceDetail:UpdateView()
    local deveice = XDataCenter.HostelManager.GetFunctionDeviceData(self.CurFuncType)
    if not deveice then return end
    local config = XDataCenter.HostelManager.GetHostelFunctionDeviceLevelTempalte(self.CurFuncType,deveice.Level)
    if not config then return end
    if config.Type == XDataCenter.HostelManager.FunctionDeviceType.MainComputer then
        self.BtnQuest.gameObject:SetActive(false)
    else
        self.BtnQuest.gameObject:SetActive(true)
    end
    self:UpdateFuncDeviceContent(deveice,config)
    local rectTf = self.PanelBtnInfo.gameObject:GetComponent("RectTransform")
    local width = rectTf.sizeDelta.x
    rectTf.sizeDelta = CS.UnityEngine.Vector2(width,110 + #self.UiContentList * 65)


    self.TxtFunctionDeviceName.text = config.Name
    self.TxtSysDes.text = config.Des
    local nextConfig = XDataCenter.HostelManager.GetHostelFunctionDeviceLevelTempalte(self.CurFuncType,deveice.Level + 1)
    if not nextConfig then
        self.PanelUpInfo.gameObject:SetActive(false)
        self.BtnIntoUpgrade.gameObject:SetActive(false)
    else
        self.PanelUpInfo.gameObject:SetActive(true)
        self.BtnIntoUpgrade.gameObject:SetActive(true)
        if nextConfig.CostId > 0 then
            self:SetUiSprite(self.ImgCost, XDataCenter.ItemManager.GetItemIcon(nextConfig.CostId))
            self.TxtCostCount.text = nextConfig.CostCount
            self.ImgCost.gameObject:SetActive(true)
            self.TxtCostCount.gameObject:SetActive(true)
        else
            self.ImgCost.gameObject:SetActive(false)
            self.TxtCostCount.gameObject:SetActive(false)
        end
        local dataTime = XUiHelper.GetTime(nextConfig.CostTime, XUiHelper.TimeFormatType.HOSTEL)
        self.TxtCostTime.text = dataTime
    end
end

function XUiHostelDeviceDetail:UpdateFuncDeviceContent(deveice,config)
    local datas = {}
    table_insert(datas,{CS.XTextManager.GetText("HostelDeviceLevel"),deveice.Level})
    if config.Type == XDataCenter.HostelManager.FunctionDeviceType.PowerStation then
        self:GetPowerStationContent(datas,config)
    elseif config.Type == XDataCenter.HostelManager.FunctionDeviceType.Factory then
        self:GetFactoryContent(datas,config)
    end

    local onCreate = function(item, data)
        item:SetData(data[1],data[2])
    end
    XUiHelper.CreateTemplates(self, self.UiContentList, datas, XUiGridFunctionContenItem.New, self.GridFunctionContenItem.gameObject, self.PanelFunctionContent, onCreate)

end

--发电站
function XUiHostelDeviceDetail:GetPowerStationContent(datas,config)
    table_insert(datas,{CS.XTextManager.GetText("HostelMaxElectric"),config.FunctionParam[3]})
    table_insert(datas,{CS.XTextManager.GetText("HostelPerElectric"),config.FunctionParam[2].."/"..XUiHelper.GetTimeDesc(config.FunctionParam[1],1)})
end
--发电站

--工厂
function XUiHostelDeviceDetail:GetFactoryContent(datas,config)
    local curSlotData = XDataCenter.HostelManager.GetCurDeviceWorkSlot(XDataCenter.HostelManager.FunctionDeviceType.Factory)
    local curWorkProduct = {}
    for i,v in ipairs(curSlotData) do
        local slotConfig = XDataCenter.HostelManager.GetFuncDeviceSlotTemplate(v)
        local Id = slotConfig.FunctionParam[3]
        if not curWorkProduct[Id] then  
            curWorkProduct[Id] = slotConfig.FunctionParam[4] + config.FunctionParam[1]
        end
    end

    for Id,count in pairs(curWorkProduct) do
        table_insert(datas,{CS.XTextManager.GetText("HostelSlotProduct",XDataCenter.ItemManager.GetItemName(Id)),CS.XTextManager.GetText("HostelPerSlot",count)})
    end
end

function XUiHostelDeviceDetail:OnBtnShowInfoClick(...)
    local active = self.PanelSysDes.gameObject.activeSelf
    self.PanelSysDes.gameObject:SetActive(not active)
end

function XUiHostelDeviceDetail:OnBtnIntoUpgradeClick(...)
    self.PanelUpgardeInfo:SetActive(true)
    self.ImgBg.gameObject:SetActive(true)
    self.PanelUpgardeInfo:UpdateView()
    self.PanelDeviceUpgradeMain.gameObject:SetActive(false)
end

function XUiHostelDeviceDetail:OnBtnQuestClick(...)

end
