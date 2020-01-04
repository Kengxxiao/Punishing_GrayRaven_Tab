XPlayerInfoConfigs = XPlayerInfoConfigs or {}

local TABLE_FETTER_PATH = "Share/Fetters/FettersLevel.tab"

local FettersCfg = {}

function XPlayerInfoConfigs.Init()
    FettersCfg = XTableManager.ReadByIntKey(TABLE_FETTER_PATH, XTable.XTableFetter, "Level")
end

function XPlayerInfoConfigs.GetLevelByExp(exp)
    local Level = 1
    for k, v in pairs(FettersCfg) do
        Level = k
        if exp == 0 then
            Level = 1
            break
        elseif v.Exp > exp then
            break
        elseif v.Exp == exp then
            if Level >= FettersCfg[#FettersCfg].Level then
                break
            end
            Level = Level + 1
            break
        end
    end
    return Level
end

function XPlayerInfoConfigs.GetLevelDataByExp(exp)
    --默认1级
    local result = FettersCfg[1]
    if exp > FettersCfg[#FettersCfg].Exp then
        return FettersCfg[#FettersCfg]
    else
        for i = #FettersCfg, 1, -1 do
            if exp >= FettersCfg[i].Exp then
                result = FettersCfg[i + 1]
                break
            end
        end
    end
    return result
end

function XPlayerInfoConfigs.GetCurLevelExp(level)
    if level == 0 then
        return 0
    end
    for i = #FettersCfg, 1, -1 do
        if level == FettersCfg[i].Level then
            return FettersCfg[i].Exp
        end
    end
    --满级
    return FettersCfg[#FettersCfg]
end