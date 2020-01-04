local XUiPanelBaseEquipRecycle = XClass()

function XUiPanelBaseEquipRecycle:Ctor(ui, parent, uiRoot)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Parent = parent
    self.RootUI = uiRoot
    self:InitAutoScript()
    self:InitDynamicTable()
end

function XUiPanelBaseEquipRecycle:InitDynamicTable()
    self.DynamicTable = XDynamicTableNormal.New(self.PanelRewardView)
    self.DynamicTable:SetProxy(XUiGridCommon)
    self.DynamicTable:SetDelegate(self)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelBaseEquipRecycle:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiPanelBaseEquipRecycle:AutoInitUi()
    self.PanelRewardView = self.Transform:Find("PanelRewardView")
    self.BtnCloseRecycle = self.Transform:Find("BtnCloseRecycle"):GetComponent("Button")
    self.BtnReset = self.Transform:Find("BtnReset"):GetComponent("Button")
    self.BtnDoRecycle = self.Transform:Find("BtnDoRecycle"):GetComponent("Button")
    self.TxtSelectedNum = self.Transform:Find("TxtSelectedNum"):GetComponent("Text")
    self.TogTwoStar = self.Transform:Find("TogTwoStar"):GetComponent("Toggle")
    self.TogThreeStar = self.Transform:Find("TogThreeStar"):GetComponent("Toggle")
    self.TogFourStar = self.Transform:Find("TogFourStar"):GetComponent("Toggle")
    self.TogOneStar = self.Transform:Find("TogOneStar"):GetComponent("Toggle")
end

function XUiPanelBaseEquipRecycle:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelBaseEquipRecycle:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelBaseEquipRecycle:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelBaseEquipRecycle:AutoAddListener()
    self:RegisterClickEvent(self.BtnCloseRecycle, self.OnBtnCloseRecycleClick)
    self:RegisterClickEvent(self.BtnReset, self.OnBtnResetClick)
    self:RegisterClickEvent(self.BtnDoRecycle, self.OnBtnDoRecycleClick)
    self:RegisterClickEvent(self.TogTwoStar, self.OnTogTwoStarClick)
    self:RegisterClickEvent(self.TogThreeStar, self.OnTogThreeStarClick)
    self:RegisterClickEvent(self.TogFourStar, self.OnTogFourStarClick)
    self:RegisterClickEvent(self.TogOneStar, self.OnTogOneStarClick)
end
-- auto

function XUiPanelBaseEquipRecycle:OnTogOneStarClick(eventData)
    self.Parent:SetRecycleByStar(1, self.TogOneStar.isOn)
    self:RefreshRecyclePanel()
end

function XUiPanelBaseEquipRecycle:OnTogTwoStarClick(eventData)
    self.Parent:SetRecycleByStar(2, self.TogTwoStar.isOn)
    self:RefreshRecyclePanel()
end

function XUiPanelBaseEquipRecycle:OnTogThreeStarClick(eventData)
    self.Parent:SetRecycleByStar(3, self.TogThreeStar.isOn)
    self:RefreshRecyclePanel()
end

function XUiPanelBaseEquipRecycle:OnTogFourStarClick(eventData)
    self.Parent:SetRecycleByStar(4, self.TogFourStar.isOn)
    self:RefreshRecyclePanel()
end

function XUiPanelBaseEquipRecycle:OnBtnDoRecycleClick(eventData)
    local idList = {}
    for id, _ in pairs(self.Parent.RecycleEquipList) do
        table.insert(idList, id)
    end
    XDataCenter.BaseEquipManager.Recycle(idList, function()
        self.Parent:RefreshAfterRecycle()
    end)
end

function XUiPanelBaseEquipRecycle:RefreshRecyclePanel()
    self.TxtSelectedNum.text = self.Parent:GetRecycleEquipCount()

    self.RewardList = self.Parent:GetRecycleEquipReward()
    self.DynamicTable:SetDataSource(self.RewardList)
    self.DynamicTable:ReloadDataASync()
end

function XUiPanelBaseEquipRecycle:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:Init(self.RootUI)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local data = self.RewardList[index]
        grid:Refresh(data)
    end
end

function XUiPanelBaseEquipRecycle:OnBtnCloseRecycleClick(eventData)
    self.TogOneStar.isOn = false
    self.TogTwoStar.isOn = false
    self.TogThreeStar.isOn = false
    self.TogFourStar.isOn = false
    self.Parent:HideRecyclePanel()
end

function XUiPanelBaseEquipRecycle:OnBtnResetClick(eventData)
    self.TogOneStar.isOn = false
    self.TogTwoStar.isOn = false
    self.TogThreeStar.isOn = false
    self.TogFourStar.isOn = false
    self.Parent:HideRecyclePanel()
end

return XUiPanelBaseEquipRecycle