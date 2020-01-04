XSignBoardConfigs = XSignBoardConfigs or {}

XSignBoardEventType = {
    CLICK = 10001, --点击
    ROCK = 10002, --摇晃
    LOGIN = 101, --登录
    COMEBACK = 102, --n天未登录
    WIN = 103, --胜利
    WINBUT = 104, -- 胜利，看板不在队里
    LOST = 105, --失败
    LOSTBUT = 106, --失败，不在队伍
    MAIL = 107, --邮件
    TASK = 108, --任务奖励    
    DAILY_REWARD = 109, --日常活跃奖励
    LOW_POWER = 110, -- 低电量
    PLAY_TIME = 111, --游戏时长
    RECEIVE_GIFT = 112, --收到礼物
    GIVE_GIFT = 113, --赠送礼物
    
    IDLE = 1,  --待机
    FAVOR_UP = 2, --好感度提升
    CHANGE = 120, --改变角色
}


local TABLE_SIGNBOARD_FEEDBACK = "Client/Signboard/SignBoardFeedback.tab";
--总表
local TableSignBoardFeedback = nil
--以角色Id为索引
local TableSignBoardRoleIdIndexs = {}
--无角色限制
local TableSignBoardIndexs = {}
local TableSignBoardBreak = nil

--初始化
function XSignBoardConfigs.Init()
    TableSignBoardFeedback = XTableManager.ReadByIntKey(TABLE_SIGNBOARD_FEEDBACK, XTable.XTableSignBoardFeedback, "Id")

    TableSignBoardRoleIdIndexs = {}

    for index, var in pairs(TableSignBoardFeedback) do

        if not var.RoleId then
            TableSignBoardIndexs = TableSignBoardIndexs or {}
            TableSignBoardIndexs[var.ConditionId] = TableSignBoardIndexs[var.ConditionId] or {}
            table.insert(TableSignBoardIndexs[var.ConditionId], var)
        elseif var.RoleId == "None" then
            TableSignBoardBreak = var
        else
            local roleIds = string.Split(var.RoleId, "|")
            if roleIds then
                for i, roleId in ipairs(roleIds) do
                    roleId = tonumber(roleId)
                    TableSignBoardRoleIdIndexs[roleId] = TableSignBoardRoleIdIndexs[roleId] or {}
                    TableSignBoardRoleIdIndexs[roleId][var.ConditionId] = TableSignBoardRoleIdIndexs[roleId][var.ConditionId] or {}
                    table.insert(TableSignBoardRoleIdIndexs[roleId][var.ConditionId], var)
                end
            end
        end
    end
end

--获取表数据
function XSignBoardConfigs.GetSignBoardConfig()
    if not TableSignBoardFeedback then
        return nil
    end

    return TableSignBoardFeedback
end

--获取被动事件
function XSignBoardConfigs.GetPassiveSignBoardConfig(roleId)
    if not TableSignBoardFeedback then
        return nil
    end

    local roleConfigs = XSignBoardConfigs.GetSignBoardConfigByRoldId(roleId)
    if not roleConfigs then
        return
    end

    local configs = {}
    for id,v in ipairs(roleConfigs) do
        if v.ConditionId < 10000 and v.ConditionId >= 100 then --被动事件少于10000 大于=100
            table.insert(configs,v)
        end
    end

    return configs
end

--获取打断的播放
function XSignBoardConfigs.GetBreakPlayElements()
    return TableSignBoardBreak
end

--获取
function XSignBoardConfigs.GetSignBoardConfigById(id)
    if not TableSignBoardFeedback then
        return
    end

    return TableSignBoardFeedback[id]
end


--获取角色所有事件
function XSignBoardConfigs.GetSignBoardConfigByRoldId(roleId)
    local all = {}

    if TableSignBoardRoleIdIndexs and TableSignBoardRoleIdIndexs[roleId] then
        for k, v in pairs(TableSignBoardRoleIdIndexs[roleId]) do
            for i, var in ipairs(v) do
                table.insert(all, var)
            end
        end
    end

    if TableSignBoardIndexs then
        for k, v in pairs(TableSignBoardIndexs) do
            for i, var in ipairs(v) do
                table.insert(all, var)
            end
        end
    end

    return all
end


--获取角色所有事件
function XSignBoardConfigs.GetSignBoardConfigByRoldIdAndCondition(roleId, conditionId)
    local all = {}

    if TableSignBoardRoleIdIndexs and TableSignBoardRoleIdIndexs[roleId] then
        local configs = TableSignBoardRoleIdIndexs[roleId][conditionId]
        if configs then
            for i, v in ipairs(configs) do
                table.insert(all, v)
            end
        end
    end

    if TableSignBoardIndexs and TableSignBoardIndexs[conditionId] then
        for i, v in ipairs(TableSignBoardIndexs[conditionId]) do
            table.insert(all, v)
        end
    end

    return all
end



--根据操作获取表数据
function XSignBoardConfigs.GetSignBoardConfigByFeedback(roleId, conditionId, param)
    if not TableSignBoardRoleIdIndexs then
        return
    end

    local configs = XSignBoardConfigs.GetSignBoardConfigByRoldIdAndCondition(roleId,conditionId)


    if not configs or #configs <= 0 then
        return
    end

    if not param or param < 0 then
        return configs
    end

    local fitterCfg = {}
    for index, var in ipairs(configs) do
        if var.ConditionParam < 0 or var.ConditionParam == param then
            table.insert(fitterCfg, var)
        end
    end

    return fitterCfg
end