local XUiBabelTowerTask = XLuaUiManager.Register(XLuaUi, "UiBabelTowerTask")

function XUiBabelTowerTask:OnAwake()
    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.FreeGem, XDataCenter.ItemManager.ItemId.ActionPoint, XDataCenter.ItemManager.ItemId.Coin)
    self.BtnBack.CallBack = function() self:OnBtnBackClick() end
    self.BtnMainUi.CallBack = function() self:OnBtnMainUiClick() end

    self.DynamicTable = XDynamicTableNormal.New(self.SViewTask.gameObject)
    self.DynamicTable:SetProxy(XDynamicGridTask)
    self.DynamicTable:SetDelegate(self)

    XEventManager.AddEventListener(XEventId.EVENT_BABEL_ACTIVITY_STATUS_CHANGED, self.CheckActivityStatus, self)
    XEventManager.AddEventListener(XEventId.EVENT_TASK_SYNC, self.OnTaskChangeSync, self)
end

function XUiBabelTowerTask:OnDestroy()
    self:StopCountDown()
    XEventManager.RemoveEventListener(XEventId.EVENT_BABEL_ACTIVITY_STATUS_CHANGED, self.CheckActivityStatus, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_TASK_SYNC, self.OnTaskChangeSync, self)
end

function XUiBabelTowerTask:OnBtnBackClick()
    self:Close()
end

function XUiBabelTowerTask:OnBtnMainUiClick()
    XLuaUiManager.RunMain()
end

function XUiBabelTowerTask:OnStart()
    self:OnTaskChangeSync()
    self:CreateCountDown()
end

function XUiBabelTowerTask:CreateCountDown()
    self:StopCountDown()
    local time = XTime.GetServerNowTimestamp()
    local curActivityNo = XDataCenter.FubenBabelTowerManager.GetCurrentActivityNo()
    if not curActivityNo then return end
    local activityTemplate = XFubenBabelTowerConfigs.GetBabelTowerActivityTemplateById(curActivityNo)
    if not activityTemplate then return end

    local endTime = XTime.ParseToTimestamp(activityTemplate.EndTimeStr)
    if not endTime then return end
    local leftTimeDesc = CS.XTextManager.GetText("BabelTowerLeftTimeDesc")
    self.TxtTime.text = string.format("%s%s", leftTimeDesc, XUiHelper.GetTime(endTime - time, XUiHelper.TimeFormatType.ACTIVITY))
    self.Timer = CS.XScheduleManager.ScheduleForever(function(...)
        time = XTime.GetServerNowTimestamp()
        if time > endTime then
            self:StopCountDown()
            return
        end
        self.TxtTime.text = string.format("%s%s", leftTimeDesc, XUiHelper.GetTime(endTime - time, XUiHelper.TimeFormatType.ACTIVITY))
    end, CS.XScheduleManager.SECOND, 0)
end

function XUiBabelTowerTask:StopCountDown()
    if self.Timer ~= nil then
        CS.XScheduleManager.UnSchedule(self.Timer)
        self.Timer = nil
    end
end

function XUiBabelTowerTask:OnEnable()
    self:CheckActivityStatus()
end

function XUiBabelTowerTask:CheckActivityStatus()
    if not XLuaUiManager.IsUiShow("UiBabelTowerTask") then return end
    local curActivityNo = XDataCenter.FubenBabelTowerManager.GetCurrentActivityNo()
    if not curActivityNo or not XDataCenter.FubenBabelTowerManager.IsInActivityTime(curActivityNo) then
        XUiManager.TipMsg(CS.XTextManager.GetText("BabelTowerNoneOpen"))
        XLuaUiManager.RunMain()
    end
end

function XUiBabelTowerTask:OnTaskChangeSync()
    self.BabelTowerTasks = XDataCenter.TaskManager.GetBabelTowerTaskList()
    self.DynamicTable:SetDataSource(self.BabelTowerTasks)
    self.DynamicTable:ReloadDataASync()
    self.ImgEmpty.gameObject:SetActiveEx(#self.BabelTowerTasks <= 0)
end

--动态列表事件
function XUiBabelTowerTask:OnDynamicTableEvent(event,index,grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local data = self.BabelTowerTasks[index]
        if not data then return end
        grid.RootUi = self
        grid:ResetData(data)
    end
end
