XExhibitionConfigs = XExhibitionConfigs or {}

local TABLE_CHARACTER_EXHIBITION = "Client/Exhibition/Exhibition.tab"
local TABLE_CHARACTER_EXHIBITION_LEVEL = "Client/Exhibition/ExhibitionLevel.tab"
local TABLE_CHARACTER_GROW_TASK_INFO = "Share/Exhibition/ExhibitionReward.tab"

local DefaultPortraitImagePath = CS.XGame.ClientConfig:GetString("DefaultPortraitImagePath")

local ExhibitionLevelPoint = {} 
local ExhibitionConfig = {}
local ExhibitionGroupNameConfig = {}
local ExhibitionGroupLogoConfig = {}
local ExhibitionGroupDescConfig = {}
local CharacterExhibitionLevelConfig = {}
local GrowUpTasksConfig = {}
local CharacterGrowUpTasksConfig = {}
local CharacterHeadPortrait = {}
local CharacterGraduationPortrait = {}

function XExhibitionConfigs.Init()
    CharacterExhibitionLevelConfig = XTableManager.ReadByIntKey(TABLE_CHARACTER_EXHIBITION_LEVEL, XTable.XTableExhibitionLevel, "LevelId")

    GrowUpTasksConfig = XTableManager.ReadByIntKey(TABLE_CHARACTER_GROW_TASK_INFO, XTable.XTableExhibitionReward, "Id")
    for task, v in pairs(GrowUpTasksConfig) do
        if CharacterGrowUpTasksConfig[v.CharacterId] == nil then
            CharacterGrowUpTasksConfig[v.CharacterId] = {}
        end
        CharacterGrowUpTasksConfig[v.CharacterId][task] = v
    end

    local exhibitionConfig = XTableManager.ReadByIntKey(TABLE_CHARACTER_EXHIBITION, XTable.XTableCharacterExhibition, "Id")
    for _, v in pairs(exhibitionConfig) do
        if v.Port ~= nil then
            ExhibitionConfig[v.Port] = v
            CharacterHeadPortrait[v.CharacterId] = v.HeadPortrait
            CharacterGraduationPortrait[v.CharacterId] = v.GraduationPortrait
            ExhibitionGroupNameConfig[v.GroupId] = v.GroupName
            ExhibitionGroupLogoConfig[v.GroupId] = v.GroupLogo
            ExhibitionGroupDescConfig[v.GroupId] = v.GroupDescription
        end
    end
    
    ExhibitionLevelPoint[1] = CS.XGame.ClientConfig:GetInt("ExhibitionLevelPoint_01")
    ExhibitionLevelPoint[2] = CS.XGame.ClientConfig:GetInt("ExhibitionLevelPoint_02")
    ExhibitionLevelPoint[3] = CS.XGame.ClientConfig:GetInt("ExhibitionLevelPoint_03")
    ExhibitionLevelPoint[4] = CS.XGame.ClientConfig:GetInt("ExhibitionLevelPoint_04")
end

function XExhibitionConfigs.GetDefaultPortraitImagePath()
    return DefaultPortraitImagePath
end

function XExhibitionConfigs.GetExhibitionConfig()
    return ExhibitionConfig
end

function XExhibitionConfigs.GetExhibitionGroupNameConfig()
    return ExhibitionGroupNameConfig
end

function XExhibitionConfigs.GetExhibitionGroupLogoConfig()
    return ExhibitionGroupLogoConfig
end

function XExhibitionConfigs.GetExhibitionGroupDescConfig()
    return ExhibitionGroupDescConfig
end

function XExhibitionConfigs.GetExhibitionLevelConfig()
    return CharacterExhibitionLevelConfig
end

function XExhibitionConfigs.GetCharacterGrowUpTasks(characterId)
    return CharacterGrowUpTasksConfig[characterId]
end

function XExhibitionConfigs.GetExhibitionLevelPoints()
    return ExhibitionLevelPoint
end

function XExhibitionConfigs.GetGrowUpLevelMax()
    local maxPoint = 0
    for i = 1,4 do
        maxPoint = maxPoint + ExhibitionLevelPoint[i]
    end
    return maxPoint
end

function XExhibitionConfigs.GetCharacterGrowUpTask(characterId, level)
    local levelTasks = XExhibitionConfigs.GetCharacterGrowUpTasks(characterId)
    for _, config in pairs(levelTasks) do
        if config.LevelId == level then
            return config
        end
    end
end

function XExhibitionConfigs.GetCharacterGrowUpTasksConfig()
    return CharacterGrowUpTasksConfig
end

function XExhibitionConfigs.GetExhibitionGrowUpLevelConfig(level)
    return CharacterExhibitionLevelConfig[level]
end

function XExhibitionConfigs.GetExhibitionLevelNameByLevel(level)
    return CharacterExhibitionLevelConfig[level].Name or ""
end

function XExhibitionConfigs.GetExhibitionLevelDescByLevel(level)
    return CharacterExhibitionLevelConfig[level].Desc or ""
end

function XExhibitionConfigs.GetExhibitionLevelIconByLevel(level)
    return CharacterExhibitionLevelConfig[level].LevelIcon or ""
end

function XExhibitionConfigs.GetCharacterHeadPortrait(characterId)
    return CharacterHeadPortrait[characterId]
end

function XExhibitionConfigs.GetCharacterGraduationPortrait(characterId)
    return CharacterGraduationPortrait[characterId]
end

function XExhibitionConfigs.GetGrowUpTasksConfig()
    return GrowUpTasksConfig
end