local ParseToTimestamp = XTime.ParseToTimestamp
local TimestampToGameDateTimeString = XTime.TimestampToGameDateTimeString

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
    local beginTime = ParseToTimestamp(timeLimitTaskCfg.StartTimeStr)
    local endTime = ParseToTimestamp(timeLimitTaskCfg.EndTimeStr)
    if beginTime and endTime then
        local beginTimeStr = TimestampToGameDateTimeString(beginTime, format)
        local endTimeStr = TimestampToGameDateTimeString(endTime, format)
        self.TxtContentTimeTask.text = beginTimeStr .. "~" .. endTimeStr
    end

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