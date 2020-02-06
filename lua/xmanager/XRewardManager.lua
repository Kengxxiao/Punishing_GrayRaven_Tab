local pairs = pairs
local type = type

local table = table
local tableInsert = table.insert
local tableSort = table.sort

XRewardManager = XRewardManager or {}

local XRewardType = {
    Item = 1,
    Character = 2,
    Equip = 3,
    Fashion = 4,
    BaseEquip = 5,
    Furniture = 9,
    HeadPortrait = 10,
    DormCharacter = 11,
}

local TABLE_REWARD_PATH = "Share/Reward/Reward.tab"
local TABLE_REWARD_GOODS_PATH = "Share/Reward/RewardGoods.tab"
local GOODS_PARAMS_NEED_COUNT = 3

local RewardTemplates = {}
local RewardSubIds = {}

local Arrange2RewardType = {
    [XArrangeConfigs.Types.Item] = XRewardType.Item,
    [XArrangeConfigs.Types.Character] = XRewardType.Character,
    [XArrangeConfigs.Types.Weapon] = XRewardType.Equip,
    [XArrangeConfigs.Types.Wafer] = XRewardType.Equip,
    [XArrangeConfigs.Types.Fashion] = XRewardType.Fashion,
    [XArrangeConfigs.Types.BaseEquip] = XRewardType.BaseEquip,
    [XArrangeConfigs.Types.Furniture] = XRewardType.Furniture,
    [XArrangeConfigs.Types.HeadPortrait] = XRewardType.HeadPortrait,
    [XArrangeConfigs.Types.DormCharacter] = XRewardType.DormCharacter,
}

local CreateGoodsFunc = {
    [XRewardType.Item] = function(templateId, count)
        return {
            RewardType = XRewardType.Item,
            TemplateId = templateId,
            Count = count and count or 1
        }
    end,

    [XRewardType.Character] = function(templateId, count, args)
        local template = XCharacterConfigs.GetCharacterBorderTemplate(templateId)
        if not template then
            XLog.Error("XRewardManager CreateRewardCharacter error: can not found character template, templateId is " .. templateId)
            return
        end

        local len = #args
        local level, quality, grade = template.MinLevel, template.MinQuality, template.MinGrade

        if len > 0 and args[1] > 0 then
            level = args[1]
            if level > template.MaxLevel or level < template.MinLevel then
                XLog.Error("XRewardManager CreateRewardCharacter error: level out of range, id is ", templateId, " level is ", level, " min level is ", template.MinLeXvel, " max level is ", template.MaxLeXvel)
                return
            end
        end

        if len > 1 and args[2] > 0 then
            quality = args[2]
            if quality > template.MaxQuality or quality < template.MinQuality then
                XLog.Error("XRewardManager CreateRewardCharacter error: quality out of range, id is ", templateId, " quality is ", quality, " min quality is ", template.MinQuality, " max quality is ", template.MaxQuality)
                return
            end
        end

        if len > 2 and args[3] > 0 then
            grade = args[3]
            if grade > template.MaxGrade or grade < template.MinGrade then
                XLog.Error("XRewardManager CreateRewardCharacter error: grade out of range, id is ", templateId, " grade is ", grade, " min grade is ", template.MinGrade, " max grade is ", template.MaxGrade)
                return
            end
        end

        return {
            RewardType = XRewardType.Character,
            TemplateId = templateId,
            Count = count and count or 1,
            Level = level,
            Quality = quality,
            Grade = grade
        }
    end,

    [XRewardType.Equip] = function(templateId, count, args)
        local len = args and #args or 0
        local level, star, breakthrough
        local borderCfg = XEquipConfig.GetEquipBorderCfg(templateId)

        if len > 0 and args[1] then
            level = args[1]
            if level > borderCfg.MaxLevel or level < borderCfg.MinLevel then
                XLog.Error("XRewardManager CreateRewardEquip error: level is out of range, id is ", templateId, "level is ", level, " min level is ", borderCfg.MinLevel, " max level is ", borderCfg.MaxLevel)
                return
            end
        else
            level = borderCfg.MinLevel
        end

        if len > 2 and args[3] > 0 then
            breakthrough = args[3]
            if breakthrough > borderCfg.MaxBreakthrough or breakthrough < borderCfg.MinBreakthrough then
                XLog.Error("XRewardManager CreateRewardEquip error: breakthrough is out of range, id is ", templateId, " breakthrough is ", breakthrough, " min breakthrough is ", borderCfg.MinBreakthrough, " max breakthrough is ", borderCfg.MaxBreakthrough)
                return
            end
        else
            breakthrough = borderCfg.MinBreakthrough
        end

        return {
            RewardType = XRewardType.Equip,
            TemplateId = templateId,
            Count = count and count or 1,
            Level = level,
            Star = star,
            Breakthrough = breakthrough
        }
    end,

    [XRewardType.Fashion] = function(templateId, count)
        return {
            RewardType = XRewardType.Fashion,
            TemplateId = templateId,
            Count = count and count or 1
        }
    end,

    [XRewardType.BaseEquip] = function(templateId, count)
        return {
            RewardType = XRewardType.BaseEquip,
            TemplateId = templateId,
            Count = count and count or 1
        }
    end,

    [XRewardType.Furniture] = function(templateId, count)
        local quality = XDataCenter.FurnitureManager.GetRewardFurnitureQuality(templateId)
        return {
            XRewardType = XRewardType.Furniture,
            TemplateId = templateId,
            Count = count and count or 1,
            Quality = quality,
        }
    end,

    [XRewardType.HeadPortrait] = function(templateId, count)
        return {
            RewardType = XRewardType.HeadPortrait,
            TemplateId = templateId,
            Count = count and count or 1,
            Quality = XPlayerManager.GetHeadPortraitQuality()
        }
    end,

    [XRewardType.DormCharacter] = function(templateId, count)
        return {
            RewardType = XRewardType.DormCharacter,
            TemplateId = templateId,
            Count = count and count or 1,
        }
    end,
}

local CloneRewardGoods = function(rewardGoods)
    return {
        RewardType = rewardGoods.RewardType,
        TemplateId = rewardGoods.TemplateId,
        Count = rewardGoods.Count,
        Level = rewardGoods.Level,
        Quality = rewardGoods.Quality,
        Grade = rewardGoods.Grade,
        Star = rewardGoods.Star,
        ConvertFrom = rewardGoods.ConvertFrom,
        Breakthrough = rewardGoods.Breakthrough
    }
end

local CreateRewardGoods = function(templateId, count, args)
    local idType = XArrangeConfigs.GetType(templateId)
    local rewardType = Arrange2RewardType[idType]

    if not rewardType then
        XLog.Error("XRewardManager.CreateRewardGoodsByTemplate error: reward type not support, templateId is " .. templateId)
        return
    end

    return CreateGoodsFunc[rewardType](templateId, count, args)
end

local CreateRewardGoodsByTemplate = function(tab)
    return CreateRewardGoods(tab.TemplateId, tab.Count, tab.Params)
end

--==============================--
--desc: 通用角色奖励排序
--==============================--
local SortCharacters = function(a, b)
    local tmpId1 = a.TemplateId and a.TemplateId or a.Id
    local tmpId2 = b.TemplateId and b.TemplateId or b.Id

    local quality1 = a.Quality and a.Quality or XCharacterConfigs.GetCharMinQuality(tmpId1)
    local quality2 = b.Quality and b.Quality or XCharacterConfigs.GetCharMinQuality(tmpId2)

    if quality1 ~= quality2 then
        return quality1 > quality2
    end

    local priority1 = XCharacterConfigs.GetCharacterPriority(tmpId1)
    local priority2 = XCharacterConfigs.GetCharacterPriority(tmpId2)

    if priority1 ~= priority2 then
        return priority1 > priority2
    end

    return tmpId1 > tmpId2
end

--==============================--
--desc: 通用时装奖励排序
--==============================--
local SortFashions = function(a, b)
    local tmpId1 = a.TemplateId and a.TemplateId or a.Id
    local tmpId2 = b.TemplateId and b.TemplateId or b.Id

    local quality1 = XDataCenter.FashionManager.GetFashionQuality(tmpId1)
    local quality2 = XDataCenter.FashionManager.GetFashionQuality(tmpId2)

    if quality1 ~= quality2 then
        return quality1 > quality2
    end

    local priority1 = XDataCenter.FashionManager.GetFashionPriority(tmpId1)
    local priority2 = XDataCenter.FashionManager.GetFashionPriority(tmpId2)

    if priority1 ~= priority2 then
        return priority1 > priority2
    end

    return tmpId1 > tmpId2
end

--==============================--
--desc: 通用装备奖励排序
--==============================--
local SortEquips = function(a, b)
    local tmpId1 = a.TemplateId
    local tmpId2 = b.TemplateId

    local quality1 = XDataCenter.EquipManager.GetEquipQuality(tmpId1)
    local quality2 = XDataCenter.EquipManager.GetEquipQuality(tmpId2)

    if quality1 ~= quality2 then
        return quality1 > quality2
    end

    if a.Star ~= b.Star then
        return a.Star > b.Star
    end

    if a.Level ~= b.Level then
        return a.Level > b.Level
    end

    local priority1 = XDataCenter.EquipManager.GetEquipPriority(tmpId1)
    local priority2 = XDataCenter.EquipManager.GetEquipPriority(tmpId2)

    if priority1 ~= priority2 then
        return priority1 > priority2
    end

    return tmpId1 > tmpId2
end

--==============================--
--desc: 通用基地装备奖励排序
--==============================--
local SortBaseEquips = function(a, b)
    -- 等级 > 品质
    local tmpId1 = a.TemplateId
    local tmpId2 = b.TemplateId

    local template1 = XDataCenter.BaseEquipManager.GetBaseEquipTemplate(tmpId1)
    local template2 = XDataCenter.BaseEquipManager.GetBaseEquipTemplate(tmpId2)

    if template1.Level ~= template2.Level then
        return template1.Level > template2.Level
    end

    if template1.Quality ~= template2.Quality then
        return template1.Quality > template2.Quality
    end

    if template1.Priority ~= template2.Priority then
        return template1.Priority > template2.Priority
    end

    return tmpId1 > tmpId2
end

--==============================--
--desc: 通用家具奖励排序
--==============================--
local SortFurnitures = function(a, b)
    return a.TemplateId < b.TemplateId
end

--==============================--
--desc: 通用道具奖励排序
--==============================--
local SortItems = function(a, b)
    local tmpId1 = a.TemplateId and a.TemplateId or a.Id
    local tmpId2 = b.TemplateId and b.TemplateId or b.Id

    local quality1 = XDataCenter.ItemManager.GetItemQuality(tmpId1)
    local quality2 = XDataCenter.ItemManager.GetItemQuality(tmpId2)

    if quality1 ~= quality2 then
        return quality1 > quality2
    end

    local priority1 = XDataCenter.ItemManager.GetItemPriority(tmpId1)
    local priority2 = XDataCenter.ItemManager.GetItemPriority(tmpId2)

    if priority1 ~= priority2 then
        return priority1 > priority2
    end

    return tmpId1 > tmpId2
end

--==============================--
--desc: 通用头像奖励排序
--==============================--
local SortHeadPortraits = function(a, b)
    return a.TemplateId > b.TemplateId
end

local SortDormCharacter = function(a, b)
    return a.TemplateId > b.TemplateId
end

local SortRewardTypePrioriy = {
    [XRewardType.Item] = 1,
    [XRewardType.Character] = 4,
    [XRewardType.Equip] = 2,
    [XRewardType.Fashion] = 3,
    [XRewardType.BaseEquip] = 5,
    [XRewardType.Furniture] = 9,
    [XRewardType.HeadPortrait] = 10,
    [XRewardType.DormCharacter] = 11,
}

local SortFunc = {
    [XRewardType.Item] = SortItems,
    [XRewardType.Character] = SortCharacters,
    [XRewardType.Equip] = SortEquips,
    [XRewardType.Fashion] = SortFashions,
    [XRewardType.BaseEquip] = SortBaseEquips,
    [XRewardType.Furniture] = SortFurnitures,
    [XRewardType.HeadPortrait] = SortHeadPortraits,
    [XRewardType.DormCharacter] = SortDormCharacter,
}

--==============================--
--desc: 奖励排序
--@rewardGoodsList: 奖励列表
--@return 排序后列表
--==============================--
local function SortRewardGoodsList(rewardGoodsList)
    if not rewardGoodsList then
        XLog.Warning("XRewardManager.SortRewardGoodsList: rewardGoodsList is nil")
        return
    end

    tableSort(rewardGoodsList, function(a, b)
        local rewardType1, rewardType2 = a.RewardType, b.RewardType

        if rewardType1 ~= rewardType2 then
            return SortRewardTypePrioriy[rewardType1] > SortRewardTypePrioriy[rewardType2]
        end

        return SortFunc[rewardType1](a, b)
    end)

    return rewardGoodsList
end

--==============================--
--desc: 合并相同奖励
--@rewardGoodsList: 奖励列表
--@return 合并列表
--==============================--
local function MergeRewardGoodsList(rewardGoodsList)
    if not rewardGoodsList then
        XLog.Warning("XRewardManager.MergeRewardGoodsList: rewardGoodsList is nil")
        return
    end

    local mergeList = {}
    local mergeDict = {}

    for _, goods in pairs(rewardGoodsList) do
        if goods.RewardType == XRewardType.Character or
        goods.RewardType == XRewardType.Equip then
            tableInsert(mergeList, goods)
        else
            local oldGoods = mergeDict[goods.TemplateId]

            if oldGoods then
                mergeDict[goods.TemplateId].Count = mergeDict[goods.TemplateId].Count + goods.Count
            else
                mergeDict[goods.TemplateId] = CloneRewardGoods(goods)
            end
        end
    end

    for _, goods in pairs(mergeDict) do
        tableInsert(mergeList, goods)
    end

    return mergeList
end

--==============================--
--desc: 奖励合并排序
--@rewardGoodsList: 奖励列表
--@return 处理完列表
--==============================--
local function MergeAndSortRewardGoodsList(rewardGoodsList)
    if not rewardGoodsList then
        XLog.Warning("XRewardManager.MergeAndSortRewardGoodsList: rewardGoodsList is nil")
        return
    end

    return SortRewardGoodsList(MergeRewardGoodsList(rewardGoodsList))
end

function XRewardManager.Init()
    local rewardTable = XTableManager.ReadByIntKey(TABLE_REWARD_PATH, XTable.XTableReward, "Id")
    local rewardGoodsTable = XTableManager.ReadByIntKey(TABLE_REWARD_GOODS_PATH, XTable.XTableRewardGoods, "Id")

    for k, v in pairs(rewardTable) do
        local list = {}
        for _, id in pairs(v.SubIds) do
            local tab = rewardGoodsTable[id]
            if not tab then
                XLog.Error("XRewardManager.Init error: can not found reward, id = " .. id)
                return
            end
            tableInsert(list, XRewardManager.CreateRewardGoodsByTemplate(tab))
        end

        RewardSubIds[k] = v.SubIds
        RewardTemplates[k] = list
    end

    RewardTemplates = XReadOnlyTable.Create(RewardTemplates)
    RewardSubIds = XReadOnlyTable.Create(RewardSubIds)
end

function XRewardManager.GetRewardSubId(id, index)
    local rewardSubIds = RewardSubIds[id]
    if not rewardSubIds then
        XLog.Error("XRewardManager.GetRewardSubId error: can not found SubIds, id is " .. id)
        return
    end

    return rewardSubIds[index]
end

function XRewardManager.GetRewardList(id)
    local rewardList = RewardTemplates[id]
    if not rewardList then
        XLog.Error("XRewardManager.GetRewardList error: can not found reward, id is " .. id)
        return
    end

    return rewardList
end

function XRewardManager.GetRewardListNotCount(id)
    local rewardList = RewardTemplates[id]
    local rewardNotCountList = {}
    if not rewardList then
        XLog.Error("XRewardManager.GetRewardList error: can not found reward, id is " .. id)
        return
    end
    
    for Id,Val in pairs(rewardList) do
        local tmpList = {}
        for k,v in pairs(Val) do
            if k ~= "Count" then
                tmpList[k] = v
            end
        end
        table.insert(rewardNotCountList,tmpList)
    end
    return rewardNotCountList
end

XRewardManager.XRewardType = XRewardType
XRewardManager.CreateRewardGoodsByTemplate = CreateRewardGoodsByTemplate
XRewardManager.CreateRewardGoods = CreateRewardGoods
XRewardManager.SortRewardGoodsList = SortRewardGoodsList
XRewardManager.MergeAndSortRewardGoodsList = MergeAndSortRewardGoodsList