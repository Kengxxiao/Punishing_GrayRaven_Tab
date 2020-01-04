local XUiArenaTask = XLuaUiManager.Register(XLuaUi, "UiArenaTask")

function XUiArenaTask:OnAwake()
    self:AutoAddListener()
end

function XUiArenaTask:OnStart(...)
    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.FreeGem, XDataCenter.ItemManager.ItemId.ActionPoint, XDataCenter.ItemManager.ItemId.Coin)

    self.GridTask.gameObject:SetActive(false)

    self.DynamicTable = XDynamicTableNormal.New(self.SViewTask.transform)
    self.DynamicTable:SetProxy(XDynamicGridTask)
    self.DynamicTable:SetDelegate(self)
end

function XUiArenaTask:OnEnable()
    XEventManager.AddEventListener(XEventId.EVENT_FINISH_TASK, self.Refresh, self)
    self:Refresh()
end

function XUiArenaTask:OnDisable()
    XEventManager.RemoveEventListener(XEventId.EVENT_FINISH_TASK, self.Refresh, self)
end

function XUiArenaTask:AutoAddListener()
    self:RegisterClickEvent(self.BtnBack, self.OnBtnBackClick)
    self:RegisterClickEvent(self.BtnMainUi, self.OnBtnMainUiClick)
end

function XUiArenaTask:OnBtnBackClick(eventData)
    self:Close()
end

function XUiArenaTask:OnBtnMainUiClick(eventData)
    XLuaUiManager.RunMain()
end

--动态列表事件
function XUiArenaTask:OnDynamicTableEvent(event,index,grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local data = self.DailyTasks[index]
        grid.RootUi = self
        grid:ResetData(data)
    end
end

function XUiArenaTask:Refresh()
    if not self.GameObject:Exist() then
        return
    end

    self.DailyTasks = XDataCenter.TaskManager.GetArenaChallengeTaskList()
    self.DynamicTable:SetDataSource(self.DailyTasks)
    self.DynamicTable:ReloadDataASync()
end