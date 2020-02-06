local table = table
local tableInsert = table.insert
local tableSort = table.sort

XGachaConfigs = XGachaConfigs or {}

local TABLE_GACHA = "Share/Gacha/Gacha.tab"
local TABLE_GACHA_REWARD = "Share/Gacha/GachaReward.tab"

local Gachas = {}
local GachaRewards = {}

function XGachaConfigs.Init()
    Gachas = XTableManager.ReadByIntKey(TABLE_GACHA, XTable.XTableGacha, "Id")
    GachaRewards = XTableManager.ReadByIntKey(TABLE_GACHA_REWARD, XTable.XTableGachaReward, "Id")
end

function XGachaConfigs.GetGachaReward()
    return GachaRewards
end

function XGachaConfigs.GetGachas()
    return Gachas
end

