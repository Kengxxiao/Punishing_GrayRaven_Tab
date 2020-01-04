--local XUiMission = XUiManager.Register("UiMission")
local XUiMission = XLuaUiManager.Register(XLuaUi, "UiMission")

function XUiMission:OnAwake()
    self:InitAutoScript()
end

function XUiMission:OnStart()

    self:Init()
    self:SetupContent()
    --XUiHelper.PlayAnimation(self, "AniMissionBegin")

end

function XUiMission:OnEnable()
    if self.DynamicTable then
        self.DynamicTable:ReloadDataASync()
    end

    XUiHelper.PlayAnimation(self, "AniMissionBegin")
end

function XUiMission:Init()
    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.FreeGem, XDataCenter.ItemManager.ItemId.ActionPoint, XDataCenter.ItemManager.ItemId.Coin)

    self.DynamicTable = XDynamicTableNormal.New(self.PanelTaskList)
    self.DynamicTable:SetProxy(XUiPanelMissionGrid)
    self.DynamicTable:SetDelegate(self)

    self.Timer = nil
    self.PanelPointRect = self.PanelPreview:GetComponent("RectTransform")
    self.CompletetTaskList = {}
    local sections = XDataCenter.TaskForceManager.GetTaskForceSectionConfig()
    self.PanelArea.gameObject:SetActive(false)
    self.ProgressPoint = {}
    for i, v in pairs(sections) do
        local point = CS.UnityEngine.Object.Instantiate(self.PanelArea)
        point.transform:SetParent(self.PanelPreview, false)
        point.gameObject:SetActive(true)
        local area = XUiPanelArea.New(point, v, self)
        table.insert(self.ProgressPoint, area)
    end

    XEventManager.AddEventListener(XEventId.EVENT_TASKFORCE_REFRESH_REQUEST, self.SetupContent, self)
    XEventManager.AddEventListener(XEventId.EVENT_TASKFORCE_ACCEPT_TASK_REQUEST, self.SetupContent, self)
    XEventManager.AddEventListener(XEventId.EVENT_TASKFORCE_GIVEUP_TASK_REQUEST, self.SetupContent, self)
    XEventManager.AddEventListener(XEventId.EVENT_TASKFORCE_ACCEPT_REWARD_REQUEST, self.SetupContent, self)
    XEventManager.AddEventListener(XEventId.EVENT_TASKFORCE_COMPLETE_NOTIFY, self.OnTaskComplete, self)
    XEventManager.AddEventListener(XEventId.EVENT_TASKFORCE_TASKFINISH_REQUEST, self.OnTaskComplete, self)
    XEventManager.AddEventListener(XEventId.EVENT_TASKFORCE_SECTIONCHANGE_NOTIFY, self.SetupContent, self)
    XEventManager.AddEventListener(XEventId.EVENT_TASKFORCE_INFO_NOTIFY, self.SetupContent, self)


end

function XUiMission:OnDestroy()
    XEventManager.RemoveEventListener(XEventId.EVENT_TASKFORCE_INFO_NOTIFY, self.SetupContent, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_TASKFORCE_REFRESH_REQUEST, self.SetupContent, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_TASKFORCE_ACCEPT_TASK_REQUEST, self.SetupContent, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_TASKFORCE_GIVEUP_TASK_REQUEST, self.SetupContent, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_TASKFORCE_ACCEPT_REWARD_REQUEST, self.SetupContent, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_TASKFORCE_COMPLETE_NOTIFY, self.OnTaskComplete, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_TASKFORCE_TASKFINISH_REQUEST, self.OnTaskComplete, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_TASKFORCE_SECTIONCHANGE_NOTIFY, self.SetupContent, self)
    self:StopTimer()
end


--任务完成
function XUiMission:OnTaskComplete(taskList)
    if taskList then
        for i, v in pairs(taskList) do
            for index, task in ipairs(self.AllTasks) do
                if task.Task.TaskId == v then
                    local grid = self.DynamicTable:GetGridByIndex(index)
                    if grid ~= nil then
                        grid:PlayCompletedAnimation(function()
                            grid:SetupContent(task)
                        end)
                    end
                end
            end
        end
    end
end

--设置内容
function XUiMission:SetupContent()
    self.MissionData = XDataCenter.TaskForceManager.GetTaskForeInfo()
    if not self.MissionData then
        return
    end

    self:SetupTaskPool()
    self:SetupRefresh()
    self:SetupTaskChapter()
end

--设置任务
function XUiMission:SetupTaskPool()

    local id = self.MissionData.ConfigIndex
    local taskList = self.MissionData.TaskList

    local taskCount = 0
    for i, v in ipairs(taskList) do
        if v.Status ~= XDataCenter.TaskForceManager.TaskForceTaskStatus.Normal then
            taskCount = taskCount + 1
        end
    end

    local taskForeCfg = XDataCenter.TaskForceManager.GetTaskForceConfigById(id)
    if taskForeCfg then
        self.TxtSending.text = tostring(taskForeCfg.MaxTaskForceCount)
    end

    local taskPools = XDataCenter.TaskForceManager.GetTaskPoolInfo()
    if not taskPools then
        return
    end

    self.AllTasks = taskPools
    self.DynamicTable:SetDataSource(taskPools)
    self.DynamicTable:ReloadDataASync(1)
end

--设置刷新
function XUiMission:SetupRefresh()

    local refreshCount = self.MissionData.RefreshCount
    local refreshCfg = XDataCenter.TaskForceManager.GetRefreshInfoByTimes(refreshCount + 1)
    self.RefeshCfg = refreshCfg
    if refreshCfg then
        local item = XDataCenter.ItemManager.GetItem(refreshCfg.ItemId)
        --self:SetUiSprite(self.RImgCostIcon, item.Template.Icon)
        self.RImgCostIcon:SetRawImage(item.Template.Icon)
        self.TxtCost.text = tostring(refreshCfg.ItemCount)
    end

    --剩余免费重置次数
    local totalFreeRefreshCount = XDataCenter.TaskForceManager.GetTotalFreeRefreshTimes()
    local leftTimes = totalFreeRefreshCount - refreshCount
    leftTimes = leftTimes >= 0 and leftTimes or 0

    self.BtnRefreshFree.gameObject:SetActive(leftTimes > 0)
    self.BtnRefresh.gameObject:SetActive(leftTimes <= 0)
    -- self.TxtResetCount.text = tostring(leftTimes)
    local nextRefreshTime = XDataCenter.TaskForceManager.GetNextRefreshTime()
    local curTime = XTime.Now()

    self:UpdateTime()
    if nextRefreshTime > curTime then
        self:StartTimer()
    end

end

function XUiMission:StartTimer()
    if self.Timer then
        self:StopTimer()
    end

    self.Timer = CS.XScheduleManager.ScheduleForever(function()
        self:UpdateTime()
    end, CS.XScheduleManager.SECOND)
end

function XUiMission:StopTimer()
    if self.Timer then
        CS.XScheduleManager.UnSchedule(self.Timer)
        self.Timer = nil
    end
end

function XUiMission:UpdateTime()

    local curTime = XTime.Now()
    local nextRefreshTime = XDataCenter.TaskForceManager.GetNextRefreshTime()

    if not self.TxtTimeRefresh:Exist() then
        return
    end

    local offset = nextRefreshTime - curTime
    if offset > 0 then
        self.TxtTimeRefresh.text = CS.XDate.GetTimeString(math.ceil(offset))
    else
        self.TxtTimeRefresh.text = "00:00:00"
        self:StopTimer()
    end
end

--设置章节信息
function XUiMission:SetupTaskChapter()
    local sectionId = self.MissionData.SectionId
    local sectionCount = XDataCenter.TaskForceManager.GetTotalTaskForeSectionCount()
    local taskSectionCfg = XDataCenter.TaskForceManager.GetTaskForceSectionConfigById(sectionId)

    if not self.ProgressPoint then
        return
    end

    for k, v in pairs(self.ProgressPoint) do
        v:SetCurSection(taskSectionCfg)
    end

end

--动态列表事件
function XUiMission:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:Init(self)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local data = self.AllTasks[index]
        grid:SetupContent(data)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_RECYCLE then
        grid:OnRecycle()
    end
end


-- auto
-- Automatic generation of code, forbid to edit
function XUiMission:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiMission:AutoInitUi()
    self.PanelTopBtn = self.Transform:Find("SafeAreaContentPane/PanelTopBtn")
    self.BtnBack = self.Transform:Find("SafeAreaContentPane/PanelTopBtn/BtnBack"):GetComponent("Button")
    self.BtnMainUi = self.Transform:Find("SafeAreaContentPane/PanelTopBtn/BtnMainUi"):GetComponent("Button")
    self.PanelAsset = self.Transform:Find("SafeAreaContentPane/PanelAsset")
    self.PanelTask = self.Transform:Find("SafeAreaContentPane/PanelTask")
    self.PanelTaskList = self.Transform:Find("SafeAreaContentPane/PanelTask/PanelTaskList")
    self.PanelTop = self.Transform:Find("SafeAreaContentPane/PanelTop")
    self.PanelTimeRefresh = self.Transform:Find("SafeAreaContentPane/PanelTop/PanelTimeRefresh")
    self.TxtTimeRefresh = self.Transform:Find("SafeAreaContentPane/PanelTop/PanelTimeRefresh/TxtTimeRefresh"):GetComponent("Text")
    self.PanelResetCount = self.Transform:Find("SafeAreaContentPane/PanelTop/PanelResetCount")
    self.TxtResetCount = self.Transform:Find("SafeAreaContentPane/PanelTop/PanelResetCount/TxtResetCount"):GetComponent("Text")
    self.PanelSending = self.Transform:Find("SafeAreaContentPane/PanelTop/PanelSending")
    self.ImgRedTag = self.Transform:Find("SafeAreaContentPane/PanelTop/PanelSending/ImgRedTag"):GetComponent("Image")
    self.TxtSending = self.Transform:Find("SafeAreaContentPane/PanelTop/PanelSending/TxtSending"):GetComponent("Text")
    self.BtnTips = self.Transform:Find("SafeAreaContentPane/PanelTop/PanelSending/BtnTips"):GetComponent("Button")
    self.BtnRefresh = self.Transform:Find("SafeAreaContentPane/PanelTop/BtnRefresh"):GetComponent("Button")
    self.PanelRefresh = self.Transform:Find("SafeAreaContentPane/PanelTop/BtnRefresh/PanelRefresh")
    self.RImgCostIcon = self.Transform:Find("SafeAreaContentPane/PanelTop/BtnRefresh/PanelRefresh/RImgCostIcon"):GetComponent("RawImage")
    self.TxtCost = self.Transform:Find("SafeAreaContentPane/PanelTop/BtnRefresh/PanelRefresh/TxtCost"):GetComponent("Text")
    self.BtnRefreshFree = self.Transform:Find("SafeAreaContentPane/PanelTop/BtnRefreshFree"):GetComponent("Button")
    self.PanelDown = self.Transform:Find("SafeAreaContentPane/PanelDown")
    self.PanelPreview = self.Transform:Find("SafeAreaContentPane/PanelDown/PanelPreview")
    self.PanelArea = self.Transform:Find("SafeAreaContentPane/PanelDown/PanelPreview/PanelArea")
    self.BtnPreview = self.Transform:Find("SafeAreaContentPane/PanelDown/BtnPreview"):GetComponent("Button")
end

function XUiMission:GetAutoKey(uiNode, eventName)
    if not uiNode then
        return
    end
    return eventName .. uiNode:GetHashCode()
end

function XUiMission:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then
        return
    end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiMission:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiMission:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterListener(self.BtnBack, "onClick", self.OnBtnBackClick)
    self:RegisterListener(self.BtnMainUi, "onClick", self.OnBtnMainUiClick)
    self:RegisterListener(self.BtnTips, "onClick", self.OnBtnTipsClick)
    self:RegisterListener(self.BtnRefresh, "onClick", self.OnBtnRefreshClick)
    self:RegisterListener(self.BtnRefreshFree, "onClick", self.OnBtnRefreshFreeClick)
    self:RegisterListener(self.BtnPreview, "onClick", self.OnBtnPreviewClick)
end
-- auto
function XUiMission:OnBtnRefreshFreeClick(...)
    self:OnBtnRefreshClick()
end
function XUiMission:OnBtnTipsClick(...)
    --CS.XUiManager.ViewManager:Push("UiMissionTeamLimit", true, false, self.MissionData.ConfigIndex)
    XLuaUiManager.Open("UiMissionTeamLimit",self.MissionData.ConfigIndex)
end

function XUiMission:OnBtnBackClick(...)
    --CS.XUiManager.ViewManager:Pop()
    self:Close()
end

function XUiMission:OnBtnMainUiClick(...)
    XLuaUiManager.RunMain()
end

function XUiMission:OnBtnRefreshClick(...)

    local itemName = XDataCenter.ItemManager.GetItemName(self.RefeshCfg.ItemId)
    XUiManager.DialogTip(CS.XTextManager.GetText("MissionTeamCountTipTile"), string.format(CS.XTextManager.GetText("MissionRefreshTaskContent"), self.RefeshCfg.ItemCount, itemName), XUiManager.DialogType.Normal, nil, function()
        if XDataCenter.TaskForceManager.CheckCanRefresh(self.RefeshCfg.ItemId, self.RefeshCfg.ItemCount) then
            XDataCenter.TaskForceManager.TaskForceRefreshRequest(function()
                XUiHelper.PlayAnimation(self, "AniMissionTaskRefresh")
            end)
        end
    end)

end

function XUiMission:OnSliderChapterValueChanged(...)

end

function XUiMission:OnBtnPreviewClick(...)
    --CS.XUiManager.ViewManager:Push("UiMissionChapter", true, false)
    XLuaUiManager.Open("UiMissionChapter")
end