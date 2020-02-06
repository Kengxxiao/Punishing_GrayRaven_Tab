XGachaManagerCreator = function()

    local GET_GACHA_DATA_INTERVAL = 15

    local XGachaManager = {}
    local GachaInfos = {}
    local GachaCfg = {}
    local GachaRewardCfg = {}
    local LastGetGachaInfoTimes = {}
    local CurCountOfAll = 0
    local MaxCountOfAll = 0
    local ParseToTimestamp = XTime.ParseToTimestamp
    function XGachaManager.Init()
        GachaCfg = XGachaConfigs.GetGachas()
        GachaRewardCfg = XGachaConfigs.GetGachaReward()
        XGachaManager.SetGachaInfo()

    end

    function XGachaManager.GetGachaInfoList(gaChaId, cb)
       -- local now = XTime.GetServerNowTimestamp()
       -- if LastGetGachaInfoTimes[gaChaId] and now - LastGetGachaInfoTimes[gaChaId] <= GET_GACHA_DATA_INTERVAL then
        --    cb()
        --    return
       -- end
        XNetwork.Call("GetGachaInfoRequest", { Id = gaChaId }, function(res)
                if res.Code ~= XCode.Success then
                    XUiManager.TipCode(res.Code)
                    return
                end
                XGachaManager.UpdataGachaInfo(res.GridInfoList)
                --LastGetGachaInfoTimes[gaChaId] = now
                cb()
            end)
    end

    function XGachaManager.DoGacha(gaChaId, count, cb)
        XNetwork.Call("GachaRequest", { Id = gaChaId, Times = count }, function(res)
                if res.Code ~= XCode.Success then
                    XUiManager.TipCode(res.Code)
                    return
                end
                XGachaManager.UpdataGachaInfo(res.GridInfoList)
                cb(res.RewardList)
            end)
    end

    function XGachaManager.GetGachaInfosById(id)
        MaxCountOfAll = 0
        CurCountOfAll = 0
        local groupIdList = {} 
        for _,groupId in pairs(GachaCfg[id].GroupId) do
            table.insert(groupIdList,groupId)
        end
        
        local list = {}
        for k,v in pairs(GachaInfos) do
            for _,groupId in pairs(groupIdList)do
                if v.GroupId == groupId then
                    table.insert(list,v)
                    break
                end
            end
            
        end
        for k,v in pairs(list) do
            MaxCountOfAll = MaxCountOfAll + v.UsableTimes
            CurCountOfAll = CurCountOfAll + (v.UsableTimes - v.CurCount)
        end
        
        table.sort(list, function(a, b)
                if a.Priority == b.Priority then
                    return a.Id < b.Id
                else
                    return a.Priority > b.Priority
                end
            end)
        return list
    end

    function XGachaManager.GetGachaCfgById(id)
        return GachaCfg[id]
    end

    function XGachaManager.GetCurCountOfAll()
        return CurCountOfAll
    end

    function XGachaManager.GetMaxCountOfAll()
        return MaxCountOfAll
    end

    function XGachaManager.CheckGachaIsOpenById(id,IsShowText)
        
        if IsShowText then
            if not XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.ActivityDrawCard) then
                return false
            end
        else
            if not XFunctionManager.JudgeCanOpen(XFunctionManager.FunctionName.ActivityDrawCard) then
                return false
            end
        end
        local notInTimeStr = nil
        local nowTime = XTime.GetServerNowTimestamp()
        local startTime = ParseToTimestamp(GachaCfg[id].StartTimeStr)
        local endTime = ParseToTimestamp(GachaCfg[id].EndTimeStr)
        local IsClose = nowTime > endTime
        local IsNotOpen = startTime > nowTime
        if IsShowText and IsNotOpen then
            notInTimeStr = "GachaIsNotOpen"
        end
        if IsShowText and IsClose then
            notInTimeStr = "GachaIsClose"
        end
        if notInTimeStr then
            XUiManager.TipText(notInTimeStr) 
        end
        return (not IsClose) and (not IsNotOpen)
    end

    function XGachaManager.UpdataGachaInfo(gridInfoList)
        for k,v in pairs(gridInfoList or {}) do
            if GachaInfos[v.Id] then
                GachaInfos[v.Id].CurCount = GachaInfos[v.Id].UsableTimes - v.Times
            end
        end
    end

    function XGachaManager.SetGachaInfo()
        for id,reward in pairs(GachaRewardCfg) do
            GachaInfos[id] = {}
            for k,v in pairs(reward)do
                GachaInfos[id][k] = v
            end
            GachaInfos[id].CurCount = GachaInfos[id].UsableTimes
        end
    end

    XGachaManager.Init()
    return XGachaManager
end