XAttribConfigs = XAttribConfigs or {}

local TABLE_ATTRIB_DESC_PATH = "Share/Attrib/AttribDesc.tab"
local TABLE_ATTRIB_ABILITY_PATH = "Share/Attrib/AttribAbility.tab"
local TABLE_ATTRIB_PATH = "Share/Attrib/Attrib"
local TABLE_ATTRIB_PROMOTED_PATH = "Share/Attrib/AttribPromoted"
local TABLE_ATTRIB_GROW_RATE_PATH = "Share/Attrib/AttribGrowRate"
local TABLE_ATTRIB_POOL_PATH = "Share/Attrib/AttribPool/"
local TABLE_ATTRIB_REVISE_PATH = "Share/Attrib/AttribRevise/"
local TABLE_NPC_PATH = "Share/Fight/Npc/Npc/Npc.tab"

local AttribAbilityTemplate = {}
local AttribTemplates = {}
local AttribPromotedTemplates = {}
local AttribGrowRateTemplates = {}
local AttribReviseTemplates = {}
local AttribGroupTemplates = {}
local AttribGroupPoolIdDic = {} --共鸣属性池字典
local NpcTemplates = {}

--属性名字配置表
local AttribDescTemplates = {}    

local tableInsert = table.insert

function XAttribConfigs.Init()
    AttribTemplates = XTableManager.ReadByIntKey(TABLE_ATTRIB_PATH, XTable.XTableNpcAttrib, "Id")
    AttribPromotedTemplates = XTableManager.ReadByIntKey(TABLE_ATTRIB_PROMOTED_PATH, XTable.XTableNpcAttrib, "Id")
    AttribGrowRateTemplates = XTableManager.ReadByIntKey(TABLE_ATTRIB_GROW_RATE_PATH, XTable.XTableNpcAttrib, "Id")
    AttribGroupTemplates = XTableManager.ReadByIntKey(TABLE_ATTRIB_POOL_PATH, XTable.XTableAttribGroup, "Id")
    AttribReviseTemplates = XTableManager.ReadByIntKey(TABLE_ATTRIB_REVISE_PATH, XTable.XTableAttribRevise, "Id")
    NpcTemplates = XTableManager.ReadByIntKey(TABLE_NPC_PATH, XTable.XTableNpc, "Id")
    AttribDescTemplates = XTableManager.ReadByIntKey(TABLE_ATTRIB_DESC_PATH, XTable.XTableAttribDesc, "Index")
    AttribAbilityTemplate = XTableManager.ReadByStringKey(TABLE_ATTRIB_ABILITY_PATH, XTable.XTableAttribAbility, "Key")

    for _, template in pairs(AttribGroupTemplates) do
        AttribGroupPoolIdDic[template.PoolId] = AttribGroupPoolIdDic[template.PoolId] or {}
        tableInsert(AttribGroupPoolIdDic[template.PoolId], template)
    end
end

function XAttribConfigs.GetAttribTemplates()
    return AttribTemplates
end

function XAttribConfigs.GetAttribPromotedTemplates()
    return AttribPromotedTemplates
end

function XAttribConfigs.GetAttribGrowRateTemplates()
    return AttribGrowRateTemplates
end

function XAttribConfigs.GetAttribReviseTemplates()
    return AttribReviseTemplates
end

function XAttribConfigs.GetAttribGroupTemplates()
    return AttribGroupTemplates
end

function XAttribConfigs.GetNpcTemplates()
    return NpcTemplates
end

function XAttribConfigs.GetAttribDescTemplates()
    return AttribDescTemplates
end

function XAttribConfigs.GetAttribAbilityTemplate()
    return AttribAbilityTemplate
end

function XAttribConfigs.GetAttribGroupTemplateByPoolId(poolId)
    return AttribGroupPoolIdDic[poolId] or {}
end