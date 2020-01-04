---
--- 家具管理器
---
XFurnitureManagerCreator = function()
    local XFurnitureManager = {}

    local FurnitureDatas = {}        -- 家具数据 table = {id = XHomeFurnitureData}
    local OtherFurnitureDatas = {}        -- 家具数据(其他人的) table = {id = XHomeFurnitureData}
    local FurnitureCategoryTypes = {}   -- 家具类型 table = {FurnitureTypeId = {ids}}
    local FurnitureCreateDatas = {}  -- 家具创建列表
    local FurnitureDatasCount = 0       -- 擁有家具总数

    local FurnitureRequest = {
        DecomposeFurniture = "DecomposeFurnitureRequest", -- 分解家具
        ActiveDormItem = "ActiveDormItemRequest", -- 激活宿舍--待删除
        CreateFurniture = "CreateFurnitureRequest", --建造家具
        CheckCreateFurniture = "CheckCreateFurnitureRequest", --领取家具
        RemouldFurniture = "RemouldFurnitureRequest", --改造家具
        PutFurniture = "PutFurnitureRequest", --家具摆放
    }

    function XFurnitureManager.InitFurnitureCreateList(response)
        if not response or not response.FurnitureCreateList then return end
        FurnitureCreateDatas = response.FurnitureCreateList
    end

    function XFurnitureManager.InitData(furnitureList, furnitureCreateList)
        -- MinorType 加入全部类型
        FurnitureDatas = {}
        FurnitureCategoryTypes = {}

        FurnitureCategoryTypes[XFurnitureConfigs.FURNITURE_CATEGORY_ALL_ID] = {}

        if furnitureList == nil then
            return
        end

        local furnitureDatasCount = 0
        for _, data in pairs(furnitureList) do
            if FurnitureDatas[data.Id] then
                XLog.Error("XFurnitureManager.InitData error:id is repeated, id = " .. data.Id)
            else
                FurnitureDatas[data.Id] = XHomeFurnitureData.New(data)
            end

            local typeConfig = XFurnitureConfigs.GetFurnitureTypeCfgByConfigId(data.ConfigId)
            if not FurnitureCategoryTypes[typeConfig.Id] then
                FurnitureCategoryTypes[typeConfig.Id] = {}
            end

            table.insert(FurnitureCategoryTypes[typeConfig.Id], data.Id)
            table.insert(FurnitureCategoryTypes[XFurnitureConfigs.FURNITURE_CATEGORY_ALL_ID], data.Id)
            furnitureDatasCount = furnitureDatasCount + 1
        end

        FurnitureDatasCount = furnitureDatasCount
    end

    ---------------------start Data---------------------
    -- 本地管理的红点 -> 移除
    function XFurnitureManager.DeleteNewHint(ids)
        local needSave = false
        for _, id in ipairs(ids) do
            local key = XPrefs.DormNewHint .. tostring(XPlayer.Id) .. id
            if CS.UnityEngine.PlayerPrefs.HasKey(key) then
                CS.UnityEngine.PlayerPrefs.DeleteKey(key)
                needSave = true
            end
        end

        if needSave then
            CS.UnityEngine.PlayerPrefs.Save()
        end
    end

    -- 本地管理的红点 -> 增加Id 表示此红点不再出现！
    function XFurnitureManager.AddNewHint(ids)
        local needSave = false
        for _, id in ipairs(ids) do
            local key = XPrefs.DormNewHint .. tostring(XPlayer.Id) .. id
            if not CS.UnityEngine.PlayerPrefs.HasKey(key) then
                CS.UnityEngine.PlayerPrefs.SetString(key, key)
                needSave = true
            end
        end

        if needSave then
            CS.UnityEngine.PlayerPrefs.Save()
        end
    end

    -- 本地管理的红点 -> 检查是否需要显示红点
    -- 如果本地有存储 说明不需要显示
    function XFurnitureManager.CheckNewHint(id)
        local key = XPrefs.DormNewHint .. tostring(XPlayer.Id) .. id
        return not CS.UnityEngine.PlayerPrefs.HasKey(key)
    end

    -- 通过家具唯一Id 获取家具ConfigId
    function XFurnitureManager.GetFurnitureConfigId(id, dormDataType)
        local t = XFurnitureManager.GetFurnitureById(id, dormDataType)
        return t.ConfigId
    end

    -- 获取家具配置表By 唯一Id
    function XFurnitureManager.GetFurnitureConfigByUniqueId(uniqueId, dormDataType)
        local t = XFurnitureManager.GetFurnitureById(uniqueId, dormDataType)
        return XFurnitureConfigs.GetFurnitureTemplateById(t.ConfigId)
    end

    --获取所有家具数据
    function XFurnitureManager.GetFurnitureDatas()
        return FurnitureDatas
    end

    --获取所擁有家具总数
    function XFurnitureManager.GetAllFurnitureCount()
        return FurnitureDatasCount
    end

    -- 获取家具
    function XFurnitureManager.GetFurnitureById(id, dormDataType)
        local datas = FurnitureDatas
        if dormDataType == XDormConfig.DormDataType.Target then
            datas = OtherFurnitureDatas
        end

        local t = datas[id]
        if not t and t ~= nil then
            XLog.Error("XFurnitureManager.GetFurnitureById error:id is not found, id = " .. id)
            return nil
        end

        return t
    end

    --设置家具为使用中
    function XFurnitureManager.SetFurnitureState(furnitureId, dormitoryId)
        local furniture = XFurnitureManager.GetFurnitureById(furnitureId)
        if furniture then
            furniture:SetUsedDormitoryId(dormitoryId)
        end
    end

    --查看家具是否在使用中
    function XFurnitureManager.CheckFurnitureUsing(furnitureId, dormDataType)
        local isUsing = false
        local furniture = XFurnitureManager.GetFurnitureById(furnitureId, dormDataType)
        if furniture and furniture:CheckIsUsed() then
            isUsing = true
        end

        return isUsing
    end

    -- 获取未使用的家具列表
    function XFurnitureManager.GetUnusedFurnitureList()
        local list = {}
        for _, furniture in pairs(FurnitureDatas) do
            if furniture and furniture.DormitoryId > 0 then
                table.insert(list, furniture)
            end
        end

        return list
    end

    -- 获取CategoryType的家具的个数
    function XFurnitureManager.GetFurnitureCategoryCount(selectIds)
        local count = 0
        for _, selectId in ipairs(selectIds) do
            if FurnitureCategoryTypes[selectId] then
                count = count + #FurnitureCategoryTypes[selectId]
            end
        end

        return count
    end

    local CheckSuit = function(selectSuitIds, furinitureId)
        if not selectSuitIds or #selectSuitIds <= 0 then
            return true
        end

        for _, suitId in ipairs(selectSuitIds) do
            if suitId == XFurnitureConfigs.FURNITURE_SUIT_CATEGORY_ALL_ID then 
                return true
            end

            local tempCfg = XFurnitureManager.GetFurnitureConfigByUniqueId(furinitureId)
            if tempCfg.SuitId == suitId then
                return true
            end
        end

        return false
    end

    -- 获取FurnitureTypeId的家具唯一Ids
    function XFurnitureManager.GetFurnitureCategoryIds(selectIds, selectSuitIds, isRemoveUsed, isAscending, isRemoveUnuse)
        local ids = {}
        for _, selectId in ipairs(selectIds) do
            if FurnitureCategoryTypes[selectId] then
                for _, id in ipairs(FurnitureCategoryTypes[selectId]) do
                    if isRemoveUsed and XFurnitureManager.CheckFurnitureUsing(id) then
                        goto continue
                    end

                    if isRemoveUnuse and not XFurnitureManager.CheckFurnitureUsing(id) then
                        goto continue
                    end

                    if not CheckSuit(selectSuitIds, id) then
                        goto continue
                    end

                    table.insert(ids, id)
                    :: continue ::
                end
            end
        end

        table.sort(ids, function(a, b)
            -- 是否使用
            local usingA = XFurnitureManager.CheckFurnitureUsing(a)
            local usingB = XFurnitureManager.CheckFurnitureUsing(b)
            if usingA ~= usingB then
                return usingB
            end

            -- 判断积分
            local scoreA = XFurnitureManager.GetFurnitureScore(a)
            local scoreB = XFurnitureManager.GetFurnitureScore(b)
            if scoreA ~= scoreB then
                if isAscending then
                    return scoreA < scoreB
                else
                    return scoreA > scoreB
                end
            end

            -- 判断类型
            local configIdA = XFurnitureManager.GetFurnitureConfigId(a)
            local minorA = XFurnitureConfigs.GetFurnitureTypeCfgByConfigId(configIdA).MinorType

            local configIdB = XFurnitureManager.GetFurnitureConfigId(b)
            local minorB = XFurnitureConfigs.GetFurnitureTypeCfgByConfigId(configIdB).MinorType

            if minorA ~= minorB then
                return minorA < minorB
            end

            return a < b
        end)

        return ids
    end

    -- 获取已拥有的家具配置id列表
    function XFurnitureManager.GetTotalFurnitureIds()
        local configIds = {}
        local furnitureIds = XFurnitureManager.GetFurnitureCategoryIds({ XFurnitureConfigs.FURNITURE_CATEGORY_ALL_ID },
                                                                       { XFurnitureConfigs.FURNITURE_SUIT_CATEGORY_ALL_ID }, false)
        for k, id in pairs(furnitureIds) do
            local furnitureData = XFurnitureManager.GetFurnitureConfigByUniqueId(id)
            if furnitureData then
                configIds[furnitureData.Id] = furnitureData.Id
            end
        end

        return configIds
    end

    -- 判断是否已经有的该图鉴
    function XFurnitureManager.IsFieldGuideHave(id)
        if not id then
            return false
        end

        local ids = XFurnitureManager.GetTotalFurnitureIds() or {}
        return ids[id] ~= nil
    end

    -- 获取家具得总积分
    function XFurnitureManager.GetFurnitureScore(furnitureId,dormDataType)
        local t = XFurnitureManager.GetFurnitureById(furnitureId,dormDataType)
        if not t then
            return 0
        end

        return t:GetScore()
    end

    function XFurnitureManager.GetFurnitureRedScore(furnitureId)
        local t = XFurnitureManager.GetFurnitureById(furnitureId)
        if t then
            return t:GetRedScore()
        end

        return 0
    end

    function XFurnitureManager.GetFurnitureYellowScore(furnitureId)
        local t = XFurnitureManager.GetFurnitureById(furnitureId)
        if t then
            return t:GetYellowScore()
        end

        return 0
    end

    function XFurnitureManager.GetFurnitureBlueScore(furnitureId)
        local t = XFurnitureManager.GetFurnitureById(furnitureId)
        if t then
            return t:GetBlueScore()
        end

        return 0
    end

    -- 获取家具特殊效果描述
    function XFurnitureManager.GetFurnitureEffectDesc(furnitureId)
        local t = XFurnitureManager.GetFurnitureById(furnitureId)
        if t.Addition <= 0 then
            return CS.XTextManager.GetText("DormFurnitureEffectDescNull")
        end

        local addConfig = XFurnitureConfigs.GetAdditonAttrConfigById(t.Addition)
        return addConfig.Introduce
    end

    -- 分别获取家具三条属性总分(attrA, attrB, attrC)
    function XFurnitureManager.GetFurniturePartScore(furnitureIds,dormDataType)
        local attrA = 0
        local attrB = 0
        local attrC = 0

        if furnitureIds then
            for _, id in ipairs(furnitureIds) do
                local t = XFurnitureManager.GetFurnitureById(id,dormDataType)
                if t then
                    attrA = attrA + t:GetRedScore()
                    attrB = attrB + t:GetYellowScore()
                    attrC = attrC + t:GetBlueScore()
                end
            end
        end

        return attrA, attrB, attrC
    end

    -- 添加家具
    function XFurnitureManager.AddFurniture(furnitureData, dormDataType)
        local datas
        if not dormDataType or dormDataType == XDormConfig.DormDataType.Self then
            datas = FurnitureDatas
        else
            datas = OtherFurnitureDatas
        end

        if datas[furnitureData.Id] then
            XLog.Error("FurnitureDatas is already exist furniture id is" .. furnitureData.Id)
            return
        end

        datas[furnitureData.Id] = XHomeFurnitureData.New(furnitureData)

        if not dormDataType or dormDataType == XDormConfig.DormDataType.Self then
            FurnitureDatasCount = FurnitureDatasCount + 1

            -- FurnitureCategoryTypes同时添加
            local configId = furnitureData.ConfigId
            local furnitureTypeId = XFurnitureConfigs.GetFurnitureTypeCfgByConfigId(configId).Id

            if not FurnitureCategoryTypes[furnitureTypeId] then
                FurnitureCategoryTypes[furnitureTypeId] = {}
            end

            if not FurnitureCategoryTypes[XFurnitureConfigs.FURNITURE_CATEGORY_ALL_ID] then
                FurnitureCategoryTypes[XFurnitureConfigs.FURNITURE_CATEGORY_ALL_ID] = {}
            end
            
            table.insert(FurnitureCategoryTypes[furnitureTypeId], furnitureData.Id)
            table.insert(FurnitureCategoryTypes[XFurnitureConfigs.FURNITURE_CATEGORY_ALL_ID], furnitureData.Id)
        end
    end

    -- 移除家具(其他人的)
    function XFurnitureManager.RemoveFurnitureOther()
        OtherFurnitureDatas = {}
    end

    -- 移除家具
    function XFurnitureManager.RemoveFurniture(furnitureId)
        -- 先FurnitureCategoryTypes 同时移除
        local configId = XFurnitureManager.GetFurnitureConfigId(furnitureId)
        local furnitureTypeId = XFurnitureConfigs.GetFurnitureTypeCfgByConfigId(configId).Id

        if FurnitureCategoryTypes[furnitureTypeId] then
            local index
            for i, v in ipairs(FurnitureCategoryTypes[furnitureTypeId]) do
                if furnitureId == v then
                    index = i
                    break
                end
            end

            if index then
                table.remove(FurnitureCategoryTypes[furnitureTypeId], index)
            end
        end

        if FurnitureCategoryTypes[XFurnitureConfigs.FURNITURE_CATEGORY_ALL_ID] then
            local index
            for i, v in ipairs(FurnitureCategoryTypes[XFurnitureConfigs.FURNITURE_CATEGORY_ALL_ID]) do
                if furnitureId == v then
                    index = i
                    break
                end
            end

            if index then
                table.remove(FurnitureCategoryTypes[XFurnitureConfigs.FURNITURE_CATEGORY_ALL_ID], index)
            end
        end

        if not FurnitureDatas[furnitureId] or FurnitureDatas[furnitureId] == nil then
            XLog.Error("FurnitureDatas is not exist furniture id is" .. furnitureId)
            return
        end
        if FurnitureDatasCount and FurnitureDatasCount > 0 then
            FurnitureDatasCount = FurnitureDatasCount - 1
        end

        FurnitureDatas[furnitureId] = nil
    end

    -- 服务器推送增加家具
    function XFurnitureManager.NotifyFurnitureOperate(data)
        if data == nil or #data <= 0 then 
            return 
        end
        
        for _, v in pairs(data) do
            if v.OperateType == XFurnitureConfigs.FurnitureOperate.Add then 
                XFurnitureManager.AddFurniture(v.Furniture)
            elseif v.OperateType == XFurnitureConfigs.FurnitureOperate.Delete then
                XFurnitureManager.RemoveFurniture(v.Furniture.Id)
            end
        end
    end

    -- 获取家具等级奖励Id
    function XFurnitureManager.GetLevelRewardId(furnitureId)
        local allScore = XFurnitureManager.GetFurnitureScore(furnitureId)
        local configId = XFurnitureManager.GetFurnitureConfigId(furnitureId)
        local furnitureTypeId = XFurnitureConfigs.GetFurnitureTypeCfgByConfigId(configId).Id
        local levelConfigs = XFurnitureConfigs.GetFurnitureLevelTemplate(furnitureTypeId)
        local rewardId

        for _, levelConfig in pairs(levelConfigs) do
            if allScore >= levelConfig.MinScore and allScore < levelConfig.MaxScore then
                rewardId = levelConfig.ReturnId
                break
            end
        end

        return rewardId
    end

    -- 获取家具品质
    function XFurnitureManager.GetLevelRewardQuality(furnitureId)
        local allScore = XFurnitureManager.GetFurnitureScore(furnitureId)
        local configId = XFurnitureManager.GetFurnitureConfigId(furnitureId)
        local furnitureTypeId = XFurnitureConfigs.GetFurnitureTypeCfgByConfigId(configId).Id
        local levelConfigs = XFurnitureConfigs.GetFurnitureLevelTemplate(furnitureTypeId)
        local quality
        for _, levelConfig in pairs(levelConfigs) do
            if allScore >= levelConfig.MinScore and allScore < levelConfig.MaxScore then
                quality = levelConfig.Quality
                break
            end
        end

        if not quality then
            XLog.Error("XFurnitureManager.GetLevelRewardQuality Error allScore is " .. allScore)
            return 1
        end
        return quality
    end

    -- 获得回收家具的奖励列表
    function XFurnitureManager.GetRecycleRewards(furnitureIds)
        local rewards = {}
        local rewardIds = {}
        local recycleRewards = {}

        for _, furnitureId in ipairs(furnitureIds) do
            local levelRewardId = XFurnitureManager.GetLevelRewardId(furnitureId)

            local configId = XFurnitureManager.GetFurnitureConfigId(furnitureId)
            local normalRewardId = XFurnitureConfigs.GetFurnitureReturnId(configId)

            if levelRewardId then
                table.insert(rewardIds, levelRewardId)
            end

            if normalRewardId then
                table.insert(rewardIds, normalRewardId)
            end
        end

        for _, rewardId in ipairs(rewardIds) do
            local rewardList = XRewardManager.GetRewardList(rewardId)
            for _, item in pairs(rewardList) do
                if rewards[item.TemplateId] then
                    rewards[item.TemplateId].Count = rewards[item.TemplateId].Count + item.Count
                else
                    rewards[item.TemplateId] = XRewardManager.CreateRewardGoodsByTemplate(item)
                end
            end
        end
        for _, reward in pairs(rewards) do
            table.insert(recycleRewards, reward)
        end

        if #recycleRewards > 0 then
            recycleRewards = XRewardManager.SortRewardGoodsList(recycleRewards)
        end

        return recycleRewards
    end

    -- 分解家具
    function XFurnitureManager.DecomposeFurniture(furnitureIds, cb)
        XNetwork.Call(FurnitureRequest.DecomposeFurniture, { FurnitureIds = furnitureIds }, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            if cb then
                cb(res.RewardGoods, res.SuccessIds)
            end

            XEventManager.DispatchEvent(XEventId.EVENT_FURNITURE_ON_MODIFY)
        end)
    end

    function XFurnitureManager.GetRewardFurnitureAttr(extraAttrId)
        local extraAttr = XFurnitureConfigs.GetFurnitureExtraAttrsById(extraAttrId)
        local total = XFurnitureConfigs.GetFurnitureBaseAttrValueById(extraAttr.BaseAttrId)

        local totalPercent = extraAttr.AttrIds[XFurnitureConfigs.AttrType.AttrA] + extraAttr.AttrIds[XFurnitureConfigs.AttrType.AttrB] + extraAttr.AttrIds[XFurnitureConfigs.AttrType.AttrC]

        local attrA = math.floor(extraAttr.AttrIds[XFurnitureConfigs.AttrType.AttrA] / totalPercent * total or 0)
        local attrB = math.floor(extraAttr.AttrIds[XFurnitureConfigs.AttrType.AttrB] / totalPercent * total or 0)
        local attrC = total - attrA - attrB

        return attrA, attrB, attrC
    end


    -- 获取奖励家具特殊属性id
    function XFurnitureManager.GetRewardFurnitureEffectId(furntiureRewardId)
        local template = XFurnitureConfigs.GetFurnitureReward(furntiureRewardId)
        if not template then
            return 0
        end

        return template.AdditionId
    end

    -- 获取奖励家具品质
    function XFurnitureManager.GetRewardFurnitureQuality(id)
        local template = XFurnitureConfigs.GetFurnitureReward(id)
        if not template then
            return 0
        end

        local attrScore = XFurnitureConfigs.GetFurntiureExtraAttrTotalValue(template.ExtraAttrId)
        local additionScore = XFurnitureConfigs.GetAdditionalAddScore(template.AdditionId)

        local allScore = attrScore + additionScore
        local furnitureTypeId = XFurnitureConfigs.GetFurnitureTypeCfgByConfigId(template.FurnitureId).Id
        local levelConfigs = XFurnitureConfigs.GetFurnitureLevelTemplate(furnitureTypeId)

        for _, levelConfig in ipairs(levelConfigs) do
            if allScore >= levelConfig.MinScore and allScore < levelConfig.MaxScore then
                return levelConfig.Quality
            end
        end

        return 0
    end

    -- 获取Extra家具总分
    function XFurnitureManager.GetRewardFurnitureScore(id)
        local template = XFurnitureConfigs.GetFurnitureReward(id)
        if not template then
            return 0
        end

        local attrScore = XFurnitureConfigs.GetFurntiureExtraAttrTotalValue(template.ExtraAttrId)
        local additionScore = XFurnitureConfigs.GetAdditionalAddScore(template.AdditionId)

        return attrScore + additionScore
    end

    ---------------------ppx manager start---------------------

    function XFurnitureManager.IsFurnitureMatchType(id, targetType)
        local furnitureDatas = XFurnitureManager.GetFurnitureById(id)
        local furnitureTemplates = XFurnitureConfigs.GetFurnitureTemplateById(furnitureDatas.ConfigId)
        if furnitureTemplates then
            return furnitureTemplates.TypeId == targetType
        end
        return false
    end

    function XFurnitureManager.UpdateFurnitureCreateList(pos, endTime, furniture)
        for k, v in pairs(FurnitureCreateDatas) do
            if v.Pos == pos then
                v.EndTime = endTime
                v.Furniture = furniture
                return
            end
        end
        table.insert(FurnitureCreateDatas, {
            Pos = pos,
            EndTime = endTime,
            Furniture = furniture
        })
    end

    function XFurnitureManager.GetFurnitureCreateItemByPos(pos)
        if not FurnitureCreateDatas then
            return nil
        end

        for k, v in pairs(FurnitureCreateDatas) do
            if v.Pos == pos then
                return v
            end
        end
    end

    function XFurnitureManager.RemoveFurnitureCreateListByPos(pos)
        local key = nil
        for k, v in pairs(FurnitureCreateDatas) do
            if v.Pos == pos then
                key = k
                break
            end
        end
        if key then
            FurnitureCreateDatas[key] = nil
        end
    end

    function XFurnitureManager.HasCollectableFurniture()
        if not FurnitureCreateDatas then 
            return false 
        end
        local now = XTime.Now()
        local canCollect = false
        for k, v in pairs(FurnitureCreateDatas) do
            if v.EndTime <= now then 
                canCollect = true
                break
            end
        end
        return canCollect
    end

    function XFurnitureManager.GetFurnitureCreateList()
        return FurnitureCreateDatas
    end


    --判断坑位已满
    function XFurnitureManager.IsFurnitureCreatePosFull()
        local maxCreateNum = CS.XGame.Config:GetInt("DormFurnitureCreateNum")
        if not FurnitureCreateDatas then
            return false
        end

        local buildingNum = 0
        for k, v in pairs(FurnitureCreateDatas) do
            buildingNum = buildingNum + 1
        end

        if buildingNum == maxCreateNum then
            return true
        end

        return false
    end



    -- 获取所有MinorType类型的家具数量，需要过滤风格参数
    function XFurnitureManager.GetFurnitureCountByMinorTypeAndSuitId(roomId, furnitureCache, suitId, minorType)
        local totalDatas = furnitureCache or {}
        local totalCount = 0

        for k, v in pairs(totalDatas) do
            local furnitureTemplate = XFurnitureConfigs.GetFurnitureTemplateById(v.ConfigId)
            local currentTypeDatas = XFurnitureConfigs.GetFurnitureTypeById(furnitureTemplate.TypeId)
            local currentBaseDatas = XFurnitureConfigs.GetFurnitureBaseTemplatesById(v.ConfigId)
            local currentFurniture = XFurnitureManager.GetFurnitureById(v.Id)
            local isUsing = currentFurniture:CheckIsUsed() and currentFurniture.DormitoryId ~= roomId--不计算其他宿舍的

            if XFurnitureManager.IsAllSuit(suitId) then
                --全部
                if (not isUsing) and currentTypeDatas.MinorType == minorType then
                    totalCount = totalCount + 1
                end
            else
                if (not isUsing) and currentTypeDatas.MinorType == minorType and currentBaseDatas.SuitId == suitId then
                    totalCount = totalCount + 1
                end
            end
        end
        return totalCount
    end

    function XFurnitureManager.GetFurnitureCountByMinorAndCategoryAndSuitId(roomId, furnitureCache, suitId, minor, category)
        local totalDatas = furnitureCache or {}
        local totalCount = 0
        category = category or 0

        for k, v in pairs(totalDatas) do
            local furnitureTemplate = XFurnitureConfigs.GetFurnitureTemplateById(v.ConfigId)
            local currentTypeDatas = XFurnitureConfigs.GetFurnitureTypeById(furnitureTemplate.TypeId)
            local currentBaseDatas = XFurnitureConfigs.GetFurnitureBaseTemplatesById(v.ConfigId)
            local currentFurniture = XFurnitureManager.GetFurnitureById(v.Id)
            local isUsing = currentFurniture:CheckIsUsed() and currentFurniture.DormitoryId ~= roomId--不计算其他宿舍的

            if not isUsing then
                if XFurnitureManager.IsAllSuit(suitId) then
                    if currentTypeDatas.MinorType == minor and currentTypeDatas.Category == category then
                        totalCount = totalCount + 1
                    end
                else
                    if suitId == currentBaseDatas.SuitId and currentTypeDatas.MinorType == minor and currentTypeDatas.Category == category then
                        totalCount = totalCount + 1
                    end
                end
            end
        end

        return totalCount
    end

    -- 获取过滤的家具数据
    function XFurnitureManager.FilterDisplayFurnitures(roomId, suitId, minorType, categoryType)
        local totalDatas = XDataCenter.FurnitureManager.GetFurnitureDatas()
        local list = {}
        -- 过滤
        for k, v in pairs(totalDatas) do
            local furnitureTemplate = XFurnitureConfigs.GetFurnitureTemplateById(v.ConfigId)
            local baseData = XFurnitureConfigs.GetFurnitureBaseTemplatesById(v.ConfigId)
            local currentTypeDatas = XFurnitureConfigs.GetFurnitureTypeById(furnitureTemplate.TypeId)
            local isUsing = XFurnitureManager.CheckFurnitureUsing(v.Id)

            if not isUsing then
                if suitId and suitId ~= 1 then
                    --有套装id
                    if baseData.SuitId == suitId then
                        if categoryType ~= nil and categoryType ~= 0 then
                            --不为空
                            if currentTypeDatas.MinorType == minorType and currentTypeDatas.Category == categoryType then
                                table.insert(list, v)
                            end
                        else
                            if currentTypeDatas.MinorType == minorType then
                                table.insert(list, v)
                            end
                        end
                    end
                else
                    --没有套装id
                    if categoryType ~= nil and categoryType ~= 0 then
                        --不为空
                        if currentTypeDatas.MinorType == minorType and currentTypeDatas.Category == categoryType then
                            table.insert(list, v)
                        end
                    else
                        if currentTypeDatas.MinorType == minorType then
                            table.insert(list, v)
                        end
                    end
                end
            end
        end
        return list
    end

    -- 获取家具套装数量
    function XFurnitureManager.GetFurnitureCountBySuitId(roomId, cache, suitId)

        local typeList = XFurnitureConfigs.GetFurnitureTypeList()

        local totalCount = 0
        if XFurnitureManager.IsAllSuit(suitId) then
            for id, typeDatas in pairs(typeList) do
                local baseType = typeDatas.MinorType
                local cacheBaseKey = XFurnitureManager.GenerateCacheKey(baseType, nil)
                for _, furniture in pairs(cache[cacheBaseKey]) do
                    totalCount = totalCount + 1
                end
            end
        else
            for id, typeDatas in pairs(typeList) do
                local baseType = typeDatas.MinorType
                local cacheBaseKey = XFurnitureManager.GenerateCacheKey(baseType, nil)
                for _, furniture in pairs(cache[cacheBaseKey]) do

                    local baseData = XFurnitureConfigs.GetFurnitureBaseTemplatesById(furniture.ConfigId)
                    if baseData.SuitId == suitId then
                        totalCount = totalCount + 1
                    end

                end
            end
        end

        return totalCount
    end

    function XFurnitureManager.GenerateCacheKey(baseType, subType)
        if not baseType then
            return
        end

        if subType == nil then
            return string.format("%d_", baseType)
        else
            return string.format("%d_%d_", baseType, subType)
        end
    end

    function XFurnitureManager.IsAllSuit(suitId)
        return suitId == nil or suitId == 0 or suitId == 1
    end

    -- 摆放家具
    function XFurnitureManager.PutFurniture(dormitoryId, furnitureList, func)
        XNetwork.Call(FurnitureRequest.PutFurniture, {
            DormitoryId = dormitoryId,
            FurnitureList = furnitureList
        }, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            if func then
                func()
            end
        end)
    end

    -- 改造家具
    function XFurnitureManager.RemouldFurniture(furnitureId, draftId, func)
        XNetwork.Call(FurnitureRequest.RemouldFurniture, { FurnitureId = furnitureId, ItemId = draftId }, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            -- 清除消耗的家具
            XFurnitureManager.RemoveFurniture(furnitureId)
            XFurnitureManager.DeleteNewHint({ [1] = furnitureId })

            -- 添加新增的家具
            XFurnitureManager.AddFurniture(res.Furniture)
            XFurnitureManager.DeleteNewHint({ [1] = res.Furniture.Id })

            if func then
                func(res.Furniture)
            end
        end)
    end

    -- 领取家具,
    function XFurnitureManager.CheckCreateFurniture(pos, func)
        XNetwork.Call(FurnitureRequest.CheckCreateFurniture, { Pos = pos }, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            -- 清除FurnitureManager的创建家具列表数据
            XFurnitureManager.RemoveFurnitureCreateListByPos(pos)
            -- 将家具添加到List列表
            XFurnitureManager.AddFurniture(res.Furniture)
            if func then
                func(res.Furniture)
            end
        end)
    end

    -- 建造家具
    function XFurnitureManager.CreateFurniture(pos, typeId, costA, costB, costC, func)
        XNetwork.Call(FurnitureRequest.CreateFurniture, {
            Pos = pos,
            TypeId = typeId,
            CostA = costA,
            CostB = costB,
            CostC = costC
        }, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            -- 添加到FurnitureManager
            XFurnitureManager.UpdateFurnitureCreateList(pos, res.EndTime, res.Furniture)
            if func then
                -- 刷新界面
                func()
            end
        end)
    end

    -- 根据家具属性获得贴图
    function XFurnitureManager.GetFurnitureMaterial(furnitureId, dormDataType)
        if not furnitureId then
            return
        end
        
        local furnitureData = XFurnitureManager.GetFurnitureById(furnitureId, dormDataType)
        if not furnitureData then
            return
        end

        local furnitureColour = XFurnitureConfigs.GetFurnitureColour(furnitureData.ConfigId)
        if not furnitureColour then
            return
        end

        local maxAttrKey = 0
        local maxAttrVal = 0
        local midAttrKey = 0
        local midAttrVal = 0

        for k, v in pairs(furnitureData.AttrList) do
            if v >= maxAttrVal then
                midAttrKey = maxAttrKey
                midAttrVal = maxAttrVal

                maxAttrKey = k
                maxAttrVal = v
            elseif v >= midAttrVal then
                midAttrKey = k
                midAttrVal = v
            end
        end

        -- 最高和第二高值一致，则返回默认
        if maxAttrVal == midAttrVal then
            return furnitureColour.DefaultMaterial
        end
        if midAttrVal == 0 then
            return furnitureColour.FurnitureMaterials[maxAttrKey]
        end

        local attrOverRate = (maxAttrVal - midAttrVal) / midAttrVal * 100
        if furnitureColour and attrOverRate >= furnitureColour.AttrIds[maxAttrKey] then
            return furnitureColour.FurnitureMaterials[maxAttrKey]
        end

        return furnitureColour.DefaultMaterial
    end

    -- 根据家具属性获得家具特效
    function XFurnitureManager.GetFurnitureFx(furnitureId, dormDataType)
        if not furnitureId then
            return
        end
        
        local furnitureData = XFurnitureManager.GetFurnitureById(furnitureId, dormDataType)
        if not furnitureData then
            return
        end

        local furnitureColour = XFurnitureConfigs.GetFurnitureColour(furnitureData.ConfigId)
        if not furnitureColour then
            return
        end

        local maxAttrKey = 0
        local maxAttrVal = 0
        local midAttrKey = 0
        local midAttrVal = 0

        for k, v in pairs(furnitureData.AttrList) do
            if v >= maxAttrVal then
                midAttrKey = maxAttrKey
                midAttrVal = maxAttrVal

                maxAttrKey = k
                maxAttrVal = v
            elseif v >= midAttrVal then
                midAttrKey = k
                midAttrVal = v
            end
        end

        -- 最高和第二高值一致，则返回默认
        if maxAttrVal == midAttrVal then
            return furnitureColour.DefaultFurnitureFx
        end
        if midAttrVal == 0 then
            return furnitureColour.FurnitureFx[maxAttrKey]
        end

        local attrOverRate = (maxAttrVal - midAttrVal) / midAttrVal * 100
        if furnitureColour and attrOverRate >= furnitureColour.AttrIds[maxAttrKey] then
            return furnitureColour.FurnitureFx[maxAttrKey]
        end

        return furnitureColour.DefaultFurnitureFx
    end

    -- 读取家具表的Icon,不能获得家具的属性用这个接口
    function XFurnitureManager.GetFurnitureIconByConfigId(configId)
        local furnitureTemplates = XFurnitureConfigs.GetFurnitureBaseTemplatesById(configId)
        if not furnitureTemplates then
            return ""
        end
        return furnitureTemplates.Icon
    end

    -- 根据家具属性计算家具的Icon,能获得家具的属性用这个接口
    function XFurnitureManager.GetFurnitureIconById(furnitureId, dormDataType)
        if not furnitureId then
            return ""
        end
        
        local furnitureData = XFurnitureManager.GetFurnitureById(furnitureId, dormDataType)
        return XFurnitureManager.GetIconByFurniture(furnitureData)
    end

    function XFurnitureManager.GetIconByFurniture(furniture)
        if not furniture then
            return ""
        end

        local baseIcon = XFurnitureManager.GetFurnitureIconByConfigId(furniture.ConfigId)

        local furnitureColour = XFurnitureConfigs.GetFurnitureColour(furniture.ConfigId)
        if not furnitureColour then
            return baseIcon
        end

        local maxAttrKey = 0
        local maxAttrVal = 0
        local midAttrKey = 0
        local midAttrVal = 0

        for k, v in pairs(furniture.AttrList) do
            if v >= maxAttrVal then
                midAttrKey = maxAttrKey
                midAttrVal = maxAttrVal

                maxAttrKey = k
                maxAttrVal = v
            elseif v >= midAttrVal then
                midAttrKey = k
                midAttrVal = v
            end
        end

        local defaultIcon = (furnitureColour.DefaultFurnitureIcon == "") and baseIcon or furnitureColour.DefaultFurnitureIcon
        local chooseIcon = (furnitureColour.FurnitureIcons[maxAttrKey] == "") and defaultIcon or furnitureColour.FurnitureIcons[maxAttrKey]

        -- 最高和第二高值一致，则返回默认
        if maxAttrVal == midAttrVal then
            return defaultIcon
        end
        if midAttrVal == 0 then
            return chooseIcon
        end

        local attrOverRate = (maxAttrVal - midAttrVal) / midAttrVal * 100
        if furnitureColour and attrOverRate >= furnitureColour.AttrIds[maxAttrKey] then
            return chooseIcon
        end
        return defaultIcon
    end

    function XFurnitureManager.GetTemplateCount(templateId)
        local totalCount = 0
        for k, v in pairs(XFurnitureManager.GetFurnitureDatas()) do
            local isUsing = XFurnitureManager.CheckFurnitureUsing(v.Id)
            if (not isUsing) and v.ConfigId == templateId then
                totalCount = totalCount + 1
            end
        end
        return totalCount
    end
    ---------------------ppx manager end-----------------------

    return XFurnitureManager
end

XRpc.NotifyFurnitureOperate = function(data)
    XDataCenter.FurnitureManager.NotifyFurnitureOperate(data.OperateList)
end
