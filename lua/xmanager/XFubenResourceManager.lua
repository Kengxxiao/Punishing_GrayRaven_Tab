XFubenResourceManagerCreator = function()

    local XFubenResourceManager = {}

    local PREFS_LEVEL_KEY = "FunbenResourceLastLevel"
    local PREFS_REWARD_KEY = "FunbenResourceLastReward"
    -- local TABLE_LEVEL_SECTION = "Share/Fuben/FubenResource/FubenResourceLevelSection.tab"
    -- local TABLE_RESOURCE_CHAPTER = "Share/Fuben/FubenResource/FubenResourceChapter.tab"

    --资源副本配置表
    local LevelSectionCfg = {}
    --挑战副本入口表的子表
    local FubenResourceChapter = {}
    --当天副本数据
    local CurrentSectionData = nil
    local NextRefreshTime = nil
    local LastPlayerLevel = nil
    local TopRewardList = nil
    local TempTopRewardList = nil

    local ResourceType = {
        Coin = 1,
        Skill = 2,
    }

    --读取玩家本地缓存
    local function InitPrefs()
        local lastLevel = XSaveTool.GetData(XPlayer.Id .. PREFS_LEVEL_KEY)
        if lastLevel then
            LastPlayerLevel = lastLevel
        else
            LastPlayerLevel = XPlayer.Level
            XSaveTool.SaveData(XPlayer.Id .. PREFS_LEVEL_KEY, LastPlayerLevel)
        end
    end

    function XFubenResourceManager.Init()
        -- LevelSectionCfg = XTableManager.ReadByIntKey(TABLE_LEVEL_SECTION, XTable.XTableFubenResourceLevelSection, "Id")
        -- FubenResourceChapter = XTableManager.ReadByIntKey(TABLE_RESOURCE_CHAPTER, XTable.XFubenResourceChapter, "Id")
    end

    function XFubenResourceManager.InitStageInfo()
        -- for sectionId, sectionCfg in pairs(LevelSectionCfg) do
        --     for _, stageId in pairs(sectionCfg.StageList) do
        --         local stageInfo = XDataCenter.FubenManager.GetStageInfo(stageId)
        --         stageInfo.ResourceType = sectionCfg.Type
        --         stageInfo.Type = XDataCenter.FubenManager.StageType.Resource
        --     end
        -- end
    end

    --从服务器获取相关数据
    function XFubenResourceManager.InitFubenResourceData(stageMaps)
        -- CurrentSectionData = {}
        -- for _, data in pairs(stageMaps) do
        --     local cfg = LevelSectionCfg[data.ConfigId]
        --     local index = data.Index + 1
        --     local typeId = cfg.Type
        --     local localTable = {
        --         Type = typeId,
        --         Difficulty = cfg.DifficultyList[index],
        --         ColorChallenge = cfg.ColorChallengeList[index],
        --         ColorReward = cfg.ColorRewardList[index],
        --         StageId = cfg.StageList[index],
        --         LeftCount = data.LeftCount,
        --         MaxCount = cfg.DaliyCount,
        --     }
        --     CurrentSectionData[typeId] = localTable
        -- end
    end

    function XFubenResourceManager.CheckPreFight(stage)
        local stageInfo = XDataCenter.FubenManager.GetStageInfo(stage.StageId)
        local resourceData = XFubenResourceManager.GetSectionDataByTypeId(stageInfo.ResourceType)
        if resourceData.LeftCount <= 0 then
            local msg = CS.XTextManager.GetText("FubenChallengeCountNotEnough")
            XUiManager.TipMsg(msg)
            return false
        end
        return true
    end

    --更新资源副本剩余挑战次数
    function XFubenResourceManager.FubenLeftCountUpdate(data)
        CurrentSectionData[data.Type].LeftCount = data.LeftCount
    end

    --更新资源副本通关收益
    function XFubenResourceManager.FubenRewardUpdate(data)
        local maxRewards = {
            [ResourceType.Coin] = data.CoinRewardNum,
            [ResourceType.Skill] = data.SkillRewardNum,
        }
        if not TopRewardList then
            TopRewardList = maxRewards
            return
        end
        TempTopRewardList = maxRewards
    end

    --检查最高奖励是否有变化
    function XFubenResourceManager.CheckRewradChange(typeId)
        if not TempTopRewardList or not TempTopRewardList[typeId] then
            return false
        end

        if not TopRewardList then
            TopRewardList = {}
        end

        return TempTopRewardList[typeId] > (TopRewardList[typeId] or 0)
    end

    --将缓存数据更换到实际记录数据
    function XFubenResourceManager.UpdateRewardFromTemp()
        if TempTopRewardList then
            TopRewardList = TempTopRewardList
        end
        TempTopRewardList = nil
    end

    --获取玩家上次的等级和当前的等级
    function XFubenResourceManager.GetPlayerLevelInfo()
        if not LastPlayerLevel then
            InitPrefs()
        end
        local nowLevel = XPlayer.Level
        local lastLevel = nil
        if XPlayer.Level ~= LastPlayerLevel then
            if XPlayer.Level > LastPlayerLevel then
                lastLevel = LastPlayerLevel
            else
                XLog.Error("XFubenResourceManager.LastPlayerLevel is Wrong!")
            end
            LastPlayerLevel = XPlayer.Level
            XSaveTool.SaveData(XPlayer.Id .. PREFS_LEVEL_KEY, LastPlayerLevel)
        end
        return nowLevel, lastLevel
    end

    function XFubenResourceManager.GetTopRewardByTypeId(typeId)
        if TempTopRewardList and TempTopRewardList[typeId] then
            return TempTopRewardList[typeId]
        else
            return TopRewardList[typeId] or 0
        end
    end

    function XFubenResourceManager.GetResourceChapters()
        return FubenResourceChapter
    end

    --获取资源副本数据
    function XFubenResourceManager.GetSectionDatas()
        return CurrentSectionData
    end

    --根据资源副本类型ID获取资源副本Cfg
    function XFubenResourceManager.GetSectionDataByTypeId(typeId)
        return CurrentSectionData[typeId]
    end

    function XFubenResourceManager.GetRemainingTime()
        local timeNow = XTime.Now()
        if NextRefreshTime < timeNow then
            return 0
        end
        return (NextRefreshTime - timeNow)
    end

    --服务端协议
    function XFubenResourceManager.GetCurrentSectionData(callback)
        -- XNetwork.Call("ResourceStageDataRequest", nil, function(res)
        --     if res.Code ~= XCode.Success then
        --         XUiManager.TipCode(res.Code)
        --         return
        --     end
        --     NextRefreshTime = res.NextRefreshTime
        --     local stageMaps = {
        --         [ResourceType.Coin] = res.CoinStageData;
        --         [ResourceType.Skill] = res.SkillStageData;
        --     }
        --     XFubenResourceManager.InitFubenResourceData(stageMaps)
        --     if callback then
        --         callback(CurrentSectionData)
        --     end
        -- end)
    end

    XFubenResourceManager.Init()
    return XFubenResourceManager
end

XRpc.NotifyResourceStageSingleData = function(data)
    XDataCenter.FubenResourceManager.FubenLeftCountUpdate(data)
end

XRpc.NotifyResourceStageRewardIds = function(data)
    XDataCenter.FubenResourceManager.FubenRewardUpdate(data)
end