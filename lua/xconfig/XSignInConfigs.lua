XSignInConfigs = XSignInConfigs or {}

XSignInConfigs.SignType = {
    Daily = 1,             -- 日常签到
    Activity = 2,          -- 活动签到
}

XSignInConfigs.SignOpen = {
    Default = 1,           -- 默认打开
    Level = 2,             -- 等级
    PreFunction  = 3,      -- 前置功能
}

local TABLE_SIGN_IN           = "Share/SignIn/SignIn.tab"
local TABLE_SIGN_IN_REWARD    = "Share/SignIn/SignInReward.tab"
local TABLE_SIGN_IN_SUBROUND  = "Client/SignIn/SubRound.tab"
local TABLE_SIGN_CARD         = "Client/SignIn/SignCard.tab"
local TABLE_SIGN_RECHARGE     = "Client/SignIn/SignFirstRecharge.tab"
local TABLE_SIGN_WELFARE     = "Client/SignIn/Welfare.tab"

local SignInConfig = {}           -- 签到配置表
local SignInRewardConfig = {}     -- 签到奖励配置表[key = signId, value = (key = round, value = {conifig1, config2 ...})]
local SignInSubRound = {}         -- 客户端显示子轮次配置表
local SignCard = {}               -- 客户端月卡签到表
local SignRecharge = {}           -- 首充签到表
local SignWelfareList = {}        -- 福利配置表List
local SignWelfareDir = {}         -- 福利配置表dir

function XSignInConfigs.Init()
    SignInConfig = XTableManager.ReadByIntKey(TABLE_SIGN_IN, XTable.XTableSignIn, "Id")
    SignInSubRound = XTableManager.ReadByIntKey(TABLE_SIGN_IN_SUBROUND, XTable.XTableSignInSubround, "Id")
    SignCard = XTableManager.ReadByIntKey(TABLE_SIGN_CARD, XTable.XTableSignCard, "Id")
    SignRecharge = XTableManager.ReadByIntKey(TABLE_SIGN_RECHARGE, XTable.XTableSignFirstRecharge, "Id")
    SignWelfareDir = XTableManager.ReadByIntKey(TABLE_SIGN_WELFARE, XTable.XTableWelfare, "Id")
    local signInReward = XTableManager.ReadByIntKey(TABLE_SIGN_IN_REWARD, XTable.XTableSignInReward, "Id")

    local signInRewardSort = {}
    -- 按SignId 建表
    for _, v in pairs(signInReward) do
        if not signInRewardSort[v.SignId] then
            signInRewardSort[v.SignId] = {}
        end

        table.insert(signInRewardSort[v.SignId], v)
    end

    -- 按Pre排序
    for _, v in pairs(signInRewardSort) do
        table.sort(v, function (a, b)
            return a.Pre < b.Pre
        end)
    end

    for _, v in pairs(signInRewardSort) do
        local signInRoundTemp = {}
        for _, v2 in ipairs(v) do
            if not SignInRewardConfig[v2.SignId] then
                SignInRewardConfig[v2.SignId] = {}
            end

            if not SignInRewardConfig[v2.SignId][v2.Round] then
                SignInRewardConfig[v2.SignId][v2.Round] = {}
            end

            table.insert(SignInRewardConfig[v2.SignId][v2.Round], v2)
        end
    end

    -- 福利表
    for _, v in pairs(SignWelfareDir) do
        table.insert(SignWelfareList, v)
    end

    table.sort(SignWelfareList, function (a, b)
        return a.Sort < b.Sort
    end)
end

-- 获取福利配置表
function XSignInConfigs.GetWelfareConfigs()
    local setConfig = function(id, name, path, functionType, welfareId)
        local config = {}
        config.Id = id
        config.Name = name
        config.PrefabPath = path
        config.FunctionType = functionType
        config.WelfareId = welfareId
        return config
    end

    local welfareConfigs = {}
    for _, v in pairs(SignWelfareList) do
        if v.FunctionType == XAutoWindowConfigs.AutoFuncitonType.Sign then
            if XDataCenter.SignInManager.IsShowSignIn(v.SubConfigId, true) then
                local t = XSignInConfigs.GetSignInConfig(v.SubConfigId)
                table.insert(welfareConfigs, setConfig(t.Id, t.Name, t.PrefabPath, v.FunctionType, v.Id))
            end
        elseif v.FunctionType == XAutoWindowConfigs.AutoFuncitonType.FirstRecharge then
            if not XDataCenter.PayManager.GetFirstRechargeReward() then
                local t = XSignInConfigs.GetFirstRechargeConfig(v.SubConfigId)
                table.insert(welfareConfigs, setConfig(t.Id, t.Name, t.PrefabPath, v.FunctionType, v.Id))
            end
        elseif v.FunctionType == XAutoWindowConfigs.AutoFuncitonType.Card then
            local t = XSignInConfigs.GetSignCardConfig(v.SubConfigId)
            table.insert(welfareConfigs, setConfig(t.Id, t.Name, t.PrefabPath, v.FunctionType, v.Id))
        end
    end

    return welfareConfigs
end

-- 获取福利配置表
function XSignInConfigs.GetWelfareConfig(id)
    local t = SignWelfareDir[id]
    if not t then
        XLog.Error("XSignInConfigs.GetWelfareConfig Error Config id nil, is " .. tostring(id))
        return nil
    end

    return t
end

-- 通过福利表Id获取PrefabPath
function XSignInConfigs.GetPrefabPath(id)
    local config = XSignInConfigs.GetWelfareConfig(id)

    if config.FunctionType == XAutoWindowConfigs.AutoFuncitonType.Sign then
        local t = XSignInConfigs.GetSignInConfig(config.SubConfigId)
        return  t.PrefabPath
    elseif config.FunctionType == XAutoWindowConfigs.AutoFuncitonType.FirstRecharge then
        local t = XSignInConfigs.GetFirstRechargeConfig(config.SubConfigId)
        return  t.PrefabPath
    elseif config.FunctionType == XAutoWindowConfigs.AutoFuncitonType.Card then
        local t = XSignInConfigs.GetSignCardConfig(config.SubConfigId)
        return  t.PrefabPath
    end

    return nil
end

-- 获取签到配置表
function XSignInConfigs.GetSignInConfig(signInId)
    local t = SignInConfig[signInId]
    if not t then
        XLog.Error("XSignInConfigs.GetSignInConfig Error Config signInId nil, is " .. tostring(signInId))
        return nil
    end

    return t
end

-- 获取子轮次配置表
function XSignInConfigs.GetSubRoundConfig(subRoundId)
    local t = SignInSubRound[subRoundId]
    if not t then
        XLog.Error("XSignInConfigs.GetSubRoundConfig Error Config signInId nil, is " .. tostring(subRoundId))
        return nil
    end

    return t
end

-- 获取月卡签到配置表
function XSignInConfigs.GetSignCardConfig(id)
    local t = SignCard[id]
    if not t then
        XLog.Error("XSignInConfigs.GetSignCardConfig Error Config id nil, is " .. tostring(id))
        return nil
    end

    return t
end

-- 获取首充签到配置表
function XSignInConfigs.GetFirstRechargeConfig(id)
    local t = SignRecharge[id]
    if not t then
        XLog.Error("XSignInConfigs.GetFirstRechargeConfig Error Config id nil, is " .. tostring(id))
        return nil
    end

    return t
end

-- 获取当签到结束是否继续显示签到
function XSignInConfigs.GetSignInShowWhenDayOver(signInId)
    local t = XSignInConfigs.GetSignInConfig(signInId)
    return t.IsShowWhenDayOver
end

-- 获取签到轮次数据List
function XSignInConfigs.GetSignInInfos(signInId)
    local t = XSignInConfigs.GetSignInConfig(signInId)
    local signInfos = {}

    if t.Type == XSignInConfigs.SignType.Activity then
        for i = 1, #t.SubRoundId do
            local subRoundCfg = XSignInConfigs.GetSubRoundConfig(t.SubRoundId[i])
            local signInfo = {}
            signInfo.RoundName = subRoundCfg.SubRoundName[1] or ""
            signInfo.Round = i
            signInfo.Day = subRoundCfg.SubRoundDays[1] or 0
            signInfo.Icon = subRoundCfg.SubRoundIcon[1] or 0
            signInfo.Description = subRoundCfg.SubRoundDesc or ""
            table.insert(signInfos, signInfo)
        end
    else
        local round = XDataCenter.SignInManager.GetSignRound(signInId)
        local subRoundCfg = XSignInConfigs.GetSubRoundConfig(t.SubRoundId[round])

        for i = 1, #subRoundCfg.SubRoundDays do
            local signInfo = {}
            signInfo.RoundName = subRoundCfg.SubRoundName[i] or ""
            signInfo.Round = i
            signInfo.Day = subRoundCfg.SubRoundDays[i] or 0
            signInfo.Icon = subRoundCfg.SubRoundIcon[i] or 0
            signInfo.Description = subRoundCfg.SubRoundDesc or ""
            table.insert(signInfos, signInfo)
        end
    end

    return signInfos
end

local GetDailyRewardConfigs = function(data, sunRoundId, subRound)
    local subRoundCfg = XSignInConfigs.GetSubRoundConfig(sunRoundId)
    local dailyData = {}
    local startIndex = 1
    local endIndex = 1

    for i = 1, #subRoundCfg.SubRoundDays do
        if subRound == i then
            endIndex = endIndex + subRoundCfg.SubRoundDays[i] - 1
            break
        else
            startIndex = startIndex + subRoundCfg.SubRoundDays[i]
            endIndex = startIndex
        end
    end

    for i = startIndex, endIndex do
        table.insert(dailyData, data[i])
    end

    return dailyData
end

-- 获得每轮奖励配置表List
function XSignInConfigs.GetSignInRewardConfigs(signInId, round)
    local signInInfo = SignInRewardConfig[signInId]
    local config = XSignInConfigs.GetSignInConfig(signInId)

    if not signInInfo then
        XLog.Error("XSignInConfigs.GetSignInRewardConfig Error signInInfo is nil, signInId " .. tostring(signInId))
        return nil
    end

    if config.Type == XSignInConfigs.SignType.Daily then
        local curRound =  XDataCenter.SignInManager.GetSignRound(signInId)
        local sunRoundId = config.SubRoundId[curRound]

        local t = signInInfo[curRound]
        local dailyData = GetDailyRewardConfigs(t, sunRoundId, round)
        return dailyData
    else
        local t = signInInfo[round]
        if not t then
            XLog.Error("XSignInConfigs.GetSignInRewardConfig Error round is nil, round " .. tostring(round))
            return nil
        end
        return t
    end
end

-- 判断是否显示
function XSignInConfigs.IsShowSignIn(signInId)
    local isShowSignIn = false
    local t = XSignInConfigs.GetSignInConfig(signInId)
    local startTime = CS.XDate.GetTime(t.StartTimeStr)
    local closeTime = CS.XDate.GetTime(t.CloseTimeStr)
    local now = XTime.Now()

    if now <= startTime and now > closeTime then
        return false
    end

    return true
end

-- 判断最后一轮最后一天获得后是否继续再福利界面显示
function XSignInConfigs.JudgeLastDayGet(signInId, signData)
    local config = XSignInConfigs.GetSignInConfig(signInId)
    if config.Type == XSignInConfigs.SignType.Daily then
        return true
    end

    -- 判断是不是最后一轮
    local t = XSignInConfigs.GetSignInConfig(signInId)
    if #t.RoundDays > signData.Round then
        return true
    end

    -- 判断是不是最后一天
    if t.RoundDays[#t.RoundDays] > signData.Day then
        return true
    end

    -- 最后一天是否签到
    if not signData.Got then
        return true
    end

    -- 配置表是否继续显示
    return config.IsShowWhenSignOver
end

-- 判断是否当前轮的最后一天
function XSignInConfigs.JudgeLastRoundDay(signInId, round, day)
    local t = XSignInConfigs.GetSignInConfig(signInId)
    if not t then
        return false
    end

    if t.Type == XSignInConfigs.SignType.Daily then
        local subRoundCfg = XSignInConfigs.GetSubRoundConfig(t.SubRoundId[round])
        local subDay = 0
        local isLastDay = false
        local subRound = 1
        for i = 1, #subRoundCfg.SubRoundDays do
            subDay = subDay + subRoundCfg.SubRoundDays[i]
            if day <= subDay then
                subRound = i

                if day == subDay then
                    isLastDay = true
                end

                break
            end
        end

        return isLastDay, subRound
    else
        local allDay = t.RoundDays[round]
        return day >= allDay, round
    end
end