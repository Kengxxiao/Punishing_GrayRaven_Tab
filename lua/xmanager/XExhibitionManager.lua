XExhibitionManagerCreator = function()
    local XExhibitionManager = {}
    local METHOD_NAME = {
        GatherRewardListRequest = "GatherRewardListRequest",
        GetGatherReward = "GatherRewardRequest",
    }

    local TotalCharacterNum = 0
    local CharacterTaskFinished = {}
    --临时存放要查看的人的数据
    local CharacterInfo = {}
    local SelfGatherRewards = {}

    function XExhibitionManager.HandleExhibitionInfo(data)
        for _, v in pairs(data.GatherRewards) do
            CharacterTaskFinished[v] = true
        end
        SelfGatherRewards = data.GatherRewards
        XDataCenter.ExhibitionManager.SetCharacterInfo(SelfGatherRewards)

        XEventManager.DispatchEvent(XEventId.EVENT_CHARACTER_EXHIBITION_REFRESH)
    end
    --获得新的角色
    function XExhibitionManager.GetNewCharacter(Id)
        if not CharacterTaskFinished[Id] then
            CharacterTaskFinished[Id] = true
            table.insert(SelfGatherRewards, Id)
            XDataCenter.ExhibitionManager.SetCharacterInfo(SelfGatherRewards)
        end
    end
    --存放希望查看的玩家所持有图鉴数据
    function XExhibitionManager.SetCharacterInfo(info)
        CharacterInfo = info
    end
    --存放自己的所持有图鉴数据
    function XExhibitionManager.GetSelfGatherRewards()
        return SelfGatherRewards
    end

    function XExhibitionManager.CheckTempCharacterTaskFinish(id)
        for k, v in pairs(CharacterInfo) do
            if v == id then
                return true
            end
        end
        return false
    end

    --查看自己的isSelf = true,isSelf = false查看别人的
    function XExhibitionManager.GetCharacterGrowUpLevel(characterId)
        local curLevel = XCharacterConfigs.GrowUpLevel.New
        local characterTasks = XExhibitionConfigs.GetCharacterGrowUpTasks(characterId)
        for _, task in pairs(characterTasks) do
            if task.LevelId > curLevel and XExhibitionManager.CheckTempCharacterTaskFinish(task.Id) then
                curLevel = task.LevelId
            end
        end

        return curLevel
    end

    function XExhibitionManager.IsAchieveMaxLiberation(characterId)
        return XExhibitionManager.IsAchieveLiberation(characterId, XCharacterConfigs.GrowUpLevel.End)
    end
    
    function XExhibitionManager.IsAchieveLiberation(characterId, level)
        return level and XExhibitionManager.GetCharacterGrowUpLevel(characterId) == level
    end

    function XExhibitionManager.IsMaxLiberationLevel(level)
        return level == XCharacterConfigs.GrowUpLevel.End
    end

    --查看别人是否拥有某个character
    function XExhibitionManager.CheckIsOwnCharacter(characterId)
        local growUpTasksConfig = XExhibitionConfigs.GetGrowUpTasksConfig()
        for k, v in pairs(CharacterInfo) do
            if growUpTasksConfig[v].CharacterId == characterId then
                return true
            end
        end
        return false
    end

    function XExhibitionManager.CheckNewCharacterReward(characterId)
        local isNew = false

        if characterId then
            return XExhibitionManager.CheckNewRewardByCharacterId(characterId)
        end

        local tasksConfig = XExhibitionConfigs.GetCharacterGrowUpTasksConfig()
        if XDataCenter.ExhibitionManager.CheckRedPointIsCanSee() then
            for characterId, taskConfig in pairs(tasksConfig) do
                if XDataCenter.CharacterManager.IsOwnCharacter(characterId) then
                    for taskId, config in pairs(taskConfig) do
                        local canGetReward = true
                        for index = 1, #config.ConditionIds do
                            local ret, _ = XConditionManager.CheckCondition(config.ConditionIds[index], characterId)
                            if not ret then
                                canGetReward = false
                            end
                        end
                        if canGetReward and not XExhibitionManager.CheckGrowUpTaskFinish(taskId) then
                            isNew = true
                        end
                    end
                end
            end
        end
        return isNew
    end

    function XExhibitionManager.CheckRedPointIsCanSee()
        return XFunctionManager.JudgeCanOpen(XFunctionManager.FunctionName.CharacterExhibition)
    end

    function XExhibitionManager.CheckNewRewardByCharacterId(characterId)
        if not XDataCenter.CharacterManager.IsOwnCharacter(characterId) then
            return false
        end

        local taskConfig = XExhibitionConfigs.GetCharacterGrowUpTasks(characterId)
        for taskId, config in pairs(taskConfig) do
            local canGetReward = true
            for index = 1, #config.ConditionIds do
                local ret, _ = XConditionManager.CheckCondition(config.ConditionIds[index], characterId)
                if not ret then
                    canGetReward = false
                end
            end
            if canGetReward and not XExhibitionManager.CheckGrowUpTaskFinish(taskId) then
                return true
            end
        end
    end

    function XExhibitionManager.GetCollectionTotalNum()
        if TotalCharacterNum <= 0 then
            TotalCharacterNum = 0
            local characterExhibitionInfo = XExhibitionConfigs.GetExhibitionConfig()
            for _, v in pairs(characterExhibitionInfo) do
                if v.CharacterId ~= 0 then
                    TotalCharacterNum = TotalCharacterNum + 1
                end
            end
        end
        return TotalCharacterNum
    end

    function XExhibitionManager.GetCollectionRate()
        local totalTaskNum = XExhibitionConfigs.GetGrowUpLevelMax() * XExhibitionManager.GetTotalCharacterNum()
        local curTaskNum = 0
        local tempData = {}
        local tempConfigData = XExhibitionConfigs.GetGrowUpTasksConfig()
        local tempExhibitionConfigs = XExhibitionConfigs.GetExhibitionLevelPoints()
        for k, v in pairs(CharacterInfo) do
            if tempData[tempConfigData[v].CharacterId] then
                if tempExhibitionConfigs[tempConfigData[v].LevelId] then
                    tempData[tempConfigData[v].CharacterId] = tempData[tempConfigData[v].CharacterId] + tempExhibitionConfigs[tempConfigData[v].LevelId]
                else
                    tempData[tempConfigData[v].CharacterId] = tempData[tempConfigData[v].CharacterId] + 1 
                end
            else
                if tempExhibitionConfigs[tempConfigData[v].LevelId] then
                    tempData[tempConfigData[v].CharacterId] = tempExhibitionConfigs[tempConfigData[v].LevelId]
                else
                    tempData[tempConfigData[v].CharacterId] = 1
                end
            end
        end
        for k, v in pairs(tempData) do
            curTaskNum = curTaskNum + v
        end
        return curTaskNum / totalTaskNum
    end

    function XExhibitionManager.GetTaskFinishNum()
        local taskFinishNum = {}
        local growUpTasksConfig = XExhibitionConfigs.GetGrowUpTasksConfig()
        for index = XCharacterConfigs.GrowUpLevel.End, 1, -1 do
            taskFinishNum[index] = 0
            for k, v in pairs(CharacterInfo) do
                if growUpTasksConfig[v].LevelId == index then
                    taskFinishNum[index] = taskFinishNum[index] + 1
                end
            end
        end
        return taskFinishNum
    end

    function XExhibitionManager.GetTotalCharacterNum()
        local totalCharacterNum = 0
        local characterExhibitionInfo = XExhibitionConfigs.GetExhibitionConfig()
        for _, v in pairs(characterExhibitionInfo) do
            if v.CharacterId ~= 0 then
                totalCharacterNum = totalCharacterNum + 1
            end
        end
        return totalCharacterNum
    end

    function XExhibitionManager.CheckGrowUpTaskFinish(taskId)
        return CharacterTaskFinished[taskId] ~= nil
    end

    function XExhibitionManager.CheckCharacterGraduation(characterId)
        local count = 0
        local growUpTasksConfig = XExhibitionConfigs.GetGrowUpTasksConfig()
        for k, v in pairs(CharacterInfo) do
            if growUpTasksConfig[v].CharacterId == characterId then
                if growUpTasksConfig[v].LevelId > count then
                    count = growUpTasksConfig[v].LevelId
                end
            end
        end
        return count >= XCharacterConfigs.GrowUpLevel.End
    end
    --区分是否是查看自己的信息
    function XExhibitionManager.GetCharHeadPortrait(characterId)
        if characterId == nil or characterId == 0 then
            return XExhibitionConfigs.GetDefaultPortraitImagePath()
        elseif XExhibitionManager.CheckCharacterGraduation(characterId) then
            return XExhibitionConfigs.GetCharacterGraduationPortrait(characterId)
        else
            return XExhibitionConfigs.GetCharacterHeadPortrait(characterId)
        end
    end

    -- --服务端交互
    -- function XExhibitionManager.RefreshGatherReward(cb)
    --     XNetwork.Call(METHOD_NAME.GatherRewardListRequest, nil,
    --     function(response)
    --         if response.Code ~= XCode.Success then
    --             XUiManager.TipCode(response.Code)
    --             return
    --         end
    --         for _, v in pairs(response.GatherRewards) do
    --             CharacterTaskFinished[v] = true
    --         end
    --         if cb then
    --             cb()
    --         end
    --     end)
    -- end
    function XExhibitionManager.GetGatherReward(characterId, curSelectLevel, cb)
        local taskConfig = XExhibitionConfigs.GetCharacterGrowUpTask(characterId, curSelectLevel)
        local id = taskConfig.Id
        XNetwork.Call(METHOD_NAME.GetGatherReward, { Id = id },
        function(response)
            if response.Code ~= XCode.Success then
                XUiManager.TipCode(response.Code)
                return
            end
            
            XExhibitionManager.GetNewCharacter(id)
            XEventManager.DispatchEvent(XEventId.EVENT_CHARACTER_EXHIBITION_REFRESH)
            if cb then cb() end

            XUiManager.OpenUiObtain(response.RewardGoods, nil, function()
                local levelId = taskConfig.LevelId
                local levelName = XExhibitionConfigs.GetExhibitionLevelNameByLevel(levelId)
                XLuaUiManager.Open("UiEquipLevelUpTips", CS.XTextManager.GetText("CharacterLiberateSuccess", levelName))
            end)

            --终阶解放自动解放技能
            local growUpLevel = XExhibitionManager.GetCharacterGrowUpLevel(characterId)
            if growUpLevel == XCharacterConfigs.GrowUpLevel.End then
                XDataCenter.CharacterManager.UnlockMaxLiberationSkill(characterId)
            end
        end)
    end

    return XExhibitionManager
end

XRpc.NotifyGatherRewardList = function(data)
    XDataCenter.ExhibitionManager.HandleExhibitionInfo(data)
end

XRpc.NotifyGatherReward = function(data)
    XDataCenter.ExhibitionManager.GetNewCharacter(data.Id)
end