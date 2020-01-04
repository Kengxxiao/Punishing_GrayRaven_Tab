XBaseEquipManagerCreator = function()

    local pairs = pairs

    local table = table
    local tableInsert = table.insert
    local tableSort = table.sort
    local string = string
    local stringFormat = string.format

    local XBaseEquipManager = {}


    local METHOD_NAME = {
        Evaluate = "BaseEquipEvaluateRequest",
        PutOn = "BaseEquipPutOnRequest",
        Recycle = "BaseEquipRecycleRequest"
    }

    XBaseEquipManager.XATTRIB_CHANGE = {
        NoChange = 0,
        Up = 1,
        Down = 2
    }

    local BaseEquipTemplates = {}       -- 基地装备配置

    local BaseEquipDatas = {}           -- 基地装备数据
    local BaseEquipInfo = {}            -- 已装备的基地装备信息
    local EvaluatedAttribInfoDict = {}  -- 基地装备属性信息

    function XBaseEquipManager.Init()
        BaseEquipTemplates = XBaseEquipConfigs.GetBaseEquipTemplates()
    end

    function XBaseEquipManager.IsBaseEquipEvaluated(baseEquip)
        return baseEquip.AttribGroupIdList and #baseEquip.AttribGroupIdList > 0
    end

    function XBaseEquipManager.IsBaseEquipPutOn(baseEquipId)
        for _, id in pairs(BaseEquipInfo) do
            if id == baseEquipId then
                return true
            end
        end

        return false
    end

    local function PutOnBaseEquip(part, baseEquipId)
        BaseEquipInfo[part] = baseEquipId
    end

    local function DeleteBaseEquips(idList)
        for _, id in pairs(idList) do
            BaseEquipDatas[id] = nil
        end
    end

    local function GetAttribInfo(groupId)
        local template = XAttribManager.TryGetAttribGroupTemplate(groupId)
        if not template then
            return 
        end
        
        local numericalList = {}
        if template.AttribId > 0 then
            local attrib = XAttribManager.GetBaseAttribs(template.AttribId)
            for k, v in pairs(attrib) do
                if k ~= "Id" and v > fix.zero then
                    tableInsert(numericalList, {
                        Name = XAttribManager.GetAttribNameByIndex(k),
                        Key = k,
                        Value = v
                    })
                end
            end
        end

        local growRateList = {}
        if template.AttribGrowRateId > 0 then
            local attrib = XAttribManager.GetGrowRateAttribs(template.AttribGrowRateId)
            for k, v in pairs(attrib) do
                if k ~= "Id" and v > fix.zero then
                    tableInsert(growRateList, {
                        Name = XAttribManager.GetAttribNameByIndex(k),
                        Key = k,
                        Value = v
                    })
                end
            end
        end

        return numericalList, growRateList
    end

    local function GetMaxAttribDesc(groupId)
        local template = XAttribManager.TryGetAttribGroupTemplate(groupId)
        if not template then
            return
        end

        return template.MaxAttribDesc
    end

    local function AddEvaluatedAttribInfo(baseEquipData)
        if not baseEquipData then
            return
        end

        local attribPoolIdList = baseEquipData.AttribGroupIdList
        if not attribPoolIdList or #attribPoolIdList <= 0 then
            return
        end

        local numericalList = {}
        local growRateList = {}

        for _, id in pairs(attribPoolIdList) do
            local list1, list2 = GetAttribInfo(id)

            for _, info in pairs(list1) do
                tableInsert(numericalList, info)
            end

            for _, info in pairs(list2) do
                tableInsert(growRateList, info)
            end
        end

        EvaluatedAttribInfoDict[baseEquipData.Id] = {
            NumericalList = numericalList,
            GrowRateList = growRateList,
        }
    end

    function XBaseEquipManager.GetBaseEquipTemplate(templateId)
        local template = BaseEquipTemplates[templateId]
        if not template then
            XLog.Error("XBaseEquipManager.GetBaseEquipTemplate erorr: can not found template, templateId is " .. templateId)
            return
        end

        return template
    end

    local function SortBaseEquipFunc(a, b)
        local isEvaluated1 = XBaseEquipManager.IsBaseEquipEvaluated(a)
        local isEvaluated2 = XBaseEquipManager.IsBaseEquipEvaluated(b)

        if isEvaluated1 ~= isEvaluated2 then
            return isEvaluated2
        end

        local template1 = XBaseEquipManager.GetBaseEquipTemplate(a.TemplateId)
        local template2 = XBaseEquipManager.GetBaseEquipTemplate(b.TemplateId)

        if template1.Star ~= template2.Star then
            return template1.Star > template2.Star
        end

        if template1.Quality ~= template2.Quality then
            return template1.Quality > template2.Quality
        end

        return template1.Priority > template2.Priority
    end

    function XBaseEquipManager.GetBaseEquipListByPart(part)
        part = part and part or 0
        local list = {}
        for _, baseEquip in pairs(BaseEquipDatas) do
            local template = XBaseEquipManager.GetBaseEquipTemplate(baseEquip.TemplateId)
            if template.Part == part or part == 0 then
                tableInsert(list, baseEquip)
            end
        end

        tableSort(list, SortBaseEquipFunc)

        return list
    end

    function XBaseEquipManager.GetBaseEquipNotPutOnListByPart(part)
        part = part and part or 0
        local list = {}
        for _, baseEquip in pairs(BaseEquipDatas) do
            if not XBaseEquipManager.IsBaseEquipPutOn(baseEquip.Id) then
                local template = XBaseEquipManager.GetBaseEquipTemplate(baseEquip.TemplateId)
                if template.Part == part or part == 0 then
                    tableInsert(list, baseEquip)
                end
            end
        end

        tableSort(list, SortBaseEquipFunc)

        return list
    end

    --==============================--
    --desc: 获取属性信息
    --@id: 基地装备id
    --@return 属性信息
    --==============================--
    function XBaseEquipManager:GetEvaluatedAttribInfo(id)
        return EvaluatedAttribInfoDict[id]
    end

    --==============================--
    --desc: 获取属性展示信息
    --@pooId: 基地装备id
    --@return 属性展示信息
    --==============================--
    function XBaseEquipManager.GetEvaluatedAttribShowInfo(id)
        local info = EvaluatedAttribInfoDict[id]
        if not info then
            return
        end

        local attriDescList = {}
        if info.NumericalList and #info.NumericalList > 0 then
            for _, v in pairs(info.NumericalList) do
                tableInsert(attriDescList, {
                    Name = v.Name,
                    Key = v.Key,
                    Value = "+" .. FixToInt(v.Value)
                })
            end
        end

        if info.GrowRateList and #info.GrowRateList > 0 then
            for _, v in pairs(info.GrowRateList) do
                tableInsert(attriDescList, {
                    Name = v.Name,
                    Key = v.Key,
                    Value = "+" .. stringFormat("%.2f", (v.Value * fix.hundred):ToString()) .. "%"
                })
            end
        end

        return {
            AttriDescList = attriDescList,
        }
    end

    function XBaseEquipManager.GetEvaluatedMaxAttribShowInfo(id)
        local data = BaseEquipDatas[id]
        if not data then
            return
        end

        local maxAttribDescList = {}
        for _, pooId in pairs(data.AttribGroupIdList) do
            tableInsert(maxAttribDescList, GetMaxAttribDesc(pooId))
        end

        return maxAttribDescList
    end

    function XBaseEquipManager.GetBaseEquipPart(templateId)
        local template = BaseEquipTemplates[templateId]
        if not template then
            XLog.Error("XBaseEquipManager.GetBaseEquipPart erorr: can not found template, templateId is " .. templateId)
            return
        end

        return template.Part
    end

    function XBaseEquipManager.GetBaseEquipName(templateId)
        local template = BaseEquipTemplates[templateId]
        if not template then
            XLog.Error("XBaseEquipManager.GetBaseEquipName erorr: can not found template, templateId is " .. templateId)
            return
        end

        return template.Name
    end

    function XBaseEquipManager.GetBaseEquipQuality(templateId)
        local template = BaseEquipTemplates[templateId]
        if not template then
            XLog.Error("XBaseEquipManager.GetBaseEquipQuality erorr: can not found template, templateId is " .. templateId)
            return
        end

        return template.Quality
    end

    function XBaseEquipManager.GetBaseEquipIcon(templateId)
        local template = BaseEquipTemplates[templateId]
        if not template then
            XLog.Error("XBaseEquipManager.GetBaseEquipIcon erorr: can not found template, templateId is " .. templateId)
            return
        end

        return template.Icon
    end

    function XBaseEquipManager.GetBaseEquipBigIcon(templateId)
        local template = BaseEquipTemplates[templateId]
        if not template then
            XLog.Error("XBaseEquipManager.GetBaseEquipBigIcon erorr: can not found template, templateId is " .. templateId)
            return
        end

        return template.BigIcon
    end

    function XBaseEquipManager.GetBaseEquipDesc(templateId)
        local template = BaseEquipTemplates[templateId]
        if not template then
            XLog.Error("XBaseEquipManager.GetBaseEquipDesc erorr: can not found template, templateId is " .. templateId)
            return
        end

        return template.Description
    end

    function XBaseEquipManager.GetBaseEquipNotEvaluatedDesc(templateId)
        local template = BaseEquipTemplates[templateId]
        if not template then
            XLog.Error("XBaseEquipManager.GetBaseEquipNotEvaluatedDesc erorr: can not found template, templateId is " .. templateId)
            return
        end

        return template.NotEvaluatedDesc
    end

    function XBaseEquipManager.GetBaseEquipRecoveryRewardId(templateId)
        local template = BaseEquipTemplates[templateId]
        if not template then
            XLog.Error("XBaseEquipManager.GetBaseEquipRecoveryRewardId erorr: can not found template, templateId is " .. templateId)
            return
        end

        return template.RecoveryRewardId
    end

    function XBaseEquipManager.GetBaseEquipRecoveryRewardList(templateIdList)
        if not templateIdList or #templateIdList <= 0 then
            return
        end

        local rewardGoodsList = {}
        for _, templateId in pairs(templateIdList) do
            local rewardId = XBaseEquipManager.GetBaseEquipRecoveryRewardId(templateId)
            if rewardId then
                local rewardList = XRewardManager.GetRewardList(rewardId)
                for _, reward in pairs(rewardList) do
                    tableInsert(rewardGoodsList, reward)
                end
            end
        end

        return XRewardManager.MergeAndSortRewardGoodsList(rewardGoodsList)
    end

    function XBaseEquipManager.GetBaseEquipStar(templateId)
        local template = XBaseEquipManager.GetBaseEquipTemplate(templateId)
        return template.Star
    end

    function XBaseEquipManager.GetBaseEquipInfo()
        local baseEquipDict = {}
        for k, v in pairs(BaseEquipInfo) do
            local baseEquip = BaseEquipDatas[v]
            baseEquipDict[k] = baseEquip
        end
        return baseEquipDict
    end

    function XBaseEquipManager.GetBaseEquipById(id)
        return BaseEquipDatas[id]
    end

    function XBaseEquipManager.GetBaseEquipByPart(part)
        local id = BaseEquipInfo[part]
        if not id then
            return
        end

        return BaseEquipDatas[id]
    end

    --==============================--
    --desc: 比较属性变化
    --@newId: 基地装备Id
    --@oldId: 基地装备Id
    --@return 比较结果
    --==============================--
    function XBaseEquipManager.CompareAttrib(newId, oldId)
        if not newId then
            return
        end

        local newInfo = XBaseEquipManager:GetEvaluatedAttribInfo(newId)
        local oldInfo

        if oldId then
            oldInfo = XBaseEquipManager:GetEvaluatedAttribInfo(oldId)
        end

        local resultList = {}

        local compareFunc = function(curInfo, infoList)
            local result = XBaseEquipManager.XATTRIB_CHANGE.Up

            if not infoList or #infoList <= 0 then
                return result
            end

            for _, info in pairs(infoList) do
                if info.Key == curInfo.Key then
                    if info.Value > curInfo.Value then
                        result = XBaseEquipManager.XATTRIB_CHANGE.Down
                    elseif info.Value < curInfo.Value then
                        result = XBaseEquipManager.XATTRIB_CHANGE.Up
                    else
                        result = XBaseEquipManager.XATTRIB_CHANGE.NoChange
                    end
                    break
                end
            end

            return result
        end

        if newInfo.NumericalList and #newInfo.NumericalList > 0 then
            for _, info in pairs(newInfo.NumericalList) do
                tableInsert(resultList, compareFunc(info, oldInfo and oldInfo.NumericalList or nil))
            end
        end

        if newInfo.GrowRateList and #newInfo.GrowRateList > 0 then
            for _, info in pairs(newInfo.GrowRateList) do
                tableInsert(resultList, compareFunc(info, oldInfo and oldInfo.GrowRateList or nil))
            end
        end

        return resultList
    end

    function XBaseEquipManager.HasBaseEquipUnEvaluated()
        for _, baseEquip in pairs(BaseEquipDatas) do
            if not XBaseEquipManager.IsBaseEquipEvaluated(baseEquip) then
                return true
            end
        end

        return false
    end

    function XBaseEquipManager.GetBaseEquipCount(templateId)
        local count = 0
        for _, baseEquip in pairs(BaseEquipDatas) do
            if baseEquip.TemplateId == templateId then
                count = count + 1
            end
        end
        return count
    end

    function XBaseEquipManager.GetAttribGroupIdListByType(type)
        local groupIdList = {}

        for _, id in pairs(BaseEquipInfo) do
            local baseEquip = BaseEquipDatas[id]
            if baseEquip then
                local template = XBaseEquipManager.GetBaseEquipTemplate(baseEquip.TemplateId)
                if template and template.Type == type then
                    for _, groupId in pairs(baseEquip.AttribGroupIdList) do
                        tableInsert(groupIdList, groupId)
                    end
                end
            end
        end

        return groupIdList
    end

    ----------------------服务端协议begin----------------------
    function XBaseEquipManager.Evaluate(id, cb)
        local baseEquipData = BaseEquipDatas[id]
        if not baseEquipData then
            XUiManager.TipCode(XCode.BaseEquipNotFound)
            return
        end

        if XBaseEquipManager.IsBaseEquipEvaluated(baseEquipData) then
            XUiManager.TipCode(XCode.BaseEquipEvaluated)
            return
        end

        XNetwork.Call(METHOD_NAME.Evaluate, { Id = id }, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            if cb then
                cb(BaseEquipDatas[id])
            end
        end)
    end

    function XBaseEquipManager.PutOn(id, cb)
        local baseEquipData = BaseEquipDatas[id]
        if not baseEquipData then
            XUiManager.TipCode(XCode.BaseEquipNotFound)
            return
        end

        local template = BaseEquipTemplates[baseEquipData.TemplateId]
        if not template then
            XUiManager.TipCode(XCode.BaseEquipTemplateNoFound)
            return
        end


        if XBaseEquipManager.IsBaseEquipPutOn(id) then
            XUiManager.TipCode(XCode.BaseEquipWasPutOn)
            return
        end

        XNetwork.Call(METHOD_NAME.PutOn, { Id = id }, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            PutOnBaseEquip(template.Part, id)

            if cb then
                cb()
            end

            XEventManager.DispatchEvent(XEventId.EVENT_BASE_EQUIP_DATA_CHANGE_NOTIFY, id)
        end)
    end

    -- 本地管理的红点 -> 移除
    function XBaseEquipManager.DeleteNewHint(id)
        local key = XPrefs.BaseEquip .. tostring(XPlayer.Id) .. id
        if CS.UnityEngine.PlayerPrefs.HasKey(key) then
            CS.UnityEngine.PlayerPrefs.DeleteKey(key)
        end
    end

    -- 本地管理的红点 -> 增加Id 表示此红点不再出现！
    function XBaseEquipManager.AddNewHint(id)
        local key = XPrefs.BaseEquip .. tostring(XPlayer.Id) .. id
        if not CS.UnityEngine.PlayerPrefs.HasKey(key) then
            CS.UnityEngine.PlayerPrefs.SetString(key, key)
        end
    end

    -- 本地管理的红点 -> 检查是否需要显示红点
    -- 如果本地有存储 说明不需要显示
    function XBaseEquipManager.CheckNewHint(id)
        local key = XPrefs.BaseEquip .. tostring(XPlayer.Id) .. id
        return not CS.UnityEngine.PlayerPrefs.HasKey(key)
    end

    function XBaseEquipManager.CheckNewHintByPart(part)
        local isNew = false
        local baseEquipList = XBaseEquipManager.GetBaseEquipListByPart(part)
        for _, baseEquip in pairs(baseEquipList) do
            local key = XPrefs.BaseEquip .. tostring(XPlayer.Id) .. baseEquip.Id
            if not CS.UnityEngine.PlayerPrefs.HasKey(key) then
                isNew = true
            end
        end
        return isNew
    end

    function XBaseEquipManager.CheckBaseEquipHint()
        local isNew = false
        for part = 1, 6 do
            if XBaseEquipManager.CheckNewHintByPart(part) then
                isNew = true
                break
            end
        end
        return isNew
    end

    function XBaseEquipManager.Recycle(idList, cb)
        if #idList == 0 then
            XUiManager.TipText("BaseEquipRecycleNotSelected")
            return
        end
        local highQuality = false

        for _, id in pairs(idList) do
            local data = BaseEquipDatas[id]
            if not data then
                XUiManager.TipCode(XCode.BaseEquipNotFound)
                return
            end

            if XBaseEquipManager.IsBaseEquipPutOn(id) then
                XUiManager.TipCode(XCode.BaseEquipWasPutOn)
                return
            end

            XBaseEquipManager.DeleteNewHint(id)

            local quality = XBaseEquipManager.GetBaseEquipQuality(data.TemplateId)

            if quality >= XGoodsCommonManager.QualityType.Gold then
                highQuality = true
            end
        end

        local requestFunc = function()
            XNetwork.Call(METHOD_NAME.Recycle, { IdList = idList }, function(res)
                if res.Code ~= XCode.Success then
                    XUiManager.TipCode(res.Code)
                    return
                end

                if res.RewardGoodsList and #res.RewardGoodsList > 0 then
                    XUiManager.OpenUiObtain(res.RewardGoodsList)
                end

                DeleteBaseEquips(idList)

                if cb then
                    cb()
                end
            end)
        end

        if highQuality then
            XUiManager.DialogTip("", CS.XTextManager.GetText("DecomposeConfirmTip"), XUiManager.DialogType.Normal, nil, requestFunc)
            return
        end

        requestFunc()
    end

    local function UpdateBaseEquipDatas(baseEquipList)
        if not baseEquipList or #baseEquipList <= 0 then
            return
        end

        for _, baseEquip in pairs(baseEquipList) do
            BaseEquipDatas[baseEquip.Id] = baseEquip
            AddEvaluatedAttribInfo(baseEquip)
        end

        XEventManager.DispatchEvent(XEventId.EVENT_BASE_EQUIP_DATA_REFRESH)
    end

    function XBaseEquipManager.NotifyBaseEquipDataList(data)
        if not data then return end
        UpdateBaseEquipDatas(data.BaseEquipDataList)
    end

    function XBaseEquipManager.NotifyBaseEquipInfo(data)
        if not data then return end
        BaseEquipInfo = data.BaseEquipInfo
    end

    local function UpdateBaseEquipInfo(dressedList)
        if not dressedList or #dressedList <= 0 then
            return
        end

        for _, info in pairs(dressedList) do
            BaseEquipInfo[info.Part] = info.BaseEquipId
        end
    end

    ----------------------服务端协议end----------------------

    function XBaseEquipManager.InitLoginData(data)
        if not data then
            return
        end

        UpdateBaseEquipDatas(data.BaseEquipList)
        UpdateBaseEquipInfo(data.DressedList)
    end

    XBaseEquipManager.Init()
    return XBaseEquipManager
end

XRpc.NotifyBaseEquipDataList = function(data)
    XDataCenter.BaseEquipManager.NotifyBaseEquipDataList(data)
end