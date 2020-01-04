local XUiMoneyRewardTask = XLuaUiManager.Register(XLuaUi, "UiMoneyRewardTask")

function XUiMoneyRewardTask:OnAwake()
    self:InitAutoScript()
end

function XUiMoneyRewardTask:OnStart()
   
    self:Init()
    self:SetupContent()

    self.Transform:PlayLegacyAnimation("MoneyRewardTaskBegin")
end

function XUiMoneyRewardTask:OnDestroy()
    XEventManager.RemoveEventListener(XEventId.EVENT_BOUNTYTASK_ACCEPT_TASK, self.OnAsseptTask, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_BOUNTYTASK_TASK_REFRESH, self.SetupContent, self)

end

function XUiMoneyRewardTask:OnAsseptTask()
    self.Transform:PlayLegacyAnimation("MoneyRewardTaskEnd",function()
        self:Close()
    end)
end

--设置任务卡
function XUiMoneyRewardTask:Init()
    self.TaskGrid = {}
    self.TaskGrid[1] = XUiPanelTaskCard.New(self.PanelTaskCard, self)
    for i = 2, XDataCenter.BountyTaskManager.MAX_BOUNTY_TASK_COUNT do
        local ui = CS.UnityEngine.Object.Instantiate(self.PanelTaskCard)
        self.TaskGrid[i] = XUiPanelTaskCard.New(ui, self)
        self.TaskGrid[i].Transform:SetParent(self.PanelTask, false)
    end
    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.FreeGem, XDataCenter.ItemManager.ItemId.ActionPoint, XDataCenter.ItemManager.ItemId.Coin)

    XEventManager.AddEventListener(XEventId.EVENT_BOUNTYTASK_TASK_REFRESH, self.SetupContent, self)
    XEventManager.AddEventListener(XEventId.EVENT_BOUNTYTASK_ACCEPT_TASK, self.OnAsseptTask, self)
end

--设置内容
function XUiMoneyRewardTask:SetupContent()
    self.BountyInfo = XDataCenter.BountyTaskManager.GetBountyTaskInfo()
    if not self.BountyInfo then
        return
    end

    --设置刷新次数
    local taskPoolRefreshCount = self.BountyInfo.TaskPoolRefreshCount
    local leaveRefreshCount = XDataCenter.BountyTaskManager.MAX_BOUNTY_TASK_REFRESH_COUNT - taskPoolRefreshCount
    leaveRefreshCount = leaveRefreshCount >= 0 and leaveRefreshCount or 0
    self.TxtTimes.text = tostring(leaveRefreshCount)

    self:SetupTaskCard()
end

--设置任务卡
function XUiMoneyRewardTask:SetupTaskCard()
    local taskCards = self.BountyInfo.TaskPool
    for i = 1, XDataCenter.BountyTaskManager.MAX_BOUNTY_TASK_COUNT do
        if taskCards[i] then
            self.TaskGrid[i]:SetupTaskCard(taskCards[i])
        else
            self.TaskGrid[i]:SetActive(false)
        end
    end
end


-- auto
-- Automatic generation of code, forbid to edit
function XUiMoneyRewardTask:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiMoneyRewardTask:AutoInitUi()
    self.PanelContent = self.Transform:Find("SafeAreaContentPane/PanelContent")
    self.PanelRefresh = self.Transform:Find("SafeAreaContentPane/PanelContent/PanelRefresh")
    self.TxtTimes = self.Transform:Find("SafeAreaContentPane/PanelContent/PanelRefresh/TxtTimes"):GetComponent("Text")
    self.BtnRefresh = self.Transform:Find("SafeAreaContentPane/PanelContent/PanelRefresh/BtnRefresh"):GetComponent("Button")
    self.PanelTask = self.Transform:Find("SafeAreaContentPane/PanelContent/PanelTask")
    self.PanelTaskCard = self.Transform:Find("SafeAreaContentPane/PanelContent/PanelTask/PanelTaskCard")
    self.PanelAsset = self.Transform:Find("SafeAreaContentPane/PanelAsset")
    self.PanelTopBtn = self.Transform:Find("SafeAreaContentPane/PanelTopBtn")
    self.BtnBack = self.Transform:Find("SafeAreaContentPane/PanelTopBtn/BtnBack"):GetComponent("Button")
    self.BtnMainUi = self.Transform:Find("SafeAreaContentPane/PanelTopBtn/BtnMainUi"):GetComponent("Button")
end

function XUiMoneyRewardTask:AutoAddListener()
    self:RegisterClickEvent(self.BtnRefresh, self.OnBtnRefreshClick)
    self:RegisterClickEvent(self.BtnBack, self.OnBtnBackClick)
    self:RegisterClickEvent(self.BtnMainUi, self.OnBtnMainUiClick)
end
-- auto
--刷新
function XUiMoneyRewardTask:OnBtnRefreshClick(...)
    if not self.BountyInfo then
        return
    end

    local taskPoolRefreshCount = self.BountyInfo.TaskPoolRefreshCount
    local leaveRefreshCount = XDataCenter.BountyTaskManager.MAX_BOUNTY_TASK_REFRESH_COUNT - taskPoolRefreshCount
    if leaveRefreshCount <= 0 then
        XUiManager.TipMsg(CS.XTextManager.GetText("BountyTaskRefreshCountNotEnough"))
        return
    end

    XDataCenter.BountyTaskManager.RefreshBountyTaskPool(function()
        self.Transform:PlayLegacyAnimation("MoneyRewardTaskBeginRefresh")
    end)
end

function XUiMoneyRewardTask:OnBtnBackClick(...)
    self.Transform:PlayLegacyAnimation("MoneyRewardTaskEnd", function()
        XDataCenter.BountyTaskManager.SetSelectIndex(-1)
        --CS.XUiManager.ViewManager:Pop()
        self:Close()
    end)

end

function XUiMoneyRewardTask:OnBtnMainUiClick(...)
    XDataCenter.BountyTaskManager.SetSelectIndex(-1)
    XLuaUiManager.RunMain()
end