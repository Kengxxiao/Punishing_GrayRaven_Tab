XMedalConfigs = XMedalConfigs or {}

local TABLE_MEDAL = "Share/Medal/Medal.tab"

local Meadals = {}

function XMedalConfigs.Init()
    Meadals = XTableManager.ReadByIntKey(TABLE_MEDAL, XTable.XTableMedal, "Id")
end

function XMedalConfigs.GetMeadalConfigById(Id)
    return Meadals[Id]
end

function XMedalConfigs.GetMeadalConfigs()
    return Meadals
end