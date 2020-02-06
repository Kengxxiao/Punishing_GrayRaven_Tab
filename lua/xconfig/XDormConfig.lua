XDormConfig = XDormConfig or {}

-- 加载宿舍类型
XDormConfig.DormDataType = {
    Self = 0,
    Target = 1
}

-- 构造体喜欢类型
XDormConfig.CharacterLikeType = {
    LoveType = "LoveType",
    LikeType = "LikeType",
}

-- 仓库Toggle
XDormConfig.DORM_BAG_PANEL_INDEX = {
    FURNITURE = 1, -- 家具
    CHARACTER = 2, -- 构造体
    DRAFT = 3, -- 图纸
}

-- 仓库住户Toggle
XDormConfig.DORM_CHAR_INDEX = {
    CHARACTER = 1, -- 构造体
    EMNEY = 2, -- 感染体
}

-- 跳转类型
XDormConfig.VisitDisplaySetType = {
    MySelf = 1,
    MyFriend = 2,
    Stranger = 3
}

-- 访问类型
XDormConfig.VisitTabTypeCfg = {
    MyFriend = 1,
    Visitor = 2
}

-- 宿舍激活状态
XDormConfig.DormActiveState = {
    Active = 0,
    UnActive = 1
}

-- 宿舍构造体抚摸状态
XDormConfig.TouchState = {
    Hide = 0, -- 关闭
    Touch = 1, -- 抚摸
    WaterGun = 2, -- 水枪
    Play = 3, -- 玩耍
    TouchSuccess = 4, -- 抚摸成功
    WaterGunSuccess = 5, -- 水枪成功
    PlaySuccess = 6, --玩耍成功
    Hate = 7, -- 讨厌
    TouchHate = 8, --讨厌抚摸
}

-- 打工状态
XDormConfig.WorkPosState = {
    Working = 1, --打工中
    Worked = 0, --打工完成
    Empty = -1, --空的
    RewardEd = 2, --奖励领取完
    Lock = 3,
}

-- 客户端展示事件Id
XDormConfig.ShowEventId = {
    VitalityAdd = 101, -- 体力增加
    VitalityCut = 102, -- 体力减少
    MoodAdd = 103, -- 心情增加
    MoodCut = 104, -- 心情减少
    VitalitySpeedAdd = 105, -- 体力速度增加
    VitalitySpeedCut = 106, -- 体力速度减少
    MoodSpeedAdd = 107, -- 心情速度增加
    MoodSpeedCut = 108, -- 心情速度减少
}

-- 客户端展示事件Id
XDormConfig.ShowEffectType = {
    Simple = 1, -- 单行模式
    Complex = 2, -- 多行模式
}

-- 客户端展示事件Id
XDormConfig.CompareType = {
    Less = 0, -- 小于等于
    Greater = 1, -- 大于等于
    Equal = 2, -- 等于
}

-- 回复类型
XDormConfig.RecoveryType = {
    PutFurniture = 1, -- 放置家具
    PutCharacter = 2, -- 放置构造体
}

XDormConfig.DormSecondEnter = {
    Task = 1, -- 任务
    Des = 2, -- 描述
    WareHouse = 3, --仓库
    ReName = 4, --改名
    FieldGuilde = 5, --图鉴
    Buid = 6, --建造
    Shop = 7, --商店
    Person = 8, --人员
}

XDormConfig.DormAttDesIndex = {
    [1] = "DormScoreAttrADes",
    [2] = "DormScoreAttrBDes",
    [3] = "DormScoreAttrCDes",
}

-- 宿舍人物类型
XDormConfig.DormSex = {
    Man = 1,
    Woman = 2,
    Infect = 3,
    Other = 4,
}

-- 构造体入住枚举
XDormConfig.DormIntakeType = {
    All = 0,
    Architecture = 1,
    Infection  = 2,
}

XDormConfig.DORM_VITALITY_MAX_VALUE = math.floor(CS.XGame.Config:GetInt("DormVitalityMaxValue") / 100)
XDormConfig.DORM_MOOD_MAX_VALUE = math.floor(CS.XGame.Config:GetInt("DormMoodMaxValue") / 100)
XDormConfig.DORM_DRAFT_SHOP_ID = CS.XGame.ClientConfig:GetInt("DormDraftShopId")

XDormConfig.TOUCH_LENGTH = CS.XGame.ClientConfig:GetInt("DormCharacterTouchLength")
XDormConfig.WATERGUN_TIME = CS.XGame.ClientConfig:GetInt("DormCharacterWaterGunTime")
XDormConfig.PLAY_TIME = CS.XGame.ClientConfig:GetInt("DormCharacterPlayTime")
XDormConfig.DISPPEAR_TIME = CS.XGame.ClientConfig:GetInt("DormDetailDisppearTime")
XDormConfig.DRAFT_DIS = CS.XGame.ClientConfig:GetInt("DormDraftDistance")
XDormConfig.TOUCH_CD = CS.XGame.ClientConfig:GetFloat("DormCharacterTouchCD")
XDormConfig.TOUCH_PROP = CS.XGame.ClientConfig:GetFloat("DormCharacterTouchProportion")
XDormConfig.DormComfortTime = CS.XGame.ClientConfig:GetInt("DormComfortTime") or 1

local TABLE_DORM_CHARACTER_EVENT_PATH = "Share/Dormitory/Character/DormCharacterEvent.tab"
local TABLE_DORM_CHARACTER_BEHAVIOR_PATH = "Share/Dormitory/Character/DormCharacterBehavior.tab"
local TABLE_DORMITORY_PATH = "Share/Dormitory/Dormitory.tab"
local TABLE_DORMCHARACTERWORK_PATH = "Share/Dormitory/Character/DormCharacterWork.tab"
local TABLE_DORM_CHARACTER_RECOVERY_PATH = "Share/Dormitory/Character/DormCharacterRecovery.tab"
local TABLE_DORM_CHARACTER_FONDLE_PATH = "Share/Dormitory/Character/DormCharacterFondle.tab"
local TABLE_CHARACTER_STYLE_PATH = "Share/Dormitory/Character/DormCharacterStyle.tab"
local TABLE_CHARACTER_REWARD_PATH = "Share/Dormitory/Character/DormCharacterReward.tab"
local TABLE_DORM_BGM_PATH = "Share/Dormitory/DormBgm.tab"


local TABLE_CHARACTER_MOOD_PATH = "Client/Dormitory/DormCharacterMood.tab"
local TABLE_FURNITURESUIT_PATH = "Client/Dormitory/DormFurnitureSuit.tab"
local TABLE_MOOD_EFFECT_PATH = "Client/Dormitory/DormCharacterEffect.tab"
local TABLE_CHARACTER_DIALOG_PATH = "Client/Dormitory/DormCharacterDialog.tab"
local TABLE_CHARACTER_ACTION_PATH = "Client/Dormitory/DormCharacterAction.tab"
local TABLE_CHARACTER_INTERACTIVE_PATH = "Client/Dormitory/DormInteractiveEvent.tab"
local TABLE_SHOW_EVENT_PATH = "Client/Dormitory/DormShowEvent.tab"
local TABLE_DORM_GUIDE_TASK_PATH = "Client/Dormitory/DormGuideTask.tab"

local CharacterEventTemplate = {}
local CharacterBehaviorTemplate = {}
local DormitoryTemplate = {}        --宿舍配置表
local CharacterBehaviorStateIndex = {}
local DormCharacterWork = {}        --宿舍打工工位配置表
local DormCharacterRecovery = {}    --构造体回复配置表 table = {characterId = {config1, config2, ...}}
local CharacterStyleTemplate = {}       --客户端构造体风格配置表
local CharacterMoodTemplate = {}        --客户端构造体心情配置表
local MoodEffectTemplate = {}       --构造体表情特效配置表
local CharacterFondleTemplate = {}       -- 爱抚配置表
local ChaarcterShowEventTemplate = {}       -- 事件客户端表现配置表
local DormTaskGuideCfg = {}       -- 宿舍指引任务
local DormCharacterRewardCfg = {}
local AllEnmeyCount = 0           -- 可获得感染体总数
local AllCharcterCount = 0           -- 可获得构造体总数

local CharacterActionTemplate = {} --动作
local CharacterInteractiveTemplate = {} --动作

local CharacterDialogTemplate = {}       -- 构造体对话表
local CharacterDialogStateIndex = {}
local CharacterActionIndex = {}
local CharacterInteractiveIndex = {}
local DormTaskGuideDic = nil

local DormBgmTemplate = {}

-- 初始化构造体恢复表，并排序
local function InitDormCharacterRecovery()
    local recoverys = XTableManager.ReadByIntKey(TABLE_DORM_CHARACTER_RECOVERY_PATH, XTable.XTableDormCharacterRecovery, "Id")
    for _, recovery in pairs(recoverys) do
        if not DormCharacterRecovery[recovery.CharacterId] then
            DormCharacterRecovery[recovery.CharacterId] = {}
        end

        table.insert(DormCharacterRecovery[recovery.CharacterId], recovery)
    end

    for charId, recovery in pairs(DormCharacterRecovery) do
        table.sort(recovery, function(a, b)
            return a.Pre < b.Pre
        end)
    end
end

function XDormConfig.Init()
    CharacterEventTemplate = XTableManager.ReadByIntKey(TABLE_DORM_CHARACTER_EVENT_PATH, XTable.XTableDormCharacterEvent, "EventId")
    CharacterBehaviorTemplate = XTableManager.ReadByIntKey(TABLE_DORM_CHARACTER_BEHAVIOR_PATH, XTable.XTableDormCharacterBehavior, "Id")
    DormitoryTemplate = XTableManager.ReadByIntKey(TABLE_DORMITORY_PATH, XTable.XTableDormitory, "Id")
    DormCharacterWork = XTableManager.ReadByIntKey(TABLE_DORMCHARACTERWORK_PATH, XTable.XTableDormCharacterWork, "DormitoryNum")
    CharacterStyleTemplate = XTableManager.ReadByIntKey(TABLE_CHARACTER_STYLE_PATH, XTable.XTableDormCharacterStyle, "Id")
    CharacterMoodTemplate = XTableManager.ReadByIntKey(TABLE_CHARACTER_MOOD_PATH, XTable.XTableDormCharacterMood, "Id")
    MoodEffectTemplate = XTableManager.ReadByIntKey(TABLE_MOOD_EFFECT_PATH, XTable.XTableDormCharacterEffect, "Id")
    CharacterDialogTemplate = XTableManager.ReadByIntKey(TABLE_CHARACTER_DIALOG_PATH, XTable.XTableDormCharacterDialog, "Id")
    CharacterActionTemplate = XTableManager.ReadByIntKey(TABLE_CHARACTER_ACTION_PATH, XTable.XTableDormCharacterAction, "Id")
    CharacterFondleTemplate = XTableManager.ReadByIntKey(TABLE_DORM_CHARACTER_FONDLE_PATH, XTable.XTableDormCharacterFondle, "CharacterId")
    CharacterActionTemplate = XTableManager.ReadByIntKey(TABLE_CHARACTER_ACTION_PATH, XTable.XTableDormCharacterAction, "Id")
    CharacterInteractiveTemplate = XTableManager.ReadByIntKey(TABLE_CHARACTER_INTERACTIVE_PATH, XTable.XTableDormInteractiveEvent, "Id")
    ChaarcterShowEventTemplate = XTableManager.ReadByIntKey(TABLE_SHOW_EVENT_PATH, XTable.XTableDormShowEvent, "Id")
    DormBgmTemplate = XTableManager.ReadByIntKey(TABLE_DORM_BGM_PATH, XTable.XTableDormBgm, "Id")

    DormTaskGuideCfg = XTableManager.ReadByIntKey(TABLE_DORM_GUIDE_TASK_PATH, XTable.XTableDormGuideTask, "Id")
    DormCharacterRewardCfg = XTableManager.ReadByIntKey(TABLE_CHARACTER_REWARD_PATH, XTable.XTableDormCharacterReward, "Id")
    InitDormCharacterRecovery()

    CharacterBehaviorStateIndex = {}

    for k, v in pairs(CharacterBehaviorTemplate) do
        CharacterBehaviorStateIndex[v.CharacterId] = CharacterBehaviorStateIndex[v.CharacterId] or {}
        CharacterBehaviorStateIndex[v.CharacterId][v.State] = v
    end

    for k, v in pairs(CharacterDialogTemplate) do
        CharacterDialogStateIndex[v.CharacterId] = CharacterDialogStateIndex[v.CharacterId] or {}
        CharacterDialogStateIndex[v.CharacterId][v.State] = CharacterDialogStateIndex[v.CharacterId][v.State] or {}
        table.insert(CharacterDialogStateIndex[v.CharacterId][v.State], v)
    end

    for k, v in pairs(CharacterActionTemplate) do
        CharacterActionIndex[v.CharacterId] = CharacterActionIndex[v.CharacterId] or {}
        CharacterActionIndex[v.CharacterId][v.Name] = v.State
    end

    for k, v in pairs(CharacterInteractiveTemplate) do
        local cha1 = v.CharacterIds[1]
        local cha2 = v.CharacterIds[2]
        CharacterInteractiveIndex[cha1] = CharacterInteractiveIndex[cha1] or {}
        CharacterInteractiveIndex[cha1][cha2] = v
    end

    for k, v in pairs(CharacterStyleTemplate) do
        if v.Type == XDormConfig.DormSex.Infect then
            AllEnmeyCount = AllEnmeyCount + 1
        else
            AllCharcterCount = AllCharcterCount + 1
        end
    end

    XDormConfig.DormAnimationMoveTime = CS.XGame.ClientConfig:GetInt("DormMainAnimationMoveTime") or 0
    XDormConfig.DormAnimationStaicTime = CS.XGame.ClientConfig:GetInt("DormMainAnimationStaicTime") or 0
    XDormConfig.DormSecondAnimationDelayTime = CS.XGame.ClientConfig:GetInt("DormSecondAnimationDelayTime") or 0
end

-- 获取构造体奖励名字
function XDormConfig.GetDormCharacterRewardNameById(id)
    local data = XDormConfig.GetDormCharacterRewardData(id)
    if not data or not data.Name then
        XLog.Error("XDormConfig.GetDormCharacterRewardNameById error:id is not found, id = " .. tostring(id))
        return nil
    end

    return data.Name
end

-- 获取构造体奖励品质
function XDormConfig.GetDormCharacterRewardQualityById(id)
    local data = XDormConfig.GetDormCharacterRewardData(id)
    if not data or not data.Quality then
        XLog.Error("XDormConfig.GetDormCharacterRewardQualityById error:id is not found, id = " .. tostring(id))
        return nil
    end

    return data.Quality
end

-- 获取构造体奖励Icon
function XDormConfig.GetDormCharacterRewardIconById(id)
    local data = XDormConfig.GetDormCharacterRewardData(id)
    if not data or not data.Icon then
        XLog.Error("XDormConfig.GetDormCharacterRewardIconById error:id is not found, id = " .. tostring(id))
        return nil
    end

    return data.Icon
end

-- 获取构造体奖励SmallIcon
function XDormConfig.GetDormCharacterRewardSmallIconById(id)
    local data = XDormConfig.GetDormCharacterRewardData(id)
    if not data or not data.SmallIcon then
        XLog.Error("XDormConfig.GetDormCharacterRewardSmallIconById error:id is not found, id = " .. tostring(id))
        return nil
    end

    return data.SmallIcon
end

-- 获取构造体奖励CharacterId
function XDormConfig.GetDormCharacterRewardCharIdById(id)
    local data = XDormConfig.GetDormCharacterRewardData(id)
    if not data or not data.CharacterId then
        XLog.Error("XDormConfig.GetDormCharacterRewardCharacterIdById error:id is not found, id = " .. tostring(id))
        return nil
    end

    return data.CharacterId
end

-- 获取构造体奖励Description
function XDormConfig.GetDormDescriptionRewardCharIdById(id)
    local data = XDormConfig.GetDormCharacterRewardData(id)
    if not data or not data.Description then
        XLog.Error("XDormConfig.GetDormDescriptionRewardCharIdById error:id is not found, id = " .. tostring(id))
        return nil
    end

    return data.Description
end

-- 获取构造体奖励WorldDescription
function XDormConfig.GetDormWorldDescriptionRewardCharIdById(id)
    local data = XDormConfig.GetDormCharacterRewardData(id)
    if not data or not data.WorldDescription then
        XLog.Error("XDormConfig.GetDormWorldDescriptionRewardCharIdById error:id is not found, id = " .. tostring(id))
        return nil
    end

    return data.WorldDescription
end

function XDormConfig.GetDormCharacterRewardData(id)
    local data = DormCharacterRewardCfg[id]
    return data
end

-- 宿舍指引任务Dic
function XDormConfig.GetDormitoryGuideTaskCfg()
    if DormTaskGuideDic then
        return DormTaskGuideDic
    end

    DormTaskGuideDic = {}
    for _, v in pairs(DormTaskGuideCfg) do
        DormTaskGuideDic[v.TaskId] = v.TaskId
    end
    return DormTaskGuideDic
end

-- 获取所有宿舍
function XDormConfig.GetTotalDormitoryCfg()
    local t = DormitoryTemplate
    return t
end

-- 获取可获得感染体总数
function XDormConfig.GetEnmeyTemplatesCount()
    return AllEnmeyCount
end

-- 获取可获得构造体总数
function XDormConfig.GetCharacterTemplatesCount()
    return AllCharcterCount
end

-- 配置的宿舍总数
function XDormConfig.GetTotalDormitortCountCfg()
    local count = 0
    local t = DormitoryTemplate or {}
    for _, v in pairs(t) do
        count = count + 1
    end

    return count
end

-- 获取宿舍配置
function XDormConfig.GetDormitoryCfgById(id)
    if not id then
        return nil
    end

    local t = DormitoryTemplate[id]
    if not t then
        XLog.Error("XDormConfig.GetDormitoryCfgById error:id is not found, id = " .. tostring(id))
        return nil
    end

    return t
end

-- 获取宿舍号
function XDormConfig.GetDormitoryNumById(dormitoryId)
    local dormitoryConfig = XDormConfig.GetDormitoryCfgById(dormitoryId)
    return dormitoryConfig.InitNumber
end

-- 宿舍可住人数
-- 获取宿舍配置
function XDormConfig.GetDormPersonCount(id)
    local t = XDormConfig.GetDormitoryCfgById(id)
    if not t then
        return 0
    end

    return t.CharCapacity or 0
end

--获取行为节点Id
function XDormConfig.GetCharacterBehavior(charId, state)
    if not CharacterBehaviorStateIndex or not CharacterBehaviorStateIndex[charId] then
        XLog.Error("CharacterBehaviorStateIndex is null or charId not exist", charId)
        return
    end

    if not CharacterBehaviorStateIndex[charId][state] then
        XLog.Error("CharacterBehaviorStateIndex State not exist", charId, state)
        return
    end

    return CharacterBehaviorStateIndex[charId][state]
end


--获取行为表
function XDormConfig.GetCharacterBehaviorById(id)
    if not CharacterBehaviorTemplate then
        XLog.Error("CharacterBehaviorTemplate is null")
        return
    end

    if not CharacterBehaviorTemplate[id] then
        XLog.Error("CharacterBehaviorTemplate is null .Id:" .. tostring(id))
        return
    end


    return CharacterBehaviorTemplate[id]
end


--获取角色交互
function XDormConfig.GetCharacterInteractiveIndex(id1, id2)
    if not CharacterInteractiveIndex then
        return false
    end

    if CharacterInteractiveIndex[id1] and CharacterInteractiveIndex[id1][id2] then
        local temp = CharacterInteractiveIndex[id1][id2]
        return true, temp, temp.State[1], temp.State[2]
    elseif CharacterInteractiveIndex[id2] and CharacterInteractiveIndex[id2][id1] then
        local temp = CharacterInteractiveIndex[id2][id1]
        return true, temp, temp.State[2], temp.State[1]
    end

    return false
end

--获取动作状态机
function XDormConfig.GetCharacterActionState(charId, name)
    if not CharacterActionIndex or not CharacterActionIndex[charId] or not CharacterActionIndex[charId][name] then
        XLog.Error(string.format("CharacterActionIndex action not exist charId:%s name:%s", charId, name))
        name = "QR2YongyechaoExcessiveBase01"
    end

    return CharacterActionIndex[charId][name]
end

--获取事件
function XDormConfig.GetCharacterEventById(id)
    if not CharacterEventTemplate then
        XLog.Error("CharacterEventTemplate is null")
        return
    end

    if not CharacterEventTemplate[id] then
        XLog.Error("CharacterEventTemplate is null .ID: " .. tostring(id))
        return
    end

    return CharacterEventTemplate[id]
end

function XDormConfig.GetDormCharacterWorkById(id)
    if not id then
        return
    end

    return DormCharacterWork[id]
end

function XDormConfig.GetDormCharacterWorkData()
    return DormCharacterWork
end

-- 获取构造体回复配置表
function XDormConfig.GetCharRecoveryConfig(charId)
    local t = DormCharacterRecovery[charId]
    if not t then
        XLog.Error("XDormConfig.GetCharRecoveryConfig error:charId is not found, charId = " .. tostring(charId))
        return nil
    end

    return t
end

-- 获取构造体表情特效
function XDormConfig.GetMoodEffectConfig(id)
    local t = MoodEffectTemplate[id]
    if not t then
        XLog.Error("XDormConfig.GetMoodEffectConfig error:Id is not found, Id = " .. tostring(id))
        return nil
    end

    return t
end

-- 获取构造体对话配置表
function XDormConfig.GetCharacterDialogConfig(id)
    local t = CharacterDialogTemplate[id]
    if not t then
        XLog.Error("XDormConfig.GetCharacterDialogConfig error:Id is not found, Id = " .. tostring(id))
        return nil
    end

    return t
end

-- 获取构造体信息配置
function XDormConfig.GetCharacterStyleConfigById(id)
    local t = CharacterStyleTemplate[id]
    if not t then
        XLog.Error("XDormConfig.GetCharacterStyleConfigById error:id is not found, id = " .. tostring(id))
        return nil
    end

    return t
end

-- 获取构造体Q版头像(圆形)
function XDormConfig.GetCharacterStyleConfigQIconById(id)
    local t = CharacterStyleTemplate[id]
    if not t or not t.HeadRoundIcon then
        XLog.Error("XDormConfig.GetCharacterStyleConfigQIconById error:id is not found, id = " .. tostring(id))
        return nil
    end

    return t.HeadRoundIcon
end

-- 获取构造体Q版头像(圆形)
function XDormConfig.GetCharacterStyleConfigQSIconById(id)
    local t = CharacterStyleTemplate[id]
    if not t or not t.HeadIcon then
        XLog.Error("XDormConfig.GetCharacterStyleConfigQIconById error:id is not found, id = " .. tostring(id))
        return nil
    end

    return t.HeadIcon
end

-- 获取构造体性别类型
function XDormConfig.GetCharacterStyleConfigSexById(id)
    local t = CharacterStyleTemplate[id]
    if not t or not t.Type then
        XLog.Error("XDormConfig.GetCharacterStyleConfigSexById error:id is not found, id = " .. tostring(id))
        return nil
    end

    return t.Type
end

function XDormConfig.GetCharacterNameConfigById(id)
    local t = CharacterStyleTemplate[id]
    if not t then
        XLog.Error("XDormConfig.GetCharacterStyleConfigById error:id is not found, id = " .. tostring(id))
        return nil
    end

    return t.Name
end

-- 获取构造体爱抚配置表
function XDormConfig.GetCharacterFondleByCharId(characterId)
    local t = CharacterFondleTemplate[characterId]
    if not t then
        XLog.Error("XDormConfig.GetCharacterFondleByCharId error:id is not found, id = " .. tostring(characterId))
        return nil
    end

    return t
end

-- 获取构造体爱总次数
function XDormConfig.GetCharacterFondleCount(characterId)
    local t = XDormConfig.GetCharacterFondleByCharId(characterId)
    return t.MaxCount
end

-- 获取构造体爱恢复一次时间
function XDormConfig.GetCharacterFondleRecoveryTime(characterId)
    local t = XDormConfig.GetCharacterFondleByCharId(characterId)
    return t.RecoveryTime
end

-- 获取构造体事件客户表现表
function XDormConfig.GetCharacterShowEvent(id)
    local t = ChaarcterShowEventTemplate[id]
    if not t then
        XLog.Error("XDormConfig.GetCharacterShowEvent error:id is not found, id = " .. tostring(id))
        return nil
    end

    return t
end

-- 获取构造体事件状态
function XDormConfig.GetCharacterShowEventState(id)
    local t = XDormConfig.GetCharacterShowEvent(id)
    return t.State
end

-- 获取构造体心情状态
function XDormConfig.GetMoodStateByMoodValue(moodValue)
    local t

    for _, v in pairs(CharacterMoodTemplate) do
        if moodValue > v.MoodMinValue and moodValue <= v.MoodMaxValue then
            t = v
            break
        end
    end

    if not t then
        XLog.Error("XDormConfig.GetMoodStateByMoodValue moodValue:moodValue is not found, moodValue = " .. tostring(moodValue))
        return nil
    end

    return t
end

-- 获取构造体心情状态描述
function XDormConfig.GetMoodStateDesc(moodValue)
    local desc = ""

    for _, v in pairs(CharacterMoodTemplate) do
        if moodValue > v.MoodMinValue and moodValue <= v.MoodMaxValue then
            desc = v.Describe
            break
        end
    end

    return desc
end

-- 获取构造体心情状态颜色值
function XDormConfig.GetMoodStateColor(moodValue)
    local color = "FFFFFFFF"

    for _, v in pairs(CharacterMoodTemplate) do
        if moodValue > v.MoodMinValue and moodValue <= v.MoodMaxValue then
            color = v.Color
            break
        end
    end

    return XUiHelper.Hexcolor2Color(color)
end

-- 获取图纸商店跳转ID
function XDormConfig.GetDraftShopId()
    return XDormConfig.DORM_DRAFT_SHOP_ID
end


--获取对话表
function XDormConfig.GetCharacterDialog(charData, state)

    local charId = charData.CharacterId

    if not CharacterDialogStateIndex or not CharacterDialogStateIndex[charId] then
        XLog.Error("CharacterDialogStateIndex is null or charId not exist", charId)
        return
    end

    if not CharacterDialogStateIndex[charId][state] then
        XLog.Error("CharacterDialogStateIndex State not exist", charId, state)
        return
    end

    local dialogList = CharacterDialogStateIndex[charId][state]

    if not dialogList then
        return
    end

    local fitterList = {}

    for i, v in ipairs(dialogList) do
        if charData.Mood >= v.MoodMinValue and charData.Mood <= v.MoodMaxValue then
            table.insert(fitterList, v)
        end
    end

    if #fitterList <= 0 then
        return
    end

    math.randomseed(os.time())
    local index = math.random(0, #fitterList)

    return fitterList[index]

end

--获取套装的音乐信息
function XDormConfig.GetDormSuitBgmInfo(suitId)
    for i, v in pairs(DormBgmTemplate) do
        if v.SuitId == suitId then
            return v
        end
    end

    return nil
end

--获取背景音乐
function XDormConfig.GetDormBgm(furnitureList)
    local musicList = {}

    for i, v in pairs(DormBgmTemplate) do
        if v.SuitId == -1 then
            table.insert(musicList, v)
        end
    end


    if not furnitureList then
        return false, musicList
    end


    local suitDic = {}
    for i, v in pairs(furnitureList) do
        suitDic[v.SuitId] = suitDic[v.SuitId] or {}
        local isExist = false
        for idx, id in ipairs(suitDic[v.SuitId]) do
            if id == v.Id then
                isExist = true
                break
            end
        end

        if not isExist then
            table.insert(suitDic[v.SuitId], v.Id)
        end
    end


    for i, v in pairs(DormBgmTemplate) do
        if suitDic[v.SuitId] and #suitDic[v.SuitId] >= v.SuitNum then
            table.insert(musicList, v)
        end
    end


    if #musicList <= 1 then
        return false, musicList
    end


    table.sort(musicList, function(a, b)
        return a.Order > b.Order
    end)


    return true, musicList
end