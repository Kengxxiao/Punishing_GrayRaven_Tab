local XUiGridActivityBranchReward = require("XUi/XUiActivityBranch/XUiGridActivityBranchReward")

local XUiActivityBranchReward = XLuaUiManager.Register(XLuaUi, "UiActivityBranchReward")

function XUiActivityBranchReward:OnAwake()
    self:InitAutoScript()
    self:InitDynamicTable()
end

function XUiActivityBranchReward:OnStart(sectionCfgs,curSectionId)
    self.SectionCfgs = sectionCfgs
    self.CurSectionId = curSectionId
    self:RefreshDynamicTable()
end

function XUiActivityBranchReward:InitDynamicTable()
    self.DynamicTable = XDynamicTableNormal.New(self.PanelScroll)
    self.DynamicTable:SetProxy(XUiGridActivityBranchReward)
    self.DynamicTable:SetDelegate(self)
end

function XUiActivityBranchReward:RefreshDynamicTable()
    self.DynamicTable:SetDataSource(self.SectionCfgs)
    self.DynamicTable:ReloadDataASync()
end

--动态列表事件
function XUiActivityBranchReward:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:SetRootUi(self)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        grid:Refresh(self.SectionCfgs[index],self.CurSectionId)
    end
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiActivityBranchReward:InitAutoScript()
    self:AutoAddListener()
end

function XUiActivityBranchReward:AutoAddListener()
    self:RegisterClickEvent(self.BtnBg, self.OnBtnBgClick)
end
-- auto
function XUiActivityBranchReward:OnBtnBgClick(eventData)
    self:Close()
end