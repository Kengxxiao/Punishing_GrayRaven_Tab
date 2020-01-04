XFubenMainLineConfigs = XFubenMainLineConfigs or {}

local TABLE_CHAPTER_MAIN = "Share/Fuben/MainLine/ChapterMain.tab"
local TABLE_CHAPTER = "Share/Fuben/MainLine/Chapter.tab"
local TABLE_TREASURE = "Share/Fuben/MainLine/Treasure.tab"

local ChapterMainTemplates = {}
local ChapterCfg = {}
local TreasureCfg = {}

function XFubenMainLineConfigs.Init()
    ChapterMainTemplates = XTableManager.ReadByIntKey(TABLE_CHAPTER_MAIN, XTable.XTableChapterMain, "Id")
    ChapterCfg = XTableManager.ReadByIntKey(TABLE_CHAPTER, XTable.XTableChapter, "ChapterId")
    TreasureCfg = XTableManager.ReadByIntKey(TABLE_TREASURE, XTable.XTableTreasure, "TreasureId")
end

function XFubenMainLineConfigs.GetChapterMainTemplates()
    return ChapterMainTemplates
end

function XFubenMainLineConfigs.GetChapterCfg()
    return ChapterCfg
end

function XFubenMainLineConfigs.GetTreasureCfg()
    return TreasureCfg
end