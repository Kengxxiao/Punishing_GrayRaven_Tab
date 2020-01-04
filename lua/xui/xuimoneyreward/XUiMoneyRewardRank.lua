local XUiMoneyRewardRank = XLuaUiManager.Register(XLuaUi, "UiMoneyRewardRank")

function XUiMoneyRewardRank:OnAwake()
    self:InitAutoScript()
end

function XUiMoneyRewardRank:OnStart()
    self:Init()
    self:SetupRewardInfo()
    self.Transform:PlayLegacyAnimation("MoneyRewardRank")
end

function XUiMoneyRewardRank:Init()
    self.DynamicTable = XDynamicTableNormal.New(self.PanelScroll)
    self.DynamicTable:SetProxy(XUiPanelRewardGird)
    self.DynamicTable:SetDelegate(self)
end

--设置内容
function XUiMoneyRewardRank:SetupRewardInfo()
    local config = XDataCenter.BountyTaskManager.GetBountyTaskRankTable()
    if not config then
        return
    end

    local curLevel = XDataCenter.BountyTaskManager.GetBountyTaskInfoRankLevel()

    self.TxtDesc.text = CS.XTextManager.GetText("BountyRankDescContent")
    self.BountyTaskRankConfig = config
    self.DynamicTable:SetDataSource(config)
    self.DynamicTable:ReloadDataSync(#config - curLevel)
end

--动态列表事件
function XUiMoneyRewardRank:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local data = self.BountyTaskRankConfig[index]
        grid.Parent = self
        grid:SetupContent(data)
    end
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiMoneyRewardRank:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiMoneyRewardRank:AutoInitUi()
    self.PanelContent = self.Transform:Find("SafeAreaContentPane/PanelContent")
    self.PanelScroll = self.Transform:Find("SafeAreaContentPane/PanelContent/PanelScroll")
    self.PanelRewardGird = self.Transform:Find("SafeAreaContentPane/PanelContent/PanelScroll/Viewport/PanelRewardGird")
    self.BtnBg = self.Transform:Find("FullScreenBackground/BtnBg"):GetComponent("Button")
    self.TxtDesc = self.Transform:Find("SafeAreaContentPane/TxtDesc"):GetComponent("Text")
end

function XUiMoneyRewardRank:AutoAddListener()
    self:RegisterClickEvent(self.BtnBg, self.OnBtnBgClick)
end
-- auto
function XUiMoneyRewardRank:OnBtnBgClick(...)
    --CS.XUiManager.ViewManager:Pop()
    self:Close()
end