XUiPanelTaskWeekly = XClass()

function XUiPanelTaskWeekly:Ctor(ui, parent)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Parent = parent
    XTool.InitUiObject(self)

    self.DynamicTable = XDynamicTableNormal.New(self.PanelTaskWeeklyList)
    self.DynamicTable:SetProxy(XDynamicDailyTask)
    self.DynamicTable:SetDelegate(self)
end

function XUiPanelTaskWeekly:ShowPanel()
    self.GameObject:SetActive(true)
    
    self.WeeklyTasks = XDataCenter.TaskManager.GetWeeklyTaskList()
    self.PanelNoneWeeklyTask.gameObject:SetActive(#self.WeeklyTasks<=0)
    self.DynamicTable:SetDataSource(self.WeeklyTasks)
    self.DynamicTable:ReloadDataASync()
end

function XUiPanelTaskWeekly:HidePanel(...)
    self.GameObject:SetActive(false)
end

function XUiPanelTaskWeekly:Refresh()
    self.WeeklyTasks = XDataCenter.TaskManager.GetWeeklyTaskList()
    self.PanelNoneWeeklyTask.gameObject:SetActive(#self.WeeklyTasks<=0)
    self.DynamicTable:SetDataSource(self.WeeklyTasks)
    self.DynamicTable:ReloadDataSync()
end


--动态列表事件
function XUiPanelTaskWeekly:OnDynamicTableEvent(event,index,grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local data = self.WeeklyTasks[index]
        grid.RootUi = self.Parent
        grid:ResetData(data)
    end
end
