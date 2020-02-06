local XUiHostelDelegate = XUiManager.Register("UiHostelDelegate")
local table_insert = table.insert
-- auto
-- Automatic generation of code, forbid to edit
function XUiHostelDelegate:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiHostelDelegate:AutoInitUi()
    self.PanelBg = self.Transform:Find("FullScreenBackground/PanelBg")
    self.PanelCharTopButton = self.Transform:Find("SafeAreaContentPane/PanelCharTopButton")
    self.BtnBack = self.Transform:Find("SafeAreaContentPane/PanelCharTopButton/BtnBack"):GetComponent("Button")
    self.PanelLeft = self.Transform:Find("SafeAreaContentPane/PanelLeft")
    self.ScrollView = self.Transform:Find("SafeAreaContentPane/PanelLeft/ScrollView"):GetComponent("Scrollbar")
    self.PanelTabGroup = self.Transform:Find("SafeAreaContentPane/PanelLeft/ScrollView/Viewport/PanelTabGroup")
    self.BtnTab1 = self.Transform:Find("SafeAreaContentPane/PanelLeft/ScrollView/Viewport/PanelTabGroup/BtnTab1"):GetComponent("Button")
    self.TxtNormal = self.Transform:Find("SafeAreaContentPane/PanelLeft/ScrollView/Viewport/PanelTabGroup/BtnTab1/TxtNormal"):GetComponent("Text")
    self.TxtSelected = self.Transform:Find("SafeAreaContentPane/PanelLeft/ScrollView/Viewport/PanelTabGroup/BtnTab1/TxtSelected"):GetComponent("Text")
    self.PanelReport = self.Transform:Find("SafeAreaContentPane/PanelLeft/PanelReport")
    self.BtnReport = self.Transform:Find("SafeAreaContentPane/PanelLeft/PanelReport/BtnReport"):GetComponent("Button")
    self.TxtReleaseCount = self.Transform:Find("SafeAreaContentPane/PanelLeft/PanelReport/TxtReleaseCount"):GetComponent("Text")
    self.TxtCompleteCount = self.Transform:Find("SafeAreaContentPane/PanelLeft/PanelReport/TxtCompleteCount"):GetComponent("Text")
    self.PanelContent = self.Transform:Find("SafeAreaContentPane/PanelContent")
    self.TxtTitle = self.Transform:Find("SafeAreaContentPane/PanelContent/TxtTitle"):GetComponent("Text")
    self.TxtDesc = self.Transform:Find("SafeAreaContentPane/PanelContent/TxtDesc"):GetComponent("Text")
    self.ImgRewardIcon = self.Transform:Find("SafeAreaContentPane/PanelContent/ImgRewardIcon"):GetComponent("Image")
    self.TxtRewardCount = self.Transform:Find("SafeAreaContentPane/PanelContent/TxtRewardCount"):GetComponent("Text")
    self.PanelBottom = self.Transform:Find("SafeAreaContentPane/PanelBottom")
    self.PanelRelease = self.Transform:Find("SafeAreaContentPane/PanelBottom/PanelRelease")
    self.BtnAdd = self.Transform:Find("SafeAreaContentPane/PanelBottom/PanelRelease/BtnAdd"):GetComponent("Button")
    self.BtnMinus = self.Transform:Find("SafeAreaContentPane/PanelBottom/PanelRelease/BtnMinus"):GetComponent("Button")
    self.TxtCount = self.Transform:Find("SafeAreaContentPane/PanelBottom/PanelRelease/TxtCount"):GetComponent("Text")
    self.BtnRelease = self.Transform:Find("SafeAreaContentPane/PanelBottom/PanelRelease/BtnRelease"):GetComponent("Button")
    self.TxtRemainCount = self.Transform:Find("SafeAreaContentPane/PanelBottom/PanelRelease/TxtRemainCount"):GetComponent("Text")
    self.PanelMission = self.Transform:Find("SafeAreaContentPane/PanelBottom/PanelMission")
    self.BtnCancel = self.Transform:Find("SafeAreaContentPane/PanelBottom/PanelMission/BtnCancel"):GetComponent("Button")
    self.BtnHelp = self.Transform:Find("SafeAreaContentPane/PanelBottom/PanelMission/BtnHelp"):GetComponent("Button")
end

function XUiHostelDelegate:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiHostelDelegate:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiHostelDelegate:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiHostelDelegate:AutoAddListener()
    self.AutoCreateListeners = {}
    XUiHelper.RegisterClickEvent(self, self.BtnBack, self.OnBtnBackClick)
    XUiHelper.RegisterClickEvent(self, self.BtnReport, self.OnBtnReportClick)
    XUiHelper.RegisterClickEvent(self, self.BtnAdd, self.OnBtnAddClick)
    XUiHelper.RegisterClickEvent(self, self.BtnMinus, self.OnBtnMinusClick)
    XUiHelper.RegisterClickEvent(self, self.BtnRelease, self.OnBtnReleaseClick)
    XUiHelper.RegisterClickEvent(self, self.BtnCancel, self.OnBtnCancelClick)
    XUiHelper.RegisterClickEvent(self, self.BtnHelp, self.OnBtnHelpClick)
end
-- auto

function XUiHostelDelegate:OnOpen(deviceType)
    
    self:InitAutoScript()
    self.BtnDelegateTypeList = {}
    table_insert(self.BtnDelegateTypeList,self.BtnTab1)
    self.DeviceType = deviceType
    self:UpdateView()
end

function XUiHostelDelegate:UpdateView()
    local bRes, playerId = XDataCenter.HostelManager.IsInVisitFriendHostel()
    if bRes then
        self.IsVisitPlayer = true
        self.PanelMission.gameObject:SetActive(true)
        self.PanelReport.gameObject:SetActive(false)
        self.PanelRelease.gameObject:SetActive(false)
        self.VisitPlayerId = playerId
    else
        self.PanelMission.gameObject:SetActive(false)
        self.PanelReport.gameObject:SetActive(true)
        self.PanelRelease.gameObject:SetActive(true)
    end
    self:UpdateTabGroup()
end

function XUiHostelDelegate:UpdateTabGroup()
    local delegateTypeList = XDataCenter.HostelDelegateManager.GetDelegateListByDeviceType(deviceType)
    if not delegateTypeList or #delegateTypeList == 0 then
        return
    end
    self.DelegateTypeList = delegateTypeList
    for i,ty in ipairs(delegateTypeList) do
        local btn = self.BtnDelegateTypeList[i]
        if not btn then
            btn = CS.UnityEngine.Object.Instantiate(self.BtnTab1)
            btn.transform:SetParent(self.PanelTabGroup, false)
            table.insert(self.BtnDelegateTypeList, btn)
        end
    end
    if self.TabBtnGroup then
        self.TabBtnGroup:Dispose()
    end
    self.TabBtnGroup = XUiTabBtnGroup.New(self.BtnDelegateTypeList, function(index) self:OnSeletDelegateType(index) end)
    for i,v in ipairs(self.TabBtnGroup.TabBtnList) do
        local config = XDataCenter.HostelDelegateManager.GetDelegateTemplateByType(delegateTypeList[i])
        if config then
            btn:SetName(config.DelegateName)
        end
    end
    self.TabBtnGroup:SelectIndex(1)

end

function XUiHostelDelegate:OnSeletDelegateType(index)
    local delegateType = self.DelegateTypeList[index]
    self:UpdeteDelegateDes(delegateType)
    if self.IsVisitPlayer then
        self:UpdateMissonView(delegateType)
    else
        self:UpdatePublishView(delegateType)
    end
end

function XUiHostelDelegate:UpdeteDelegateDes(delegateType)
    local config = XDataCenter.HostelDelegateManager.GetDelegateTemplateByType(delegateType)
    if not config then return end
    self.TxtTitle.text = config.DelegateName
    self.TxtDesc.text = config.ReportDes
end

function XUiHostelDelegate:UpdatePublishView(delegateType)
    local config = XDataCenter.HostelDelegateManager.GetDelegateTemplateByType(delegateType)
    if not config then return end
    local Id, count = XDataCenter.HostelManager.GetDevieWorkSlotPruduct(config.SlotType)
    self:SetUiSprite(self.ImgRewardIcon, XDataCenter.ItemManager.GetItemIcon(Id))
    self.TxtRewardCount.text = math.floor(count * config.PublishAwardPercent / 100 )
end

function XUiHostelDelegate:UpdateMissonView(delegateType)
    local config = XDataCenter.HostelDelegateManager.GetDelegateTemplateByType(delegateType)
    if not config then return end
    local Id, count = XDataCenter.HostelManager.GetDevieWorkSlotPruduct(config.SlotType)
    self:SetUiSprite(self.ImgRewardIcon, XDataCenter.ItemManager.GetItemIcon(Id))
    self.TxtRewardCount.text = math.floor(count * config.AssistAwardPercent / 100 )
end

function XUiHostelDelegate:OnBtnBackClick(...)

end

function XUiHostelDelegate:OnBtnReportClick(...)

end

function XUiHostelDelegate:OnBtnAddClick(...)

end

function XUiHostelDelegate:OnBtnMinusClick(...)

end

function XUiHostelDelegate:OnBtnReleaseClick(...)

end

function XUiHostelDelegate:OnBtnCancelClick(...)

end

function XUiHostelDelegate:OnBtnHelpClick(...)

end
