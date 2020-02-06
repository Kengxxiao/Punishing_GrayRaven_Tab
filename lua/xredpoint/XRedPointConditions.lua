
XRedPointConditionGroup  = require("XRedPoint/XRedPointConditionGroup")
XRedPointEvent = require("XRedPoint/XRedPointEvent")
XRedPointListener = require("XRedPoint/XRedPointListener")
XRedPointEventElement = require("XRedPoint/XRedPointEventElement")

XRedPointConditions = XRedPointConditions or { }
XRedPointConditions.Conditions = {
    --角色界面红点相关UiCharacter-----------------------------------------------
    CONDITION_CHARACTER          = "XRedPointConditionCharacter",          --角色列表红点，培养
    CONDITION_CHARACTER_GRADE    = "XRedPointConditionCharacterGrade",     --晋升标签
    CONDITION_CHARACTER_QUALITY  = "XRedPointConditionCharacterQuality",   --升品标签
    CONDITION_CHARACTER_SKILL    = "XRedPointConditionCharacterSkill",     --技能标签
    CONDITION_CHARACTER_LEVEL    = "XRedPointConditionCharacterLevel",     --升级标签
    CONDITION_CHARACTER_UNLOCK   = "XRedPointConditionCharacterUnlock",    --解锁

    --好友红点相关 UiSocial-----------------------------------------------
    CONDITION_FRIEND_WAITPASS     = "XRedPointConditionFriendWaitPass",    --等待通过
    CONDITION_FRIEND_CONTACT      = "XRedPointConditionFriendContact",     --私聊信息标签
    CONDITION_FRIEND_CHAT_PRIVATE = "XRedPointConditionFriendChatPrivate", --个人私聊信息

    --邮件红点相关 UiMail-----------------------------------------------
    CONDITION_MAIL_PERSONAL       = "XRedPointConditionMailPersonal", --邮件

    --主界面红点相关 UiMain-----------------------------------------------
    CONDITION_MAIN_MEMBER         = "XRedPointConditionMainMember",  --成员
    CONDITION_MAIN_FRIEND         = "XRedPointConditionMainFriend",  --好友
    CONDITION_MAIN_NOTICE         = "XRedPointConditionMainNotice",  --活动系统
    CONDITION_MAIN_MAIL           = "XRedPointConditionMainMail",    --邮件
    CONDITION_MAIN_NEWPLAYER_TASK = "XRedPointConditionMainNewPlayerTask", --新手任务
    CONDITION_MAIN_TASK           = "XRedPointConditionMainTask", --任务
    CONDITION_MAIN_CHAPTER        = "XRedPointConditionMainChapter", --主线副本
    CONDITION_BASEEQUIP          = "XRedPointConditionBaseEquip",--基地装备
    CONDITION_MAIN_DISPATCH       = "XRedPointConditionMainDispatch",--派遣  

    --玩家红点相关 UiPlayer-----------------------------------------------
    CONDITION_PLAYER_SETNAME = "XRedPointConditionPlayerSetName",
    CONDITION_PLAYER_ACHIEVE      = "XRedPointConditionPlayerAchieve",  --成就标签
    CONDITION_PLAYER_ACHIEVE_TYPE     = "XRedPointConditionPlayerAchieveType",  --各类型成就标签

    --玩家任务红点相关 UiTask-----------------------------------------------
    CONDITION_TASK_TYPE       = "XRedPointConditionTaskType",  --是否有对应类型的任务奖励
    CONDITION_TASK_COURSE     = "XRedPointConditionTaskCourse",  --是否有历程任务奖励
    CONDITION_TASK_WEEK_ACTIVE     = "XRedPointConditionTaskWeekActive",  --是否有周活跃任务奖励
    --赏金任务
    CONDITION_BOUNTYTASK     = "XRedPointConditionBountyTask",  --是否有赏金任务奖励
    --竞技
    CONDITION_ARENA_APPLY = "XRedPointConditionArenaApply", --是否有申请数据

    --玩家章节红点相关 UiFuBen-----------------------------------------------
    CONDITION_MAINLINE_CHAPTER_REWARD    = "XRedPointConditionChapterReward",  --是否有主线章节进度奖励
    CONDITION_BFRT_CHAPTER_REWARD    = "XRedPointConditionBfrtChapterReward",  --是否有据点战章节进度奖励

    -- 好感度
    CONDITION_FAVORABILITY_RED = "XRedPointConditionFavorability",--好感度红点
    CONDITION_FAVORABILITY_DOCUMENT = "XRedPointConditionFavorabilityDocument",--好感度-档案
    CONDITION_FAVORABILITY_DOCUMENT_INFO = "XRedPointConditionFavorabilityInfo",--好感度-档案-资料
    CONDITION_FAVORABILITY_DOCUMENT_RUMOR = "XRedPointConditionFavorabilityRumor",--好感度-档案-异闻
    CONDITION_FAVORABILITY_DOCUMENT_AUDIO = "XRedPointConditionFavorabilityAudio",--好感度-档案-语音
    CONDITION_FAVORABILITY_PLOT = "XRedPointConditionFavorabilityPlot",--好感度-剧情
    CONDITION_FAVORABILITY_GIFT = "XRedPointConditionFavorabilityGift",--好感度-礼物
    -- 试炼
    CONDITION_TRIAL_RED = "XRedPointConditionTrial",--试炼关卡奖励
    CONDITION_TRIAL_REWARD_RED = "XRedPointConditionTrialReward",--试炼关卡奖励
    CONDITION_TRIAL_UNLOCK_RED = "XRedPointConditionTrialUnlock",--试炼关卡解锁

    -- 探索
    CONDITION_EXPLORE_REWARD = "XRedPointConditionExplore",--是否有探索奖励可领取

    --竞技
    CONDITION_ARENA_MAIN_TASK = "XRedPointConditionArenaTask", --竞技战区任务

    --展示厅
    CONDITION_EXHIBITION_NEW = "XRedPointConditionExhibitionNew", --构造展示厅奖励可领取

    --活动系统
    CONDITION_ACTIVITY_NEW_ACTIVITIES = "XRedPointConditionActivityNewAcitivies", --活动系统-新活动
    CONDITION_ACTIVITY_NEW_NOTICES = "XRedPointConditionActivityNewNotices", --活动系统-新公告
    CONDITION_ACTIVITY_NEW_ACTIVITY_NOTICES = "XRedPointConditionActivityNewActivityNotices", --活动系统-新活动公告

    --单机Boss奖励
    CONDITION_BOSS_SINGLE_REWARD = "XRedPointConditionBossSingleReward", --单机Boss奖励领取

    --充值
    CONDITION_PURCHASE_RED = "XRedPointConditionPurchase",
    CONDITION_PURCHASE_LB_RED = "XRedPointConditionPurchaseLB",
    CONDITION_PURCHASE_GET_RERARGE = "XRedPointConditionGetFirstRecharge",   -- 是否有首充奖励领取
    CONDITION_PURCHASE_GET_CARD = "XRedPointConditionGetCard",   -- 是否有月卡奖励领取
    CONDITION_ACCUMULATEPAY_RED = "XRedPointConditionPurchaseAccumlate",   -- 是否有累计奖励领取
    --宿舍红点
    CONDITION_DORM_RED = "XRedPointConditionDormRed",   -- 宿舍红点
    CONDITION_DORM_TASK = "XRedPointConditionDormTaskType",   -- 是否有奖励领取
    CONDITION_FURNITURE_CREATE = "XRedPointConditionFurnitureCreate",   --是否有家具可以领取  
    CONDITION_DORM_WORK_RED = "XRedPointConditionDormWork",   -- 宿舍打工
    CONDITION_DORM_MAIN_TASK_RED = "XRedPointConditionDormMainTaskRed",   -- 是否有奖励领取(宿舍主界面)
    
    --研究红点
    CONDITION_ACTIVITYDRAW_RED = "XRedPointActivityDrawNew",   -- 研究活动卡池红点
    
    --头像红点
    CONDITION_HEADPORTRAIT_RED = "XRedPointConditionHeadPortraitNew",
    --勋章红点
    CONDITION_MEDAL_RED = "XRedPointConditionMedalNew",

    --活动简介红点
    CONDITION_ACTIVITY_BRIRF_TASK_FINISHED = "XRedPointConditionActivityBriefTaskFinished", --活动简介任务完成
}

--注册所有条件
function XRedPointConditions.RegisterAllConditions()
    if not XRedPointConditions.Conditions then
        return 
    end

    XRedPointConditions.Types = { }
    for key,value in pairs(XRedPointConditions.Conditions) do
        local m = require("XRedPoint/XRedPointConditions/"..value)
        _G[value] = m
        XRedPointConditions[key] = m
        XRedPointConditions.Types[key] = key
    end
end 

XRedPointConditions.RegisterAllConditions()