XUiPanelDormTaskDaily = XClass()

local DailyTimeSchedule = nil

function XUiPanelDormTaskDaily:Ctor(ui, parent)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Parent = parent

    XTool.InitUiObject(self)
    self.BtnWeekActive.CallBack = function() self:OnBtnBackClick() end

    self:InitPanelActiveGrid()
    self.ItemObjList = {}
    
    -- 自适应调整
    self.OriginPosition = self.PanelActiveGrids[1].Transform.localPosition
    self.ActiveProgressRect = self.ImgDaylyActiveProgress:GetComponent("RectTransform")
    self.ActiveProgressPosition = self.ImgDaylyActiveProgress.transform.localPosition
    self.OffsetPanelPosition = self.PanelContent.localPosition
    self.PanelDailyListRect = self.PanelTaskDailyList

    self:UpdateActiveness()
    self:ShowDailyPanel()

    self.DynamicTable = XDynamicTableNormal.New(self.PanelTaskDailyList.gameObject)
    self.DynamicTable:SetProxy(XDynamicDailyTask)
    self.DynamicTable:SetDelegate(self)

    XRedPointManager.AddRedPointEvent(self.ImgWeek,self.CheckWeeKActiveRedDot,self,{ XRedPointConditions.Types.CONDITION_TASK_WEEK_ACTIVE })
    XDataCenter.ItemManager.AddCountUpdateListener(XDataCenter.ItemManager.ItemId.DailyActiveness, function()
        self:UpdateActiveness()
        self.Parent:CheckDailyTask()
    end, self.TxtDailyActive)
end

--动态列表事件
function XUiPanelDormTaskDaily:OnDynamicTableEvent(event,index,grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local data = self.DailyTasks[index]
        if data == nil then return end
        grid.RootUi = self.Parent
        grid:ResetData(data)
    end
end

--
function XUiPanelDormTaskDaily:CheckWeeKActiveRedDot(count)
    self.ImgWeek.gameObject:SetActive(count >= 0)
end

function XUiPanelDormTaskDaily:InitPanelActiveGrid()
    self.PanelActiveGrids = {}
    self.PanelActiveGridRects = {}
    for i = 1,5,1 do
        local grid = self.PanelActiveGrids[i]
        if not grid then
            if i == 1 then
                grid = XUiPanelActive.New(self.PanelActive, self.Parent, i, self)
            else
                local activeGO = CS.UnityEngine.Object.Instantiate(self.PanelActive)
                activeGO.transform:SetParent(self.PanelContent, false)
                grid = XUiPanelActive.New(activeGO, self.Parent, i, self)
            end
            self.PanelActiveGrids[i] = grid
            self.PanelActiveGridRects[i] = grid.Transform:GetComponent("RectTransform")
        end
    end
end

function XUiPanelDormTaskDaily:UpdateActiveness()
    local dActiveness = XDataCenter.ItemManager.GetDailyActiveness().Count
    local dailyActiveness = XTaskConfig.GetDailyActiveness()
    self.ImgDaylyActiveProgress.fillAmount = dActiveness / XTaskConfig.GetDailyActivenessTotal()
    self.TxtDailyActive.text = dActiveness
    for i = 1, 5 do
        self.PanelActiveGrids[i]:UpdateActiveness(dailyActiveness[i],dActiveness)
    end
    
    -- 自适应
    local activeProgressRectSize = self.ActiveProgressRect.rect.size
    local offsetWidth = self.OffsetPanelPosition.x - self.ActiveProgressPosition.x
    local itemOffset = activeProgressRectSize.x / #self.PanelActiveGrids
    for i = 1, #self.PanelActiveGrids do
        local itemWidth = self.PanelActiveGridRects[i].sizeDelta.x / 2
        local adjustPosition = CS.UnityEngine.Vector3(self.ActiveProgressPosition.x + i * itemOffset - offsetWidth - itemWidth, self.OriginPosition.y, self.OriginPosition.z)
        self.PanelActiveGridRects[i].anchoredPosition3D = adjustPosition
    end
end

function XUiPanelDormTaskDaily:OnBtnBackClick(...)
    self:ShowDailyPanel()
end

function XUiPanelDormTaskDaily:ShowDailyPanel( ... )
    self.PanelDaily.gameObject:SetActive(true)
end

function XUiPanelDormTaskDaily:ShowPanel()
    self:StartSchedule()
    self:UpdateActiveness()
    self.GameObject:SetActive(true)

    local tasks = XDataCenter.TaskManager.GetDormTaskDailyListData()
    self.DailyTasks = tasks
    self.PanelNoneDailyTask.gameObject:SetActive(#self.DailyTasks<=0)
    self.DynamicTable:SetDataSource(tasks)
    self.DynamicTable:ReloadDataASync()
end

function XUiPanelDormTaskDaily:HidePanel(...)
    self:StopSchedule()
    self.GameObject:SetActive(false)
end 

function XUiPanelDormTaskDaily:Refresh(...)
    self:UpdateActiveness()
    local tasks = XDataCenter.TaskManager.GetDormTaskDailyListData()
    self.DailyTasks = tasks
    self.PanelNoneDailyTask.gameObject:SetActive(#self.DailyTasks<=0)
    self.DynamicTable:SetDataSource(tasks)
    self.DynamicTable:ReloadDataASync()
end

function XUiPanelDormTaskDaily:StartSchedule()
    self:StopSchedule()
    DailyTimeSchedule = CS.XScheduleManager.Schedule(function()
        if self.DynamicTable then
            for i=1, #self.DailyTasks do
            local grid = self.DynamicTable:GetGridByIndex(i)
                if grid then
                    grid:UpdateTimes()
                end
            end
        end
    end, 1000 * 60, 0)
end

function XUiPanelDormTaskDaily:StopSchedule()
    if DailyTimeSchedule then
        CS.XScheduleManager.UnSchedule(DailyTimeSchedule)
        DailyTimeSchedule = nil
    end
end