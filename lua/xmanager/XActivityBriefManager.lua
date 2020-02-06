XActivityBriefManagerCreator = function()
    local pairs = pairs
    local ParseToTimestamp = XTime.ParseToTimestamp
    local CSUnityEnginePlayerPrefs = CS.UnityEngine.PlayerPrefs

    local ActivityConfig = XActivityBriefConfigs.GetActivityConfig()
    local ActivityEntryConfigTemp = XActivityBriefConfigs.GetActivityEntryConfigTemp()
    local FirstOpenUi = true
    local CookieInited = false

    local XActivityBriefManager = {}

    function XActivityBriefManager.GetActivityShopId()
        return ActivityConfig.ShopId
    end

    function XActivityBriefManager.GetActivityGachaId()
        return ActivityConfig.GachaId
    end

    function XActivityBriefManager.GetActivityGachaUi()
        return ActivityConfig.GachaUi
    end

    function XActivityBriefManager.GetActivityGacha3DBg()
        return ActivityConfig.Gacha3DBg
    end

    function XActivityBriefManager.GetActivityActivityPointId()
        return ActivityConfig.ActivityPointId
    end

    function XActivityBriefManager.CheakTaskIsInMark(Id)
        for k, v in pairs(ActivityConfig.MarkTaskId or {}) do
            if v == Id then
                return true
            end
        end
        return false
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
        endTime = ParseToTimestamp(taskConfig.EndTimeStr)

        return endTime or 0
    end

    function XActivityBriefManager.GetActivityTaskTime()
        local beginTime, endTime = 0, 0

        local taskGroupId = ActivityConfig.TaskGroupId
        if taskGroupId == 0 then return beginTime, endTime end

        local taskConfig = XTaskConfig.GetTimeLimitTaskCfg(taskGroupId)
        beginTime = ParseToTimestamp(taskConfig.StartTimeStr)
        endTime = ParseToTimestamp(taskConfig.EndTimeStr)

        return beginTime or 0, endTime or 0
    end

    function XActivityBriefManager.GetActivityBriefTime()
        local beginTime = ParseToTimestamp(ActivityConfig.StartTimeStr)
        local endTime = ParseToTimestamp(ActivityConfig.EndTimeStr)

        return beginTime or 0, endTime or 0
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

        local nowTime = XTime.GetServerNowTimestamp()
        local startTime = ParseToTimestamp(ActivityConfig.StartTimeStr)
        local endTime = ParseToTimestamp(ActivityConfig.EndTimeStr)
        return startTime and endTime and startTime <= nowTime and nowTime < endTime
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

    -- 临时活动入口 begin 
    function XActivityBriefManager:CheckActivityEntryOpen()
        local nowTime = XTime.GetServerNowTimestamp()
        local startTime = ParseToTimestamp(ActivityEntryConfigTemp.StartTimeStr)
        local endTime = ParseToTimestamp(ActivityEntryConfigTemp.EndTimeStr)
        return startTime and endTime and startTime <= nowTime and nowTime < endTime
    end

    function XActivityBriefManager.GetActivityEntrySkipId()
        return ActivityEntryConfigTemp.ShopId
    end

    function XActivityBriefManager.GetActivityEntryIcon()
        return ActivityEntryConfigTemp.Gacha3DBg
    end
    -- 临时活动入口 end 
    return XActivityBriefManager
end