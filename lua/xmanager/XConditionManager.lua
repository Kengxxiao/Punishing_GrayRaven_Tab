XConditionManager = XConditionManager or {}

local TABLE_CONDITION_PATH = "Share/Condition/Condition.tab"
local ConditionTemplate = {}

local DefaultRet = true

XConditionManager.ConditionType = {
    Unknown = 0,
    Player = 1,
    Character = 13,
    Team = 18
}

local PlayerCondition = {
    [10101] = function(condition) -- 查询玩家等级是否达标
        return XPlayer.Level >= condition.Params[1], condition.Desc
    end,
    [10102] = function(condition) -- 查询玩家是否拥有指定角色
        return XDataCenter.CharacterManager.IsOwnCharacter(condition.Params[1]), condition.Desc
    end,
    [10103] = function(condition) -- 查询玩家是否拥有指定数量的角色
        return #XDataCenter.CharacterManager.GetOwnCharacterList() >= condition.Params[1], condition.Desc
    end,
    [10104] = function(condition) -- 查询玩家背包是否有容量
        local ret, desc = PlayerCondition[12101](condition)
        if not ret then
            return ret, desc
        end

        return PlayerCondition[12102](condition)
    end,
    [10105] = function(condition) -- 查询玩家是否通过指定得关卡
        local stageId = condition.Params[1]
        -- local stageInfo = XDataCenter.FubenManager.GetStageInfo(stageId)
        -- if stageInfo then
        --     return stageInfo.Passed, condition.Desc
        -- else
        --     return true, condition.Desc
        -- end
        local flage = XDataCenter.FubenManager.CheckStageIsPass(stageId)
        return flage, condition.Desc
    end,
    [10106] = function(condition)--至少拥有其中一个角色
        if condition.Params and #condition.Params > 0 then
            for i = 1, #condition.Params do
                local isOwnCharacter = XDataCenter.CharacterManager.IsOwnCharacter(condition.Params[i])
                if isOwnCharacter then
                    return true, condition.Desc
                end
            end
        end
        return false, condition.Desc
    end,
    [10107] = function(condition) -- 查询玩家等级是否小于等于n
        return XPlayer.Level <= condition.Params[1], condition.Desc
    end,
    [10108] = function(condition) -- 查询玩家是否通过指定得关卡
        local stageId = condition.Params[1]
        local stageInfo = XDataCenter.FubenManager.GetStageInfo(stageId)
        if stageInfo then
            return (not stageInfo.Passed), condition.Desc
        else
            return false, condition.Desc
        end
    end,
    [10109] = function(condition) --查询玩家是否拥有战力X的角色数量
        local needCount = condition.Params[1]
        local needAbility = condition.Params[2]
        local curCount = XDataCenter.CharacterManager.GetCharacterCountByAbility(needAbility)
        if (curCount >= needCount) then
            return true, condition.Desc
        else
            return false, condition.Desc
        end
    end,
    [10110] = function(condition) -- 查询玩家是否有某个勋章
        return XPlayer.IsMedalUnlock(condition.Params[1]), condition.Desc
    end,
    [11101] = function(condition) -- 查询指定道具数量是否达标
        return XDataCenter.ItemManager.CheckItemCountById(condition.Params[1], condition.Params[2]), condition.Desc
    end,
    [11102] = function(condition)--查询玩家角色解放阶段是否达到
        return XDataCenter.ExhibitionManager.IsAchieveLiberation(condition.Params[1], condition.Params[2]), condition.Desc
    end,
    [11103] = function(condition) -- 查询玩家是否领取首充奖励
        return XDataCenter.PayManager.GetFirstRechargeReward(), condition.Desc
    end,
    [11104] = function(condition) -- 查询玩家是否拥有某个时装
        return XDataCenter.FashionManager.CheckHasFashion(condition.Params[1]), condition.Desc
    end,
    [11105] = function(condition) -- 查询玩家是否不拥有某个时装
        return not XDataCenter.FashionManager.CheckHasFashion(condition.Params[1]), condition.Desc
    end,
    [11106] = function(condition) -- 查询玩家是否通过某个试验区关卡（填试验区ID）
        return XDataCenter.FubenExperimentManager.CheakExperimentIsFinish(condition.Params[1]), condition.Desc
    end,
    [12101] = function(condition) -- 查询武器库是否有容量
        return XDataCenter.EquipManager.CheckMaxCount(XEquipConfig.Classify.Weapon), condition.Desc
    end,
    [12102] = function(condition) -- 查询意识库是否有容量
        return XDataCenter.EquipManager.CheckMaxCount(XEquipConfig.Classify.Awareness), condition.Desc
    end,
    [21101] = function(condition) -- 查询玩家是否购买月卡
        local isGot = true
        if XDataCenter.PurchaseManager.IsYkBuyed() then
            local data = XDataCenter.PurchaseManager.GetYKInfoData()
            if data then
                isGot = data.IsDailyRewardGet
            end
        end
        return not isGot, condition.Desc
    end,
    [21102] = function(condition) -- 查询玩家是否未领取首充奖励
        return not XDataCenter.PayManager.GetFirstRechargeReward(), condition.Desc
    end,
    [22001] = function(condition) -- 红包活动ID下指定NPC累计获得的物品数量
        local count = condition.Params[1]
        local itemId = condition.Params[2]
        local activityId = condition.Params[3]
        local npcId = condition.Params[4]
        local total = XDataCenter.ItemManager.GetRedEnvelopeCertainNpcItemCount(activityId, npcId, itemId)
        return total >= count, condition.Desc
    end,
}

local CharacterCondition = {
    [13101] = function(condition, characterId) -- 查询角色性别是否符合
        if type(characterId) ~= "number" then
            characterId = characterId.Id
        end
        local characterTemplate = XCharacterConfigs.GetCharacterTemplate(characterId)
        return characterTemplate.Sex == condition.Params[1], condition.Desc
    end,
    [13102] = function(condition, characterId) -- 查询角色类型是否符合
        local character = characterId
        if type(characterId) == "number" then
            character = XDataCenter.CharacterManager.GetCharacter(characterId)
        end
        local npcId = XCharacterConfigs.GetCharNpcId(character.Id, character.Quality)
        local npcTemplate = CS.XNpcManager.GetNpcTemplate(npcId)
        for i = 1, #condition.Params do
            if npcTemplate.Type == condition.Params[i] then
                return true
            end
        end
        return false, condition.Desc
    end,

    [13103] = function(condition, characterId) -- 查询角色是否符合等级
        local character = XDataCenter.CharacterManager.GetCharacter(characterId)
        return character.Level >= condition.Params[1], condition.Desc
    end,

    [13104] = function(condition, characterId) -- 查询单个角色类型是否符合
        local character = characterId
        if type(characterId) == "number" then
            character = XDataCenter.CharacterManager.GetCharacter(characterId)
        end
        local npcId = XCharacterConfigs.GetCharNpcId(character.Id, character.Quality)
        local npcTemplate = CS.XNpcManager.GetNpcTemplate(npcId)
        if npcTemplate.Type == condition.Params[1] then
            return true
        end
        return false, condition.Desc
    end,
    [13105] = function(condition, characterId) -- 查询单个角色品质是否符合
        local character = characterId
        if type(characterId) == "number" then
            character = XDataCenter.CharacterManager.GetCharacter(characterId)
        end

        if character.Quality >= condition.Params[1] then
            return true
        end

        return false, condition.Desc
    end,


    [13106] = function(condition, characterId) -- 查询拥有构造体
        if characterId == condition.Params[1] then
            return true
        end

        return false, condition.Desc
    end,

    [13107] = function(condition, characterId) --查询角色是否符合Grade等级要求
        local character = nil
        if type(characterId) == "number" then
            character = XDataCenter.CharacterManager.GetCharacter(characterId)
        end

        if not character then
            return false, condition.Desc
        end

        if character.Grade >= condition.Params[1] then
            return true
        end
        return false, condition.Desc
    end,

    [13108] = function(condition, characterId) --查询角色战力是否满足
        local character = XDataCenter.CharacterManager.GetCharacter(characterId)
        if character.Ability >= condition.Params[1] then
            return true, condition.Desc
        end
        return false, condition.Desc
    end,

    [13109] = function(condition, characterId) --查询角色是否佩戴共鸣技能
        local starLimit = condition.Params[1]
        local limitSkillNum = condition.Params[2]
        local allSkillNum = 0

        local weaponData = XDataCenter.EquipManager.GetCharacterWearingWeaponId(characterId)
        local equipInfo = XDataCenter.EquipManager.GetEquip(weaponData)
        local star = XDataCenter.EquipManager.GetEquipStar(equipInfo.TemplateId)
        if star >= starLimit then
            if equipInfo.ResonanceInfo ~= nil then
                for _, info in pairs(equipInfo.ResonanceInfo) do
                    if info.CharacterId == characterId then
                        allSkillNum = allSkillNum + 1
                    end
                end
            end
        end

        local awarenessData = XDataCenter.EquipManager.GetCharacterWearingAwarenessIds(characterId)
        for _, equipId in pairs(awarenessData) do
            local equipInfo = XDataCenter.EquipManager.GetEquip(equipId)
            local star = XDataCenter.EquipManager.GetEquipStar(equipInfo.TemplateId)
            if star >= starLimit then
                if equipInfo.ResonanceInfo ~= nil then
                    for _, info in pairs(equipInfo.ResonanceInfo) do
                        if info.CharacterId == characterId then
                            allSkillNum = allSkillNum + 1
                        end
                    end
                end
            end
        end

        if allSkillNum >= limitSkillNum then
            return true, condition.Desc
        end

        return false, condition.Desc
    end,

    [13110] = function(condition, characterId) --角色武器共鸣技能数
        if not condition.Params or #condition.Params ~= 2 then
            return false, condition.Desc
        end
        local resonanceCount = 0
        local weaponData = XDataCenter.EquipManager.GetCharacterWearingWeaponId(characterId)
        local equipInfo = XDataCenter.EquipManager.GetEquip(weaponData)
        if equipInfo.ResonanceInfo ~= nil then
            for _, info in pairs(equipInfo.ResonanceInfo) do
                local quality = XDataCenter.EquipManager.GetEquipQuality(equipInfo.TemplateId)
                if info.CharacterId == characterId and quality >= condition.Params[1] then
                    resonanceCount = resonanceCount + 1
                end
                if resonanceCount > condition.Params[2] then
                    return true, condition.Desc
                end
            end
        end
        return false, condition.Desc
    end,

    [13111] = function(condition, characterId) --角色意识共鸣技能数
        if not condition.Params or #condition.Params ~= 2 then
            return false, condition.Desc
        end
        local weaponData = XDataCenter.EquipManager.GetCharacterWearingAwarenessIds(characterId)
        local resonanceCount = 0
        for _, equipId in pairs(weaponData) do
            local equipInfo = XDataCenter.EquipManager.GetEquip(equipId)
            if equipInfo.ResonanceInfo ~= nil then
                for _, info in pairs(equipInfo.ResonanceInfo) do
                    local quality = XDataCenter.EquipManager.GetEquipQuality(equipInfo.TemplateId)
                    if info.CharacterId == characterId and quality >= condition.Params[1] then
                        resonanceCount = resonanceCount + 1
                    end
                    if resonanceCount > condition.Params[2] then
                        return true, condition.Desc
                    end
                end
            end
        end
        return false, condition.Desc
    end,

    [13112] = function(condition, characterId) --角色指定id武器共鸣技能数
        if not condition.Params or #condition.Params ~= 2 then
            return false, condition.Desc
        end
        local weaponData = XDataCenter.EquipManager.GetCanUseWeaponIds(characterId)
        local resonanceCount = 0
        local equipInfo = nil
        for _, equipId in pairs(weaponData) do
            if equipId == condition.Params[1] then
                equipInfo = XDataCenter.EquipManager.GetEquip(equipId)
            end

            if equipInfo then
                if equipInfo.ResonanceInfo ~= nil then
                    for _, info in pairs(equipInfo.ResonanceInfo) do
                        if info.CharacterId == characterId then
                            resonanceCount = resonanceCount + 1
                        end
                        if resonanceCount > condition.Params[2] then
                            return true, condition.Desc
                        end
                    end
                end
            end
        end
        return false, condition.Desc
    end
}

local TeamCondition = {
    [18101] = function(condition, characterIds) -- 查询队伍角色性别是否符合
        local ret, desc = true, nil
        if type(characterIds) == "table" then
            for _, id in pairs(characterIds) do
                if id > 0 then
                    ret, desc = CharacterCondition[13101](condition, id)
                    if not ret then
                        break
                    end
                end
            end
        else
            XTool.LoopCollection(characterIds, function(id)
                if id > 0 then
                    if ret then
                        ret, desc = CharacterCondition[13101](condition, id)
                    end
                end
            end)
        end

        return ret, desc
    end,
    [18102] = function(condition, characterIds) -- 查询队伍角色类型是否符合
        local ret, desc = true, nil
        if type(characterIds) == "table" then
            for _, id in pairs(characterIds) do
                if id > 0 then
                    ret, desc = CharacterCondition[13102](condition, id)
                    if not ret then
                        break
                    end
                end
            end
        else
            XTool.LoopCollection(characterIds, function(id)
                if id > 0 then
                    ret, desc = CharacterCondition[13102](condition, id)
                    if ret then
                        ret, desc = CharacterCondition[13101](condition, id)
                    end
                end
            end)
        end

        return ret, desc
    end,
    [18103] = function(condition, characterIds) -- 查询队伍是否拥有指定角色数量
        local chechCount = condition.Params[1] or 1
        local total = 0
        if type(characterIds) == "table" then
            for i = 2, #condition.Params do
                for _, id in pairs(characterIds) do
                    if id > 0 then
                        if id == condition.Params[i] then
                            total = total + 1
                            break
                        end
                    end
                end

                if total >= chechCount then
                    break
                end
            end
        else
            for i = 2, #condition.Params do
                XTool.LoopCollection(characterIds, function(id)
                    if id > 0 then
                        if id == condition.Params[i] then
                            total = total + 1
                        end
                    end
                end)

                if total >= chechCount then
                    break
                end
            end
        end

        return total >= chechCount, condition.Desc
    end,
    [18104] = function(condition, characterIds) -- 查询队伍是否已拥有指定角色数量
        if type(characterIds) == "table" then
            for i = 1, #condition.Params do
                for _, id in pairs(characterIds) do
                    if id > 0 then
                        if id == condition.Params[i] then
                            return false, condition.Desc
                        end
                    end
                end
            end
        else
            for i = 2, #condition.Params do
                XTool.LoopCollection(characterIds, function(id)
                    if id > 0 then
                        if id == condition.Params[i] then
                            return false, condition.Desc
                        end
                    end
                end)
            end
        end

        return true, condition.Desc
    end,
    [18105] = function(condition, characterIds) -- 派遣中拥有指定数量指定兵种构造
        local ret, desc = true, nil
        local chechCount = condition.Params[2] or 1
        local total = 0
        if type(characterIds) == "table" then
            for _, id in pairs(characterIds) do
                if id > 0 then
                    ret, desc = CharacterCondition[13104](condition, id)
                    if ret then
                        total = total + 1
                    end
                end

                if total >= chechCount then
                    break
                end
            end
        else
            XTool.LoopCollection(characterIds, function(id)
                if id > 0 then
                    ret, desc = CharacterCondition[13104](condition, id)
                    if ret then
                        total = total + 1
                    end
                end

                if total >= chechCount then
                    return
                end
            end)
        end

        return total >= chechCount, condition.Desc
    end,
    [18106] = function(condition, characterIds) -- 派遣中拥有指定数量达到指定战斗力的构造体
        local ret, desc = true, nil
        local chechCount = condition.Params[2] or 1
        local total = 0

        if type(characterIds) == "table" then
            for _, id in pairs(characterIds) do
                local character = XDataCenter.CharacterManager.GetCharacter(id)
                if character.Ability >= condition.Params[1] then
                    total = total + 1
                end
            end
        end

        return total >= chechCount, condition.Desc
    end,

    [18107] = function(condition, characterIds) -- 派遣中拥有指定数量达到指定品质的构造体
        local ret, desc = true, nil
        local chechCount = condition.Params[2] or 1
        local total = 0
        if type(characterIds) == "table" then
            for _, id in pairs(characterIds) do
                if id > 0 then
                    ret, desc = CharacterCondition[13105](condition, id)
                    if ret then
                        total = total + 1
                    end
                end

                if total >= chechCount then
                    break
                end
            end
        else
            XTool.LoopCollection(characterIds, function(id)
                if id > 0 then
                    ret, desc = CharacterCondition[13105](condition, id)
                    if ret then
                        total = total + 1
                    end
                end

                if total >= chechCount then
                    return
                end
            end)
        end

        return total >= chechCount, condition.Desc
    end,
    [18108] = function(condition, characterIds) -- 派遣中拥有指定数量达到指定等级的构造体
        local ret, desc = true, nil
        local chechCount = condition.Params[2] or 1
        local total = 0
        if type(characterIds) == "table" then
            for _, id in pairs(characterIds) do
                if id > 0 then
                    ret, desc = CharacterCondition[13103](condition, id)
                    if ret then
                        total = total + 1
                    end
                end

                if total >= chechCount then
                    break
                end
            end
        else
            XTool.LoopCollection(characterIds, function(id)
                if id > 0 then
                    ret, desc = CharacterCondition[13103](condition, id)
                    if ret then
                        total = total + 1
                    end
                end

                if total >= chechCount then
                    return
                end
            end)
        end

        return total >= chechCount, condition.Desc
    end,
    [18109] = function(condition, characterIds) -- 派遣中拥有指定数量指定性别的构造体
        local ret, desc = true, nil
        local chechCount = condition.Params[2] or 1
        local total = 0
        if type(characterIds) == "table" then
            for _, id in pairs(characterIds) do
                if id > 0 then
                    ret, desc = CharacterCondition[13101](condition, id)
                    if ret then
                        total = total + 1
                    end
                end

                if total >= chechCount then
                    break
                end

            end
        else
            XTool.LoopCollection(characterIds, function(id)
                if id > 0 then
                    ret, desc = CharacterCondition[13101](condition, id)
                    if ret then
                        total = total + 1
                    end
                end

                if total >= chechCount then
                    return
                end
            end)
        end

        return total >= chechCount, condition.Desc
    end,
    [18110] = function(condition, characterIds) -- 派遣中拥有构造体
        local ret, desc = true, nil
        local chechCount = condition.Params[2] or 1
        local total = 0
        if type(characterIds) == "table" then
            for _, id in pairs(characterIds) do
                if id > 0 then
                    ret, desc = CharacterCondition[13106](condition, id)
                    if ret then
                        total = total + 1
                    end
                end

                if total >= chechCount then
                    break
                end
            end
        else
            XTool.LoopCollection(characterIds, function(id)
                if id > 0 then
                    ret, desc = CharacterCondition[13106](condition, id)
                    if ret then
                        total = total + 1
                    end
                end

                if total >= chechCount then
                    return
                end
            end)
        end

        return total >= chechCount, condition.Desc
    end,
    [18111] = function(condition, characterIds) -- 仅可上阵N个人
        local count = condition.Params[1]
        local compareType = condition.Params[2]
        local total = 0
        for k, v in pairs(characterIds) do
            if v > 0 then
                total = total + 1
            end
        end
        if compareType == XUiCompareType.Equal then--等于
            return total == count, condition.Desc
        end
        if compareType == XUiCompareType.NoLess then--大于等于
            return total >= count, condition.Desc
        end
        return false, condition.Desc
    end,
}

function XConditionManager.GetConditionType(id)
    local template = ConditionTemplate[id]
    if not template then
        XLog.Error("XConditionManager.GetConditionType error: can not found template, id is " .. id)
        return XConditionManager.ConditionType.Unknown
    end

    if template.Type >= 13000 and template.Type < 14000 then
        return XConditionManager.ConditionType.Character
    elseif template.Type >= 18000 and template.Type < 19000 then
        return XConditionManager.ConditionType.Team
    else
        return XConditionManager.ConditionType.Player
    end
end


function XConditionManager.Init()
    ConditionTemplate = XTableManager.ReadByIntKey(TABLE_CONDITION_PATH, XTable.XTableCondition, "Id")
end

function XConditionManager.GetConditionTemplate(id)
    if not ConditionTemplate[id] then
        XLog.Error("XConditionManager.GetConditionTemplate config is null " .. id)
        return
    end
    return ConditionTemplate[id]
end

function XConditionManager.CheckCharacterCondtion(id, characterId)
    local template = ConditionTemplate[id]
    if not template then
        XLog.Error("XConditionManager.CheckCharacterCondtion error: can not found template, id is " .. id)
        return DefaultRet
    end

    local func = CharacterCondition[template.Type]
    if not func then
        XLog.Error("XConditionManager.CheckCharacterCondtion error: can not found condition, id is " .. id .. " type is " .. template.Type)
        return DefaultRet
    end

    return func(template, characterId)
end

function XConditionManager.CheckPlayerCondtion(id)
    local template = ConditionTemplate[id]
    if not template then
        XLog.Error("XConditionManager.CheckPlayerCondtion error: can not found template, id is " .. id)
        return DefaultRet
    end

    local func = PlayerCondition[template.Type]
    if not func then
        XLog.Error("XConditionManager.CheckPlayerCondtion error: can not found condition, id is " .. id .. " type is " .. template.Type)
        return DefaultRet
    end

    return func(template)
end

function XConditionManager.CheckTeamCondition(id, characterIds)
    local template = ConditionTemplate[id]
    if not template then
        XLog.Error("XConditionManager.CheckTeamCondition error: can not found template, id is " .. id)
        return DefaultRet
    end

    local func = TeamCondition[template.Type]
    if not func then
        XLog.Error("XConditionManager.CheckTeamCondition error: can not found condition, id is " .. id .. " type is " .. template.Type)
        return DefaultRet
    end

    return func(template, characterIds)
end

function XConditionManager.CheckCondition(id, ...)
    local type = XConditionManager.GetConditionType(id)
    if type == XConditionManager.ConditionType.Character then
        return XConditionManager.CheckCharacterCondtion(id, ...)
    elseif type == XConditionManager.ConditionType.Team then
        return XConditionManager.CheckTeamCondition(id, ...)
    else
        return XConditionManager.CheckPlayerCondtion(id, ...)
    end
end