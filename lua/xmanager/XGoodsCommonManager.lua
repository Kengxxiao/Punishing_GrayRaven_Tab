local type = type

XGoodsCommonManager = XGoodsCommonManager or {}

XGoodsCommonManager.QualityType = {
    White = 1,
    Greed = 2,
    Blue = 3,
    Purple = 4,
    Gold = 5,
    Red = 6,
    Red1 = 7
}


local GoodsName = {
    [XArrangeConfigs.Types.Item] = function(templateId)
        return XDataCenter.ItemManager.GetItemName(templateId)
    end,

    [XArrangeConfigs.Types.Character] = function(templateId)
        return XCharacterConfigs.GetCharacterName(templateId)
    end,

    [XArrangeConfigs.Types.Weapon] = function(templateId)
        return XDataCenter.EquipManager.GetEquipName(templateId)
    end,

    [XArrangeConfigs.Types.Wafer] = function(templateId)
        return XDataCenter.EquipManager.GetEquipName(templateId)
    end,

    [XArrangeConfigs.Types.Fashion] = function(templateId)
        return XDataCenter.FashionManager.GetFashionName(templateId)
    end,

    [XArrangeConfigs.Types.BaseEquip] = function(templateId)
        return XDataCenter.BaseEquipManager.GetBaseEquipName(templateId)
    end,

    [XArrangeConfigs.Types.Furniture] = function(templateId)
        return XFurnitureConfigs.GetFurnitureNameById(templateId)
    end
}

local GoodsQuality = {
    [XArrangeConfigs.Types.Item] = function(templateId)
        return XDataCenter.ItemManager.GetItemQuality(templateId)
    end,

    [XArrangeConfigs.Types.Character] = function(templateId)
        return XGoodsCommonManager.QualityType.Gold
    end,

    [XArrangeConfigs.Types.Weapon] = function(templateId)
        return XDataCenter.EquipManager.GetEquipQuality(templateId)
    end,

    [XArrangeConfigs.Types.Wafer] = function(templateId)
        return XDataCenter.EquipManager.GetEquipQuality(templateId)
    end,

    [XArrangeConfigs.Types.Fashion] = function(templateId)
        return XDataCenter.FashionManager.GetFashionQuality(templateId)
    end,

    [XArrangeConfigs.Types.BaseEquip] = function(templateId)
        return XDataCenter.BaseEquipManager.GetBaseEquipQuality(templateId)
    end
}

local GoodsIcon = {
    [XArrangeConfigs.Types.Item] = function(templateId)
        return XDataCenter.ItemManager.GetItemIcon(templateId)
    end,

    [XArrangeConfigs.Types.Character] = function(templateId)
        return XDataCenter.CharacterManager.GetCharRoundnessHeadIcon(templateId)
    end,

    [XArrangeConfigs.Types.Weapon] = function(templateId)
        return XDataCenter.EquipManager.GetEquipIconPath(templateId)
    end,

    [XArrangeConfigs.Types.Wafer] = function(templateId)
        return XDataCenter.EquipManager.GetEquipIconPath(templateId)
    end,

    [XArrangeConfigs.Types.Fashion] = function(templateId)
        return XDataCenter.FashionManager.GetFashionIcon(templateId)
    end,

    [XArrangeConfigs.Types.BaseEquip] = function(templateId)
        return XDataCenter.BaseEquipManager.GetBaseEquipIcon(templateId)
    end,

    [XArrangeConfigs.Types.Furniture] = function(templateId)
        return XFurnitureConfigs.GetFurnitureIconById(templateId)
    end
}

local GoodsDescription = {
    [XArrangeConfigs.Types.Item] = function(templateId)
        return XDataCenter.ItemManager.GetItemDescription(templateId)
    end,

    [XArrangeConfigs.Types.Character] = function(templateId)
        return XCharacterConfigs.GetCharacterIntro(templateId)
    end,

    [XArrangeConfigs.Types.Fashion] = function(templateId)
        return XDataCenter.FashionManager.GetFashionDesc(templateId)
    end,

    [XArrangeConfigs.Types.Weapon] = function(templateId)
        return XDataCenter.EquipManager.GetEquipDescription(templateId)
    end,

    [XArrangeConfigs.Types.Wafer] = function(templateId)
        return XDataCenter.EquipManager.GetEquipDescription(templateId)
    end,

    [XArrangeConfigs.Types.BaseEquip] = function(templateId)
        return XDataCenter.BaseEquipManager.GetBaseEquipDesc(templateId)
    end,

    [XArrangeConfigs.Types.Furniture] = function(templateId)
        return XFurnitureConfigs.GetFurnitureDescriptionById(templateId)
    end,
    
    [XArrangeConfigs.Types.HeadPortrait] = function(templateId)
        return XPlayerManager.GetHeadPortraitDescriptionById(templateId)
    end,
}

local GoodsWorldDesc = {
    [XArrangeConfigs.Types.Item] = function(templateId)
        return XDataCenter.ItemManager.GetItemWorldDesc(templateId)
    end,
    
    [XArrangeConfigs.Types.Fashion] = function(templateId)
        return XDataCenter.FashionManager.GetFashionWorldDescription(templateId)
    end,
    
    [XArrangeConfigs.Types.HeadPortrait] = function(templateId)
        return XPlayerManager.GetHeadPortraitWorldDescById(templateId)
    end,
}

local GoodsSkipIdParams = {
    [XArrangeConfigs.Types.Item] = function(templateId)
        return XDataCenter.ItemManager.GetItemSkipIdParams(templateId)
    end,

    [XArrangeConfigs.Types.Fashion] = function(templateId)
        return XDataCenter.FashionManager.GetFashionSkipIdParams(templateId)
    end,
}

local GoodsCurrentCount = {
    [XArrangeConfigs.Types.Item] = function(templateId)
        local item = XDataCenter.ItemManager.GetItem(templateId)
        return item and item:GetCount() or 0
    end,

    [XArrangeConfigs.Types.Character] = function(templateId)
        return XDataCenter.CharacterManager.IsOwnCharacter(templateId) and 1 or 0
    end,

    [XArrangeConfigs.Types.Weapon] = function(templateId)
        return XDataCenter.EquipManager.GetEquipCount(templateId)
    end,

    [XArrangeConfigs.Types.Wafer] = function(templateId)
        return XDataCenter.EquipManager.GetEquipCount(templateId)
    end,

    [XArrangeConfigs.Types.Fashion] = function (templateId)
        return XDataCenter.FashionManager.CheckHasFashion(templateId) and 1 or 0
    end,

    [XArrangeConfigs.Types.BaseEquip] = function(templateId)
        return XDataCenter.BaseEquipManager.GetBaseEquipCount(templateId)
    end,

    [XArrangeConfigs.Types.Furniture] = function(templateId)
        return XDataCenter.FurnitureManager.GetTemplateCount(templateId)
    end
}

--==============================--
--desc: 通用物品名字获取
--@templateId: 配置表id
--@return 物品名
--==============================--
function XGoodsCommonManager.GetGoodsName(templateId)
    local arrangeType = XArrangeConfigs.GetType(templateId)
    return GoodsName[arrangeType] and GoodsName[arrangeType](templateId) or nil
end

--==============================--
--desc: 通用物品默认品质
--@templateId: 配置表id
--@return 物品品质
--==============================--
function XGoodsCommonManager.GetGoodsDefaultQuality(templateId)
    local arrangeType = XArrangeConfigs.GetType(templateId)
    return GoodsQuality[arrangeType] and GoodsQuality[arrangeType](templateId) or nil
end

--==============================--
--desc: 通用物品Icon
--@templateId: 配置表id
--@args: 额外参数
--@return 物品Icon
--==============================--
function XGoodsCommonManager.GetGoodsIcon(templateId)
    local arrangeType = XArrangeConfigs.GetType(templateId)
    return GoodsIcon[arrangeType] and GoodsIcon[arrangeType](templateId) or nil
end

--==============================--
--desc: 通用物品描述
--@templateId: 配置表id
--@return 物品描述
--==============================--
function XGoodsCommonManager.GetGoodsDescription(templateId)
    local arrangeType = XArrangeConfigs.GetType(templateId)
    return GoodsDescription[arrangeType] and GoodsDescription[arrangeType](templateId) or nil
end

--==============================--
--desc: 通用物品世界观描述
--@templateId: 配置表id
--@return 世界观描述
--==============================--
function XGoodsCommonManager.GetGoodsWorldDesc(templateId)
    local arrangeType = XArrangeConfigs.GetType(templateId)
    return GoodsWorldDesc[arrangeType] and GoodsWorldDesc[arrangeType](templateId) or nil
end

--==============================--
--desc: 通用物品跳转列表
--@templateId: 配置表id
--@return 跳转列表
--==============================--
function XGoodsCommonManager.GetGoodsSkipIdParams(templateId)
    local arrangeType = XArrangeConfigs.GetType(templateId)
    return GoodsSkipIdParams[arrangeType] and GoodsSkipIdParams[arrangeType](templateId) or nil
end

--==============================--
--desc: 通用物品当前数量
--@templateId: 配置表id
--@return 当前数量
--==============================--
function XGoodsCommonManager.GetGoodsCurrentCount(templateId)
    local arrangeType = XArrangeConfigs.GetType(templateId)
    return GoodsCurrentCount[arrangeType] and GoodsCurrentCount[arrangeType](templateId) or 0
end

local GoodsShowParams = {}

GoodsShowParams[XArrangeConfigs.Types.Item] = function(templateId)
    return {
        RewardType = XRewardManager.XRewardType.Item,
        TemplateId = templateId,
        Name = XDataCenter.ItemManager.GetItemName(templateId),
        Quality = XDataCenter.ItemManager.GetItemQuality(templateId),
        Icon = XDataCenter.ItemManager.GetItemIcon(templateId),
        BigIcon = XDataCenter.ItemManager.GetItemBigIcon(templateId)
    }
end

GoodsShowParams[XArrangeConfigs.Types.Character] = function(templateId)
    local quality = XCharacterConfigs.GetCharMinQuality(templateId)

    return {
        RewardType = XRewardManager.XRewardType.Character,
        TemplateId = templateId,
        Name = XCharacterConfigs.GetCharacterName(templateId),
        TradeName = XCharacterConfigs.GetCharacterTradeName(templateId),
        Quality = quality,
        QualityIcon = XCharacterConfigs.GetCharQualityIconGoods(quality),
        Icon = XDataCenter.CharacterManager.GetCharRoundnessHeadIcon(templateId),
        BigIcon = XDataCenter.CharacterManager.GetCharBigRoundnessHeadIcon(templateId),
        
    }
end

GoodsShowParams[XArrangeConfigs.Types.Weapon] = function(templateId)
    local quality = XDataCenter.EquipManager.GetEquipQuality(templateId)

    return {
        RewardType = XRewardManager.XRewardType.Equip,
        TemplateId = templateId,
        Name = XDataCenter.EquipManager.GetEquipName(templateId),
        Quality = quality,
        QualityTag = quality > XGoodsCommonManager.QualityType.Gold,
        Star = XDataCenter.EquipManager.GetEquipStar(templateId),
        Site = XDataCenter.EquipManager.GetEquipSiteByTemplateId(templateId),
        Icon = XDataCenter.EquipManager.GetEquipIconPath(templateId),
        BigIcon = XDataCenter.EquipManager.GetEquipBigIconPath(templateId)
    }
end

GoodsShowParams[XArrangeConfigs.Types.Wafer] = GoodsShowParams[XArrangeConfigs.Types.Weapon]

GoodsShowParams[XArrangeConfigs.Types.Fashion] = function(templateId)
    return {
        RewardType = XRewardManager.XRewardType.Fashion,
        TemplateId = templateId,
        Count = 1,
        Name = XDataCenter.FashionManager.GetFashionName(templateId),
        Quality = XDataCenter.FashionManager.GetFashionQuality(templateId),
        Icon = XDataCenter.FashionManager.GetFashionIcon(templateId),
        BigIcon = XDataCenter.FashionManager.GetFashionBigIcon(templateId)
    }
end

GoodsShowParams[XArrangeConfigs.Types.BaseEquip] = function(templateId)
    return {
        RewardType = XRewardManager.XRewardType.BaseEquip,
        TemplateId = templateId,
        Name = XDataCenter.BaseEquipManager.GetBaseEquipName(templateId),
        Quality = XDataCenter.BaseEquipManager.GetBaseEquipQuality(templateId),
        Icon = XDataCenter.BaseEquipManager.GetBaseEquipIcon(templateId),
        BigIcon = XDataCenter.BaseEquipManager.GetBaseEquipBigIcon(templateId)
    }
end

GoodsShowParams[XArrangeConfigs.Types.Furniture] = function(templateId)
    local cfg = XFurnitureConfigs.GetFurnitureReward(templateId)
    if cfg and cfg.FurnitureId then
        return {
            RewardType = XRewardManager.XRewardType.Furniture,
            TemplateId = cfg.FurnitureId,
            Name = XFurnitureConfigs.GetFurnitureNameById(cfg.FurnitureId),
            Icon = XFurnitureConfigs.GetFurnitureIconById(cfg.FurnitureId),
            BigIcon = XFurnitureConfigs.GetFurnitureBigIconById(cfg.FurnitureId),
        }
    end
end

GoodsShowParams[XArrangeConfigs.Types.HeadPortrait] = function(templateId)
    return {
        RewardType = XRewardManager.XRewardType.HeadPortrait,
        TemplateId = templateId,
        Name = XPlayerManager.GetHeadPortraitNameById(templateId),
        Icon = XPlayerManager.GetHeadPortraitImgSrcById(templateId),
        BigIcon = XPlayerManager.GetHeadPortraitImgSrcById(templateId),
        Effect = XPlayerManager.GetHeadPortraitEffectById(templateId),
    }
end

--==============================--
--desc: 通用物品展示参数
--@templateId: 配置表id
--@return 物品展示参数
--==============================--
function XGoodsCommonManager.GetGoodsShowParamsByTemplateId(templateId)
    local arrangeType = XArrangeConfigs.GetType(templateId)

    if not GoodsShowParams[arrangeType] then
        XLog.Error("XGoodsCommonManager.GetGoodsShowParamsByTemplateId error: goods type is nonsupport, arrangeType is " .. arrangeType .. " templateId is " .. templateId)
        return
    end

    return GoodsShowParams[arrangeType](templateId)
end