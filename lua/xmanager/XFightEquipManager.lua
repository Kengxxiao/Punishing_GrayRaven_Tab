local pairs = pairs
local type = type

local table = table
local tableInsert = table.insert

local mathMin = math.min

XFightEquipManager = XFightEquipManager or {}

local EquipTemplates = {}
local EquipSuitTemplates = {}
local EquipSuitEffectTemplates = {}
local EquipBreakthroughTemplates = {}
local WeaponSkillTemplates = {}

local function Awake()
    EquipTemplates = XEquipConfig.GetEquipTemplates()
    EquipSuitTemplates = XEquipConfig.GetEquipSuitTemplates()
    EquipSuitEffectTemplates = XEquipConfig.GetEquipSuitEffectTemplates()
    EquipBreakthroughTemplates = XEquipConfig.GetEquipBreakthroughTemplates()
    WeaponSkillTemplates = XEquipConfig.GetWeaponSkillTemplates()
end

local function GetEquipTemplate(equipTemplateId)
    local template = EquipTemplates[equipTemplateId]
    if not template then
        XLog.Error("XFightEquipManager GetEquipTemplate error: template not found, template id: " .. equipTemplateId)
        return XCode.EquipTemplateNotFound, nil
    end

    return XCode.Success, template
end

local function GetBreakthroughTemplate(equipTemplateId, times)
    local configs = EquipBreakthroughTemplates[equipTemplateId]
    if not configs then
        XLog.Error("XFightEquipManager GetBreakthroughTemplate error: template not found, template id: " .. equipTemplateId)
        return XCode.EquipBreakthroughTemplateNotFound, nil
    end

    local template = configs[times]
    if not template then
        XLog.Error("XFightEquipManager GetBreakthroughTemplate error: template not found, template id: " .. equipTemplateId .. ",times: " .. times)
        return XCode.EquipBreakthroughTemplateNotFound, nil
    end

    return XCode.Success, template
end

local function GetWeaponSkillTemplate(templateId)
    local template = WeaponSkillTemplates[templateId]
    if not template then
        XLog.Error("XFightEquipManager GetWeaponSkillTemplate error: template not found, template id: " .. templateId)
        return XCode.EquipWeaponSkillTemplateNotFound, nil
    end

    return XCode.Success, template
end

local function GetSuitTemplate(suitId)
    local template = EquipSuitTemplates[suitId]
    if not template then
        XLog.Error("XFightEquipManager GetSuitTemplate error: template not found, template id: " .. suitId)
        return XCode.EquipManagerGetSuitTemplateNotFound, nil
    end

    return XCode.Success, template
end

local function GetSuitEffectTemplate(templateId)
    local template = EquipSuitEffectTemplates[templateId]
    if not template then
        XLog.Error("XFightEquipManager GetSuitEffectTemplate error: template not found, template id: " .. templateId)
        return XCode.EquipManagerGetSuitEffectTemplateNotFound, nil
    end

    return XCode.Success, template
end
-----------------------------------------Attribs Begin---------------------------------------

---突破属性成长加成
---@param equipData userdata 装备数据
---@param attribIds table 属性id列表
---@param trainedLevels table 培养等级列表
---@return XCode 状态码
local function DoAddBreakthroughPromotedAttribId(equipData, attribIds, trainedLevels)
    local code, template = GetBreakthroughTemplate(equipData.TemplateId, equipData.Breakthrough)
    if code ~= XCode.Success then
        return code
    end

    local trainedLevel = equipData.Level - 1
    if trainedLevel > 0 and template.AttribPromotedId > 0 then
        tableInsert(attribIds, template.AttribPromotedId)
        tableInsert(trainedLevels, trainedLevel)
    end

    return XCode.Success
end

---共鸣属性叠加id
local function DoAddResonanceAttribId(equipData, characterId, attribIds)
    local resonanceInfo = equipData.ResonanceInfo

    if type(resonanceInfo) == "userdata" then
        resonanceInfo = XTool.CsList2LuaTable(resonanceInfo)
    end

    for _, resonanceData in pairs(resonanceInfo) do
        if resonanceData.Type == XEquipConfig.EquipResonanceType.Attrib or
                resonanceData.Type == CS.EquipResonanceType.Attrib then
            if resonanceData.CharacterId == 0 or resonanceData.CharacterId == characterId then
                local code, template = XAttribManager.GetAttribGroupTemplate(resonanceData.TemplateId)
                if code ~= XCode.Success then
                    return code
                end

                if template.AttribId > 0 then
                    tableInsert(attribIds, template.AttribId)
                end
            end
        end
    end

    return XCode.Success
end

---共鸣属性加成id
local function DoAddResonanceGrowRateAttribId(equipData, characterId, attribIds)
    local resonanceInfo = equipData.ResonanceInfo

    if type(resonanceInfo) == "userdata" then
        resonanceInfo = XTool.CsList2LuaTable(resonanceInfo)
    end

    for _, resonanceData in pairs(resonanceInfo) do
        if resonanceData.Type == XEquipConfig.EquipResonanceType.Attrib or
                resonanceData.Type == CS.EquipResonanceType.Attrib then
            if resonanceData.CharacterId == 0 or resonanceData.CharacterId == characterId then
                local code, template = XAttribManager.GetAttribGroupTemplate(resonanceData.TemplateId)
                if code ~= XCode.Success then
                    return code
                end

                if template.AttribGrowRateId > 0 then
                    tableInsert(attribIds, template.AttribGrowRateId)
                end
            end
        end
    end

    return XCode.Success
end

--- 属性计算
--- 1、突破提供基础属性
--- 2、共鸣属性计算
local function AddNumericAttribId(npcData, attribIds)
    local equips = npcData.Equips
    if not equips then
        return XCode.Success
    end

    if type(equips) == "userdata" then
        equips = XTool.CsList2LuaTable(equips)
    end

    if #equips <= 0 then
        return XCode.Success
    end

    for _, equipData in pairs(equips) do
        local code, template = GetBreakthroughTemplate(equipData.TemplateId, equipData.Breakthrough)
        if code ~= XCode.Success then
            return code
        end

        if template.AttribId > 0 then
            tableInsert(attribIds, template.AttribId)
        end

        if equipData.ResonanceInfo then
            code = DoAddResonanceAttribId(equipData, npcData.Character.Id, attribIds)
            if code ~= XCode.Success then
                return code
            end
        end
    end

    return XCode.Success
end

--- 属性百分比加成
--- 1、共鸣提供加成
local function AddGrowRateAttribId(npcData, attribIds)
    local equips = npcData.Equips
    if not equips then
        return XCode.Success
    end

    if type(equips) == "userdata" then
        equips = XTool.CsList2LuaTable(equips)
    end

    if #equips < 0 then
        return XCode.Success
    end

    for _, equipData in pairs(equips) do
        if equipData.ResonanceInfo then
            local code = DoAddResonanceGrowRateAttribId(equipData, npcData.Character.Id, attribIds)
            if code ~= XCode.Success then
                return code
            end
        end
    end

    return XCode.Success
end

--- 属性成长加成
--- 1、突破提供加成
local function AddPromotedAttribId(npcData, attribIds, trainedLevels)
    local equips = npcData.Equips
    if not equips then
        return XCode.Success
    end

    if type(equips) == "userdata" then
        equips = XTool.CsList2LuaTable(equips)
    end

    if #equips <= 0 then
        return XCode.Success
    end

    for _, equipData in pairs(equips) do
        local code = DoAddBreakthroughPromotedAttribId(equipData, attribIds, trainedLevels)
        if code ~= XCode.Success then
            return code
        end
    end

    return XCode.Success
end
-----------------------------------------Attribs End-----------------------------------------
-----------------------------------------Skill Begin-----------------------------------------

---武器技能等级集合
---武器技能都为1级
---@param equipData userdata 装备数据
---@param levelMap table 技能等级集合
---@return XCode 状态码
local function DoGetWeaponSkillLevel(equipData, levelMap)
    local code, template = GetEquipTemplate(equipData.TemplateId)
    if code ~= XCode.Success then
        return code
    end

    if template.Site ~= XEquipConfig.EquipSite.Weapon then
        return XCode.Success
    end

    if template.WeaponSkillId <= 0 then
        return XCode.Success
    end

    local skillTemplate
    code, skillTemplate = GetWeaponSkillTemplate(template.WeaponSkillId)
    if code ~= XCode.Success then
        return code
    end

    for _, subSkillId in pairs(skillTemplate.SubSkillId) do
        levelMap[subSkillId] = 1
    end

    return XCode.Success
end

---武器共鸣技能集合
---共鸣技能等级都为1级
---@param equipData userdata 装备数据
---@param characterId number 角色id
---@param levelMap table 技能等级集合
---@return XCode 状态码
local function DoGetResonanceSkillLevel(equipData, characterId, levelMap)
    local resonanceInfo = equipData.ResonanceInfo

    if type(resonanceInfo) == "userdata" then
        resonanceInfo = XTool.CsList2LuaTable(resonanceInfo)
    end

    for _, resonanceData in pairs(resonanceInfo) do
        if resonanceData.Type == CS.EquipResonanceType.WeaponSkill then
            if resonanceData.CharacterId == 0 or resonanceData.CharacterId == characterId then
                local code, skillTemplate = GetWeaponSkillTemplate(resonanceData.TemplateId)
                if code ~= XCode.Success then
                    return code
                end

                for _, subSkillId in pairs(skillTemplate.SubSkillId) do
                    levelMap[subSkillId] = 1
                end
            end
        end
    end

    return XCode.Success
end

---套装技能等级集合
---套装技能等级都为1级
---@param equips userdata 装备数据
---@param levelMap table 技能等级集合
---@return XCode 状态码
local function DoGetSuitSkillLevel(equips, levelMap)
    local suitCount = {}

    if type(equips) == "userdata" then
        equips = XTool.CsList2LuaTable(equips)
    end

    for _, equip in pairs(equips) do
        local code, template = GetEquipTemplate(equip.TemplateId)
        if code ~= XCode.Success then
            return code
        end

        if template.SuitId > 0 then
            if not suitCount[template.SuitId] then
                suitCount[template.SuitId] = 1
            else
                suitCount[template.SuitId] = suitCount[template.SuitId] + 1
            end
        end
    end

    for suitId, count in pairs(suitCount) do
        local code, template = GetSuitTemplate(suitId)
        if code ~= XCode.Success then
            return code
        end

        for i = 1, mathMin(count, XEquipConfig.MAX_SUIT_COUNT) do
            local effectId = template.SkillEffect[i]
            if effectId and effectId > 0 then
                local effectTemplate
                code, effectTemplate = GetSuitEffectTemplate(effectId)
                if code ~= XCode.Success then
                    return code
                end

                if #effectTemplate.SkillId > 0 then
                    for _, skillId in pairs(effectTemplate.SkillId) do
                        levelMap[skillId] = 1
                    end
                end
            end
        end
    end

    return XCode.Success
end

--- 技能等级
--- 1、武器技能加成
--- 2、共鸣提供加成
--- 3、套装技能加成
local function GetSkillLevel(npcData, levelMap)
    local code
    local equips = npcData.Equips

    if type(equips) == "userdata" then
        equips = XTool.CsList2LuaTable(equips)
    end

    for _, equipData in pairs(equips) do
        code = DoGetWeaponSkillLevel(equipData, levelMap)
        if code ~= XCode.Success then
            return code
        end

        code = DoGetResonanceSkillLevel(equipData, npcData.Character.Id, levelMap)
        if code ~= XCode.Success then
            return code
        end
    end

    code = DoGetSuitSkillLevel(equips, levelMap)
    if code ~= XCode.Success then
        return code
    end

    return XCode.Success
end
-----------------------------------------Skill End-----------------------------------------
-----------------------------------------Magic Begin-----------------------------------------

---武器出生魔法等级集合
---武器出生魔法等级都为1级
---@param equipData userdata 装备数据
---@param levelMap table 出生魔法等级集合
---@return XCode 状态码
local function DoGetWeaponBornMagicLevel(equipData, levelMap)
    local code, template = GetEquipTemplate(equipData.TemplateId)
    if code ~= XCode.Success then
        return code
    end

    if template.Site ~= XEquipConfig.EquipSite.Weapon then
        return XCode.Success
    end

    if template.WeaponSkillId <= 0 then
        return XCode.Success
    end

    local skillTemplate
    code, skillTemplate = GetWeaponSkillTemplate(template.WeaponSkillId)
    if code ~= XCode.Success then
        return code
    end

    for _, magic in pairs(skillTemplate.BornMagic) do
        levelMap[magic] = 1
    end

    return XCode.Success
end

---武器共鸣出生魔法等级集合
---共鸣出生魔法等级都为1级
---@param equipData userdata 装备数据
---@param characterId number 角色id
---@param levelMap table 技能等级集合
---@return XCode 状态码
local function DoGetResonanceBornMagicLevel(equipData, characterId, levelMap)
    local resonanceInfo = equipData.ResonanceInfo

    if type(resonanceInfo) == "userdata" then
        resonanceInfo = XTool.CsList2LuaTable(resonanceInfo)
    end

    for _, resonanceData in pairs(resonanceInfo) do
        if resonanceData.Type == CS.EquipResonanceType.WeaponSkill then
            if resonanceData.CharacterId == 0 or resonanceData.CharacterId == characterId then
                local code, skillTemplate = GetWeaponSkillTemplate(resonanceData.TemplateId)
                if code ~= XCode.Success then
                    return code
                end

                for _, magic in pairs(skillTemplate.BornMagic) do
                    levelMap[magic] = 1
                end
            end
        end
    end

    return XCode.Success
end

---套装出生魔法等级集合
---套装出生魔法等级都为1级
---@param equips userdata 装备数据
---@param levelMap table 出生魔法等级集合
---@return XCode 状态码
local function DoGetSuitBornMagicLevel(equips, levelMap)
    local suitCount = {}

    if type(equips) == "userdata" then
        equips = XTool.CsList2LuaTable(equips)
    end

    for _, equip in pairs(equips) do
        local code, template = GetEquipTemplate(equip.TemplateId)
        if code ~= XCode.Success then
            return code
        end

        if template.SuitId > 0 then
            if not suitCount[template.SuitId] then
                suitCount[template.SuitId] = 1
            else
                suitCount[template.SuitId] = suitCount[template.SuitId] + 1
            end
        end
    end

    for suitId, count in pairs(suitCount) do
        local code, template = GetSuitTemplate(suitId)
        if code ~= XCode.Success then
            return code
        end

        for i = 1, mathMin(count, XEquipConfig.MAX_SUIT_COUNT) do
            local effectId = template.SkillEffect[i]
            if effectId and effectId > 0 then
                local effectTemplate
                code, effectTemplate = GetSuitEffectTemplate(effectId)
                if code ~= XCode.Success then
                    return code
                end

                if #effectTemplate.BornMagic > 0 then
                    for _, bornMagic in pairs(effectTemplate.BornMagic) do
                        levelMap[bornMagic] = 1
                    end
                end
            end
        end
    end

    return XCode.Success
end

--- 出生魔法属性等级
--- 1、武器技能加成
--- 2、共鸣提供加成
--- 3、套装技能加成
local function GetBornMagicLevel(npcData, levelMap)
    local code
    local equips = npcData.Equips

    if type(equips) == "userdata" then
        equips = XTool.CsList2LuaTable(equips)
    end

    for _, equipData in pairs(equips) do
        code = DoGetWeaponBornMagicLevel(equipData, levelMap)
        if code ~= XCode.Success then
            return code
        end

        code = DoGetResonanceBornMagicLevel(equipData, npcData.Character.Id, levelMap)
        if code ~= XCode.Success then
            return code
        end
    end

    code = DoGetSuitBornMagicLevel(npcData.Equips, levelMap)
    if code ~= XCode.Success then
        return code
    end

    return XCode.Success
end
-----------------------------------------Magic End-----------------------------------------
local function RegisterInterfaces()
    XAttribManager.RegisterGrowRateIdInterface(AddGrowRateAttribId)
    XAttribManager.RegisterNumericIdInterface(AddNumericAttribId)
    XAttribManager.RegisterPromotedIdInterface(AddPromotedAttribId)

    XMagicSkillManager.RegisterSkillLevelInterface(GetSkillLevel)
    XMagicSkillManager.RegisterBornMagicLevelInterface(GetBornMagicLevel)
end

function XFightEquipManager.Init()
    Awake()
    RegisterInterfaces()
end

---------------------------------------客户端特有方法---------------------------------------
local function DoGetEquipAttribIds(equipData, numericIds, promotedIds, trainedLevels)
    local code, template = GetBreakthroughTemplate(equipData.TemplateId,equipData.Breakthrough)
    if code ~= XCode.Success then
        return
    end

    tableInsert(numericIds, template.AttribId)
    DoAddBreakthroughPromotedAttribId(equipData, promotedIds, trainedLevels)
end

function XFightEquipManager.GetEquipAttribs(equipData, preLevel)
    local numericIds = {}
    local trainedLevels = {}
    local promotedIds = {}
    local equipLevel = preLevel or equipData.Level

    DoGetEquipAttribIds({
        TemplateId = equipData.TemplateId,
        Breakthrough = equipData.Breakthrough,
        Level = equipLevel
    }, numericIds, promotedIds, trainedLevels)

    return XAttribManager.GetMergeAttribs(numericIds, promotedIds, trainedLevels)
end

function XFightEquipManager.GetEquipListAttribs(equipDatas)
    local numericIds = {}
    local trainedLevels = {}
    local promotedIds = {}

    XTool.LoopCollection(equipDatas, function(equipData)
        DoGetEquipAttribIds(equipData, numericIds, promotedIds, trainedLevels)
    end)

    return XAttribManager.GetMergeAttribs(numericIds, promotedIds, trainedLevels)
end