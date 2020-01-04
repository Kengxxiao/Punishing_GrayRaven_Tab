local tableSort = table.sort
local tableInsert = table.insert
local mathMin = math.min
local stringFormat = string.format

XEquipConfig = XEquipConfig or {}

XEquipConfig.MAX_STAR_COUNT = 6                 -- 最大星星数
XEquipConfig.MAX_SUIT_SKILL_COUNT = 3           -- 最大套装激活技能个数
XEquipConfig.MAX_RESONANCE_SKILL_COUNT = 3      -- 最大共鸣属性/技能个数
XEquipConfig.MIN_RESONANCE_EQUIP_STAR_COUNT = 5 -- 装备共鸣最低星级
XEquipConfig.MAX_SUIT_COUNT = 6                 -- 套装最大数量
XEquipConfig.DEFAULT_SUIT_ID = 1                -- 用来显示全部套装数量的默认套装Id
XEquipConfig.CAN_NOT_AUTO_EAT_STAR = 5          -- 大于等于该星级的装备不会被当做默认狗粮选中

--武器类型
XEquipConfig.EquipType = {
    Universal = 0, -- 通用
    Suncha = 1, -- 双枪
    Sickle = 2, -- 太刀
    Mount = 3, -- 挂载
    Arrow = 4, -- 弓箭
    Chainsaw = 5, -- 电锯
    Sword = 6, -- 大剑
    Hcan = 7, -- 巨炮
    DoubleSwords = 8, -- 双短刀
    Food = 99, -- 狗粮
}

XEquipConfig.AddAttrType = {
    Numeric = 1, -- 数值
    Rate = 2, -- 基础属性的百分比
    Promoted = 3, -- 等级加成
}

--要显示的属性排序
XEquipConfig.AttrSortType = {
    XNpcAttribType.Life,
    XNpcAttribType.AttackNormal,
    XNpcAttribType.DefenseNormal,
    XNpcAttribType.Crit,
}

XEquipConfig.EquipSite = {
    Weapon = 0, -- 武器
    Awareness = { -- 意识
        One = 1, -- 1号位
        Two = 2, -- 2号位
        Three = 3, -- 3号位
        Four = 4, -- 4号位
        Five = 5, -- 5号位
        Six = 6, -- 6号位
    },
}

XEquipConfig.Classify = {
    Weapon = 1, -- 武器
    Awareness = 2, -- 意识
}

XEquipConfig.EquipResonanceType = {
    Attrib = 1, -- 属性共鸣
    CharacterSkill = 2, -- 角色技能共鸣
    WeaponSkill = 3, -- 武器技能共鸣
}

--排序优先级选项
XEquipConfig.PriorSortType = {
    Star = 0, -- 星级
    Breakthrough = 1, -- 突破次数
    Level = 2, -- 等级
    Proceed = 3, -- 入手顺序
}

local EquipBreakThroughIcon = {
    [0] = CS.XGame.ClientConfig:GetString("EquipBreakThrough0"),
    [1] = CS.XGame.ClientConfig:GetString("EquipBreakThrough1"),
    [2] = CS.XGame.ClientConfig:GetString("EquipBreakThrough2"),
    [3] = CS.XGame.ClientConfig:GetString("EquipBreakThrough3"),
    [4] = CS.XGame.ClientConfig:GetString("EquipBreakThrough4"),
}

local EquipBreakThroughSmallIcon = {
    [1] = CS.XGame.ClientConfig:GetString("EquipBreakThroughSmall1"),
    [2] = CS.XGame.ClientConfig:GetString("EquipBreakThroughSmall2"),
    [3] = CS.XGame.ClientConfig:GetString("EquipBreakThroughSmall3"),
    [4] = CS.XGame.ClientConfig:GetString("EquipBreakThroughSmall4"),
}

local EquipBreakThroughBigIcon = {
    [0] = CS.XGame.ClientConfig:GetString("EquipBreakThroughBig0"),
    [1] = CS.XGame.ClientConfig:GetString("EquipBreakThroughBig1"),
    [2] = CS.XGame.ClientConfig:GetString("EquipBreakThroughBig2"),
    [3] = CS.XGame.ClientConfig:GetString("EquipBreakThroughBig3"),
    [4] = CS.XGame.ClientConfig:GetString("EquipBreakThroughBig4"),
}

local EquipQualityBgPath = {
    [1] = CS.XGame.Config:GetString("QualityIconColor1"),
    [2] = CS.XGame.Config:GetString("QualityIconColor2"),
    [3] = CS.XGame.Config:GetString("QualityIconColor3"),
    [4] = CS.XGame.Config:GetString("QualityIconColor4"),
    [5] = CS.XGame.Config:GetString("QualityIconColor5"),
    [6] = CS.XGame.Config:GetString("QualityIconColor6"),
    [7] = CS.XGame.Config:GetString("QualityIconColor7"),
}

local TABLE_EQUIP_PATH = "Share/Equip/Equip.tab"
local TABLE_EQUIP_BREAKTHROUGH_PATH = "Share/Equip/EquipBreakThrough.tab"
local TABLE_EQUIP_SUIT_PATH = "Share/Equip/EquipSuit.tab"
local TABLE_EQUIP_SUIT_EFFECT_PATH = "Share/Equip/EquipSuitEffect.tab"
local TABLE_LEVEL_UP_TEMPLATE_PATH = "Share/Equip/LevelUpTemplate/"
local TABLE_EQUIP_DECOMPOSE_PATH = "Share/Equip/EquipDecompose.tab"
local TABLE_EAT_EQUIP_COST_PATH = "Share/Equip/EatEquipCost.tab"
local TABLE_EQUIP_RESONANCE_PATH = "Share/Equip/EquipResonance.tab"
local TABLE_EQUIP_RESONANCE_CONSUME_ITEM_PATH = "Share/Equip/EquipResonanceUseItem.tab"
local TABLE_WEAPON_SKILL_PATH = "Share/Equip/WeaponSkill.tab"
local TABLE_WEAPON_SKILL_POOL_PATH = "Share/Equip/WeaponSkillPool.tab"
local TABLE_EQUIP_RES_PATH = "Client/Equip/EquipRes.tab"
local TABLE_EQUIP_MODEL_PATH = "Client/Equip/EquipModel.tab"
local TABLE_EQUIP_MODEL_TRANSFORM_PATH = "Client/Equip/EquipModelTransform.tab"
local TABLE_EQUIP_SKIPID_PATH = "Client/Equip/EquipSkipId.tab"

local MAX_WEAPON_COUNT                      -- 武器拥有最大数量
local MAX_AWARENESS_COUNT                   -- 意识拥有最大数量
local EQUIP_EXP_INHERIT_PRECENT             -- 强化时的经验继承百分比
local MIN_RESONANCE_BIND_STAR               -- 只有6星以上的意识才可以共鸣出绑定角色的技能

local EquipTemplates = {}                       -- 装备配置
local EquipBreakthroughTemplate = {}            -- 突破配置
local EquipResonanceTemplate = {}               -- 共鸣配置
local EquipResonanceConsumeItemTemplates = {}   -- 共鸣消耗物品配置
local LevelUpTemplates = {}                     -- 升级模板
local EquipSuitTemplate = {}                    -- 套装技能表
local EquipSuitEffectTemplate = {}              -- 套装效果表
local WeaponSkillTemplate = {}                  -- 武器技能配置
local WeaponSkillPoolTemplate = {}              -- 武器技能池（共鸣用）配置
local EatEquipCostTemplate = {}                 -- 装备强化消耗配置
local EquipResTemplates = {}                    -- 装备资源配置
local EquipModelTemplates = {}                  -- 武器模型配置
local EquipModelTranformTemplates = {}          -- 武器模型UI偏移配置
local EquipSkipIdTemplates = {}                 -- 装备来源跳转ID配置

local EquipBorderDic = {}                   -- 装备边界属性构造字典
local EquipDecomposeDic = {}
local SuitIdToEquipTemplateIdsDic = {}      -- 套装Id索引的装备Id字典                
local SuitSitesDic = {}                     -- 套装产出部位字典                

local CompareBreakthrough = function(templateId, breakthrough)
    local template = EquipBorderDic[templateId]
    if not template then
        return
    end

    if not template.MaxBreakthrough or template.MaxBreakthrough < breakthrough then
        template.MaxBreakthrough = breakthrough
    end
end

local CheckEquipBorderConfig = function()
    for k, v in pairs(EquipBorderDic) do
        local template = EquipBorderDic[k]
        template.MinLevel = 1
        local equipBreakthroughCfg = XEquipConfig.GetEquipBreakthroughCfg(k, v.MaxBreakthrough)
        template.MaxLevel = equipBreakthroughCfg.LevelLimit
        template.MinBreakthrough = 0
    end
end

local InitEquipBreakthroughConfig = function()
    local tab = XTableManager.ReadByIntKey(TABLE_EQUIP_BREAKTHROUGH_PATH, XTable.XTableEquipBreakthrough, "Id")
    for _, config in pairs(tab) do
        if not EquipBreakthroughTemplate[config.EquipId] then
            EquipBreakthroughTemplate[config.EquipId] = {}
        end

        if config.AttribPromotedId == 0 then
            XLog.Error("XEquipConfig.InitEquipBreakthroughConfig error: AttribPromotedId can not be 0, path is " .. TABLE_EQUIP_BREAKTHROUGH_PATH)
        end

        EquipBreakthroughTemplate[config.EquipId][config.Times] = config
        CompareBreakthrough(config.EquipId, config.Times)
    end
end

local InitEquipLevelConfig = function()
    local paths = CS.XTableManager.GetPaths(TABLE_LEVEL_UP_TEMPLATE_PATH)
    XTool.LoopCollection(paths, function(path)
        local key = tonumber(XTool.GetFileNameWithoutExtension(path))
        LevelUpTemplates[key] = XTableManager.ReadByIntKey(path, XTable.XTableEquipLevelUp, "Level")
    end)
end

local InitWeaponSkillPoolConfig = function()
    local tab = XTableManager.ReadByIntKey(TABLE_WEAPON_SKILL_POOL_PATH, XTable.XTableWeaponSkillPool, "Id")
    for _, config in pairs(tab) do
        WeaponSkillPoolTemplate[config.PoolId] = WeaponSkillPoolTemplate[config.PoolId] or {}
        WeaponSkillPoolTemplate[config.PoolId][config.CharacterId] = WeaponSkillPoolTemplate[config.PoolId][config.CharacterId] or {}
        tableInsert(WeaponSkillPoolTemplate[config.PoolId][config.CharacterId], config.SkillId)
    end
end

local InitEquipModelTransformConfig = function()
    local tab = XTableManager.ReadByIntKey(TABLE_EQUIP_MODEL_TRANSFORM_PATH, XTable.XTableEquipModelTransform, "Id")
    for id, config in pairs(tab) do
        local indexId = config.IndexId
        if not indexId then
            XLog.Error("XEquipConfig InitEquipModelTransformConfig error: IndexId is nil,path is:" .. TABLE_EQUIP_MODEL_TRANSFORM_PATH .. "id is:" .. id)
        end
        EquipModelTranformTemplates[indexId] = EquipModelTranformTemplates[indexId] or {}

        local uiName = config.UiName
        if not uiName then
            XLog.Error("XEquipConfig InitEquipModelTransformConfig error: UiName is nil,path is:" .. TABLE_EQUIP_MODEL_TRANSFORM_PATH .. "id is:" .. id)
        end
        EquipModelTranformTemplates[indexId][uiName] = config
    end
end

local InitEquipSkipIdConfig = function()
    local tab = XTableManager.ReadByIntKey(TABLE_EQUIP_SKIPID_PATH, XTable.XTableEquipSkipId, "Id")
    for id, config in pairs(tab) do
        local site = config.Site
        if not site then
            XLog.Error("XEquipConfig InitEquipSkipIdConfig error: IndexId is nil,path is:" .. TABLE_EQUIP_SKIPID_PATH .. "id is:" .. id)
        end
        EquipSkipIdTemplates[site] = config
    end
end

local InitEquipSuitConfig = function()
    EquipSuitTemplate = XTableManager.ReadByIntKey(TABLE_EQUIP_SUIT_PATH, XTable.XTableEquipSuit, "Id")
    EquipSuitEffectTemplate = XTableManager.ReadByIntKey(TABLE_EQUIP_SUIT_EFFECT_PATH, XTable.XTableEquipSuitEffect, "Id")
end

function XEquipConfig.Init()
    MAX_WEAPON_COUNT = CS.XGame.Config:GetInt("EquipWeaponMaxCount")
    MAX_AWARENESS_COUNT = CS.XGame.Config:GetInt("EquipChipMaxCount")
    EQUIP_EXP_INHERIT_PRECENT = CS.XGame.Config:GetInt("EquipExpInheritPercent")
    MIN_RESONANCE_BIND_STAR = CS.XGame.Config:GetInt("MinResonanceBindStar")

    EquipTemplates = XTableManager.ReadByIntKey(TABLE_EQUIP_PATH, XTable.XTableEquip, "Id")
    EquipResTemplates = XTableManager.ReadByIntKey(TABLE_EQUIP_RES_PATH, XTable.XTableEquipRes, "Id")

    for id, equipCfg in pairs(EquipTemplates) do
        EquipBorderDic[id] = {}

        local suitId = equipCfg.SuitId
        if suitId and suitId > 0 then
            SuitIdToEquipTemplateIdsDic[suitId] = SuitIdToEquipTemplateIdsDic[suitId] or {}
            tableInsert(SuitIdToEquipTemplateIdsDic[suitId], id)

            SuitSitesDic[suitId] = SuitSitesDic[suitId] or {}
            SuitSitesDic[suitId][equipCfg.Site] = true
        end
    end

    InitEquipSuitConfig()
    InitEquipBreakthroughConfig()
    InitEquipLevelConfig()
    InitWeaponSkillPoolConfig()
    InitEquipModelTransformConfig()
    InitEquipSkipIdConfig()

    CheckEquipBorderConfig()

    EquipBorderDic = XReadOnlyTable.Create(EquipBorderDic)
    WeaponSkillTemplate = XTableManager.ReadByIntKey(TABLE_WEAPON_SKILL_PATH, XTable.XTableWeaponSkill, "Id")
    EquipResonanceTemplate = XTableManager.ReadByIntKey(TABLE_EQUIP_RESONANCE_PATH, XTable.XTableEquipResonance, "Id")
    EquipResonanceConsumeItemTemplates = XTableManager.ReadByIntKey(TABLE_EQUIP_RESONANCE_CONSUME_ITEM_PATH, XTable.XTableEquipResonanceUseItem, "Id")
    EquipModelTemplates = XTableManager.ReadByIntKey(TABLE_EQUIP_MODEL_PATH, XTable.XTableEquipModel, "Id")

    local decomposetab = XTableManager.ReadByIntKey(TABLE_EQUIP_DECOMPOSE_PATH, XTable.XTableEquipDecompose, "Id")
    for k, v in pairs(decomposetab) do
        EquipDecomposeDic[v.Site .. v.Star .. v.Breakthrough] = v
    end

    local eatCostTab = XTableManager.ReadByIntKey(TABLE_EAT_EQUIP_COST_PATH, XTable.XTableEatEquipCost, "Id")
    for k, v in pairs(eatCostTab) do
        EatEquipCostTemplate[v.Site .. v.Star] = v.UseMoney
    end
end

function XEquipConfig.GetMaxWeaponCount()
    return MAX_WEAPON_COUNT
end

function XEquipConfig.GetMaxAwarenessCount()
    return MAX_AWARENESS_COUNT
end

function XEquipConfig.GetEquipExpInheritPercent()
    return EQUIP_EXP_INHERIT_PRECENT
end

function XEquipConfig.GetMinResonanceBindStar()
    return MIN_RESONANCE_BIND_STAR
end

function XEquipConfig.GetEquipCfg(templateId)
    local equipCfg = EquipTemplates[templateId]
    if not equipCfg then
        XLog.Error("XEquipConfig.GetEquipCfg error: can not find equipCfg, templateId is " .. templateId)
        return
    end
    return equipCfg
end

--todo 道具很多地方没有检查ID类型就调用了，临时处理下
function XEquipConfig.CheckTemplateIdIsEquip(templateId)
    return templateId and EquipTemplates[templateId]
end

function XEquipConfig.GetEatEquipCostMoney(site, star)
    if not site then
        XLog.Error("XEquipConfig.GetEatEquipCostMoney error: site is nil")
        return
    end
    if not star then
        XLog.Error("XEquipConfig.GetEatEquipCostMoney error: star is nil")
        return
    end

    return EatEquipCostTemplate[site .. star]
end

function XEquipConfig.GetEquipBorderCfg(templateId)
    local template = EquipBorderDic[templateId]
    if not template then
        XLog.Error("XEquipConfig.GetEquipBorderCfg error: can not find template, templateId is " .. templateId)
        return
    end
    return template
end

function XEquipConfig.GetEquipBreakthroughCfg(templateId, times)
    local template = EquipBreakthroughTemplate[templateId]
    if not template then
        XLog.Error("XEquipConfig.GetEquipBreakthroughCfg error: can not find template, templateId is " .. templateId)
        return
    end

    template = template[times]
    if not template then
        XLog.Error("XEquipConfig.GetEquipBreakthroughCfg error: can not find template, times is " .. times)
        return
    end

    return template
end

function XEquipConfig.GetEquipResCfg(templateId, breakthroughTimes)
    breakthroughTimes = breakthroughTimes or 0
    local breakthroughCfg = XEquipConfig.GetEquipBreakthroughCfg(templateId, breakthroughTimes)

    local resId = breakthroughCfg.ResId
    if not resId then
        XLog.Error("XEquipConfig.GetEquipResCfg error: can not find resId, templateId is " .. templateId)
        return
    end

    local template = EquipResTemplates[resId]
    if not template then
        XLog.Error("XEquipConfig.GetEquipResCfg error: can not find template, resId is " .. resId)
        return
    end

    return template
end

function XEquipConfig.GetEquipModelName(modelTransId)
    local template = EquipModelTemplates[modelTransId]

    if not template then
        XLog.Error("XEquipConfig.GetEquipModelName error: can not find template, templateId is " .. modelTransId)
        return
    end

    return template.ModelName
end

--返回武器模型和位置配置（双枪只返回一把）
function XEquipConfig.GetEquipModelTransformCfg(templateId, uiName)
    local modelCfg, template

    --尝试用ModelTransId索引
    local resCfg = XEquipConfig.GetEquipResCfg(templateId)
    local modelTransId = resCfg.ModelTransId[1]
    if not modelTransId then
        XLog.Error("XEquipConfig.GetEquipModelTransformCfg error: can not find ModelTransId, templateId is " .. templateId)
        return
    end

    template = EquipModelTranformTemplates[modelTransId]
    if template then
        modelCfg = template[uiName]
    end

    --读不到配置时用equipType索引
    if not modelCfg then
        local equipCfg = XEquipConfig.GetEquipCfg(templateId)
        local equiptype = equipCfg.Type

        template = EquipModelTranformTemplates[equiptype]
        if not template then
            XLog.Error("XEquipConfig.GetEquipModelTransformCfg error: can not find template, equiptype is " .. equiptype)
            return
        end

        modelCfg = template[uiName]
        if not modelCfg then
            XLog.Error("XEquipConfig.GetEquipModelTransformCfg error: can not find modelCfg, uiName is " .. uiName)
            return
        end
    end

    return modelCfg
end

function XEquipConfig.GetLevelUpCfg(templateId, times, level)
    local breakthroughCfg = XEquipConfig.GetEquipBreakthroughCfg(templateId, times)
    if not breakthroughCfg then
        return
    end

    templateId = breakthroughCfg.LevelUpTemplateId

    local template = LevelUpTemplates[templateId]
    if not template then
        XLog.Error("XEquipConfig.GetLevelUpCfg error: can not find template, templateId is " .. templateId)
        return
    end

    template = template[level]
    if not template then
        XLog.Error("XEquipConfig.GetLevelUpCfg error: can not find template, level is " .. level)
        return
    end

    return template
end

function XEquipConfig.GetEquipSuitCfg(templateId)
    local template = EquipSuitTemplate[templateId]
    if not template then
        XLog.Error("XEquipConfig.GetEquipSuitCfg error: can not find template, templateId is " .. templateId)
        return
    end
    return template
end

function XEquipConfig.GetEquipSuitEffectCfg(templateId)
    local template = EquipSuitEffectTemplate[templateId]
    if not template then
        XLog.Error("XEquipConfig.GetEquipSuitEffectCfg error: can not find template, templateId is " .. templateId)
        return
    end

    return template
end

function XEquipConfig.GetEquipTemplateIdsBySuitId(suitId)
    return SuitIdToEquipTemplateIdsDic[suitId] or {}
end

function XEquipConfig.GetSuitSites(suitId)
    return SuitSitesDic[suitId] or {}
end

function XEquipConfig.GetMaxSuitCount()
    return XTool.GetTableCount(SuitSitesDic)
end

function XEquipConfig.GetEquipBgPath(templateId)
    if not XEquipConfig.CheckTemplateIdIsEquip(templateId) then return end
    local template = XEquipConfig.GetEquipCfg(templateId)
    local quality = template.Quality
    return XArrangeConfigs.GeQualityBgPath(quality)
end

function XEquipConfig.GetEquipQualityPath(templateId)
    local template = XEquipConfig.GetEquipCfg(templateId)
    local quality = template.Quality
    if not quality then
        XLog.Error("XEquipConfig.GetEquipQualityPath error: quality is nil")
        return
    end
    return EquipQualityBgPath[quality]
end

function XEquipConfig.GetEquipDecomposeCfg(templateId, breakthroughTimes)
    if not XEquipConfig.CheckTemplateIdIsEquip(templateId) then return end
    breakthroughTimes = breakthroughTimes or 0

    local template = XEquipConfig.GetEquipCfg(templateId)
    local site = template.Site
    if not site then
        XLog.Error("XEquipConfig.GetEquipDecomposeCfg error: can not find template.Site, templateId is " .. templateId)
        return
    end

    local star = template.Star
    if not star then
        XLog.Error("XEquipConfig.GetEquipBgPath error: can not find template.Star, templateId is " .. templateId)
        return
    end

    return EquipDecomposeDic[site .. star .. breakthroughTimes]
end

function XEquipConfig.GetWeaponTypeIconPath(templateId)
    return XGoodsCommonManager.GetGoodsShowParamsByTemplateId(templateId).Icon
end

function XEquipConfig.GetEquipBreakThroughIcon(breakthroughTimes)
    local icon = EquipBreakThroughIcon[breakthroughTimes]
    if not icon then
        XLog.Error("XEquipConfig.EquipBreakThroughIcon error: can not find icon, breakthroughTimes is " .. breakthroughTimes)
        return
    end
    return icon
end

function XEquipConfig.GetEquipBreakThroughSmallIcon(breakthroughTimes)
    local icon = EquipBreakThroughSmallIcon[breakthroughTimes]
    if not icon then
        XLog.Error("XEquipConfig.EquipBreakThroughSmallIcon error: can not find icon, breakthroughTimes is " .. breakthroughTimes)
        return
    end
    return icon
end

function XEquipConfig.GetEquipBreakThroughBigIcon(breakthroughTimes)
    local icon = EquipBreakThroughBigIcon[breakthroughTimes]
    if not icon then
        XLog.Error("XEquipConfig.GetEquipBreakThroughBigIcon error: can not find icon, breakthroughTimes is " .. breakthroughTimes)
        return
    end
    return icon
end

function XEquipConfig.GetWeaponSkillTemplate(templateId)
    local template = WeaponSkillTemplate[templateId]
    if not template then
        XLog.Error("XEquipConfig.GetWeaponSkillTemplate error: can not find template, templateId is " .. templateId)
        return
    end

    return template
end

function XEquipConfig.GetWeaponSkillInfo(weaponSkillId)
    local skillInfo = {}

    local template = WeaponSkillTemplate[weaponSkillId]
    if not template then
        XLog.Error("XEquipConfig.GetWeaponSkillInfo error: can not find template, weaponSkillId is " .. weaponSkillId)
        return
    end

    skillInfo.Icon = template.Icon
    skillInfo.Name = template.Name
    skillInfo.Description = template.Description

    return skillInfo
end

function XEquipConfig.GetWeaponSkillAbility(weaponSkillId)
    local template = WeaponSkillTemplate[weaponSkillId]
    if not template then
        XLog.Error("XEquipConfig.GetWeaponSkillAbility error: can not find template, weaponSkillId is " .. weaponSkillId)
        return
    end

    return template.Ability
end

function XEquipConfig.GetWeaponSkillPoolSkillIds(poolId, characterId)
    local template = WeaponSkillPoolTemplate[poolId]
    if not template then
        XLog.Error("XEquipConfig.GetWeaponSkillPoolSkillIds error: can not find template, poolId is " .. poolId)
        return
    end

    local skillIds = template[characterId]
    if not skillIds then
        XLog.Error("XEquipConfig.GetWeaponSkillPoolSkillIds error: can not find skillIds, characterId is " .. characterId)
        return
    end

    return skillIds
end

function XEquipConfig.GetEquipSkipIdTemplate(site)
    local template = EquipSkipIdTemplates[site]
    if not template then
        XLog.Error("XEquipConfig.GetEquipSkipIdTemplate error: can not find template, site is " .. site)
        return
    end
    return template
end

function XEquipConfig.GetEquipResonanceCfg(templateId)
    local equipResonanceCfg = EquipResonanceTemplate[templateId]

    if not equipResonanceCfg then
        return
    end

    return equipResonanceCfg
end

function XEquipConfig.GetEquipResonanceConsumeItemCfg(templateId)
    local equipResonanceItemCfg = EquipResonanceConsumeItemTemplates[templateId]

    if not equipResonanceItemCfg then
        return
    end

    return equipResonanceItemCfg
end

function XEquipConfig.GetNeedFirstShow(templateId)
    local template = XEquipConfig.GetEquipCfg(templateId)
    return template.NeedFirstShow
end

function XEquipConfig.GetEquipTemplates()
    return EquipTemplates
end

function XEquipConfig.GetEquipSuitTemplates()
    return EquipSuitTemplate
end

function XEquipConfig.GetEquipBreakthroughTemplates()
    return EquipBreakthroughTemplate
end

function XEquipConfig.GetWeaponSkillTemplates()
    return WeaponSkillTemplate
end

function XEquipConfig.GetEquipSuitEffectTemplates()
    return EquipSuitEffectTemplate
end