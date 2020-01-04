local XUiHostelCharacterWork = XUiManager.Register("UiHostelCharacterWork")
local table_insert = table.insert
-- auto
-- Automatic generation of code, forbid to edit
function XUiHostelCharacterWork:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiHostelCharacterWork:AutoInitUi()
    self.PanelAsset = self.Transform:Find("SafeAreaContentPane/PanelAsset")
    self.PanelTool1 = self.Transform:Find("SafeAreaContentPane/PanelAsset/PanelTool1")
    self.ImgTool1 = self.Transform:Find("SafeAreaContentPane/PanelAsset/PanelTool1/ImgTool1"):GetComponent("Image")
    self.TxtTool1 = self.Transform:Find("SafeAreaContentPane/PanelAsset/PanelTool1/TxtTool1"):GetComponent("Text")
    self.PanelTool2 = self.Transform:Find("SafeAreaContentPane/PanelAsset/PanelTool2")
    self.ImgTool2 = self.Transform:Find("SafeAreaContentPane/PanelAsset/PanelTool2/ImgTool2"):GetComponent("Image")
    self.TxtTool2 = self.Transform:Find("SafeAreaContentPane/PanelAsset/PanelTool2/TxtTool2"):GetComponent("Text")
    self.PanelCharTopButton = self.Transform:Find("SafeAreaContentPane/PanelCharTopButton")
    self.BtnBack = self.Transform:Find("SafeAreaContentPane/PanelCharTopButton/BtnBack"):GetComponent("Button")
    self.BtnMainUi = self.Transform:Find("SafeAreaContentPane/PanelCharTopButton/BtnMainUi"):GetComponent("Button")
    self.PanelSelectWork = self.Transform:Find("SafeAreaContentPane/PanelSelectWork")
    self.PanelSlotInfo = self.Transform:Find("SafeAreaContentPane/PanelSelectWork/PanelSlotInfo")
    self.TxtSlotName = self.Transform:Find("SafeAreaContentPane/PanelSelectWork/PanelSlotInfo/TxtSlotName"):GetComponent("Text")
    self.TxtProductName = self.Transform:Find("SafeAreaContentPane/PanelSelectWork/PanelSlotInfo/TxtProductName"):GetComponent("Text")
    self.TxtProductValue = self.Transform:Find("SafeAreaContentPane/PanelSelectWork/PanelSlotInfo/TxtProductValue"):GetComponent("Text")
    self.PanelRight = self.Transform:Find("SafeAreaContentPane/PanelSelectWork/PanelRight")
    self.SViewIdleCharList = self.Transform:Find("SafeAreaContentPane/PanelSelectWork/PanelRight/SViewIdleCharList"):GetComponent("ScrollRect")
    self.PanelIdleCharContent = self.Transform:Find("SafeAreaContentPane/PanelSelectWork/PanelRight/SViewIdleCharList/Viewport/PanelIdleCharContent")
    self.GridIdleCharacter = self.Transform:Find("SafeAreaContentPane/PanelSelectWork/PanelRight/SViewIdleCharList/Viewport/PanelIdleCharContent/GridIdleCharacter")
    self.TxtCostVitality = self.Transform:Find("SafeAreaContentPane/PanelSelectWork/PanelRight/TxtCostVitality"):GetComponent("Text")
    self.TxtCostTime = self.Transform:Find("SafeAreaContentPane/PanelSelectWork/PanelRight/TxtCostTime"):GetComponent("Text")
    self.BtnCharWork = self.Transform:Find("SafeAreaContentPane/PanelSelectWork/PanelRight/BtnCharWork"):GetComponent("Button")
end

function XUiHostelCharacterWork:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiHostelCharacterWork:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiHostelCharacterWork:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiHostelCharacterWork:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterListener(self.BtnBack, "onClick", self.OnBtnBackClick)
    self:RegisterListener(self.BtnMainUi, "onClick", self.OnBtnMainUiClick)
    self:RegisterListener(self.BtnCharWork, "onClick", self.OnBtnCharWorkClick)
end
-- auto

function XUiHostelCharacterWork:OnOpen(slotType, deveiceObj, fCloseCallBack)
    self:InitAutoScript()
    self.AssetPanel =  XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.HostelElectric, XDataCenter.ItemManager.ItemId.HostelMat)
    self.DeviceObj = deveiceObj
    self.GridIdleCharacter.gameObject:SetActive(false)
    self.SlotType = slotType
    self.FCloseCallBack = fCloseCallBack
    self.CurSelectIndex = 0
    self.IdleCharUiItem = {}
    self:UpdateView()
end

function XUiHostelCharacterWork:OnBtnBackClick(...)
    CS.XUiManager.ViewManager:Pop()
    if self.FCloseCallBack then
        self.FCloseCallBack()
    end
end

function XUiHostelCharacterWork:OnBtnMainUiClick(...)
    XLuaUiManager.RunMain()
end

function XUiHostelCharacterWork:OnBtnCharWorkClick(...)
    if self.CurSelectIndex == 0 then
        XUiManager.TipText("HostelSelectCharWork")
        return
    end
    local charId = self.IdleCharUiItem[self.CurSelectIndex]:GetCharId()
    if charId == 0 then
        return
    end

    local fSucCallBack = function ()
        self.CurSelectIndex = 0
        self:UpdateView()
        self.DeviceObj:CheckShowHud()
    end
    XDataCenter.HostelManager.ReqWorkInFunctionDevice(charId, self.SlotType, fSucCallBack)
end

function XUiHostelCharacterWork:UpdateView()
    self.SlotBelongType = 0
    local slotConfig =  XDataCenter.HostelManager.GetFuncDeviceSlotTemplate(self.SlotType)
    if not slotConfig then
        return
    end
    self.SlotBelongType = slotConfig.BelongType

    if self:IsWorkSlotEmpty() then
        self.PanelRight.gameObject:SetActive(true)
        self:UpdateIdleList()
        if self.CurSelectIndex == 0 then
            local hud = self.DeviceObj:GetDisplayHud()
            if hud then
                hud:ShowJiantou()
            end
        end
    else
        self.PanelRight.gameObject:SetActive(false)
    end


    if self.SlotBelongType == XDataCenter.HostelManager.FunctionDeviceType.PowerStation then
        self:UpdatePowerStationSlotInfo(slotConfig)
    elseif self.SlotBelongType == XDataCenter.HostelManager.FunctionDeviceType.Factory then
        self:UpdateFactorySlotInfo(slotConfig)
    end  
    
end

function XUiHostelCharacterWork:IsWorkSlotEmpty()
    ---发电站槽位
    if self.SlotBelongType == XDataCenter.HostelManager.FunctionDeviceType.PowerStation then
        return XDataCenter.HostelManager.CheckWorkSlotIsEmpty(self.SlotType)
    elseif self.SlotBelongType == XDataCenter.HostelManager.FunctionDeviceType.Factory then
        return XDataCenter.HostelManager.CheckWorkSlotIsIdle(self.SlotType)
    --TODO elseif 其他槽位
    end 
    return true
end


---发电站信息
function XUiHostelCharacterWork:UpdatePowerStationSlotInfo(slotConfig)
    self.TxtCostVitality.text = CS.XTextManager.GetText("CharacterVitality",slotConfig.FunctionParam[2])
    local dataTime = XUiHelper.GetTime(slotConfig.FunctionParam[1] * slotConfig.FunctionParam[3], XUiHelper.TimeFormatType.SHOP)
    self.TxtCostTime.text = dataTime
    self.TxtSlotName.text = slotConfig.Name
    self.TxtProductName.text = CS.XTextManager.GetText("HostelProductElectric")
    local deviceConfig = XDataCenter.HostelManager.GetFuncDeviceCurLvlTemplate(XDataCenter.HostelManager.FunctionDeviceType.PowerStation)
    if not deviceConfig then return end
    local slotData = XDataCenter.HostelManager.GetWorkCharBySlot(self.SlotType)
    if slotData and slotData.BeginTime > 0 then
        self.PanelRight.gameObject:SetActive(false)
        local curTime = XTime.Now()
        local passTime = curTime - slotData.BeginTime
        local electric = math.floor(passTime/slotConfig.FunctionParam[3]) *(slotConfig.FunctionParam[4] + deviceConfig.FunctionParam[4])
        if electric < 0 then
            electric = 0
        end
        self.TxtProductValue.text = tostring(electric).."/"..tostring(slotConfig.FunctionParam[1] *(slotConfig.FunctionParam[4] + deviceConfig.FunctionParam[4]))
    else
        self.PanelRight.gameObject:SetActive(true)
        self.TxtProductValue.text = CS.XTextManager.GetText("HostelPerSlot",slotConfig.FunctionParam[1] *(slotConfig.FunctionParam[4] + deviceConfig.FunctionParam[4]))
    end
end

---工厂信息
function XUiHostelCharacterWork:UpdateFactorySlotInfo(slotConfig)
    self.TxtCostVitality.text = CS.XTextManager.GetText("CharacterVitality",slotConfig.FunctionParam[2])
    local dataTime = XUiHelper.GetTime(slotConfig.FunctionParam[1], XUiHelper.TimeFormatType.SHOP)
    self.TxtCostTime.text = dataTime
    self.TxtSlotName.text = slotConfig.Name
    self.TxtProductName.text = CS.XTextManager.GetText("HostelSlotProduct", XDataCenter.ItemManager.GetItemName(slotConfig.FunctionParam[3]))

    local deviceConfig = XDataCenter.HostelManager.GetFuncDeviceCurLvlTemplate(XDataCenter.HostelManager.FunctionDeviceType.Factory)
    if not deviceConfig then return end
    local count = slotConfig.FunctionParam[4] + deviceConfig.FunctionParam[1]
    self.TxtProductValue.text = CS.XTextManager.GetText("HostelPerSlot",count)
end


function XUiHostelCharacterWork:UpdateIdleList()
    local charList = XDataCenter.CharacterManager.GetOwnCharacterList() or {}
    local idleCharList = {}
    for i,v in ipairs(charList) do
        if XDataCenter.HostelManager.IsCharacterInRest(v.Id) and not XDataCenter.HostelManager.IsCharacterInWork(v.Id) then
            table_insert(idleCharList,v)
        end
    end


    table.sort(idleCharList, function (a,b)
        return a.Id > b.Id
    end )

    local datas = {}
    for i,v in ipairs(idleCharList) do
        table_insert(datas,{Index = i, Id = v.Id})
    end
    local callback = function (index, charId)
        self:OnSelectIdleItem(index)
    end
    local onCreate = function(item, data)
        item:SetData(data.Index,data.Id)
        item:SetClickCallBack(callback)
    end
    XUiHelper.CreateTemplates(self, self.IdleCharUiItem, datas, XUiGridIdleCharacter.New, self.GridIdleCharacter.gameObject, self.PanelIdleCharContent, onCreate)
    if #datas > 0 and self.CurSelectIndex == 0 then
        self:OnSelectIdleItem(1)
    end
end

function XUiHostelCharacterWork:OnSelectIdleItem(index)
    if self.CurSelectIndex > 0 then
        self.IdleCharUiItem[self.CurSelectIndex]:SetSelect(false)
    end
    self.CurSelectIndex = index
    if self.CurSelectIndex > 0 then
        self.IdleCharUiItem[self.CurSelectIndex]:SetSelect(true)
        local charId = self.IdleCharUiItem[self.CurSelectIndex]:GetCharId()
        self:UpdateSceneCharModel(charId)
    end
end

function XUiHostelCharacterWork:UpdateSceneCharModel(charId)
    local hud = self.DeviceObj:GetDisplayHud()
    if hud then
        hud:HideContent()
    end
    -- body
    -- 现在选择模型
end

