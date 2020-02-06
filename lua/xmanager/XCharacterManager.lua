XCharacterManagerCreator = function()

    local type = type
    local pairs = pairs

    local table = table
    local tableSort = table.sort
    local tableInsert = table.insert
    local mathMin = math.min
    local stringFormat = string.format

    local XCharacterManager = {}

    -- service config begin --
    local METHOD_NAME = {
        LevelUp = "CharacterLevelUpRequest",
        ActivateStar = "CharacterActivateStarRequest",
        PromoteQuality = "CharacterPromoteQualityRequest",
        PromoteGrade = "CharacterPromoteGradeRequest",
        ExchangeCharacter = "CharacterExchangeRequest",
        UnlockSubSkill = "CharacterUnlockSkillRequest",
        UpgradeSubSkill = "CharacterUpgradeSkillRequest",
    }
    -- service config end --
    local OwnCharacters = {}               -- 已拥有角色数据

    function XCharacterManager.NewCharacter(character)
        if character == nil or character.Id == nil then
            XLog.Error("XCharacterManager.NewCharacter error: params is error")
            return
        end

        return XCharacter.New(character)
    end

    function XCharacterManager.InitCharacters(characters)
        for k, character in pairs(characters) do
            OwnCharacters[character.Id] = XCharacterManager.NewCharacter(character)
        end
    end

    function XCharacterManager.GetCharacter(id)
        return OwnCharacters[id]
    end

    function XCharacterManager.IsOwnCharacter(characterId)
        return OwnCharacters[characterId] ~= nil
    end

    function XCharacterManager.IsIsomer(characterId)
        local isomer = XCharacterConfigs.GetCharacterIsomer(characterId)
        return isomer and isomer ~= 0
    end

    local DefaultSort = function(a, b)
        if a.Level ~= b.Level then
            return a.Level > b.Level
        end

        if a.Quality ~= b.Quality then
            return a.Quality > b.Quality
        end

        local priorityA = XCharacterConfigs.GetCharacterPriority(a.Id)
        local priorityB = XCharacterConfigs.GetCharacterPriority(b.Id)

        if priorityA ~= priorityB then
            return priorityA < priorityB
        end

        return a.Id > b.Id
    end

    function XCharacterManager.GetOwnCharacter()
        local characterList = {}
        for k, v in pairs(OwnCharacters) do
            table.insert(characterList, v)
        end
        return characterList
    end

    --==============================--
    --desc: 获取卡牌列表(获得)
    --@return 卡牌列表
    --==============================--
    function XCharacterManager.GetCharacterList()
        local characterList = {}
        local unOwnCharList = {}
        for k, v in pairs(XCharacterConfigs.GetCharacterTemplates()) do
            if OwnCharacters[k] then
                tableInsert(characterList, OwnCharacters[k])
            else
                tableInsert(unOwnCharList, v)
            end
        end

        tableSort(characterList, function(a, b)
            local isInteamA = XDataCenter.TeamManager.CheckInTeam(a.Id)
            local isInteamB = XDataCenter.TeamManager.CheckInTeam(b.Id)

            if isInteamA ~= isInteamB then
                return isInteamA
            end

            return DefaultSort(a, b)
        end)


        tableSort(unOwnCharList, function(a, b)
            return DefaultSort(a, b)
        end)

        -- 合并列表
        for _, char in pairs(unOwnCharList) do
            tableInsert(characterList, char)
        end

        return characterList
    end

    function XCharacterManager.GetOwnCharacterList()
        local characterList = {}
        for _, v in pairs(OwnCharacters) do
            tableInsert(characterList, v)
        end

        tableSort(characterList, function(a, b)
            return DefaultSort(a, b)
        end)

        return characterList
    end

    function XCharacterManager.GetCharacterCountByAbility(ability)
        local count = 0
        for _,v in pairs(OwnCharacters) do
            local curAbility = XCharacterManager.GetCharacterAbility(v)
            if curAbility and curAbility >= ability then
                count = count + 1            
            end
        end

        return count
    end


    --队伍预设列表排序特殊处理
    function XCharacterManager.GetSpecilOwnCharacterList()
        local characterList = {}
        for _, v in pairs(OwnCharacters) do
            tableInsert(characterList, v)
        end

        tableSort(characterList, function(a, b)
            return DefaultSort(a, b)
        end)

        local specilList = {}

        for k, v in pairs(characterList) do
            if k % 2 ~= 0 then
                tableInsert(specilList, v)
            end
        end

        for k, v in pairs(characterList) do
            if k % 2 == 0 then
                tableInsert(specilList, v)
            end
        end

        return specilList
    end

    function XCharacterManager.GetCharacterListInTeam(inTeamIdMap, inTeamFirst)
        local characterList = XCharacterManager.GetOwnCharacterList()

        local inTeamFlag = {}
        for _, v in pairs(inTeamIdMap) do
            if v > 0 then
                inTeamFlag[v] = 1
            end
        end

        tableSort(characterList, function(a, b)
            local isInteamA = XDataCenter.TeamManager.CheckInTeam(a.Id)
            local isInteamB = XDataCenter.TeamManager.CheckInTeam(b.Id)

            if isInteamA ~= isInteamB then
                return isInteamA
            end

            return DefaultSort(a, b)
        end)

        return characterList
    end

    function XCharacterManager.IsUseItemEnough(itemIds, itemCounts)
        if not itemIds then
            return true
        end

        if type(itemIds) == "number" then
            if type(itemCounts) == "table" then
                itemCounts = itemCounts[1]
            end

            return XDataCenter.ItemManager.CheckItemCountById(itemIds, itemCounts)
        end

        itemCounts = itemCounts or {}
        for i = 1, #itemIds do
            local key = itemIds[i]
            local count = itemCounts[i] or 0

            if not XDataCenter.ItemManager.CheckItemCountById(key, count) then
                return false
            end
        end

        return true
    end

    function XCharacterManager.AddCharacter(charData)
        local character = XCharacterManager.NewCharacter(charData)
        OwnCharacters[character.Id] = character
        XEventManager.DispatchEvent(XEventId.EVENT_CHARACTER_ADD_SYNC, character)
        return character
    end

    local function GetAttribGroupIdList(character)
        local npcTemplate = XCharacterConfigs.GetNpcTemplate(character.NpcId)
        if not npcTemplate then
            return
        end

        return XDataCenter.BaseEquipManager.GetAttribGroupIdListByType(npcTemplate.Type)
    end

    function XCharacterManager.GetFightNpcData(characterId)
        local character = characterId

        if type(characterId) == "number" then
            character = XCharacterManager.GetCharacter(characterId)
            if not character then
                return
            end
        end

        local equipDataList = XDataCenter.EquipManager.GetCharacterWearingEquips(character.Id)
        if not equipDataList then
            return
        end

        local groupIdList = GetAttribGroupIdList(character)
        if not groupIdList then
            return
        end

        return {
            Character = character,
            Equips = equipDataList,
            AttribGroupList = groupIdList
        }
    end

    function XCharacterManager.GetCharacterAttribs(character)
        local npcData = XCharacterManager.GetFightNpcData(character)
        if not npcData then
            return
        end

        return XAttribManager.GetNpcAttribs(npcData)
    end

    local function GetSkillAbility(skillList)
        local ability = 0
        for id, level in pairs(skillList) do
            ability = ability + XCharacterConfigs.GetSubSkillAbility(id, level)
        end
        return ability
    end

    local function GetResonanceSkillAbility(skillList)
        local ability = 0
        for id, level in pairs(skillList) do
            ability = ability + XCharacterConfigs.GetResonanceSkillAbility(id, level)
        end
        return ability
    end

    function XCharacterManager.GetCharacterAbility(character)
        local npcData = XCharacterManager.GetFightNpcData(character)
        if not npcData then
            return
        end

        local baseAbility = XAttribManager.GetAttribAbility(character.Attribs)
        if not baseAbility then
            return
        end

        local skillLevel = XFightCharacterManager.GetCharSkillLevelMap(npcData)
        local skillAbility = GetSkillAbility(skillLevel)

        local resonanceSkillLevel = XFightCharacterManager.GetResonanceSkillLevelMap(npcData)
        local resonanceSkillAbility = GetResonanceSkillAbility(resonanceSkillLevel)

        local equipAbility = XDataCenter.EquipManager.GetEquipSkillAbility(character.Id)
        if not equipAbility then
            return
        end

        return baseAbility + skillAbility + resonanceSkillAbility + equipAbility
    end

    function XCharacterManager.GetNpcBaseAttrib(npcId)
        local npcTemplate = CS.XNpcManager.GetNpcTemplate(npcId)
        if not npcTemplate then
            XLog.Error(" XCharacterManager.GetNpcBaseAttrib npcTemplate is null " .. npcTemplate)
            return
        end
        return XAttribManager.GetBaseAttribs(npcTemplate.AttribId)
    end

    -- 升级相关begin --
    function XCharacterManager.IsOverLevel(templateId)
        local curLevel = XPlayer.Level
        local char = XCharacterManager.GetCharacter(templateId)
        return char and char.Level >= curLevel
    end

    function XCharacterManager.IsMaxLevel(templateId)
        local char = XCharacterManager.GetCharacter(templateId)
        local maxLevel = XCharacterConfigs.GetCharMaxLevel(templateId)
        return char and char.Level >= maxLevel
    end

    function XCharacterManager.CalLevelAndExp(character, exp)
        local teamLevel = XPlayer.Level
        local id = character.Id
        local curExp = character.Exp + exp
        local curLevel = character.Level

        local maxLevel = XCharacterConfigs.GetCharMaxLevel(id)

        while curLevel do
            local nextLevelExp = XCharacterConfigs.GetNextLevelExp(id, curLevel)
            if ((curExp >= nextLevelExp) and (curLevel < teamLevel)) then
                if curLevel == maxLevel then
                    curExp = nextLevelExp
                    break
                else
                    curExp = curExp - nextLevelExp
                    curLevel = curLevel + 1
                    if (curLevel >= teamLevel) then
                        break
                    end
                end
            else
                break
            end
        end
        return curLevel, curExp
    end

    function XCharacterManager.GetMaxAvailableLevel(templateId)
        if not templateId then
            return
        end

        local charMaxLevel = XCharacterConfigs.GetCharMaxLevel(templateId)
        local playerMaxLevel = XPlayer.Level

        return mathMin(charMaxLevel, playerMaxLevel)
    end

    function XCharacterManager.GetMaxLevelNeedExp(character)
        local id = character.Id
        local levelUpTemplateId = XCharacterConfigs.GetCharacterTemplate(id).LevelUpTemplateId
        local levelUpTemplate = XCharacterConfigs.GetLevelUpTemplate(levelUpTemplateId)
        local maxLevel = XCharacterConfigs.GetCharMaxLevel(id)
        local totalExp = 0
        for i = character.Level, maxLevel - 1 do
            totalExp = totalExp + levelUpTemplate[i].Exp
        end

        return totalExp - character.Exp
    end
    -- 升级相关end --
    -- 品质相关begin --
    function XCharacterManager.IsMaxQuality(character)
        if not character then
            XLog.Error("XCharacterManager.IsMaxQuality error: character is nil")
            return
        end

        return character.Quality >= XCharacterConfigs.GetCharMaxQuality(character.Id)
    end

    function XCharacterManager.IsMaxQualityById(characterId)
        if not characterId then
            return
        end

        local character = XCharacterManager.GetCharacter(characterId)
        return character and character.Quality >= XCharacterConfigs.GetCharMaxQuality(character.Id)
    end

    function XCharacterManager.IsCanActivateStar(character)
        if not character then
            XLog.Error("XCharacterManager.IsCanActivateStar error: character is nil")
            return
        end

        if character.Quality >= XCharacterConfigs.GetCharMaxQuality(character.Id) then
            return false
        end

        if character.Star >= XCharacterConfigs.MAX_QUALITY_STAR then
            return false
        end

        return true
    end

    function XCharacterManager.IsActivateStarUseItemEnough(templateId, quality, star)
        if not templateId or not quality or not star then
            XLog.Error("XCharacterManager.IsCharQualityStarUseItemEnough error: params is nil, templateId  is " .. templateId .. "quality is " .. quality .. " star is " .. star)
            return
        end

        local template = XCharacterConfigs.GetCharacterTemplate(templateId)
        if not template then
            XLog.Error("XCharacterManager.IsCharQualityStarUseItemEnough error: character config is nil, templateId is " .. templateId)
            return
        end

        if quality < 1 then
            XLog.Error("XCharacterManager.IsCharQualityStarUseItemEnough error: quality is " .. quality)
            return
        end

        if star < 1 or star > XCharacterConfigs.MAX_QUALITY_STAR then
            XLog.Error("XCharacterManager.IsCharQualityStarUseItemEnough error: star is " .. star)
            return
        end

        local itemKey = template.ItemId
        local itemCount = XCharacterConfigs.GetStarUseCount(quality, star)

        return XCharacterManager.IsUseItemEnough(itemKey, itemCount)
    end

    function XCharacterManager.IsCanPromoted(charcaterId)
        local character = XCharacterManager.GetCharacter(charcaterId)
        local hasCoin = XDataCenter.ItemManager.GetCoinsNum()
        local useCoin = XCharacterConfigs.GetPromoteUseCoin(character.Quality)

        return hasCoin >= useCoin
    end

    --得到角色需要展示的 fashionId
    function XCharacterManager.GetShowFashionId(templateId)
        if XCharacterManager.IsOwnCharacter(templateId) == true then
            return OwnCharacters[templateId].FashionId
        else
            return XCharacterConfigs.GetCharacterTemplate(templateId).DefaultNpcFashtionId
        end
    end

    function XCharacterManager.GetCharHalfBodyBigImage(templateId) --获得角色半身像
        local fashionId = XCharacterManager.GetShowFashionId(templateId)

        if fashionId == nil then
            XLog.Error("XCharacterManager.GetShowFashionId error: fashionId id null")
            return
        end

        return XDataCenter.FashionManager.GetFashionHalfBodyImage(fashionId)
    end

    function XCharacterManager.GetCharHalfBodyImage(templateId) --获得角色大全身像
        local fashionId = XCharacterManager.GetShowFashionId(templateId)

        if fashionId == nil then
            XLog.Error("XCharacterManager.GetShowFashionId error: fashionId id null")
            return
        end

        return XDataCenter.FashionManager.GetRoleCharacterBigImage(fashionId)
    end

    function XCharacterManager.GetCharSmallHeadIcon(templateId) --获得角色小头像列表
        local fashionId = XCharacterManager.GetShowFashionId(templateId)

        if fashionId == nil then
            XLog.Error("XCharacterManager.GetShowFashionId error: fashionId id null")
            return
        end

        local isAchieveMaxLiberation = XDataCenter.ExhibitionManager.IsAchieveMaxLiberation(templateId)
        return isAchieveMaxLiberation and XDataCenter.FashionManager.GetFashionSmallHeadIconLiberation(fashionId) or XDataCenter.FashionManager.GetFashionSmallHeadIcon(fashionId)
    end

    function XCharacterManager.GetCharSmallHeadIconByCharacter(character)
        local fashionId = character.FashionId
        local isAchieveMaxLiberation = XDataCenter.ExhibitionManager.IsMaxLiberationLevel(character.LiberateLv)
        if isAchieveMaxLiberation then
            return XDataCenter.FashionManager.GetFashionSmallHeadIconLiberation(fashionId)
        else
            return XDataCenter.FashionManager.GetFashionSmallHeadIcon(fashionId)
        end
    end

    function XCharacterManager.GetCharBigHeadIcon(templateId) --获得角色大头像
        local fashionId = XCharacterManager.GetShowFashionId(templateId)

        if fashionId == nil then
            XLog.Error("XCharacterManager.GetShowFashionId error: fashionId id null")
            return
        end

        local isAchieveMaxLiberation = XDataCenter.ExhibitionManager.IsAchieveMaxLiberation(templateId)
        return isAchieveMaxLiberation and XDataCenter.FashionManager.GetFashionBigHeadIconLiberation(fashionId) or XDataCenter.FashionManager.GetFashionBigHeadIcon(fashionId)
    end

    function XCharacterManager.GetCharRoundnessHeadIcon(templateId) --获得角色圆头像
        local fashionId = XCharacterManager.GetShowFashionId(templateId)

        if fashionId == nil then
            XLog.Error("XCharacterManager.GetShowFashionId error: fashionId id null")
            return
        end

        return XDataCenter.FashionManager.GetFashionRoundnessHeadIcon(fashionId)
    end

    function XCharacterManager.GetCharBigRoundnessHeadIcon(templateId) --获得角色大圆头像
        local fashionId = XCharacterManager.GetShowFashionId(templateId)

        if fashionId == nil then
            XLog.Error("XCharacterManager.GetShowFashionId error: fashionId id null")
            return
        end

        return XDataCenter.FashionManager.GetFashionBigRoundnessHeadIcon(fashionId)
    end

    function XCharacterManager.GetCharBigRoundnessNotItemHeadIcon(templateId) --获得角色圆头像(非物品使用)
        local fashionId = XCharacterManager.GetShowFashionId(templateId)

        if fashionId == nil then
            XLog.Error("XCharacterManager.GetShowFashionId error: fashionId id null")
            return
        end

        local isAchieveMaxLiberation = XDataCenter.ExhibitionManager.IsAchieveMaxLiberation(templateId)
        return isAchieveMaxLiberation and XDataCenter.FashionManager.GetFashionRoundnessNotItemHeadIconLiberation(fashionId) or XDataCenter.FashionManager.GetFashionRoundnessNotItemHeadIcon(fashionId)
    end

    function XCharacterManager.GetFightCharHeadIcon(character) --获得战斗角色头像
        local fashionId = character.FashionId
        local isAchieveMaxLiberation = XDataCenter.ExhibitionManager.IsMaxLiberationLevel(character.LiberateLv)
        if isAchieveMaxLiberation then
            return XDataCenter.FashionManager.GetFashionRoundnessNotItemHeadIconLiberation(fashionId)
        else
            return XDataCenter.FashionManager.GetFashionRoundnessNotItemHeadIcon(fashionId)
        end
    end

    function XCharacterManager.GetCharUnlockFragment(templateId)
        if not templateId then
            XLog.Error("XCharacterManager.GetCharUnlockFragment : templateId")
            return
        end

        local curCharItemId = XCharacterConfigs.GetCharacterTemplate(templateId).ItemId
        if not curCharItemId then
            XLog.Error("XCharacterManager.GetCharUnlockFragment : curCharItemId")
            return
        end

        local item = XDataCenter.ItemManager.GetItem(curCharItemId)

        if not item then
            return 0
        end

        return item.Count
    end

    -- 品质相关end --
    -- 改造相关begin --
    function XCharacterManager.IsMaxCharGrade(character)
        return character.Grade >= XCharacterConfigs.GetCharMaxGrade(character.Id)
    end

    function XCharacterManager.IsPromoteGradeUseItemEnough(templateId, grade)
        if not templateId or not grade then
            XLog.Error("XCharacterManager.IsPromoteGradeUseItemEnough error: params is nil, templateId is " .. templateId .. " grade is" .. grade)
            return
        end

        local gradeConfig = XCharacterConfigs.GetGradeTemplates(templateId, grade)
        if not gradeConfig then
            XLog.Error("XCharacterManager.IsPromoteGradeUseItemEnough error: grade config is nil, grade is " .. grade)
            return
        end

        local itemKey, itemCount = gradeConfig.UseItemKey, gradeConfig.UseItemCount
        if not itemKey then
            return true
        end

        return XCharacterManager.IsUseItemEnough(itemKey, itemCount)
    end

    function XCharacterManager.CheckCanUpdateSkill(charId, subSkillId, subSkillLevel)
        local char = XCharacterManager.GetCharacter(charId)
        if (char == nil) then
            return false
        end

        local min_max = XCharacterConfigs.GetSubSkillMinMaxLevel(subSkillId)
        if (subSkillLevel >= min_max.Max) then
            return false
        end

        local gradeConfig = XCharacterConfigs.GetSkillGradeConfig(subSkillId, subSkillLevel)
        if gradeConfig.ConditionId then
            for k, v in pairs(gradeConfig.ConditionId) do
                if not XConditionManager.CheckCondition(v, charId) then
                    return false
                end
            end
        end

        if (not XCharacterManager.IsUseItemEnough(XDataCenter.ItemManager.ItemId.SkillPoint, gradeConfig.UseSkillPoint)) then
            return false
        end

        if (not XCharacterManager.IsUseItemEnough(XDataCenter.ItemManager.ItemId.Coin, gradeConfig.UseCoin)) then
            return false
        end

        return true
    end

    --==============================--
    --desc: 获取技能等级
    --@npcData: npc数据
    --@return 技能等级映射
    --==============================--
    function XCharacterManager.GetSkillLevelMap(character, skillLevelMap)
        local subSkills = character.SkillLevel

        XTool.LoopMap(subSkills, function(id, level)
            local template = XCharacterConfigs.GetSkillLevelEffectTemplate(id, level)
            for _, v in pairs(template.SubSkillId) do
                skillLevelMap[v] = level
            end
        end)
    end

    --得到人物技能共鸣等级
    function XCharacterManager.GetResonanceSkillLevel(characterId, skillId)
        local npcData = {}
        npcData.Character = XCharacterManager.GetCharacter(characterId)
        npcData.Equips = XDataCenter.EquipManager.GetCharacterWearingEquips(characterId)
        local resonanceSkillLevelMap = XMagicSkillManager.GetResonanceSkillLevelMap(npcData)
        return resonanceSkillLevelMap[skillId] or 0
    end

    --==============================--
    --desc: 获取卡牌出生魔法属性
    --@character: 卡牌数据
    --@bornMagicLevelMap: 出生魔法属性
    --@return
    --==============================--
    function XCharacterManager.GetBornMagicLevelMap(character, bornMagicLevelMap)
        local subSkills = character.SkillLevel

        XTool.LoopMap(subSkills, function(id, level)
            local config = XCharacterConfigs.GetSkillLevelEffectTemplate(id, level)
            for _, v in pairs(config.BornMagic) do
                bornMagicLevelMap[v] = level
            end
        end)
    end

    --==============================--
    --desc: 获取队长技能描述
    --@characterId: 卡牌数据
    --@return 技能Data
    --==============================--
    function XCharacterManager.GetCaptainSkillInfo(characterId)
        local captianSkillId = XCharacterConfigs.GetCharacterCaptainSkill(characterId)
        local skillLevel

        local character = OwnCharacters[characterId]
        if character then
            skillLevel = character.SkillLevel[captianSkillId]
        end

        return XCharacterConfigs.GetCaptainSkillInfo(characterId, skillLevel)
    end

    --解锁角色终阶解放技能
    function XCharacterManager.UnlockMaxLiberationSkill(characterId)
        local skillId = XCharacterConfigs.GetCharMaxLiberationSkillId(characterId)
        local character = OwnCharacters[characterId]
        if character then
            local skillLevel = character.SkillLevel[skillId]
            if not skillLevel or skillLevel <= 0 then
                XCharacterManager.UnlockSubSkill(skillId, characterId)
            end
        end
    end

    -- 技能相关end --
    -- 服务端相关begin--
    function XCharacterManager.ExchangeCharacter(templateId, cb)
        if XCharacterManager.IsOwnCharacter(templateId) then
            XUiManager.TipCode(XCode.CharacterManagerExchangeCharacterAlreadyOwn)
            return
        end

        local char = XCharacterConfigs.GetCharacterTemplate(templateId)
        if not char then
            XUiManager.TipCode(XCode.CharacterManagerGetCharacterTemplateNotFound)
            return
        end

        local itemId = char.ItemId
        local bornQulity = XCharacterConfigs.GetCharMinQuality(templateId)
        local itemCount = XCharacterConfigs.GetComposeCount(bornQulity)

        if not XCharacterManager.IsUseItemEnough(itemId, itemCount) then
            XUiManager.TipText("CharacterManagerItemNotEnough")
            return
        end

        XNetwork.Call(METHOD_NAME.ExchangeCharacter, { TemplateId = templateId }, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            CsXGameEventManager.Instance:Notify(XEventId.EVENT_CHARACTER_SYN, templateId)

            if cb then
                cb()
            end
        end)
    end

    function XCharacterManager.OnSyncCharacter(protoData)
        if not OwnCharacters[protoData.Id] then
            XCharacterManager.AddCharacter(protoData)

            local templateId = protoData.Id
            if XCharacterConfigs.GetCharacterNeedFirstShow(templateId) ~= 0 then
                XUiHelper.PushInFirstGetIdList(templateId, XArrangeConfigs.Types.Character)
            end

            XEventManager.DispatchEvent(XEventId.EVENT_CHARACTER_FIRST_GET, templateId)

            return
        end

        OwnCharacters[protoData.Id]:Sync(protoData)
    end

    function XCharacterManager.OnSyncSubSkillLevel(characterId, subSkillId, level)
        local character = OwnCharacters[characterId]
        character.SkillLevel[subSkillId] = level
    end

    function XCharacterManager.OnSyncCharacterVitality(characterId, vitality)
        local character = OwnCharacters[characterId]
        if not character then return end
        character.Vitality = vitality
    end

    function XCharacterManager.AddExp(character, itemDict, cb)
        if type(character) == "number" then
            character = OwnCharacters[character]
        end

        cb = cb and cb or function(...) end

        XMessagePack.MarkAsTable(itemDict)

        local oldLevel = character.Level
        XNetwork.Call(METHOD_NAME.LevelUp, { TemplateId = character.Id, UseItems = itemDict }, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            local exp = 0
            for k, v in pairs(itemDict) do
                exp = exp + XDataCenter.ItemManager.GetCharExp(k, character.Type) * v
            end
            XEventManager.DispatchEvent(XEventId.EVENT_CHARACTER_INCREASE_TIP, CS.XTextManager.GetText("CharacterExpItemsUse"), CS.XTextManager.GetText("ExpAdd", exp), oldLevel)
            XEventManager.DispatchEvent(XEventId.EVENT_CHARACTER_LEVEL_UP, character.Id)

            cb()
        end)
    end

    function XCharacterManager.ActivateStar(character, cb)
        if type(character) == "number" then
            character = OwnCharacters[character]
        end

        cb = cb or function() end

        if XCharacterManager.IsMaxQuality(character) then
            XUiManager.TipCode(XCode.CharacterManagerMaxQuality)
            return
        end

        if character.Star >= XCharacterConfigs.MAX_QUALITY_STAR then
            XUiManager.TipCode(XCode.CharacterManagerActivateStarMaxStar)
            return
        end

        local star = character.Star + 1

        if not XCharacterManager.IsActivateStarUseItemEnough(character.Id, character.Quality, star) then
            XUiManager.TipText("CharacterManagerItemNotEnough")
            return
        end

        local oldAttribs = XCharacterConfigs.GetCharStarAttribs(character.Id, character.Quality, character.Star)

        XNetwork.Call(METHOD_NAME.ActivateStar, { TemplateId = character.Id }, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            local attrText = ""
            for k, v in pairs(oldAttribs) do
                local value = FixToDouble(v)
                if value > 0 then
                    attrText = XAttribManager.GetAttribNameByIndex(k) .. "+" .. stringFormat("%.2f", value)
                    break
                end
            end

            XEventManager.DispatchEvent(XEventId.EVENT_CHARACTER_QUALITY_STAR_PROMOTE, character.Id)
            XEventManager.DispatchEvent(XEventId.EVENT_CHARACTER_INCREASE_TIP, CS.XTextManager.GetText("CharacterActivation"), attrText)

            if cb then
                cb()
            end
        end)
    end

    function XCharacterManager.PromoteQuality(character, cb)
        if type(character) == "number" then
            character = OwnCharacters[character]
        end

        if XCharacterManager.IsMaxQuality(character) then
            XUiManager.TipCode(XCode.CharacterManagerMaxQuality)
            return
        end

        if character.Star < XCharacterConfigs.MAX_QUALITY_STAR then
            XUiManager.TipCode(XCode.CharacterManagerPromoteQualityStarNotEnough)
            return
        end
        
        if not XDataCenter.ItemManager.DoNotEnoughBuyAsset(XDataCenter.ItemManager.ItemId.Coin,
                XCharacterConfigs.GetPromoteUseCoin(character.Quality),
                1,
                function() 
                    XCharacterManager.PromoteQuality(character, cb)
                end,
                "CharacterManagerItemNotEnough") then
            return
        end

        XNetwork.Call(METHOD_NAME.PromoteQuality, { TemplateId = character.Id }, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            XEventManager.DispatchEvent(XEventId.EVENT_CHARACTER_QUALITY_PROMOTE, character.Id)

            if cb then
                cb()
            end
        end)
    end

    --------------------------------------------------------------------------
    function XCharacterManager.PromoteGrade(character, cb)
        if type(character) == "number" then
            character = OwnCharacters[character]
        end

        if XCharacterManager.IsMaxCharGrade(character) then
            XUiManager.TipCode(XCode.CharacterManagerMaxGrade)
            return
        end

        if not XCharacterManager.IsPromoteGradeUseItemEnough(character.Id, character.Grade) then
            XUiManager.TipText("CharacterManagerCoinNotEnough")
            return
        end

        cb = cb or function() end

        local oldGrade = character.Grade
        XNetwork.Call(METHOD_NAME.PromoteGrade, { TemplateId = character.Id }, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            XEventManager.DispatchEvent(XEventId.EVENT_CHARACTER_GRADE, character.Id)

            cb(oldGrade)
        end)
    end

    function XCharacterManager.UnlockSubSkill(skillId, characterId, cb)
        XNetwork.Call(METHOD_NAME.UnlockSubSkill, { TemplateId = skillId }, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            XEventManager.DispatchEvent(XEventId.EVENT_CHARACTER_SKILL_UNLOCK, characterId)

            if cb then
                cb()
            end
        end)
    end

    function XCharacterManager.UpgradeSubSkillLevel(characterId, skillId, cb)
        XNetwork.Call(METHOD_NAME.UpgradeSubSkill, { TemplateId = skillId }, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            XEventManager.DispatchEvent(XEventId.EVENT_CHARACTER_SKILL_UP, characterId)

            if cb then
                cb()
            end
        end)
    end

    -- 服务端相关end--
    function XCharacterManager.GetCharModel(templateId, quality)
        if not templateId then
            XLog.Error("XCharacterManager.GetCharModel error: templateId is nil")
            return
        end

        if not quality then
            quality = XCharacterConfigs.GetCharMinQuality(templateId)
        end

        local npcId = XCharacterConfigs.GetCharNpcId(templateId, quality)

        if npcId == nil then
            return
        end

        local npcTemplate = CS.XNpcManager.GetNpcTemplate(npcId)

        if npcTemplate == nil then
            XLog.Error("XCharacterManager.GetCharModel: npcTemplate is nil, templateId is ," .. templateId .. " quality is " .. quality)
            return
        end

        return npcTemplate.ModelId
    end

    function XCharacterManager.GetCharResModel(resId)
        if not resId then
            XLog.Error("XCharacterManager.GetCharResModel error: resId is nil")
            return
        end

        local npcTemplate = CS.XNpcManager.GetNpcResTemplate(resId)

        if npcTemplate == nil then
            XLog.Error("XCharacterManager.GetCharResModel: npcTemplate is nil, resId is ," .. resId)
            return
        end

        return npcTemplate.ModelId
    end

    --获取角色解放等级到对应的ModelId
    function XCharacterManager.GetCharLiberationLevelModelId(characterId, growUpLevel)
        if not characterId then
            XLog.Error("XCharacterManager.GetCharLiberationLevelModel error: templateId is nil")
            return
        end
        growUpLevel = growUpLevel or XCharacterConfigs.GrowUpLevel.New

        local modelId = XCharacterConfigs.GetCharLiberationLevelModelId(characterId, growUpLevel)
        if not modelId then
            local character = XDataCenter.CharacterManager.GetCharacter(characterId)
            return XCharacterManager.GetCharModel(characterId, character.Quality)
        end

        return modelId
    end

    --获取角色解放等级到对应的特效名称和模型挂点名
    function XCharacterManager.GetCharLiberationLevelEffectRootAndPath(characterId, growUpLevel)
        if not characterId then
            XLog.Error("XCharacterManager.GetCharLiberationLevelModel error: templateId is nil")
            return
        end
        growUpLevel = growUpLevel or XDataCenter.ExhibitionManager.GetCharacterGrowUpLevel(characterId)
 
        return XCharacterConfigs.GetCharLiberationLevelEffectRootAndPath(characterId, growUpLevel)
    end
    
    function XCharacterManager.GetCharResIcon(resId)
        if not resId then
            XLog.Error("XCharacterManager.GetCharResModel error: resId is nil")
            return
        end

        local npcTemplate = CS.XNpcManager.GetNpcResTemplate(resId)

        if npcTemplate == nil then
            XLog.Error("XCharacterManager.GetCharResModel: npcTemplate is nil, resId is ," .. resId)
            return
        end

        return npcTemplate.HeadImageName
    end

    --红点相关-----------------------------
    function XCharacterManager.CanLevelUp(characterId)
        if not characterId then
            return false
        end

        if not XCharacterManager.IsOwnCharacter(characterId) then
            return false
        end

        local character = XCharacterManager.GetCharacter(characterId)
        if not character then return false end

        if XCharacterManager.IsOverLevel(characterId) or XCharacterManager.IsMaxLevel(characterId) then
            return false
        end

        local expItemsInfo = XDataCenter.ItemManager.GetCardExpItems()
        return next(expItemsInfo)
    end

    --检测是否可以提升品质
    function XCharacterManager.CanPromoteQuality(characterId)

        if not characterId then
            return false
        end

        if not XCharacterManager.IsOwnCharacter(characterId) then
            return false
        end

        local character = XCharacterManager.GetCharacter(characterId)

        if XCharacterManager.IsMaxQuality(character) then
            return false
        end

        --最大星级时可以进化到下一阶
        if character.Star == XCharacterConfigs.MAX_QUALITY_STAR then
            return XCharacterManager.IsCanPromoted(character.Id)
        end

        local star = character.Star + 1
        if not XCharacterManager.IsActivateStarUseItemEnough(character.Id, character.Quality, star) then
            return false
        end

        return true
    end

    --检测是否可以晋升
    function XCharacterManager.CanPromoteGrade(characterId)

        if not characterId then
            return false
        end

        if not XCharacterManager.IsOwnCharacter(characterId) then
            return false
        end

        local character = XCharacterManager.GetCharacter(characterId)

        if XCharacterManager.IsMaxCharGrade(character) then
            return false
        end

        if not XCharacterManager.CheckCanPromoteGradePrecondition(characterId, character.Id, character.Grade) then
            return false
        end

        if not XCharacterManager.IsPromoteGradeUseItemEnough(character.Id, character.Grade) then
            return false
        end

        return true
    end

    function XCharacterManager.CheckCanPromoteGradePrecondition(characterId, templateId, grade)
        local gradeTemplate = XCharacterConfigs.GetGradeTemplates(templateId, grade)
        if not gradeTemplate then
            return
        end

        if #gradeTemplate.ConditionId > 0 then
            for i = 1, #gradeTemplate.ConditionId do
                local coditionId = gradeTemplate.ConditionId[i]
                if not XConditionManager.CheckCondition(coditionId, characterId) then
                    return false
                end
            end

            return true
        else
            return true
        end
    end

    --是否有技能红点
    function XCharacterManager.CanPromoteSkill(characterId)
        if not characterId then
            return false
        end

        local character = OwnCharacters[characterId]
        if not character then
            return false
        end

        local canUpdate = false
        local skills = XCharacterConfigs.GetCharacterSkills(characterId)
        for pos, skill in pairs(skills) do
            for _, subSkill in ipairs(skill.subSkills) do
                if (XCharacterManager.CheckCanUpdateSkill(characterId, subSkill.SubSkillId, subSkill.Level)) then
                    canUpdate = true
                    break
                end
            end
        end

        return canUpdate
    end

    --判断是否能解锁
    function XCharacterManager:CanCharacterUnlock(characterId)
        if not characterId then
            return false
        end

        if XCharacterManager.IsOwnCharacter(characterId) then
            return false
        end

        local character = XCharacterConfigs.GetCharacterTemplate(characterId)

        local itemId = character.ItemId
        local bornQulity = XCharacterConfigs.GetCharMinQuality(characterId)
        local itemCount = XCharacterConfigs.GetComposeCount(bornQulity)

        if not XCharacterManager.IsUseItemEnough(itemId, itemCount) then
            return false
        end

        return true
    end

    function XCharacterManager.NotifyCharacterDataList(data)
        local characterList = data.CharacterDataList
        if not characterList then
            return
        end

        for _, character in pairs(characterList) do
            XCharacterManager.OnSyncCharacter(character)
        end
    end
    return XCharacterManager
end

XRpc.NotifyCharacterDataList = function(data)
    XDataCenter.CharacterManager.NotifyCharacterDataList(data)
end