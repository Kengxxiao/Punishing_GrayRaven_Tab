local CSXDateGetTime = CS.XDate.GetTime
local CSXDateFormatTime = CS.XDate.FormatTime

local XUiPanelTask = XClass()

function XUiPanelTask:Ctor(ui, rootUi)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    XTool.InitUiObject(self)

    self.DynamicTable = XDynamicTableNormal.New(self.PanelTaskActivityList)
    self.DynamicTable:SetProxy(XDynamicDailyTask)
    self.DynamicTable:SetDelegate(self)
end

function XUiPanelTask:Refresh(activityCfg)
    if not activityCfg then return end
    self.ActivityCfg = activityCfg 

    local format = "yyyy-MM-dd HH:mm"
    local taskGroupId = activityCfg.Params[1]
    local timeLimitTaskCfg = XTaskConfig.GetTimeLimitTaskCfg(taskGroupId)
    local beginTime = CSXDateGetTime(timeLimitTaskCfg.StartTimeStr)
    local endTime = CSXDateGetTime(timeLimitTaskCfg.EndTimeStr)
    local beginTimeStr = CSXDateFormatTime(beginTime, format)
    local endTimeStr = CSXDateFormatTime(endTime, format)
    
    self.TxtContentTimeTask.text = beginTimeStr .. "~" .. endTimeStr
    self.TxtContentTitleTask.text = activityCfg.ActivityTitle
    self.TxtContentTask.text = activityCfg.ActivityDes

    self:UpdateDynamicTable()
end

function XUiPanelTask:UpdateDynamicTable()
    self.TaskDatas = XDataCenter.ActivityManager.GetActivityTaskData(self.ActivityCfg.Id)
    self.ImgEmpty.gameObject:SetActive(#self.TaskDatas <= 0)
    self.DynamicTable:SetDataSource(self.TaskDatas)
    self.DynamicTable:ReloadDataASync()
end

function XUiPanelTask:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid.RootUi = self.RootUi
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local data = self.TaskDatas[index]

        grid:ResetData(data)
    end
end

return XUiPanelTask