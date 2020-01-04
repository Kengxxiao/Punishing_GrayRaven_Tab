XGuildConfig = {}

local CLIENT_GUILD_WELFARE = "Client/Guild/GuildWelfare.tab"

local SHARE_GUILD_CREATE = "Share/Guild/GuildCreate.tab"
local SHARE_GUILD_LEVEL = "Share/Guild/GuildLevel.tab"
local SHARE_GUILD_POSITION = "Share/Guild/GuildPosition.tab"

local GuildWelfare = {}

local GuildCreate = {}
local GuildLevel = {}
local GuildPosition = {}

function XGuildConfig.Init()
    GuildWelfare = XTableManager.ReadByIntKey(CLIENT_GUILD_WELFARE, XTable.XTableGuildWelfare, "Id")

    GuildCreate = XTableManager.ReadByIntKey(SHARE_GUILD_CREATE, XTable.XTableGuildCreate, "Id")
    GuildLevel = XTableManager.ReadByIntKey(SHARE_GUILD_LEVEL, XTable.XTableGuildLevel, "Level")
    GuildPosition = XTableManager.ReadByIntKey(SHARE_GUILD_POSITION, XTable.XTableGuildPosition, "Id")
end

function XGuildConfig.GetGUildWelfares()
    return GuildWelfare
end

function XGuildConfig.GetGuildWelfareById(id)
    local welfareData = GuildWelfare[id]
    if not welfareData then
        XLog.Error("XGuildConfig.GetGuildWelfareById error: not data found by id " .. tostring(id))
        return 
    end
    return welfareData
end

function XGuildConfig.GetGuildCreateById(id)
    local guildData = GuildCreate[id]
    if not guildData then
        XLog.Error("XGuildConfig.GetGuildCreateById error: not data found by id " .. tostring(id))
        return 
    end
    return guildData
end

function XGuildConfig.GetGuildLevelDataBylevel(level)
    local guildLevelData = GuildLevel[level]
    if not guildLevelData then
        XLog.Error("XGuildConfig.GetGuildLevelDataBylevel error: not data found by level " .. tostring(level))
        return 
    end
    return guildLevelData
end

function XGuildConfig.GetGuildPositionById(id)
    local guildPositionData = GuildPosition[id]
    if not guildPositionData then
        XLog.Error("XGuildConfig.GetGuildPositionById error: not data found by id " .. tostring(id))
        return 
    end
    return guildPositionData
end