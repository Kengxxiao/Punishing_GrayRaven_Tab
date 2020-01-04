local TABLE_ACTIVITY_PATH = "Client/Activity/Activity.tab"
local TABLE_ACTIVITY_GROUP_PATH = "Client/Activity/ActivityGroup.tab"

local ActivityTemplates = {}
local ActivityGroupTemplates = {}

XActivityConfigs = XActivityConfigs or {}

--活动类型
XActivityConfigs.ActivityType = {
    Task = 1, --任务
    Shop = 2, --商店
    Skip = 3, --跳转
}

function XActivityConfigs.Init()
    ActivityTemplates = XTableManager.ReadByIntKey(TABLE_ACTIVITY_PATH, XTable.XTableActivity, "Id")
    ActivityGroupTemplates = XTableManager.ReadByIntKey(TABLE_ACTIVITY_GROUP_PATH, XTable.XTableActivityGroup, "Id")
end

function XActivityConfigs.GetActivityTemplates()
    return ActivityTemplates
end

function XActivityConfigs.GetActivityGroupTemplates()
    return ActivityGroupTemplates
end

function XActivityConfigs.GetActivityTemplate(activityId)
    return ActivityTemplates[activityId]
end
