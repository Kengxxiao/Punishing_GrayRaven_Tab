XTaskForceConfigs = XTaskForceConfigs or {}


--派遣表
local TABLE_TASKFORCE_CONFIG = "Share/TaskForce/TaskForceConfig.tab"
local TABLE_TASKFORCE_EXPEND = "Share/TaskForce/TaskForceExpend.tab"
local TABLE_TASKFORCE_SECTION = "Share/TaskForce/TaskForceSection.tab"
local TABLE_TASKFORCE_TASKPOOL = "Share/TaskForce/TaskForceTaskPool.tab"

local TaskForceConfig = {}
local TaskForceExpendConfig = {}
local TaskForceSectionConfig = {}
local TaskForceTaskPoolConfig = {}
local TaskForceCountConfig = {}

local MaxRefreshTimes = 0 --最大刷新次数，可以超过
local TotalFreeRefreshTimes = 0 -- 总的免费次数
local TotalSectionCount = 0 -- 总的章节数

--初始化表
function XTaskForceConfigs.Init()
    TaskForceConfig = XTableManager.ReadByIntKey(TABLE_TASKFORCE_CONFIG, XTable.XTableTaskForceConfig, "Id")
    TaskForceExpendConfig = XTableManager.ReadByIntKey(TABLE_TASKFORCE_EXPEND, XTable.XTableTaskForceExpend, "RefreshCount")
    TaskForceSectionConfig = XTableManager.ReadByIntKey(TABLE_TASKFORCE_SECTION, XTable.XTableTaskForceSection, "Id")
    TaskForceTaskPoolConfig = XTableManager.ReadByIntKey(TABLE_TASKFORCE_TASKPOOL, XTable.XTableTaskForceTask, "Id")

    --初始化刷新花费相关
    if TaskForceExpendConfig then
        TotalFreeRefreshTimes = 0
        for k, v in pairs(TaskForceExpendConfig) do
            if k > MaxRefreshTimes then
                MaxRefreshTimes = k
            end

            if v.ItemCount == 0 then
                TotalFreeRefreshTimes = TotalFreeRefreshTimes + 1
            end
        end
    end

    if TaskForceSectionConfig then
        TotalSectionCount = #TaskForceSectionConfig
    end

    --用MaxTaskForceCount作为key
    if TaskForceConfig then
        for k, v in pairs(TaskForceConfig) do
            TaskForceCountConfig[v.MaxTaskForceCount] = v
        end
    end

    XTaskForceConfigs.MaxRefreshTimes = MaxRefreshTimes
    XTaskForceConfigs.TotalFreeRefreshTimes = TotalFreeRefreshTimes
    XTaskForceConfigs.TotalSectionCount = TotalSectionCount
end

XTaskForceConfigs.GetTaskForceConfig = function()
    return TaskForceConfig
end

XTaskForceConfigs.GetTaskForceExpendConfig = function()
    return TaskForceExpendConfig
end

XTaskForceConfigs.GetTaskForceSectionConfig = function()
    return TaskForceSectionConfig
end

XTaskForceConfigs.GetTaskForceTaskPoolConfig = function()
    return TaskForceTaskPoolConfig
end

XTaskForceConfigs.GetTaskForceCountConfig = function()
    return TaskForceCountConfig
end

