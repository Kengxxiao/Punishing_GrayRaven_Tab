XFavorabilityManagerCreator = function()
    local XFavorabilityManager = {}
    local ClientConfig = CS.XGame.ClientConfig

    local CharacterFavorabilityDatas = {}

    local UnlockRewardFunc = {}

    -- [战斗参数达到target, 后端还不能正确计算出战斗参数，暂时返回false]
    UnlockRewardFunc[XFavorabilityConfigs.RewardUnlockType.FightAbility] = function(characterId, target)
        local characterData = XDataCenter.CharacterManager.GetCharacter(characterId)
        local curCharacterAbility = characterData.Ability or 0
        return false
        -- return math.ceil(curCharacterAbility) >= target
    end
    -- [信赖度达到target]
    UnlockRewardFunc[XFavorabilityConfigs.RewardUnlockType.TrustLv] = function(characterId, target)
        local characterData = XDataCenter.CharacterManager.GetCharacter(characterId)
        local trustLv = characterData.TrustLv or 1
        return trustLv >= target
    end
    -- [角色等级达到target]
    UnlockRewardFunc[XFavorabilityConfigs.RewardUnlockType.CharacterLv] = function(characterId, target)
        local characterData = XDataCenter.CharacterManager.GetCharacter(characterId)
        local characterLevel = characterData.Level or 1
        return characterLevel >= target
    end
    -- [进化至target]
    UnlockRewardFunc[XFavorabilityConfigs.RewardUnlockType.Quality] = function(characterId, target)
        local characterData = XDataCenter.CharacterManager.GetCharacter(characterId)
        local characterQuality = characterData.Quality or 1
        return characterQuality >= target
    end

    local UnlockStrangeNewsFunc = {}
    UnlockStrangeNewsFunc[XFavorabilityConfigs.StrangeNewsUnlockType.TrustLv] = function(characterId, target)
        local characterData = XDataCenter.CharacterManager.GetCharacter(characterId)
        local trustLv = characterData.TrustLv or 1
        return trustLv >= target
    end

    -- [宿舍事件:等宿舍完工补上]
    UnlockStrangeNewsFunc[XFavorabilityConfigs.StrangeNewsUnlockType.DormEvent] = function(characterId, unlockParam)
        return false
    end

    function XFavorabilityManager.InitEventListener()
        XEventManager.AddEventListener(XEventId.EVENT_CHARACTER_FIRST_GET, function(characterId)
            XDataCenter.FavorabilityManager.PlayCvByType(characterId, XFavorabilityConfigs.SoundEventType.FirstTimeObtain)
        end)

        XEventManager.AddEventListener(XEventId.EVENT_CHARACTER_LEVEL_UP, function(characterId)
            XDataCenter.FavorabilityManager.PlayCvByType(characterId, XFavorabilityConfigs.SoundEventType.LevelUp)
        end)

        XEventManager.AddEventListener(XEventId.EVENT_CHARACTER_QUALITY_PROMOTE, function(characterId)
            XDataCenter.FavorabilityManager.PlayCvByType(characterId, XFavorabilityConfigs.SoundEventType.Evolve)
        end)

        XEventManager.AddEventListener(XEventId.EVENT_CHARACTER_GRADE, function(characterId)
            XDataCenter.FavorabilityManager.PlayCvByType(characterId, XFavorabilityConfigs.SoundEventType.GradeUp)
        end)

        XEventManager.AddEventListener(XEventId.EVENT_CHARACTER_SKILL_UP, function(characterId)
            XDataCenter.FavorabilityManager.PlayCvByType(characterId, XFavorabilityConfigs.SoundEventType.SkillUp)
        end)

        XEventManager.AddEventListener(XEventId.EVENT_EQUIP_PUTON_WEAPON_NOTYFY, function(characterId)
            XDataCenter.FavorabilityManager.PlayCvByType(characterId, XFavorabilityConfigs.SoundEventType.WearWeapon)
        end)

        XEventManager.AddEventListener(XEventId.EVENT_TEAM_MEMBER_CHANGE, function(curTeamId, characterId, isCaptain)
            if characterId == 0 then return end
            local soundEventType = isCaptain and XFavorabilityConfigs.SoundEventType.CaptainJoinTeam or XFavorabilityConfigs.SoundEventType.MemberJoinTeam
            XDataCenter.FavorabilityManager.PlayCvByType(characterId, soundEventType)
        end)
    end

    function XFavorabilityManager.GetFavorabilityColorWorld(trustLv, name)
        return XFavorabilityConfigs.GetWordsWithColor(trustLv, name)
    end

    -- [获得好感度面板信息]
    function XFavorabilityManager.GetNameWithTitleById(characterId)
        local currCharacterName = XCharacterConfigs.GetCharacterName(characterId)
        local currCharacterTitle = XCharacterConfigs.GetCharacterTradeName(characterId)
        return XFavorabilityConfigs.GetCharacterNameWithTitle(currCharacterName, currCharacterTitle)
    end


    function XFavorabilityManager.GetCurrCharacterFavorabilityLevel(characterId)
        if characterId == nil then
            return 1
        end

        local currCharacterData = XDataCenter.CharacterManager.GetCharacter(characterId)
        if currCharacterData == nil then
            return 1
        end
        return currCharacterData.TrustLv or 1
    end

    function XFavorabilityManager.GetCurrCharacterExp(characterId)
        if characterId == nil then
            return 0
        end

        local currCharacterData = XDataCenter.CharacterManager.GetCharacter(characterId)

        if currCharacterData == nil then
            return 0
        end
        return currCharacterData.TrustExp or 0
    end

    function XFavorabilityManager.GetCharacterTrustExpById(characterId)
        local currCharacterData = XDataCenter.CharacterManager.GetCharacter(characterId)

        if currCharacterData == nil then
            return 0
        end
        return currCharacterData.TrustExp or 0
    end

    --获取好感度最高的角色Id
    function XFavorabilityManager.GetHighestTrustExpCharacter()
        local characters = XDataCenter.CharacterManager.GetOwnCharacter()
        local char = nil
        local highestExp = -1
        for _, v in pairs(characters) do
          --  local exp = XFavorabilityManager.GetCharacterTrustExpById(v.Id)
            local level = XFavorabilityManager.GetCurrCharacterFavorabilityLevel(v.Id)
          --  local num = exp + level * 100000 --权重

            if char and level == highestExp then
                if char.Level == v.Level then

                    if char.CreateTime == v.CreateTime then
                        if char.Id > v.Id then
                            highestExp = level
                            char = v
                        end
                    elseif char.CreateTime > v.CreateTime then
                        highestExp = level
                        char = v
                    end

                elseif char.Level < v.Level then
                    highestExp = level
                    char = v
                end

            elseif level > highestExp then
                char = v
                highestExp = level
            end
        end

        return char.Id
    end
    -- [获取好感度等级经验表数据]
    function XFavorabilityManager.GetFavorabilityTableData(characterId)
        local curTrustExp = XFavorabilityConfigs.GetTrustExpById(characterId)
        if curTrustExp == nil then
            return
        end
        local currLevel = XFavorabilityManager.GetCurrCharacterFavorabilityLevel(characterId)
        return curTrustExp[currLevel]
    end

    -- [资料是否已经解锁]
    function XFavorabilityManager.IsInformationUnlock(characterId, infoId)
        local favorabilityDatas = XFavorabilityManager.GetCharacterFavorabilityDatasById(characterId)
        if favorabilityDatas == nil or favorabilityDatas.UnlockInformation == nil then return false end
        return favorabilityDatas.UnlockInformation[infoId]
    end

    -- [资料是否可以解锁]
    function XFavorabilityManager.CanInformationUnlock(characterId, infoId)
        local characterData = XDataCenter.CharacterManager.GetCharacter(characterId)
        if characterData == nil then return false end
        local trustLv = characterData.TrustLv or 1
        local characterUnlockLvs = XFavorabilityConfigs.GetCharacterInformationUnlockLvById(characterId)
        if characterUnlockLvs and characterUnlockLvs[infoId] then
            return trustLv >= characterUnlockLvs[infoId]
        end
        return false
    end

    -- [异闻是否解锁]
    function XFavorabilityManager.IsRumorUnlock(characterId, rumorId)
        local favorabilityDatas = XFavorabilityManager.GetCharacterFavorabilityDatasById(characterId)
        if favorabilityDatas == nil or favorabilityDatas.UnlockStrangeNews == nil then return false end
        return favorabilityDatas.UnlockStrangeNews[rumorId]
    end
    -- [异闻是否可以解锁]
    function XFavorabilityManager.CanRumorsUnlock(characterId, unlockType, unlockParam)
        if UnlockStrangeNewsFunc[unlockType] then
            return UnlockStrangeNewsFunc[unlockType](characterId, unlockParam)
        end
        return false
    end

    -- [语音是否解锁]
    function XFavorabilityManager.IsVoiceUnlock(characterId, Id)
        local favorabilityDatas = XFavorabilityManager.GetCharacterFavorabilityDatasById(characterId)
        if favorabilityDatas == nil or favorabilityDatas.UnlockVoice == nil then return false end
        return favorabilityDatas.UnlockVoice[Id]
    end

    -- [语音是否可以解锁]
    function XFavorabilityManager.CanVoiceUnlock(characterId, Id)
        local characterData = XDataCenter.CharacterManager.GetCharacter(characterId)
        if characterData == nil then return false end
        local trustLv = characterData.TrustLv or 1
        local voiceUnlockLvs = XFavorabilityConfigs.GetCharacterVoiceUnlockLvsById(characterId)
        if voiceUnlockLvs and voiceUnlockLvs[Id] then
            return trustLv >= voiceUnlockLvs[Id]
        end
        return false
    end
    -- 【档案end】
    -- 【剧情begin】
    -- [剧情是否已经解锁]
    function XFavorabilityManager.IsStoryUnlock(characterId, Id)
        local favorabilityDatas = XFavorabilityManager.GetCharacterFavorabilityDatasById(characterId)
        if favorabilityDatas == nil or favorabilityDatas.UnlockStory == nil then return false end
        return favorabilityDatas.UnlockStory[Id]
    end

    -- [剧情剧情是否可以解锁]
    function XFavorabilityManager.CanStoryUnlock(characterId, Id)
        local characterData = XDataCenter.CharacterManager.GetCharacter(characterId)
        if characterData == nil then return false end
        local storys = XFavorabilityConfigs.GetCharacterStoryUnlockLvsById(characterId)
        if storys == nil then return false end
        local storyUnlockLv = storys[Id] or 1
        local trustLv = characterData.TrustLv or 1
        return trustLv >= storyUnlockLv
    end

    -- 【剧情end】
    -- 【礼物begin】
    function XFavorabilityManager.SortTrustItems(itemA, itemB)
        local itemAPriority = XDataCenter.ItemManager.GetItemPriority(itemA.Id) or 0
        local itemBPriority = XDataCenter.ItemManager.GetItemPriority(itemB.Id) or 0

        if itemA.IsFavourWeight == itemB.IsFavourWeight then
            if itemA.TrustItemQuality == itemB.TrustItemQuality then
                if itemAPriority == itemBPriority then
                    return itemA.Id > itemB.Id
                end
                return itemAPriority > itemBPriority
            end
            return itemA.TrustItemQuality > itemB.TrustItemQuality
        end
        return itemA.IsFavourWeight > itemB.IsFavourWeight
    end

    -- 可领取>未解锁>已领取>id排序，权重1,2,3
    local sortTrustItemReward = function(rewardA, rewardB)
        local aWeight = rewardA.Weight or 3
        local bWeight = rewardB.Weight or 3
        if aWeight == bWeight then
            return rewardA.Id < rewardB.Id
        else
            return aWeight < bWeight
        end
    end

    -- [获取奖励道具的列表：排序]
    function XFavorabilityManager.GetTrustItemRewardById(characterId)
        local currRewardDatas = XFavorabilityConfigs.GetCharacterGiftRewardById(characterId)
        for k, v in pairs(currRewardDatas) do
            if XFavorabilityManager.IsRewardCollected(characterId, v.Id) then
                v.Weight = 3
            else
                if XFavorabilityManager.CanRewardUnlock(characterId, v.UnlockType, v.UnlockPara) then--可领取
                    v.Weight = 1
                else
                    v.Weight = 2
                end
            end
        end
        table.sort(currRewardDatas, sortTrustItemReward)
        return currRewardDatas
    end

    -- [角色奖励是否已经领取]
    function XFavorabilityManager.IsRewardCollected(characterId, rewardId)
        local favorabilityDatas = XFavorabilityManager.GetCharacterFavorabilityDatasById(characterId)
        if favorabilityDatas == nil or favorabilityDatas.UnlockReward == nil then return false end
        return favorabilityDatas.UnlockReward[rewardId]
    end

    -- [奖励是否可以解锁]
    function XFavorabilityManager.CanRewardUnlock(characterId, unlockType, unlockParam)
        if UnlockRewardFunc[unlockType] then
            return UnlockRewardFunc[unlockType](characterId, unlockParam)
        end
        return false
    end
    -- 【礼物begin】
    -- 【Rpc相关】
    -- [领取角色奖励]
    function XFavorabilityManager.OnCollectCharacterReward(templateId, rewardId, cb)
        XNetwork.Call("CharacterUnlockRewardRequest", { TemplateId = templateId, Id = rewardId }, function(res)
            cb = cb or function() end
            if res.Code == XCode.Success then
                local characterFavorabilityDatas = XFavorabilityManager.GetCharacterFavorabilityDatasById(templateId)
                if characterFavorabilityDatas and characterFavorabilityDatas.UnlockReward then
                    characterFavorabilityDatas.UnlockReward[rewardId] = true
                end

                cb()
                XEventManager.DispatchEvent(XEventId.EVENT_FAVORABILITY_COLLECTGIFT)
                local rewards = XFavorabilityConfigs.GetLikeRewardById(rewardId)
                if rewards then
                    local list = {}
                    table.insert(list, XRewardManager.CreateRewardGoodsByTemplate({ TemplateId = rewards.ItemId, Count = rewards.ItemCount }))
                    XUiManager.OpenUiObtain(list)
                end

            else
                XUiManager.TipCode(res.Code)
            end
        end)
    end

    -- [解锁剧情]解锁成功，返回0，重新登陆数据会绑定再character上，不重新登陆也会有最新的数据绑到character
    function XFavorabilityManager.OnUnlockCharacterStory(templateId, storyId, cb, name)
        XNetwork.Call("CharacterUnlockStoryRequest", { TemplateId = templateId, Id = storyId }, function(res)
            cb = cb or function() end
            if res.Code == XCode.Success then
                local characterFavorabilityDatas = XFavorabilityManager.GetCharacterFavorabilityDatasById(templateId)
                if characterFavorabilityDatas and characterFavorabilityDatas.UnlockStory then
                    characterFavorabilityDatas.UnlockStory[storyId] = true
                end

                cb(res)
                XUiManager.TipMsg(CS.XTextManager.GetText("FavorabilityUnlockPlotSucc", name))
                XEventManager.DispatchEvent(XEventId.EVENT_FAVORABILITY_PLOTUNLOCK)

            else
                XUiManager.TipCode(res.Code)
            end
        end)
    end
    -- [解锁数据]
    function XFavorabilityManager.OnUnlockCharacterInfomatin(templateId, infoId, cb, title)
        XNetwork.Call("CharacterUnlockInformationRequest", { TemplateId = templateId, Id = infoId }, function(res)
            cb = cb or function() end
            if res.Code == XCode.Success then
                local characterFavorabilityDatas = XFavorabilityManager.GetCharacterFavorabilityDatasById(templateId)
                if characterFavorabilityDatas and characterFavorabilityDatas.UnlockInformation then
                    characterFavorabilityDatas.UnlockInformation[infoId] = true
                end

                cb(res)
                XUiManager.TipMsg(CS.XTextManager.GetText("FavorabilityUnlockInfoSucc", title))
                XEventManager.DispatchEvent(XEventId.EVENT_FAVORABILITY_INFOUNLOCK)

            else
                XUiManager.TipCode(res.Code)
            end
        end)

    end

    -- [解锁异闻]
    function XFavorabilityManager.OnUnlockCharacterRumor(templateId, rumorId, cb, title)
        XNetwork.Call("CharacterUnlockStrangeNewsRequest", { TemplateId = templateId, Id = rumorId }, function(res)
            cb = cb or function() end
            if res.Code == XCode.Success then
                local characterFavorabilityDatas = XFavorabilityManager.GetCharacterFavorabilityDatasById(templateId)
                if characterFavorabilityDatas and characterFavorabilityDatas.UnlockStrangeNews then
                    characterFavorabilityDatas.UnlockStrangeNews[rumorId] = true
                end

                cb(res)
                XUiManager.TipMsg(CS.XTextManager.GetText("FavorabilityUnlockStrangeNewsSucc", title))
                XEventManager.DispatchEvent(XEventId.EVENT_FAVORABILITY_RUMERUNLOCK)

            else
                XUiManager.TipCode(res.Code)
            end
        end)
    end

    -- [解锁语音]
    function XFavorabilityManager.OnUnlockCharacterVoice(templateId, cvId, cb, name)
        XNetwork.Call("CharacterUnlockVoiceRequest", { TemplateId = templateId, Id = cvId }, function(res)
            cb = cb or function() end
            if res.Code == XCode.Success then
                local characterFavorabilityDatas = XFavorabilityManager.GetCharacterFavorabilityDatasById(templateId)
                if characterFavorabilityDatas and characterFavorabilityDatas.UnlockVoice then
                    characterFavorabilityDatas.UnlockVoice[cvId] = true
                end

                cb(res)
                XUiManager.TipMsg(CS.XTextManager.GetText("FavorabilityUnlockAudioSucc", name))
                XEventManager.DispatchEvent(XEventId.EVENT_FAVORABILITY_AUDIOUNLOCK)
            else
                XUiManager.TipCode(res.Code)
            end
        end)
    end

    -- [发送礼物]
    function XFavorabilityManager.OnSendCharacterGift(args, cb)
        XNetwork.Call("CharacterSendGiftRequest", { TemplateId = args.CharacterId, ItemId = args.ItemId, ItemNum = args.ItemNum }, function(res)
            cb = cb or function() end
            if res.Code == XCode.Success then
                cb(res)
                XUiManager.TipMsg(CS.XTextManager.GetText("FavorabilityAddExp", tostring(args.CharacterName), args.ItemNum * args.Exp))
                XEventManager.DispatchEvent(XEventId.EVENT_FAVORABILITY_GIFT, args.CharacterId)
            else
                XUiManager.TipCode(res.Code)
            end
        end)
    end

    -- [通知更新角色信赖度等级和经验]
    function XFavorabilityManager.OnCharacterTrustInfoUpdate(response)
        local characterData = XDataCenter.CharacterManager.GetCharacter(response.TemplateId)
        if characterData then
            -- 等级变化
            if characterData.TrustLv ~= response.TrustLv then
                CsXGameEventManager.Instance:Notify(XEventId.EVENT_FAVORABILITY_LEVELCHANGED, response.TrustLv)
            end
            characterData.TrustLv = response.TrustLv
            characterData.TrustExp = response.TrustExp
            CsXGameEventManager.Instance:Notify(XEventId.EVENT_FAVORABILITY_MAIN_REFRESH)
        end
    end

    -- [看板交互]
    function XFavorabilityManager.BoardMutualRequest()
        XNetwork.Send("BoardMutualRequest", {})
    end

    function XFavorabilityManager.IsMaxFavorabilityLevel(characterId)
        local trustLv = XFavorabilityManager.GetCurrCharacterFavorabilityLevel(characterId)
        local maxLv = XFavorabilityConfigs.GetMaxFavorabilityLevel(characterId)
        return trustLv == maxLv
    end

    -- 【红点相关】
    -- [某个角色是否有资料可以解锁]
    function XFavorabilityManager.HasDataToBeUnlock(characterId)
        local characterData = XDataCenter.CharacterManager.GetCharacter(characterId)
        if characterData == nil then return false end
        local characterTrustLv = characterData.TrustLv or 1

        local informationDatas = XFavorabilityConfigs.GetCharacterInformationById(characterId)
        if informationDatas == nil then return false end

        local favorabilityDatas = XFavorabilityManager.GetCharacterFavorabilityDatasById(characterId)
        if favorabilityDatas == nil or favorabilityDatas.UnlockInformation == nil then return false end

        for _, info in pairs(informationDatas) do
            local isUnlock = favorabilityDatas.UnlockInformation[info.Id]
            local canUnlock = characterTrustLv >= info.UnlockLv
            if (not isUnlock) and canUnlock then
                return true
            end
        end
        return false
    end

    -- [某个角色是否有异闻可以解锁]
    function XFavorabilityManager.HasRumorsToBeUnlock(characterId)
        local characterData = XDataCenter.CharacterManager.GetCharacter(characterId)

        if characterData == nil then return false end
        local rumors = XFavorabilityConfigs.GetCharacterRumorsById(characterId)

        for _, news in pairs(rumors) do
            local isNewsUnlock = XFavorabilityManager.IsRumorUnlock(characterId, news.Id)
            local canNewsUnlock = XFavorabilityManager.CanRumorsUnlock(characterId, news.UnlockType, news.UnlockPara)
            if (not isNewsUnlock) and canNewsUnlock then
                return true
            end
        end
        return false
    end
    -- [某个角色是否有语音可以解锁]
    function XFavorabilityManager.HasAudioToBeUnlock(characterId)
        local characterData = XDataCenter.CharacterManager.GetCharacter(characterId)
        if characterData == nil then return false end
        local trustLv = characterData.TrustLv or 1

        local voices = XFavorabilityConfigs.GetCharacterVoiceById(characterId)
        if voices == nil then return false end

        local favorabilityDatas = XFavorabilityManager.GetCharacterFavorabilityDatasById(characterId)
        if favorabilityDatas == nil or favorabilityDatas.UnlockVoice == nil then return false end

        for _, voice in pairs(voices) do
            local isVoiceUnlock = favorabilityDatas.UnlockVoice[voice.Id]
            local canVoiceUnlock = trustLv >= voice.UnlockLv
            if (not isVoiceUnlock) and canVoiceUnlock then
                return true
            end
        end
        return false
    end
    -- [某个/当前角色是否有剧情可以解锁]
    function XFavorabilityManager.HasStroyToBeUnlock(characterId)
        local storys = XFavorabilityConfigs.GetCharacterStoryById(characterId)
        if storys == nil then return false end

        local characterData = XDataCenter.CharacterManager.GetCharacter(characterId)
        if characterData == nil then return false end
        local characterTrustLv = characterData.TrustLv or 1

        local favorabilityDatas = XFavorabilityManager.GetCharacterFavorabilityDatasById(characterId)
        if favorabilityDatas == nil or favorabilityDatas.UnlockStory == nil then return false end

        for storyId, story in pairs(storys) do
            local isStoryUnlock = favorabilityDatas.UnlockStory[story.Id]
            local canStoryUnlock = characterTrustLv >= story.UnlockLv
            if (not isStoryUnlock) and canStoryUnlock then
                return true
            end
        end
        return false
    end

    -- [剧情是否可以解锁]
    function XFavorabilityManager.CanStoryUnlock(characterId, Id)
        local characterData = XDataCenter.CharacterManager.GetCharacter(characterId)
        if characterData == nil then return false end
        local characterLv = characterData.TrustLv or 1

        local storys = XFavorabilityConfigs.GetCharacterStoryUnlockLvsById(characterId)
        if storys == nil then return false end
        local storyLv = storys[Id] or 1

        return characterLv >= storyLv
    end

    -- [播放特殊事件音效]
    local PlayingCvId = nil
    local PlayingCvInfo = nil
    function XFavorabilityManager.PlayCvByType(characterId, soundType)
        if not characterId or characterId == 0 then return end

        local voices = XFavorabilityConfigs.GetCharacterVoiceById(characterId)
        for _, voice in pairs(voices) do
            if voice.SoundType == soundType then
                local cvId = voice.CvId

                if PlayingCvId and PlayingCvId == cvId then return end
                PlayingCvId = cvId

                PlayingCvInfo = CS.XAudioManager.PlayCv(voice.CvId, function()
                    PlayingCvId = nil
                end)

                return
            end
        end
    end

    function XFavorabilityManager.StopCv()
        if not PlayingCvInfo or not PlayingCvInfo.Playing then return end
        PlayingCvInfo:Stop()
        PlayingCvId = nil
        PlayingCvInfo = nil
    end

    function XFavorabilityManager.OnCharacterFavorabilityDatasAsync(response)
        if not response then return end
        local extraData = response.CharacterExtraDatas
        for k, v in pairs(extraData or {}) do
            CharacterFavorabilityDatas[v.Id] = {}
            CharacterFavorabilityDatas[v.Id].Id = v.Id

            CharacterFavorabilityDatas[v.Id].UnlockInformation = {}
            for _, infoId in pairs(v.UnlockInformation or {}) do
                CharacterFavorabilityDatas[v.Id].UnlockInformation[infoId] = true
            end

            CharacterFavorabilityDatas[v.Id].UnlockStory = {}
            for _, storyId in pairs(v.UnlockStory or {}) do
                CharacterFavorabilityDatas[v.Id].UnlockStory[storyId] = true
            end

            CharacterFavorabilityDatas[v.Id].UnlockReward = {}
            for _, rewardId in pairs(v.UnlockReward or {}) do
                CharacterFavorabilityDatas[v.Id].UnlockReward[rewardId] = true
            end

            CharacterFavorabilityDatas[v.Id].UnlockVoice = {}
            for _, voiceId in pairs(v.UnlockVoice or {}) do
                CharacterFavorabilityDatas[v.Id].UnlockVoice[voiceId] = true
            end

            CharacterFavorabilityDatas[v.Id].UnlockStrangeNews = {}
            for _, strangeNewsId in pairs(v.UnlockStrangeNews or {}) do
                CharacterFavorabilityDatas[v.Id].UnlockStrangeNews[strangeNewsId] = true
            end
        end
    end

    function XFavorabilityManager.GetCharacterFavorabilityDatasById(characterId)
        return CharacterFavorabilityDatas[characterId]
    end

    function XFavorabilityManager.GetFavorabilitySkipIds()
        local skip_size = ClientConfig:GetInt("FavorabilitySkipSize")
        local skipIds = {}
        for i = 1, skip_size do
            table.insert(skipIds, ClientConfig:GetInt(string.format("FavorabilitySkip%d", i)))
        end

        return skipIds
    end

    XFavorabilityManager.InitEventListener()

    return XFavorabilityManager
end
-- [更新好感度等级，经验]
XRpc.NotifyCharacterTrustInfo = function(response)
    XDataCenter.FavorabilityManager.OnCharacterTrustInfoUpdate(response)
end

XRpc.NotifyCharacterExtraData = function(response)
    XDataCenter.FavorabilityManager.OnCharacterFavorabilityDatasAsync(response)
end