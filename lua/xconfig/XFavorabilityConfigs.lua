XFavorabilityConfigs = XFavorabilityConfigs or {}

XFavorabilityConfigs.RewardUnlockType = {
    FightAbility = 1,
    TrustLv = 2,
    CharacterLv = 3,
    Quality = 4,
}

XFavorabilityConfigs.InfoState = {
    Normal = 1,
    Avaliable = 2,
    Lock = 3,
}

XFavorabilityConfigs.StrangeNewsUnlockType = {
    TrustLv = 1,
    DormEvent = 2,
}

XFavorabilityConfigs.SoundEventType = {
    FirstTimeObtain = 1, -- 首次获得角色
    LevelUp = 2, -- 角色升级
    Evolve = 3, -- 角色进化
    GradeUp = 4, -- 角色升军阶
    SkillUp = 5, -- 角色技能升级
    WearWeapon = 6, -- 角色穿戴武器
    MemberJoinTeam = 7, --角色入队(队员)
    CaptainJoinTeam = 8, --角色入队（队长）
}

-- [礼物品质]
XFavorabilityConfigs.GiftQualityIcon = {
    [1] = CS.XGame.ClientConfig:GetString("CommonBagWhite"),
    [2] = CS.XGame.ClientConfig:GetString("CommonBagGreed"),
    [3] = CS.XGame.ClientConfig:GetString("CommonBagBlue"),
    [4] = CS.XGame.ClientConfig:GetString("CommonBagPurple"),
    [5] = CS.XGame.ClientConfig:GetString("CommonBagGold"),
    [6] = CS.XGame.ClientConfig:GetString("CommonBagRed"),
}

local TABLE_LIKE_BASEDATA = "Share/Trust/CharacterBaseData.tab"
local TABLE_LIKE_INFORMATION = "Share/Trust/CharacterInformation.tab"
local TABLE_LIKE_STORY = "Share/Trust/CharacterStory.tab"
local TABLE_LIKE_STRANGENEWS = "Share/Trust/CharacterStrangeNews.tab"
local TABLE_LIKE_TRUSTEXP = "Share/Trust/CharacterTrustExp.tab"
local TABLE_LIKE_TRUSTITEM = "Share/Trust/CharacterTrustItem.tab"
local TABLE_LIKE_VOICE = "Share/Trust/CharacterVoice.tab"
local TABLE_LIKE_LEVELCONFIG = "Share/Trust/FavorabilityLevelConfig.tab"

local TABLE_AUDIO_CV = "Client/Audio/Cv.tab"

local CharacterFavorabilityConfig = {}
local CharacterTrustExp = {}
local CharacterBaseData = {}
local CharacterInformation = {}
local CharacterInformationUnlockLv = {}
local CharacterRumors = {}
local CharacterVoice = {}
local CharacterVoiceUnlockLv = {}
local CharacterStory = {}
local CharacterStoryUnlockLv = {}
local CharacterSendGift = {}
local CharacterGiftReward = {}
local likeReward = {}

local AudioCV = {}

local DEFAULT_CV_TYPE = CS.XGame.Config:GetInt("DefaultCvType")

function XFavorabilityConfigs.Init()
    local baseData = XTableManager.ReadByIntKey(TABLE_LIKE_BASEDATA, XTable.XTableCharacterBaseData, "Id")
    for _, v in pairs(baseData) do
        if CharacterBaseData[v.CharacterId] == nil then
            CharacterBaseData[v.CharacterId] = {}
        end
        CharacterBaseData[v.CharacterId] = {
            CharacterId = v.CharacterId,
            ServerTime = v.BaseData[1],
            StartupTime = v.BaseData[2],
            Height = v.BaseData[3],
            Weight = v.BaseData[4],
            LoopType = v.BaseData[5],
            MentalAge = v.BaseData[6],
            Cast = v.Cast,
        }
    end

    local likeInformation = XTableManager.ReadByIntKey(TABLE_LIKE_INFORMATION, XTable.XTableCharacterInformation, "Id")
    for _, v in pairs(likeInformation) do
        if CharacterInformation[v.CharacterId] == nil then
            CharacterInformation[v.CharacterId] = {}
        end
        
        table.insert(CharacterInformation[v.CharacterId], {
            Id = v.Id,
            CharacterId = v.CharacterId,
            UnlockLv = v.UnlockLv,
            Title = v.Title,
            Content = v.Content,
            ConditionDescript = v.ConditionDescript
        })
        if CharacterInformationUnlockLv[v.CharacterId] == nil then
            CharacterInformationUnlockLv[v.CharacterId] = {}
        end
        CharacterInformationUnlockLv[v.CharacterId][v.Id] = v.UnlockLv
        
    end
    for characterId, characterDatas in pairs(CharacterInformation) do
        table.sort(characterDatas, function(infoA, infoB)
            if infoA.UnlockLv == infoB.UnlockLv then
                return infoA.Id < infoB.Id
            end
            return infoA.UnlockLv < infoB.UnlockLv
        end)
    end
    
    local likeStory = XTableManager.ReadByIntKey(TABLE_LIKE_STORY, XTable.XTableCharacterStory, "Id")
    for _, v in pairs(likeStory) do
        if CharacterStory[v.CharacterId] == nil then
            CharacterStory[v.CharacterId] = {}
        end
        table.insert(CharacterStory[v.CharacterId], {
            Id = v.Id,
            Name = v.Name,
            CharacterId = v.CharacterId,
            StoryId = v.StoryId,
            Icon = v.Icon,
            UnlockLv = v.UnlockLv,
            ConditionDescript = v.ConditionDescript,
            SectionNumber = v.SectionNumber,
        })

        if CharacterStoryUnlockLv[v.CharacterId] == nil then
            CharacterStoryUnlockLv[v.CharacterId] = {}
        end
        CharacterStoryUnlockLv[v.CharacterId][v.Id] = v.UnlockLv
    end
    for characterId, storys in pairs(CharacterStory) do
        table.sort(storys, function(storyA, storyB)
            if storyA.UnlockLv == storyB.UnlockLv then
                return  storyA.Id < storyB.Id
            end
            return storyA.UnlockLv < storyB.UnlockLv
        end)
    end

    local likeStrangeNews = XTableManager.ReadByIntKey(TABLE_LIKE_STRANGENEWS, XTable.XTableCharacterStrangeNews, "Id")
    for _, v in pairs(likeStrangeNews) do
        if CharacterRumors[v.CharacterId] == nil then
            CharacterRumors[v.CharacterId] = {}
        end

        table.insert(CharacterRumors[v.CharacterId], {
            Id = v.Id,
            CharacterId = v.CharacterId,
            Type = v.Type,
            UnlockType = v.UnlockType,
            Title = v.Title,
            Content = v.Content,
            Picture = v.Picture,
            UnlockPara = v.UnlockPara,
            ConditionDescript = v.ConditionDescript,
            PreviewPicture = v.PreviewPicture
        })
    end
    for characterId, strangeNews in pairs(CharacterRumors) do
        table.sort(strangeNews, function(strangeNewsA, strangeNewsB)
            return strangeNewsA.Id < strangeNewsB.Id
        end)
    end
    
    local likeTrustExp = XTableManager.ReadByIntKey(TABLE_LIKE_TRUSTEXP, XTable.XTableCharacterTrustExp, "Id")
    for _, v in pairs(likeTrustExp) do
        if CharacterTrustExp[v.CharacterId] == nil then
            CharacterTrustExp[v.CharacterId] = {}
        end
        CharacterTrustExp[v.CharacterId][v.TrustLv] = {
            Exp = v.Exp,
            Name = v.Name,
            PlayId = v.PlayId
        }
    end

    local likeTrustItem = XTableManager.ReadByIntKey(TABLE_LIKE_TRUSTITEM, XTable.XTableCharacterTrustItem, "Id")
    for _, v in pairs(likeTrustItem) do
        table.insert(CharacterSendGift, {
            Id = v.Id,
            Exp = v.Exp,
            FavorCharacterId = v.FavorCharacterId,
            FavorExp = v.FavorExp,
        })
    end
    
    local likeVoice = XTableManager.ReadByIntKey(TABLE_LIKE_VOICE, XTable.XTableCharacterVoice, "Id")
    for _, v in pairs(likeVoice) do
        if v.IsShow == 1 then
            if CharacterVoice[v.CharacterId] == nil then
                CharacterVoice[v.CharacterId] = {}
            end
            table.insert(CharacterVoice[v.CharacterId], {
                Id = v.Id,
                CharacterId = v.CharacterId,
                Name = v.Name,
                CvId = v.CvId,
                UnlockLv = v.UnlockLv,
                ConditionDescript = v.ConditionDescript,
                SoundType = v.SoundType,
                IsShow = v.IsShow,
            })
        end
        if CharacterVoiceUnlockLv[v.CharacterId] == nil then
            CharacterVoiceUnlockLv[v.CharacterId] = {}
        end
        CharacterVoiceUnlockLv[v.CharacterId][v.Id] = v.UnlockLv

    end
    for characterId, v in pairs(CharacterVoice) do
        table.sort(v, XFavorabilityConfigs.SortVoice)
    end

    CharacterFavorabilityConfig = XTableManager.ReadByIntKey(TABLE_LIKE_LEVELCONFIG, XTable.XTableFavorabilityLevelConfig, "Id")

    AudioCV = XTableManager.ReadByIntKey(TABLE_AUDIO_CV, XTable.XTableCv, "Id")
end

function XFavorabilityConfigs.SortVoice(a, b)
    if a.UnlockLv == b.UnlockLv then
        return a.Id < b.Id
    end
    return a.UnlockLv < b.UnlockLv
end

-- [好感度等级经验]
function XFavorabilityConfigs.GetTrustExpById(characterId)
    local trustExp = CharacterTrustExp[characterId]
    if not trustExp then
        XLog.Error("XFavorabilityConfigs.GetTrustExpById error: not data found by characterId " .. tostring(characterId))
        return 
    end
    return trustExp
end

-- [好感度基础数据]
function XFavorabilityConfigs.GetCharacterBaseDataById(characterId)
    local baseData = CharacterBaseData[characterId]
    if not baseData then
        XLog.Error("XFavorabilityConfigs.GetCharacterBaseDataById error: not data found by characterId " .. tostring(characterId))
        return 
    end
    return baseData
end

-- 获取cv名字
function XFavorabilityConfigs.GetCharacterCvById(characterId)
    local baseData = XFavorabilityConfigs.GetCharacterBaseDataById(characterId)
    if not baseData then return "" end

    local cvType = CS.UnityEngine.PlayerPrefs.GetInt("CV_TYPE", DEFAULT_CV_TYPE)
    if baseData.Cast and baseData.Cast[cvType] then return baseData.Cast[cvType] end
    return ""
end

-- [好感度档案-资料]
function XFavorabilityConfigs.GetCharacterInformationById(characterId)
    local information = CharacterInformation[characterId]
    if not information then
        XLog.Error("XFavorabilityConfigs.GetCharacterInformationById error: not data found by characterId " .. tostring(characterId))
        return 
    end
    return information
end

-- [好感度档案-资料解锁等级]
function XFavorabilityConfigs.GetCharacterInformationUnlockLvById(characterId)
    local informationUnlockDatas = CharacterInformationUnlockLv[characterId]
    if not informationUnlockDatas then
        XLog.Error("XFavorabilityConfigs.GetCharacterInformationUnlockLvById error: not data found by characterId " .. tostring(characterId))
        return 
    end
    return informationUnlockDatas
end

-- [好感度档案-异闻]
function XFavorabilityConfigs.GetCharacterRumorsById(characterId)
    local rumors = CharacterRumors[characterId]
    if not rumors then
        XLog.Error("XFavorabilityConfigs.GetCharacterRumorsById error: not data found by characterId " .. tostring(characterId))
        return 
    end
    return rumors
end

-- [好感度档案-语音]
function XFavorabilityConfigs.GetCharacterVoiceById(characterId)
    local voice = CharacterVoice[characterId]
    if not voice then
        XLog.Error("XFavorabilityConfigs.GetCharacterVoiceById error: not data found by characterId " .. tostring(characterId))
        return 
    end
    return voice
end

-- [好感度档案-语音解锁等级]
function XFavorabilityConfigs.GetCharacterVoiceUnlockLvsById(characterId)
    local voiceUnlockDatas = CharacterVoiceUnlockLv[characterId]
    if not voiceUnlockDatas then
        XLog.Error("XFavorabilityConfigs.GetCharacterVoiceUnlockLvsById error: not data found by characterId " .. tostring(characterId))
        return 
    end
    return voiceUnlockDatas
end

-- [好感度剧情]
function XFavorabilityConfigs.GetCharacterStoryById(characterId)
    local storys = CharacterStory[characterId]
    if not storys then
        XLog.Error("XFavorabilityConfigs.GetCharacterStoryById error: not data found by characterId " .. tostring(characterId))
        return 
    end
    return storys
end

-- [好感度剧情解锁等级]
function XFavorabilityConfigs.GetCharacterStoryUnlockLvsById(characterId)
    local storyUnlockDatas = CharacterStoryUnlockLv[characterId]
    if not storyUnlockDatas then
        XLog.Error("XFavorabilityConfigs.GetCharacterStoryUnlockLvsById error: not data found by characterId " .. tostring(characterId))
        return 
    end
    return storyUnlockDatas
end

-- [好感度礼物-送礼]
function XFavorabilityConfigs.GetAllCharacterSendGift()
    if not CharacterSendGift then
        XLog.Error("XFavorabilityConfigs.GetAllCharacterSendGift error: not data found")
        return
    end
    return CharacterSendGift
end

-- [好感度礼物-奖励]
function XFavorabilityConfigs.GetCharacterGiftRewardById(characterId)
    local giftReward = CharacterGiftReward[characterId]
    if not giftReward then
        XLog.Error("XFavorabilityConfigs.GetCharacterGiftRewardById error: not data found by characterId " .. tostring(characterId))
        return
    end
    return giftReward
end

function XFavorabilityConfigs.GetLikeRewardById(rewardId)
    if not likeReward then
        XLog.Error("XFavorabilityConfigs.GetLikeRewardById error: not data found by rewardId " .. tostring(rewardId))
        return 
    end
    return  likeReward[rewardId]
end

function XFavorabilityConfigs.GetFavorabilityLevelCfg(level)
    local cfgs = CharacterFavorabilityConfig[level]
    if not cfgs then
        XLog.Error("XFavorability.GetFavorability error: not data found by level " .. tostring(level))
    end
    return cfgs
end

-- CharacterFavorabilityConfig
-- [好感度-等级名字]
function XFavorabilityConfigs.GetWordsWithColor(trustLv, name)
    local color = XFavorabilityConfigs.GetFavorabilityLevelCfg(trustLv).WordColor
    return string.format("<color=%s>%s</color>", color, name)
end

-- [好感度-名字-称号]
function XFavorabilityConfigs.GetCharacterNameWithTitle(name, title)
    return string.format("%s <size=36>%s</size>", name, title)
end

-- [好感度-等级图标]
function XFavorabilityConfigs.GetTrustLevelIconByLevel(level)
    return XFavorabilityConfigs.GetFavorabilityLevelCfg(level).LevelIcon
end

-- [好感度-品质图标]
function XFavorabilityConfigs.GetQualityIconByQuality(quality)
    if quality == nil or XFavorabilityConfigs.GiftQualityIcon[quality] == nil then
        return XFavorabilityConfigs.GiftQualityIcon[1]
    end
    return XFavorabilityConfigs.GiftQualityIcon[quality]
end

function XFavorabilityConfigs.GetCvContent(cvId)
    local cvData = AudioCV[cvId]
    if not cvData then return "" end
    return cvData.CvContent[1] or ""
end

function XFavorabilityConfigs.GetMaxFavorabilityLevel(characterId)
    local characterFavorabilityLevelDatas = CharacterTrustExp[characterId]
    if not characterFavorabilityLevelDatas then 
        XLog.Error("XFavorabilityConfigs.GetMaxFavorabilityLevel not found by characterId " .. tostring(characterId))
        return 
    end
    local maxLevel = 1
    for trustLv, levelDatas in pairs(characterFavorabilityLevelDatas) do
        if levelDatas.Exp == 0 then
            maxLevel = trustLv
            break
        end
    end

    return maxLevel
end