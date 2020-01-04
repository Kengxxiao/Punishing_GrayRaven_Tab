

local SignBoardCondition = {
    --邮件
    [XSignBoardEventType.MAIL] = function()
        return XDataCenter.MailManager.GetHasUnDealMail() > 0
    end,

    --任务
    [XSignBoardEventType.TASK] = function()
        if  XDataCenter.TaskManager.GetIsRewardForEx(XDataCenter.TaskManager.TaskType.Story) then
            return true
        end

        if XFunctionManager.JudgeOpen(XFunctionManager.FunctionName.TaskDay) and XDataCenter.TaskManager.GetIsRewardForEx(XDataCenter.TaskManager.TaskType.Daily)  then
            return true
        end

        if XFunctionManager.JudgeOpen(XFunctionManager.FunctionName.TaskActivity) and XDataCenter.TaskManager.GetIsRewardForEx(XDataCenter.TaskManager.TaskType.Activity)  then
            return true
        end

        return false
    end,

    --日活跃
    [XSignBoardEventType.DAILY_REWARD] = function()
        return XDataCenter.TaskManager.CheckHasDailyActiveTaskReward()
    end,

    --登陆
    [XSignBoardEventType.LOGIN] = function(param)
        local loginTime = XDataCenter.SignBoardManager.GetLoginTime()
        local offset = XTime.Now() - loginTime

        return offset <= param
    end,

    --n天没登陆
    [XSignBoardEventType.COMEBACK] = function(param)
        local lastLoginTime = XDataCenter.SignBoardManager.GetlastLoginTime()
        local todayTime = XTime.GetTodayTime()
        local offset = todayTime - lastLoginTime
        local day = math.ceil(offset / 86400)
        return day >= param
    end,

    --收到礼物
    [XSignBoardEventType.RECEIVE_GIFT] = function(param,displayCharacterId)
        return false
    end,

    --赠送礼物
    [XSignBoardEventType.GIVE_GIFT] = function(param,displayCharacterId,eventParam)
        if eventParam == nil then
            return false
        end

        return eventParam.CharacterId == displayCharacterId
    end,

    --战斗胜利
    [XSignBoardEventType.WIN] = function()
        local signBoardEvent = XDataCenter.SignBoardManager.GetSignBoardEvent()
        if signBoardEvent[XSignBoardEventType.WIN] then
            return true
        end
    end,

    --战斗胜利
    [XSignBoardEventType.WINBUT] = function()
        local signBoardEvent = XDataCenter.SignBoardManager.GetSignBoardEvent()
        if signBoardEvent[XSignBoardEventType.WINBUT] then
            return true
        end
    end,

    --战斗失败
    [XSignBoardEventType.LOST] = function()
        local signBoardEvent = XDataCenter.SignBoardManager.GetSignBoardEvent()
        if signBoardEvent[XSignBoardEventType.LOST] then
            return true
        end
    end,

    --战斗失败
    [XSignBoardEventType.LOSTBUT] = function()
        local signBoardEvent = XDataCenter.SignBoardManager.GetSignBoardEvent()
        if signBoardEvent[XSignBoardEventType.LOSTBUT] then
            return true
        end
    end,

    --电量
    [XSignBoardEventType.LOW_POWER] = function(param)
        return XDataCenter.ItemManager.GetCount(XDataCenter.ItemManager.ItemId.ActionPoint) <= param
    end,


    --游戏时间
    [XSignBoardEventType.PLAY_TIME] = function(param)
        local loginTime = XDataCenter.SignBoardManager.GetLoginTime()
        local offset = XTime.Now() - loginTime
        return offset >= param
    end,


    --长时间待机
    [XSignBoardEventType.IDLE] = function(param)
         return true
    end,

    --换人
    [XSignBoardEventType.CHANGE] = function(param,displayCharacterId)
         return displayCharacterId == XDataCenter.SignBoardManager.ChangeDisplayId
    end,
    
    --好感度提升
    [XSignBoardEventType.FAVOR_UP] = function(param,displayCharacterId)
        return true
   end,
}

--看板互动
XSignBoardManagerCreator = function()
    local BREAK_SIGNBOARD_ID = 1 --打断ID
    local XSignBoardManager = {}

    XSignBoardManager.ChangeDisplayId = -1

    local LoginTime = -1 --登录时间
    local LastLoginTime = -1 --上次登录时间
   -- local TodayFirstLoginTime = -1 --今天首次登陆时间

    --记录需要做出反馈的事件
    local SignBoarEvents = {}
    --播放器数据
    local PlayerData = nil

    --播放过的
    local PlayedList = {}

    --初始化
    function XSignBoardManager.Init()
       

        -- --记录今天首次登陆时间
        -- key = tostring(XPlayer.Id) .. "_TodayFirstLoginTime"
        -- TodayFirstLoginTime = CS.UnityEngine.PlayerPrefs.GetInt(key, -1)
        -- if TodayFirstLoginTime < XTime.GetTodayTime(5) then
        --     CS.UnityEngine.PlayerPrefs.SetInt(key, TodayFirstLoginTime)
        -- end
        XEventManager.AddEventListener(XEventId.EVENT_LOGIN_SUCCESS, function()
            local key = tostring(XPlayer.Id) .. "_LastLoginTime"
            LastLoginTime = CS.UnityEngine.PlayerPrefs.GetInt(key, -1)
            LoginTime = XTime.Now()
            if LastLoginTime == -1 then
                LastLoginTime = LoginTime
            end
            CS.UnityEngine.PlayerPrefs.SetInt(key, LoginTime)
        end)
    end

    --获取登陆时间
    function XSignBoardManager.GetLoginTime()
        return LoginTime
    end

    --获取上次登陆时间
    function XSignBoardManager.GetlastLoginTime()
        return LastLoginTime
    end

    --获取事件
    function XSignBoardManager.GetSignBoardEvent()
        return SignBoarEvents
    end

    --
    function XSignBoardManager.GetSignBoardPlayerData()
        if not PlayerData then
            PlayerData = {}
            PlayerData.PlayerList = {} --播放列表
            PlayerData.PlayingElement = nil --播放对象
            PlayerData.PlayedList = {} --播放过的列表
            PlayerData.LastPlayTime = -1 --上次播放时间
        end

        return PlayerData
    end


    --监听
    function XSignBoardManager.OnNotify(event, ...)
        if event == XEventId.EVENT_FIGHT_RESULT then
            local displayCharacterId = XDataCenter.DisplayManager.GetDisplayChar().Id

            local settle = ...
            local info = settle[0]
            local isExist = false

            local beginData = XDataCenter.FubenManager.GetFightBeginData()
            if beginData then
                for k, v in pairs(beginData.CharList) do
                    if v == displayCharacterId then
                        isExist = true
                        break
                    end
                end
            end

            if isExist and info.IsWin then
                SignBoarEvents[XSignBoardEventType.WIN] =  SignBoarEvents[XSignBoardEventType.WIN] or {}
                SignBoarEvents[XSignBoardEventType.WIN].Time = XTime.Now()
            elseif not isExist and info.IsWin then
                SignBoarEvents[XSignBoardEventType.WINBUT] =  SignBoarEvents[XSignBoardEventType.WINBUT] or {}
                SignBoarEvents[XSignBoardEventType.WINBUT].Time = XTime.Now()
            elseif isExist and not info.IsWin then
                SignBoarEvents[XSignBoardEventType.LOST] =  SignBoarEvents[XSignBoardEventType.LOST] or {}
                SignBoarEvents[XSignBoardEventType.LOST].Time = XTime.Now()
            elseif not isExist and not info.IsWin then
                SignBoarEvents[XSignBoardEventType.LOSTBUT] =  SignBoarEvents[XSignBoardEventType.LOSTBUT] or {}
                SignBoarEvents[XSignBoardEventType.LOSTBUT].Time = XTime.Now()
            end

        elseif event == XEventId.EVENT_FAVORABILITY_GIFT then
            local characterId  = ...
            SignBoarEvents[XSignBoardEventType.GIVE_GIFT] =  SignBoarEvents[XSignBoardEventType.GIVE_GIFT] or {}
            SignBoarEvents[XSignBoardEventType.GIVE_GIFT].Time = XTime.Now()
            SignBoarEvents[XSignBoardEventType.GIVE_GIFT].CharacterId = characterId

        end


    end

    --获取互动的事件
    function XSignBoardManager.GetPlayElements(displayCharacterId)
        local elements = XSignBoardConfigs.GetPassiveSignBoardConfig(displayCharacterId)
        if not elements then
            return
        end

        elements = XSignBoardManager.FitterPlayElementByShowTime(elements)
        elements = XSignBoardManager.FitterPlayElementByFavorLimit(elements,displayCharacterId)

        local all = {}

        if not elements then
            return
        end

        for i, tab in ipairs(elements) do

            local param = SignBoarEvents[tab.ConditionId]


            if SignBoardCondition[tab.ConditionId] and SignBoardCondition[tab.ConditionId](tab.ConditionParam,displayCharacterId,param) then
                local element = {}
                element.Id = tab.Id --Id
                element.AddTime = SignBoarEvents[tab.ConditionId] and SignBoarEvents[tab.ConditionId].Time or XTime.Now()  -- 添加事件
                element.StartTime = -1 --开始播放的时间
                element.EndTime = -1 --结束时间
                element.Duration = tab.Duration  --播放持续时间
                element.Validity = tab.Validity --有效期
                element.CoolTime = tab.CoolTime --冷却时间
                element.Weight = tab.Weight --权重
                element.SignBoardConfig = tab
                table.insert(all,element)
            end
        end

      
        table.sort(all,function(a,b)
            return a.Weight > b.Weight
        end) 

        XDataCenter.SignBoardManager.ChangeDisplayId = -1

        return all
    end

    --获取打断的播放
    function XSignBoardManager.GetBreakPlayElements()
        return XSignBoardConfigs.GetBreakPlayElements()
    end

    --通过点击次数获取事件
    function XSignBoardManager.GetRandomPlayElementsByClick(clickTimes,displayCharacterId)

        local configs = XSignBoardConfigs.GetSignBoardConfigByFeedback(displayCharacterId, XSignBoardEventType.CLICK, clickTimes)
        configs = XSignBoardManager.FitterPlayElementByShowTime(configs)
        configs = XSignBoardManager.FitterPlayElementByFavorLimit(configs,displayCharacterId)
        configs = XSignBoardManager.FitterPlayed(configs)
        
        local element = XSignBoardManager.WeightRandomSelect(configs)
        
        if element then
            PlayedList[element.Id] = element
        end

        return element
    end

    --过滤播放过的
    function XSignBoardManager.FitterPlayed(elements)
        if not elements or #elements <= 0 then
            return
        end

        local configs = {}
        for i, v in ipairs(elements) do
            if not PlayedList[v.Id] then
                table.insert(configs,v)
            end
        end

        if #configs <= 0 then
            PlayedList = {}
            return elements
        end

        return configs
    end


    --权重随机算法
    function XSignBoardManager.WeightRandomSelect(elements)
        if not elements or #elements <= 0 then
            return
        end

        if #elements == 1 then
            return elements[1]
        end

        --获取权重总和
        local sum = 0
        for i, v in ipairs(elements) do
            sum = sum + v.Weight
        end

        --设置随机数种子
        math.randomseed(os.time())

        --随机数加上权重，越大的权重，数值越大
        local weightList = {}
        for i, v in ipairs(elements) do
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

        --返回最大的权重值
        local index = weightList[1].Index
        return elements[index]
    end

    --通过显示时间过滤
    function XSignBoardManager.FitterPlayElementByShowTime(elements)
        if not elements or #elements <= 0 then
            return
        end

        local todayTime = XTime.GetTodayTime(0)

        local configs = {}
        local curTime = XTime.Now()
        for i, v in ipairs(elements) do
            if not v.ShowTime then
                table.insert(configs, v)
            else
                local showTime = string.Split(v.ShowTime, "|")
                if #showTime == 2 then
                    local start = tonumber(showTime[1])
                    local stop = tonumber(showTime[2])
                    if curTime >= todayTime + start and curTime <= stop + todayTime then
                        table.insert(configs, v)
                    end
                end
            end
        end

        return configs
    end

    --通过好感度过滤
    function XSignBoardManager.FitterPlayElementByFavorLimit(elements,displayCharacterId)

        if not elements or #elements <= 0 then
            return
        end

        local favor =  XDataCenter.FavorabilityManager.GetCurrCharacterFavorabilityLevel(displayCharacterId)
        local configs = {}

        for i, v in ipairs(elements) do
            if not v.FavorLimit then
                table.insert(configs, v)
            else
                local showTime = string.Split(v.FavorLimit, "|")
                if #showTime == 2 then
                    local start = tonumber(showTime[1])
                    local stop = tonumber(showTime[2])
                    if favor >= start and favor <= stop then
                        table.insert(configs, v)
                    end
                end
            end
        end

        return configs
    end

    function XSignBoardManager.ChangeDisplayCharacter(id)
        XSignBoardManager.ChangeDisplayId = id
        PlayedList = {}
    end


    XSignBoardManager.Init()
    return XSignBoardManager
end
