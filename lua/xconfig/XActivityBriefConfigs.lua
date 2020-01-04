

local TABLE_ACTIVITY_PATH = "Client/ActivityBrief/ActivityBrief.tab"
local TABLE_ACTIVITY_GROUP_PATH = "Client/ActivityBrief/ActivityBriefGroup.tab"

local ActivityTemplates = {}
local ActivityGroupTemplates = {}

XActivityBriefConfigs = XActivityBriefConfigs or {}

--活动名称Id
XActivityBriefConfigs.ActivityGroupId = {
    MainLine = 1, --主线活动
    Branch = 2, --支线活动
    BossSingle = 3, --单机Boss活动
    BossOnline = 4, --联机Boss活动
    Prequel = 5, --间章预告
}

function XActivityBriefConfigs.Init()
    ActivityTemplates = XTableManager.ReadByIntKey(TABLE_ACTIVITY_PATH, XTable.XTableBriefActivity, "Id")
    ActivityGroupTemplates = XTableManager.ReadByIntKey(TABLE_ACTIVITY_GROUP_PATH, XTable.XTableActivityBriefGroup, "Id")
end

function XActivityBriefConfigs.GetActivityConfig()
    return ActivityTemplates[1]
end

function XActivityBriefConfigs.GetActivityGroupConfig(groupId)
    local groupConfig = ActivityGroupTemplates[groupId]
    if not groupConfig then
        XLog.Error("XActivityBriefConfigs.GetActivityGroupConfig error,sectionId is" .. groupId)
        return
    end
    return groupConfig
end
