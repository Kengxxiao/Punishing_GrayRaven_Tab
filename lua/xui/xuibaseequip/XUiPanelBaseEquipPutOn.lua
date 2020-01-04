local XUiGridBaseEquip = require("XUi/XUiBaseEquip/XUiGridBaseEquip")
local XUiPanelPutOnShowTip = require("XUi/XUiBaseEquip/XUiPanelPutOnShowTip")
local XUiBaseEquipInfo = require("XUi/XUiBaseEquip/XUiPanelBaseEquipInfo")
local XUiPanelBaseEquipRecycle = require("XUi/XUiBaseEquip/XUiPanelBaseEquipRecycle")
local XUiPanelBaseEquipPutOn = XClass()

function XUiPanelBaseEquipPutOn:Ctor(ui, parent)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Parent = parent
    self:InitAutoScript()

    self.PutOnTipPanel = XUiPanelPutOnShowTip.New(self.PanelPutOnShowTip)
    self.RecyclePanel = XUiPanelBaseEquipRecycle.New(self.PanelBaseEquipRecycle, self, self.Parent)
    self.BaseEquipInfoPanel = XUiBaseEquipInfo.New(self.PanelBaseEquipInfo, self.Parent)
    self.SelectedGrid = XUiGridBaseEquip.New(self.GridBaseEquipSelected, self.RecyclePanel)
    self.SelectedGrid:Init(self.Parent, self)
    self.RecycleEquipList = {}

    self:AddCoinListener()
    self:ResetUi()
    self:InitDynamicTable()
end

function XUiPanelBaseEquipPutOn:ResetUi()
    self.BtnPutOn.gameObject:SetActive(false)
    self.GridBaseEquipSelected.gameObject:SetActive(false)
    self.PanelBaseEquipList.gameObject:SetActive(true)
    self.PutOnTipPanel:HidePanel()
end

function XUiPanelBaseEquipPutOn:InitDynamicTable()
    self.DynamicTable = XDynamicTableNormal.New(self.PanelBaseEquipView.gameObject)
    self.DynamicTable:SetProxy(XUiGridBaseEquip)
    self.DynamicTable:SetDelegate(self)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelBaseEquipPutOn:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiPanelBaseEquipPutOn:AutoInitUi()
    self.PanelPart = self.Transform:Find("PanelPart")
    self.GridBaseEquipSelected = self.Transform:Find("PanelPart/GridBaseEquipSelected")
    self.PanelEmpty = self.Transform:Find("PanelPart/PanelEmpty")
    self.TxtPart = self.Transform:Find("PanelPart/PanelEmpty/TxtPart"):GetComponent("Text")
    self.TxtDesc = self.Transform:Find("PanelPart/PanelEmpty/TxtDesc"):GetComponent("Text")
    self.BtnEquipInfo = self.Transform:Find("PanelPart/BtnEquipInfo"):GetComponent("Button")
    self.PanelTogglePos = self.Transform:Find("PanelTogglePos")
    self.Toggle1 = self.Transform:Find("PanelTogglePos/Toggle1"):GetComponent("Toggle")
    self.ImgNew1 = self.Transform:Find("PanelTogglePos/Toggle1/ImgNew1"):GetComponent("Image")
    self.Toggle2 = self.Transform:Find("PanelTogglePos/Toggle2"):GetComponent("Toggle")
    self.ImgNew2 = self.Transform:Find("PanelTogglePos/Toggle2/ImgNew2"):GetComponent("Image")
    self.Toggle3 = self.Transform:Find("PanelTogglePos/Toggle3"):GetComponent("Toggle")
    self.ImgNew3 = self.Transform:Find("PanelTogglePos/Toggle3/ImgNew3"):GetComponent("Image")
    self.Toggle4 = self.Transform:Find("PanelTogglePos/Toggle4"):GetComponent("Toggle")
    self.ImgNew4 = self.Transform:Find("PanelTogglePos/Toggle4/ImgNew4"):GetComponent("Image")
    self.Toggle5 = self.Transform:Find("PanelTogglePos/Toggle5"):GetComponent("Toggle")
    self.ImgNew5 = self.Transform:Find("PanelTogglePos/Toggle5/ImgNew5"):GetComponent("Image")
    self.Toggle6 = self.Transform:Find("PanelTogglePos/Toggle6"):GetComponent("Toggle")
    self.ImgNew6 = self.Transform:Find("PanelTogglePos/Toggle6/ImgNew6"):GetComponent("Image")
    self.PanelBaseEquipList = self.Transform:Find("PanelBaseEquipList")
    self.PanelBaseEquipView = self.Transform:Find("PanelBaseEquipList/PanelBaseEquipView")
    self.PanelBaseEquipRecycle = self.Transform:Find("PanelBaseEquipRecycle")
    self.BtnPutOn = self.Transform:Find("BtnPutOn"):GetComponent("Button")
    self.TxtEmptyTip = self.Transform:Find("TxtEmptyTip"):GetComponent("Text")
    self.TxtCapacity = self.Transform:Find("TxtCapacity"):GetComponent("Text")
    self.TxtCoinNum = self.Transform:Find("TxtCoinNum"):GetComponent("Text")
    self.PanelPutOnShowTip = self.Transform:Find("PanelPutOnShowTip")
    self.BtnRecycle = self.Transform:Find("BtnRecycle"):GetComponent("Button")
    self.PanelBaseEquipInfo = self.Transform:Find("PanelBaseEquipInfo")
end

function XUiPanelBaseEquipPutOn:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelBaseEquipPutOn:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelBaseEquipPutOn:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelBaseEquipPutOn:AutoAddListener()
    self:RegisterClickEvent(self.BtnEquipInfo, self.OnBtnEquipInfoClick)
    self:RegisterClickEvent(self.Toggle1, self.OnToggle1Click)
    self:RegisterClickEvent(self.Toggle2, self.OnToggle2Click)
    self:RegisterClickEvent(self.Toggle3, self.OnToggle3Click)
    self:RegisterClickEvent(self.Toggle4, self.OnToggle4Click)
    self:RegisterClickEvent(self.Toggle5, self.OnToggle5Click)
    self:RegisterClickEvent(self.Toggle6, self.OnToggle6Click)
    self:RegisterClickEvent(self.BtnPutOn, self.OnBtnPutOnClick)
    self:RegisterClickEvent(self.BtnRecycle, self.OnBtnRecycleClick)
end
-- auto

function XUiPanelBaseEquipPutOn:OnBtnEquipInfoClick(eventData)
    if not self.CurIndex then
        return
    end

    local baseEquip = XDataCenter.BaseEquipManager.GetBaseEquipByPart(self.CurPart)
    if not baseEquip then
        return
    end
    self.BaseEquipInfoPanel:ShowPanel(baseEquip)
end

function XUiPanelBaseEquipPutOn:OnBtnRecycleClick(eventData)
    self:ShowRecyclePanel()
end

function XUiPanelBaseEquipPutOn:OnToggle1Click(eventData)
    self:ShowPanel(1)
end

function XUiPanelBaseEquipPutOn:OnToggle2Click(eventData)
    self:ShowPanel(2)
end

function XUiPanelBaseEquipPutOn:OnToggle3Click(eventData)
    self:ShowPanel(3)
end

function XUiPanelBaseEquipPutOn:OnToggle4Click(eventData)
    self:ShowPanel(4)
end

function XUiPanelBaseEquipPutOn:OnToggle5Click(eventData)
    self:ShowPanel(5)
end

function XUiPanelBaseEquipPutOn:OnToggle6Click(eventData)
    self:ShowPanel(6)
end

function XUiPanelBaseEquipPutOn:OnBtnPutOnClick(...)
    if not self.CurIndex then
        return
    end

    local baseEquip = self.BaseEquipList[self.CurIndex]
    if not baseEquip then
        return 
    end 

    local oldBaseEquip = XDataCenter.BaseEquipManager.GetBaseEquipByPart(self.CurPart)
    XDataCenter.BaseEquipManager.PutOn(baseEquip.Id, function()
        self.PutOnTipPanel:ShowPanel(baseEquip.Id, oldBaseEquip and oldBaseEquip.Id or nil)
        self:UpdateSelectedGrid(baseEquip)
        self:HidePutOn()
        self:ResetGrids()
        self.CurGrid:SetPutOn(true)
    end)
end

function XUiPanelBaseEquipPutOn:SetRecycleByStar(star, recycle)
    for index, data in pairs(self.BaseEquipList) do
        if XDataCenter.BaseEquipManager.GetBaseEquipStar(data.TemplateId) == star then
            if recycle then
                self:AddToRecycleList(data.Id)
            else
                self:RemoveFromRecycleList(data.Id)
            end

            local grid = self.DynamicTable:GetGridByIndex(index)
            if grid then
                grid:SetRecycle(recycle)
            end
        end
    end
end

function XUiPanelBaseEquipPutOn:ResetGrids()
    for index, data in pairs(self.BaseEquipList) do
        local grid = self.DynamicTable:GetGridByIndex(index)
        if grid then
            grid:SetPutOn(false)
            grid:SetRecycle(false)
        end
    end
end

function XUiPanelBaseEquipPutOn:ShowRecyclePanel()
    self.RecycleMode = true
    if self.CurGrid then
        self.CurGrid:SetSelect(false)
        self.CurGrid = nil
        self.CurIndex = 0
    end
    self.BtnPutOn.gameObject:SetActive(false)
    self.BtnRecycle.gameObject:SetActive(false)
    self.PanelBaseEquipRecycle.gameObject:SetActive(true)
    local isShow = XDataCenter.BaseEquipManager.CheckNewHintByPart(self.CurPart)
    self["ImgNew" .. self.CurPart].gameObject:SetActive(isShow)
    self.BaseEquipList = XDataCenter.BaseEquipManager.GetBaseEquipNotPutOnListByPart(self.CurPart)
    self:ReloadDynamicTable()
end

function XUiPanelBaseEquipPutOn:HideRecyclePanel()
    self.RecycleMode = false
    self.PanelBaseEquipRecycle.gameObject:SetActive(false)
    self.BtnRecycle.gameObject:SetActive(true)
    self:ClearRecycleList()
    self.RecyclePanel:RefreshRecyclePanel()
    local isShow = XDataCenter.BaseEquipManager.CheckNewHintByPart(self.CurPart)
    self["ImgNew" .. self.CurPart].gameObject:SetActive(isShow)
    self.BaseEquipList = XDataCenter.BaseEquipManager.GetBaseEquipListByPart(self.CurPart)
    self:ReloadDynamicTable()
end

function XUiPanelBaseEquipPutOn:UpdateSelectedGrid(baseEquip)
    self.SelectedGrid:Refresh(baseEquip)
end

function XUiPanelBaseEquipPutOn:ShowPanel(part)
    self:ResetUi()
    self.CurPart = part
    self.CurGrid = nil
    self.CurIndex = 0
    if self.RecycleMode then
        self.BaseEquipList = XDataCenter.BaseEquipManager.GetBaseEquipNotPutOnListByPart(part)
        self:ClearRecycleList()
        self.RecyclePanel:RefreshRecyclePanel()
    else
        self.BaseEquipList = XDataCenter.BaseEquipManager.GetBaseEquipListByPart(part)
    end
    
    self:HidePutOn()
    self.GameObject:SetActive(true)
    self["Toggle" .. part].isOn = true

    for i = 1, 6 do
        local isShow = XDataCenter.BaseEquipManager.CheckNewHintByPart(i)
        self["ImgNew" .. i].gameObject:SetActive(isShow)
    end

    self.TxtPart.text = part
    local curType = math.ceil(part /2)
    self.TxtDesc.text = CS.XTextManager.GetText("BaseEquipType" .. curType)
    self:UpdateSelectedGrid(XDataCenter.BaseEquipManager.GetBaseEquipByPart(part))
    self:ReloadDynamicTable()
end

function XUiPanelBaseEquipPutOn:ReloadDynamicTable()
    if self.CurGrid then
        self.CurGrid:SetSelect(false)
    end

    local count = #self.BaseEquipList
    self.TxtEmptyTip.gameObject:SetActive(count <= 0)
    self.DynamicTable:SetDataSource(self.BaseEquipList)
    self.DynamicTable:ReloadDataASync(count > 0 and 1 or -1)

    self.TxtCapacity.text = count
end

function XUiPanelBaseEquipPutOn:HidePanel()
    self.GameObject:SetActive(false)
end

function XUiPanelBaseEquipPutOn:IsShow()
    return self.GameObject.activeSelf
end

function XUiPanelBaseEquipPutOn:ShowPutOn()
    self.BtnPutOn.gameObject:SetActive(true)
end

function XUiPanelBaseEquipPutOn:HidePutOn()
    self.BtnPutOn.gameObject:SetActive(false)
end

function XUiPanelBaseEquipPutOn:AddCoinListener()
    local coinID = XDataCenter.ItemManager.ItemId.BaseEquipCoin
    XDataCenter.ItemManager.AddCountUpdateListener(coinID, function ()
        self:UpdateBaseEquipCoin()
    end, self.TxtCoinNum)
    self:UpdateBaseEquipCoin()
end

function XUiPanelBaseEquipPutOn:UpdateBaseEquipCoin()
    local coinID = XDataCenter.ItemManager.ItemId.BaseEquipCoin
    self.TxtCoinNum.text = XDataCenter.ItemManager.GetItem(coinID).Count
end

function XUiPanelBaseEquipPutOn:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:Init(self.Parent, self)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local data = self.BaseEquipList[index]
        grid:Refresh(data)
        grid:SetSelect(index == self.CurIndex)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then
        local data = self.BaseEquipList[index]
        if self.RecycleMode then
            if self:CheckRecycle(data.Id) then
                self:RemoveFromRecycleList(data.Id)
                self.RecyclePanel:RefreshRecyclePanel()
                grid:SetRecycle(false)
            else
                self:AddToRecycleList(data.Id)
                self.RecyclePanel:RefreshRecyclePanel()
                grid:SetRecycle(true)
            end
        else
            local oldEquip = XDataCenter.BaseEquipManager.GetBaseEquipByPart(self.CurPart)

            if oldEquip == nil or data.Id ~= oldEquip.Id then
                self:ShowPutOn()
            else
                self:HidePutOn()
            end

            if self.CurGrid then
            self.CurGrid:SetSelect(false)
            end

            grid:SetSelect(true)
            self.CurGrid = grid
            self.CurIndex = index
        end
    end
end

function XUiPanelBaseEquipPutOn:AddToRecycleList(equipId)
    self.RecycleEquipList[equipId] = true
end

function XUiPanelBaseEquipPutOn:RemoveFromRecycleList(equipId)
    self.RecycleEquipList[equipId] = nil
end

function XUiPanelBaseEquipPutOn:CheckRecycle(equipId)
    return self.RecycleEquipList[equipId] ~= nil
end

function XUiPanelBaseEquipPutOn:ClearRecycleList()
    self.RecycleEquipList = {}
end

function XUiPanelBaseEquipPutOn:GetRecycleEquipCount()
    local count = 0
    for k , v in pairs(self.RecycleEquipList) do
        count = count + 1
    end
    return count
end

function XUiPanelBaseEquipPutOn:GetRecycleEquipReward()
    local rewardGoodsList = {}
    for id, _ in pairs(self.RecycleEquipList) do
        local equip = XDataCenter.BaseEquipManager.GetBaseEquipById(id)
        local rewardId = XDataCenter.BaseEquipManager.GetBaseEquipRecoveryRewardId(equip.TemplateId)
        if rewardId then
            local rewardList = XRewardManager.GetRewardList(rewardId)
            for _, reward in pairs(rewardList) do
                table.insert(rewardGoodsList, reward)
            end
        end
    end

    return XRewardManager.MergeAndSortRewardGoodsList(rewardGoodsList)
end

function XUiPanelBaseEquipPutOn:RefreshAfterRecycle()
    self:HideRecyclePanel()
end

return XUiPanelBaseEquipPutOn
