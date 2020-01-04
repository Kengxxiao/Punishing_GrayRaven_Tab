XTrialManagerCreator = function()
    local XTrialManager = {}
    local TrialInfos = nil
    local PreFinishTrial = {}
    local IsTrialChanllenge = false

    XTrialManager.TrialTypeCfg = {
        TrialFor = 1,
        TrialBackEnd = 2
    }
    --关卡打开，玩家点过后红点消失。
    XTrialManager.UnLockRed = false
    -- Rpc请求
    -- 领取关卡奖励
    function XTrialManager.OnTrialPassRewardRequest(trialId, cb)
        if not trialId then
            return
        end
        XTrialManager.TrialRewardId = trialId
        XNetwork.Call(
        "TrialPassRewardRequest",
        { TrialId = trialId },
        function(res)
            cb = cb or function()
            end

            if res.Code == XCode.Success then
                if not TrialInfos then
                    TrialInfos = {}
                    TrialInfos.rewardRecord = {}
                end
                TrialInfos.rewardRecord[trialId] = trialId
                local rewardGoodsList = res.RewardGoodsList
                cb(rewardGoodsList)
            else
                XUiManager.TipCode(res.Code)
            end
        end
        )
    end

    -- 领取类型奖励
    function XTrialManager.OnTrialTypeRewardRequest(trialType, cb)
        if not trialType then
            return
        end

        XNetwork.Call(
        "TrialTypeRewardRequest",
        { Type = trialType },
        function(res)
            cb = cb or function()
            end
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            if not TrialInfos then
                TrialInfos = {}
                TrialInfos.typeRewardRecord = {}
            end

            TrialInfos.typeRewardRecord[trialType] = trialType
            local rewardGoodsList = res.RewardGoodsList
            cb(rewardGoodsList)
        end
        )
    end

    -- 通知更新角色信息
    function XTrialManager.OnTrialInfoUpdate(response)
        if response then --有通关
            TrialInfos = {}
            TrialInfos.finishTrial = response.FinishTrial
            TrialInfos.rewardRecord = {}
            XTool.LoopMap(response.RewardRecord, function(k, v)
                TrialInfos.rewardRecord[v] = v
            end)
            TrialInfos.typeRewardRecord = response.TypeRewardRecord
            PreFinishTrial = TrialInfos.finishTrial
        else
            TrialInfos = nil
        end
    end

    -- 判断当前完成到前段还是后段关卡,前段返回1，后段返回2。
    function XTrialManager.FinishTrialType()
        if (not TrialInfos) or (not TrialInfos.finishTrial) then
            return XDataCenter.TrialManager.TrialTypeCfg.TrialFor
        end

        local finishtrial = TrialInfos.finishTrial
        local forcfgdata = XTrialConfigs.GetForTotalData(XDataCenter.TrialManager.TrialTypeCfg.TrialFor)
        for _, v in pairs(forcfgdata) do
            if finishtrial[v.Id] ~= v.Id then --没有在里面，前段没有完成。
                return XDataCenter.TrialManager.TrialTypeCfg.TrialFor
            end
        end

        return XDataCenter.TrialManager.TrialTypeCfg.TrialBackEnd
    end

    -- 判断当前关卡是否已经领取了奖励，levelId-->TrialChallenge表Id,false:没有 true：领了
    function XTrialManager.TrialRewardGeted(trialId)
        if (not TrialInfos) or (not TrialInfos.rewardRecord) then
            return false
        end

        local rewardRecord = TrialInfos.rewardRecord
        return rewardRecord[trialId] == trialId
    end

    -- 判断当前关卡是否完成,trialId-->TrialChallenge表Id,false:没有 true：过了
    function XTrialManager.TrialLevelFinished(trialId)
        if (not TrialInfos) or (not TrialInfos.finishTrial) then
            return false
        end

        local finishtrial = TrialInfos.finishTrial
        return finishtrial[trialId] == trialId
    end

    -- 判断类型奖励是否领过。false:没有 true:领过(总)
    function XTrialManager.TypeRewardGeted()
        return TrialInfos and TrialInfos.typeRewardRecord
    end

    -- 判断当前类型奖励是否已经领了。false:没有 true:领过
    function XTrialManager.TypeRewardByTrialtype(trialtype)
        if not XTrialManager.TypeRewardGeted() then
            return false
        end

        local typeRewardRecord = TrialInfos.typeRewardRecord
        return typeRewardRecord[trialtype] == trialtype
    end

    -- 判断当前关卡是否是否解锁,trialId-->TrialChallenge表Id,false:没有解锁，true:解锁
    function XTrialManager.TrialLevelLock(trialId)
        local trialcfg = XTrialConfigs.GetForDataByLevel(trialId) or
        XTrialConfigs.GetBackEndDataByLevel(trialId - XTrialConfigs.GetForTotalLength())

        local level = XPlayer.Level or 0
        if not trialcfg or trialcfg.Unlocklevel > level then
            return false
        end

        return trialcfg.PreId == 0 or XDataCenter.TrialManager.TrialLevelFinished(trialcfg.PreId)
    end

    -- 打过关卡
    function XTrialManager.OnSettleTrial()
        local res = XDataCenter.FubenManager.FubenSettleResult
        if not res or not res.Settle then
            return
        end

        local settle = res.Settle
        local isWin = settle.IsWin and res.Code == 0
        if not isWin then
            return
        end

        local StageId = settle.StageId
        local forcfgdata = XTrialConfigs.GetForTotalData()
        for _, v in pairs(forcfgdata) do
            if v.StageId == StageId then
                XDataCenter.TrialManager.TrialLevelPassState(v.Id)
            end
        end

        local backendcfgdata = XTrialConfigs.GetBackEndTotalData()
        for _, v in pairs(backendcfgdata) do
            if v.StageId == StageId then
                XDataCenter.TrialManager.TrialLevelPassState(v.Id)
            end
        end
    end
    -- 关卡通关改状态,trialId-->TrialChallenge表Id,stageId-->关卡Id
    function XTrialManager.TrialLevelPassState(trialId, stageId)
        if not TrialInfos then
            TrialInfos = {}
            TrialInfos.finishTrial = {}
        end

        XDataCenter.TrialManager.SetTrialFinishJustState(true)
        TrialInfos.finishTrial[trialId] = trialId
        XEventManager.DispatchEvent(XEventId.EVENT_TRIAL_LEVEL_FINISH, stageId)
    end

    -- 判断前段是否刚好完成
    function XTrialManager.ForTrialFinishJust()
        if XDataCenter.TrialManager.FinishTrialType() ~= XDataCenter.TrialManager.TrialTypeCfg.TrialBackEnd then
            return false
        end

        return XTrialConfigs.GetForTotalLength() == #TrialInfos.finishTrial --刚好完成前段
    end

    -- 判断后段是否刚好完成
    function XTrialManager.BackEndTrialFinishJust()
        if XDataCenter.TrialManager.FinishTrialType() ~= XDataCenter.TrialManager.TrialTypeCfg.TrialBackEnd then
            return false
        end

        local cfg = XTrialConfigs.GetBackEndTotalData()
        for _, v in pairs(cfg) do
            if not TrialInfos.finishTrial[v.Id] then
                return false
            end
        end

        return true
    end

    -- 是否刚通关
    function XTrialManager.IsTrialFinishJust()
        return IsTrialChanllenge
    end

    -- 设置是否刚通关
    function XTrialManager.SetTrialFinishJustState(state)
        IsTrialChanllenge = state
    end

    -- 判断是否要打开入口 true:打开 false:关闭
    --条件-->所有关卡打过&&奖励都领完。
    function XTrialManager.EntranceOpen()
        -- 判断类型奖励
        for _, v in pairs(XDataCenter.TrialManager.TrialTypeCfg) do
            if not XDataCenter.TrialManager.TypeRewardByTrialtype(v) and XDataCenter.TrialManager.TrialTypeRewardGeted(v) then
                return true
            end
        end

        -- 判断关卡是否通过而且奖励是否已经领取
        local cfg = XTrialConfigs.GetForTotalData()
        for _, v in pairs(cfg) do
            if not XDataCenter.TrialManager.TrialLevelFinished(v.Id) or not XDataCenter.TrialManager.TrialRewardGeted(v.Id) then
                return true
            end
        end

        cfg = XTrialConfigs.GetBackEndTotalData()
        for _, v in pairs(cfg) do
            if not XDataCenter.TrialManager.TrialLevelFinished(v.Id) or not XDataCenter.TrialManager.TrialRewardGeted(v.Id) then
                return true
            end
        end
        return false
    end

    -- 红点相关
    -- 判断该关卡奖励是否可领,trialId-->TrialChallenge表Id
    function XTrialManager.TrialLevelRewardGetSignRedPoint(trialId)
        if XDataCenter.TrialManager.TrialLevelFinished(trialId) and not XDataCenter.TrialManager.TrialRewardGeted(trialId) then
            return true
        end
        return false
    end

    -- 判断该关卡是否刚刚解锁,trialId-->TrialChallenge表Id。关卡打完，角色等级变化都需要判断一下。
    function XTrialManager.TrialLevelLockSignRedPoint()
        local playerLevel = XPlayer.Level or 1
        -- 通关的时候
        local finishTrial = TrialInfos.finishTrial
        local trialId = -1
        for k, v in pairs(finishTrial) do
            if not PreFinishTrial[v] then
                trialId = v
                PreFinishTrial[v] = trialId
            end
        end

        if not XDataCenter.TrialManager.PreLevel or XDataCenter.TrialManager.PreLevel < playerLevel then
            XDataCenter.TrialManager.PreLevel = playerLevel
            XDataCenter.TrialManager.UnLockRed = false
        end

        if XDataCenter.TrialManager.UnLockRed then
            return false
        end

        if trialId ~= -1 then
            local cfg = XTrialConfigs.GetForDataByLevel(trialId) or XTrialConfigs.GetBackEndDataByLevel(trialId - XTrialConfigs.GetForTotalLength())
            if cfg and cfg.Unlocklevel <= playerLevel then
                return true
            end
        end

        -- 等级
        local finishTrial = TrialInfos.finishTrial
        local cfg = XTrialConfigs.GetForTotalData()
        if XDataCenter.TrialManager.FinishTrialType() == XDataCenter.TrialManager.TrialTypeCfg.TrialBackEnd then
            cfg = XTrialConfigs.GetBackEndTotalData()
        end

        for _, v in pairs(cfg) do
            if not finishTrial[v.Id] then
                if v.Unlocklevel <= playerLevel then
                    return true
                end
            end
        end

        return false
    end

    --判断类型奖励是否可领
    function XTrialManager.TrialTypeRewardRedPoint()
        for k, v in pairs(XDataCenter.TrialManager.TrialTypeCfg) do
            if XDataCenter.TrialManager.TypeRewardByTrialtype(v) and not XDataCenter.TrialManager.TrialTypeRewardGeted(v) then
                return true
            end
        end

        return false
    end

    -- 前段打到第几关
    function XTrialManager.TrialForFinishLevel()
        local cfg = XTrialConfigs.GetForTotalData()

        for k, v in pairs(cfg) do
            if v then
                if not XDataCenter.TrialManager.TrialLevelFinished(v.Id) then
                    return v.Id - 1
                end
            end
        end

        return XTrialConfigs.GetForTotalLength()
    end

    -- 后段打到第几关
    function XTrialManager.TrialBackEndFinishLevel()
        local cfg = XTrialConfigs.GetBackEndTotalData()

        for k, v in pairs(cfg) do
            if v then
                if not XDataCenter.TrialManager.TrialLevelFinished(v.Id) then
                    return v.Id - XTrialConfigs.GetForTotalLength() - 1
                end
            end
        end

        return XTrialConfigs.GetBackEndTotalLength()
    end

    -- 是否所有关卡打完
    function XTrialManager.IsAllLevelFinish()
        local cfg = XTrialConfigs.GetForTotalData() or {}

        for k, v in pairs(cfg) do
            if v then
                if not XDataCenter.TrialManager.TrialLevelFinished(v.Id) then
                    return false
                end
            end
        end

        cfg = XTrialConfigs.GetBackEndTotalData() or {}

        for k, v in pairs(cfg) do
            if v then
                if not XDataCenter.TrialManager.TrialLevelFinished(v.Id) then
                    return false
                end
            end
        end

        return true
    end
    -- 前段奖励是否领完
    function XTrialManager.TrialRewardGetedFinish()
        local cfg = XTrialConfigs.GetForTotalData()

        for k, v in pairs(cfg) do
            if v then
                if not XDataCenter.TrialManager.TrialRewardGeted(v.Id) then
                    return false
                end
            end
        end

        return true
    end

    -- 后段奖励是否领完
    function XTrialManager.TrialRewardGetedBackEndFinish()
        local cfg = XTrialConfigs.GetBackEndTotalData()

        for k, v in pairs(cfg) do
            if v then
                if not XDataCenter.TrialManager.TrialRewardGeted(v.Id) then
                    return false
                end
            end
        end

        return true
    end

    -- 判断前段奖励领取是不是最后一关
    function XTrialManager.TrialRewardIdIsForEnd()
        local cfg = XTrialConfigs.GetForTotalData()

        if not XTrialManager.TrialRewardId or not cfg or not cfg[#cfg] or XTrialManager.TrialRewardId ~= cfg[#cfg].Id then
            return false
        end
        return true
    end

    -- 前段奖励领了多少
    function XTrialManager.TrialRewardGetedForCount()
        local cfg = XTrialConfigs.GetForTotalData()
        local count = 0

        for k, v in pairs(cfg) do
            if v then
                if XDataCenter.TrialManager.TrialRewardGeted(v.Id) then
                    count = count + 1
                end
            end
        end

        return count
    end

    -- 后段奖励领了多少
    function XTrialManager.TrialRewardGetedBackEndCount()
        local cfg = XTrialConfigs.GetBackEndTotalData()
        local count = 0

        for k, v in pairs(cfg) do
            if v then
                if XDataCenter.TrialManager.TrialRewardGeted(v.Id) then
                    count = count + 1
                end
            end
        end

        return count
    end
    -- 关卡奖励领取完判断
    function XTrialManager.TrialTypeRewardGeted(trialtype)
        if trialtype == XDataCenter.TrialManager.TrialTypeCfg.TrialFor then
            return XDataCenter.TrialManager.TrialRewardGetedFinish()
        end

        return XDataCenter.TrialManager.TrialRewardGetedBackEndFinish()
    end
    XEventManager.AddEventListener(XEventId.EVENT_FUBEN_SETTLE_REWARD, XTrialManager.OnSettleTrial, XTrialManager)

    function XTrialManager.InitStageInfo()
        local forcfgdata = XTrialConfigs.GetForTotalData(XDataCenter.TrialManager.TrialTypeCfg.TrialFor)
        for id, v in pairs(forcfgdata) do
            local stageInfo = XDataCenter.FubenManager.GetStageInfo(v.StageId)
            stageInfo.Type = XDataCenter.FubenManager.StageType.Trial
        end
    end

    return XTrialManager
end

-- 记录玩家---完成的关卡、奖励记录、类型奖励记录
-- 完成的关卡-->对应TrialChallenge表的id
-- 奖励记录-->对应TrialTypeReward表的id
-- 类型奖励记录-->1:前段，2：后段。
XRpc.NotifyTrialData = function(response)
    XDataCenter.TrialManager.OnTrialInfoUpdate(response)
end