XSignInManagerCreator = function()
    local XSignInManager = {}

    local SignInData = {}                   -- 签到数据
    local SignInRequest = {SignInRequest = "SignInRequest"} -- 签到请求
    local NotifySignIn = false     -- 是否打出服务器推送签到

    -- 推送初始化数据
    function XSignInManager.InitData(data)
        if not data then
            return
        end

        SignInData = {}
        for _, v in ipairs(data) do
            SignInData[v.Id] = v
        end
    end

    -- 获取数据
    function XSignInManager.GetSignInData(signInId)
        local t = SignInData[signInId]
        if not t then
            return nil
        end

        return t
    end

    -- 获取当前轮次
    function XSignInManager.GetSignRound(signInId, isDistinguishType)
        local t = XSignInConfigs.GetSignInConfig(signInId)
        local signData = XSignInManager.GetSignInData(signInId)
        if not signData then
            return 1
        end

        if not isDistinguishType then
            return signData.Round
        end

        if t.Type == XSignInConfigs.SignType.Activity then
            return signData.Round
        else
            local subRoundId = t.SubRoundId[signData.Round]
            local subRoundCfg = XSignInConfigs.GetSubRoundConfig(subRoundId)
            local day = 0
            for i = 1, #subRoundCfg.SubRoundDays do
                day = day + subRoundCfg.SubRoundDays[i]
                if signData.Day <= day then
                    return i
                end
            end
        end
    end

    -- 获取当前天数
    function XSignInManager.GetSignDay(signInId)
        local signData = XSignInManager.GetSignInData(signInId)
        if not signData then
            return 1
        end

        return signData.Day
    end

    -- 设置已经签到领取奖励
    function XSignInManager.SetSignRewardGet(signInId)
        local signData = XSignInManager.GetSignInData(signInId)
        if not signData then
            return
        end
        signData.Got = true
    end

    -- 判断是否显示
    function XSignInManager.IsShowSignIn(signInId, isSignInUi)
        if not XSignInConfigs.IsShowSignIn(signInId) then
            return false
        end

        local signData = XSignInManager.GetSignInData(signInId)
        if not signData then
            return false
        end

        if isSignInUi then
            return XSignInConfigs.JudgeLastDayGet(signInId, signData)
        end

        local isShowWhenDayOver = XSignInConfigs.GetSignInShowWhenDayOver(signInId)
        if not isShowWhenDayOver and signData.Got then
            return false
        end

        return true
    end

    -- 判断是否已经领取过
    function XSignInManager.JudgeAlreadyGet(signInId, round, day)
        local signData = XSignInManager.GetSignInData(signInId)
        if not signData then
            return false
        end

        if round < signData.Round then
            return true
        end

        if round == signData.Round and day < signData.Day then
            return true
        end

        if round == signData.Round and day == signData.Day then
            return signData.Got
        end

        return false
    end

    -- 判断是否是明日领取
    function XSignInManager.JudgeTomorrow(signInId, round, day)
        local signData = XSignInManager.GetSignInData(signInId)
        if not signData then
            return false
        end

        local isRoundLastDay = XSignInConfigs.JudgeLastRoundDay(signInId, signData.Round, signData.Day)
        local t = XSignInConfigs.GetSignInConfig(signInId)

        if isRoundLastDay and t.Type == XSignInConfigs.SignType.Activity then
            if round == signData.Round + 1 and day == 1 then
                return true
            end
        else
            if round == signData.Round and day == signData.Day + 1 then
                return true
            end
        end

        return false
    end

    -- 判断是否是今日领取
    function XSignInManager.JudgeTodayGet(signInId, round, day)
        local isToday = false
        local isGet = false

        local signData = XSignInManager.GetSignInData(signInId)
        if not signData then
            return isToday, isGet
        end

        if round == signData.Round and day == signData.Day then
            isToday = true
            isGet = signData.Got
        end

        return isToday, isGet
    end

    -- 设置推送签到
    function XSignInManager.SetNotifySign(isNotify)
        NotifySignIn = isNotify
    end

    -- 判断是否有推送签到
    function XSignInManager.CheckNotifySign()
        return NotifySignIn
    end

    -- 领取签到奖励请求
    function XSignInManager.SignInRequest(signInId, successCb, failCb)
        XNetwork.Call(SignInRequest.SignInRequest, { Id = signInId }, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                if failCb then
                    failCb()
                end
                return
            end

            XSignInManager.SetSignRewardGet(signInId)
            if successCb then
                successCb(res.RewardGoodsList)
            end
        end)
    end

    return XSignInManager
end

XRpc.NotifySignInData = function(data)
    XDataCenter.SignInManager.InitData(data.SignInfos)
    XDataCenter.SignInManager.SetNotifySign(true)
end