local XUiActivityBriefTask = XLuaUiManager.Register(XLuaUi, "UiActivityBriefTask")

local CSXTextManagerGetText = CS.XTextManager.GetText

function XUiActivityBriefTask:OnAwake()
    self.GridTask.gameObject:SetActiveEx(false)
    self.BtnBack.CallBack = function()
        self:Close()
        if self.CloseCb then self.CloseCb() end
    end
    self:InitDynamicTable()
end

function XUiActivityBriefTask:OnStart(closeCb)
    self.CloseCb = closeCb
    self:InitLeftTime()
end

function XUiActivityBriefTask:OnEnable()
    self:UpdateDynamicTable()
end

function XUiActivityBriefTask:OnGetEvents()
    return { XEventId.EVENT_FINISH_TASK }
end

function XUiActivityBriefTask:OnNotify(evt, ...)
    if evt == XEventId.EVENT_FINISH_TASK then
        self:UpdateDynamicTable()
    end
end

function XUiActivityBriefTask:InitLeftTime()
    local nowTime = XTime.Now()
    local taskBeginTime, taskEndTime = XDataCenter.ActivityBriefManager.GetActivityTaskTime()
    if taskBeginTime > nowTime or nowTime >= taskEndTime then
        self.TxtTime.gameObject:SetActiveEx(false)
    else
        local timeStr = XUiHelper.GetTime(taskEndTime - nowTime, XUiHelper.TimeFormatType.ACTIVITY)
        self.TxtTime.text = CSXTextManagerGetText("ActivityBriefTaskLeftTime", timeStr)
        self.TxtTime.gameObject:SetActiveEx(true)
    end
end

function XUiActivityBriefTask:InitDynamicTable()
    self.DynamicTable = XDynamicTableNormal.New(self.PanelTaskStoryList)
    self.DynamicTable:SetProxy(XDynamicDailyTask)
    self.DynamicTable:SetDelegate(self)
end

function XUiActivityBriefTask:UpdateDynamicTable()
    local taskDatas = XDataCenter.ActivityBriefManager.GetActivityTaskDatas()
    if not next(taskDatas) then
        XUiManager.TipText("ActivityBriefNoTask")
        return
    end
    self.TaskDatas = taskDatas
    self.DynamicTable:SetDataSource(taskDatas)
    self.DynamicTable:ReloadDataASync()
end

function XUiActivityBriefTask:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid.RootUi = self
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local data = self.TaskDatas[index]
        grid:ResetData(data)
    end
end