---
--- 宿舍业务管理器
---
XDormManagerCreator = function()
    local XDormManager = {}

    local CharacterData = {}  -- 构造体数据
    local DormitoryData = {}  -- 宿舍数据
    local VisitorData = {}  -- 宿舍访客数据
    local WorkListData = {} --打工数据(正在打工或者打完工但是奖励没有领)
    local WorkRefreshTime = -1 --打工刷新时间
    local RecommVisData = {} --推荐访问数据
    local RecommVisIds = {}
    local RecommVisFriendData = {}

    local LastSyncServerTime = 0 -- 爱抚水枪上一次请求时间
    local DormShowEventList = {}  -- 构造体客户端展示事件效果列表
    local IsPlayingShowEvent = false  -- 现在是否在播放展示事件
    local IsInTouch = false  -- 是否再爱抚中
    local OneDaySecond = 86400

    local TargetDormitoryData = {}  --别人宿舍数据
    local TargetCharacterData = {} -- 构造体数据(访问其他人时)
    local TargetVisitorData = {} -- 宿舍访问数据(访问其他人时)

    local DormRedTimer

    local DormitoryRequest = {
        DormitoryDataReq = "DormitoryDataRequest", -- 宿舍总数据请求
        ActiveDormItemReq = "ActiveDormItemRequest", --激活宿舍
        DormRenameReq = "DormRenameRequest", --房间改名
        PutFurnitureReq = "PutFurnitureRequest", --摆放家具请求

        DormEnterReq = "DormEnterRequest", --进入宿舍通知
        DormExitReq = "DormOutRequest", --退出宿舍通知

        DormCharacterOperateReq = "DormCharacterOperateRequest", --构造体处理事件反馈
        DormRemoveCharacterReq = "DormRemoveCharacterRequest", --拿走构造体
        DormPutCharacterReq = "DormPutCharacterRequest", --放置构造体
        CheckCreateFurnitureReq = "CheckCreateFurnitureRequest", --请求刷新家具建造列表
        DormRecommendReq = "DormRecommendRequest", --推荐访问
        DormDetailsReq = "DormDetailsRequest", --宿舍访问时的详细信息
        DormVisitReq = "DormVisitRequest", --访问宿舍
        DormWorkReq = "DormWorkRequest", --宿舍打工
        DormWorkRewardReq = "DormWorkRewardRequest", --宿舍打工领取奖励

        FondleDataReq = "GetFondleDataRequest", -- 爱抚信息查询
        FondleReq = "DormDoFondleRequest", -- 爱抚请求
    }

    function XDormManager.InitData(characterList, dormitoryList, visitorList, furnitureList)
        CharacterData = {}
        DormitoryData = {}
        VisitorData = {}
        IsPlayingShowEvent = false

        local dormitoryTemplates = XDormConfig.GetTotalDormitoryCfg()
        -- 宿舍布局数据
        for id, cfg in pairs(dormitoryTemplates) do
            DormitoryData[id] = XHomeRoomData.New(id)
            DormitoryData[id]:SetPlayerId(XPlayer.Id)
        end

        for _, data in pairs(dormitoryList) do
            local roomData = DormitoryData[data.DormitoryId]
            if not roomData then
                XLog.Error("XDormManager.InitData error: Dormitory id is not exist, id = " .. data.DormitoryId)
            else
                roomData:SetRoomUnlock(true)
                roomData:SetRoomName(data.DormitoryName)
            end
        end

        for _, data in pairs(furnitureList) do
            local roomData = DormitoryData[data.DormitoryId]
            if roomData then
                roomData:SetRoomUnlock(true)
                roomData:AddFurniture(data.Id, data.ConfigId, data.X, data.Y, data.Angle)
            end
        end

        -- 构造体数据
        for _, data in ipairs(characterList) do
            CharacterData[data.CharacterId] = data
            if data.DormitoryId and data.DormitoryId > 0 then
                local roomData = DormitoryData[data.DormitoryId]
                if roomData then
                    roomData:AddCharacter(data)
                end
            end
        end

        -- 宿舍访客数据
        for _, data in pairs(visitorList) do
            VisitorData[data.CharacterId] = data
        end

    end

    --获取所有宿舍数据
    function XDormManager.GetDormitoryData(dormDataType)
        if dormDataType == XDormConfig.DormDataType.Target then
            return TargetDormitoryData
        end

        return DormitoryData
    end

    -- 获取指定宿舍数据
    function XDormManager.GetRoomDataByRoomId(roomId, dormDataType)
        local data
        if dormDataType == XDormConfig.DormDataType.Target then
            data = TargetDormitoryData
        else
            data = DormitoryData
        end

        local roomData = data[roomId]
        if not roomData then
            XLog.Error("XDormManager.GetRoomDataByRoomId not found by roomId : " .. tostring(roomId))
            return
        end

        return roomData
    end

    -- 入住排序方法
    local CharacterCheckInSortFunc = function(a, b)
        if a.DormitoryId < 0 or b.DormitoryId < 0 then
            --未入住
            return a.DormitoryId < b.DormitoryId
        elseif a.DormitoryId > 0 or b.DormitoryId > 0 then
            --已入住
            return a.CharacterId < b.CharacterId
        end

        return false
    end

    -- 取回入住人数据
    function XDormManager.GetCharactersSortedCheckInByDormId(dormId)
        if not CharacterData then
            return nil
        end

        local data = {}
        local d = {}

        for _, v in pairs(CharacterData) do
            if v.DormitoryId == dormId then
                table.insert(data, { CharacterId = v.CharacterId, DormitoryId = v.DormitoryId })
            else
                table.insert(d, { CharacterId = v.CharacterId, DormitoryId = v.DormitoryId })
            end
        end

        table.sort(d, CharacterCheckInSortFunc)
        for _, v in pairs(d) do
            table.insert(data, v)
        end
        return data
    end

    ---------------------start data---------------------
    --
    function XDormManager.GetCharacterDataByCharId(id)
        -- 没有数据下 直接返回nil
        if not CharacterData then
            return nil
        end
        local t = CharacterData[id]
        if not t then
            XLog.Error("XDormManager.GetCharacterDataByCharId error: charId is not found, charId = " .. tostring(id))
            return nil
        end

        return t
    end

    function XDormManager.GetTargetCharacterDataByCharId(id)
        -- 没有数据下 直接返回nil
        if not TargetCharacterData then
            return nil
        end

        local t = TargetCharacterData[id]
        if not t then
            XLog.Error("XDormManager.GetTargetCharacterDataByCharId error: charId is not found, charId = " .. tostring(id))
            return nil
        end

        return t
    end

    -- 根据宿舍人员id---->CharacterId,获得角色大头像
    function XDormManager.GetCharBigHeadIcon(id)
        return XDataCenter.CharacterManager.GetCharBigHeadIcon(id)
    end

    -- 根据宿舍人员id---->CharacterId,获得角色小头像
    function XDormManager.GetCharSmallHeadIcon(id)
        return XDataCenter.CharacterManager.GetCharSmallHeadIcon(id)
    end

    -- 根据宿舍人员id---->CharacterId和类型,取回角色喜好Icon
    function XDormManager.GetCharacterLikeIconById(id, lt)
        if not id or not lt then
            return
        end

        local charStyleConfig = XDormConfig.GetCharacterStyleConfigById(id)

        if not charStyleConfig then
            return
        end

        local d = charStyleConfig[lt]
        if not d then
            return
        end

        local likeTypeConfig = XFurnitureConfigs.GetDormFurnitureType(d)
        return likeTypeConfig.TypeIcon
    end

    -- 根据宿舍人员id---->CharacterId和类型,取回角色喜好Name
    function XDormManager.GetCharacterLikeNameById(id, lt)
        if not id or not lt then
            return
        end

        local charStyleConfig = XDormConfig.GetCharacterStyleConfigById(id)
        if not charStyleConfig then
            return
        end
        local d = charStyleConfig[lt]
        if not d then
            return
        end

        local likeTypeConfig = XFurnitureConfigs.GetDormFurnitureType(d)
        return likeTypeConfig.TypeName
    end

    -- 根据宿舍人员id---->CharacterId,取回角色体力
    function XDormManager.GetVitalityById(id)
        local d = XDormManager.GetCharacterDataByCharId(id)
        if not d then
            return 0
        end

        return d.Vitality
    end

    -- 根据宿舍人员id---->CharacterId,取回角色心情值
    function XDormManager.GetMoodById(id)
        local d = XDormManager.GetCharacterDataByCharId(id)
        if not d then
            return 0
        end

        return d.Mood
    end

    -- 根据宿舍id--->DormitoryId,取回宿舍人员角色Icon圆头像
    function XDormManager.GetDormCharactersIcons(id, dormDataType)
        local icons = {}
        local d = XDormManager.GetRoomDataByRoomId(id, dormDataType)
        if not d then
            return icons
        end

        local characterList = d:GetCharacter()
        for k, v in pairs(characterList) do
            --获得角色圆头像
            local icon = XDataCenter.CharacterManager.GetCharRoundnessHeadIcon(v.CharacterId)
            icons[k] = icon
        end
        return icons
    end

    -- 根据宿舍id--->DormitoryId,取回宿舍人员Ids
    function XDormManager.GetDormCharactersIds(roomId, dormDataType)
        local ids = {}
        local d = XDormManager.GetRoomDataByRoomId(roomId, dormDataType)
        if not d then
            return ids
        end

        local list = d:GetCharacter()
        for _, v in pairs(list) do
            ids[v.CharacterId] = v.CharacterId
        end
        return ids
    end

    -- 根据宿舍id--->DormitoryId,取回宿舍人员中是否有事件
    function XDormManager.IsHaveDormCharactersEvent(roomId)
        local d = XDormManager.GetRoomDataByRoomId(roomId)
        local list = d:GetCharacter()
        for _, v in pairs(list) do
            local eventtemp = XHomeCharManager.GetCharacterEvent(v.CharacterId,true)
            if eventtemp then
                return true
            end
        end
        return false
    end

    -- 根据宿舍id--->DormitoryId,取回宿舍名字
    function XDormManager.GetDormName(id, dormDataType)
        local d = XDormManager.GetRoomDataByRoomId(id, dormDataType)
        if not d then
            return
        end

        return d:GetRoomName() or ""
    end

    -- 根据宿舍id--->DormitoryId,取回宿舍总评分
    function XDormManager.GetDormTotalScore(id, dormDataType)
        local totalScore = 0
        local d = XDormManager.GetRoomDataByRoomId(id, dormDataType)
        if d then
            local furnitureIdList = {}
            local dic = d:GetFurnitureDic()
            for furnitureId, _ in pairs(dic) do
                table.insert(furnitureIdList, furnitureId)
            end

            if furnitureIdList then
                for k, furnitureId in pairs(furnitureIdList) do
                    totalScore = totalScore + XDataCenter.FurnitureManager.GetFurnitureScore(furnitureId,dormDataType)
                end
            end
        end

        return XFurnitureConfigs.GetFurnitureTotalAttrLevelDescription(1,totalScore)
    end

    -- 获取房间地表实例Id
    function XDormManager.GetRoomPlatId(roomId, homePlatType, dormDataType)
        if homePlatType == nil then
            return nil
        end

        local dic
        if dormDataType == XDormConfig.DormDataType.Target then
            dic = TargetDormitoryData
        else
            dic = DormitoryData
        end

        local roomData = dic[roomId]
        if roomData == nil then
            return nil
        end

        local list = roomData:GetFurnitureDic()
        for _, v in pairs(list) do
            local cfg = XFurnitureConfigs.GetFurnitureTemplateById(v.ConfigId)
            if cfg then
                local typeCfg = XFurnitureConfigs.GetFurnitureTypeById(cfg.TypeId)
                if typeCfg then
                    if homePlatType == CS.XHomePlatType.Ground and typeCfg.MajorType == 1 and typeCfg.MinorType == 1 then
                        return v
                    end

                    if homePlatType == CS.XHomePlatType.Wall and typeCfg.MajorType == 1 and typeCfg.MinorType == 2 then
                        return v
                    end
                end
            end
        end

        return nil
    end

    function XDormManager.GetCharacterIds()
        local characters = XDataCenter.CharacterManager.GetOwnCharacterList()

        local characterIds = {}
        for _, v in pairs(characters) do
            table.insert(characterIds, v.Id)
        end

        return characterIds
    end

    -- 构造体所在宿舍号
    function XDormManager.GetCharacterRoomNumber(charId)
        local t = XDormManager.GetCharacterDataByCharId(charId)
        if not t then
            return 0
        end

        if t.DormitoryId > 0 then
            return t.DormitoryId
        end

        return 0
    end

    -- 构造体是否在宿舍中
    function XDormManager.CheckCharInDorm(charId)
        local t = XDormManager.GetCharacterDataByCharId(charId)
        if not t then
            return false
        end
        return t.DormitoryId > 0
    end

    -- 获取构造体当前回复等级
    function XDormManager.GetCharRecoveryCurLevel(charId)
        local curLevelConfig = nil
        local curIndex = 0
        local charData = XDormManager.GetCharacterDataByCharId(charId)
        if not charData then
            return curLevelConfig, curIndex
        end
        local scoreA, scoreB, scoreC = XDormManager.GetDormitoryScore(charData.DormitoryId)
        local indexA = XFurnitureConfigs.AttrType.AttrA - 1
        local indexB = XFurnitureConfigs.AttrType.AttrB - 1
        local indexC = XFurnitureConfigs.AttrType.AttrC - 1

        local allFurnitureAttrs = XHomeDormManager.GetFurnitureScoresByUnsaveRoom(charData.DormitoryId)
        local allScores = allFurnitureAttrs.TotalScore

        local recoveryConfigs = XDormConfig.GetCharRecoveryConfig(charId)
        for index, recoveryConfig in pairs(recoveryConfigs) do
            if recoveryConfig.CompareType == XDormConfig.CompareType.Less then
                if scoreA <= (recoveryConfig.AttrCondition[indexA] or 0) and
                        scoreB <= (recoveryConfig.AttrCondition[indexB] or 0) and
                        scoreC <= (recoveryConfig.AttrCondition[indexC] or 0) and
                        allScores <= recoveryConfig.AttrTotal then
                            curLevelConfig = recoveryConfig
                            curIndex = index
                end
            elseif recoveryConfig.CompareType == XDormConfig.CompareType.Equal then
                if scoreA == (recoveryConfig.AttrCondition[indexA] or 0) and
                        scoreB == (recoveryConfig.AttrCondition[indexB] or 0) and
                        scoreC == (recoveryConfig.AttrCondition[indexC] or 0) and
                        allScores == recoveryConfig.AttrTotal then
                            curLevelConfig = recoveryConfig
                            curIndex = index
                end
            elseif recoveryConfig.CompareType == XDormConfig.CompareType.Greater then
                if scoreA >= (recoveryConfig.AttrCondition[indexA] or 0) and
                        scoreB >= (recoveryConfig.AttrCondition[indexB] or 0) and
                        scoreC >= (recoveryConfig.AttrCondition[indexC] or 0) and
                        allScores >= recoveryConfig.AttrTotal then
                            curLevelConfig = recoveryConfig
                            curIndex = index
                end
            end
        end

        return curLevelConfig, curIndex
    end

    -- 获取构造体当前 下一个回复等级Config
    function XDormManager.GetCharRecoveryConfigs(charId)
        local curRecoveryConfig, curConfigIndex = XDormManager.GetCharRecoveryCurLevel(charId)
        local nextRecoveryConfig = nil

        if curRecoveryConfig == nil then
            return nil, nil
        end

        local recoveryConfigs = XDormConfig.GetCharRecoveryConfig(charId)

        -- 当前已经是最大值 直接把当前作为Next返回 当前为nil
        if curConfigIndex >= #recoveryConfigs then
            return nil, curRecoveryConfig
        end

        nextRecoveryConfig = recoveryConfigs[curConfigIndex + 1]
        return curRecoveryConfig, nextRecoveryConfig
    end

    -- 获取某个宿舍的家具三个总分(attrA, attrB, attrC)
    function XDormManager.GetDormitoryScore(dormitoryId, dormDataType)
        local dic
        if dormDataType == XDormConfig.DormDataType.Target then
            dic = TargetDormitoryData
        else
            dic = DormitoryData
        end

        local data = dic[dormitoryId]
        if not data then
            return 0, 0, 0
        end

        local kv = data:GetFurnitureDic()
        local furnitureIds = {}
        for id, _ in pairs(kv) do
            table.insert(furnitureIds, id)
        end
        local scoreA, scoreB, scoreC = XDataCenter.FurnitureManager.GetFurniturePartScore(furnitureIds,dormDataType)
        return scoreA, scoreB, scoreC
    end

    local getScoreNamesSort = function(a, b)
        return a[2] > b[2]
    end

    -- 获取某个宿舍的家具三个总分对应名字
    function XDormManager.GetDormitoryScoreNames()
        local attrType = XFurnitureConfigs.AttrType
        local indexA = attrType.AttrA
        local indexB = attrType.AttrB
        local indexC = attrType.AttrC
        local a = XFurnitureConfigs.GetDormFurnitureTypeName(indexA)
        local b = XFurnitureConfigs.GetDormFurnitureTypeName(indexB)
        local c = XFurnitureConfigs.GetDormFurnitureTypeName(indexC)
        return a,b,c
    end

    -- 获取某个宿舍的家具三个总分(attrA, attrB, attrC)以及对应Icon
    function XDormManager.GetDormitoryScoreIcons(dormitoryId, dormDataType)
        local scoreA, scoreB, scoreC = XDormManager.GetDormitoryScore(dormitoryId, dormDataType)
        local data = {}
        local attrType = XFurnitureConfigs.AttrType
        local indexA = attrType.AttrA
        local indexB = attrType.AttrB
        local indexC = attrType.AttrC
        data[1] = { XFurnitureConfigs.GetDormFurnitureTypeIcon(indexA), scoreA }
        data[2] = { XFurnitureConfigs.GetDormFurnitureTypeIcon(indexB), scoreB }
        data[3] = { XFurnitureConfigs.GetDormFurnitureTypeIcon(indexC), scoreC }
        table.sort(data, getScoreNamesSort)
        return data
    end

    function XDormManager.GetDormitoryScoreLevelDes(dormitoryId, dormDataType)
        local scoreA, scoreB, scoreC = XDormManager.GetDormitoryScore(dormitoryId, dormDataType)
        local data = {}
        local attrType = XFurnitureConfigs.AttrType
        local indexA = attrType.AttrA
        local indexB = attrType.AttrB
        local indexC = attrType.AttrC
        local a = XFurnitureConfigs.GetFurnitureAttrLevelDescription(1, indexA, scoreA)
        local b = XFurnitureConfigs.GetFurnitureAttrLevelDescription(1, indexB, scoreB)
        local c = XFurnitureConfigs.GetFurnitureAttrLevelDescription(1, indexC, scoreC)
        return a,b,c
    end

    -- 获得玩家访问其他宿舍时的角色id(暂时做成随机，二期做成可设置)
    function XDormManager.GetVisitorDormitoryCharacterId()
        local d = XDormManager.GetCharacterIds()
        if _G.next(d) == nil then
            return nil
        end

        local index = math.random(1, #d)
        return d[index]
    end

    -- 改名完成修正数据
    function XDormManager.RenameSuccess(dormitoryId, newName)
        local roomData = DormitoryData[dormitoryId]
        if roomData then
            roomData:SetRoomName(newName)
        end
    end

    -- 通知有人进入房间
    function XDormManager.NotifyDormVisitEnter(data)
    end

    -- 通知打工刷新时间
    function XDormManager.NotifyDormWorkRefreshTime(data)
        WorkRefreshTime = data.NextRefreshTime or -1
        XEventManager.DispatchEvent(XEventId.EVENT_DORM_WORK_RESET)
    end

    function XDormManager.GetDormWorkRefreshTime()
        return WorkRefreshTime
    end

    -- 批量通知构造体心情值和体力值改变
    function XDormManager.NotifyCharacterAttr(data)
        for k, v in pairs(data.AttrList) do
            XDormManager.NotifyCharacterMood(v)
            XDormManager.NotifyCharacterVitality(v)
        end
    end

    -- 通知构造体心情值改变
    function XDormManager.NotifyCharacterMood(data)
        local t = XDormManager.GetCharacterDataByCharId(data.CharacterId)
        if not t then
            return
        end

        local changeValue = data.Mood - t.Mood
        t.Mood = data.Mood
        XEventManager.DispatchEvent(XEventId.EVENT_CHARACTER_MOOD_CHANGED, data.CharacterId, changeValue)
    end

    -- 通知构造体体力值改变
    function XDormManager.NotifyCharacterVitality(data)
        local t = XDormManager.GetCharacterDataByCharId(data.CharacterId)
        if not t then
            return
        end

        t.Vitality = data.Vitality
        XEventManager.DispatchEvent(XEventId.EVENT_CHARACTER_VITALITY_CHANGED, data.CharacterId)
    end

    -- 通知构造体体力/心情恢复速度改变
    function XDormManager.NotifyCharacterSpeedChange(data)
        for _, v in ipairs(data.Recoveries) do
            local t = XDormManager.GetCharacterDataByCharId(v.CharacterId)
            if not t then
                return
            end

            local moodChangeValue = v.MoodSpeed - t.MoodSpeed
            local vitalityChangeValue = v.VitalitySpeed - t.VitalitySpeed
            t.MoodSpeed = v.MoodSpeed
            t.VitalitySpeed = v.VitalitySpeed

            if data.ChangeType == XDormConfig.RecoveryType.PutFurniture then

                local moodEventId = moodChangeValue > 0 and XDormConfig.ShowEventId.MoodSpeedAdd or XDormConfig.ShowEventId.MoodSpeedCut
                local vitalityEventId = vitalityChangeValue > 0 and XDormConfig.ShowEventId.VitalitySpeedAdd or XDormConfig.ShowEventId.VitalitySpeedCut

                if moodChangeValue ~= 0 then
                    XDormManager.DormShowEventShowAdd(v.CharacterId, moodChangeValue, moodEventId)
                end

                if vitalityChangeValue ~= 0 then
                    XDormManager.DormShowEventShowAdd(v.CharacterId, vitalityChangeValue, vitalityEventId)
                end
            end
        end
    end

    -- 设置是否再爱抚中
    function XDormManager.SetInTouch(isInTouch)
        IsInTouch = isInTouch
    end

    -- 是否再爱抚中
    function XDormManager.CheckInTouch()
       return IsInTouch
    end

    function XDormManager.DormShowEventShowAdd(charId, changeValue, eventId)
        local dormShowEvent = {}
        dormShowEvent.CharacterId = charId
        dormShowEvent.ChangeValue = changeValue
        dormShowEvent.EventId = eventId
        table.insert(DormShowEventList, dormShowEvent)

        if not XLuaUiManager.IsUiShow("UiDormSecond") then
            return
        end

        if IsInTouch then
            return
        end

        if IsPlayingShowEvent then
            return
        end

        XDormManager.GetNextShowEvent()
    end

    function XDormManager.GetNextShowEvent()
        if #DormShowEventList <= 0 then
            IsPlayingShowEvent = false
            return
        end

        if not XLuaUiManager.IsUiShow("UiDormSecond") then
            return
        end

        if IsInTouch then
            return
        end

        IsPlayingShowEvent = true
        local firstData = table.remove(DormShowEventList, 1)
        XEventManager.DispatchEvent(XEventId.EVENT_DORM_SHOW_EVENT_CHANGE, firstData)
    end

    -- 通知构造有事件变更
    function XDormManager.NotifyDormCharacterAddEvent(data)
        if not data or not data.EventList then
            return
        end

        for i, v in ipairs(data.EventList) do
            local t = XDormManager.GetCharacterDataByCharId(v.CharacterId)
            if not t then
                return
            end

            t.EventList = t.EventList or {}
            for i,v in ipairs(v.EventList) do
                table.insert(t.EventList, v)
            end
            XEventManager.DispatchEvent(XEventId.EVENT_CHARACTER_DORMMAIN_EVENT_NOTIFY, t.DormitoryId)
            XEventManager.DispatchEvent(XEventId.EVENT_CHARACTER_ADD_EVENT_NOTIFY, v.CharacterId)
        end
    end

    -- 通知构造有事件变更
    function XDormManager.NotifyDormCharacterSubEvent(data)

        if not data or not data.EventList then
            return
        end

        for i, v in ipairs(data.EventList) do

            local t = XDormManager.GetCharacterDataByCharId(v.CharacterId)
            if not t then
                return
            end
            local idx = -1
            t.EventList = t.EventList or {}
            for index, var in ipairs(t.EventList) do
                if var.EventId == v.EventId then
                    idx = index
                end
            end

            if idx > 0 then
                table.remove(t.EventList, idx)
            end

            XEventManager.DispatchEvent(XEventId.EVENT_CHARACTER_SUB_EVENT_NOTIFY, data.CharacterId)
        end

    end

    -- 取回玩家宿舍打工数据(正在打工或者奖励没有领)
    -- 保证工位小的在前面
    local DormWorkDataSort = function(a, b)
        return a.WorkPos < b.WorkPos
    end

    function XDormManager.GetDormWorkData()
        local listData = {}
        local d = WorkListData or {}
        for _, v in pairs(d) do
            if v then
                table.insert(listData, v)
            end
        end

        table.sort(listData, DormWorkDataSort)
        return listData
    end

    -- 取回玩家宿舍打工数据(能打工的)
    function XDormManager.GetDormNotWorkData()
        local listData = {}
        local ids = XDormManager.GetCharacterIds()

        for _, id in pairs(ids) do
            if XDormManager.CheckCharInDorm(id) and not XDormManager.IsWorking(id) then
                table.insert(listData, id)
            end
        end
        table.sort(listData, function(a, b)
            local vitalityA = XDormManager.GetVitalityById(a)
            local vitalityB = XDormManager.GetVitalityById(b)

            if vitalityA ~= vitalityB then 
                return vitalityA > vitalityB
            end

            return a < b
        end)

        return listData
    end

    -- 是否在打工中
    function XDormManager.IsWorking(charId)
        local d = WorkListData or {}
        for _, v in pairs(d) do
            if v.CharacterId == charId then
                local f = v.WorkEndTime - XTime.Now() > 0
                if f then
                    return true
                end
            end
        end

        return false
    end

    -- 取回玩家宿舍已经占了的工位
    function XDormManager.GetDormWorkPosData()
        local posList = {}
        local d = WorkListData or {}
        for _, v in pairs(d) do
            posList[v.WorkPos] = v.WorkPos
        end
        return posList
    end

    -- 当前拥有的宿舍
    function XDormManager.GetDormitoryCount()
        local count = 0
        for _, room in pairs(DormitoryData) do
            if room:WhetherRoomUnlock() then
                count = count + 1
            end
        end
        return count
    end

    -- 检查某个宿舍是否激活
    function XDormManager.IsDormitoryActive(dormitoryId)
        local room = DormitoryData[dormitoryId]
        if not room then return false end
        return room:WhetherRoomUnlock()
    end

    -- 如果拥有的数量超过配置的最大数量，就取最大数量。
    function XDormManager.GetWorkCfg(dormCount)
        local cfgWork = XDormConfig.GetDormCharacterWorkData() or {}
        local count = XDormManager.GetDormitoryCount()
        if dormCount then
            count = dormCount
        end

        local index = count
        local temple = #cfgWork

        if count > temple then
            index = temple
        end

        local data = XDormConfig.GetDormCharacterWorkById(index)
        return data
    end
    ---------------------end data---------------------
    ---------------------start net---------------------
    function XDormManager.UpdateDormData(roomId, roomData)
        local newRoomData = XHomeRoomData.New(roomId)
        newRoomData:SetPlayerId(XPlayer.Id)
        local furnitureList = roomData:GetFurnitureDic()
        for k, furniture in pairs(furnitureList) do
            local furnitureData = XDataCenter.FurnitureManager.GetFurnitureById(furniture.Id)
            if furnitureData then
                newRoomData:AddFurniture(furnitureData.Id, furnitureData.ConfigId, furnitureData.X, furnitureData.Y, furnitureData.Angle)
            end
        end

        DormitoryData[roomId] = newRoomData
    end

    function XDormManager.SetRoomDataDormitoryId(roomData, roomId)
        local furnitureList = roomData:GetFurnitureDic()

        for k, furniture in pairs(furnitureList) do
            XDataCenter.FurnitureManager.SetFurnitureState(furniture.Id, roomId)
        end
    end

    -- 房间家具摆放
    function XDormManager.RequestDecorationRoom(roomId, room, cb)
        --TODO
        if not room then
            return
        end

        local roomData = room:GetData()
        if not roomData then
            return
        end

        -- 通知服务端
        local furnitureList = {}
        local furnitures = roomData:GetFurnitureDic()

        for k, v in pairs(furnitures) do
            table.insert(furnitureList, {
                Id = v.Id,
                X = v.GridX,
                Y = v.GridY,
                Angle = v.RotateAngle,
            })
        end

        local roomUnsaveData = XDormManager.GetRoomDataByRoomId(roomId)

        XDataCenter.FurnitureManager.PutFurniture(roomId, furnitureList, function()
            room:GenerateRoomMap()
            -- 提示成功
            XUiManager.TipMsg(CS.XTextManager.GetText("FurnitureSaveSuccess"))

            -- 修改保存之前的家具为不属于这个房间
            XDormManager.SetRoomDataDormitoryId(roomUnsaveData, 0)

            -- 修改保存之后的家具为属于这个房间
            XDormManager.SetRoomDataDormitoryId(roomData, roomId)

            -- 将修改保存起来
            DormitoryData[roomId].FurnitureDic = roomData:GetFurnitureDic()

            CsXGameEventManager.Instance:Notify(XEventId.EVENT_FURNITURE_REFRESH)

            if cb then 
                cb()
            end
        end)
    end

    -- Req
    -- 请求宿舍所有数据
    function XDormManager.RequestDormitoryData(cb)
        XNetwork.Call(DormitoryRequest.DormitoryDataReq, nil, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            XDataCenter.FurnitureManager.InitData(res.FurnitureList, res.FurnitureCreateList)
            XDormManager.InitData(res.CharacterList, res.DormitoryList, res.VisitorList, res.FurnitureList)

            if cb then
                cb()
            end
        end)
    end

    -- 获取构造体回复速度
    function XDormManager.GetDormitoryRecoverSpeed(charId, cb)
        local t = XDormManager.GetCharacterDataByCharId(charId)
        if not t then
            return nil
        end

        local moodSpeed = string.format("%.1f", t.MoodSpeed / 100)
        local vitalitySpeed = string.format("%.1f", t.VitalitySpeed / 100)

        if moodSpeed * 10 % 10 == 0 then
            moodSpeed = string.format("%d", moodSpeed)
        end

        if vitalitySpeed * 10 % 10 == 0 then
            vitalitySpeed = string.format("%d", vitalitySpeed)
        end


        if cb then
            cb(moodSpeed, vitalitySpeed, t)
        end
    end

    -- 激活宿舍
    function XDormManager.RequestDormitoryActive(dormitoryId, cb)
        XNetwork.Call(DormitoryRequest.ActiveDormItemReq, { DormitoryId = dormitoryId }, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            XDormManager.ReqDormitoryActiveSuccess(res.DormitoryId, res.DormitoryName, res.FurnitureList)
            if cb then
                cb()
            end

            XUiManager.TipText("DormActiveSuccessTips")
            XEventManager.DispatchEvent(XEventId.EVENT_DORM_ROOM_ACTIVE_SUCCESS)
        end)
    end

    -- 激活宿舍成功修正数据
    function XDormManager.ReqDormitoryActiveSuccess(dormitoryId, dormitoryName, furnitureList)

        local furnitureDatas = XDataCenter.FurnitureManager.GetFurnitureDatas()
        if furnitureDatas then
            for _, v in pairs(furnitureList) do
                furnitureDatas[v.Id] = XHomeFurnitureData.New(v)
            end
        end

        local roomData = DormitoryData[dormitoryId]

        if roomData then
            roomData:SetRoomName(dormitoryName)
            roomData:SetRoomUnlock(true)
            for _, data in pairs(furnitureList) do
                roomData:AddFurniture(data.Id, data.ConfigId, data.X, data.Y, data.Angle)
                XDataCenter.FurnitureManager.SetFurnitureState(data.Id, data.DormitoryId)
            end
        end

        local room = XHomeDormManager.GetSingleDormByRoomId(dormitoryId)
        room:SetData(roomData)
    end

    -- 访问宿舍(包括自己和他人的)
    function XDormManager.VisitDormitory(displayState, dormitoryId)
        local f = displayState == XDormConfig.VisitDisplaySetType.MySelf
        local isvistor = false
        if f then
            local data = XDataCenter.DormManager.GetDormitoryData()
            XHomeDormManager.LoadRooms(data, XDormConfig.DormDataType.Self)
        else
            local data = XDataCenter.DormManager.GetDormitoryData(XDormConfig.DormDataType.Target)
            XHomeDormManager.LoadRooms(data, XDormConfig.DormDataType.Target)
            isvistor = true
        end

        XHomeDormManager.SetSelectedRoom(dormitoryId, true, isvistor)
    end

    -- 房间改名
    function XDormManager.RequestDormitoryRename(dormitoryId, newName, cb)
        XNetwork.Call(DormitoryRequest.DormRenameReq, { DormitoryId = dormitoryId, NewName = newName }, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            if cb then
                XDormManager.RenameSuccess(dormitoryId, newName)
                cb()
            end
        end)
    end

    -- 摆放家具请求
    function XDormManager.RequestDormitoryPutFurniture(dormitoryId, furnitureList, cb)
        XNetwork.Call(DormitoryRequest.PutFurnitureReq, { DormitoryId = dormitoryId, FurnitureList = furnitureList }, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            if cb then
                cb()
            end
        end)
    end

    -- 退出宿舍请求
    function XDormManager.RequestDormitoryExit()
        XNetwork.Send(DormitoryRequest.DormExitReq)
    end

    -- 进入宿舍通知
    function XDormManager.RequestDormitoryDormEnter(cb)
        XNetwork.Call(DormitoryRequest.DormEnterReq, nil, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            local data = res.CharacterEvents
            if data then
                for i, v in pairs(data) do

                    local t = XDormManager.GetCharacterDataByCharId(v.CharacterId)
                    if not t then
                        return
                    end

                    t.EventList = v.EventList
                end
            end

            if cb then
                cb()
            end

        end)
    end

    -- 构造体处理事件反馈
    function XDormManager.RequestDormitoryCharacterOperate(charId, dormitoryId, eventId, operateType, cb)
        XNetwork.Call(DormitoryRequest.DormCharacterOperateReq, { CharacterId = charId, EventId = eventId, OperateType = operateType }, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            local character = XDormManager.GetCharacterDataByCharId(charId)
            if not character.EventList then
                return
            end

            local index = -1
            for i, v in ipairs(character.EventList) do
                if v.EventId == eventId then
                    index = i
                end
            end

            if index > 0 then
                table.remove(character.EventList, index)
            end

            XHomeCharManager.SetEventReward(charId, res.RewardGoods)

            -- 处理回复弹条
            local changeValue = math.floor(res.MoodValue / 100)
            if character.Mood + changeValue > XDormConfig.DORM_MOOD_MAX_VALUE then 
                changeValue = XDormConfig.DORM_MOOD_MAX_VALUE - character.Mood
            end

            character.Mood = character.Mood + changeValue
            local showEventId = changeValue > 0 and XDormConfig.ShowEventId.MoodAdd or XDormConfig.ShowEventId.MoodCut
            XDormManager.DormShowEventShowAdd(charId, changeValue, showEventId)

            XEventManager.DispatchEvent(XEventId.EVENT_CHARACTER_MOOD_CHANGED, charId, changeValue)

            if cb then
                cb()
            end
        end)
    end

    -- 放置构造体
    function XDormManager.RequestDormitoryPutCharacter(dormitoryId, characterIds, cb)
        XNetwork.Call(DormitoryRequest.DormPutCharacterReq, { DormitoryId = dormitoryId, CharacterIds = characterIds }, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            XDormManager.PutCharacterSuccess(dormitoryId, res.SuccessIds)
            if cb then
                cb()
            end
        end)
    end

    -- 放置构造体成功修正数据
    function XDormManager.PutCharacterSuccess(dormitoryId, characterIds)
        if not dormitoryId or not characterIds then
            return
        end

        for _, id in pairs(characterIds) do
            local d = CharacterData[id]
            if d then
                d.DormitoryId = dormitoryId
            end

            local roomData = DormitoryData[dormitoryId]
            roomData:AddCharacter(d)
            local room = XHomeDormManager.GetRoom(dormitoryId)
            if room and room.IsSelected then
                room.Data.Character = roomData.Character
                room:AddCharacter(dormitoryId, id)
            end
        end
    end

    -- 移走构造体
    function XDormManager.RequestDormitoryRemoveCharacter(characterIds, cb)
        XNetwork.Call(DormitoryRequest.DormRemoveCharacterReq, { CharacterIds = characterIds }, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            XDormManager.RemoveCharacterSuccess(res.SuccessList)
            if cb then
                cb()
            end
        end)
    end

    -- 移走构造体成功修正数据
    function XDormManager.RemoveCharacterSuccess(successList)
        if not successList then
            return
        end

        for _, v in pairs(successList) do
            local roomData = DormitoryData[v.DormitoryId]
            if roomData then
                roomData:RemoveCharacter(v.CharacterId)

                local room = XHomeDormManager.GetRoom(v.DormitoryId)
                if room then
                    room:RemoveCharacter(v.DormitoryId, v.CharacterId)
                end
            end

            local id = v.CharacterId
            local d = CharacterData[id]
            if d then
                d.DormitoryId = -1
            end
        end
    end

    -- 请求刷新家具建造列表
    function XDormManager.RequestDormitoryCheckCreateFurniture(cb)
        XNetwork.Call(DormitoryRequest.CheckCreateFurnitureReq, nil, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            if cb then
                cb(res.FurnitureList)
            end
        end)
    end

    -- 访问具体宿舍
    function XDormManager.RequestDormitoryVisit(targetId, dormitoryId, characterId, cb)
        XNetwork.Call(DormitoryRequest.DormVisitReq, { TargetId = targetId, DormitoryId = dormitoryId, CharacterId = characterId }, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            XDormManager.DormitoryVisitData(res.VisitorList, res.CharacterList, res.DormitoryList, res.FurnitureList, res.PlayerName, targetId)
            if cb then
                cb()
            end
        end)
    end

    -- 访问具体宿舍数据记录
    function XDormManager.DormitoryVisitData(visitorList, characterList, dormitoryList, furnitureList, playername, targetId)
        local dormitoryCfgs = XDormConfig.GetTotalDormitoryCfg()

        -- 宿舍布局数据
        for id, cfg in pairs(dormitoryCfgs) do
            TargetDormitoryData[id] = XHomeRoomData.New(id)
            TargetDormitoryData[id]:SetPlayerId(targetId)
            TargetDormitoryData[id].PlayerName = playername
        end

        if dormitoryList then
            for _, data in pairs(dormitoryList) do
                local roomData = TargetDormitoryData[data.DormitoryId]
                if not roomData then
                    XLog.Error("XDormManager.DormitoryVisitData error: dormitory id is not exist, id = " .. tostring(data.DormitoryId))
                else
                    roomData:SetRoomUnlock(true)
                    roomData:SetRoomName(data.DormitoryName)
                end
            end
        end

        -- 宿舍家具
        XDataCenter.FurnitureManager.RemoveFurnitureOther()
        if furnitureList then
            for _, data in pairs(furnitureList) do
                local roomData = TargetDormitoryData[data.DormitoryId]
                if roomData then
                    roomData:SetRoomUnlock(true)
                    roomData:AddFurniture(data.Id, data.ConfigId, data.X, data.Y, data.Angle)
                    XDataCenter.FurnitureManager.AddFurniture(data, XDormConfig.DormDataType.Target)
                end
            end
        end

        -- 构造体数据
        if characterList then
            for _, data in ipairs(characterList) do
                TargetCharacterData[data.CharacterId] = data
                if data.DormitoryId and data.DormitoryId > 0 then
                    local roomData = TargetDormitoryData[data.DormitoryId]
                    if roomData then
                        roomData:AddCharacter(data)
                    end
                end
            end
        end

        -- 正在访问宿舍数据
        if visitorList then
            for _, data in pairs(visitorList) do
                TargetVisitorData[data.CharacterId] = data
            end
        end
    end

    -- 推荐访问
    function XDormManager.RequestDormitoryRecommend(cb)
        XNetwork.Call(DormitoryRequest.DormRecommendReq, nil, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            XDormManager.RecordDormitoryRecommend(res)
            if cb then
                cb(res)
            end
        end)
    end

    -- 记录推荐访问数据
    function XDormManager.RecordDormitoryRecommend(data)
        RecommVisData = {}
        local d = data.Details or {}
        for _, v in pairs(d) do
            RecommVisIds[v.DormitoryId] = v.DormitoryId
            RecommVisData[v.PlayerId] = v
        end
    end

    -- 取总的推荐访问数据
    function XDormManager.GetDormitoryRecommendTotalData()
        return RecommVisData
    end

    -- 取总的推荐访问数据
    function XDormManager.GetDormitoryRecommendScore(id)
        if not id then
            return
        end

        return RecommVisData[id]
    end

    function XDormManager.GetDormitoryTargetScore(roomId)
        local roomData = XDormManager.GetRoomDataByRoomId(roomId,XDormConfig.DormDataType.Target)
        if not roomData then
            return 
        end
        return XHomeDormManager.GetFurnitureScoresByRoomData(roomData,XDormConfig.DormDataType.Target)
    end

    -- 取推荐访问id和是否是最后一个(当前dormId的下一个id,最后一个直接返回dormId和true)
    function XDormManager.GetDormitoryRecommendDataForNext(dormId)
        local data = XDormManager.GetDormitoryRecommendTotalDormId()
        local len = #data
        local f = false

        for i = 1, len do
            if f then
                return data[i], len == i
            end

            if data[i] == dormId then
                f = true
            end
        end

        return dormId, true
    end

    -- 取推荐访问id和是否是前一个(当前dormId的上一个id,第一个直接返回dormId和true)
    function XDormManager.GetDormitoryRecommendDataForPre(dormId)
        local data = XDormManager.GetDormitoryRecommendTotalDormId()
        local f = false

        for i, v in pairs(data) do
            if f then
                return v, i == 1
            end

            if v == dormId then
                f = true
            end
        end

        return dormId, true
    end

    -- 取所有推荐访问DormId
    function XDormManager.GetDormitoryRecommendTotalDormId()
        local d = {}
        for _, v in pairs(RecommVisIds) do
            table.insert(d, v)
        end
        return d
    end

    function XDormManager.HandleVisFriendData(data)
        if data then
            for _, v in pairs(data) do
                if v.DormitoryId ~= 0 then
                    v.DataTime = XTime.Now()
                    RecommVisFriendData[v.PlayerId] = v
                end
            end
        end
        return RecommVisFriendData
    end

    function XDormManager.GetVisFriendData()
        return RecommVisFriendData
    end

    function XDormManager.GetVisFriendById(playerid)
        if not playerid then
            return 
        end

        if RecommVisFriendData and RecommVisFriendData[playerid] then
            return RecommVisFriendData[playerid]
        end
    end
    -- 访问具体数据
    function XDormManager.RequestDormitoryDetails(players, cb)
        XNetwork.Call(DormitoryRequest.DormDetailsReq, { Players = players }, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            XDormManager.HandleVisFriendData(res.Details)
            if cb then
                cb()
            end
        end)
    end

    -- 宿舍打工
    function XDormManager.RequestDormitoryWork(works, cb)
        XNetwork.Call(DormitoryRequest.DormWorkReq, { Works = works }, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            XDormManager.DormWorkRespHandle(res.WorkList)
            if cb then
                cb(res)
            end
        end)
    end

    -- 打工成功修正数据
    function XDormManager.DormWorkRespHandle(workList)
        if not workList then
            return
        end

        for _, data in pairs(workList) do
            WorkListData[data.WorkPos] = data
            local dormitoryId = XDormManager.GetCharacterRoomNumber(data.CharacterId)
            if dormitoryId then
                local room = XHomeDormManager.GetRoom(dormitoryId)
                if room then
                    room:RemoveCharacter(dormitoryId, data.CharacterId)
                end
            end
        end
    end

    -- 宿舍打工领取奖励
    function XDormManager.RequestDormitoryWorkReward(posList, cb)
        XNetwork.Call(DormitoryRequest.DormWorkRewardReq, { PosList = posList }, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            XDormManager.DormWorkRewardGet(res.WorkRewards)
            if cb then
                cb()
            end
        end)
    end

    -- 领取奖励成功修正数据
    function XDormManager.DormWorkRewardGet(workRewards)
        if not workRewards or _G.next(workRewards) == nil then
            return
        end

        local rewards = {}
        local workPos = {}
        for k, v0 in pairs(workRewards) do
            for _, v1 in pairs(WorkListData) do
                if v1.WorkPos == v0.WorkPos then
                    if v0.ResetCount == 0 then
                        v1.WorkEndTime = 0
                    else
                        workPos[v1.WorkPos] = v1.WorkPos
                    end
                end
            end
            table.insert(rewards, { TemplateId = v0.ItemId, Count = v0.ItemNum })
        end

        for pos, v in pairs(workPos) do
            for index,item in pairs(WorkListData)do
                if item and item.WorkPos == pos then
                    WorkListData[index] = nil
                end
            end
        end

        XUiManager.OpenUiObtain(rewards)
    end

    -- 爱抚信息查询
    function XDormManager.GetDormFondleData(characterId, cb)
        if not characterId then
            return
        end

        XNetwork.Call(DormitoryRequest.FondleDataReq, { CharacterId = characterId }, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            local fondle = { LastRecoveryTime = res.LastRecoveryTime, LeftCount = res.FondleCount }
            if cb then
                cb(fondle)
            end
        end)
    end

    -- 爱抚请求
    function XDormManager.DoFondleReq(characterId, fondleType, cb)
        if not characterId or not fondleType then
            return
        end

        local now = XTime.Now()
        if fondleType == XDormConfig.TouchState.WaterGun then
            if LastSyncServerTime + XDormConfig.WATERGUN_TIME >= now then
                return
            end
        end
        LastSyncServerTime = now

        local req = { CharacterId = characterId, FondleType = fondleType }
        XNetwork.Call(DormitoryRequest.FondleReq, req, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            if cb then
                cb()
            end
        end)
    end

    -- 打工数据
    function XDormManager.NotifyDormWork(data)

        if data and data.WorkList then
           for _, data in pairs(data.WorkList) do
            WorkListData[data.WorkPos] = data
           end
        end
    end

    -- 打工Red
    function XDormManager.DormWorkRedFun()
        if _G.next(WorkListData) ~= nil then
            for _, data in pairs(WorkListData) do
                if data.WorkEndTime > 0 and data.WorkEndTime < XTime.Now() then
                    return true
                end
            end
        end
        return false
    end

    -- 重置打工工位
    function XDormManager.ResetDormWorkPos()
        local workdata = {}
        if _G.next(WorkListData) ~= nil then
            for _, data in pairs(WorkListData) do
                if data.WorkEndTime ~= 0 then
                    workdata[data.WorkPos] = data
                end
            end
        end
        WorkListData = workdata
    end

    -- 启动
    function XDormManager.StartDormRedTimer()
        if XDormManager.DormRedTimer then
            return
        end

        XDormManager.DormRedTimer = CS.XScheduleManager.Schedule(XDormManager.UpdataDormRed, 2000, 0)
    end

    -- 停止
    function XDormManager.StopDormRedTimer()
        if not XDormManager.DormRedTimer then
            return
        end

        CS.XScheduleManager.UnSchedule(XDormManager.DormRedTimer)
        XDormManager.DormRedTimer = nil
    end

    function XDormManager.UpdataDormRed()
        XEventManager.DispatchEvent(XEventId.EVENT_DORM_WORK_REDARD)
        XEventManager.DispatchEvent(XEventId.EVENT_FURNITURE_CREATE_CHANGED)
    end
    ---------------------end net---------------------
    return XDormManager
end

XRpc.NotifyDormVisitEnter = function(data)
    XDataCenter.DormManager.NotifyDormVisitEnter(data)
end

XRpc.NotifyWorkNextRefreshTime = function(data)
    XDataCenter.DormManager.NotifyDormWorkRefreshTime(data)
end

XRpc.NotifyCharacterAttr = function(data)
    XDataCenter.DormManager.NotifyCharacterAttr(data)
end

XRpc.NotifyCharacterMood = function(data)
    XDataCenter.DormManager.NotifyCharacterMood(data)
end

XRpc.NotifyCharacterVitality = function(data)
    XDataCenter.DormManager.NotifyCharacterVitality(data)
end

XRpc.NotifyDormCharacterRecovery = function(data)
    XDataCenter.DormManager.NotifyCharacterSpeedChange(data)
end

XRpc.NotifyDormCharacterAddEvent = function(data)
    XDataCenter.DormManager.NotifyDormCharacterAddEvent(data)
end

XRpc.NotifyDormCharacterSubEvent = function(data)
    XDataCenter.DormManager.NotifyDormCharacterSubEvent(data)
end

XRpc.NotifyDormLoginData = function(data)
    XDataCenter.DormManager.NotifyDormWork(data)
    XDataCenter.FurnitureManager.InitFurnitureCreateList(data)
end