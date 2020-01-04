XComeAcrossConfig = {}

ComeAcrossGameType = {
    GAME_CLICK = 1,
    GAME_ELIMINATE = 2,
}

local TABLE_COMEACROSS = "Share/Trust/TrustGameConfig.tab";
local TABLE_COMEACROSS_CLICK_POOL = "Share/Trust/TrustGameClickPool.tab";
local TABLE_COMEACROSS_ELIMINATE_POOL = "Share/Trust/TrustGameEliminatePool.tab";
local TABLE_COMEACROSS_REWARD = "Share/Trust/TrustGameReward.tab";
local TABLE_COMEACROSS_POSITION = "Share/Trust/TrustGamePosition.tab";
local TABLE_COMEACROSS_GRID = "Share/Trust/TrustGameGrid.tab";
local TABLE_COMEACROSS_GAMETYPE = "Share/Trust/TrustGameTypeConfig.tab";

local ComeAcrossConfig = {}
local ComeAcrossClickPoolConfig = {}
local ComeAcrossEliminatePoolConfig = {}
local ComeAcrossRewardConfig = {}
local ComeAcrossPositionConfig = {}
local ComeAcrossGridConfig = {}
local ComeAcrossGameTypeConfig = {}

local GameTypePools = {}

function XComeAcrossConfig.Init()
    ComeAcrossConfig = XTableManager.ReadByIntKey(TABLE_COMEACROSS, XTable.XTableTrustGameConfig, "Id")
    ComeAcrossRewardConfig = XTableManager.ReadByIntKey(TABLE_COMEACROSS_REWARD, XTable.XTableTrustGameReward, "Id")
    ComeAcrossClickPoolConfig = XTableManager.ReadByIntKey(TABLE_COMEACROSS_CLICK_POOL, XTable.XTableTrustGameClickPool, "Id")
    ComeAcrossEliminatePoolConfig = XTableManager.ReadByIntKey(TABLE_COMEACROSS_ELIMINATE_POOL, XTable.XTableTrustGameEliminatePool, "Id")
    ComeAcrossPositionConfig = XTableManager.ReadByIntKey(TABLE_COMEACROSS_POSITION, XTable.XTableTrustGamePosition, "Id")
    ComeAcrossGridConfig = XTableManager.ReadByIntKey(TABLE_COMEACROSS_GRID, XTable.XTableTrustGameGrid, "Id")
    ComeAcrossGameTypeConfig = XTableManager.ReadByIntKey(TABLE_COMEACROSS_GAMETYPE, XTable.XTableTrustGameTypeConfig, "Id")

    GameTypePools[ComeAcrossGameType.GAME_CLICK] = ComeAcrossClickPoolConfig
    GameTypePools[ComeAcrossGameType.GAME_ELIMINATE] = ComeAcrossEliminatePoolConfig
end

--获取小游戏关卡表
function XComeAcrossConfig.GetComeAcrossConfig()
    return ComeAcrossConfig
end

--获取小游戏关卡
function XComeAcrossConfig.GetComeAcrossConfigById(id)
    if not ComeAcrossConfig then
        return
    end

    return ComeAcrossConfig[id]
end

--获取小游戏内容
function XComeAcrossConfig.GetComeAcrossTypeConfigById(id)
    if not ComeAcrossGameTypeConfig then
        return
    end

    return ComeAcrossGameTypeConfig[id]
end

--获取小游戏位置
function XComeAcrossConfig.GetComeAcrossPositionConfigById(id)
    if not ComeAcrossPositionConfig then
        return
    end

    return ComeAcrossPositionConfig[id]
end


--获得奖励
function XComeAcrossConfig.GetComeAcrossRewardConfigById(id)
    if not ComeAcrossRewardConfig then
        return
    end

    return ComeAcrossRewardConfig[id]
end

--根据类型获取小游戏消除元素
function XComeAcrossConfig.GetComeAcrossGridConfigById(gridType)
    if not ComeAcrossGridConfig then
        return
    end

    for i,v in ipairs(ComeAcrossGridConfig) do
        if v.Type == gridType then
            return v
        end
    end

    return nil
end

--随机获取N个小游戏
function XComeAcrossConfig.RandomNumberGetGameConfig(count)
    if not ComeAcrossConfig then
        return
    end

    local length = #ComeAcrossConfig
    if length <= count then
        return ComeAcrossConfig
    end

    local temp = {}

    for i, v in ipairs(ComeAcrossConfig) do
        table.insert(temp, v)
    end

    local games = {}

    for i = 1, count, 1 do
        local sum = #temp
        local rand = math.random(1, sum)
        local gameTable = {}
        gameTable.GameConfig = table.remove(temp, rand)
        gameTable.TypeOfGames = XComeAcrossConfig.RandomNumberGetGameConfigFormPoolByType(gameTable.GameConfig.Count, gameTable.GameConfig.Type,gameTable.GameConfig.Difficult)
        gameTable.Position = ComeAcrossPositionConfig[i]
        table.insert(games, gameTable)
    end

    return games
end

--从游戏类型池随出特定类型和数量的游戏关卡
function XComeAcrossConfig.RandomNumberGetGameConfigFormPoolByType(count, gameType,difficult)
    local pools = GameTypePools[gameType]

    if not pools or #pools <= count then
        return pools
    end

    --筛选难度
    local pool = {}
    for k,v in ipairs(pools) do
        if v.Difficult == difficult then
            table.insert(pool,v)
        end
    end

    if not pool or #pool <= count then
        return pool
    end

    --获取权重总和
    local sum = 0
    for i, v in ipairs(pool) do
        sum = sum + v.Weight
    end

    --设置随机数种子
    math.randomseed(os.time())

    --随机数加上权重，越大的权重，数值越大
    local weightList = {}
    for i, v in ipairs(pool) do
        local rand = math.random(0, sum)
        local seed = {}
        seed.Index = i
        seed.Weight = rand + v.Weight
        table.insert(weightList, seed)
    end

    --排序
    table.sort(weightList, function(x, y)
        return x.Weight > y.Weight
    end)

    --返回最大的权重值的前几个
    local typeOfGames = {}

    for i = 1, count, 1 do
        local index = weightList[i].Index
        if pool[index] then
            table.insert(typeOfGames,pool[index] )
        end
    end

    return typeOfGames
end

