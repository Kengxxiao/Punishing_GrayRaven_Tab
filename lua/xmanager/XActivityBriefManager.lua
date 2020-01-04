XActivityBriefManagerCreator = function()
    local pairs = pairs
    local CSXDateGetTime = CS.XDate.GetTime
    local CSUnityEnginePlayerPrefs = CS.UnityEngine.PlayerPrefs

    local ActivityConfig = XActivityBriefConfigs.GetActivityConfig()
    local FirstOpenUi = true
    local CookieInited = false

    local XActivityBriefManager = {}

    function XActivityBriefManager.GetActivityShopId()
        return ActivityConfig.ShopId
    end

    function XActivityBriefManager.GetActivityShopGoods()
        local goods = {}
        local shopId = XDataCenter.ActivityBriefManager.GetActivityShopId()
        goods = XShopManager.GetShopGoodsList(shopId)
        return goods
    end

    function XActivityBriefManager.GetActivityShopEndTime()
        local endTime = 0

        local taskGroupId = ActivityConfig.TaskGroupId
        if taskGroupId == 0 then return endTime end

        local taskConfig = XTaskConfig.GetTimeLimitTaskCfg(taskGroupId)
        endTime = CSXDateGetTime(taskConfig.EndTimeStr)

        return endTime
    end

    function XActivityBriefManager.GetActivityTaskTime()
        local beginTime, endTime = 0, 0

        local taskGroupId = ActivityConfig.TaskGroupId
        if taskGroupId == 0 then return beginTime, endTime end

        local taskConfig = XTaskConfig.GetTimeLimitTaskCfg(taskGroupId)
        beginTime = CSXDateGetTime(taskConfig.StartTimeStr)
        endTime = CSXDateGetTime(taskConfig.EndTimeStr)

        return beginTime, endTime
    end

    function XActivityBriefManager.GetActivityTaskDatas()
        local taskGroupId = ActivityConfig.TaskGroupId
        if taskGroupId == 0 then return {} end
        return XDataCenter.TaskManager.GetTimeLimitTaskListByGroupId(ActivityConfig.TaskGroupId)
    end

    function XActivityBriefManager.CheckAnyTaskFinished()
        local taskDatas = XActivityBriefManager.GetActivityTaskDatas()

        local achieved = XDataCenter.TaskManager.TaskState.Achieved
        for _, taskData in pairs(taskDatas) do
            if taskData.State == achieved then
                return true
            end
        end

        return false
    end

    function XActivityBriefManager:CheckActivityBriefOpen()
        if not XFunctionManager.JudgeCanOpen(XFunctionManager.FunctionName.ActivityBrief) then
            return false
        end

        local nowTime = XTime.Now()
        local startTime = CSXDateGetTime(ActivityConfig.StartTimeStr)
        local endTime = CSXDateGetTime(ActivityConfig.EndTimeStr)
        return startTime <= nowTime and nowTime < endTime
    end

    function XActivityBriefManager.IsFirstOpen()
        if not CookieInited then
            FirstOpenUi = not XActivityBriefManager.ReadCookie()
            CookieInited = true
        end
        return FirstOpenUi
    end

    function XActivityBriefManager.SetNotFirstOpen()
        FirstOpenUi = false
        CSUnityEnginePlayerPrefs.SetInt(XActivityBriefManager.GetCookieKeyStr(), 1)
        CSUnityEnginePlayerPrefs.Save()
    end

    function XActivityBriefManager.GetCookieKeyStr()
        return string.format("%s%s", ActivityConfig.EndTimeStr, XPlayer.Id)
    end

    function XActivityBriefManager.ReadCookie()
        return CSUnityEnginePlayerPrefs.HasKey(XActivityBriefManager.GetCookieKeyStr())
    end

    return XActivityBriefManager
end