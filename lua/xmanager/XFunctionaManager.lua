local table = table


local tableInsert = table.insert
local tableSort = table.sort


XFunctionManager = XFunctionManager or {}

local UI_MAIN = "UiMain"
local TABLE_SECONDARY_FUNCTIONAL_PATH = "Client/Functional/SecondaryFunctional.tab"
local TABLE_SKIP_FUNCTIONAL_PATH = "Client/Functional/SkipFunctional.tab"
local TABLE_FUNCTIONAL_OPEN = "Share/Functional/FunctionalOpen.tab"
local TABLE_MAIN_AD = "Client/Functional/MainAd.tab"
local TABLE_MAIN_ACTIVITY_SKIP_PATH = "Client/Functional/MainActiviitySkip.tab"

local TIP_MSG_SHOW_TIME = 2500
local SecondaryFunctionalTemplates = {}  --二级功能配置
local SkipFunctionalTemplates = {}  --跳转功能表
local FunctionalOpenTemplates = {}  --功能开启表
local MainAdTemplates = {}          --广告栏
local MainActivitySkipTemplates = {} --活动便捷入口
local SelfTime = nil
local ShieldFuncList = {}

XFunctionManager.IsOpen = false

XFunctionManager.SkipOrigin = {
    System = 1,         -- 系统来源
    SonSystem = 2,      -- 子系统来源
    Section = 3,        -- 副本来源
    Main = 4,           -- 主界面
    Webpage = 5,        -- 网页
    SystemWithArgs = 6, -- 跳转特定标签页的系统
    Custom = 7,         -- 跳转自定义系统（大部分副本）
    Dormitory = 8,      -- 跳转宿舍
}

XFunctionManager.OpenCondition = {
    Default = 0, -- 默认
    TeamLevel = 1, -- 战队等级
    FinishSection = 2, -- 通关副本
    FinishTask = 3, -- 完成任务
    FinishNoob = 4, -- 完成新手
    Main = 5, -- 掉线返回主界面
}

XFunctionManager.OpenHint = {
    TeamLevelToOpen,
    CopyToOpen,
    FinishToOpen
}

XFunctionManager.FunctionName = {
    SkipTarget = 1, --目标
    SkipObligate = 2, --预留
    SkipRecharge = 3, --充值
    SkipSetting = 4, --设置
    SkipSignIn = 5, --签到
    SkipWelfare = 7, --福利
    SkipFeedBack = 6, --反馈
    ExchangeCode = 8, --兑换码

    Character = 101, --构造体
    CharacterGrade = 102, --构造体晋升
    CharacterQuality = 103, --构造体进化
    CharacterSkill = 104, --构造体技能
    CharacterExhibition = 105, --构造体展示厅

    Equip = 201, --装备
    EquipStrengthen = 202, --装备强化
    EquipResonance = 203, --装备共鸣
    EquipStrengthenAutoSelect = 204, --装备一键强化

    Bag = 301, --背包
    DrawCard = 401, --研发
    DrawCardEquip = 402, --研发装备
    ActivityDrawCard = 403,--活动研发
    Task = 501, --任务
    TaskDay = 503, --任务每日
    TaskActivity = 504, --任务活动
    TaskWeekly = 505, --任务每周
    Player = 601, --战队
    PlayerBrand = 602, --战队烙印
    PlayerAchievement = 603, --战斗成就
    Mail = 701, --邮件
    SocialFriend = 801, --好友
    SocialChat = 802, --聊天
    Domitory = 901, --基建
    LivingQuarters = 902, --宿舍
    ShopCommon = 1001, --普通商店
    ShopActive = 1002, --活动商店
    Dispatch = 1201, --派遣
    BountyTask = 1301, --赏金
    OtherHelp = 2001, --助战

    FubenDifficulty = 10102, --副本困难
    FubenNightmare = 10103, --据点战
    FubenChallenge = 10201, --挑战副本
    FubenChallengeTower = 10202, --挑战爬塔
    FubenChallengeBossSingle = 10203, --挑战单机Boss
    FubenChallengeTrial = 1601, --试炼玩法
    
    ActivityBrief = 10300, --活动简介
    FubenActivity = 10301, --活动副本
    FubenActivityOnlineBoss = 10302, --活动联机boss
    FubenActivityBranch = 10303, --活动支线
    FubenActivitySingleBoss = 10304, --活动单挑boss
    FubenActivityTrial = 10305, --试验区
    FubenActivityFestival = 10306, --节日活动
    BabelTower = 10307,--巴别塔计划
    FubenActivityMainLine = 10308, --活动主线

    FubenDaily = 10401, --日常副本
    FubenDailyYSHTX = 10402, --日常意识海特训
    FubenDailyEMEX = 10403, --日常EMEX行动
    FubenDailyResource = 10404, --日常资源副本
    FubenExplore = 10405, --探索
    FubenDailyGZTX= 10406, --日常構造體特訓
    FubenDailyXYZB= 10407, --日常稀有裝備
    FubenDailyTPCL= 10408, --日常突破材料
    FubenDailyZBJY= 10409, --日常裝備經驗
    FubenDailyLMDZ= 10410, --日常螺母大戰
    FubenDailyJNQH= 10411, --日常技能强化

    FubenArena = 10204, -- 竞技

    FavorabilityMain = 1400, --好感度
    FavorabilityFile = 1401, --好感度-档案
    FavorabilityStory = 1402, --好感度-剧情
    FavorabilityGift = 1403, --好感度-礼物
    FavorabilityComeAcross = 1404, --好感度-偶遇

    CustomUi = 1501, --自定义控件

    Prequel = 1701, --断章
    Practice = 1800, --教学

    Trophy = 2100, --战利品（暂定）
    Medal = 2101,--勋章

    FestivalActivity = 10306,--节日活动
    PurchaseAdd = 3000,--累计充值
}

XFunctionManager.FunctionType = {
    System = 1,
    Stage = 2,
}

function XFunctionManager.InitData(data)
    ShieldFuncList = data
end

function XFunctionManager.Init()
    SecondaryFunctionalTemplates = XTableManager.ReadByIntKey(TABLE_SECONDARY_FUNCTIONAL_PATH, XTable.XTableSecondaryFunctional, "Id")
    SkipFunctionalTemplates = XTableManager.ReadByIntKey(TABLE_SKIP_FUNCTIONAL_PATH, XTable.XTableSkipFunctional, "SkipId")
    local mainAdTemplates = XTableManager.ReadByIntKey(TABLE_MAIN_AD, XTable.XTableMainAd, "Id")
    local listOpenFunctional = XTableManager.ReadByIntKey(TABLE_FUNCTIONAL_OPEN, XTable.XTableFunctionalOpen, "Id")
    MainActivitySkipTemplates = XTableManager.ReadByIntKey(TABLE_MAIN_ACTIVITY_SKIP_PATH, XTable.XTableMainActiviitySkip, "Id")

    for k, v in pairs(mainAdTemplates) do
        if not MainAdTemplates[v.ChannelId] then
            MainAdTemplates[v.ChannelId] = {}
        end

        tableInsert(MainAdTemplates[v.ChannelId], v)
    end

    MainAdTemplates = XReadOnlyTable.Create(MainAdTemplates)

    for k, v in pairs(listOpenFunctional) do
        local IsHasCondition = false

        for index,id in pairs(v.Condition) do
            if id ~= 0 then
                IsHasCondition = true
            end
        end

        if IsHasCondition then
            FunctionalOpenTemplates[k] = v
        end
    end

    XFunctionManager.IsOpen = false
end

function XFunctionManager.GetSecondaryFunctionalList()
    local list = {}
    for _, v in pairs(SecondaryFunctionalTemplates) do
        tableInsert(list, v)
    end
    --排序优先级
    table.sort(list, function(a, b)
        if a.Priority ~= b.Priority then
            return a.Priority < b.Priority
        end
    end)
    return list
end

function XFunctionManager.GetMainAdList()
    local channelId = 0

    if XUserManager.Channel == XUserManager.CHANNEL.HERO then
        channelId = CS.XHeroSdkAgent.GetChannelId()
    end

    local list = {}
    local templates = MainAdTemplates[channelId]

    if not templates then
        templates = MainAdTemplates[0]
    end

    for _, v in pairs(templates) do
        tableInsert(list, v)
    end

    tableSort(list, function(a, b)
        if a.Priority ~= b.Priority then
            return a.Priority < b.Priority
        end
    end)

    return list
end

--检测是否可以过滤该功能
function XFunctionManager.CheckFunctionFitter(id)
    if not ShieldFuncList or #ShieldFuncList <= 0 then
        return false
    end

    for index,v in ipairs(ShieldFuncList) do
        if v == id then
            return true
        end
    end


    return false
end

--界面跳转
function XFunctionManager.SkipInterface(id)
    local list = SkipFunctionalTemplates[id]
    if id == 0 then
        return
    end
    if list == nil then
        XLog.Error("XFunctionManager.GetSkipChanges error: can not found list, id = " .. tostring(id))
        return
    end

    if list.FunctionalId ~= nil and list.FunctionalId ~= 0 then
        -- 屏蔽功能
        if XFunctionManager.CheckFunctionFitter(list.FunctionalId) then
            XUiManager.TipMsg(CS.XTextManager.GetText("FunctionalMaintain"))
            return
        end

        if not XFunctionManager.DetectionFunction(list.FunctionalId) then
            return
        end
        
    end

    if list.Origin == XFunctionManager.SkipOrigin.System then
        if XLuaUiManager.IsUiShow(list.UiName) then
            return
        end

        XLuaUiManager.Open(list.UiName)
    end

    if list.Origin == XFunctionManager.SkipOrigin.SonSystem then
        if XLuaUiManager.IsUiShow(list.UiName) then
            return
        end

        if list.UiName == "UiCharacter" then
            XLuaUiManager.Open(list.UiName, list.ParamId, nil, nil, nil, true)
        elseif list.UiName == "UiPrequel" then
            XLuaUiManager.Open(list.UiName, list.ParamId)
        else
            XLuaUiManager.Open(list.UiName, list.ParamId)
        end
    end

    if list.Origin == XFunctionManager.SkipOrigin.Section then
        XDataCenter.FubenManager.GoToFuben(list.ParamId)
    end

    if list.Origin == XFunctionManager.SkipOrigin.Main then
        if XLuaUiManager.IsUiShow("UiMain") then
            return
        end

        XLuaUiManager.RunMain()
    end

    if list.Origin == XFunctionManager.SkipOrigin.SystemWithArgs then
        XDataCenter.FunctionalSkipManager.SkipSystemWidthArgs(list)
        return
    end

    if list.Origin == XFunctionManager.SkipOrigin.Custom then
        XDataCenter.FunctionalSkipManager.SkipCustom(list)
        return
    end

    if list.Origin == XFunctionManager.SkipOrigin.Dormitory then
        XDataCenter.FunctionalSkipManager.SkipDormitory(list)
        return
    end

    if list.Origin == XFunctionManager.SkipOrigin.Webpage then

    end
end

function XFunctionManager.GetSkipList(id)
    if SkipFunctionalTemplates[id] then
        return SkipFunctionalTemplates[id]
    end
end

function XFunctionManager.GetUiName(id)
    local uiName = SkipFunctionalTemplates[id].UiName
    if uiName == nil then
        XLog.Error("XFunctionManager.GetUiName error: can not found UiName, id = " .. id)
    end
    return uiName
end

function XFunctionManager.GetExplain(id)
    local explain = SkipFunctionalTemplates[id].Explain
    if explain == nil then
        XLog.Error("XFunctionManager.GetExplain error: can not found Explain, id = " .. id)
    end
    return explain
end

function XFunctionManager.GetParamId(id)
    local paramId = SkipFunctionalTemplates[id].ParamId
    if paramId == nil then
        XLog.Error("XFunctionManager.GetParamId error: can not found ParamId, id = " .. id)
    end
    return paramId
end

function XFunctionManager.IsCanSkip(skipId)
    local list = XFunctionManager.GetSkipList(skipId)
    if not list then return false end
    return XFunctionManager.JudgeCanOpen(list.FunctionalId)
end

--功能开启
function XFunctionManager.GetFuntionOpenList(id)
    --获取表
    local openList = FunctionalOpenTemplates[id]
    if openList == nil then
        return
    end
    return openList
end

function XFunctionManager.JudgeOpen(id)
    --判断是否开启功能
    if not FunctionalOpenTemplates[id] then
        return true
    end

    return XPlayer.IsMark(id)
end

function XFunctionManager.GetFunctionOpenCondition(id)
    --获取开启条件说明
    local isOpen = true
    local decs = ""
    if FunctionalOpenTemplates[id] == nil then
        return decs
    end

    for k,v in pairs(FunctionalOpenTemplates[id].Condition) do
        if v and v ~= 0 then
            isOpen,decs = XConditionManager.CheckCondition(v)
            if not isOpen then
                break
            end
        end
    end

    return decs

end

function XFunctionManager.JudgeCanOpen(id)
    -- 判断是否能开启
    local isOpen = true
    local decs = ""
    -- 如果没有配置应该返回true
    if FunctionalOpenTemplates[id] == nil then
        return true
    end

    for k,v in pairs(FunctionalOpenTemplates[id].Condition) do
        if v and v ~= 0 then
            isOpen,decs = XConditionManager.CheckCondition(v)
            if not isOpen then
                break
            end
        end
    end

    return isOpen
end

function XFunctionManager.DetectionFunction(functionNameId)
    --判断能否进入功能按钮
    if not XFunctionManager.JudgeCanOpen(functionNameId) then
        XUiManager.TipError(XFunctionManager.GetFunctionOpenCondition(functionNameId))
        return false
    end
    return true
end

function XFunctionManager.HandlerUiOpen(show, uiName)
    if show then
        if uiName ~= "UiHud" and uiName ~= "UiLogin" then
            XFunctionManager.CheckOpen()
        end
    end
end


local CanOpenId = {}

function XFunctionManager.CheckOpen()
    --开启功能
    local openList = {}

    for k, v in pairs(FunctionalOpenTemplates) do
        tableInsert(openList, k)
    end

    table.sort(openList, function(a, b)
        if FunctionalOpenTemplates[a].Priority ~= FunctionalOpenTemplates[b].Priority then
            return FunctionalOpenTemplates[a].Priority < FunctionalOpenTemplates[b].Priority
        end
    end)


    for i = 1, #openList do
        if not XFunctionManager.JudgeOpen(openList[i]) then
            if XFunctionManager.JudgeCanOpen(openList[i]) then

                XPlayer.ChangeMarks(openList[i])
                if XFunctionManager.GetOpenHint(openList[i]) == 1 then
                    tableInsert(CanOpenId, openList[i])
                end
            end
        end
    end

end


--获取功能开启提醒方式
function XFunctionManager.ShowOpenHint()
    if not CanOpenId or #CanOpenId <= 0 then
        return false
    end

    for i = 1, #CanOpenId do
        if XFunctionManager.GetOpenHint(CanOpenId[i]) == 1 then
            XLuaUiManager.Open("UiHintFunctional", CanOpenId)
            XFunctionManager.IsOpen = true
            CanOpenId = {}
            return true
        end
    end

    return false
end


--获取功能开启提醒方式
function XFunctionManager.GetOpenHint(id)
    return FunctionalOpenTemplates[id].Hint
end

--获取功能名字
function XFunctionManager.GetFunctionalName(id)
    return FunctionalOpenTemplates[id].Name
end

--获取功能类型
function XFunctionManager.GetFunctionalType(id)
    return FunctionalOpenTemplates[id].Type
end

--获取npc名字
function XFunctionManager.GetNpcName(id)
    return FunctionalOpenTemplates[id].NpcName
end

--获取npc头像
function XFunctionManager.GetNpcHandIcon(id)
    return FunctionalOpenTemplates[id].NpcHandIcon
end

--获取npc半身像
function XFunctionManager.GetNpcHalfIcon(id)
    return FunctionalOpenTemplates[id].NpcHalfIcon
end

--活动跳转相关 begin
function XFunctionManager.CheckSkipActivityOpen()
    local template = MainActivitySkipTemplates[1]
    local stageType = template.StageType
    local stageTypes = XDataCenter.FubenManager.StageType

    if stageType == stageTypes.Mainline then
        return XDataCenter.FubenMainLineManager.IsMainLineActivityOpen()
    elseif stageType == stageTypes.ActivtityBranch then
        return XDataCenter.FubenActivityBranchManager.IsOpen()
    elseif stageType == stageTypes.ActivityBossSingle then
        return XDataCenter.FubenActivityBossSingleManager.IsOpen()
    end

    return false
end

function XFunctionManager.SkipToActivity()
    if not XFunctionManager.CheckSkipActivityOpen() then
        return
    end

    local skipId = MainActivitySkipTemplates[1].SkipId
    if not skipId then
        return
    end

    XFunctionManager.SkipInterface(skipId)
end

function XFunctionManager.GetSkipToActivityIcon()
    return MainActivitySkipTemplates[1].Icon
end
--活动跳转相关 end