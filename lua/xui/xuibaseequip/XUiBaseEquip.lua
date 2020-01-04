--local XUiBaseEquip = XUiManager.Register("UiBaseEquip")
local XUiBaseEquip = XLuaUiManager.Register(XLuaUi, "UiBaseEquip")

local XUiGridBaseEquip = require("XUi/XUiBaseEquip/XUiGridBaseEquip")
local XUiPanelBaseEquipPutOn = require("XUi/XUiBaseEquip/XUiPanelBaseEquipPutOn")

function XUiBaseEquip:OnAwake()
    self:InitAutoScript()
end

function XUiBaseEquip:OnStart(exitCb)
  
    self.ExitCb = exitCb

    self.GridBaseEquip.gameObject:SetActive(false)
    self.PanelMain.gameObject:SetActive(true)

    self.GridBaseEquipDict = {}
    self.PutOnPanel = XUiPanelBaseEquipPutOn.New(self.PanelBaseEquipPutOn, self)
    self.PutOnPanel:HidePanel()
    self:ShowMainPanel()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiBaseEquip:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiBaseEquip:AutoInitUi()
    self.PanelBaseEquipPutOn = self.Transform:Find("SafeAreaContentPane/PanelBaseEquipPutOn")
    self.PanelMain = self.Transform:Find("SafeAreaContentPane/PanelMain")
    self.BtnPart1 = self.Transform:Find("SafeAreaContentPane/PanelMain/BtnPart1"):GetComponent("Button")
    self.ImgRedPoint1 = self.Transform:Find("SafeAreaContentPane/PanelMain/BtnPart1/ImgRedPoint1"):GetComponent("Image")
    self.BtnPart2 = self.Transform:Find("SafeAreaContentPane/PanelMain/BtnPart2"):GetComponent("Button")
    self.ImgRedPoint2 = self.Transform:Find("SafeAreaContentPane/PanelMain/BtnPart2/ImgRedPoint2"):GetComponent("Image")
    self.BtnPart3 = self.Transform:Find("SafeAreaContentPane/PanelMain/BtnPart3"):GetComponent("Button")
    self.ImgRedPoint3 = self.Transform:Find("SafeAreaContentPane/PanelMain/BtnPart3/ImgRedPoint3"):GetComponent("Image")
    self.BtnPart4 = self.Transform:Find("SafeAreaContentPane/PanelMain/BtnPart4"):GetComponent("Button")
    self.ImgRedPoint4 = self.Transform:Find("SafeAreaContentPane/PanelMain/BtnPart4/ImgRedPoint4"):GetComponent("Image")
    self.BtnPart5 = self.Transform:Find("SafeAreaContentPane/PanelMain/BtnPart5"):GetComponent("Button")
    self.ImgRedPoint5 = self.Transform:Find("SafeAreaContentPane/PanelMain/BtnPart5/ImgRedPoint5"):GetComponent("Image")
    self.BtnPart6 = self.Transform:Find("SafeAreaContentPane/PanelMain/BtnPart6"):GetComponent("Button")
    self.ImgRedPoint6 = self.Transform:Find("SafeAreaContentPane/PanelMain/BtnPart6/ImgRedPoint6"):GetComponent("Image")
    self.GridBaseEquip = self.Transform:Find("SafeAreaContentPane/PanelMain/GridBaseEquip")
    self.PanelTopButton = self.Transform:Find("SafeAreaContentPane/PanelTopButton")
    self.BtnBack = self.Transform:Find("SafeAreaContentPane/PanelTopButton/BtnBack"):GetComponent("Button")
    self.BtnMainUi = self.Transform:Find("SafeAreaContentPane/PanelTopButton/BtnMainUi"):GetComponent("Button")
end

function XUiBaseEquip:AutoAddListener()
    self:RegisterClickEvent(self.BtnPart1, self.OnBtnPart1Click)
    self:RegisterClickEvent(self.BtnPart2, self.OnBtnPart2Click)
    self:RegisterClickEvent(self.BtnPart3, self.OnBtnPart3Click)
    self:RegisterClickEvent(self.BtnPart4, self.OnBtnPart4Click)
    self:RegisterClickEvent(self.BtnPart5, self.OnBtnPart5Click)
    self:RegisterClickEvent(self.BtnPart6, self.OnBtnPart6Click)
    self:RegisterClickEvent(self.BtnBack, self.OnBtnBackClick)
    self:RegisterClickEvent(self.BtnMainUi, self.OnBtnMainUiClick)
end
-- auto

function XUiBaseEquip:OnBtnBackClick(...)
    if self.PutOnPanel:IsShow() then
        self.PutOnPanel:HidePanel()
        self:ShowMainPanel()
        return
    end

    if self.ExitCb then
        self.ExitCb()
    end

    --CS.XUiManager.ViewManager:Pop()
    self:Close()
end

function XUiBaseEquip:OnBtnMainUiClick(...)
    XLuaUiManager.RunMain()
end

function XUiBaseEquip:OnBtnPart1Click(...)
    self:ShowPart(1)
end

function XUiBaseEquip:OnBtnPart2Click(...)
    self:ShowPart(2)
end

function XUiBaseEquip:OnBtnPart3Click(...)
    self:ShowPart(3)
end

function XUiBaseEquip:OnBtnPart4Click(...)
    self:ShowPart(4)
end

function XUiBaseEquip:OnBtnPart5Click(...)
    self:ShowPart(5)
end

function XUiBaseEquip:OnBtnPart6Click(...)
    self:ShowPart(6)
end

function XUiBaseEquip:ShowPart(part)
    self.PutOnPanel:ShowPanel(part)
    self.PanelMain.gameObject:SetActive(false)
end

function XUiBaseEquip:ShowMainPanel()
    self:RefreshBaseEquipInfo()
    self:CheckRedPoint()
    self.PanelMain.gameObject:SetActive(true)
end

function XUiBaseEquip:CreateBaseEquipGrid(part, baseEquip)
    local btnPart = self["BtnPart" .. part]
    if not btnPart then
        return
    end

    local grid = XUiGridBaseEquip.New(CS.UnityEngine.Object.Instantiate(self.GridBaseEquip), baseEquip)
    grid:Init(self, self.PutOnPanel)
    grid:Refresh(baseEquip)
    grid.Transform:SetParent(btnPart.transform, false)
    grid.GameObject:SetActive(true)
    self.GridBaseEquipDict[part] = grid
end

function XUiBaseEquip:RefreshBaseEquipInfo()
    local infoDict = XDataCenter.BaseEquipManager.GetBaseEquipInfo()
    for part, baseEquip in pairs(infoDict) do
        self:UpdateBaseEquip(part, baseEquip)
    end
end

function XUiBaseEquip:CheckRedPoint()
    for part = 1, 6 do
        local panelRedPoint = self["ImgRedPoint" .. part]
        if panelRedPoint then
            panelRedPoint.gameObject:SetActive(XDataCenter.BaseEquipManager.CheckNewHintByPart(part))
        end
    end
end

function XUiBaseEquip:UpdateBaseEquip(part, baseEquip)
    local grid = self.GridBaseEquipDict[part]
    if grid then
        grid:Refresh(baseEquip)
        return
    end

    self:CreateBaseEquipGrid(part, baseEquip)
end
