local XUiHostelDeviceUpgradeResult = XUiManager.Register("UiHostelDeviceUpgradeResult")
local table_insert = table.insert

-- auto
-- Automatic generation of code, forbid to edit
function XUiHostelDeviceUpgradeResult:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiHostelDeviceUpgradeResult:AutoInitUi()
    self.PanelFuncUpgradeResult = self.Transform:Find("SafeAreaContentPane/PanelFuncUpgradeResult")
    self.PanelInfo = self.Transform:Find("SafeAreaContentPane/PanelFuncUpgradeResult/PanelInfo")
    self.PanelContent = self.Transform:Find("SafeAreaContentPane/PanelFuncUpgradeResult/PanelInfo/PanelContent")
    self.GridFuncUpgradeResItem = self.Transform:Find("SafeAreaContentPane/PanelFuncUpgradeResult/PanelInfo/PanelContent/GridFuncUpgradeResItem")
    self.BtnClick = self.Transform:Find("SafeAreaContentPane/PanelFuncUpgradeResult/BtnClick"):GetComponent("Button")
end

function XUiHostelDeviceUpgradeResult:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiHostelDeviceUpgradeResult:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiHostelDeviceUpgradeResult:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiHostelDeviceUpgradeResult:AutoAddListener()
    self.AutoCreateListeners = {}
    XUiHelper.RegisterClickEvent(self, self.BtnClick, self.OnBtnClickClick)
end
-- auto

function XUiHostelDeviceUpgradeResult:OnBtnClickClick(...)
    CS.XUiManager.DialogManager:Pop()
end

function XUiHostelDeviceUpgradeResult:OnOpen(type)
    self:InitAutoScript()
    self.GridFuncUpgradeResItem.gameObject:SetActive(false)
    self.CurFuncType = type
    self.UiContentList = {}
    self:UpdateView()
end

function XUiHostelDeviceUpgradeResult:UpdateView()
    local deveice = XDataCenter.HostelManager.GetFunctionDeviceData(self.CurFuncType)
    if not deveice then return end
    local config = XDataCenter.HostelManager.GetHostelFunctionDeviceLevelTempalte(self.CurFuncType,deveice.Level)
    if not config then return end
    self:UpdateFuncDeviceContent(deveice,config)

end

function XUiHostelDeviceUpgradeResult:UpdateFuncDeviceContent(deveice,config)
    local datas = {}
    table_insert(datas,{CS.XTextManager.GetText("HostelDeviceLevel")..CS.XTextManager.GetText("HostelDeviceUp"),deveice.Level})
    if config.Type == XDataCenter.HostelManager.FunctionDeviceType.PowerStation then
        self:GetPowerStationContent(datas,deveice,config)
    elseif config.Type == XDataCenter.HostelManager.FunctionDeviceType.Factory then
        self:GetFactoryContent(datas,deveice,config)
    end

    local onCreate = function(item, data)
        item:SetData(data[1],data[2])
    end
    XUiHelper.CreateTemplates(self, self.UiContentList, datas, XUiGridFuncUpgradeResItem.New, self.GridFuncUpgradeResItem.gameObject, self.PanelContent, onCreate)
end

--发电站内容
function XUiHostelDeviceUpgradeResult:GetPowerStationContent(datas,deveice,config)
    local str = CS.XTextManager.GetText("HostelDeviceUp")
    table_insert(datas,{CS.XTextManager.GetText("HostelMaxElectric")..str,config.FunctionParam[3]})
    table_insert(datas,{CS.XTextManager.GetText("HostelPerElectric")..str,config.FunctionParam[2].."/"..XUiHelper.GetTimeDesc(config.FunctionParam[1],1)})
    local curSlotData = XDataCenter.HostelManager.GetCurDeviceWorkSlot(XDataCenter.HostelManager.FunctionDeviceType.PowerStation)
    local curWorkEle = 0
    for i,v in ipairs(curSlotData) do
         local slotConfig = XDataCenter.HostelManager.GetFuncDeviceSlotTemplate(v)
         curWorkEle = curWorkEle + slotConfig.FunctionParam[1] * (slotConfig.FunctionParam[4] + config.FunctionParam[4])
         break
    end
    table_insert(datas,{CS.XTextManager.GetText("HostelWorkElectric")..str,CS.XTextManager.GetText("HostelPerSlot",curWorkEle)})
    table_insert(datas,{CS.XTextManager.GetText("HostelWorkSlot")..str,#curSlotData})
end

function XUiHostelDeviceUpgradeResult:GetFactoryContent(datas,deveice,config)
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
    table_insert(datas,{CS.XTextManager.GetText("HostelWorkSlot"),#curSlotData})
end