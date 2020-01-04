XFashionManagerCreator = function()

    local pairs = pairs

    local table = table
    local tableInsert = table.insert
    local tableSort = table.sort

    local XFashionManager = {}


    XFashionManager.FashionStatus = {
        -- 未拥有
        UnOwned = 0,
        -- 未解锁
        Lock = 1,
        -- 已解锁
        UnLock = 2,
        -- 已穿戴
        Dressed = 3
    }

    local TABLE_FASHION_PATH = "Share/Fashion/Fashion.tab"
    local TABLE_FASHION_QUALITY_PATH = "Share/Fashion/FashionQuality.tab"

    local METHOD_NAME = {
        Use = "FashionUseRequest",
        Unlock = "FashionUnLockRequest",
    }

    local FashionTemplates = {}      -- 时装配置
    local FashionQuality = {}        -- 时装品质相关信息

    local OwnFashionStatus = {}           -- 已拥有的时装
    local CharFashions = {}     -- 角色对应时装列表


    --==============================--
    --desc: 获取时装配置
    --@id: 时装Id
    --@return: 时装配置
    --==============================--
    function XFashionManager.GetFashionTemplate(id)
        local tab = FashionTemplates[id]
        if tab == nil then
            XLog.Error("XFashionManager.GetFashionTemplate error: can not found table, id = " .. id)
        end
        return tab
    end

    --==============================--
    --desc: 是否拥有时装
    --@id: 时装id
    --@return 拥有为true，否则false
    --==============================--
    local function CheckOwnFashion(id)
        return OwnFashionStatus[id] ~= nil
    end

    --==============================--
    --desc: 时装是否已穿戴
    --@id: 时装id
    --@return 穿戴为true，否则false
    --==============================--
    local function IsFashionDressed(id)
        local template = XFashionManager.GetFashionTemplate(id)

        if not template then
            return false
        end

        local char = XDataCenter.CharacterManager.GetCharacter(template.CharacterId)
        if not char then
            return false
        end

        return char.FashionId == id
    end

    --==============================--
    --desc: 获取时装状态
    --@id: 时装id
    --@return 状态
    --==============================--
    function XFashionManager.GetFashionStatus(id)
        local status = OwnFashionStatus[id]

        if status == nil then
            return XFashionManager.FashionStatus.UnOwned
        end

        if IsFashionDressed(id) then
            return XFashionManager.FashionStatus.Dressed
        end

        return status and XFashionManager.FashionStatus.Lock or XFashionManager.FashionStatus.UnLock
    end

    function XFashionManager.Init()
        FashionTemplates = XTableManager.ReadByIntKey(TABLE_FASHION_PATH, XTable.XTableFashion, "Id")
        FashionQuality = XTableManager.ReadByIntKey(TABLE_FASHION_QUALITY_PATH, XTable.XTableFashionQuality, "Id")

        for id, template in pairs(FashionTemplates) do
            local list = CharFashions[template.CharacterId]
            if not list then
                list = {}
            end

            tableInsert(list, id)
            CharFashions[template.CharacterId] = list
        end
    end

    function XFashionManager.InitFashions(fashions)
        local fashionDic = {}
        for _, data in ipairs(fashions) do
            fashionDic[data.Id] = data.IsLock
        end

        OwnFashionStatus = fashionDic
    end

    --==============================--
    --desc: 检查角色是否有时装
    --@id: 角色Id
    --@return: 是否有时装
    --==============================--
    function XFashionManager.IsCharacterHasFashions(charId)
        local fashions = CharFashions[charId]
        return fashions and #fashions > 0
    end

    --==============================--
    --desc: 检查角色是否有时装
    --@id: 时装Id
    --@return: 是否有时装
    --==============================--
    function XFashionManager.CheckHasFashion(id)
        return OwnFashionStatus[id] ~= nil 
    end

    --==============================--
    --desc: 服务器获得时装推送
    --protoData：时装数据
    --==============================--
    function XFashionManager.NotifyFashionDict(data)
        local fashions = data.FashionList
        if not fashions then
            return
        end

        for _, data in ipairs(fashions) do
            OwnFashionStatus[data.Id] = data.IsLock
        end
    end

    --==============================--
    --desc: 获取时装图标
    --@fashionId: 时装id
    --@return 时装对应的人物角色小图像图标
    --==============================--
    function XFashionManager.GetFashionSmallHeadIcon(fashionId)
        local tab = FashionTemplates[fashionId]
        if tab == nil then
            XLog.Error("XFashionManager.GetFashionIcon error: can not found table, id = " .. fashionId)
            return
        end
        return tab.SmallHeadIcon
    end

    --==============================--
    --desc: 获取时装图标
    --@fashionId: 时装id
    --@return 时装对应的人物角色小图像图标【三阶解放版】
    --==============================--
    function XFashionManager.GetFashionSmallHeadIconLiberation(fashionId)
        local tab = FashionTemplates[fashionId]
        if tab == nil then
            XLog.Error("XFashionManager.GetFashionIcon error: can not found table, id = " .. fashionId)
            return
        end
        return tab.SmallHeadIconLiberation
    end

    --==============================--
    --desc: 获取时装图标
    --@fashionId: 时装id
    --@return 时装对应的人物角色大图像图标
    --==============================--
    function XFashionManager.GetFashionBigHeadIcon(fashionId)
        local tab = FashionTemplates[fashionId]
        if tab == nil then
            XLog.Error("XFashionManager.GetFashionIcon error: can not found table, id = " .. fashionId)
            return
        end
        return tab.BigHeadIcon
    end

    --==============================--
    --desc: 获取时装图标
    --@fashionId: 时装id
    --@return 时装对应的人物角色大图像图标
    --==============================--
    function XFashionManager.GetFashionBigHeadIconLiberation(fashionId)
        local tab = FashionTemplates[fashionId]
        if tab == nil then
            XLog.Error("XFashionManager.GetFashionIcon error: can not found table, id = " .. fashionId)
            return
        end
        return tab.BigHeadIconLiberation
    end

    --==============================--
    --desc: 获取时装图标
    --@fashionId: 时装id
    --@return 时装对应的人物角色小圆形图像图标
    --==============================--
    function XFashionManager.GetFashionRoundnessHeadIcon(fashionId)
        local tab = FashionTemplates[fashionId]
        if tab == nil then
            XLog.Error("XFashionManager.GetFashionIcon error: can not found table, id = " .. fashionId)
            return
        end
        return tab.RoundnessHeadIcon
    end

    --==============================--
    --desc: 获取时装图标
    --@fashionId: 时装id
    --@return 时装对应的人物角色大圆形图像图标
    --==============================--
    function XFashionManager.GetFashionBigRoundnessHeadIcon(fashionId)
        local tab = FashionTemplates[fashionId]
        if tab == nil then
            XLog.Error("XFashionManager.GetFashionIcon error: can not found table, id = " .. fashionId)
            return
        end
        return tab.BigRoundnessHeadIcon
    end

    --==============================--
    --desc: 获取时装图标
    --@fashionId: 时装id
    --@return 时装对应的人物角色圆形图像图标(非物品使用)
    --==============================--
    function XFashionManager.GetFashionRoundnessNotItemHeadIcon(fashionId)
        local tab = FashionTemplates[fashionId]
        if tab == nil then
            XLog.Error("XFashionManager.GetFashionIcon error: can not found table, id = " .. fashionId)
            return
        end
        return tab.RoundnessNotItemHeadIcon
    end

    --==============================--
    --desc: 获取时装图标
    --@fashionId: 时装id
    --@return 时装对应的人物角色圆形图像图标(非物品使用)【三阶解放版】
    --==============================--
    function XFashionManager.GetFashionRoundnessNotItemHeadIconLiberation(fashionId)
        local tab = FashionTemplates[fashionId]
        if tab == nil then
            XLog.Error("XFashionManager.GetFashionIcon error: can not found table, id = " .. fashionId)
            return
        end
        return tab.RoundnessNotItemHeadIconLiberation
    end

    --==============================--
    --desc: 获取时装图标
    --@fashionId: 时装id
    --@return 时装对应的人物角色半身像
    --==============================--
    function XFashionManager.GetFashionHalfBodyImage(fashionId)
        local tab = FashionTemplates[fashionId]
        if tab == nil then
            XLog.Error("XFashionManager.GetFashionIcon error: can not found table, id = " .. fashionId)
            return
        end
        return tab.HalfBodyImage
    end

    --==============================--
    --desc: 获取时装图标
    --@fashionId: 时装id
    --@return 时装对应的人物角色全身像
    --==============================--
    function XFashionManager.GetRoleCharacterBigImage(fashionId)
        local tab = FashionTemplates[fashionId]
        if tab == nil then
            XLog.Error("XFashionManager.GetFashionIcon error: can not found table, id = " .. fashionId)
            return
        end
        return tab.RoleCharacterBigImage
    end

    --==============================--
    --desc: 获取时装图标
    --@id: 时装id
    --@return 时装图标
    --==============================--
    function XFashionManager.GetFashionIcon(id)
        local tab = FashionTemplates[id]
        if tab == nil then
            XLog.Error("XFashionManager.GetFashionIcon error: can not found table, id = " .. id)
        end
        return tab.Icon
    end

    --==============================--
    --desc: 获取ResourcesId
    --@id: 时装id
    --@return ResourcesId
    --==============================--
    function XFashionManager.GetResourcesId(id)
        local tab = FashionTemplates[id]
        if tab == nil then
            XLog.Error("XFashionManager.GetFashionIcon error: can not found table, id = " .. id)
        end
        return tab.ResourcesId
    end

    --==============================--
    --desc: 获取时装大图标
    --@id: 时装id
    --@return 时装大图标
    --==============================--
    function XFashionManager.GetFashionBigIcon(id)
        local tab = FashionTemplates[id]
        if tab == nil then
            XLog.Error("XFashionManager.GetFashionBigIcon error: can not found table, id = " .. id)
        end
        return tab.BigIcon
    end

    --==============================--
    --desc: 拿取时装名字
    --@id: 时装Id
    --@return: 时装名字
    --==============================--
    function XFashionManager.GetFashionName(id)
        local tab = FashionTemplates[id]
        if tab == nil then
            XLog.Error("XFashionManager.GetFashionName error: can not found table, id = " .. id)
        end
        return tab.Name
    end

    --==============================--
    --desc: 拿取时装品质
    --@id: 时装Id
    --@return: 时装品质
    --==============================--
    function XFashionManager.GetFashionQuality(id)
        local tab = FashionTemplates[id]
        if tab == nil then
            XLog.Error("XFashionManager.GetFashionQuality error: can not found table, id = " .. id)
        end
        return tab.Quality
    end

    --==============================--
    --desc: 拿取时装简介1
    --@id: 时装Id
    --@return: 时装简介
    --==============================--
    function XFashionManager.GetFashionDesc(id)
        local tab = FashionTemplates[id]
        if tab == nil then
            XLog.Error("XFashionManager.GetFashionDesc error: can not found table, id = " .. id)
        end
        return tab.Description
    end
    
    --==============================--
    --desc: 拿取时装简介2
    --@id: 时装Id
    --@return: 时装简介
    --==============================--
    function XFashionManager.GetFashionWorldDescription(id)
        local tab = FashionTemplates[id]
        if tab == nil then
            XLog.Error("XFashionManager.GetFashionDesc error: can not found table, id = " .. id)
        end
        return tab.WorldDescription
    end


    --==============================--
    --desc: 拿取时装跳转列表
    --@id: 时装Id
    --@return: 时装列表
    --==============================--
    function XFashionManager.GetFashionSkipIdParams(id)
        local tab = FashionTemplates[id]
        if tab == nil then
            XLog.Error("XFashionManager.GetFashionSkipIdParams error: can not found table, id = " .. id)
        end
        return tab.SkipIdParams
    end


    local SortStatusPriority = {
        [XFashionManager.FashionStatus.UnOwned] = 1,
        [XFashionManager.FashionStatus.UnLock] = 2,
        [XFashionManager.FashionStatus.Lock] = 3,
        [XFashionManager.FashionStatus.Dressed] = 4
    }

    --==============================--
    --desc: 通过角色ID获取角色所有时装信息
    --@charId: 角色ID
    --@return: 时装List
    --==============================--
    function XFashionManager.GetFashionByCharId(charId)
        local fashions = CharFashions[charId]
        if not fashions then
            XLog.Error("XFashionManager.GetFashionByCharId error: can not found character fashion, character Id is " .. charId)
            return
        end

        local fashionList = {}
        for _, id in pairs(fashions) do
            tableInsert(fashionList, id)
        end

        tableSort(fashionList, function(a, b)
            local status1, status2 = XFashionManager.GetFashionStatus(a), XFashionManager.GetFashionStatus(b)

            if status1 ~= status2 then
                return SortStatusPriority[status1] > SortStatusPriority[status2]
            end

            return XFashionManager.GetFashionPriority(a) > XFashionManager.GetFashionPriority(b)
        end)

        return fashionList
    end

    --==============================--
    --desc: 通过时装品质获取描述Icon
    --@quality: 时装品质
    --@return: 描述Icon
    --==============================--
    function XFashionManager.GetDescIcon(quality)
        local config = FashionQuality[quality]
        if not config then
            XLog.Error("XFashionManager.GetDescIcon error: can not found config, id is " .. quality)
            return
        end

        return config.IconDesc
    end

    --==============================--
    --desc: 通过时装品质获取通用Icon
    --@quality: 时装品质
    --@return: 通用Icon
    --==============================--
    function XFashionManager.GetBgIcon(quality)
        local config = FashionQuality[quality]
        if not config then
            XLog.Error("XFashionManager.GetBgIcon error: can not found config, id is " .. quality)
            return
        end

        return config.IconBg
    end

    --==============================--
    --desc: 通过角色ID获取角色当前使用时装信息
    --@charId: 角色ID
    --@return: 当前使用的时装信息
    --==============================--
    function XFashionManager.GetFashionResouceIdByCharId(charId)
        local char = XDataCenter.CharacterManager.GetCharacter(charId)
        if not char then
            return
        end

        local template = XFashionManager.GetFashionTemplate(char.FashionId)
        if template then
            return template.ResourcesId
        end
    end

    --==============================--
    --desc: 通过XFightNpcData返回资源
    --@fightNpcData: 角色数据
    --@return: 角色模型名称
    --==============================--
    function XFashionManager.GetCharacterModelName(fightNpcData)
        if not fightNpcData then
            XLog.Error("XFashionManager.GetCharacterModelName error: can not found fightNpcData")
            return
        end

        local fashionId = fightNpcData.Character.FashionId
        if fashionId <= 0 then
            local charId = fightNpcData.Character.Id
            fashionId = XCharacterConfigs.GetCharacterTemplate(charId).DefaultNpcFashtionId
        end
        local resId = XFashionManager.GetFashionTemplate(fashionId).ResourcesId

        return XDataCenter.CharacterManager.GetCharResModel(resId)
    end

    --==============================--
    --desc: 通过fashionId拿取头像信息
    --@fightNpcData: fashionId
    --@return: 头像Icon
    --==============================--
    function XFashionManager.GetCharacterModelIcon(fashionId, charId)
        if not fashionId then
            XLog.Error("XFashionManager.GetCharacterModelIcon error: can not found fashionId")
            return
        end

        if fashionId <= 0 then
            fashionId = XCharacterConfigs.GetCharacterTemplate(charId).DefaultNpcFashtionId
        end

        local resId = XFashionManager.GetFashionTemplate(fashionId).ResourcesId
        return XDataCenter.CharacterManager.GetCharResIcon(resId)
    end

    --==============================--
    --desc: 获取时装显示优先级
    --@templateId: 时装配置表id
    --@return 显示优先级
    --==============================--
    function XFashionManager.GetFashionPriority(templateId)
        local tab = FashionTemplates[templateId]
        if tab == nil then
            XLog.Error("XFashionManager.GetFashionPriority error: can not found table, id = " .. templateId)
        end
        return tab.Priority
    end

    -- service config begin --
    function XFashionManager.UseFashion(id, cb)
        local temp = XFashionManager.GetFashionTemplate(id)
        if temp and not XDataCenter.CharacterManager.IsOwnCharacter(temp.CharacterId) then
            XUiManager.TipText("CharacterLock")
            return
        end

        XNetwork.Call(METHOD_NAME.Use, { FashionId = id}, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            if cb then cb() end
        end)
    end

    function XFashionManager.UnlockFashion(id, cb)
        local status = XFashionManager.GetFashionStatus(id)
        if status == XFashionManager.FashionStatus.UnOwned then
            XUiManager.TipCode(XCode.FashionIsUnOwned)
            return
        end

        if status ~= XFashionManager.FashionStatus.Lock then
            XUiManager.TipCode(XCode.FashionIsUnLock)
            return
        end

        XNetwork.Call(METHOD_NAME.Unlock, { FashionId = id }, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
            end

            if cb then cb() end
        end)
    end
    -- service config end --

    XFashionManager.Init()
    return XFashionManager
end

XRpc.FashionSyncNotify = function(data)
    XDataCenter.FashionManager.NotifyFashionDict(data)
end