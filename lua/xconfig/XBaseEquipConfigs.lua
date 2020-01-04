XBaseEquipConfigs =XBaseEquipConfigs or {}

local TABLE_BASE_EQUIP_PATH = "Share/BaseEquip/BaseEquip.tab"
local TABLE_BASE_EQUIP_SCORE = "Client/BaseEquip/BaseEquipScore.tab"

local BaseEquipTemplates = {}       -- 基地装备配置
local BaseEquipScoreTemplates = {}  -- 基地装备评分计算配置

function XBaseEquipConfigs.Init()
    BaseEquipTemplates = XTableManager.ReadByIntKey(TABLE_BASE_EQUIP_PATH, XTable.XTableBaseEquip, "Id")
    BaseEquipScoreTemplates = XTableManager.ReadByStringKey(TABLE_BASE_EQUIP_SCORE, XTable.XTableBaseEquipScore, "Key")
end

function XBaseEquipConfigs.GetBaseEquipTemplates()
    return BaseEquipTemplates
end

function XBaseEquipConfigs.GetBaseEquipScoreTemplates()
    return BaseEquipScoreTemplates
end