local XUiNewPlayerTask = XLuaUiManager.Register(XLuaUi, "UiNewPlayerTask")

local ITEM_TASK_PROGRESS_ID = CS.XGame.ClientConfig:GetInt("NewPlayerTaskExpId")
local FULL_PROGRESS = 0.9

function XUiNewPlayerTask:OnAwake()
    self:InitBottomView()
    self:InitDayTabView()
    self:InitNewbieTaskView()

    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.FreeGem, XDataCenter.ItemManager.ItemId.ActionPoint, XDataCenter.ItemManager.ItemId.Coin)
    self.BtnBack.CallBack = function() self:Close() end
    self.BtnMainUi.CallBack = function() XLuaUiManager.RunMain() end
    self.BtnSkipChat.CallBack = function() self:OnEndTalkClick() end

    XDataCenter.ItemManager.AddCountUpdateListener(ITEM_TASK_PROGRESS_ID, function()
        self:RefreshBottomView()
    end, self.TxtCurProgress)
    self.OnStartState = false
end

function XUiNewPlayerTask:InitNewbieTaskView()
    if not self.DynamicTableNewbieTask then
        self.DynamicTableNewbieTask = XDynamicTableNormal.New(self.SViewTask.gameObject)
        self.DynamicTableNewbieTask:SetProxy(XUiGridNewbieTaskItem)
        self.DynamicTableNewbieTask:SetDelegate(self)
    end
end

function XUiNewPlayerTask:InitDayTabView()

    local tabName = "BtnNewbie"
    self.BtnsTabInfos = XTaskConfig.GetNewPlayerTaskGroupTemplate()
    self.BtnsDayTab = {}
    self.BtnsDayTab[1] = self.BtnNewbieTaskTab
    self.BtnsDayTab[1].gameObject.name = string.format( "%s%d", tabName, 1 )
    self:UpdateTaskListTag(self.BtnsDayTab[1], self.BtnsTabInfos[1].OpenDay)

    for i=2, #self.BtnsTabInfos do
        local btnTab = self.BtnsDayTab[i]
        if not btnTab then
            local tabUi = CS.UnityEngine.Object.Instantiate(self.BtnNewbieTaskTab.gameObject)
            tabUi.name = string.format( "%s%d", tabName, i )
            tabUi.transform:SetParent(self.UiContent, false)
            btnTab = tabUi.transform:GetComponent("XUiButton")
            btnTab:SetName(CS.XTextManager.GetText("NewbieDayTab1", self.BtnsTabInfos[i].OpenDay))
            tabUi:SetActive(true)
            table.insert(self.BtnsDayTab, i, btnTab)
        end
        self:UpdateTaskListTag(btnTab, self.BtnsTabInfos[i].OpenDay)
    end
    
    self.TabBtnGroup:Init(self.BtnsDayTab, function(index) self:OnBtnDaySelected(index) end)
end

function XUiNewPlayerTask:UpdateTaskListTag(tab, openDay)
    local curNewbieTask = XDataCenter.TaskManager.GetNewPlayerTaskListByGroup(openDay)
    if curNewbieTask == nil then 
        tab:ShowTag(true)
        return 
    end
    local unfinishTaskCount = 0
    for k, v in pairs(curNewbieTask) do
        local stateTask = XDataCenter.TaskManager.GetTaskDataById(v)
        if stateTask.State ~= XDataCenter.TaskManager.TaskState.Finish and stateTask.State ~= XDataCenter.TaskManager.TaskState.Invalid then
            tab:ShowTag(false)
            return 
        end
    end
    tab:ShowTag(true)
end

function XUiNewPlayerTask:InitBottomView()
    local newbieActiveness = XTaskConfig.GetTaskNewbieActivenessTemplate()
    self.TotalProgress = {}
    self.TotalCount = #newbieActiveness.Activeness
    self.MaxProgress = newbieActiveness.Activeness[self.TotalCount]
    self.ProgressStage = {}
    for i=1, self.TotalCount do
        self.ProgressStage[i] = newbieActiveness.Activeness[i]
    end
    
    self.ImgProgressRect = self.ImgProgress:GetComponent("RectTransform")
    self.TemplatePositon = self.PanelNewbieActive.transform.localPosition
    self.TemplateRect = self.PanelNewbieActive:GetComponent("RectTransform")
    
    self.TotalProgress[1] = XUiPanelNewbieActive.New(self.PanelNewbieActive.gameObject, self, 1, self.ProgressStage[1])
    for i=2, #self.ProgressStage do
        local progress = self.TotalProgress[i]
        if not progress then
            local ui = CS.UnityEngine.Object.Instantiate(self.PanelNewbieActive)
            ui.transform:SetParent(self.ImgProgress.transform, false)
            progress = XUiPanelNewbieActive.New(ui, self, i, self.ProgressStage[i])
            table.insert(self.TotalProgress, i, progress)
        end
    end
    
end

function XUiNewPlayerTask:UpdateNewbieActivePositions()
    -- 更新位置
    local totalWdith = self.ImgProgressRect.rect.size.x
    local activeWidthOffset = self.TemplateRect.rect.size.x / 2
    for i=1, #self.ProgressStage do
        local currProgress = self.ProgressStage[i] * 1.0 / self.MaxProgress * FULL_PROGRESS
        local progress = self.TotalProgress[i]
        if progress then
            progress.Transform:GetComponent("RectTransform").anchoredPosition3D = CS.UnityEngine.Vector3(currProgress * totalWdith - activeWidthOffset, self.TemplatePositon.y, self.TemplatePositon.z)
        end
    end
end


function XUiNewPlayerTask:OnStart(selectIdx)
    self.OnStartState = true
    self.DefaultIdx = selectIdx
    XEventManager.AddEventListener(XEventId.EVENT_TASK_SYNC, self.OnTaskChangeSync, self)
    XEventManager.AddEventListener(XEventId.EVENT_NEWBIETASK_DAYCHANGED, self.OnTaskChangeSync, self)
end


function XUiNewPlayerTask:OnEnable()
    local hintTab = XDataCenter.TaskManager.GetNewPlayerHint(XDataCenter.TaskManager.NewPlayerLastSelectTab, self.BtnsTabInfos[1].OpenDay)
    hintTab = self.DefaultIdx or self.CurSelectDay or hintTab
    self.DefaultIdx = nil

    local hintFirstOpenTab = string.format("%s%d", XDataCenter.TaskManager.NewPLayerTaskFirstTalk, hintTab)
    local hintTabFirstOpen = XDataCenter.TaskManager.GetNewPlayerHint(hintFirstOpenTab, 0)
    
    self:UpdateTabGroupStatus()
    self.TabBtnGroup:SelectIndex(hintTab)

    -- 不是第一次播放了，可以直接播入場動畫
    if self.OnStartState and hintTabFirstOpen == 1 then
        self:PlayAnimation("AnimEnableOpen", function()
            XLuaUiManager.SetMask(false)
        end,
        function()
            XLuaUiManager.SetMask(true)
        end)
    end
    self.OnStartState = false
end


function XUiNewPlayerTask:OnDestroy()
    XEventManager.RemoveEventListener(XEventId.EVENT_TASK_SYNC, self.OnTaskChangeSync, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_NEWBIETASK_DAYCHANGED, self.OnTaskChangeSync, self)
end


function XUiNewPlayerTask:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:Init(self)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local data = self.CurrentNewbieTasks[index]
        if data ~= nil then
            grid:OnRefreshDatas(data)
        end
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then
   
    end
end

-- [更新底部]
function XUiNewPlayerTask:RefreshBottomView()
    local newbieActiveness = XTaskConfig.GetTaskNewbieActivenessTemplate()
    local count = #newbieActiveness.Activeness
    local maxProgress = newbieActiveness.Activeness[count]
    local taskProgressCount = XDataCenter.ItemManager.GetCount(ITEM_TASK_PROGRESS_ID) or 0
    self.TxtCurProgress.text = taskProgressCount
    self.TxtTotalProgress.text = string.format("/%d", maxProgress)
    local currentProgress = taskProgressCount * 1.0 / maxProgress * FULL_PROGRESS
    self.ImgProgress.fillAmount = (currentProgress > FULL_PROGRESS) and 1 or currentProgress

    for i=1, #self.TotalProgress do
        self.TotalProgress[i]:UpdateNewbieActiveView(taskProgressCount, maxProgress)
    end
    -- 更新
    self:UpdateNewbieActivePositions()
end

-- [更新左边立绘信息]
function XUiNewPlayerTask:RefreshLeftView(day)
    local talkConfig = XDataCenter.TaskManager.GetNewPlayerTaskTalkConfig(day)
    if not talkConfig then return end

    self.RImgTabBoard:SetRawImage(talkConfig.RoleHalfIcon)
    self.TxtBoardName.text = XCharacterConfigs.GetCharacterName(talkConfig.ShowCharId)
    self.TxtBoardPinyin.text = talkConfig.SpellName
end


-- [刷新第几天的任务列表]
function XUiNewPlayerTask:RefreshNewbieTaskView(group)
    local curNewbieTask = XDataCenter.TaskManager.GetNewPlayerTaskListByGroup(group)
    if curNewbieTask == nil then return end
    self.CurrentNewbieTasks = {}
    for k, v in pairs(curNewbieTask) do
        local stateTask = XDataCenter.TaskManager.GetTaskDataById(v)
        if stateTask.State ~= XDataCenter.TaskManager.TaskState.Finish and stateTask.State ~= XDataCenter.TaskManager.TaskState.Invalid then
            table.insert(self.CurrentNewbieTasks, v)
        end
    end
   
    self.PanelNoneTask.gameObject:SetActive(#self.CurrentNewbieTasks <= 0)
    self.BtnsDayTab[group]:ShowTag(#self.CurrentNewbieTasks <= 0)

    if self.DynamicTableNewbieTask then
        self.DynamicTableNewbieTask:SetDataSource(self.CurrentNewbieTasks)
        self.DynamicTableNewbieTask:ReloadDataSync()
    end
end

function XUiNewPlayerTask:IsCurrentLock(day)
    if XPlayer.NewPlayerTaskActiveDay == nil then return true end

    return day > XPlayer.NewPlayerTaskActiveDay
end

function XUiNewPlayerTask:UpdateTabGroupStatus()
    for i=1, #self.BtnsDayTab do
        if self:IsCurrentLock(self.BtnsTabInfos[i].OpenDay) then
            self.BtnsDayTab[i]:SetButtonState(CS.UiButtonState.Disable)
            self.BtnsDayTab[i]:ShowReddot(false)
        else
            self.BtnsDayTab[i]:ShowReddot(XDataCenter.TaskManager.GetNewbiePlayTaskReddotByOpenDay(self.BtnsTabInfos[i].OpenDay))
        end
    end
end

function XUiNewPlayerTask:OnTaskChangeSync()
    if self.CurSelectDay then
        self:UpdateTabGroupStatus()
        self:RefreshLeftView(self.CurSelectDay)
        self:RefreshBottomView()
        self:RefreshNewbieTaskView(self.CurSelectDay)
    end
end

function XUiNewPlayerTask:OnBtnDaySelected(day)

    if self:IsCurrentLock(self.BtnsTabInfos[day].OpenDay) then
        XUiManager.TipMsg(CS.XTextManager.GetText("NewbieDayUnlock"))
        return 
    end

    self:RefreshBottomView()
    if self.CurSelectDay ~= nil and self.CurSelectDay == day then
        self:RefreshLeftView(day)
        self:RefreshNewbieTaskView(day)
    else
        self:RefreshLeftView(day)
        self:RefreshNewbieTaskView(day)

        local hintFirstOpenTab = string.format("%s%d", XDataCenter.TaskManager.NewPLayerTaskFirstTalk, day)
        local isFirstOpen = XDataCenter.TaskManager.GetNewPlayerHint(hintFirstOpenTab, 0)
        
        if isFirstOpen == 1 then
            self.AnimQieHuan:PlayTimelineAnimation(function()
                self:UpdateNewbieActivePositions()
            end)
        else
            -- 第一次打開，設置已經標記
            XDataCenter.TaskManager.SaveNewPlayerHint(hintFirstOpenTab, 1)

            self.PanelRightCanvas.alpha = 0
            self.PanelContent.gameObject:SetActive(false)
            self.ImgMask.gameObject:SetActiveEx(true)
            self.ChatContent.text = self.BtnsTabInfos[day].FirstTalk
            self.BeginTalkEnable:PlayTimelineAnimation(function()
                self.BtnSkipChat.gameObject:SetActive(true)
                self.MaskClickCount = 0
            end)
        end

    end
    self.CurSelectDay = day
    XDataCenter.TaskManager.SaveNewPlayerHint(XDataCenter.TaskManager.NewPlayerLastSelectTab, day)
end
    
function XUiNewPlayerTask:OnEndTalkClick()
    if self.MaskClickCount and self.MaskClickCount >= 1 then return end
    self.PanelRightCanvas.alpha = 1
    self.PanelContent.gameObject:SetActive(true)
    self.EndTalkEnable:PlayTimelineAnimation(function()
        self.BtnSkipChat.gameObject:SetActive(false)
        self.ImgMask.gameObject:SetActiveEx(false)
    end)
    self:UpdateNewbieActivePositions()
    self.MaskClickCount = self.MaskClickCount + 1
end