XFurnitureConfigs = XFurnitureConfigs or {}

--家具交互点被使用情况
XFurnitureInteractUsedType = {
    None = 1, --空，未被占用
    Character = 2, --被构造体占用
    Block = 4, --交互点被阻挡，无法使用
}

XFurnitureConfigs.FURNITURE_CATEGORY_ALL_ID = 0
XFurnitureConfigs.MAX_FURNITURE_ATTR_LEVEL = 5
XFurnitureConfigs.FURNITURE_SUIT_CATEGORY_ALL_ID = 1

XFurnitureConfigs.GainType = {
    Create = 1,
    Refit = 2
}

XFurnitureConfigs.XFurnitureAdditionType = {
    Mood = 0,
    Vitality = 1,
    AttrA = 2,
    AttrB = 3,
    AttrC = 4,
    AttrAPercent = 5,
    AttrBPercent = 6,
    AttrCPercent = 7,
    AttrTotal = 8,
    AttrTotalPercent = 9,
    Count = 10
}

-- 家具摆放类型
XFurniturePlaceType = {
    Ground = 1, -- 地板
    Wall = 2, -- 墙
    Ceiling = 3, -- 天花板
    OnGround = 4, -- 摆放在地板上
    OnWall = 5, -- 摆放在墙上
}

-- 家具类型
XFurnitureConfigs.HomeSurfaceBaseType = {
    Ground = 25001, --地板
    Wall = 25002, --墙
    Ceiling = 25003, --天花板
}

-- 家具Attr类型
XFurnitureConfigs.AttrType = {
    AttrA = 1, --美观(红)
    AttrB = 2, --舒适(黄)
    AttrC = 3, --实用(蓝)
    AttrAll = 4, --总值
}

-- 家具操作状态
XFurnitureConfigs.FURNITURE_STATE = {
    RECYCLE = 1, -- 回收状态
    DETAILS = 2, -- 查看详情状态
    SELECT = 3, -- 选择家具或者图纸状态
}

--- 家具摆放类型
XFurnitureConfigs.HomeLocateType = {
    Replace = 0, --直接替换
    LocateGround = 1, --摆放在地板上
    LocateWall = 2, --悬挂墙上
}

--- 增减
XFurnitureConfigs.FurnitureOperate = {
    Delete = 0,     --增加
    Add = 1,        --减少
}

--- 家具点击播放动画类型
XFurnitureConfigs.FurnitureAnimationType = {
    None = 0,     -- 不播放
    Once = 1,     -- 点击播放一次
    Repeat = 2,   -- 连续播放动画
}

--- 家具额外属性
XFurnitureConfigs.FurnitureAdditionType = {
    Mood = 0,
    Vitality = 1,
    AttrTotal = 2,
    AttrTotalPercent = 3,
    Count = 4,
}

XFurnitureConfigs.HomePlatType = {
    Ground = 0, -- 地板
    Wall = 1, -- 墙
}

--排序优先级选项
XFurnitureConfigs.PriorSortType = {
    All = 0,    -- 全选
    Unuse = 1,  -- 未使用
    Use = 2,    -- 使用中
}

-- 属性分级颜色
XFurnitureConfigs.FurnitureAttrColor = {
    [1] = CS.XTextManager.GetText("FurnitureColorC"),
    [2] = CS.XTextManager.GetText("FurnitureColorC"),
    [3] = CS.XTextManager.GetText("FurnitureColorB"),
    [4] = CS.XTextManager.GetText("FurnitureColorA"),
    [5] = CS.XTextManager.GetText("FurnitureColorS"),
}


-- 属性标签分级颜色
XFurnitureConfigs.FurnitureAttrTagColor = {
    [1] = "#62DE4AFF",
    [2] = "#62DE4AFF",
    [3] = "#34AFF8FF",
    [4] = "#D07EFFFF",
    [5] = "#FFB400FF",
}



XFurnitureConfigs.FurnitureAttrLevel = {
    [1] = CS.XTextManager.GetText("FurnitureQualityC"),
    [2] = CS.XTextManager.GetText("FurnitureQualityC"),
    [3] = CS.XTextManager.GetText("FurnitureQualityB"),
    [4] = CS.XTextManager.GetText("FurnitureQualityA"),
    [5] = CS.XTextManager.GetText("FurnitureQualityS"),
}

local CLIENT_FURNITURE_SUIT = "Client/Hostel/FurnitureSuit.tab"
local CLIENT_FURNITURE_VIEWANGLE = "Client/Hostel/FurnitureViewAngle.tab"
local CLIENT_FURNITURE_COLOUR = "Client/Hostel/FurnitureColour.tab"
local TABLE_DORM_FURNITURE_TYPE_PATH = "Client/Dormitory/DormFurnitureType.tab"
local TABLE_DORM_FURNITURE_TAG_TYPE_PATH = "Client/Dormitory/DormFurnitureTagType.tab"
local TABLE_DORM_FURNITURE_SINGLE_LEVEL_PATH = "Client/Dormitory/FurnitureSingleAttrLevel.tab"

local TABLE_DORM_FURNITURE_ANIMATION_PATH = "Client/Dormitory/DormFurnitureAnimation.tab"

local SHARE_FURNITURE = "Share/Dormitory/Furniture/Furniture.tab"
local SHARE_FURNITURE_LEVEL = "Share/Dormitory/Furniture/FurnitureLevel.tab"
local SHARE_FURNITURE_TYPE = "Share/Dormitory/Furniture/FurnitureType.tab"
local SHARE_FURNITURE_ADDITIONALATTR = "Share/Dormitory/Furniture/FurnitureAdditionalAttr.tab"
local SHARE_FURNITURE_FURNITURE_CREATEATTR = "Share/Dormitory/Furniture/FurnitureCreateAttr.tab"
local SHARE_FURNITURE_FURNITURE_BASE_ATTR = "Share/Dormitory/Furniture/FurnitureBaseAttr.tab"
local SHARE_FURNITURE_FURNITURE_EXTRA_ATTR = "Share/Dormitory/Furniture/FurnitureExtraAttr.tab"
local SHARE_FURNTIURE_REWARD = "Share/Dormitory/Furniture/FurnitureReward.tab"

local FurnitureBaseTemplates = {}
local FurnitureSuitTemplates = {}
local FurnitureViewAngle = {}
local FurnitureColour = {}

local FurnitureTemplates = {}
local FurnitureLevelTemplates = {}
local FurnitureTypeTemplates = {}
local FurnitureTagTypeTemplates = {}
local FurnitureAdditionalAttr = {}
local FurnitureAdditionalAttrRandom = {}
local FurnitureCreateAttr = {}
local FurnitureBaseAttrTemplate = {}
local FurnitureExtraAttrTemplate = {}
local FurnitureTypeList = {}
local FurnitureTypeGroupList = {}
local FurnitureRewardTemplate = {}

local FurnitureSingleAttrLevelTemplate  = {}
local FurnitureSingleAttrLevelIndex  = {}

local FurnitureToDrawingMap = {}--家具改装所需的图纸
local DrawingToFurnitureMap = {}--图纸能改装的家具
local DrawingPicMap = {}
local DormFurnitureTypeTemplate = {} -- 家具喜好度类型配置表
local DormFurnitureTypeAttsDic = {} -- 家具属性
local DormFurnitureAnimation = {} -- 家具动画配置表

local function InitFurnitureTypeConfig()
    local map = {}
    for _, cfg in pairs(FurnitureTypeTemplates) do
        local newId = cfg.MajorType * 100 + cfg.MinorType

        local data = map[newId]
        if not data then
            data = {}
            data.MinorType = cfg.MinorType
            data.MinorName = cfg.MinorName
            data.CategoryMap = {}
            map[newId] = data
        end

        local category = {}
        category.Category = cfg.Category
        category.CategoryName = cfg.CategoryName

        data.CategoryMap[category.Category] = category
    end

    for _, data in pairs(map) do
        data.CategoryList = {}

        for _, v in pairs(data.CategoryMap) do
            table.insert(data.CategoryList, v)
        end

        data.CategoryMap = nil
        if #data.CategoryList < 2 then
            data.CategoryList = {}
        else
            local category = {}
            category.Category = 0
            category.CategoryName = CS.XTextManager.GetText("FurnitureWholeText")
            table.insert(data.CategoryList, 1, category)
        end

        table.insert(FurnitureTypeList, data)
    end
end

local function InitFurnitureTypeGroupConfig()
    local map = {}
    for _, cfg in pairs(FurnitureTypeTemplates) do
        local newId = cfg.MajorType * 100 + cfg.MinorType

        local data = map[newId]
        if not data then
            data = {}
            data.MinorType = cfg.MinorType
            data.MinorName = cfg.MinorName
            data.CategoryMap = {}
            map[newId] = data
        end

        local category = {}
        category.Category = cfg.Category
        category.CategoryName = cfg.CategoryName

        data.CategoryMap[category.Category] = category
    end

    for _, data in pairs(map) do
        data.CategoryList = {}

        for _, v in pairs(data.CategoryMap) do
            table.insert(data.CategoryList, v)
        end

        data.CategoryMap = nil
        if #data.CategoryList > 1 then
            local category = {}
            category.Category = 0
            category.CategoryName = CS.XTextManager.GetText("FurnitureWholeText")
            table.insert(data.CategoryList, 1, category)
        end

        table.insert(FurnitureTypeGroupList, data)
    end
end

local function InitFurnitureLevelConfigs(configs)
    for _, config in pairs(configs) do
        if not FurnitureLevelTemplates[config.FurnitureType] then
            FurnitureLevelTemplates[config.FurnitureType] = {}
        end
        table.insert(FurnitureLevelTemplates[config.FurnitureType], config)
    end
end


local function InitFurnitureSingleAttrLevelConfigs(configs)
    for _, config in pairs(configs) do
        if not FurnitureSingleAttrLevelIndex[config.FurnitureType] then
            FurnitureSingleAttrLevelIndex[config.FurnitureType] = {}
        end
        table.insert(FurnitureSingleAttrLevelIndex[config.FurnitureType], config)
    end
end

function XFurnitureConfigs.Init()
    FurnitureSuitTemplates = XTableManager.ReadByIntKey(CLIENT_FURNITURE_SUIT, XTable.XTableFurnitureSuit, "Id")
    FurnitureViewAngle = XTableManager.ReadByIntKey(CLIENT_FURNITURE_VIEWANGLE, XTable.XTableFurnitureViewAngle, "MinorType")
    FurnitureColour = XTableManager.ReadByIntKey(CLIENT_FURNITURE_COLOUR, XTable.XTableFurntiureColour, "Id")
    FurnitureTemplates = XTableManager.ReadByIntKey(SHARE_FURNITURE, XTable.XTableFurniture, "Id")
    FurnitureTypeTemplates = XTableManager.ReadByIntKey(SHARE_FURNITURE_TYPE, XTable.XTableFurnitureType, "Id")

    FurnitureTagTypeTemplates = XTableManager.ReadByIntKey(TABLE_DORM_FURNITURE_TAG_TYPE_PATH, XTable.XTableDormFurnitureTagType, "Id")
    FurnitureSingleAttrLevelTemplate = XTableManager.ReadByIntKey(TABLE_DORM_FURNITURE_SINGLE_LEVEL_PATH, XTable.XTableFurnitureSingleAttrLevel, "Id")

    FurnitureAdditionalAttr = XTableManager.ReadByIntKey(SHARE_FURNITURE_ADDITIONALATTR, XTable.XTableFurnitureAdditionalAttr, "AttributeId")
    FurnitureCreateAttr = XTableManager.ReadByIntKey(SHARE_FURNITURE_FURNITURE_CREATEATTR, XTable.XTableFurnitureCreateAttr, "Id")
    FurnitureBaseAttrTemplate = XTableManager.ReadByIntKey(SHARE_FURNITURE_FURNITURE_BASE_ATTR, XTable.XTableFurnitureBaseAttr, "Id")
    FurnitureExtraAttrTemplate = XTableManager.ReadByIntKey(SHARE_FURNITURE_FURNITURE_EXTRA_ATTR, XTable.XTableFurnitureExtraAttr, "Id")
    FurnitureRewardTemplate = XTableManager.ReadByIntKey(SHARE_FURNTIURE_REWARD, XTable.XTableFurnitureReward, "Id")
    DormFurnitureTypeTemplate = XTableManager.ReadByIntKey(TABLE_DORM_FURNITURE_TYPE_PATH, XTable.XTableDormFurnitureType, "Id")
    DormFurnitureAnimation = XTableManager.ReadByIntKey(TABLE_DORM_FURNITURE_ANIMATION_PATH, XTable.XTableDormFunitureAnimation, "Id")
    local furnitureLevelTemplates = XTableManager.ReadByIntKey(SHARE_FURNITURE_LEVEL, XTable.XTableFurnitureLevel, "Id")

    InitFurnitureTypeConfig()
    InitFurnitureTypeGroupConfig()
    InitFurnitureLevelConfigs(furnitureLevelTemplates)
    InitFurnitureSingleAttrLevelConfigs(FurnitureSingleAttrLevelTemplate)

    -- 改装功能家具映射
    for k, v in pairs(FurnitureTemplates) do
        if v.PicId ~= nil and v.PicId > 0 then
            FurnitureToDrawingMap[k] = v.PicId
            DrawingToFurnitureMap[v.PicId] = k

            if DrawingPicMap[v.TypeId] == nil then
                DrawingPicMap[v.TypeId] = {}
            end
            table.insert(DrawingPicMap[v.TypeId], {
                FurnitureId = v.Id,
                TypeId = v.TypeId,
                PicId = v.PicId,
                GainType = v.GainType
            })
        end
    end
end

-- 获取家具额外属性加成配置分数
function XFurnitureConfigs.GetAdditionalAddScore(id)
    local currentAttr = FurnitureAdditionalAttr[id]

    if not currentAttr then
        XLog.Error("XFurnitureConfigs.GetAdditionalAddScore not found by id : " .. tostring(id))
        return 0
    end

    return currentAttr.AddScore or 0
end

-- 获取家具额外属性加成配置表
function XFurnitureConfigs.GetAdditonAttrConfigById(id)
    local t = FurnitureAdditionalAttr[id]
    if not t then
        XLog.Error("XFurnitureConfigs.GetFurnitureAdditonAttrConfigById error:id is not found, id = " .. tostring(id))
        return nil
    end

    return t
end

-- 获取喜好度类型配置表
function XFurnitureConfigs.GetDormFurnitureType(id)
    local t = DormFurnitureTypeTemplate[id]
    if not t then
        XLog.Error("XFurnitureConfigs.GetDormFurnitureType error:id is not found, id = " .. tostring(id))
        return nil
    end

    return t
end

-- 获取家具动画配置表
function XFurnitureConfigs.GetDormFurnitureAnimation(id)
    local t = DormFurnitureAnimation[id]
    if not t then
        XLog.Error("XFurnitureConfigs.GetDormFurnitureAnimation error:id is not found, id = " .. tostring(id))
        return nil
    end

    return t
end

-- 获取家具动画类型
function XFurnitureConfigs.GetOnceAnimationType(furnitureId)
    local furniture = XFurnitureConfigs.GetFurnitureBaseTemplatesById(furnitureId)
    if not furniture then
        return nil
    end

    local t = XFurnitureConfigs.GetDormFurnitureAnimation(furniture.AnimationId)
    if not t then
        return nil
    end

    return t.ClickType
end

-- 根据构造体ID获取家具交互动画名
function XFurnitureConfigs.GetDormFurnitureAnimationByCharId(furnitureId, charId)
    local furniture = XFurnitureConfigs.GetFurnitureBaseTemplatesById(furnitureId)
    if not furniture then
        return nil
    end

    local t = XFurnitureConfigs.GetDormFurnitureAnimation(furniture.AnimationId)
    if not t then
        return nil
    end

    for k, v in pairs(t.CharacterId) do
        if charId == v and t.CharacterAnimationName[k] then
            return t.CharacterAnimationName[k]
        end
    end

    return nil
end

-- 获取家具动画名
function XFurnitureConfigs.GetOnceAnimationName(furnitureId)
    local furniture = XFurnitureConfigs.GetFurnitureBaseTemplatesById(furnitureId)
    if not furniture then
        return nil
    end

    local t = XFurnitureConfigs.GetDormFurnitureAnimation(furniture.AnimationId)
    if not t then
        return nil
    end

    if t.ClickType == XFurnitureConfigs.FurnitureAnimationType.Once then
        return  t.OnceAnimationName
    elseif t.ClickType == XFurnitureConfigs.FurnitureAnimationType.Repeat then
        return  t.RepaatAnimationName
    end

    return nil
end

-- 获取喜好度类型Icon
function XFurnitureConfigs.GetDormFurnitureTypeIcon(id)
    local t = XFurnitureConfigs.GetDormFurnitureType(id)
    return t.TypeIcon
end

-- 获取喜好度类型Name
function XFurnitureConfigs.GetDormFurnitureTypeName(id)
    local t = XFurnitureConfigs.GetDormFurnitureType(id)
    return t.TypeName
end

-- 获取家具分类数据
function XFurnitureConfigs.GetFurnitureTemplatePartType()
    local parts = {}
    for _, part in pairs(FurnitureTypeTemplates) do
        if not parts[part.MinorType] then
            parts[part.MinorType] = {}
            parts[part.MinorType].MinorName = part.MinorName
            parts[part.MinorType].Categorys = {}
        end
        local categoryInfo = {}
        categoryInfo.Category = part.Category
        categoryInfo.CategoryName = part.CategoryName
        categoryInfo.Id = part.Id

        parts[part.MinorType].Categorys[part.Id] = categoryInfo
    end

    return parts
end


-- 随机属性描述
function XFurnitureConfigs.GetAdditionalRandomIntroduce(id)
    local currentAttr = FurnitureAdditionalAttr[id]

    if not currentAttr then
        XLog.Error("XFurnitureConfigs.GetAdditionalRandomIntroduce not found by id : " .. tostring(id))
        return
    end

    return currentAttr.Introduce or ""
end

-- 获取评分词条
function XFurnitureConfigs.GetAdditionalRandomEntry(id, removeScore)
    local addRandom = XFurnitureConfigs.GetAdditonAttrConfigById(id)
    local quality = addRandom.QualityType < 0 and 2 or addRandom.QualityType
    local color = XFurnitureConfigs.FurnitureAttrColor[quality]
    local level = XFurnitureConfigs.FurnitureAttrLevel[quality]
    if removeScore then
        return string.format("<color=%s>%s</color>", color, level)
    else
        return string.format("<color=%s>%s%d</color>", color, level, addRandom.AddScore)
    end
end

-- 获取一组随机属性描述
function XFurnitureConfigs.GetGroupRandomIntroduce(groupId,removeScore)
    if DormFurnitureTypeAttsDic[groupId] then
        return DormFurnitureTypeAttsDic[groupId]
    end

    local removeScore = removeScore or false
    local groupIntroduce = {}
    local data = {}
    for k, v in pairs(FurnitureAdditionalAttr) do
        if groupId == v.GroupId then
            table.insert(groupIntroduce, {
                Id = v.AttributeId,
                Introduce = v.Introduce,
                QualityType = v.QualityType,
                AddDes = XFurnitureConfigs.GetAdditionalRandomEntry(v.AttributeId,removeScore) or ""
            })
        end
    end

    if _G.next(groupIntroduce) then
        table.sort(groupIntroduce,function (a,b)
            return a.QualityType > b.QualityType
        end)
    end

    for _,v in pairs(groupIntroduce)do
        if not data[v.AddDes] then
            data[v.AddDes] = {}
        end
        table.insert(data[v.AddDes], v)
    end

    DormFurnitureTypeAttsDic[groupId] = data

    return data
end

-- 家具风格套装
function XFurnitureConfigs.GetFurnitureSuitTemplates()
    return FurnitureSuitTemplates
end

-- 宿舍套装类型名字
function XFurnitureConfigs.GetFurnitureSuitName(id)
    local d = FurnitureSuitTemplates[id]
    if not d then
        return
    end

    return d.SuitName
end

-- 属性标签
function XFurnitureConfigs.GetFurnitureTagTypeTemplates()
    return FurnitureTagTypeTemplates
end

-- 获取家具类型列表
function XFurnitureConfigs.GetFurnitureTypeList()
    return FurnitureTypeList
end

-- 获取家具类型列表，用于构建二级菜单
function XFurnitureConfigs.GetFurnitureTypeGroupList()
    return FurnitureTypeGroupList
end

function XFurnitureConfigs.GetFurnitureSuitTemplatesById(suitId)
    local currentSuitTemplate = FurnitureSuitTemplates[suitId]

    if not currentSuitTemplate then
        XLog.Error("XFurnitureConfigs.GetFurnitureSuitTemplatesById not found by suitId : " .. tostring(suitId))
        return
    end

    return currentSuitTemplate
end

-- 家具客户端数据
function XFurnitureConfigs.GetFurnitureBaseTemplatesById(id)
    local currentTemplates = FurnitureTemplates[id]

    if not currentTemplates then
        XLog.Error("XFurnitureConfigs.GetFurnitureBaseTemplatesById not found by id : " .. tostring(id))
        return
    end

    return currentTemplates
end

-- 家具名称
function XFurnitureConfigs.GetFurnitureNameById(id)
    local currentTempates = XFurnitureConfigs.GetFurnitureBaseTemplatesById(id)
    return currentTempates.Name
end

-- 家具Icon
function XFurnitureConfigs.GetFurnitureIconById(id)
    local currentTempates = XFurnitureConfigs.GetFurnitureBaseTemplatesById(id)
    return currentTempates.Icon
end

-- 家具描述
function XFurnitureConfigs.GetFurnitureDescriptionById(id)
    local currentTempates = XFurnitureConfigs.GetFurnitureBaseTemplatesById(id)
    return currentTempates.Desc
end

-- 家具大图标
function XFurnitureConfigs.GetFurnitureBigIconById(id)
    local currentTempates = XFurnitureConfigs.GetFurnitureBaseTemplatesById(id)
    return currentTempates.Icon
end

-- 属性类型
function XFurnitureConfigs.GetFurnitureAttrType()
    local temp = {}
    for k, v in pairs(DormFurnitureTypeTemplate) do
        if k < XFurnitureConfigs.AttrType.AttrAll then
            table.insert(temp, v)
        end
    end

    return temp
end

-- 获取所有家具
function XFurnitureConfigs.GetAllFurnitures()
    return FurnitureTemplates
end

-- 家具基础数据
function XFurnitureConfigs.GetFurnitureTemplateById(id)
    local currentTemplate = FurnitureTemplates[id]

    if not currentTemplate then
        XLog.Error("XFurnitureConfigs.GetFurnitureTemplateById not found by id : " .. tostring(id))
        return
    end

    return currentTemplate
end

-- 获取家具类型配置表通过 ConfigID
function XFurnitureConfigs.GetFurnitureTypeCfgByConfigId(configId)
    local furnitureTemplate = XFurnitureConfigs.GetFurnitureTemplateById(configId)
    if not furnitureTemplate then
        return nil
    end

    local typeTemplate = XFurnitureConfigs.GetFurnitureTypeById(furnitureTemplate.TypeId)
    return typeTemplate
end

-- 摆放类型转地表类型
function XFurnitureConfigs.LocateTypeToXHomePlatType(locateType)
    local type = nil
    if locateType == XFurnitureConfigs.HomeLocateType.LocateGround then
        type = CS.XHomePlatType.Ground
    elseif locateType == XFurnitureConfigs.HomeLocateType.LocateWall then
        type = CS.XHomePlatType.Wall
    end

    return type
end

-- 获取家具交互点列表
function XFurnitureConfigs.GetFurnitureInteractPosList(posStr)
    local list = {}

    local strs = string.Split(posStr, "|")
    if strs and #strs > 0 then
        for _, v in ipairs(strs) do
            local xy = string.Split(v, "#")
            if xy and #xy >= 2 then
                local x = tonumber(xy[1])
                local y = tonumber(xy[2])
                if x and y then
                    local vec = {}
                    vec.x = x
                    vec.y = y
                    table.insert(list, vec)
                end
            end
        end
    end

    return list
end

-- 获取家具等级配置表
function XFurnitureConfigs.GetFurnitureLevelTemplate(furnitureType)
    local currentTemplates = FurnitureLevelTemplates[furnitureType]

    if not currentTemplates then
        XLog.Error("XFurnitureConfigs.GetFurnitureLevelTemplate not found by id : " .. tostring(furnitureType))
        return
    end

    return currentTemplates
end
-- 获取家具总属性分级描述
function XFurnitureConfigs.GetFurnitureTotalAttrLevelDescription(furnitureType, totalScore)
    local quality = XFurnitureConfigs.GetFurnitureTotalAttrLevel(furnitureType, totalScore)
    local color = XFurnitureConfigs.FurnitureAttrColor[quality] or XFurnitureConfigs.FurnitureAttrColor[1]
    local level = XFurnitureConfigs.FurnitureAttrLevel[quality] or XFurnitureConfigs.FurnitureAttrLevel[1]
    return string.format(CS.XGame.ClientConfig:GetString("DormAttrFormat"), color, level, totalScore)
end


function XFurnitureConfigs.GetFurnitureTotalAttrLevelNewColorDescription(furnitureType, totalScore)
    local quality = XFurnitureConfigs.GetFurnitureTotalAttrLevel(furnitureType, totalScore)
    local color =   XFurnitureConfigs.FurnitureAttrTagColor[3]-- XFurnitureConfigs.FurnitureAttrTagColor[quality] or XFurnitureConfigs.FurnitureAttrTagColor[3]
    local level =   XFurnitureConfigs.FurnitureAttrLevel[quality] or XFurnitureConfigs.FurnitureAttrLevel[1]
    return string.format(CS.XGame.ClientConfig:GetString("DormAttrFormat"), color, level, totalScore)
end

-- 获取家具总属性等级
function XFurnitureConfigs.GetFurnitureTotalAttrLevel(furnitureType, totalScore)
    local temp = -1
    local furntiureLevels = XFurnitureConfigs.GetFurnitureLevelTemplate(furnitureType)
    local quality = 2
    local maxScore = 0
    local minScore = totalScore
    for k, v in pairs(furntiureLevels) do
        local minScore = v.MinScore
        if totalScore >= minScore and minScore > temp then
            temp = minScore
            quality = v.Quality
            minScore =  v.MinScore
        end

        if v.MaxScore > maxScore then
            maxScore = v.MaxScore
        end
    end
    return quality,maxScore,minScore
end

-- 获取家具单个属性等级
function XFurnitureConfigs.GetFurnitureSingleAttrLevel(furnitureType,attrIndex,score)
    local temp = -1
    local furntiureLevels = FurnitureSingleAttrLevelIndex[furnitureType]
    local quality = 2
    local maxScore = 0
    local mScore = score

    for k, v in pairs(furntiureLevels) do
        local minScore = v.AttrMinScore[attrIndex]
        if score >= minScore and minScore > temp then
            temp = minScore
            quality = v.Quality
            mScore = minScore
        end

        if v.AttrMaxScore[attrIndex] > maxScore then
            maxScore = v.AttrMaxScore[attrIndex]
        end
    end

    return quality,maxScore,mScore
end

-- 获取家具等级描述
function XFurnitureConfigs.GetFurnitureAttrLevelDescription(furnitureType, attrType, score)
    local quality = XFurnitureConfigs.GetFurnitureAttrlevel(furnitureType, attrType, score)
    local color = XFurnitureConfigs.FurnitureAttrColor[quality] or XFurnitureConfigs.FurnitureAttrColor[1]
    local level = XFurnitureConfigs.FurnitureAttrLevel[quality] or XFurnitureConfigs.FurnitureAttrLevel[1]
    return string.format(CS.XGame.ClientConfig:GetString("DormAttrFormat"), color, level, score)
end


-- 获取家具等级描述
function XFurnitureConfigs.GetFurnitureAttrLevelNewDescription(furnitureType, attrType, score)
    local quality = XFurnitureConfigs.GetFurnitureAttrlevel(furnitureType, attrType, score)
    local color = XFurnitureConfigs.FurnitureAttrTagColor[quality] or XFurnitureConfigs.FurnitureAttrTagColor[1]
    local level = XFurnitureConfigs.FurnitureAttrLevel[quality] or XFurnitureConfigs.FurnitureAttrLevel[1]
    return string.format(CS.XGame.ClientConfig:GetString("DormAttrFormat"), color, level, score)
end


-- 获取家具属性等级
function XFurnitureConfigs.GetFurnitureAttrlevel(furnitureType, attrType, score)
    local temp = -1
    local furntiureLevels = XFurnitureConfigs.GetFurnitureLevelTemplate(furnitureType)
    local quality = 2

    for k, v in pairs(furntiureLevels) do
        local attrScore = v.AttrScore[attrType] or 0
        if score >= attrScore and attrScore > temp then
            temp = attrScore
            quality = v.Quality
        end
    end
    return quality
end

-- 获取家具摆放类型
function XFurnitureConfigs.GetFurniturePlaceType(furnitureTypeId)
    if not furnitureTypeId then
        XLog.Error("XFurnitureConfigs.GetFurniturePlaceType furnitureTypeId is nil.")
        return
    end

    local typeCfg = FurnitureTypeTemplates[furnitureTypeId]
    if not typeCfg then
        XLog.Error("XFurnitureConfigs.GetFurniturePlaceType furniture type cfg is not exist. id = " .. tostring(furnitureTypeId))
        return
    end

    if typeCfg.MajorType == 1 and typeCfg.MinorType == 1 then
        return XFurniturePlaceType.Ground
    elseif typeCfg.MajorType == 1 and typeCfg.MinorType == 2 then
        return XFurniturePlaceType.Wall
    elseif typeCfg.MajorType == 1 and typeCfg.MinorType == 3 then
        return XFurniturePlaceType.Ceiling
    elseif typeCfg.MajorType == 2 and typeCfg.MinorType == 6 then
        return XFurniturePlaceType.OnWall
    else
        return XFurniturePlaceType.OnGround
    end
end

-- 获取所有家具类型
function XFurnitureConfigs.GetAllFurnitureTypes()
    return FurnitureTypeTemplates
end

-- 家具类型数据
function XFurnitureConfigs.GetFurnitureTypeById(id)
    local currentTemplates = FurnitureTypeTemplates[id]

    if not currentTemplates then
        XLog.Error("XFurnitureConfigs.GetFurnitureType not found by id : " .. tostring(id))
    end

    return currentTemplates
end

-- 家具属基础性数据
function XFurnitureConfigs.GetFurnitureBaseAttrValueById(id)
    local furnitureBaseAttrTemplate = FurnitureBaseAttrTemplate[id]

    if not furnitureBaseAttrTemplate then
        return 0
    end

    return furnitureBaseAttrTemplate.Value
end

-- 家具属额外性数据
function XFurnitureConfigs.GetFurnitureExtraAttrsById(id)
    local attrIds = {}
    local furnitureExtraAttrTemplate = FurnitureExtraAttrTemplate[id]

    if not furnitureExtraAttrTemplate then
        return attrIds
    end

    return furnitureExtraAttrTemplate
end

function XFurnitureConfigs.GetFurntiureExtraAttrTotalValue(id)
    if not FurnitureExtraAttrTemplate[id] then
        return 0
    end

    return XFurnitureConfigs.GetFurnitureBaseAttrValueById(FurnitureExtraAttrTemplate[id].BaseAttrId)
end

-- 最低，最高档位
function XFurnitureConfigs.GetFurnitureCreateMinAndMax()
    local minConsume = FurnitureCreateAttr[1].MinConsume
    local maxConsume = FurnitureCreateAttr[1].MinConsume
    for k, v in pairs(FurnitureCreateAttr) do
        if v.MinConsume < minConsume then
            minConsume = v.MinConsume
        end
        if v.MinConsume > maxConsume then
            maxConsume = v.MinConsume
        end
    end
    return minConsume, maxConsume
end

-- 根据家具拿到对应的图纸，一一对应,家具不一定有对应的图纸,如果没有则不能改装
function XFurnitureConfigs.GetDrawingByFurnitureId(furnitureId)
    return FurnitureToDrawingMap[furnitureId]
end

-- 根据图纸拿到预览的家具，一一对应,图纸一定有对应的家具
function XFurnitureConfigs.GetPreviewFurnitureByDrawingId(drawingId)
    return DrawingToFurnitureMap[drawingId]
end

function XFurnitureConfigs.GetRefitTypeDatas(typeId)
    return DrawingPicMap[typeId]
end

-- 根据家具基础类型设置视角
function XFurnitureConfigs.GetFurnitureViewAngleByMinor(minor)
    local currentViewAngle = FurnitureViewAngle[minor]
    if not currentViewAngle then
        XLog.Error("XFurnitureConfigs.GetFurnitureViewAngleByMinor is not found by minor :" .. tostring(minor))
        return
    end
    return currentViewAngle
end

function XFurnitureConfigs.GetFurnitureColour(furnitureId)
    return FurnitureColour[furnitureId]
end

-- 获取家具套装
function XFurnitureConfigs.GetFurnitureSuitConfig(configId)
    local furnitureTemplate = XFurnitureConfigs.GetFurnitureTemplateById(configId)
    if furnitureTemplate.SuitId <= 0 then
        return nil
    end

    return XFurnitureConfigs.GetFurnitureSuitTemplatesById(furnitureTemplate.SuitId)
end

-- 图鉴显示配置数据
function XFurnitureConfigs.GetFieldGuideDatas()
    local data = {}

    for _, v in pairs(FurnitureTemplates) do
        if v and v.SuitId and v.SuitId > 0 then
            if not data[v.SuitId] then
                data[v.SuitId] = {}
            end
            table.insert(data[v.SuitId], v)
        end
    end

    return data
end

-- 获取家具回收奖励Id
function XFurnitureConfigs.GetFurnitureReturnId(configId)
    local furnitureTemplate = XFurnitureConfigs.GetFurnitureTemplateById(configId)
    if not furnitureTemplate.ReturnId or furnitureTemplate.ReturnId <= 0 then
        return nil
    end

    return furnitureTemplate.ReturnId
end

function XFurnitureConfigs.GetFurnitureReward(id)
    return FurnitureRewardTemplate[id]
end

-- 计算恢复速度
function XFurnitureConfigs.GetRecoverSpeed(speed)
    local tempSpeed = string.format("%.1f", speed / 100)

    if tempSpeed * 10 % 10 == 0 then
        tempSpeed = string.format("%d", tempSpeed)
    end

    return tempSpeed
end
