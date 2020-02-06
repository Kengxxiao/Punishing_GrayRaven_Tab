XActivityManagerCreator = function()
    local pairs = pairs
    local ipairs = ipairs
    local tostring = tostring
    local tonumber = tonumber
    local tableSort = table.sort
    local tableInsert = table.insert
    local stringSplit = string.Split
    local ParseToTimestamp = XTime.ParseToTimestamp
    local CSUnityEnginePlayerPrefs = CS.UnityEngine.PlayerPrefs

    local SortedActivityGroupInfos = {}
    local HaveReadActivityIds = {}

    local XActivityManager = {}

    function XActivityManager.Init()
        XEventManager.AddEventListener(XEventId.EVENT_LOGIN_SUCCESS, XActivityManager.ReadCookie)
        XActivityManager.InitSortedActivityGroupInfos()
    end

    --构建活动组-活动配置索引表并分别根据SortId排序
    function XActivityManager.InitSortedActivityGroupInfos()
        local sortFunc = function(l, r)
            return l.SortId < r.SortId
        end

        local activityGroupTemplates = XActivityConfigs.GetActivityGroupTemplates()
        for groupId, template in pairs(activityGroupTemplates) do
            SortedActivityGroupInfos[groupId] = {
                SortId = template.SortId,
                ActivityGroupCfg = template,
                ActivityCfgs = {}
            }
        end

        local activityTemplates = XActivityConfigs.GetActivityTemplates()
        for activityId, template in pairs(activityTemplates) do
            local groupId = template.GroupId
            local activityGroupCfg = SortedActivityGroupInfos[groupId]
            if not activityGroupCfg then
                XLog.Error("XActivityManager.InitSortedActivityGroupInfos error:activityGroupCfg not exist, GroupId is" .. groupId)
                return
            end
            local activityCfgs = activityGroupCfg.ActivityCfgs
            tableInsert(activityCfgs, template)
        end

        for _, activityGroupInfo in pairs(SortedActivityGroupInfos) do
            tableSort(activityGroupInfo.ActivityCfgs, sortFunc)
        end

        tableSort(SortedActivityGroupInfos, sortFunc)
    end

    function XActivityManager.IsActivityOpen(activityId)
        if not activityId then return false end
        local activityCfg = XActivityConfigs.GetActivityTemplate(activityId)
        if not activityCfg then return false end

        local beginTime, endTime
        local now = XTime.GetServerNowTimestamp()
        if activityCfg.ActivityType == XActivityConfigs.ActivityType.Task then
            local taskGroupId = activityCfg.Params[1]
            local timeLimitTaskCfg = XTaskConfig.GetTimeLimitTaskCfg(taskGroupId)
            beginTime = ParseToTimestamp(timeLimitTaskCfg.StartTimeStr)
            endTime = ParseToTimestamp(timeLimitTaskCfg.EndTimeStr)
        else
            beginTime = ParseToTimestamp(activityCfg.BeginTime)
            endTime = ParseToTimestamp(activityCfg.EndTime)
        end

        return beginTime <= now and now < endTime
    end

    function XActivityManager.GetActivityGroupInfos()
        local groupInfos = {}

        for _, activityGroupInfo in ipairs(SortedActivityGroupInfos) do
            local groupInfo = {}

            for _, activityCfg in ipairs(activityGroupInfo.ActivityCfgs) do
                if XActivityManager.IsActivityOpen(activityCfg.Id) then
                    groupInfo.ActivityGroupCfg = groupInfo.ActivityGroupCfg or activityGroupInfo.ActivityGroupCfg
                    groupInfo.ActivityCfgs = groupInfo.ActivityCfgs or {}
                    tableInsert(groupInfo.ActivityCfgs, activityCfg)
                end
            end

            if next(groupInfo) then
                tableInsert(groupInfos, groupInfo)
            end
        end

        return groupInfos
    end

    function XActivityManager.GetActivityTaskData(activityId)
        local activityCfg = XActivityConfigs.GetActivityTemplate(activityId)
        if activityCfg.ActivityType ~= XActivityConfigs.ActivityType.Task then
            return {}
        end

        local taskGroupId = activityCfg.Params[1]
        return XDataCenter.TaskManager.GetTimeLimitTaskListByGroupId(taskGroupId)
    end

    function XActivityManager.CheckRedPoint()
        local activityTemplates = XActivityConfigs.GetActivityTemplates()
        for activityId in pairs(activityTemplates) do
            if XActivityManager.CheckRedPointByActivityId(activityId) then
                return true
            end
        end
        return false
    end

    function XActivityManager.CheckRedPointByActivityId(activityId)
        if not XActivityManager.IsActivityOpen(activityId) then
            return false
        end

        --任务类型特殊加入已完成小红点逻辑
        local activityCfg = XActivityConfigs.GetActivityTemplate(activityId)
        if activityCfg.ActivityType == XActivityConfigs.ActivityType.Task then
            local achieved = XDataCenter.TaskManager.TaskState.Achieved
            local taskDatas = XActivityManager.GetActivityTaskData(activityId)
            for _, taskData in pairs(taskDatas) do
                if taskData.State == achieved then
                    return true
                end
            end
        end

        return not HaveReadActivityIds[activityId]
    end

    function XActivityManager.GetCookieKeyStr()
        return tostring(XPlayer.Id) .. "_ActivityReadInfoCookieKey"
    end

    function XActivityManager.ReadCookie()
        if not CSUnityEnginePlayerPrefs.HasKey(XActivityManager.GetCookieKeyStr()) then
            return
        end

        local dataStr = CSUnityEnginePlayerPrefs.GetString(XActivityManager.GetCookieKeyStr())
        local msgTab = stringSplit(dataStr, '\t')
        if not msgTab or #msgTab <= 0 then
            return
        end

        for _, activityIdStr in ipairs(msgTab) do
            local activityId = tonumber(activityIdStr)
            if activityId then
                if XActivityManager.IsActivityOpen(activityId) then
                    HaveReadActivityIds[activityId] = true
                else
                    HaveReadActivityIds[activityId] = nil
                end
            end
        end
    end

    function XActivityManager.SaveInGameNoticeReadList(activityId)
        if not XActivityManager.IsActivityOpen(activityId) then return end
        HaveReadActivityIds[activityId] = true

        local saveContent = ""
        for id in pairs(HaveReadActivityIds) do
            saveContent = saveContent .. id .. '\t'
        end

        CSUnityEnginePlayerPrefs.SetString(XActivityManager.GetCookieKeyStr(), saveContent)
        CSUnityEnginePlayerPrefs.Save()

        XEventManager.DispatchEvent(XEventId.EVENT_ACTIVITY_ACTIVITIES_READ_CHAGNE)
    end

    XActivityManager.Init()

    return XActivityManager
end