XUiPanelDeviceUpgradeInfo = XClass()
local table_insert = table.insert

function XUiPanelDeviceUpgradeInfo:Ctor(rootUi, ui , type, funcBackUpgarding)
    self.RootUi = rootUi
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
    self.CurFuncType = type
    self.FuncBackUpgarding = funcBackUpgarding
    self.UiContentList = {}
    self:SetActive(false)
    self.GridFuncUpgradeInfoItem.gameObject:SetActive(false)
end

function XUiPanelDeviceUpgradeInfo:SetActive(value)
    self.GameObject:SetActive(value)
end
-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelDeviceUpgradeInfo:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiPanelDeviceUpgradeInfo:AutoInitUi()
    self.Panel = self.Transform:Find("Panel")
    self.TxtDeviceName = self.Transform:Find("Panel/TxtDeviceName"):GetComponent("Text")
    self.TxtCurLevel = self.Transform:Find("Panel/TxtCurLevel"):GetComponent("Text")
    self.TxtNextLevel = self.Transform:Find("Panel/TxtNextLevel"):GetComponent("Text")
    self.PanelContent = self.Transform:Find("Panel/PanelContent")
    self.GridFuncUpgradeInfoItem = self.Transform:Find("Panel/PanelContent/GridFuncUpgradeInfoItem")
    self.ImgUpgradeCost = self.Transform:Find("GrpUpInfo/ImgUpgradeCost"):GetComponent("Image")
    self.TxtUpgradeCostCount = self.Transform:Find("GrpUpInfo/TxtUpgradeCostCount"):GetComponent("Text")
    self.TxtUpgradeCostTime = self.Transform:Find("GrpUpInfo/TxtUpgradeCostTime"):GetComponent("Text")
    self.BtnUpgrade = self.Transform:Find("GrpUpInfo/BtnUpgrade"):GetComponent("Button")
end

function XUiPanelDeviceUpgradeInfo:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiPanelDeviceUpgradeInfo:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiPanelDeviceUpgradeInfo:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiPanelDeviceUpgradeInfo:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterListener(self.BtnUpgrade, "onClick", self.OnBtnUpgradeClick)
end
-- auto

function XUiPanelDeviceUpgradeInfo:OnBtnUpgradeClick(...)
    local deveice = XDataCenter.HostelManager.GetFunctionDeviceData(self.CurFuncType)
    if not deveice then return end
    local nextConfig = XDataCenter.HostelManager.GetHostelFunctionDeviceLevelTempalte(self.CurFuncType,deveice.Level + 1)
    if not nextConfig then return end
    if nextConfig.CostId > 0 then
        local isItemEnough = XDataCenter.ItemManager.CheckItemCountById(nextConfig.CostId, nextConfig.CostCount)
        if not isItemEnough then
            local itemName = XDataCenter.ItemManager.GetItemName(nextConfig.CostId)
            local text = CS.XTextManager.GetText("HostelDeviceNeedEle",nextConfig.CostCount,itemName)
            XUiManager.TipMsg(text, XUiManager.UiTipType.Tip)
            return
        end
    end
    if nextConfig.ConditionId > 0 then
        local ret, desc = XConditionManager.CheckCondition(nextConfig.ConditionId)
        if not ret then
            XUiManager.TipError(desc)
            return
        end
    end
    XDataCenter.HostelManager.ReqFuncDeviceUpgrade(self.CurFuncType,function ( ... )
        --CS.XUiManager.DialogManager:Push("UiHostelDeviceUpgrading", false, false,self.CurFuncType,self.FuncBackUpgarding)
        CS.XUiManager.ViewManager:Pop()
        self.FuncBackUpgarding()
    end)
end

function XUiPanelDeviceUpgradeInfo:UpdateView()
    self:SetActive(true)
    local deveice = XDataCenter.HostelManager.GetFunctionDeviceData(self.CurFuncType)
    if not deveice then return end
    local config = XDataCenter.HostelManager.GetHostelFunctionDeviceLevelTempalte(self.CurFuncType,deveice.Level)
    if not config then return end
    self.TxtDeviceName.text = config.Name
    self.TxtCurLevel.text = deveice.Level
    self.TxtNextLevel.text = deveice.Level + 1
    local nextConfig = XDataCenter.HostelManager.GetHostelFunctionDeviceLevelTempalte(self.CurFuncType,deveice.Level + 1)
    if nextConfig then
        self:UpdateFuncDeviceContent(deveice,config,nextConfig)
        if nextConfig.CostId > 0 then
            self.RootUi:SetUiSprite(self.ImgUpgradeCost, XDataCenter.ItemManager.GetItemIcon(nextConfig.CostId))
            self.TxtUpgradeCostCount.text = nextConfig.CostCount
            self.ImgUpgradeCost.gameObject:SetActive(true)
            self.TxtUpgradeCostCount.gameObject:SetActive(true)
        else
            self.ImgUpgradeCost.gameObject:SetActive(false)
            self.TxtUpgradeCostCount.gameObject:SetActive(false)
        end
        local dataTime = XUiHelper.GetTime(nextConfig.CostTime, XUiHelper.TimeFormatType.HOSTEL)
        self.TxtUpgradeCostTime.text = dataTime
    end
end

function XUiPanelDeviceUpgradeInfo:UpdateFuncDeviceContent(deveice,config,nextConfig)
    local datas = {}
    if config.Type == XDataCenter.HostelManager.FunctionDeviceType.PowerStation then
        self:GetPowerStationContent(datas,deveice,config,nextConfig)
    elseif config.Type == XDataCenter.HostelManager.FunctionDeviceType.Factory then
        self:GetFactoryContent(datas,deveice,config,nextConfig)
    end

    local onCreate = function(item, data)
        item:SetData(data[1],data[2],data[3])
    end
    XUiHelper.CreateTemplates(self.RootUi, self.UiContentList, datas, XUiGridFuncUpgradeInfoItem.New, self.GridFuncUpgradeInfoItem.gameObject, self.PanelContent, onCreate)
end

---发电站内容
function XUiPanelDeviceUpgradeInfo:GetPowerStationContent(datas,deveice,config,nextConfig)
    local nextsLotData = XDataCenter.HostelManager.CalcDeviceSlotLevel(XDataCenter.HostelManager.FunctionDeviceType.PowerStation,deveice.Level + 1)
    local curSlotData = XDataCenter.HostelManager.GetCurDeviceWorkSlot(XDataCenter.HostelManager.FunctionDeviceType.PowerStation)
    table_insert(datas,{CS.XTextManager.GetText("HostelMaxElectric"),config.FunctionParam[3],nextConfig.FunctionParam[3]})
    table_insert(datas,{CS.XTextManager.GetText("HostelPerElectric"),config.FunctionParam[2].."/"..XUiHelper.GetTimeDesc(config.FunctionParam[1],1),nextConfig.FunctionParam[2].."/"..XUiHelper.GetTimeDesc(nextConfig.FunctionParam[1],1)})
    local curWorkEle = 0
    for i,v in ipairs(curSlotData) do
         local slotConfig = XDataCenter.HostelManager.GetFuncDeviceSlotTemplate(v)
         curWorkEle = curWorkEle + slotConfig.FunctionParam[1] *(slotConfig.FunctionParam[4] + config.FunctionParam[4])
         break
    end
    local nextWorkEle = 0
    for i,v in ipairs(nextsLotData) do
         local slotConfig = XDataCenter.HostelManager.GetFuncDeviceSlotTemplate(v)
         nextWorkEle = nextWorkEle + slotConfig.FunctionParam[1] *(slotConfig.FunctionParam[4] + nextConfig.FunctionParam[4] )
         break
    end

    table_insert(datas,{CS.XTextManager.GetText("HostelWorkElectric"),CS.XTextManager.GetText("HostelPerSlot",curWorkEle),CS.XTextManager.GetText("HostelPerSlot",nextWorkEle)})
    table_insert(datas,{CS.XTextManager.GetText("HostelWorkSlot"),#curSlotData,#nextsLotData})
end
--发电站内容

--工厂内容
function XUiPanelDeviceUpgradeInfo:GetFactoryContent(datas,deveice,config,nextConfig)
    local nextsLotData = XDataCenter.HostelManager.CalcDeviceSlotLevel(XDataCenter.HostelManager.FunctionDeviceType.Factory,deveice.Level + 1)
    local curSlotData = XDataCenter.HostelManager.GetCurDeviceWorkSlot(XDataCenter.HostelManager.FunctionDeviceType.Factory)
    local curWorkProduct = {}
    for i,v in ipairs(curSlotData) do
        local slotConfig = XDataCenter.HostelManager.GetFuncDeviceSlotTemplate(v)
        local Id = slotConfig.FunctionParam[3]
        if not curWorkProduct[Id] then
            curWorkProduct[Id] = slotConfig.FunctionParam[4] + config.FunctionParam[1]
        end
    end

    local nextWorkProduct = {}
    for i,v in ipairs(nextsLotData) do
        local slotConfig = XDataCenter.HostelManager.GetFuncDeviceSlotTemplate(v)
        local Id = slotConfig.FunctionParam[3]
        if not nextWorkProduct[Id] then
            nextWorkProduct[Id] = slotConfig.FunctionParam[4] + nextConfig.FunctionParam[1]
        end
    end

    for Id,count in pairs(curWorkProduct) do
        table_insert(datas,{CS.XTextManager.GetText("HostelSlotProduct",XDataCenter.ItemManager.GetItemName(Id)),CS.XTextManager.GetText("HostelPerSlot",count),CS.XTextManager.GetText("HostelPerSlot",nextWorkProduct[Id] or 0)})
    end

    table_insert(datas,{CS.XTextManager.GetText("HostelWorkSlot"),#curSlotData,#nextsLotData})
end