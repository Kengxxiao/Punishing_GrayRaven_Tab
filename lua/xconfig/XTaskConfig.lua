XTaskConfig = {}

XTaskConfig.ActivenessRewardType = {
    Daily = 1,
    Weekly = 2,
    Newbie = 3
}

XTaskConfig.PANELINDEX = {
    Story = 1,
    Daily = 2,
}

local TaskTemplate = {}
local TaskActivenessTemplate = {}
local NewPlayerTaskGroupTemplate = {}
local NewPlayerTaskTalkTemplate = {}
local TaskNewbieActivenessTemplate = {}
local CourseTemplate = {}
local DailyActivenessTemplate = {}
local WeeklyActivenessTemplate = {}
local TimeLimitTaskTemplate = {}
local TimeLimitDailyTasksCheckTable = {}
local TimeLimitWeeklyTasksCheckTable = {}
local TaskConditionTemplate = {}
local AlarmClockTemplate = {}

local DailyActivenessTotal = 0

local TABLE_TASK_PATH = "Share/Task/Task.tab"
local TABLE_TASK_ACTIVENESS_PATH = "Share/Task/TaskActiveness.tab"
local TABLE_NEW_PLAYER_TASK_GROUP_PATH = "Share/Task/NewPlayerTaskGroup.tab"
local TABLE_NEW_PLAYER_TASK_TALK_PATH = "Client/Task/NewPlayerTaskTalk.tab"
local TABLE_TASK_COURSE_PATH = "Share/Task/Course.tab"
local TABLE_TASK_TIME_LIMIT_PATH = "Share/Task/TaskTimeLimit.tab"
local TABLE_TASK_CONDITION_PATH = "Share/Task/Condition.tab"
local TABLE_ALARMCLOCK_PATH = "Share/AlarmClock/AlarmClock.tab"
local NextTaskIds = {}

local function SetNextTaskId()
    for id, task in pairs(TaskTemplate) do
        NextTaskIds[task.ShowAfterTaskId] = id
    end
end

-- 限时任务类型中每日/周刷新的打上标记
local function InitTimeLimitWithRefreshableTasks()
    for _, config in pairs(TimeLimitTaskTemplate) do
        for _, taskId in pairs(config.DayTaskId) do
            TimeLimitDailyTasksCheckTable[taskId] = true
        end
        for _, taskId in pairs(config.WeekTaskId) do
            TimeLimitWeeklyTasksCheckTable[taskId] = true
        end
    end
end

function XTaskConfig.Init()
    TaskTemplate = XTableManager.ReadByIntKey(TABLE_TASK_PATH, XTable.XTableTask, "Id")
    TaskConditionTemplate = XTableManager.ReadByIntKey(TABLE_TASK_CONDITION_PATH, XTable.XTableTaskCondition, "Id")
    SetNextTaskId()
    TaskActivenessTemplate = XTableManager.ReadByIntKey(TABLE_TASK_ACTIVENESS_PATH, XTable.XTableTaskActiveness, "Type")
    NewPlayerTaskGroupTemplate =
        XTableManager.ReadByIntKey(TABLE_NEW_PLAYER_TASK_GROUP_PATH, XTable.XTableNewPlayerTaskGroup, "Id")
    NewPlayerTaskTalkTemplate =
        XTableManager.ReadByIntKey(TABLE_NEW_PLAYER_TASK_TALK_PATH, XTable.XTableNewPlayerTaskTalk, "Id")
    CourseTemplate = XTableManager.ReadByIntKey(TABLE_TASK_COURSE_PATH, XTable.XTableCourse, "StageId")
    TimeLimitTaskTemplate = XTableManager.ReadByIntKey(TABLE_TASK_TIME_LIMIT_PATH, XTable.XTableTaskTimeLimit, "Id")
    AlarmClockTemplate = XTableManager.ReadByIntKey(TABLE_ALARMCLOCK_PATH, XTable.XTableAlarmClock, "ClockId")
    InitTimeLimitWithRefreshableTasks()

    DailyActivenessTemplate = TaskActivenessTemplate[XTaskConfig.ActivenessRewardType.Daily]
    WeeklyActivenessTemplate = TaskActivenessTemplate[XTaskConfig.ActivenessRewardType.Weekly]
    TaskNewbieActivenessTemplate = TaskActivenessTemplate[XTaskConfig.ActivenessRewardType.Newbie]

    local count = #DailyActivenessTemplate.Activeness
    DailyActivenessTotal = DailyActivenessTemplate.Activeness[count]
end

----------------------------------------- 配置表对外暴露的get方法开始 -----------------------------------------

function XTaskConfig.GetTaskTemplate()
    return TaskTemplate
end

function XTaskConfig.GetCourseTemplate()
    return CourseTemplate
end

function XTaskConfig.GetNewPlayerTaskGroupTemplate()
    return NewPlayerTaskGroupTemplate
end

function XTaskConfig.GetNewPlayerTaskTalkTemplate()
    return NewPlayerTaskTalkTemplate
end

function XTaskConfig.GetTaskNewbieActivenessTemplate()
    return TaskNewbieActivenessTemplate
end

----------------------------------------- 配置表对外暴露的get方法结束 -----------------------------------------

function XTaskConfig.GetNextTaskId(id)
    return NextTaskIds[id]
end

function XTaskConfig.GetDailyActivenessTotal()
    return DailyActivenessTotal
end

function XTaskConfig.GetDailyActiveness()
    return DailyActivenessTemplate.Activeness
end

function XTaskConfig.GetDailyActivenessRewardIds()
    return DailyActivenessTemplate.RewardId
end

function XTaskConfig.GetWeeklyActiveness()
    return WeeklyActivenessTemplate.Activeness
end

function XTaskConfig.GetWeeklyActivenessRewardIds()
    return WeeklyActivenessTemplate.RewardId
end

function XTaskConfig.GetTimeLimitTaskCfg(id)
    local cfg = TimeLimitTaskTemplate[id]
    if not cfg then
        XLog.Error("XTaskConfig.GetTimeLimitTaskCfg error:can not find template,id is" .. id)
        return
    end
    return cfg
end

function XTaskConfig.GetTimeLimitDailyTasksCheckTable()
    return TimeLimitDailyTasksCheckTable
end

function XTaskConfig.GetTimeLimitWeeklyTasksCheckTable()
    return TimeLimitWeeklyTasksCheckTable
end

function XTaskConfig.GetTaskCondition(conditionId)
    return TaskConditionTemplate[conditionId]
end

function XTaskConfig.GetAlarmClockById(id)
    local template = AlarmClockTemplate[id]
    if not template then
        XLog.Error("XTaskConfig.GetAlarmClockById error:can not find template,id is" .. tostring(id))
        return
    end
    return template
end
