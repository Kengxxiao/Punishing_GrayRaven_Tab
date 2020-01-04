XPersonalInfoManagerCreator = function()

    local XPersonalInfoManager = {}

    local PanelPersonalInfo = nil

    local DailyItemsPools = {}--自己日记item缓存池
    local OtherDailyItemsPools = {}--其它人日记item缓存池
    local DailyServerDataPools = {} --服务器数据缓存池

    local DailyDict = {}
    local PlayerId = nil
    local LeaveMsgs = {}
    local curPage = 1

    XPersonalInfoManager.ItemPanelType = {
        NorDaily = 1,
        DailyleaveMsg = 2,
    }

    XPersonalInfoManager.OpenViewType = {
        Personal = 1,
        Social = 2,
    }
    local FettersTemplates = {}

    local showLog = false
    function XPersonalInfoManager.DebugLog(...)
        if showLog then
            XLog.Error(...)
        end
    end

    function XPersonalInfoManager.Init()
    end

    function XPersonalInfoManager.ReqShowInfoPanel(id, loadCompleteCB, closeCB, chatContent)--查看个人信息
        if id == XPlayer.Id then
            --CS.XUiManager.ViewManager:Push("UiPlayer", false, false)
            if loadCompleteCB then
                loadCompleteCB()
            end
            XLuaUiManager.Open("UiPlayer", closeCB)
            return
        end
        --查看个人信息
        XDataCenter.PlayerInfoManager.RequestPlayerInfoData(id, function(data)
            XLuaUiManager.Open("UiPlayerInfo", data, chatContent)
            if loadCompleteCB then
                loadCompleteCB()
            end
        end)
    end

    --日记模块
    function XPersonalInfoManager.RefreshLeaveMsgData(id, pageNum, cb)
        if PlayerId ~= nil then
            XPersonalInfoManager.LookOverLeaveMsg(id, pageNum, cb)
        end
    end

    function XPersonalInfoManager.RefreshDailyData(pageNum, cb)
        if PlayerId ~= nil then
            XPersonalInfoManager.GetDailys(PlayerId, pageNum, cb)
        end
    end

    function XPersonalInfoManager.OpenInputView(cb)
        if XPersonalInfoManager.PanelMsgBoard ~= nil then
            XPersonalInfoManager.PanelMsgBoard.XUiPanelWriteDiary:OpenView(cb)
        end
    end

    --增加管理对象
    function XPersonalInfoManager.AddPanelPersonalInfo(obj)
        PanelPersonalInfo = obj
    end
    --End 增加管理对象
    --Protolcol Model
    local DAILY_SERVICE_NAME = "XDailyService"
    local PROTOL_METHOD_NAME = {
        GetDailys = "GetDailysRequest",
        WriteDaily = "WriteDailyRequest",
        GiveALike = "GiveLikeRequest",
        AddLeaveMsg = "LeaveMsgRequest",
        LookOverLeaveMsg = "LookOverLeaveMsgRequest",
        DeleteDaily = "DeleteDailyRequest",
        DeleteLeaveMsg = "DeleteLeaveMsgRequest",
        BanWriteMsg = "BanMsgRequest",
        ViewPersonalInfo = "ViewPersonalInfoRequest"
    }

    function XPersonalInfoManager.GetDailys(playerId, pageNum, cb)--获得日记内容,cb一般是用来刷新界面回调
        local curPageNum = pageNum
        PlayerId = playerId
        local req = { PlayerId = playerId, PageNum = pageNum }
        XNetwork.Call(PROTOL_METHOD_NAME.GetDailys, req,
        function(response)
            if response.Code ~= XCode.Success then
                XUiManager.TipCode(response.Code)
                return
            end
            local pool = XPersonalInfoManager.GetPool(DailyServerDataPools, pageNum)
            for i = 1, #pool do--清除原有数据
                table.remove(pool)
            end
            XTool.LoopCollection(response.DailyList, function(data)
                table.insert(pool, data)
                DailyDict[data.Id] = data
            end)
            if cb then
                cb()
            end
        end)
    end

    function XPersonalInfoManager.WriteDaily(content, cb)--写日记
        local req = { DailyContent = content }
        XNetwork.Call(PROTOL_METHOD_NAME.WriteDaily, req,
        function(response)
            if response.Code ~= XCode.Success then
                XUiManager.TipCode(response.Code)
                return
            end
            if cb then
                cb()
            end
        end)
    end

    function XPersonalInfoManager.GiveALike(playerId, dailyId, cb)--点赞
        local req = { PlayerId = playerId, DailyId = dailyId }
        XNetwork.Call(PROTOL_METHOD_NAME.GiveALike, req,
        function(response)
            if response.Code == XCode.DailyGiveALikeFail then
                XUiManager.TipCode(response.Code)
                return
            end
            if response.Code == XCode.DailyAddLikeSuccess and cb then
                cb(true)
                return
            end
            if response.Code == XCode.DailyDelLikeSuccess and cb then
                cb(false)
                return
            end
        end)
    end

    function XPersonalInfoManager.AddLeaveMsg(playerId, dailyId, content, cb)--留言
        local req = { PlayerId = playerId, DailyId = dailyId, LeaveMsg = content }
        XNetwork.Call(PROTOL_METHOD_NAME.AddLeaveMsg, req,
        function(response)
            if response.Code ~= XCode.Success then
                XUiManager.TipCode(response.Code)
                return
            end
            if cb then
                cb()
                return
            end
        end)
    end

    function XPersonalInfoManager.LookOverLeaveMsg(id, pageNum, cb)--查看留言
        local req = { PlayerId = PlayerId, DailyId = id }
        XNetwork.Call(PROTOL_METHOD_NAME.LookOverLeaveMsg, req,
        function(response)
            if response.Code ~= XCode.Success then
                XUiManager.TipCode(response.Code)
                return
            end
            local pool = XPersonalInfoManager.GetPool(DailyServerDataPools, pageNum)
            for k, v in pairs(pool) do
                if v.Id == id then
                    v.Msgs = {}
                    XTool.LoopCollection(response.MsgArray, function(data)
                        table.insert(v.Msgs, data)
                    end)
                    break
                end
            end
            if cb then
                cb()
                return
            end
        end)
    end

    function XPersonalInfoManager.DeleteDaily(id, cb)--删除日记
        local req = { DailyId = id }
        XNetwork.Call(PROTOL_METHOD_NAME.DeleteDaily, req,
        function(response)
            if response.Code ~= XCode.Success then
                XUiManager.TipCode(response.Code)
                return
            end
            if cb then
                cb()
                return
            end
        end)
    end

    function XPersonalInfoManager.DeleteLeaveMsg(dailyId, msgId, cb)--删除留言
        local req = { DailyId = dailyId, MsgId = msgId }
        XNetwork.Call(PROTOL_METHOD_NAME.DeleteLeaveMsg, req,
        function(response)
            if response.Code ~= XCode.Success then
                XUiManager.TipCode(response.Code)
                return
            end
            if DailyDict[dailyId] ~= nil then
                DailyDict[dailyId].LeaveMsgCount = DailyDict[dailyId].LeaveMsgCount - 1
            end
            if cb then
                cb()
                return
            end
        end)
    end


    function XPersonalInfoManager.BanWriteMsg(id, cb)--禁止留言
        local req = { DailyId = id }
        XNetwork.Call(PROTOL_METHOD_NAME.BanWriteMsg, req,
        function(response)
            if response.Code ~= XCode.Success then
                XUiManager.TipCode(response.Code)
                return
            end
            if cb then
                cb()
                return
            end
        end)
    end

    function XPersonalInfoManager.ViewPersonalInfo(findId, cb)
        XNetwork.Call(PROTOL_METHOD_NAME.ViewPersonalInfo, { viewId = findId }, function(response)
            if response.Code ~= XCode.Success then
                XUiManager.TipCode(response.Code)
                return
            end
            if cb then
                cb(response.Code, response.data)
            end
        end)
    end

    --End Protolcol Model
    --Create Pool
    function XPersonalInfoManager.GetPool(findPools, poolIndex)
        if not findPools then
            findPools = {}
        end
        local pool = findPools[poolIndex]
        if not pool then
            pool = {}
            findPools[poolIndex] = pool
        end
        return pool
    end
    local GetLeaveMsgsById = function(pageNum, id)--取出当前Id的留言消息
        LeaveMsgs = {}
        local pool = XPersonalInfoManager.GetPool(DailyServerDataPools, pageNum)
        for k, v in pairs(pool) do
            if v.Id == id then
                XTool.LoopCollection(v.Msgs, function(data)
                    table.insert(LeaveMsgs, data)
                end)
                return LeaveMsgs
            end
        end
        return LeaveMsgs
    end

    local GetCallback = function(pageNum, id)
        return function(item, data, i)
            item:SetProperty(data, i, pageNum, id)
        end
    end

    function XPersonalInfoManager.CreateItems(rootUi, item, parent, pageNum, id, selType, callback)
        --pageNum页数 --id页数item里面的ID
        local pool = selType == XPersonalInfoManager.ItemPanelType.DailyleaveMsg and XPersonalInfoManager.GetPool(XPlayer.Id == PlayerData.Id and DailyItemsPools or OtherDailyItemsPools, tonumber(pageNum .. id)) or XPersonalInfoManager.GetPool(XPlayer.Id == PlayerData.Id and DailyItemsPools or OtherDailyItemsPools, pageNum)
        local datas = selType == XPersonalInfoManager.ItemPanelType.DailyleaveMsg and GetLeaveMsgsById(pageNum, id) or XPersonalInfoManager.GetPool(DailyServerDataPools, pageNum)
        local ctor = selType == XPersonalInfoManager.ItemPanelType.DailyleaveMsg and XUiPanelLeaveMsgItem.New or XUiPanelMsgBoardItem.New
        local template = item
        local parent = parent
        local onCreate = GetCallback(pageNum, id)
        --1 对象池 2 数据源 3 Item构造 4 Clone源 5 Parent 6 create 7 Callback
        XPersonalInfoManager.CreateTemplateItems(rootUi, pool, datas, ctor, template, parent, onCreate, callback)
    end

    function XPersonalInfoManager.CreateTemplateItems(rootUi, pool, datas, ctor, template, parent, onCreate, callback)
        local tempTable = {}
        local poolCount = #pool
        if template then
            template.gameObject:SetActive(false)
        end
        for i = 1, #datas do
            local data = datas[i]
            local item = nil
            if i <= poolCount then
                item = pool[i]
            else
                if i == 1 then
                    item = template
                else
                    item = CS.UnityEngine.Object.Instantiate(template)
                end
                item.transform:SetParent(parent, false)
                item.transform.localEulerAngles = CS.UnityEngine.Vector3.zero
                item.transform.localScale = CS.UnityEngine.Vector3.one
                item = ctor(rootUi, item)
                pool[i] = item
            end
            if onCreate then
                onCreate(item, data, i)
            end
            table.insert(tempTable, item)
        end
        for i = #datas + 1, #pool do
            local item = pool[i]
            item.GameObject:SetActive(false)
        end
        if callback then
            callback(tempTable)
        end
    end

    --End Create Pool
    function XPersonalInfoManager.OnDispose(...)
        if PlayerId ~= nil and XPlayer.Id == PlayerId then
            DailyItemsPools = {}
        else
            OtherDailyItemsPools = {}
        end
        DailyServerDataPools = {}
        PlayerId = nil
        LeaveMsgs = {}
        curPage = 1
        XPersonalInfoManager.PanelMsgBoard = nil
        PanelPersonalInfo = nil
    end

    XPersonalInfoManager.Init()
    return XPersonalInfoManager
end