XTaskManagerCreator = function()
    local tableInsert = table.insert
    local tableSort = table.sort
    local CSXDateGetTime = CS.XDate.GetTime

    local Json = require("XCommon/Json")
    local WeekTaskRefreshId = 10001
    local WeekTaskEpochTime = 0
    local WeekTaskRefreshDay = 1

    local XTaskManager = {}

    local SECTION_LEVEL = 5
    local ITEM_NEWBIE_PROGRESS_ID = CS.XGame.ClientConfig:GetInt("NewPlayerTaskExpId")
    -- local TaskConditionTemplate = {}
    XTaskManager.OperationState = {
        DoWork = 1,
        GetReward = 2,
        GetedReward = 3
    }

    XTaskManager.ActiveRewardType = {
        Daily = 1,
        Weekly = 2
    }


    XTaskManager.TaskType = {
        Story = 1,
        Daily = 2,
        Weekly = 3,
        Achievement = 4,
        Activity = 5,
        OffLine = 6,
        NewPlayer = 7,
        ArenaChallenge = 10,
        TimeLimit = 11,
        DormNormal = 12, --宿舍普通
        DormDaily = 13, --宿舍日常
    }

    XTaskManager.AchvType = {
        Fight = 1,
        Collect = 2,
        Social = 3,
        Other = 4,
    }

    XTaskManager.TaskState = {
        InActive = -1, --未激活
        Standby = 0, --待命
        Active = 1, --已激活
        Accepted = 2, --已接受
        Achieved = 3, --完成（未领奖励）
        Finish = 4, --结束（领取奖励）
        Invalid = 5, --已失效/过期
    }

    XTaskManager.NewPlayerTaskGroupState = {
        Lock = 1, --未解锁
        AllTodo = 2, --待完成
        HasAward = 3, --有奖励没领取
        AllFinish = 4, --全都结束
    }

    XTaskManager.CourseType = {
        None = 0, -- 无状态
        Reward = 1, -- 有经历节点
        Function = 2, -- 有功能开启节点
        Normal = 3, -- 普通节点
    }

    XTaskManager.UpdateViewCallback = nil

    local CourseInfos = {}  -- {key = ChapterId, Value = {LasetId, NextChapterId, Courses = {stageId, type, nextType......}}}
    local CourseChapterRewards = {}

    local CourseData = {}
    local TotalTaskData = {}
    local StoryTaskData = {}
    local DailyTaskData = {}
    local WeeklyTaskData = {}
    local ActivityTaskData = {}
    local NewPlayerTaskData = {}
    local AchvTaskData = {}
    local ArenaTaskData = {}

    local StoryGroupTaskData = {}
    local DormStoryGroupTaskData = {}
    local FinishedTasks = {}

    -- 宿舍任务
    local DormNormalTaskData = {}
    local DormDailyTaskData = {}

    local NewbieActivenessRecord = {}
    XTaskManager.NewPlayerLastSelectTab = "NewPlayerHint_LastSelectTab"
    XTaskManager.TaskLastSelectTab = "TaskHint_LastSelectTab"
    XTaskManager.DormTaskLastSelectTab = "DormTaskHint_LastSelectTab"
    XTaskManager.NewPLayerTaskFirstTalk = "NewPlayerHint_FirstTalk"

    function XTaskManager.Init()
        XEventManager.AddEventListener(XEventId.EVENT_FUBEN_STAGE_SYNC, XTaskManager.SetCourseOnSyncStageData)

        local alarmClockData = XTaskConfig.GetAlarmClockById(WeekTaskRefreshId)
        local jsonFormatData = Json.decode(alarmClockData.DayOfWeek)
        WeekTaskEpochTime = alarmClockData.EpochTime
        WeekTaskRefreshDay = jsonFormatData[1]
    end

    function XTaskManager.InitTaskData(data)
        local taskdata = data.Tasks
        FinishedTasks = {}
        for k, v in pairs(data.FinishedTasks or {}) do
            FinishedTasks[v] = true
        end
        NewbieActivenessRecord = data.NewPlayerRewardRecord
        XTaskManager.InitCourseData(data.Course)

        for key, value in pairs(taskdata) do
            TotalTaskData[value.Id] = value
        end
        local taskTemplate = XTaskConfig.GetTaskTemplate()
        for k, v in pairs(taskTemplate) do
            if not TotalTaskData[k] and v.Type ~= XTaskManager.TaskType.Daily and v.Type ~= XTaskManager.TaskType.Weekly then
                TotalTaskData[k] = {}
                TotalTaskData[k].Id = k
                TotalTaskData[k].Schedule = {}
                local conditions = v.Condition

                for index, var in ipairs(conditions) do
                    if FinishedTasks and FinishedTasks[k] then
                        tableInsert(TotalTaskData[k].Schedule, { Id = var, Value = v.Result })
                        TotalTaskData[k].State = XTaskManager.TaskState.Finish
                    else
                        tableInsert(TotalTaskData[k].Schedule, { Id = var, Value = 0 })
                        TotalTaskData[k].State = XTaskManager.TaskState.Active
                    end
                end

            end
        end

        for k, v in pairs(TotalTaskData) do
            if taskTemplate[k].Type == XTaskManager.TaskType.Story then
                StoryTaskData[k] = v
            elseif taskTemplate[k].Type == XTaskManager.TaskType.Daily then
                DailyTaskData[k] = v
            elseif taskTemplate[k].Type == XTaskManager.TaskType.Weekly then
                WeeklyTaskData[k] = v
            elseif taskTemplate[k].Type == XTaskManager.TaskType.Activity then
                ActivityTaskData[k] = v
            elseif taskTemplate[k].Type == XTaskManager.TaskType.NewPlayer then
                NewPlayerTaskData[k] = v
            elseif taskTemplate[k].Type == XTaskManager.TaskType.Achievement then
                AchvTaskData[k] = v
            elseif taskTemplate[k].Type == XTaskManager.TaskType.ArenaChallenge then
                ArenaTaskData[k] = v
            elseif taskTemplate[k].Type == XTaskManager.TaskType.DormNormal then
                DormNormalTaskData[k] = v
            elseif taskTemplate[k].Type == XTaskManager.TaskType.DormDaily then
                DormDailyTaskData[k] = v
            end
        end
        XEventManager.DispatchEvent(XEventId.EVENT_TASK_SYNC)
        XEventManager.DispatchEvent(XEventId.EVENT_NOTICE_TASKINITFINISHED)--上面那个事件触发太频繁，这里只需要监听初始完成
        CsXGameEventManager.Instance:Notify(XEventId.EVENT_TASK_SYNC)
    end

    function XTaskManager.InitCourseInfos()
        local courseChapterRewardTemp = {}
        local courseTemplate = XTaskConfig.GetCourseTemplate()
        for k, v in pairs(courseTemplate) do
            local stageInfo = XDataCenter.FubenManager.GetStageInfo(v.StageId)
            local stageCfg = XDataCenter.FubenManager.GetStageCfg(v.StageId)
            if not stageInfo or not stageCfg then
                XLog.Error("XTaskManager InitCourseInfos is Error StageInfo is Null, Map Id is" .. k)
                return
            end

            local SetType = function(cfg)
                if cfg.RewardId and cfg.RewardId > 0 then
                    return XTaskManager.CourseType.Reward
                elseif cfg.Tip and cfg.Tip ~= "" then
                    return XTaskManager.CourseType.Function
                else
                    return XTaskManager.CourseType.Normal
                end
            end

            local SetCourse = function(lastStageId)
                local type = XTaskManager.CourseType.None
                type = SetType(v)

                local nextType = XTaskManager.CourseType.None
                if stageInfo.NextStageId and courseTemplate[stageInfo.NextStageId] then
                    local nextCfg = courseTemplate[stageInfo.NextStageId]
                    nextType = SetType(nextCfg)
                end

                local chapter = XDataCenter.FubenMainLineManager.GetChapterCfg(stageInfo.ChapterId)
                local name = chapter.OrderId .. "-" .. stageCfg.OrderId

                -- 寻找还没有领奖励的关卡
                if type == XTaskManager.CourseType.Reward or lastStageId == v.StageId then
                    if XTaskManager.CheckCourseCanGet(v.StageId) then
                        if courseChapterRewardTemp[stageInfo.ChapterId] then
                            if type == XTaskManager.CourseType.Reward then
                                tableInsert(courseChapterRewardTemp[stageInfo.ChapterId].stageIds, v.StageId)
                            end

                            local stageInfo = XDataCenter.FubenManager.GetStageInfo(lastStageId)
                            if lastStageId == v.StageId and not stageInfo.Passed then
                                courseChapterRewardTemp[stageInfo.ChapterId].LastStageId = v.StageId
                            end
                        else
                            if type == XTaskManager.CourseType.Reward then
                                courseChapterRewardTemp[stageInfo.ChapterId] = {}
                                courseChapterRewardTemp[stageInfo.ChapterId].ChapterId = stageInfo.ChapterId
                                courseChapterRewardTemp[stageInfo.ChapterId].OrderId = chapter.OrderId
                                courseChapterRewardTemp[stageInfo.ChapterId].stageIds = {}
                                tableInsert(courseChapterRewardTemp[stageInfo.ChapterId].stageIds, v.StageId)
                            end

                            local stageInfo = XDataCenter.FubenManager.GetStageInfo(lastStageId)
                            if lastStageId == v.StageId and not stageInfo.Passed then
                                if courseChapterRewardTemp[stageInfo.ChapterId] then
                                    courseChapterRewardTemp[stageInfo.ChapterId].LastStageId = v.StageId
                                else
                                    courseChapterRewardTemp[stageInfo.ChapterId] = {}
                                    courseChapterRewardTemp[stageInfo.ChapterId].ChapterId = stageInfo.ChapterId
                                    courseChapterRewardTemp[stageInfo.ChapterId].OrderId = chapter.OrderId
                                    courseChapterRewardTemp[stageInfo.ChapterId].stageIds = {}
                                    courseChapterRewardTemp[stageInfo.ChapterId].LastStageId = v.StageId
                                end
                            end
                        end
                    end
                end
                -- 寻找还没有领奖励的关卡
                return {
                    CouresType = type,
                    NextCouresType = nextType,
                    StageId = v.StageId,
                    Tip = v.Tip,
                    TipEn = v.TipEn,
                    RewardId = v.RewardId,
                    ShowId = v.ShowId,
                    OrderId = stageCfg.OrderId,
                    Name = name,
                    PreStageId = stageCfg.PreStageId
                }
            end

            if CourseInfos[stageInfo.ChapterId] then
                local course = SetCourse(CourseInfos[stageInfo.ChapterId].LastStageId)
                tableInsert(CourseInfos[stageInfo.ChapterId].Courses, course)
            else
                local nextChapterId = XDataCenter.FubenMainLineManager.GetNextChapterId(stageInfo.ChapterId)
                local lastStageId = XDataCenter.FubenMainLineManager.GetLastStageId(stageInfo.ChapterId)
                CourseInfos[stageInfo.ChapterId] = {}
                CourseInfos[stageInfo.ChapterId].Courses = {}
                CourseInfos[stageInfo.ChapterId].NextChapterId = nextChapterId
                CourseInfos[stageInfo.ChapterId].LastStageId = lastStageId
                local course = SetCourse(lastStageId)
                tableInsert(CourseInfos[stageInfo.ChapterId].Courses, course)
            end
        end

        for k, v in pairs(CourseInfos) do
            tableSort(v.Courses, function(a, b)
                return a.OrderId < b.OrderId
            end)
        end

        for k, v in pairs(courseChapterRewardTemp) do
            tableSort(v.stageIds, function(a, b)
                return a < b
            end)
            tableInsert(CourseChapterRewards, v)
        end

        tableSort(CourseChapterRewards, function(a, b)
            return a.OrderId < b.OrderId
        end)
    end

    function XTaskManager.InitCourseData(coursedata)
        CourseData = {}
        CourseInfos = {}
        CourseChapterRewards = {}

        if coursedata then
            XTool.LoopCollection(coursedata, function(key)
                CourseData[key] = key
            end)
        end
        XTaskManager.InitCourseInfos()
    end

    function XTaskManager.SetCourseData(stageId)
        local allRewardGet = false
        if not CourseData[stageId] then
            CourseData[stageId] = stageId

            --移除 CourseChapterRewards 里的Id,并判断是否领取完
            local remov_stage_i = -1
            local remov_stage_j = -1
            local remov_chapter_i = -1
            for i = 1, #CourseChapterRewards do
                for j = 1, #CourseChapterRewards[i].stageIds do
                    if CourseChapterRewards[i].stageIds[j] == stageId then
                        remov_stage_i = i
                        remov_stage_j = j
                        if #CourseChapterRewards[i].stageIds <= 1 then
                            local lastId = CourseChapterRewards[i].LastStageId
                            local stageInfo = XDataCenter.FubenManager.GetStageInfo(lastId)
                            if (stageInfo and stageInfo.Passed) or not lastId then
                                remov_chapter_i = i
                            end
                        end
                        break
                    end
                end
            end

            if remov_stage_i > 0 and remov_stage_j > 0 then
                table.remove(CourseChapterRewards[remov_stage_i].stageIds, remov_stage_j)
            end

            if remov_chapter_i > 0 then
                table.remove(CourseChapterRewards, remov_chapter_i)
                allRewardGet = true
            end
        end
        return allRewardGet
    end

    --判断是否有进度
    function XTaskManager.CheckTaskHasSchedule(task)
        local hasSchedule = false
        XTool.LoopMap(task.Schedule, function(k, pair)
            if pair.Value > 0 then
                hasSchedule = true
            end
        end)

        return hasSchedule
    end

    function XTaskManager.CheckCourseCanGet(stageId)
        if CourseData[stageId] then
            return false
        else
            return true
        end
    end

    function XTaskManager.GetCourseInfo(chapterId)
        return CourseInfos[chapterId]
    end

    function XTaskManager.GetCourseCurChapterId()
        if not CourseChapterRewards or #CourseChapterRewards <= 0 then
            return nil
        end
        return CourseChapterRewards[1].ChapterId
    end

    function XTaskManager.SetCourseOnSyncStageData(stageId)
        local remov_chapter_i = -1
        for i = 1, #CourseChapterRewards do
            local lastId = CourseChapterRewards[i].LastStageId
            local stageInfo = XDataCenter.FubenManager.GetStageInfo(lastId)
            if #CourseChapterRewards[i].stageIds <= 0 and lastId == stageId and stageInfo.Passed then
                remov_chapter_i = i
                break
            end
        end

        if remov_chapter_i > 0 then
            table.remove(CourseChapterRewards, remov_chapter_i)
        end
    end

    function XTaskManager.GetCourseCurRewardIndex(curChapterId)
        if not CourseChapterRewards or #CourseChapterRewards <= 0 then
            return nil
        end

        if not CourseChapterRewards[1].stageIds[1] and #CourseChapterRewards[1].stageIds <= 0 then
            return nil
        end

        local stageId = CourseChapterRewards[1].stageIds[1]
        local stageInfo = XDataCenter.FubenManager.GetStageInfo(stageId)
        if not stageInfo.Passed then
            return nil
        end
        local courses = CourseInfos[curChapterId].Courses
        for i = 1, #courses do
            if stageId == courses[i].StageId then
                return i
            end
        end
        return nil
    end

    function XTaskManager.GetTaskDataById(taskid)
        return TotalTaskData[taskid]
    end




    local function CheckTask(task)
        local template = XTaskConfig.GetTaskTemplate()[task.Id]
        local curTask = TotalTaskData[task.Id]
        
        -- startTime限制
        if template.StartTime ~= nil and template.StartTime ~= "" then
            local now = XTime.Now()
            local startTime = CS.XDate.GetTime(template.StartTime)
            if startTime > now then return false end
        end
        
        local preId = template and template.ShowAfterTaskId or -1
        if preId > 0 then
            local preTask = TotalTaskData[preId]

            if preTask then
                if preTask.State ~= XTaskManager.TaskState.Finish and preTask.State ~= XTaskManager.TaskState.Invalid then
                    return false
                end
            else
                if FinishedTasks[preId] then
                    return true
                end
                return false
            end
        end
        return true
    end

    local function State2Num(state)
        if state == XTaskManager.TaskState.Achieved then
            return 1
        end
        if state == XTaskManager.TaskState.Finish then
            return -1
        end
        return 0
    end

    local function CompareState(stateA, stateB)
        if stateA == stateB then
            return 0
        end
        local a = State2Num(stateA)
        local b = State2Num(stateB)
        if a > b then return 1 end
        if a < b then return -1 end
        return 0
    end

    local function GetTaskList(tasks)
        local list = {}
        local preList = {}
        local type
        local taskTemplate = XTaskConfig.GetTaskTemplate()
        for _, task in pairs(tasks) do
            type = taskTemplate[task.Id].Type
            break
        end
        if type == XTaskManager.TaskType.Achievement or type == XTaskManager.TaskType.ArenaChallenge then
            for _, task in pairs(tasks) do
                if CheckTask(task) then
                    tableInsert(list, task)
                end
            end
        else
            for _, task in pairs(tasks) do
                if task.State ~= XTaskManager.TaskState.Finish and task.State ~= XTaskManager.TaskState.Invalid then
                    if CheckTask(task) then
                        tableInsert(list, task)
                    end
                end
            end
        end

        tableSort(list, function(a, b)
            local pa, pb = taskTemplate[a.Id].Priority, taskTemplate[b.Id].Priority
            local stateA = TotalTaskData[a.Id].State
            local stateB = TotalTaskData[b.Id].State
            local compareResult = CompareState(stateA, stateB)
            if compareResult == 0 then
                if pa ~= pb then
                    return pa > pb
                else
                    return a.Id > b.Id
                end
            else
                return compareResult > 0
            end
        end)

        return list
    end


    function XTaskManager.SetAchievedList()
        local tasks = XTaskManager.GetTaskDataByTaskType(XTaskManager.TaskType.Achievement)
        local list = {}
        local nextIds = {}

        local taskTemplate = XTaskConfig.GetTaskTemplate()
        for _, task in pairs(tasks) do
            if not (task.State == XTaskManager.TaskState.Invalid) then
                if taskTemplate[task.Id] and taskTemplate[task.Id].ShowAfterTaskId > 0 then
                    local preId = taskTemplate[task.Id].ShowAfterTaskId
                    nextIds[preId] = task.Id
                    if TotalTaskData[preId] then
                        if (TotalTaskData[preId].State == XTaskManager.TaskState.Finish or TotalTaskData[preId].State == XTaskManager.TaskState.Invalid) then
                            tableInsert(list, task)    
                        end
                    elseif FinishedTasks[preId] then
                        tableInsert(list, task)
                    end
                else
                    tableInsert(list, task)
                end
            end
        end

        local listAchieved = {}
        for k, v in pairs(list) do
            if v.State == XTaskManager.TaskState.Achieved or v.State == XTaskManager.TaskState.Finish then
                tableInsert(listAchieved, v)
            end
        end
    end

    --获取成就任务已完成和总数量
    function XTaskManager.GetAchievedTasksByType(achvType)

        local achieveCount = 0
        local totalCount = 0
        local achieveList = {}
        local achvTaskData = XTaskManager.GetAchvTaskList()
        for _, task in pairs(achvTaskData) do
            local _achvType = XTaskConfig.GetTaskTemplate()[task.Id].AchvType
            if _achvType == achvType and task ~= nil then
                tableInsert(achieveList, task)
                totalCount = totalCount + 1
                if task.State == XTaskManager.TaskState.Finish or task.State == XTaskManager.TaskState.Achieved then
                    achieveCount = achieveCount + 1
                end
            end
        end

        return achieveList, achieveCount, totalCount
    end

    --红点---------------------------------------------------------
    --根据成就任务类型判断是否有奖励可以领取
    function XTaskManager.HasAchieveTaskRewardByAchieveType(achvType)
        for _, task in pairs(AchvTaskData) do
            local _achvType = XTaskConfig.GetTaskTemplate()[task.Id].AchvType
            if _achvType == achvType and task ~= nil and task.State == XTaskManager.TaskState.Achieved then
                return true
            end
        end

        return false
    end

    --判断历程是否有奖励获取
    function XTaskManager.CheckAllCourseCanGet()

        if not CourseInfos then
            return false
        end

        local curChapterId = XTaskManager.GetCourseCurChapterId()
        if not CourseInfos[curChapterId] then
            return
        end

        local canGet = false
        for k, v in ipairs(CourseInfos[curChapterId].Courses) do

            local stageId = v.StageId
            local stageInfo = XDataCenter.FubenManager.GetStageInfo(stageId)

            if v.CouresType == XTaskManager.CourseType.Reward and stageInfo.Passed and XTaskManager.CheckCourseCanGet(stageId) then
                canGet = true
                break
            end
        end

        return canGet
    end

    --根据任务类型判断是否有奖励可以领取
    function XTaskManager.GetIsRewardForEx(taskType)
        local taskList = nil
        if taskType == XTaskManager.TaskType.Story then
            taskList = XTaskManager.GetStoryTaskList()
        elseif taskType == XTaskManager.TaskType.Daily then
            taskList = XTaskManager.GetDailyTaskList()
        elseif taskType == XTaskManager.TaskType.Weekly then
            taskList = XTaskManager.GetWeeklyTaskList()
        elseif taskType == XTaskManager.TaskType.Activity then
            taskList = XTaskManager.GetActivityTaskList()
        elseif taskType == XTaskManager.TaskType.Achievement then
            taskList = XTaskManager.GetAchvTaskList()
        elseif taskType == XTaskManager.TaskType.DormDaily then
            taskList = XTaskManager.GetDormDailyTaskList()
        elseif taskType == XTaskManager.TaskType.DormNormal then
            taskList = XTaskManager.GetDormNormalTaskList()
        end
        if taskList == nil then
            return false
        end
        for _, taskInfo in pairs(taskList) do
            if taskInfo ~= nil and taskInfo.State == XTaskManager.TaskState.Achieved then
                return true
            end
        end
        return false
    end

    --判断新手任务是否有奖励可以领取
    function XTaskManager.CheckIsNewPlayerTaskReward()
        local newPlayerTaskGroupTemplate = XTaskConfig.GetNewPlayerTaskGroupTemplate()
        if not newPlayerTaskGroupTemplate then
            return false
        end


        local hasReward = false

        for k, v in pairs(newPlayerTaskGroupTemplate) do
            local state = XTaskManager.GetNewPlayerGroupTaskStatus(k)

            local talkConfig = XTaskManager.GetNewPlayerTaskTalkConfig(k)
            local isNewPlayerTaskUIGroupActive = XPlayer.IsNewPlayerTaskUIGroupActive(k)
            if talkConfig and not isNewPlayerTaskUIGroupActive and talkConfig.StoryId ~= 0 and state ~= XTaskManager.NewPlayerTaskGroupState.Lock then
                hasReward = true
                break
            end

            if state == XTaskManager.NewPlayerTaskGroupState.HasAward then
                hasReward = true
                break
            end
        end

        return hasReward
    end

    --判断是否有每日活跃任务是否有奖励可以领取
    function XTaskManager.CheckHasWeekActiveTaskReward()
        local wActiveness = XDataCenter.ItemManager.GetWeeklyActiveness().Count
        local weekActiveness = XTaskConfig.GetWeeklyActiveness()

        for i = 1, 2 do
            if weekActiveness[i] <= wActiveness and (not XPlayer.IsGetWeeklyActivenessReward(i)) then
                return true
            end
        end

        return false
    end


    --判断是否有周活跃任务是否有奖励可以领取
    function XTaskManager.CheckHasDailyActiveTaskReward()
        local dActiveness = XDataCenter.ItemManager.GetDailyActiveness().Count
        local dailyActiveness = XTaskConfig.GetDailyActiveness()
        for i = 1, 5 do
            if dailyActiveness[i] <= dActiveness and (not XPlayer.IsGetDailyActivenessReward(i)) then
                return true
            end
        end

        return false
    end
    ------------------------------------------------------------
    function XTaskManager.GetStoryTaskList()
        return GetTaskList(XTaskManager.GetTaskDataByTaskType(XTaskManager.TaskType.Story))
    end

    function XTaskManager.GetDailyTaskList()
        return GetTaskList(XTaskManager.GetTaskDataByTaskType(XTaskManager.TaskType.Daily))
    end

    function XTaskManager.GetWeeklyTaskList()
        return GetTaskList(XTaskManager.GetTaskDataByTaskType(XTaskManager.TaskType.Weekly))
    end

    function XTaskManager.GetActivityTaskList()
        return GetTaskList(XTaskManager.GetTaskDataByTaskType(XTaskManager.TaskType.Activity))
    end

    function XTaskManager.GetAchvTaskList()
        return GetTaskList(XTaskManager.GetTaskDataByTaskType(XTaskManager.TaskType.Achievement))
    end

    function XTaskManager.GetArenaChallengeTaskList()
        return GetTaskList(XTaskManager.GetTaskDataByTaskType(XTaskManager.TaskType.ArenaChallenge))
    end

    function XTaskManager.GetDormNormalTaskList()
        return GetTaskList(XTaskManager.GetTaskDataByTaskType(XTaskManager.TaskType.DormNormal))
    end

    function XTaskManager.GetDormDailyTaskList()
        return GetTaskList(XTaskManager.GetTaskDataByTaskType(XTaskManager.TaskType.DormDaily))
    end

    function XTaskManager.GetTimeLimitTaskListByGroupId(taskGroupId)
        local taskDatas = {}

        local timeLimitTaskCfg = taskGroupId ~= 0 and XTaskConfig.GetTimeLimitTaskCfg(taskGroupId)
        if not timeLimitTaskCfg then return taskDatas end

        local nowTime = XTime.Now()
        local beginTime = CSXDateGetTime(timeLimitTaskCfg.StartTimeStr)
        local endTime = CSXDateGetTime(timeLimitTaskCfg.EndTimeStr)
        if nowTime < beginTime or nowTime >= endTime then
            return taskDatas
        end

        for _, taskId in ipairs(timeLimitTaskCfg.TaskId) do
            local taskData = XDataCenter.TaskManager.GetTaskDataById(taskId)
            if CheckTask(taskData) then
                tableInsert(taskDatas, taskData)
            end
        end
        for _, taskId in ipairs(timeLimitTaskCfg.DayTaskId) do
            local taskData = XDataCenter.TaskManager.GetTaskDataById(taskId)
            if CheckTask(taskData) then
                tableInsert(taskDatas, taskData)
            end
        end
        for _, taskId in ipairs(timeLimitTaskCfg.WeekTaskId) do
            local taskData = XDataCenter.TaskManager.GetTaskDataById(taskId)
            if CheckTask(taskData) then
                tableInsert(taskDatas, taskData)
            end
        end

        local achieved = XDataCenter.TaskManager.TaskState.Achieved
        local finish = XDataCenter.TaskManager.TaskState.Finish
        tableSort(taskDatas, function(a, b)
            if a.State ~= b.State then
                if a.State == achieved then
                    return true
                end
                if b.State == achieved then
                    return false
                end
                if a.State == finish then
                    return false
                end
                if b.State == finish then
                    return true
                end
            end

            local templatesTaskA = XDataCenter.TaskManager.GetTaskTemplate(a.Id)
            local templatesTaskB = XDataCenter.TaskManager.GetTaskTemplate(b.Id)
            return templatesTaskA.Priority > templatesTaskB.Priority
        end)

        return taskDatas
    end

    --根据任务类型获得成就任务
    function XTaskManager.GetAchvTaskByAchieveType(achvType)
        local achieveTasks = XTaskManager.GetAchvTaskList()
        local taskList = {}
        for idx, var in achieveTasks do
            if var.AchvType == achvType then
                tableInsert(taskList, var)
            end
        end
    end

    function XTaskManager.GetTaskDataByTaskType(tasktype)
        local datas = {}
        if tasktype == XTaskManager.TaskType.Story then
            datas = StoryTaskData
        elseif tasktype == XTaskManager.TaskType.Daily then
            datas = DailyTaskData
        elseif tasktype == XTaskManager.TaskType.Weekly then
            datas = WeeklyTaskData
        elseif tasktype == XTaskManager.TaskType.Activity then
            datas = ActivityTaskData
        elseif tasktype == XTaskManager.TaskType.NewPlayer then
            datas = NewPlayerTaskData
        elseif tasktype == XTaskManager.TaskType.Achievement then
            datas = AchvTaskData
        elseif tasktype == XTaskManager.TaskType.ArenaChallenge then
            datas = ArenaTaskData
        elseif tasktype == XTaskManager.TaskType.DormDaily then
            datas = DormDailyTaskData
        elseif tasktype == XTaskManager.TaskType.DormNormal then
            datas = DormNormalTaskData
        end
        local result = {}
        for k, v in pairs(datas) do
            --原:  v.State ~= XTaskManager.TaskState.Finish and v.State ~= XTaskManager.TaskState.Invalid
            if XTaskConfig.GetTaskTemplate()[v.Id].Type == XTaskManager.TaskType.Achievement and v.State == XTaskManager.TaskState.Finish then
                result[k] = v
            elseif v.State ~= XTaskManager.TaskState.Finish and v.State ~= XTaskManager.TaskState.Invalid then
                result[k] = v
            elseif XTaskConfig.GetTaskTemplate()[v.Id].Type == XTaskManager.TaskType.ArenaChallenge and v.State ~= XTaskManager.TaskState.Invalid then
                result[k] = v
            end
        end
        return result
    end

    function XTaskManager.ResetStoryGroupTaskData()
        for k, v in pairs(StoryGroupTaskData) do
            v.UnfinishCount = 0
        end
    end

    function XTaskManager.GetCurrentStoryTaskGroupId()
        XTaskManager.ResetStoryGroupTaskData()

        local headGroupId = 1
        for k, v in pairs(StoryTaskData) do
            local templates = XTaskManager.GetTaskTemplate(v.Id)
            if templates.GroupId > 0 then
                if templates.ShowAfterGroup <= 0 then
                    headGroupId = templates.GroupId
                end
                local groupDatas = StoryGroupTaskData[templates.GroupId]
                if groupDatas == nil then
                    StoryGroupTaskData[templates.GroupId] = {}
                    groupDatas = StoryGroupTaskData[templates.GroupId]
                    groupDatas.GroupId = templates.GroupId
                    groupDatas.ShowAfterGroup = templates.ShowAfterGroup
                    groupDatas.UnfinishCount = 0
                end

                if v.State ~= XTaskManager.TaskState.Finish and v.State ~= XTaskManager.TaskState.Invalid then
                    groupDatas.UnfinishCount = groupDatas.UnfinishCount + 1
                end
            end
        end

        for groupId, groupDatas in pairs(StoryGroupTaskData) do
            if groupDatas.ShowAfterGroup > 0 then
                StoryGroupTaskData[groupDatas.ShowAfterGroup].NextGroupId = groupDatas.GroupId
            end
        end

        local currentGoupId = headGroupId
        local currentGroupDatas = StoryGroupTaskData[currentGoupId]
        while currentGroupDatas and currentGroupDatas.UnfinishCount <= 0 do
            currentGoupId = currentGroupDatas.NextGroupId
            if currentGoupId == nil then break end
            currentGroupDatas = StoryGroupTaskData[currentGoupId]
        end
        return currentGoupId
    end

    function XTaskManager.ResetDormStoryGroupTaskData()
        for k, v in pairs(DormStoryGroupTaskData) do
            v.UnfinishCount = 0
        end
    end
    function XTaskManager.GetCurrentDormStoryTaskGroupId()
        XTaskManager.ResetDormStoryGroupTaskData()

        local headGroupId = 1
        for k, v in pairs(DormNormalTaskData) do
            local templates = XTaskManager.GetTaskTemplate(v.Id)
            if templates.GroupId > 0 then
                if templates.ShowAfterGroup <= 0 then
                    headGroupId = templates.GroupId
                end
                local groupDatas = DormStoryGroupTaskData[templates.GroupId]
                if groupDatas == nil then
                    DormStoryGroupTaskData[templates.GroupId] = {}
                    groupDatas = DormStoryGroupTaskData[templates.GroupId]
                    groupDatas.GroupId = templates.GroupId
                    groupDatas.ShowAfterGroup = templates.ShowAfterGroup
                    groupDatas.UnfinishCount = 0
                end

                if v.State ~= XTaskManager.TaskState.Finish and v.State ~= XTaskManager.TaskState.Invalid then
                    groupDatas.UnfinishCount = groupDatas.UnfinishCount + 1
                end
            end
        end

        for groupId, groupDatas in pairs(DormStoryGroupTaskData) do
            if groupDatas.ShowAfterGroup > 0 then
                DormStoryGroupTaskData[groupDatas.ShowAfterGroup].NextGroupId = groupDatas.GroupId
            end
        end

        local currentGoupId = headGroupId
        local currentGroupDatas = DormStoryGroupTaskData[currentGoupId]
        while currentGroupDatas and currentGroupDatas.UnfinishCount <= 0 do
            currentGoupId = currentGroupDatas.NextGroupId
            if currentGoupId == nil then break end
            currentGroupDatas = DormStoryGroupTaskData[currentGoupId]
        end
        return currentGoupId
    end
    -- 检查主线剧情任务的红点
    function XTaskManager.CheckStoryTaskByGroup()
        -- 只检查当前组和当前没有组id的任务时候可以领取
        local currTaskGroupId = XDataCenter.TaskManager.GetCurrentStoryTaskGroupId()

        for _, taskInfo in pairs(StoryTaskData) do
            local templates = XDataCenter.TaskManager.GetTaskTemplate(taskInfo.Id)
            -- 分组任务和非组任务
            if templates.GroupId > 0 then
                --组任务
                if currTaskGroupId and currTaskGroupId == templates.GroupId then
                    if taskInfo ~= nil and currTaskGroupId == templates.GroupId and taskInfo.State == XTaskManager.TaskState.Achieved then
                        return true
                    end
                end
            else
                --非组任务
                if taskInfo ~= nil and taskInfo.State == XTaskManager.TaskState.Achieved then
                    return true
                end
            end
        end
        return false
    end


    function XTaskManager.GetTaskTemplate(templateId)
        local template = XTaskConfig.GetTaskTemplate()[templateId]
        if not template then
            XLog.Error("XTaskManager.GetTaskTemplate error: can not found template Id is " .. templateId)
        else
            return template
        end
    end

    function XTaskManager.GetShowAfterTaskId(templateId)
        local template = XTaskManager.GetTaskTemplate(templateId)
        if template then
            return template.ShowAfterTaskId
        end
    end

    function XTaskManager.SyncTasks(tasks)
        XTool.LoopCollection(tasks.Tasks, function(value)
            local tasktype = XTaskManager.GetTaskTemplate(value.Id).Type
            TotalTaskData[value.Id] = value
            if tasktype == XTaskManager.TaskType.Story then
                StoryTaskData[value.Id] = value
            elseif tasktype == XTaskManager.TaskType.Daily then
                DailyTaskData[value.Id] = value
            elseif tasktype == XTaskManager.TaskType.Weekly then
                WeeklyTaskData[value.Id] = value
            elseif tasktype == XTaskManager.TaskType.Activity then
                ActivityTaskData[value.Id] = value
            elseif tasktype == XTaskManager.TaskType.NewPlayer then
                NewPlayerTaskData[value.Id] = value
            elseif tasktype == XTaskManager.TaskType.Achievement then
                AchvTaskData[value.Id] = value
            elseif tasktype == XTaskManager.TaskType.ArenaChallenge then
                ArenaTaskData[value.Id] = value
            elseif tasktype == XTaskManager.TaskType.DormDaily then
                DormDailyTaskData[value.Id] = value
            elseif tasktype == XTaskManager.TaskType.DormNormal then
                DormNormalTaskData[value.Id] = value
            end
        end)
        XEventManager.DispatchEvent(XEventId.EVENT_TASK_SYNC)
        CsXGameEventManager.Instance:Notify(XEventId.EVENT_TASK_SYNC)
    end
    --根据任务类型判断是否有奖励可以领取
    function XTaskManager.GetIsRewardFor(taskType)
        local taskList = nil
        if taskType == XTaskManager.TaskType.Story then
            taskList = StoryTaskData
        elseif taskType == XTaskManager.TaskType.Daily then
            taskList = DailyTaskData
        elseif taskType == XTaskManager.TaskType.Activity then
            taskList = ActivityTaskData
        elseif taskType == XTaskManager.TaskType.Achievement then
            taskList = AchvTaskData
        elseif taskType == XTaskManager.TaskType.ArenaChallenge then
            taskList = ArenaTaskData
        elseif taskType == XTaskManager.TaskType.DormDaily then
            taskList = DormDailyTaskData
        elseif taskType == XTaskManager.TaskType.DormNormal then
            taskList = DormNormalTaskData
        end

        if taskList == nil then
            return false
        end

        if taskType == XTaskManager.TaskType.Story then
            return XTaskManager.CheckStoryTaskByGroup()
        end

        for _, taskInfo in pairs(taskList) do
            if taskInfo ~= nil and taskInfo.State == XTaskManager.TaskState.Achieved then
                return true
            end
        end
        return false
    end
    --获取周奖励
    function XTaskManager.GetIsWeekReward()
        local activeness = XDataCenter.ItemManager.GetWeeklyActiveness().Count
        local wActiveness = XTaskConfig.GetWeeklyActiveness()
        local rewardIds = XTaskManager.GetWeeklyActivenessRewardIds()
        for index = 1, #rewardIds do
            if activeness >= rewardIds[index] then
                return true
            end
        end
        return false
    end

    function XTaskManager.FinishTask(taskId, cb)
        cb = cb or function() end
        XNetwork.Call("FinishTaskRequest", { TaskId = taskId }, function(reply)
            if reply.Code ~= XCode.Success then
                XUiManager.TipCode(reply.Code)
                XEventManager.DispatchEvent(XEventId.EVENT_TASK_FINISH_FAIL)
                --BDC
                CS.XHeroBdcAgent.BdcAwardButtonClick(taskId, 2)
                return
            end
            --BDC
            CS.XHeroBdcAgent.BdcAwardButtonClick(taskId, 1)
            CsXGameEventManager.Instance:Notify(XEventId.EVENT_FINISH_TASK)
            XEventManager.DispatchEvent(XEventId.EVENT_FINISH_TASK)

            cb(reply.RewardGoodsList)

        end)
    end

    --获取历程奖励
    function XTaskManager.GetCourseReward(stageId, cb)
        cb = cb or function() end
        XNetwork.Call("GetCourseRewardRequest", { StageId = stageId }, function(reply)
            if reply.Code ~= XCode.Success then
                XUiManager.TipCode(reply.Code)
                return
            end

            -- 这里顺序不要变
            local allRewardGet = XTaskManager.SetCourseData(stageId)
            if cb then cb(allRewardGet) end

            XUiManager.OpenUiObtain(reply.RewardGoodsList)
            XEventManager.DispatchEvent(XEventId.EVENT_TASK_COURSE_REWAED)
        end)
    end

    function XTaskManager.GetActivenessReward(index, rewardId, rewardType, cb)
        index = index - 1 -- 客户端从1开始，服务端从0开始
        cb = cb or function() end
        XNetwork.Call("GetActivenessRewardRequest", { StageIndex = index, RewardId = rewardId, RewardType = rewardType }, function(reply)
            if reply.Code ~= XCode.Success then
                XUiManager.TipCode(reply.Code)
                return
            end

            cb()

            XEventManager.DispatchEvent(XEventId.EVENT_TASK_SYNC)
            CsXGameEventManager.Instance:Notify(XEventId.EVENT_TASK_SYNC)
            XUiManager.OpenUiObtain(reply.RewardGoodsList)
        end, "XTaskService", "GetActivenessReward", index, rewardId, rewardType)
    end

    ----NewPlayerTask
    function XTaskManager.GetNewPlayerTaskTalkConfig(group)
        return XTaskConfig.GetNewPlayerTaskTalkTemplate()[group]
    end

    function XTaskManager.GetNewPlayerTaskGroup(group)
        return XTaskConfig.GetNewPlayerTaskGroupTemplate()[group]
    end

    function XTaskManager.GetNewbiePlayTaskReddotByOpenDay(openDay)

        if XPlayer.NewPlayerTaskActiveDay == nil then
            return false
        end

        if XPlayer.NewPlayerTaskActiveDay < openDay then
            return false
        end

        local tasks = XTaskConfig.GetNewPlayerTaskGroupTemplate()[openDay]
        if not tasks or not tasks.TaskId then return false end

        for _, id in pairs(tasks.TaskId) do
            local stateTask = XTaskManager.GetTaskDataById(id)
            if stateTask and stateTask.State == XTaskManager.TaskState.Achieved then
                return true
            end
        end
        return false
    end

    function XTaskManager.GetNewPlayerTaskListByGroup(group)
        local tTaskGroupConfig = XTaskConfig.GetNewPlayerTaskGroupTemplate()[group]
        if not tTaskGroupConfig then return end
        local tTaskIdList = tTaskGroupConfig.TaskId
        if not tTaskIdList then return end
        local tCurGroupTaskList = {}
        for i, v in ipairs(tTaskIdList) do
            local taskData = NewPlayerTaskData[v]
            local template = XTaskConfig.GetTaskTemplate()[v]
            local preId = template and template.ShowAfterTaskId
            preId = preId and preId > 0 and preId
            local preTask = preId and NewPlayerTaskData[preId]
            if not preTask or preTask and preTask.State == XTaskManager.TaskState.Finish then
                tableInsert(tCurGroupTaskList, v)
            end
        end
        tableSort(tCurGroupTaskList, function(aId, bId)
            local a = NewPlayerTaskData[aId]
            local b = NewPlayerTaskData[bId]
            local fCallfunc = function(aId, bId)
                return aId < bId
            end
            if a and b then
                if a.State ~= b.State then
                    if a.State == XTaskManager.TaskState.Achieved then
                        return true
                    end
                    if b.State == XTaskManager.TaskState.Achieved then
                        return false
                    end
                    if a.State == XTaskManager.TaskState.Finish or a.State == XTaskManager.TaskState.Invalid then
                        return false
                    end
                    if b.State == XTaskManager.TaskState.Finish or b.State == XTaskManager.TaskState.Invalid then
                        return true
                    end
                else
                    return fCallfunc(aId, bId)
                end
            else
                if a and a.State == XTaskManager.TaskState.Finish then
                    return false
                end
                if b and b.State == XTaskManager.TaskState.Finish then
                    return true
                end
                return fCallfunc(aId, bId)
            end

        end)
        return tCurGroupTaskList
    end

    function XTaskManager.GetNewPlayerGroupTaskStatus(group)

        if XPlayer.NewPlayerTaskActiveDay < group then
            return XTaskManager.NewPlayerTaskGroupState.Lock
        end

        local tTaskGroupConfig = XTaskConfig.GetNewPlayerTaskGroupTemplate()[group]
        if not tTaskGroupConfig then return end
        local tTaskIdList = tTaskGroupConfig.TaskId
        if not tTaskIdList then return end
        local finishCount = 0
        for i, v in ipairs(tTaskIdList) do
            local tTaskData = NewPlayerTaskData[v]
            if not tTaskData then
                return XTaskManager.NewPlayerTaskGroupState.Lock
            end
            local template = XTaskManager.GetTaskTemplate(tTaskData.Id)
            local preId = template and template.ShowAfterTaskId
            local preTask = preId == 0 and nil or TotalTaskData[preId]

            if preTask then
                if preTask.State == XTaskManager.TaskState.Finish and tTaskData.State == XTaskManager.TaskState.Achieved then
                    return XTaskManager.NewPlayerTaskGroupState.HasAward
                end
            elseif FinishedTasks[preId] then
                return XTaskManager.NewPlayerTaskGroupState.HasAward
            end

            if not preTask and tTaskData.State == XTaskManager.TaskState.Achieved then
                return XTaskManager.NewPlayerTaskGroupState.HasAward
            end

            if tTaskData.State == XTaskManager.TaskState.Finish then
                finishCount = finishCount + 1
            end
        end

        if finishCount == #tTaskIdList then
            return XTaskManager.NewPlayerTaskGroupState.AllFinish
        end

        return XTaskManager.NewPlayerTaskGroupState.AllTodo
    end

    function XTaskManager.FindNewPlayerTaskTalkContent(group)
        local config = XTaskConfig.GetNewPlayerTaskTalkTemplate()[group]
        if not config then
            return
        end
        local tTaskGroupConfig = XTaskConfig.GetNewPlayerTaskGroupTemplate()[group]
        if not tTaskGroupConfig then return end
        local tTaskIdList = tTaskGroupConfig.TaskId
        if not tTaskIdList then return end
        local finishCount = 0
        for i, v in ipairs(tTaskIdList) do
            local tTaskData = NewPlayerTaskData[v]
            if tTaskData and tTaskData.State == XTaskManager.TaskState.Finish then
                finishCount = finishCount + 1
            end
        end

        local index = 1
        for i, v in ipairs(config.GetCount) do
            if finishCount >= v then
                index = i
            end
        end
        return config.TalkContent[index], config
    end

    function XTaskManager.SetNewPlayerTaskActiveUi(group)
        XNetwork.Call("SetNewPlayerTaskActiveUiRequest", { Group = group }, function(reply)
            if reply.Code ~= XCode.Success then
                XUiManager.TipCode(reply.Code)
                return
            end
            XPlayer.SetNewPlayerTaskActiveUi(reply.Result)
        end)
    end

    function XTaskManager.CheckTaskFinished(taskId)
        local taskData = XTaskManager.GetTaskDataById(taskId)
        return taskData and taskData.State == XTaskManager.TaskState.Finish
    end

    function XTaskManager.CheckTaskAchieved(taskId)
        local taskData = XTaskManager.GetTaskDataById(taskId)
        return taskData and taskData.State == XTaskManager.TaskState.Achieved
    end

    function XTaskManager.GetFinalChapterId()
        for k, v in pairs(CourseInfos or {}) do
            if v.NextChapterId == nil then
                return k
            end
        end
        return nil
    end

    function XTaskManager.CheckNewbieActivenessAvaliable()
        local currentCount = XDataCenter.ItemManager.GetCount(ITEM_NEWBIE_PROGRESS_ID)
        for k, v in pairs(XTaskConfig.GetTaskNewbieActivenessTemplate().Activeness or {}) do
            if not XTaskManager.CheckNewbieActivenessRecord(v) and currentCount >= v then
                return true
            end
        end
        return false
    end

    function XTaskManager.CheckNewbieTaskAvaliable()
        if not XFunctionManager.JudgeOpen(XFunctionManager.FunctionName.SkipTarget) then
            return false
        end

        if XTaskManager.CheckNewbieActivenessAvaliable() then
            return true
        end

        for id, groupDatas in pairs(XTaskConfig.GetNewPlayerTaskGroupTemplate() or {}) do
            for _, taskId in pairs(groupDatas.TaskId or {}) do
                local stateTask = XTaskManager.GetTaskDataById(taskId)
                if stateTask and stateTask.State ~= XTaskManager.TaskState.Finish and stateTask.State ~= XTaskManager.TaskState.Invalid then
                    return true
                end
            end
        end
        return false
    end

    function XTaskManager.CheckNewbieActivenessRecord(activenessId)
        for _, record in pairs(NewbieActivenessRecord or {}) do
            if activenessId == record then
                return true
            end
        end
        return false
    end

    function XTaskManager.UpdateNewbieActivenessRecord(activenessId)
        for _, record in pairs(NewbieActivenessRecord or {}) do
            if activenessId == record then
                return
            end
        end
        NewbieActivenessRecord[#NewbieActivenessRecord + 1] = activenessId
    end

    function XTaskManager.GetStoryTaskShowId()
        local groupId = XTaskManager.GetCurrentStoryTaskGroupId()
        if groupId == nil or groupId <= 0 then
            return 0
        end
        -- 有没有主题任务。
        local maxPriority = 0
        local currentTask = 0
        for k, v in pairs(StoryTaskData) do
            local templates = XTaskManager.GetTaskTemplate(v.Id)
            if templates.GroupId == groupId and templates.ShowType == 1 then
                if v.State ~= XTaskManager.TaskState.Finish and v.State ~= XTaskManager.TaskState.Invalid then
                    if templates.Priority >= maxPriority then
                        maxPriority = templates.Priority
                        currentTask = v.Id
                    end
                end
            end
        end
        return currentTask
    end

    function XTaskManager.SaveNewPlayerHint(key, value)
        if XPlayer.Id then
            key = string.format("%s_%s", tostring(XPlayer.Id), key)
            CS.UnityEngine.PlayerPrefs.SetInt(key, value)
            CS.UnityEngine.PlayerPrefs.Save()
        end
    end

    function XTaskManager.GetNewPlayerHint(key, defaultValue)
        if XPlayer.Id then
            key = string.format("%s_%s", tostring(XPlayer.Id), key)
            if CS.UnityEngine.PlayerPrefs.HasKey(key) then
                local newPlayerHint = CS.UnityEngine.PlayerPrefs.GetInt(key)
                return (newPlayerHint == nil or newPlayerHint == 0) and defaultValue or newPlayerHint
            end
        end
        return defaultValue
    end

    function XTaskManager.GetNewPlayerRewardReq(activeness, rewardList, cb)
        XNetwork.Call("GetNewPlayerRewardRequest", { Activeness = activeness }, function(response)
            cb = cb or function() end
            if response.Code == XCode.Success then
                XUiManager.OpenUiObtain(rewardList, CS.XTextManager.GetText("DailyActiveRewardTitle"))
                XTaskManager.UpdateNewbieActivenessRecord(activeness)
                cb()
                XEventManager.DispatchEvent(XEventId.EVENT_NEWBIETASK_PROGRESSCHANGED)
            else
                XUiManager.TipCode(response.Code)
            end
        end)
    end


    function XTaskManager.GetTaskStoryListData()
        return XTaskManager.SortTaskByGroup(XTaskManager.GetDormNormalTaskList()) or {}
    end

    function XTaskManager.SortTaskByGroup(tasks)
        local currTaskGroupId = XDataCenter.TaskManager.GetCurrentDormStoryTaskGroupId()
        if currTaskGroupId == nil or currTaskGroupId <= 0 then return tasks end
        local sortedTasks = {}
        -- 过滤，留下组id相同，没有组id的任务
        for k, v in pairs(tasks) do
            local templates = XDataCenter.TaskManager.GetTaskTemplate(v.Id)
            if templates.GroupId <= 0 or templates.GroupId == currTaskGroupId then

                v.SortWeight = 1
                v.SortWeight = (templates.GroupId > 0) and 2 or v.SortWeight
                v.SortWeight = (v.State == XDataCenter.TaskManager.TaskState.Achieved) and 3 or v.SortWeight
                v.SortWeight = (templates.GroupTheme == 1) and 4 or v.SortWeight
                v.GroupTheme = templates.GroupTheme
                tableInsert(sortedTasks, v)
            end
        end

        -- 排序，主题任务，可领取的任务，不能领取的任务
        tableSort(sortedTasks, function(taskA, taskB)
            local templatesTaskA = XDataCenter.TaskManager.GetTaskTemplate(taskA.Id)
            local templatesTaskB = XDataCenter.TaskManager.GetTaskTemplate(taskB.Id)
            if taskA.SortWeight == taskB.SortWeight then
                return templatesTaskA.Priority > templatesTaskB.Priority
            end
            return taskA.SortWeight > taskB.SortWeight
        end)

        return sortedTasks
    end

    --宿舍主界面，任务提示。（可领奖励或未完成的）
    function XTaskManager.GetDormTaskTips()
        local storytasks = XTaskManager.GetTaskStoryListData()
        local taskguideids = XDormConfig.GetDormitoryGuideTaskCfg()
        if _G.next(storytasks) then
            for _, data in pairs(storytasks) do
                if data.State == XTaskManager.TaskState.Achieved and taskguideids[data.Id] then
                    return data, XTaskManager.TaskType.DormNormal, XTaskManager.TaskState.Achieved
                end
            end
        end

        if _G.next(storytasks) then
            for _, data in pairs(storytasks) do
                if data.State ~= XTaskManager.TaskState.Achieved and data.State ~= XTaskManager.TaskState.Finish and taskguideids[data.Id] and data.GroupTheme ~= 1 then
                    return data, XTaskManager.TaskType.DormNormal, XTaskManager.TaskState.Standby
                end
            end
        end

        local dailytasks = XTaskManager.GetDormDailyTaskList() or {}
        if _G.next(dailytasks) then
            for _, data in pairs(dailytasks) do
                if data.State == XTaskManager.TaskState.Achieved then
                    return data, XTaskManager.TaskType.DormDaily, XTaskManager.TaskState.Achieved
                end
            end
        end

        if _G.next(dailytasks) then
            for _, data in pairs(dailytasks) do
                if data.State ~= XTaskManager.TaskState.Achieved and data.State ~= XTaskManager.TaskState.Finish then
                    return data, XTaskManager.TaskType.DormDaily, XTaskManager.TaskState.Standby
                end
            end
        end
    end

    -- 获取每周任务刷新时间
    function XTaskManager.GetWeeklyTaskRefreshTime()
        return WeekTaskRefreshDay, WeekTaskEpochTime
    end

    -- 检查任务是否特定时间刷新（每日/每周）
    function XTaskManager.CheckTaskRefreshable(taskId)
        local config = XTaskManager.GetTaskTemplate(taskId)
        if not config then return false end


        local taskType = config.Type
        if taskType == XTaskManager.TaskType.Daily then
            return true
        end

        if taskType == XTaskManager.TaskType.Weekly then
            return true
        end

        if taskType == XTaskManager.TaskType.TimeLimit then
            return XTaskConfig.GetTimeLimitWeeklyTasksCheckTable()[taskId]
        end

        return false
    end

    XTaskManager.Init()
    return XTaskManager
end


XRpc.NotifyTask = function(data)
    XDataCenter.TaskManager.SyncTasks(data.Tasks)
end

XRpc.NotifyTaskData = function(data)
    XDataCenter.TaskManager.InitTaskData(data.TaskData)
end