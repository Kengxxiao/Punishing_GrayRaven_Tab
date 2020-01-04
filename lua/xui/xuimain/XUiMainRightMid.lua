local CSXTextManagerGetText = CS.XTextManager.GetText

XUiMainRightMid = XClass()

function XUiMainRightMid:Ctor(rootUi)
    self.Transform = rootUi.PanelRightMid.gameObject.transform
    XTool.InitUiObject(self)
    --ClickEvent
    self.BtnTarget.CallBack = function() self:OnBtnTarget() end
    self.BtnFight.CallBack = function() self:OnBtnFight() end
    self.BtnTask.CallBack = function() self:OnBtnTask() end
    self.BtnBuilding.CallBack = function() self:OnBtnBuilding() end
    self.BtnDispatch.CallBack = function() self:OnBtnDispatch() end
    self.BtnReward.CallBack = function() self:OnBtnReward() end
    self.BtnSkipTask.CallBack = function() self:OnBtnSkipTask() end
    self.BtnActivityBrief.CallBack = function() self:OnBtnActivityBrief() end

    --RedPoint
    XRedPointManager.AddRedPointEvent(self.BtnTask.ReddotObj, self.OnCheckTaskNews, self, { XRedPointConditions.Types.CONDITION_MAIN_TASK })
    XRedPointManager.AddRedPointEvent(self.BtnDispatch.ReddotObj, self.OnCheckDispatchNews, self, { XRedPointConditions.Types.CONDITION_MAIN_DISPATCH })
    XRedPointManager.AddRedPointEvent(self.BtnTarget.ReddotObj, self.OnCheckTargetNews, self, { XRedPointConditions.Types.CONDITION_MAIN_NEWPLAYER_TASK })
    XRedPointManager.AddRedPointEvent(self.BtnBuilding.ReddotObj, self.OnCheckBuildingNews, self, { XRedPointConditions.Types.CONDITION_DORM_RED })
    XRedPointManager.AddRedPointEvent(self.BtnActivityBrief, self.OnCheckActivityBriefRedPoint, self, { XRedPointConditions.Types.CONDITION_ACTIVITY_BRIRF_TASK_FINISHED })
end

function XUiMainRightMid:OnEnable()
    XEventManager.AddEventListener(XEventId.EVENT_NOTICE_TASKINITFINISHED, self.OnInitTaskFinished, self)
    XEventManager.AddEventListener(XEventId.EVENT_DRAW_ACTIVITYCOUNT_CHANGE, self.CheakDrawTag, self)
    --XEventManager.AddEventListener(XEventId.EVENT_TASKFORCE_INFO_NOTIFY, self.SetupDispatch, self)
    self:RefreshFubenProgress()
    self:UpdateStoryTaskBtn()
    self:UpdateBtnActivityBrief()
    self:CheakDrawTag()
    --初始化是否锁定
    self.BtnBuilding:SetDisable(not XFunctionManager.JudgeCanOpen(XFunctionManager.FunctionName.LivingQuarters))
    self.BtnReward:SetDisable(not XFunctionManager.JudgeCanOpen(XFunctionManager.FunctionName.DrawCard))
    if self.BtnTarget then
        self.BtnTarget.gameObject:SetActive(XDataCenter.TaskManager.CheckNewbieTaskAvaliable())
    end
    XDataCenter.DormManager.StartDormRedTimer()
end

function XUiMainRightMid:OnDisable()
    XEventManager.RemoveEventListener(XEventId.EVENT_NOTICE_TASKINITFINISHED, self.OnInitTaskFinished, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_DRAW_ACTIVITYCOUNT_CHANGE, self.CheakDrawTag, self)
    --XEventManager.RemoveEventListener(XEventId.EVENT_TASKFORCE_INFO_NOTIFY, self.SetupDispatch, self)
    XDataCenter.DormManager.StopDormRedTimer()
end

function XUiMainRightMid:OnNotify(evt)
    if evt == XEventId.EVENT_TASKFORCE_INFO_NOTIFY then
        --更新派遣
        self:SetupDispatch()
    end
end

--新手目标入口
function XUiMainRightMid:OnBtnTarget(eventData)
    if not XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.SkipTarget) then
        return
    end
    XLuaUiManager.Open("UiNewPlayerTask")
end

--副本入口
function XUiMainRightMid:OnBtnFight()
    XLuaUiManager.Open("UiFuben")
end

--任务入口
function XUiMainRightMid:OnBtnTask()
    if not XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.Task) then
        return
    end
    XLuaUiManager.Open("UiTask")
end

--任务跳转按钮点击
function XUiMainRightMid:OnBtnSkipTask()
    if not self.ShowTaskId or self.ShowTaskId <= 0 then
        XLuaUiManager.Open("UiTask", XDataCenter.TaskManager.TaskType.Story)
    else
        local taskData = XDataCenter.TaskManager.GetTaskDataById(self.ShowTaskId)
        local needSkip = taskData and taskData.State < XDataCenter.TaskManager.TaskState.Achieved
        if needSkip then
            if XDataCenter.RoomManager.RoomData ~= nil then
                local title = CSXTextManagerGetText("TipTitle")
                local cancelMatchMsg = CSXTextManagerGetText("OnlineInstanceQuitRoom")
                XUiManager.DialogTip(title, cancelMatchMsg, XUiManager.DialogType.Normal, nil, function()
                    XLuaUiManager.RunMain()
                    local skipId = XDataCenter.TaskManager.GetTaskTemplate(self.ShowTaskId).SkipId
                    XFunctionManager.SkipInterface(skipId)
                end)
            else
                local skipId = XDataCenter.TaskManager.GetTaskTemplate(self.ShowTaskId).SkipId
                XFunctionManager.SkipInterface(skipId)
            end
        else
            XLuaUiManager.Open("UiTask", XDataCenter.TaskManager.TaskType.Story)
        end
    end
end

--宿舍入口
function XUiMainRightMid:OnBtnBuilding()
    if not XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.LivingQuarters) then
        return
    end
    XHomeDormManager.EnterDorm()
end

--派遣入口
function XUiMainRightMid:OnBtnDispatch()
    if not XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.Dispatch) then
        return
    end
    XLuaUiManager.Open("UiMission")
end

--研发入口
function XUiMainRightMid:OnBtnReward()
    if not XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.DrawCard) then
        return
    end
    XLuaUiManager.Open("UiDrawMain")
end

function XUiMainRightMid:CheakDrawTag()
    self:OnCheckDrawActivityTag(XDataCenter.DrawManager.CheakDrawActivityCount())
end

--副本入口进度更新
function XUiMainRightMid:RefreshFubenProgress()
    local progressOrder = 1
    local curChapterOrderId = 1
    local curStageOrderId = 1
    local curStageCount = 1
    local chapterNew = false

    -- 普通
    local curDifficult = XDataCenter.FubenManager.DifficultNormal
    local chapterList = XDataCenter.FubenMainLineManager.GetChapterList(XDataCenter.FubenManager.DifficultNormal)
    for k, v in ipairs(chapterList) do
        local chapterInfo = XDataCenter.FubenMainLineManager.GetChapterInfo(v)
        if chapterInfo then --不知道什么情况偶现的没有副本数据，暂时加个保护
            if chapterInfo.Unlock then
                local activeStageId = chapterInfo.ActiveStage
                if not activeStageId then break end
                local stageInfo = XDataCenter.FubenManager.GetStageInfo(activeStageId)
                local chapter = XDataCenter.FubenMainLineManager.GetChapterCfg(v)
                curStageOrderId = stageInfo.OrderId
                curChapterOrderId = chapter.OrderId
                curStageCount = #XDataCenter.FubenMainLineManager.GetStageList(v)
                if curStageOrderId == curStageCount and stageInfo.Passed then
                    --当前章节打完，下一章节未解锁时进度更为100%
                    progressOrder = curStageOrderId
                else
                    progressOrder = curStageOrderId - 1
                end
            end
            if not chapterInfo.Passed then
                break
            end
        end
    end

    -- 主线普通全部完成时改为显示据点战
    if XFunctionManager.JudgeCanOpen(XFunctionManager.FunctionName.FubenNightmare) and curChapterOrderId == #chapterList and progressOrder == curStageCount then
        local chapterId = XDataCenter.BfrtManager.GetActiveChapterId()
        local chapterCfg = XDataCenter.BfrtManager.GetChapterCfg(chapterId)
        progressOrder = XDataCenter.BfrtManager.GetChapterPassCount(chapterId)
        curStageCount = XDataCenter.BfrtManager.GetGroupCount(chapterId)
        chapterNew = XDataCenter.BfrtManager.CheckChapterNew(chapterId)
        self.TxtCurChapter.text = chapterCfg.ChapterEn
        local chapterPassedStr = progressOrder == curStageCount and CSXTextManagerGetText("BfrtStatePassed") or CSXTextManagerGetText("BfrtStateNotPassed")
        self.TxtCurDifficult.text = chapterPassedStr
    else
        chapterNew = XDataCenter.FubenMainLineManager.CheckNewChapater()
        local difficultTxt = CSXTextManagerGetText("Difficult" .. curDifficult)
        self.TxtCurDifficult.text = CSXTextManagerGetText("DifficultMode") .. difficultTxt
        self.TxtCurChapter.text = curChapterOrderId .. "-" .. curStageOrderId
    end

    local progress = progressOrder / curStageCount
    self.ImgCurProgress.fillAmount = progress
    self.TxtCurProgress.text = CSXTextManagerGetText("MainFubenProgress", math.ceil(progress * 100))
    self.PanelBtnFightEffect.gameObject:SetActive(chapterNew)
end

--更新任务按钮描述
function XUiMainRightMid:UpdateStoryTaskBtn()
    self.ShowTaskId = XDataCenter.TaskManager.GetStoryTaskShowId()
    local white = "#ffffff"
    local blue = "#34AFF8"
    if self.ShowTaskId > 0 then
        local taskTemplates = XDataCenter.TaskManager.GetTaskTemplate(self.ShowTaskId)
        self.BtnSkipTask:SetDisable(false, true)
        local taskData = XDataCenter.TaskManager.GetTaskDataById(self.ShowTaskId)
        local hasRed = taskData and taskData.State == XDataCenter.TaskManager.TaskState.Achieved
        self.BtnSkipTask:ShowReddot(hasRed)
        local color = hasRed and blue or white
        self.BtnSkipTask:SetName(string.format("<color=%s>%s</color>", color, taskTemplates.Desc))
    else
        self.BtnSkipTask:SetDisable(true, true)
        self.BtnSkipTask:SetName(string.format("<color=%s>%s</color>", white, CSXTextManagerGetText("TaskStoryNoTask")))
    end
end

--更新任务标签
function XUiMainRightMid:OnInitTaskFinished()
    self:UpdateStoryTaskBtn()
end

---派遣相关------------------------
-- function XUiMainRightMid:SetupDispatch()
--     self.DispatchTimer = nil
--     local isOpen = XFunctionManager.JudgeCanOpen(XFunctionManager.FunctionName.Dispatch)
--     local canvas = self.BtnDispatch.gameObject:GetComponent("CanvasGroup")
--     canvas.alpha = isOpen and 1 or 0.7
--     self.ImgDispatchLock.gameObject:SetActive(not isOpen)
--     self.ImgWorking.gameObject:SetActive(isOpen)
--     self.TxtNumber.gameObject:SetActive(isOpen)
--     self.TxtNumber1.gameObject:SetActive(isOpen)
--     self.TxtDispatchTime.gameObject:SetActive(isOpen)
--     local taskForeInfo = XDataCenter.TaskForceManager.GetTaskForeInfo()
--     if taskForeInfo then
--         self.TxtNumber.text = tostring(XDataCenter.TaskForceManager.GetWorkingTaskCount())
--         local id = taskForeInfo.ConfigIndex or 1
--         local taskForeCfg = XDataCenter.TaskForceManager.GetTaskForceConfigById(id)
--         if taskForeCfg and taskForeInfo.ConfigIndex then
--             self.TxtNumber1.text = "/" .. tostring(taskForeCfg.MaxTaskForceCount)
--         else
--             self.TxtNumber1.text = "/" .. tostring(1)
--         end
--         self.TxtDispatchTime.text = "00:00:00"
--         local taskforeInfo = XDataCenter.TaskForceManager.GetLatelyTaskForeInfo()
--         if taskforeInfo then
--             self.ImgWorking.gameObject:SetActive(true)
--             self.TxtDispatchTime.gameObject:SetActive(true)
--             self.TaskforeInfo = taskforeInfo
--             self:UpdateMissionTime()
--             self:StartMissionTimer()
--         else
--             self.ImgWorking.gameObject:SetActive(false)
--             self.TxtDispatchTime.gameObject:SetActive(false)
--         end
--     end
-- end
-- function XUiMainRightMid:StartMissionTimer()
--     if self.DispatchTimer then
--         self:StopMissionTimer()
--     end
--     self.DispatchTimer = CS.XScheduleManager.ScheduleForever(function()
--         self:UpdateMissionTime()
--     end, CS.XScheduleManager.SECOND)
-- end
-- function XUiMainRightMid:StopMissionTimer()
--     if self.DispatchTimer then
--         CS.XScheduleManager.UnSchedule(self.DispatchTimer)
--         self.DispatchTimer = nil
--     end
-- end
-- function XUiMainRightMid:UpdateMissionTime()
--     if not self.TaskforeInfo then
--         self:StopMissionTimer()
--         return
--     end
--     local curTime = XTime.Now()
--     local completeTime = self.TaskforeInfo.UtcFinishTime
--     if not self.TxtDispatchTime:Exist() then
--         return
--     end
--     local offset = completeTime - curTime
--     if offset > 0 then
--         self.TxtDispatchTime.text = CS.XDate.GetTimeString(offset)
--     else
--         self.TxtDispatchTime.text = "00:00:00"
--         local taskforeInfo = XDataCenter.TaskForceManager.GetLatelyTaskForeInfo()
--         if taskforeInfo then
--             self.TaskforeInfo = taskforeInfo
--         else
--             self:StopMissionTimer()
--             self.ImgWorking.gameObject:SetActive(false)
--             self.TxtDispatchTime.gameObject:SetActive(false)
--         end
--     end
-- end
-------------派遣End-------------------
-------------活动简介 Begin-------------------
function XUiMainRightMid:UpdateBtnActivityBrief()
    local isOpen = XDataCenter.ActivityBriefManager.CheckActivityBriefOpen()
    self.BtnActivityBrief.gameObject:SetActiveEx(isOpen)
end

function XUiMainRightMid:OnBtnActivityBrief(eventData)
    XLuaUiManager.Open("UiActivityBriefBase")
end
-------------活动简介 End-------------------

--任务红点
function XUiMainRightMid:OnCheckTaskNews(count)
    self.BtnTask:ShowReddot(count >= 0)
end

--派遣红点
function XUiMainRightMid:OnCheckDispatchNews(count)
    self.BtnDispatch:ShowReddot(count >= 0)
end

--新手目标红点
function XUiMainRightMid:OnCheckTargetNews(count)
    self.BtnTarget:ShowReddot(count >= 0)
end

--宿舍红点
function XUiMainRightMid:OnCheckBuildingNews(count)
    self.BtnBuilding:ShowReddot(count >= 0)
end

--活动简介红点
function XUiMainRightMid:OnCheckActivityBriefRedPoint(count)
    self.BtnActivityBrief:ShowReddot(count >= 0)
end

--研发活动标签
function XUiMainRightMid:OnCheckDrawActivityTag(IsShow)
    if XFunctionManager.JudgeCanOpen(XFunctionManager.FunctionName.DrawCard) then
        self.BtnReward:ShowTag(IsShow)
    else
        self.BtnReward:ShowTag(false)
    end
end