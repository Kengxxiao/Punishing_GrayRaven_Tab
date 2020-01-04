local XUiSignBanner = XLuaUiManager.Register(XLuaUi, "UiSignBanner")
local XUiSignPrefabContent = require("XUi/XUiSignIn/XUiSignPrefabContent")
local XUiSignFirstRecharge = require("XUi/XUiSignIn/XUiSignFirstRecharge")
local XUiSignCard = require("XUi/XUiSignIn/XUiSignCard")

function XUiSignBanner:OnAwake()
    self:AddListener()
    XEventManager.AddEventListener(XEventId.EVENT_SING_IN_OPEN_BTN, self.SetBtnActive, self)
end

function XUiSignBanner:OnStart(configId)
    self.Config = XSignInConfigs.GetWelfareConfig(configId)
    self:SetBtnActive(false)
    self:SetInfo(configId)
end

function XUiSignBanner:AddListener()
    self:RegisterClickEvent(self.BtnClose, self.OnBtnCloseClick)
end

function XUiSignBanner:OnBtnCloseClick()
    self:Close()
    XDataCenter.AutoWindowManager.NextAutoWindow()
end

function XUiSignBanner:SetInfo(configId)
    local path = XSignInConfigs.GetPrefabPath(configId)

    self.Resource = CS.XResourceManager.Load(path)
    local prefab = CS.UnityEngine.Object.Instantiate(self.Resource.Asset)
    prefab.transform:SetParent(self.PanelSigGrid, false)
    prefab.gameObject:SetLayerRecursively(self.PanelSigGrid.gameObject.layer)

    if self.Config.FunctionType == XAutoWindowConfigs.AutoFuncitonType.Sign then
        self.SignPrefabContent = XUiSignPrefabContent.New(prefab, self)
    elseif self.Config.FunctionType == XAutoWindowConfigs.AutoFuncitonType.FirstRecharge then
        self.SignPrefabContent = XUiSignFirstRecharge.New(prefab, self)
    elseif self.Config.FunctionType == XAutoWindowConfigs.AutoFuncitonType.Card then
        self.SignPrefabContent = XUiSignCard.New(prefab, self)
    end

    self.SignPrefabContent:Refresh(self.Config.SubConfigId, true)
end

function XUiSignBanner:SetBtnActive(active, dayRewardConfig)
    if dayRewardConfig and self.SignPrefabContent then
        self.SignPrefabContent:SetTomorrowOpen(dayRewardConfig)
    end

    if self.Config.FunctionType == XAutoWindowConfigs.AutoFuncitonType.Sign then
        self.PanelMask.gameObject:SetActive(not active)
    else
        self.PanelMask.gameObject:SetActive(false)
    end

    self.BtnClose.gameObject:SetActive(active)
    self.PanelCloseDesc.gameObject:SetActive(active)
end

function XUiSignBanner:OnDestroy()
    XEventManager.RemoveEventListener(XEventId.EVENT_SING_IN_OPEN_BTN, self.SetBtnActive, self)

    if self.Resource then
       self.Resource:Release()
    end

    if self.SignPrefabContent then
        CS.UnityEngine.Object.Destroy(self.SignPrefabContent.GameObject)
    end
end