XEquipManagerCreator = function()
    local pairs = pairs
    local type = type
    local table = table
    local tableInsert = table.insert
    local tableSort = table.sort
    local mathMin = math.min
    local mathFloor = math.floor
    local CSXTextManagerGetText = CS.XTextManager.GetText

    local XEquipManager = {}
    local Equips = {}   -- 装备数据
    local WeaponTypeCheckDic = {}
    local AwarenessTypeCheckDic = {}

    local EQUIP_FIRST_GET_KEY = "EquipFirstGetTemplateIds"
    local EQUIP_DECOMPOSE_RETURN_RATE = CS.XGame.Config:GetInt("EquipDecomposeReturnRate")
    -----------------------------------------Privite Begin------------------------------------
    local function GetEquipTemplateId(equipId)
        local equip = XEquipManager.GetEquip(equipId)
        return equip.TemplateId
    end

    local function GetEquipCfg(equipId)
        local templateId = GetEquipTemplateId(equipId)
        return XEquipConfig.GetEquipCfg(templateId)
    end

    local function CheckEquipExist(equipId)
        return Equips[equipId]
    end

    local function GetEquipBorderCfg(equipId)
        local templateId = GetEquipTemplateId(equipId)
        return XEquipConfig.GetEquipBorderCfg(templateId)
    end

    local function GetSuitPresentEquipTemplateId(suitId)
        local templateIds = XEquipConfig.GetEquipTemplateIdsBySuitId(suitId)
        return templateIds and templateIds[1]
    end

    local function GetEquipBreakthroughCfg(equipId)
        local equip = XEquipManager.GetEquip(equipId)
        return XEquipConfig.GetEquipBreakthroughCfg(equip.TemplateId, equip.Breakthrough)
    end

    local function GetEquipBreakthroughCfgNext(equipId)
        local equip = XEquipManager.GetEquip(equipId)
        return XEquipConfig.GetEquipBreakthroughCfg(equip.TemplateId, equip.Breakthrough + 1)
    end

    local function InitEquipTypeCheckDic()
        WeaponTypeCheckDic[XEquipConfig.EquipSite.Weapon] = XEquipConfig.Classify.Weapon
        for _, site in pairs(XEquipConfig.EquipSite.Awareness) do
            AwarenessTypeCheckDic[site] = XEquipConfig.Classify.Awareness
        end
    end

    InitEquipTypeCheckDic()
    -----------------------------------------Privite End------------------------------------
    function XEquipManager.InitEquipData(equipsData)
        for k, equip in pairs(equipsData) do
            Equips[equip.Id] = XEquipManager.NewEquip(equip)
        end

        XEventManager.DispatchEvent(XEventId.EVENT_EQUIP_DATA_INIT_NOTIFY)
    end

    function XEquipManager.NewEquip(protoData)
        return XEquip.New(protoData)
    end

    function XEquipManager.NotifyEquipDataList(data)
        local syncList = data.EquipDataList
        if not syncList then
            return
        end

        for _, equip in pairs(syncList) do
            XEquipManager.OnSyncEquip(equip)
        end
    end

    function XEquipManager.OnSyncEquip(protoData)
        local equip = Equips[protoData.Id]
        if not equip then
            equip = XEquipManager.NewEquip(protoData)
            Equips[protoData.Id] = equip

            local templateId = protoData.TemplateId
            if XEquipManager.CheckFirstGet(templateId) then
                XUiHelper.PushInFirstGetIdList(templateId, XArrangeConfigs.Types.Weapon)
            end
        else
            equip:SyncData(protoData)
        end

        XEventManager.DispatchEvent(XEventId.EVENT_EQUIP_DATA_CHANGE_NOTIFY, equip)
    end

    function XEquipManager.DeleteEquip(equipProtoId)
        Equips[equipProtoId] = nil
    end

    function XEquipManager.GetEquip(equipId)
        local equip = Equips[equipId]
        if not equip then
            XLog.Error("XEquipManager.GetEquip error: can not found equip, equipId is " .. equipId)
            return
        end
        return equip
    end

    --desc: 获取所有武器equipId
    function XEquipManager.GetWeaponIds()
        local weaponIds = {}
        for k, v in pairs(Equips) do
            if XEquipManager.IsClassifyEqual(v.Id, XEquipConfig.Classify.Weapon) then
                tableInsert(weaponIds, k)
            end
        end
        return weaponIds
    end

    function XEquipManager.GetAwarenessIds()
        local result = {}
        for k, v in pairs(Equips) do
            if XEquipManager.IsClassifyEqualByTemplateId(v.TemplateId, XEquipConfig.Classify.Awareness) then
                tableInsert(result, k)
            end
        end
        return result
    end

    function XEquipManager.GetWeaponCount()
        local weaponIds = XEquipManager.GetWeaponIds()
        return weaponIds and #weaponIds or 0
    end

    function XEquipManager.GetAwarenessCount()
        local awarenessIds = XEquipManager.GetAwarenessIds()
        return awarenessIds and #awarenessIds or 0
    end

    function XEquipManager.GetSuitIdsByStars(starCheckList)
        local suitIds = {}

        local doNotRepeatSuitIds = {}
        local equipIds = XEquipManager.GetAwarenessIds()
        for _, equipId in pairs(equipIds) do
            local templateId = GetEquipTemplateId(equipId)
            local star = XEquipManager.GetEquipStar(templateId)

            if starCheckList[star] then
                local suitId = XEquipManager.GetSuitId(equipId)
                if suitId > 0 then
                    doNotRepeatSuitIds[suitId] = true
                end
            end
        end

        for suitId in pairs(doNotRepeatSuitIds) do
            tableInsert(suitIds, suitId)
        end

        tableSort(suitIds, function(lSuitID, rSuitID)
            local lStar = XEquipManager.GetSuitStar(lSuitID)
            local rStar = XEquipManager.GetSuitStar(rSuitID)
            return lStar > rStar
        end)

        tableInsert(suitIds, 1, XEquipConfig.DEFAULT_SUIT_ID)

        return suitIds
    end

    function XEquipManager.GetDecomposeRewards(equipIds)
        local decomposeRewards = {}

        local rewards = {}
        local coinId = XDataCenter.ItemManager.ItemId.Coin
        XTool.LoopCollection(equipIds, function(equipId)
            local equip = XEquipManager.GetEquip(equipId)
            local decomposeconfig = XEquipConfig.GetEquipDecomposeCfg(equip.TemplateId, equip.Breakthrough)
            local levelUpCfg = XEquipConfig.GetLevelUpCfg(equip.TemplateId, equip.Breakthrough, equip.Level)
            local equipBreakthroughCfg = GetEquipBreakthroughCfg(equipId)
            local exp = (equip.Exp + levelUpCfg.AllExp + equipBreakthroughCfg.Exp)

            local expToCoin = mathFloor(exp / decomposeconfig.ExpToOneCoin)
            if expToCoin > 0 then
                local coinReward = rewards[coinId]
                if coinReward then
                    coinReward.Count = coinReward.Count + expToCoin
                else
                    rewards[coinId] = XRewardManager.CreateRewardGoods(coinId, expToCoin)
                end
            end

            local expToFoodId = decomposeconfig.ExpToEquipId
            local ratedExp = exp * EQUIP_DECOMPOSE_RETURN_RATE
            local foodBreakthroughCfg = XEquipConfig.GetEquipBreakthroughCfg(expToFoodId, 0)
            local expToFoodCount = mathFloor(ratedExp / (foodBreakthroughCfg.Exp * 10000))
            if expToFoodCount > 0 then
                local foodReward = rewards[expToFoodId]
                if foodReward then
                    foodReward.Count = foodReward.Count + expToFoodCount
                else
                    rewards[expToFoodId] = XRewardManager.CreateRewardGoods(expToFoodId, expToFoodCount)
                end
            end

            if decomposeconfig.RewardId > 0 then
                local rewardList = XRewardManager.GetRewardList(decomposeconfig.RewardId)
                for _, item in pairs(rewardList) do
                    if rewards[item.TemplateId] then
                        rewards[item.TemplateId].Count = rewards[item.TemplateId].Count + item.Count
                    else
                        rewards[item.TemplateId] = XRewardManager.CreateRewardGoodsByTemplate(item)
                    end
                end
            end
        end)

        for _, reward in pairs(rewards) do
            tableInsert(decomposeRewards, reward)
        end
        decomposeRewards = XRewardManager.SortRewardGoodsList(decomposeRewards)

        return decomposeRewards
    end
    -----------------------------------------Function Begin------------------------------------
    local DefaultSort = function(a, b, exclude)
        if not exclude or exclude ~= XEquipConfig.PriorSortType.Star then
            local aStar = XEquipManager.GetEquipStar(a.TemplateId)
            local bStar = XEquipManager.GetEquipStar(b.TemplateId)
            if aStar ~= bStar then
                return aStar > bStar
            end
        end

        if not exclude or exclude ~= XEquipConfig.PriorSortType.Breakthrough then
            if a.Breakthrough ~= b.Breakthrough then
                return a.Breakthrough > b.Breakthrough
            end
        end

        if not exclude or exclude ~= XEquipConfig.PriorSortType.Level then
            if a.Level ~= b.Level then
                return a.Level > b.Level
            end
        end

        return XEquipManager.GetEquipPriority(a.TemplateId) > XEquipManager.GetEquipPriority(b.TemplateId)
    end

    function XEquipManager.SortEquipIdListByPriorType(equipIdList, priorSortType)
        local sortFunc

        if priorSortType == XEquipConfig.PriorSortType.Level then
            sortFunc = function(aId, bId)
                local a = XEquipManager.GetEquip(aId)
                local b = XEquipManager.GetEquip(bId)
                if a.Level ~= b.Level then
                    return a.Level > b.Level
                end
                return DefaultSort(a, b, priorSortType)
            end
        elseif priorSortType == XEquipConfig.PriorSortType.Breakthrough then
            sortFunc = function(aId, bId)
                local a = XEquipManager.GetEquip(aId)
                local b = XEquipManager.GetEquip(bId)
                if a.Breakthrough ~= b.Breakthrough then
                    return a.Breakthrough > b.Breakthrough
                end
                return DefaultSort(a, b, priorSortType)
            end
        elseif priorSortType == XEquipConfig.PriorSortType.Star then
            sortFunc = function(aId, bId)
                local a = XEquipManager.GetEquip(aId)
                local b = XEquipManager.GetEquip(bId)
                local aStar = XEquipManager.GetEquipStar(a.TemplateId)
                local bStar = XEquipManager.GetEquipStar(b.TemplateId)
                if aStar ~= bStar then
                    return aStar > bStar
                end
                return DefaultSort(a, b, priorSortType)
            end
        elseif priorSortType == XEquipConfig.PriorSortType.Proceed then
            sortFunc = function(aId, bId)
                local a = XEquipManager.GetEquip(aId)
                local b = XEquipManager.GetEquip(bId)
                if a.CreateTime ~= b.CreateTime then
                    return a.CreateTime < b.CreateTime
                end
                return DefaultSort(a, b, priorSortType)
            end
        else
            sortFunc = function(aId, bId)
                local a = XEquipManager.GetEquip(aId)
                local b = XEquipManager.GetEquip(bId)
                return DefaultSort(a, b)
            end
        end

        tableSort(equipIdList, sortFunc)
    end

    function XEquipManager.ConstructAwarenessStarToSiteToSuitIdsDic()
        local starToSuitIdsDic = {}

        local doNotRepeatSuitIds = {}
        local equipIds = XEquipManager.GetNotWearingAwarenessIds()
        for _, equipId in pairs(equipIds) do
            local templateId = GetEquipTemplateId(equipId)

            local star = XEquipManager.GetEquipStar(templateId)
            doNotRepeatSuitIds[star] = doNotRepeatSuitIds[star] or {}

            local site = XEquipManager.GetEquipSite(equipId)
            doNotRepeatSuitIds[star][site] = doNotRepeatSuitIds[star][site] or {}
            doNotRepeatSuitIds[star].Total = doNotRepeatSuitIds[star].Total or {}

            local suitId = XEquipManager.GetSuitId(equipId)
            if suitId > 0 then
                doNotRepeatSuitIds[star][site][suitId] = true
                doNotRepeatSuitIds[star]["Total"][suitId] = true
            end
        end

        for star = 1, XEquipConfig.MAX_STAR_COUNT do
            starToSuitIdsDic[star] = {}

            for _, site in pairs(XEquipConfig.EquipSite.Awareness) do
                starToSuitIdsDic[star][site] = {}

                if doNotRepeatSuitIds[star] and doNotRepeatSuitIds[star][site] then
                    for suitId in pairs(doNotRepeatSuitIds[star][site]) do
                        tableInsert(starToSuitIdsDic[star][site], suitId)
                    end
                end
            end

            starToSuitIdsDic[star].Total = {}
            if doNotRepeatSuitIds[star] then
                for suitId in pairs(doNotRepeatSuitIds[star]["Total"]) do
                    tableInsert(starToSuitIdsDic[star]["Total"], suitId)
                end
            end
        end

        return starToSuitIdsDic
    end

    function XEquipManager.ConstructAwarenessSiteToEquipIdsDic()
        local siteToEquipIdsDic = {}

        for _, site in pairs(XEquipConfig.EquipSite.Awareness) do
            siteToEquipIdsDic[site] = {}
        end

        local equipIds = XEquipManager.GetNotWearingAwarenessIds()
        for _, equipId in pairs(equipIds) do
            local site = XEquipManager.GetEquipSite(equipId)
            tableInsert(siteToEquipIdsDic[site], equipId)
        end

        return siteToEquipIdsDic
    end

    function XEquipManager.ConstructAwarenessSuitIdToEquipIdsDic()
        local suitIdToEquipIdsDic = {}

        local equipIds = XEquipManager.GetNotWearingAwarenessIds()
        for _, equipId in pairs(equipIds) do
            local suitId = XEquipManager.GetSuitId(equipId)
            suitIdToEquipIdsDic[suitId] = suitIdToEquipIdsDic[suitId] or {}

            if suitId > 0 then
                local site = XEquipManager.GetEquipSite(equipId)
                suitIdToEquipIdsDic[suitId]["Total"] = suitIdToEquipIdsDic[suitId]["Total"] or {}
                suitIdToEquipIdsDic[suitId][site] = suitIdToEquipIdsDic[suitId][site] or {}

                tableInsert(suitIdToEquipIdsDic[suitId][site], equipId)
                tableInsert(suitIdToEquipIdsDic[suitId]["Total"], equipId)
            end
        end

        return suitIdToEquipIdsDic
    end

    function XEquipManager.TipEquipOperation(equipId, changeTxt, closeCb, setMask)
        local uiName = "UiEquipCanBreakthroughTip"
        if XLuaUiManager.IsUiShow(uiName) then
            XLuaUiManager.Remove(uiName)
        end
        XLuaUiManager.Open(uiName, equipId, changeTxt, closeCb, setMask)
    end
    -----------------------------------------Function End------------------------------------
    -----------------------------------------Protocol Begin------------------------------------
    function XEquipManager.PutOn(characterId, equipId, cb)
        if not characterId then
            XLog.Error("XEquipManager.PutOn error: characterId is nil")
            return
        end

        if not equipId then
            XLog.Error("XEquipManager.PutOn error: equipId is nil")
            return
        end

        if not XDataCenter.CharacterManager.IsOwnCharacter(characterId) then
            XUiManager.TipText("EquipPutOnNotChar")
            return
        end

        local equipSpecialCharacterId = XDataCenter.EquipManager.GetEquipSpecialCharacterId(equipId)
        if equipSpecialCharacterId and equipSpecialCharacterId ~= characterId then
            local char = XDataCenter.CharacterManager.GetCharacter(equipSpecialCharacterId)
            if char then
                local characterName = XCharacterConfigs.GetCharacterName(equipSpecialCharacterId)
                local gradeName = XCharacterConfigs.GetCharGradeName(equipSpecialCharacterId, char.Grade)
                XUiManager.TipMsg(CSXTextManagerGetText("EquipPutOnSpecialCharacterIdNotEqual", characterName, gradeName))
            end
            return
        end

        local characterEquipType = XCharacterConfigs.GetCharacterEquipType(characterId)
        if not XEquipManager.IsTypeEqual(equipId, characterEquipType) then
            XUiManager.TipText("EquipPutOnEquipTypeError")
            return
        end

        local req = { CharacterId = characterId, Site = XEquipManager.GetEquipSite(equipId), EquipId = equipId }
        XNetwork.Call("EquipPutOnRequest", req, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            XEquipManager.TipEquipOperation(nil, CSXTextManagerGetText("EquipPutOnSuc"))

            if cb then cb() end

            CsXGameEventManager.Instance:Notify(XEventId.EVENT_EQUIP_PUTON_NOTYFY, equipId)
            XEventManager.DispatchEvent(XEventId.EVENT_EQUIP_PUTON_NOTYFY, equipId)

            if XEquipManager.IsClassifyEqual(equipId, XEquipConfig.Classify.Weapon) then
                XEventManager.DispatchEvent(XEventId.EVENT_EQUIP_PUTON_WEAPON_NOTYFY, characterId, equipId)
            end
        end)
    end

    function XEquipManager.TakeOff(equipIds)
        if not equipIds or not next(equipIds) then
            XLog.Error("XEquipManager.TakeOff error: equipId is nil")
            return
        end

        for _, equipId in pairs(equipIds) do
            if not XEquipManager.IsWearing(equipId) then
                XUiManager.TipText("EquipTakeOffNotChar")
                return
            end
        end

        local req = { EquipIds = equipIds }
        XNetwork.Call("EquipTakeOffRequest", req, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            XEquipManager.TipEquipOperation(nil, CSXTextManagerGetText("EquipTakeOffSuc"))

            for _, equipId in pairs(equipIds) do
                XEventManager.DispatchEvent(XEventId.EVENT_EQUIP_TAKEOFF_NOTYFY, equipId)
            end
            CsXGameEventManager.Instance:Notify(XEventId.EVENT_EQUIPLIST_TAKEOFF_NOTYFY, equipIds)
        end)
    end

    function XEquipManager.SetLock(equipId, isLock)
        if not equipId then
            XLog.Error("XEquipManager.SetLock error: equipId is nil")
            return
        end

        local req = { EquipId = equipId, IsLock = isLock }
        XNetwork.Call("EquipUpdateLockRequest", req, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            CsXGameEventManager.Instance:Notify(XEventId.EVENT_EQUIP_LOCK_STATUS_CHANGE_NOTYFY, equipId, isLock)
            XEventManager.DispatchEvent(XEventId.EVENT_EQUIP_LOCK_STATUS_CHANGE_NOTYFY, equipId, isLock)
        end)
    end

    function XEquipManager.LevelUp(equipId, equipIdCheckList, callBackBeforeEvent)
        if not equipId then
            XLog.Error("XEquipManager.LevelUp error: equipId is nil")
            return
        end

        if not (equipIdCheckList and next(equipIdCheckList)) then
            XUiManager.TipText("EquipLevelUpItemEmpty")
            return
        end

        if XEquipManager.IsMaxLevel(equipId) then
            XUiManager.TipText("EquipLevelUpMaxLevel")
            return
        end

        if not XDataCenter.ItemManager.DoNotEnoughBuyAsset(XDataCenter.ItemManager.ItemId.Coin,
        XEquipManager.GetEatEquipsCostMoney(equipIdCheckList),
        1,
        function()
            XEquipManager.LevelUp(equipId, equipIdCheckList)
        end,
        "EquipBreakCoinNotEnough") then
            return
        end

        --为了方便检测，传入的table是用equipId做key的
        local useEquipIdList = {}
        local containPrecious = false
        local canNotAutoEatStar = XEquipConfig.CAN_NOT_AUTO_EAT_STAR
        for equipId in pairs(equipIdCheckList) do
            containPrecious = containPrecious or XEquipManager.GetEquipStar(GetEquipTemplateId(equipId)) >= canNotAutoEatStar
            table.insert(useEquipIdList, equipId)
        end

        local req = { EquipId = equipId, UseEquipIdList = useEquipIdList }
        local callFunc = function()
            XNetwork.Call("EquipLevelUpRequest", req, function(res)
                if res.Code ~= XCode.Success then
                    XUiManager.TipCode(res.Code)
                    return
                end

                local closeCb
                if XDataCenter.EquipManager.CanBreakThrough(equipId) then
                    closeCb = function()
                        XEquipManager.TipEquipOperation(equipId, nil, nil, true)
                    end
                end
                XEquipManager.TipEquipOperation(nil, CSXTextManagerGetText("EquipStrengthenSuc"), closeCb, true)

                for _, id in pairs(useEquipIdList) do
                    XEquipManager.DeleteEquip(id)
                end

                if callBackBeforeEvent then callBackBeforeEvent() end

                CsXGameEventManager.Instance:Notify(XEventId.EVENT_EQUIP_STRENGTHEN_NOTYFY, equipId)
            end)
        end

        if containPrecious then
            local title = CSXTextManagerGetText("EquipStrengthenPreciousTipTitle")
            local content = CSXTextManagerGetText("EquipStrengthenPreciousTipContent")
            XUiManager.DialogTip(title, content, XUiManager.DialogType.Normal, nil, callFunc)
        else
            callFunc()
        end
    end

    function XEquipManager.Breakthrough(equipId)
        if not equipId then
            XLog.Error("XEquipManager.Breakthrough error: equipId is nil")
            return
        end

        if XEquipManager.IsMaxBreakthrough(equipId) then
            XUiManager.TipText("EquipBreakMax")
            return
        end

        if not XEquipManager.IsReachBreakthroughLevel(equipId) then
            XUiManager.TipText("EquipBreakMinLevel")
            return
        end

        local consumeItems = XEquipManager.GetBreakthroughConsumeItems(equipId)
        if not XDataCenter.ItemManager.CheckItemsCount(consumeItems) then
            XUiManager.TipText("EquipBreakItemNotEnough")
            return
        end

        if not XDataCenter.ItemManager.DoNotEnoughBuyAsset(XEquipManager.GetBreakthroughUseItemId(equipId),
        XEquipManager.GetBreakthroughUseMoney(equipId),
        1,
        function()
            XEquipManager.Breakthrough(equipId)
        end,
        "EquipBreakCoinNotEnough") then
            return
        end

        local title = CSXTextManagerGetText("EquipBreakthroughConfirmTiltle")
        local content = CSXTextManagerGetText("EquipBreakthroughConfirmContent")
        XUiManager.DialogTip(title, content, XUiManager.DialogType.Normal, nil, function()
            XNetwork.Call("EquipBreakthroughRequest", { EquipId = equipId }, function(res)
                if res.Code ~= XCode.Success then
                    XUiManager.TipCode(res.Code)
                    return
                end

                CsXGameEventManager.Instance:Notify(XEventId.EVENT_EQUIP_BREAKTHROUGH_NOTYFY, equipId)
                XEventManager.DispatchEvent(XEventId.EVENT_EQUIP_BREAKTHROUGH_NOTYFY, equipId)
            end)
        end)
    end

    function XEquipManager.AwarenessTransform(suitId, site, usedIdList, cb)
        if not suitId then
            XLog.Error("XEquipManager.SetLock error: suitId is nil")
            return
        end

        local req = { SuitId = suitId, Site = site, UseIdList = usedIdList }
        XNetwork.Call("EquipTransformChipRequest", req, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            for _, id in pairs(usedIdList) do
                XEquipManager.DeleteEquip(id)
            end

            if cb then
                cb(res.EquipData)
            end
        end)
    end

    -- 服务端接口begin
    function XEquipManager.Resonance(equipId, slot, characterId, useEquipId, useItem)
        local useItemId = useItem and XEquipManager.GetResonanceConsumeItemId(equipId) or 0

        if XEquipManager.IsLock(useEquipId) then
            XUiManager.TipText("EquipIsLock")
            return
        end

        if characterId and not XDataCenter.CharacterManager.IsOwnCharacter(characterId) then
            XUiManager.TipText("EquipResonanceNotOwnCharacter")
            return
        end

        local callFunc = function()
            local req = { EquipId = equipId, Slot = slot, CharacterId = characterId, UseEquipId = useEquipId, UseItemId = useItemId }
            XNetwork.Call("EquipResonanceRequest", req, function(res)
                if res.Code ~= XCode.Success then
                    XUiManager.TipCode(res.Code)
                    return
                end

                local deleteEquip = useEquipId and XEquipManager.DeleteEquip(useEquipId)
                CsXGameEventManager.Instance:Notify(XEventId.EVENT_EQUIP_RESONANCE_NOTYFY, equipId, slot)
            end)
        end

        local containPrecious = useEquipId and XEquipManager.GetEquipStar(GetEquipTemplateId(useEquipId)) >= XEquipConfig.CAN_NOT_AUTO_EAT_STAR
        if containPrecious then
            local title = CSXTextManagerGetText("EquipResonancePreciousTipTitle")
            local content = CSXTextManagerGetText("EquipResonancePreciousTipContent")
            XUiManager.DialogTip(title, content, XUiManager.DialogType.Normal, nil, callFunc)
        else
            callFunc()
        end
    end

    function XEquipManager.ResonanceConfirm(equipId, slot, isUse)
        local req = { EquipId = equipId, Slot = slot, IsUse = isUse }
        XNetwork.Call("EquipResonanceConfirmRequest", req, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            CsXGameEventManager.Instance:Notify(XEventId.EVENT_EQUIP_RESONANCE_ACK_NOTYFY, equipId, slot)
        end)
    end

    function XEquipManager.EquipDecompose(equipIds, cb)
        local req = { EquipIds = equipIds }
        XNetwork.Call("EquipDecomposeRequest", req, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            local rewardGoodsList = res.RewardGoodsList
            for _, id in pairs(equipIds) do
                XEquipManager.DeleteEquip(id)
            end

            if cb then cb(rewardGoodsList) end
        end)
    end
    -----------------------------------------Protocol End------------------------------------
    -----------------------------------------Checker Begin-----------------------------------
    function XEquipManager.CheckMaxCount(equipType, count)
        if equipType == XEquipConfig.Classify.Weapon then
            local maxWeaponCount = XEquipConfig.GetMaxWeaponCount()
            if count and count > 0 then
                return XEquipManager.GetWeaponCount() + count > maxWeaponCount
            else
                return XEquipManager.GetWeaponCount() >= maxWeaponCount
            end
        elseif equipType == XEquipConfig.Classify.Awareness then
            local maxAwarenessCount = XEquipConfig.GetMaxAwarenessCount()
            if count and count > 0 then
                return XEquipManager.GetAwarenessCount() + count > maxAwarenessCount
            else
                return XEquipManager.GetAwarenessCount() >= maxAwarenessCount
            end
        end
    end

    function XEquipManager.CheckBagCount(count, equipType)
        if XEquipManager.CheckMaxCount(equipType, count) then
            local messageTips
            if equipType == XEquipConfig.Classify.Weapon then
                messageTips = CSXTextManagerGetText("WeaponBagFull")
            elseif equipType == XEquipConfig.Classify.Awareness then
                messageTips = CSXTextManagerGetText("ChipBagFull")
            end

            XUiManager.TipMsg(messageTips, XUiManager.UiTipType.Tip)
            return false
        end

        return true
    end

    function XEquipManager.IsWeapon(equipId)
        return XEquipManager.IsClassifyEqual(equipId, XEquipConfig.Classify.Weapon)
    end

    function XEquipManager.IsWeaponByTemplateId(templateId)
        return XEquipManager.IsClassifyEqualByTemplateId(templateId, XEquipConfig.Classify.Weapon)
    end

    function XEquipManager.IsAwareness(equipId)
        return XEquipManager.IsClassifyEqual(equipId, XEquipConfig.Classify.Awareness)
    end

    function XEquipManager.IsAwarenessByTemplateId(templateId)
        return XEquipManager.IsClassifyEqualByTemplateId(templateId, XEquipConfig.Classify.Awareness)
    end

    function XEquipManager.IsFood(equipId)
        local equipCfg = GetEquipCfg(equipId)
        return equipCfg.Type == XEquipConfig.EquipType.Food
    end

    function XEquipManager.IsClassifyEqual(equipId, classify)
        local templateId = GetEquipTemplateId(equipId)
        return XEquipManager.IsClassifyEqualByTemplateId(templateId, classify)
    end

    function XEquipManager.IsClassifyEqualByTemplateId(templateId, classify)
        local equipClassify = XEquipManager.GetEquipClassifyByTemplateId(templateId)
        return classify and equipClassify and classify == equipClassify
    end

    function XEquipManager.IsTypeEqual(equipId, equipType)
        local equipCfg = GetEquipCfg(equipId)
        return equipCfg.Type == XEquipConfig.EquipType.Universal or equipType and equipType == equipCfg.Type
    end

    function XEquipManager.IsWearing(equipId)
        if not equipId then return false end
        local equip = XEquipManager.GetEquip(equipId)
        return equip and equip.CharacterId and equip.CharacterId > 0
    end

    function XEquipManager.IsLock(equipId)
        if not equipId then return false end
        local equip = XEquipManager.GetEquip(equipId)
        return equip and equip.IsLock
    end

    function XEquipManager.IsMaxLevel(equipId)
        local equip = XEquipManager.GetEquip(equipId)
        return equip.Level >= XEquipManager.GetBreakthroughLevelLimit(equipId)
    end

    function XEquipManager.IsMaxBreakthrough(equipId)
        local equip = XEquipManager.GetEquip(equipId)
        local equipBorderCfg = GetEquipBorderCfg(equipId)
        return equip.Breakthrough >= equipBorderCfg.MaxBreakthrough
    end

    function XEquipManager.IsReachBreakthroughLevel(equipId)
        local equip = XEquipManager.GetEquip(equipId)
        return equip.Level >= XEquipManager.GetBreakthroughLevelLimit(equipId)
    end

    function XEquipManager.CanBreakThrough(equipId)
        return not XEquipManager.IsMaxBreakthrough(equipId) and XEquipManager.IsReachBreakthroughLevel(equipId)
    end

    function XEquipManager.CanResonance(equipId)
        local templateId = GetEquipTemplateId(equipId)
        local star = XEquipManager.GetEquipStar(templateId)
        return star >= XEquipConfig.MIN_RESONANCE_EQUIP_STAR_COUNT
    end

    function XEquipManager.CanResonanceByTemplateId(templateId)
        local resonanceSkillNum = XDataCenter.EquipManager.GetResonanceSkillNumByTemplateId(templateId)
        return resonanceSkillNum > 0
    end

    function XEquipManager.CanResonanceBindCharacter(equipId)
        local templateId = GetEquipTemplateId(equipId)
        local star = XEquipManager.GetEquipStar(templateId)
        return star >= XEquipConfig.GetMinResonanceBindStar()
    end

    function XEquipManager.CheckResonanceConsumeItemEnough(equipId)
        local consumeItemId = XEquipManager.GetResonanceConsumeItemId(equipId)
        local haveCount = XDataCenter.ItemManager.GetCount(consumeItemId)
        local consumeCount = XEquipManager.GetResonanceConsumeItemCount(equipId)
        return haveCount >= consumeCount
    end

    function XEquipManager.CheckEquipPosResonanced(equipId, pos)
        local equip = XEquipManager.GetEquip(equipId)
        return equip.ResonanceInfo and equip.ResonanceInfo[pos]
    end

    function XEquipManager.CheckEquipPosUnconfirmedResonanced(equipId, pos)
        local equip = XEquipManager.GetEquip(equipId)
        return equip.UnconfirmedResonanceInfo and equip.UnconfirmedResonanceInfo[pos]
    end

    function XEquipManager.CheckFirstGet(templateId)
        local needFirstShow = XEquipConfig.GetNeedFirstShow(templateId)
        if not needFirstShow or needFirstShow == 0 then return false end

        local firstGetTemplateIds = XSaveTool.GetData(XPlayer.Id .. EQUIP_FIRST_GET_KEY) or {}
        if firstGetTemplateIds[templateId] then
            return false
        else
            firstGetTemplateIds[templateId] = true
            XSaveTool.SaveData(XPlayer.Id .. EQUIP_FIRST_GET_KEY, firstGetTemplateIds)
            return true
        end
    end
    -----------------------------------------Checker End------------------------------------
    -----------------------------------------Getter Begin------------------------------------
    local function ConstructEquipAttrMap(attrs, isIncludeZero, remainDigitTwo)
        local equipAttrMap = {}

        for _, attrIndex in ipairs(XEquipConfig.AttrSortType) do
            local value = attrs and attrs[attrIndex]

            --默认保留两位小数
            if not remainDigitTwo then
                value = value and FixToInt(value)
            else
                value = value and tonumber(string.format("%0.2f", FixToDouble(value)))
            end

            if isIncludeZero or value and value > 0 then
                tableInsert(equipAttrMap, {
                    AttrIndex = attrIndex,
                    Name = XAttribManager.GetAttribNameByIndex(attrIndex),
                    Value = value or 0,
                })
            end
        end

        return equipAttrMap
    end

    function XEquipManager.GetEquipAttrMap(equipId, preLevel)
        local attrMap = {}

        if not equipId then
            return attrMap
        end
        local equip = XEquipManager.GetEquip(equipId)
        local attrs = XFightEquipManager.GetEquipAttribs(equip, preLevel)
        attrMap = ConstructEquipAttrMap(attrs)

        return attrMap
    end

    function XEquipManager.GetTemplateEquipAttrMap(templateId, preLevel)
        local equipData = {
            TemplateId = templateId,
            Breakthrough = 0,
            Level = 1,
        }
        local attrs = XFightEquipManager.GetEquipAttribs(equipData, preLevel)
        return ConstructEquipAttrMap(attrs)
    end

    function XEquipManager.GetWearingAwarenessMergeAttrMap(characterId)
        local equipList = {}

        for _, equipSite in pairs(XEquipConfig.EquipSite.Awareness) do
            local wearingEquipId = XEquipManager.GetWearingEquipIdBySite(characterId, equipSite)

            if wearingEquipId then
                local equipCfg = GetEquipCfg(wearingEquipId)
                local equip = XEquipManager.GetEquip(wearingEquipId)
                tableInsert(equipList, equip)
            end
        end

        local attrs = XFightEquipManager.GetEquipListAttribs(equipList)
        return ConstructEquipAttrMap(attrs, true)
    end

    function XEquipManager.GetBreakthroughPromotedAttrMap(equipId, preBreakthrough)
        local equipBreakthroughCfg

        if preBreakthrough then
            equipBreakthroughCfg = GetEquipBreakthroughCfgNext(equipId)
        else
            equipBreakthroughCfg = GetEquipBreakthroughCfg(equipId)
        end

        local map = XAttribManager.GetPromotedAttribs(equipBreakthroughCfg.AttribPromotedId)
        return ConstructEquipAttrMap(map, false, true)
    end

    function XEquipManager.GetCharacterWearingEquips(characterId)
        local equips = {}

        for k, v in pairs(Equips) do
            if characterId > 0 and v.CharacterId == characterId then
                tableInsert(equips, v)
            end
        end

        return equips
    end

    function XEquipManager.GetCharacterWearingWeaponId(characterId)
        for _, equip in pairs(Equips) do
            if equip.CharacterId == characterId and
            XEquipManager.IsWearing(equip.Id) and
            XEquipManager.IsClassifyEqual(equip.Id, XEquipConfig.Classify.Weapon) then
                return equip.Id
            end
        end
    end

    function XEquipManager.GetWearingEquipIdBySite(characterId, site)
        for _, equip in pairs(Equips) do
            if equip.CharacterId == characterId and XEquipManager.GetEquipSite(equip.Id) == site then
                return equip.Id
            end
        end
    end

    function XEquipManager.GetCharacterWearingAwarenessIds(characterId)
        local awarenessIds = {}
        local equips = XEquipManager.GetCharacterWearingEquips(characterId)
        for _, equip in pairs(equips) do
            if XEquipManager.IsClassifyEqual(equip.Id, XEquipConfig.Classify.Awareness) then
                tableInsert(awarenessIds, equip.Id)
            end
        end
        return awarenessIds
    end

    --desc: 获取符合当前角色使用类型的所有武器equipId
    function XEquipManager.GetCanUseWeaponIds(characterId)
        local weaponIds = {}
        local requireEquipType = XCharacterConfigs.GetCharacterEquipType(characterId)
        for k, v in pairs(Equips) do
            if XEquipManager.IsClassifyEqual(v.Id, XEquipConfig.Classify.Weapon) and XEquipManager.IsTypeEqual(v.Id, requireEquipType) then
                tableInsert(weaponIds, k)
            end
        end
        return weaponIds
    end

    --desc: 获取所有未穿戴中的意识equipId
    function XEquipManager.GetNotWearingAwarenessIds()
        local awarenessIds = {}
        for k, v in pairs(Equips) do
            if XEquipManager.IsClassifyEqual(v.Id, XEquipConfig.Classify.Awareness) and not XEquipManager.IsWearing(v.Id) then
                tableInsert(awarenessIds, k)
            end
        end
        return awarenessIds
    end

    function XEquipManager.GetAwarenessIds()
        local awarenessIds = {}
        for k, v in pairs(Equips) do
            if XEquipManager.IsClassifyEqual(v.Id, XEquipConfig.Classify.Awareness) then
                tableInsert(awarenessIds, k)
            end
        end
        return awarenessIds
    end

    local CanEatEquipSort = function(lEquipId, rEquipId)
        local ltemplateId = GetEquipTemplateId(lEquipId)
        local rtemplateId = GetEquipTemplateId(rEquipId)
        local lEquip = XEquipManager.GetEquip(lEquipId)
        local rEquip = XEquipManager.GetEquip(rEquipId)

        local lStar = XEquipManager.GetEquipStar(ltemplateId)
        local rStar = XEquipManager.GetEquipStar(rtemplateId)
        if lStar ~= rStar then
            return lStar < rStar
        end

        local lIsFood = XEquipManager.IsFood(lEquipId)
        local rIsFood = XEquipManager.IsFood(rEquipId)
        if lIsFood ~= rIsFood then
            return lIsFood
        end

        if lEquip.Breakthrough ~= rEquip.Breakthrough then
            return lEquip.Breakthrough < rEquip.Breakthrough
        end

        if lEquip.Level ~= rEquip.Level then
            return lEquip.Level < rEquip.Level
        end

        return XEquipManager.GetEquipPriority(ltemplateId) < XEquipManager.GetEquipPriority(rtemplateId)
    end

    function XEquipManager.GetCanEatWeaponIds(equipId)
        local weaponIds = {}
        for k, v in pairs(Equips) do
            if v.Id ~= equipId and XEquipManager.IsClassifyEqual(v.Id, XEquipConfig.Classify.Weapon)
            and not XEquipManager.IsWearing(v.Id) and not XEquipManager.IsLock(v.Id) then
                tableInsert(weaponIds, k)
            end
        end
        tableSort(weaponIds, CanEatEquipSort)
        return weaponIds
    end

    function XEquipManager.GetCanEatAwarenessIds(equipId)
        local awarenessIds = {}
        for k, v in pairs(Equips) do
            if v.Id ~= equipId and XEquipManager.IsClassifyEqual(v.Id, XEquipConfig.Classify.Awareness)
            and not XEquipManager.IsWearing(v.Id) and not XEquipManager.IsLock(v.Id) then
                tableInsert(awarenessIds, k)
            end
        end
        tableSort(awarenessIds, CanEatEquipSort)
        return awarenessIds
    end

    function XEquipManager.GetRecomendEatEquipIds(equipId)
        local equipIds = {}

        local equipClassify = XEquipManager.GetEquipClassify(equipId)
        local canNotAutoEatStar = XEquipConfig.CAN_NOT_AUTO_EAT_STAR
        for k, v in pairs(Equips) do
            local tmpEquipId = v.Id
            if tmpEquipId ~= equipId    --不能吃自己
            and XEquipManager.IsClassifyEqual(tmpEquipId, equipClassify)    --武器吃武器，意识吃意识
            and not XEquipManager.IsWearing(tmpEquipId)     --不能吃穿戴中
            and not XEquipManager.IsLock(tmpEquipId)      --不能吃上锁中
            and XEquipManager.GetEquipStar(v.TemplateId) < canNotAutoEatStar    --不自动吃大于该星级的装备
            and v.Breakthrough == 0     --不吃突破过的
            and v.Level == 1 and v.Exp == 0     --不吃强化过的
            and not v.ResonanceInfo and not v.UnconfirmedResonanceInfo  --不吃共鸣过的
            then
                tableInsert(equipIds, tmpEquipId)
            end
        end
        tableSort(equipIds, CanEatEquipSort)

        return equipIds
    end

    function XEquipManager.GetCanDecomposeWeaponIds()
        local weaponIds = {}
        for k, v in pairs(Equips) do
            if XEquipManager.IsClassifyEqual(v.Id, XEquipConfig.Classify.Weapon)
            and not XEquipManager.IsWearing(v.Id) and not XEquipManager.IsLock(v.Id) then
                tableInsert(weaponIds, k)
            end
        end
        return weaponIds
    end

    function XEquipManager.GetCanDecomposeAwarenessIdsBySuitId(suitId)
        local awarenessIds = {}

        local equipIds = XEquipManager.GetEquipIdsBySuitId(suitId)
        for _, v in pairs(equipIds) do
            if XEquipManager.IsClassifyEqual(v, XEquipConfig.Classify.Awareness)
            and not XEquipManager.IsWearing(v) and not XEquipManager.IsLock(v) then
                tableInsert(awarenessIds, v)
            end
        end

        return awarenessIds
    end

    function XEquipManager.GetEquipSite(equipId)
        local equipCfg = GetEquipCfg(equipId)
        return equipCfg.Site
    end

    function XEquipManager.GetEquipSiteByTemplateId(templateId)
        local equipCfg = XEquipConfig.GetEquipCfg(templateId)
        return equipCfg.Site
    end

    function XEquipManager.GetEquipWearingCharacterId(equipId)
        local equip = XEquipManager.GetEquip(equipId)
        return equip.CharacterId > 0 and equip.CharacterId
    end

    --专属角色Id
    function XEquipManager.GetEquipSpecialCharacterId(equipId)
        local equipCfg = GetEquipCfg(equipId)
        if equipCfg.CharacterId > 0 then
            return equipCfg.CharacterId
        end
    end

    function XEquipManager.GetEquipSpecialCharacterIdByTemplateId(templateId)
        local equipCfg = XEquipConfig.GetEquipCfg(templateId)
        if equipCfg.CharacterId > 0 then
            return equipCfg.CharacterId
        end
    end

    function XEquipManager.GetEquipClassify(equipId)
        local site = XEquipManager.GetEquipSite(equipId)
        if site == XEquipConfig.EquipSite.Weapon then
            return XEquipConfig.Classify.Weapon
        end

        return XEquipConfig.Classify.Awareness
    end

    function XEquipManager.GetEquipClassifyByTemplateId(templateId)
        if not XEquipConfig.CheckTemplateIdIsEquip(templateId) then return end
        local equipSite = XEquipManager.GetEquipSiteByTemplateId(templateId)
        return WeaponTypeCheckDic[equipSite] or AwarenessTypeCheckDic[equipSite]
    end

    function XEquipManager.GetSuitId(equipId)
        local equipCfg = GetEquipCfg(equipId)
        return equipCfg.SuitId
    end

    function XEquipManager.GetSuitIdByTemplateId(templateId)
        local equipCfg = XEquipConfig.GetEquipCfg(templateId)
        return equipCfg.SuitId
    end

    function XEquipManager.GetEquipTemplateIdsBySuitId(suitId)
        local equipTemplateIds = XEquipConfig.GetEquipTemplateIdsBySuitId(suitId)
        return equipTemplateIds
    end

    function XEquipManager.GetWeaponTypeIconPath(equipId)
        local templateId = GetEquipTemplateId(equipId)
        if XEquipManager.IsClassifyEqualByTemplateId(templateId, XEquipConfig.Classify.Weapon) then
            return XEquipConfig.GetWeaponTypeIconPath(templateId)
        end
    end

    function XEquipManager.GetEquipBreakThroughIcon(equipId)
        local equip = XEquipManager.GetEquip(equipId)
        return XEquipConfig.GetEquipBreakThroughIcon(equip.Breakthrough)
    end

    function XEquipManager.GetEquipBreakThroughSmallIcon(equipId)
        local equip = XEquipManager.GetEquip(equipId)
        if equip.Breakthrough == 0 then return end
        return XEquipConfig.GetEquipBreakThroughSmallIcon(equip.Breakthrough)
    end

    function XEquipManager.GetEquipBreakThroughBigIcon(equipId, preBreakthrough)
        local equip = XEquipManager.GetEquip(equipId)
        local breakthrough = equip.Breakthrough
        if preBreakthrough then
            breakthrough = breakthrough + preBreakthrough
        end
        return XEquipConfig.GetEquipBreakThroughBigIcon(breakthrough)
    end

    function XEquipManager.GetEquipIdsBySuitId(suitId, site)
        if suitId == XEquipConfig.DEFAULT_SUIT_ID then
            return XEquipManager.GetAwarenessIds()
        end

        local equipIds = {}

        for _, equip in pairs(Equips) do
            local equipId = equip.Id
            if suitId == XEquipManager.GetSuitId(equipId) then
                if type(site) ~= "number" or XEquipManager.GetEquipSite(equipId) == site then
                    tableInsert(equipIds, equipId)
                end
            end
        end

        return equipIds
    end

    function XEquipManager.GetSuitName(suitId)
        if suitId == XEquipConfig.DEFAULT_SUIT_ID then return "" end
        local suitCfg = XEquipConfig.GetEquipSuitCfg(suitId)
        return suitCfg.Name
    end

    function XEquipManager.GetSuitDescription(suitId)
        if suitId == XEquipConfig.DEFAULT_SUIT_ID then return "" end
        local suitCfg = XEquipConfig.GetEquipSuitCfg(suitId)
        return suitCfg.Description
    end

    function XEquipManager.GetSuitSites(templateId)
        local suitId = XEquipManager.GetSuitIdByTemplateId(templateId)
        return XEquipConfig.GetSuitSites(suitId)
    end

    function XEquipManager.GetSuitStar(suitId)
        if suitId == XEquipConfig.DEFAULT_SUIT_ID then return 0 end
        local templateId = GetSuitPresentEquipTemplateId(suitId)
        return XEquipManager.GetEquipStar(templateId)
    end

    function XEquipManager.GetSuitQualityIcon(suitId)
        if suitId == XEquipConfig.DEFAULT_SUIT_ID then return end
        local templateId = GetSuitPresentEquipTemplateId(suitId)
        return XEquipManager.GetEquipBgPath(templateId)
    end

    function XEquipManager.GetSuitMergeActiveSkillDesInfoList(characterId)
        local skillDesInfoList = {}

        local suitIdSet = {}
        local wearingAwarenessIds = XEquipManager.GetCharacterWearingAwarenessIds(characterId)
        for _, equipId in pairs(wearingAwarenessIds) do
            local suitId = XEquipManager.GetSuitId(equipId)
            if suitId > 0 then
                local count = suitIdSet[suitId]
                suitIdSet[suitId] = count and count + 1 or 1
            end
        end

        for suitId, count in pairs(suitIdSet) do
            local activeskillDesList = XEquipManager.GetSuitActiveSkillDesList(suitId, count)
            for _, info in pairs(activeskillDesList) do
                if info.IsActive then
                    tableInsert(skillDesInfoList, info)
                end
            end
        end

        return skillDesInfoList
    end

    function XEquipManager.GetActiveSuitEquipsCount(characterId, suitId)
        local count = 0
        local siteCheckDic = {}

        local wearingAwarenessIds = XEquipManager.GetCharacterWearingAwarenessIds(characterId)
        for _, equipId in pairs(wearingAwarenessIds) do
            local wearingSuitId = XEquipManager.GetSuitId(equipId)
            if suitId > 0 and suitId == wearingSuitId then
                count = count + 1
                local site = XEquipManager.GetEquipSite(equipId)
                siteCheckDic[site] = true
            end
        end

        return count, siteCheckDic
    end

    function XEquipManager.GetSuitActiveSkillDesList(suitId, count)
        local activeskillDesList = {}

        local skillDesList = XEquipManager.GetSuitSkillDesList(suitId)
        if skillDesList[2] then
            tableInsert(activeskillDesList, { SkillDes = skillDesList[2] or "", PosDes = CSXTextManagerGetText("EquipSuitSkillPrefix2"), IsActive = count and count >= 2 })
        end
        if skillDesList[4] then
            tableInsert(activeskillDesList, { SkillDes = skillDesList[4] or "", PosDes = CSXTextManagerGetText("EquipSuitSkillPrefix4"), IsActive = count and count >= 4 })
        end
        if skillDesList[6] then
            tableInsert(activeskillDesList, { SkillDes = skillDesList[6] or "", PosDes = CSXTextManagerGetText("EquipSuitSkillPrefix6"), IsActive = count and count >= 6 })
        end

        return activeskillDesList
    end

    function XEquipManager.GetSuitSkillDesList(suitId)
        if not suitId or suitId == 0 or suitId == XEquipConfig.DEFAULT_SUIT_ID then
            return {}
        end
        local suitCfg = XEquipConfig.GetEquipSuitCfg(suitId)
        return suitCfg and suitCfg.SkillDescription or {}
    end

    function XEquipManager.GetEquipCountInSuit(suitId, site)
        return #XEquipManager.GetEquipIdsBySuitId(suitId, site)
    end

    function XEquipManager.GetMaxSuitCount()
        return XEquipConfig.GetMaxSuitCount()
    end

    function XEquipManager.GetWeaponModelCfgByEquipId(equipId, uiName)
        local templateId = GetEquipTemplateId(equipId)
        local breakthroughTimes = XEquipManager.GetBreakthroughTimes(equipId)
        return XEquipManager.GetWeaponModelCfg(templateId, uiName, breakthroughTimes)
    end

    function XEquipManager.GetBreakthroughTimes(equipId)
        local breakthroughTimes = 0

        if CheckEquipExist(equipId) then
            local equip = XEquipManager.GetEquip(equipId)
            breakthroughTimes = equip.Breakthrough
        end

        return breakthroughTimes
    end

    --desc: 获取装备模型配置列表
    function XEquipManager.GetWeaponModelCfg(templateId, uiName, breakthroughTimes)
        local modelCfg = {}

        if not templateId then
            XLog.Error("XEquipManager.GetWeaponModelCfg error: templateId is nil")
            return modelCfg
        end

        local template = XEquipConfig.GetEquipResCfg(templateId, breakthroughTimes)
        modelCfg.ModelName = XEquipConfig.GetEquipModelName(template.ModelTransId[1])
        modelCfg.TransfromConfig = XEquipConfig.GetEquipModelTransformCfg(templateId, uiName)

        return modelCfg
    end

    --desc: 获取武器模型名字列表
    function XEquipManager.GetWeaponModelNameList(templateId)
        local nameList = {}

        local template = XEquipConfig.GetEquipResCfg(templateId)
        for _, id in pairs(template.ModelTransId) do
            local modelName = XEquipConfig.GetEquipModelName(id)
            tableInsert(nameList, modelName)
        end

        return nameList
    end

    --desc: 通过角色id获取武器模型名字列表
    function XEquipManager.GetWeaponModelNameListByCharacterId(characterId)
        local templateId
        if not XDataCenter.CharacterManager.IsOwnCharacter(characterId) then
            templateId = XCharacterConfigs.GetCharacterDefaultEquipId(characterId)
        else
            local equipId = XEquipManager.GetCharacterWearingWeaponId(characterId)

            if equipId then
                templateId = GetEquipTemplateId(equipId)
            else
                templateId = XCharacterConfigs.GetCharacterDefaultEquipId(characterId)
            end
        end

        return XEquipManager.GetWeaponModelNameList(templateId)
    end

    function XEquipManager.GetWeaponModelNameListByEquips(equips)
        for _, equip in ipairs(equips) do
            if XEquipManager.IsClassifyEqualByTemplateId(equip.TemplateId, XEquipConfig.Classify.Weapon) then
                return XEquipManager.GetWeaponModelNameList(equip.TemplateId)
            end
        end
    end

    function XEquipManager.GetEquipCount(templateId)
        local count = 0
        for _, v in pairs(Equips) do
            if v.TemplateId == templateId then
                count = count + 1
            end
        end
        return count
    end

    function XEquipManager.GetFirstEquip(templateId)
        for _, v in pairs(Equips) do
            if v.TemplateId == templateId then
                return v
            end
        end
    end

    --desc: 获取装备大图标路径
    function XEquipManager.GetEquipBigIconPath(templateId)
        if not templateId then
            XLog.Error("XEquipManager.GetEquipBigIconPath error: templateId is nil")
            return
        end

        local equipResCfg = XEquipConfig.GetEquipResCfg(templateId)
        return equipResCfg.BigIconPath
    end

    --desc: 获取装备图标路径
    function XEquipManager.GetEquipIconPath(templateId)
        if not templateId then
            XLog.Error("XEquipManager.GetEquipIconPath error: templateId is nil")
            return
        end

        local equipResCfg = XEquipConfig.GetEquipResCfg(templateId)
        return equipResCfg.IconPath
    end

    --desc: 获取装备在背包中显示图标路径
    function XEquipManager.GetEquipIconBagPath(templateId, breakthroughTimes)
        local equipResCfg = XEquipConfig.GetEquipResCfg(templateId, breakthroughTimes)
        return equipResCfg.IconPath
    end

    --desc: 获取套装在背包中显示图标路径
    function XEquipManager.GetSuitIconBagPath(suitId)
        local suitCfg = XEquipConfig.GetEquipSuitCfg(suitId)
        return suitCfg.IconPath
    end

    --desc: 获取套装在背包中显示大图标路径
    function XEquipManager.GetSuitBigIconBagPath(suitId)
        local suitCfg = XEquipConfig.GetEquipSuitCfg(suitId)
        if not suitCfg then
            XLog.Error("XEquipConfig.GetEquipSuitCfg() Error : suitCfg = nil suitId = " .. suitId)
            return
        end
        return suitCfg.BigIconPath
    end

    --desc: 获取意识立绘路径
    function XEquipManager.GetEquipLiHuiPath(templateId, breakthroughTimes)
        if not templateId then
            XLog.Error("XEquipManager.GetEquipLiHuiPath error: templateId is nil")
            return
        end

        local equipResCfg = XEquipConfig.GetEquipResCfg(templateId, breakthroughTimes)
        return equipResCfg.LiHuiPath
    end

    function XEquipManager.GetEquipPainterName(templateId, breakthroughTimes)
        local equipResCfg = XEquipConfig.GetEquipResCfg(templateId, breakthroughTimes)
        return equipResCfg.PainterName
    end

    function XEquipManager.GetEquipBgPath(templateId)
        return XEquipConfig.GetEquipBgPath(templateId)
    end

    function XEquipManager.GetEquipQualityPath(templateId)
        return XEquipConfig.GetEquipQualityPath(templateId)
    end

    function XEquipManager.GetEquipQuality(templateId)
        local equipCfg = XEquipConfig.GetEquipCfg(templateId)
        return equipCfg.Quality
    end

    function XEquipManager.GetEquipPriority(templateId)
        local equipCfg = XEquipConfig.GetEquipCfg(templateId)
        return equipCfg.Priority
    end

    function XEquipManager.GetEquipStar(templateId)
        local equipCfg = XEquipConfig.GetEquipCfg(templateId)
        return equipCfg.Star
    end

    function XEquipManager.GetEquipName(templateId)
        local equipCfg = XEquipConfig.GetEquipCfg(templateId)
        return equipCfg.Name or ""
    end

    function XEquipManager.GetEquipDescription(templateId)
        local equipCfg = XEquipConfig.GetEquipCfg(templateId)
        return equipCfg.Description or ""
    end

    function XEquipManager.GetOriginWeaponSkillInfo(templateId)
        local equipCfg = XEquipConfig.GetEquipCfg(templateId)

        local weaponSkillId = equipCfg.WeaponSkillId
        if not weaponSkillId then
            XLog.Error("XEquipManager.GetWeaponSkillInfo error: can not find equipCfg.WeaponSkillId, templateId is " .. templateId)
            return
        end

        return XEquipConfig.GetWeaponSkillInfo(weaponSkillId)
    end

    function XEquipManager.GetEquipMinLevel(templateId)
        local equipBorderCfg = XEquipConfig.GetEquipBorderCfg(templateId)
        return equipBorderCfg.MinLevel
    end

    function XEquipManager.GetEquipMaxLevel(templateId)
        local equipBorderCfg = XEquipConfig.GetEquipBorderCfg(templateId)
        return equipBorderCfg.MaxLevel
    end

    function XEquipManager.GetEquipMinBreakthrough(templateId)
        local equipBorderCfg = XEquipConfig.GetEquipBorderCfg(templateId)
        return equipBorderCfg.MinBreakthrough
    end

    function XEquipManager.GetEquipMaxBreakthrough(templateId)
        local equipBorderCfg = XEquipConfig.GetEquipBorderCfg(templateId)
        return equipBorderCfg.MaxBreakthrough
    end

    function XEquipManager.GetNextLevelExp(templateId, breakthrough, level)
        local levelUpCfg = XEquipConfig.GetLevelUpCfg(templateId, breakthrough, level)
        return levelUpCfg.Exp
    end

    function XEquipManager.GetEquipAddExp(equipId)
        local exp = 0

        local equip = XEquipManager.GetEquip(equipId)
        local levelUpCfg = XEquipConfig.GetLevelUpCfg(equip.TemplateId, equip.Breakthrough, equip.Level)
        local offerExp = XEquipManager.GetEquipOfferExp(equipId)

        --- 获得经验 = 装备已培养经验 * 继承比例 + 突破提供的经验
        exp = equip.Exp + levelUpCfg.AllExp
        exp = exp * XEquipConfig.GetEquipExpInheritPercent() / 100
        exp = exp + offerExp

        return exp
    end

    function XEquipManager.GetEquipPreLevelAndExp(equipId, costEquipIds)
        local equip = XEquipManager.GetEquip(equipId)
        local limitLevel = XEquipManager.GetBreakthroughLevelLimit(equipId)
        local preLevel = equip.Level
        local preExp = equip.Exp
        local totalExp = 0

        for costEquipId in pairs(costEquipIds) do
            local addExp = XEquipManager.GetEquipAddExp(costEquipId)
            preExp = preExp + addExp
            totalExp = totalExp + addExp

            while true do
                local nextExp = XEquipManager.GetNextLevelExp(equip.TemplateId, equip.Breakthrough, preLevel)
                if preExp < nextExp then
                    break
                end

                preExp = preExp - nextExp
                preLevel = preLevel + 1

                --超出需要吃的装备个数范围检测
                if preLevel >= limitLevel then
                    preLevel = limitLevel
                    return preLevel, totalExp
                end
            end
        end

        return preLevel, totalExp
    end

    function XEquipManager.GetEatEquipsCostMoney(equipIdKeys)
        local costMoney = 0

        for equipId in pairs(equipIdKeys) do
            local equipCfg = GetEquipCfg(equipId)
            costMoney = costMoney + XEquipConfig.GetEatEquipCostMoney(equipCfg.Site, equipCfg.Star)
        end

        return costMoney
    end

    function XEquipManager.GetBreakthroughLevelLimitByTemplateId(templateId)
        local equipBreakthroughCfg = XEquipConfig.GetEquipBreakthroughCfg(templateId, 0)
        return equipBreakthroughCfg.LevelLimit
    end

    function XEquipManager.GetBreakthroughLevelLimit(equipId)
        local equipBreakthroughCfg = GetEquipBreakthroughCfg(equipId)
        return equipBreakthroughCfg.LevelLimit
    end

    function XEquipManager.GetBreakthroughLevelLimitNext(equipId)
        local equipBreakthroughCfg = GetEquipBreakthroughCfgNext(equipId)
        return equipBreakthroughCfg.LevelLimit
    end

    function XEquipManager.GetBreakthroughCondition(equipId)
        local equipBreakthroughCfg = GetEquipBreakthroughCfg(equipId)
        return equipBreakthroughCfg.ConditionId
    end

    function XEquipManager.GetBreakthroughUseMoney(equipId)
        local equipBreakthroughCfg = GetEquipBreakthroughCfg(equipId)
        return equipBreakthroughCfg.UseMoney
    end

    function XEquipManager.GetBreakthroughUseItemId(equipId)
        local equipBreakthroughCfg = GetEquipBreakthroughCfg(equipId)
        return equipBreakthroughCfg.UseItemId
    end

    function XEquipManager.GetBreakthroughConsumeItems(equipId)
        local consumeItems = {}

        local equipBreakthroughCfg = GetEquipBreakthroughCfg(equipId)
        for i = 1, #equipBreakthroughCfg.ItemId do
            tableInsert(consumeItems, {
                Id = equipBreakthroughCfg.ItemId[i],
                Count = equipBreakthroughCfg.ItemCount[i],
            })
        end

        return consumeItems
    end

    function XEquipManager.GetEquipOfferExp(equipId)
        local equipBreakthroughCfg = GetEquipBreakthroughCfg(equipId)
        return equipBreakthroughCfg.Exp
    end

    local function GetResonanceSkillInfoByType(type, templateId)
        local skillInfo

        if type == XEquipConfig.EquipResonanceType.Attrib then
            skillInfo = XAttribManager.TryGetAttribGroupTemplate(templateId)
        elseif type == XEquipConfig.EquipResonanceType.CharacterSkill then
            skillInfo = XCharacterConfigs.GetCharacterSkillPoolSkillInfo(templateId)
        elseif type == XEquipConfig.EquipResonanceType.WeaponSkill then
            skillInfo = XEquipConfig.GetWeaponSkillInfo(templateId)
        end

        return skillInfo
    end

    function XEquipManager.GetResonanceSkillNum(equipId)
        local templateId = GetEquipTemplateId(equipId)
        return XEquipManager.GetResonanceSkillNumByTemplateId(templateId)
    end

    function XEquipManager.GetResonanceSkillNumByTemplateId(templateId)
        local count = 0

        local equipResonanceCfg = XEquipConfig.GetEquipResonanceCfg(templateId)
        if not equipResonanceCfg then return count end

        for pos = 1, XEquipConfig.MAX_RESONANCE_SKILL_COUNT do
            if equipResonanceCfg.WeaponSkillPoolId and equipResonanceCfg.WeaponSkillPoolId[pos] and equipResonanceCfg.WeaponSkillPoolId[pos] > 0 then
                count = count + 1
            elseif equipResonanceCfg.AttribPoolId and equipResonanceCfg.AttribPoolId[pos] and equipResonanceCfg.AttribPoolId[pos] > 0 then
                count = count + 1
            elseif equipResonanceCfg.CharacterSkillPoolId and equipResonanceCfg.CharacterSkillPoolId[pos] and equipResonanceCfg.CharacterSkillPoolId[pos] > 0 then
                count = count + 1
            end
        end

        return count
    end

    function XEquipManager.GetResonancePreSkillInfoList(equipId, characterId, slot)
        local preSkillInfoList = {}

        local templateId = GetEquipTemplateId(equipId)
        local equipResonanceCfg = XEquipConfig.GetEquipResonanceCfg(templateId)
        if XEquipManager.IsClassifyEqual(equipId, XEquipConfig.Classify.Weapon) then
            local poolId = equipResonanceCfg.WeaponSkillPoolId[slot]
            local skillIds = XEquipConfig.GetWeaponSkillPoolSkillIds(poolId, characterId)

            for _, skillId in pairs(skillIds) do
                local skillInfo = GetResonanceSkillInfoByType(XEquipConfig.EquipResonanceType.WeaponSkill, skillId)
                tableInsert(preSkillInfoList, skillInfo)
            end
        else
            local skillPoolId = equipResonanceCfg.CharacterSkillPoolId[slot]
            local skillInfos = XCharacterConfigs.GetCharacterSkillPoolSkillInfos(skillPoolId, characterId)

            local attrPoolId = equipResonanceCfg.AttribPoolId[slot]
            local attrInfos = XAttribConfigs.GetAttribGroupTemplateByPoolId(attrPoolId)

            preSkillInfoList = XTool.MergeArray(skillInfos, attrInfos)
        end

        return preSkillInfoList
    end

    function XEquipManager.GetResonanceSkillInfo(equipId, pos)
        local skillInfo = {}

        local equip = XEquipManager.GetEquip(equipId)
        if equip.ResonanceInfo and equip.ResonanceInfo[pos] then
            skillInfo = GetResonanceSkillInfoByType(equip.ResonanceInfo[pos].Type, equip.ResonanceInfo[pos].TemplateId)
        end

        return skillInfo
    end

    function XEquipManager.GetUnconfirmedResonanceSkillInfo(equipId, pos)
        local skillInfo = {}

        local equip = XEquipManager.GetEquip(equipId)
        if equip.UnconfirmedResonanceInfo and equip.UnconfirmedResonanceInfo[pos] then
            skillInfo = GetResonanceSkillInfoByType(equip.UnconfirmedResonanceInfo[pos].Type, equip.UnconfirmedResonanceInfo[pos].TemplateId)
        end

        return skillInfo
    end

    function XEquipManager.GetResonanceBindCharacterId(equipId, pos)
        local equip = XEquipManager.GetEquip(equipId)
        return equip.ResonanceInfo and equip.ResonanceInfo[pos] and equip.ResonanceInfo[pos].CharacterId
    end

    function XEquipManager.GetUnconfirmedResonanceBindCharacterId(equipId, pos)
        local equip = XEquipManager.GetEquip(equipId)
        return equip.UnconfirmedResonanceInfo and equip.UnconfirmedResonanceInfo[pos] and equip.UnconfirmedResonanceInfo[pos].CharacterId
    end

    function XEquipManager.GetResonanceConsumeItemId(equipId)
        local templateId = GetEquipTemplateId(equipId)
        local equipResonanceItemCfg = XEquipConfig.GetEquipResonanceConsumeItemCfg(templateId)
        return equipResonanceItemCfg.ItemId[1]
    end

    function XEquipManager.GetResonanceConsumeItemCount(equipId)
        local count = 0

        local templateId = GetEquipTemplateId(equipId)
        local equipResonanceItemCfg = XEquipConfig.GetEquipResonanceConsumeItemCfg(templateId)
        count = equipResonanceItemCfg.ItemCount[1]

        return count
    end

    function XEquipManager.GetResonanceCanEatEquipIds(equipId)
        local equipIds = {}

        if XEquipManager.IsClassifyEqual(equipId, XEquipConfig.Classify.Weapon) then
            --武器消耗同星级
            local resonanceEquip = XEquipManager.GetEquip(equipId)
            local star = XEquipManager.GetEquipStar(resonanceEquip.TemplateId)

            for _, equip in pairs(Equips) do
                if equip.Id ~= equipId and star == XEquipManager.GetEquipStar(equip.TemplateId) and XEquipManager.IsClassifyEqual(equip.Id, XEquipConfig.Classify.Weapon)
                and not XEquipManager.IsWearing(equip.Id) and not XEquipManager.IsLock(equip.Id) then
                    tableInsert(equipIds, equip.Id)
                end
            end
        else
            --意识消耗同套装
            local resonanceSuitId = XEquipManager.GetSuitId(equipId)

            for _, equip in pairs(Equips) do
                if equip.Id ~= equipId and resonanceSuitId == XEquipManager.GetSuitId(equip.Id) and XEquipManager.IsClassifyEqual(equip.Id, XEquipConfig.Classify.Awareness)
                and not XEquipManager.IsWearing(equip.Id) and not XEquipManager.IsLock(equip.Id) then
                    tableInsert(equipIds, equip.Id)
                end
            end
        end

        --加个默认排序
        XEquipManager.SortEquipIdListByPriorType(equipIds)

        return equipIds
    end

    function XEquipManager.GetCanResonanceCharacterList(equipId)
        local canResonanceCharacterList = {}

        local wearingCharacterId = XEquipManager.GetEquipWearingCharacterId(equipId)
        if wearingCharacterId then
            tableInsert(canResonanceCharacterList, XDataCenter.CharacterManager.GetCharacter(wearingCharacterId))
        end

        local ownCharacterList = XDataCenter.CharacterManager.GetOwnCharacterList()
        for _, character in pairs(ownCharacterList) do
            local characterId = character.Id
            if characterId ~= wearingCharacterId then
                local characterEquipType = XCharacterConfigs.GetCharacterEquipType(characterId)
                if XEquipManager.IsTypeEqual(equipId, characterEquipType) then
                    tableInsert(canResonanceCharacterList, character)
                end
            end
        end

        return canResonanceCharacterList
    end

    --获取某TemplateID的装备的数量
    function XEquipManager.GetEquipCountByTemplateID(templateId)
        local count = 0
        for k, v in pairs(Equips) do
            if v.TemplateId == templateId then
                count = count + 1
            end
        end
        return count
    end

    local function GetWeaponSkillAbility(equip, characterId)
        local template = XEquipConfig.GetEquipCfg(equip.TemplateId)
        if not template then
            return
        end

        if template.Site ~= XEquipConfig.EquipSite.Weapon then
            XLog.Error("GetWeaponSkillAbility error: equip is not a weapon, site is " .. template.site)
            return
        end

        local ability = 0

        if template.WeaponSkillId > 0 then
            local weaponAbility = XEquipConfig.GetWeaponSkillAbility(template.WeaponSkillId)
            if not weaponAbility then
                XLog.Error("GetWeaponSkillAbility error: weaponAbility is nil")
                return
            end

            ability = ability + weaponAbility
        end

        if equip.ResonanceInfo then
            for _, resonanceData in pairs(equip.ResonanceInfo) do
                if resonanceData.Type == XEquipConfig.EquipResonanceType.WeaponSkill then
                    if resonanceData.CharacterId == 0 or resonanceData.CharacterId == characterId then
                        local weaponAbility = XEquipConfig.GetWeaponSkillAbility(resonanceData.TemplateId)
                        if not weaponAbility then
                            XLog.Error("GetWeaponSkillAbility error: resonance weaponAbility is nil")
                            return
                        end

                        ability = ability + weaponAbility
                    end
                end
            end
        end

        return ability
    end

    local function GetEquipSkillAbility(equipList, characterId)
        local suitCount = {}
        local ability = 0

        for _, equip in pairs(equipList) do
            local template = XEquipConfig.GetEquipCfg(equip.TemplateId)
            if not template then
                return
            end

            if template.Site == XEquipConfig.EquipSite.Weapon then
                local weaponAbility = GetWeaponSkillAbility(equip, characterId)
                if not weaponAbility then
                    return
                end

                ability = ability + weaponAbility
            end

            if template.SuitId > 0 then
                if not suitCount[template.SuitId] then
                    suitCount[template.SuitId] = 1
                else
                    suitCount[template.SuitId] = suitCount[template.SuitId] + 1
                end
            end
        end

        for suitId, count in pairs(suitCount) do
            local template = XEquipConfig.GetEquipSuitCfg(suitId)
            if not template then
                return
            end

            for i = 1, mathMin(count, XEquipConfig.MAX_SUIT_COUNT) do
                local effectId = template.SkillEffect[i]
                if effectId and effectId > 0 then
                    local effectTemplate = XEquipConfig.GetEquipSuitEffectCfg(effectId)
                    if not effectTemplate then
                        return
                    end

                    ability = ability + effectTemplate.Ability
                end
            end
        end

        return ability
    end

    function XEquipManager.GetEquipSkillAbility(characterId)
        local equipList = XEquipManager.GetCharacterWearingEquips(characterId)
        if not equipList or #equipList <= 0 then
            return 0
        end

        return GetEquipSkillAbility(equipList, characterId)
    end

    --- 计算装备战斗力（不包含角色共鸣相关）
    function XEquipManager.GetEquipAbility(characterId)
        local equipList = XEquipManager.GetCharacterWearingEquips(characterId)
        if not equipList or #equipList <= 0 then
            return 0
        end

        local skillAbility = GetEquipSkillAbility(equipList, 0)
        local equipListAttribs = XFightEquipManager.GetEquipListAttribs(equipList)
        local equipListAbility = XAttribManager.GetAttribAbility(equipListAttribs)

        return equipListAbility + skillAbility
    end

    function XEquipManager.GetEquipSkipIds(equipId)
        local site = XEquipManager.GetEquipSite(equipId)
        local template = XEquipConfig.GetEquipSkipIdTemplate(site)
        return template.SkipIdParams
    end

    -----------------------------------------Getter End------------------------------------
    XEquipManager.GetEquipTemplateId = GetEquipTemplateId

    return XEquipManager
end

XRpc.NotifyEquipDataList = function(data)
    XDataCenter.EquipManager.NotifyEquipDataList(data)
end