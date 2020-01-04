XBfrtConfigs = XBfrtConfigs or {}

local TABLE_BFRT_CHAPTER_PATH = "Share/Fuben/Bfrt/BfrtChapter.tab"
local TABLE_BFRT_GROUP_PATH = "Share/Fuben/Bfrt/BfrtGroup.tab"
local TABLE_ECHELON_INFO_PATH = "Share/Fuben/Bfrt/EchelonInfo.tab"

local BfrtChapterTemplates = {}
local BfrtGroupTemplates = {}
local EchelonInfoTemplates = {}

function XBfrtConfigs.Init( ... )
    BfrtChapterTemplates = XTableManager.ReadByIntKey(TABLE_BFRT_CHAPTER_PATH, XTable.XTableBfrtChapter, "ChapterId")
    BfrtGroupTemplates = XTableManager.ReadByIntKey(TABLE_BFRT_GROUP_PATH, XTable.XTableBfrtGroup, "GroupId")
    EchelonInfoTemplates = XTableManager.ReadByIntKey(TABLE_ECHELON_INFO_PATH, XTable.XTableEchelonInfo, "Id")
end

function XBfrtConfigs.GetBfrtChapterTemplates()
    return BfrtChapterTemplates
end

function XBfrtConfigs.GetBfrtGroupTemplates()
    return BfrtGroupTemplates
end

function XBfrtConfigs.GetEchelonInfoTemplates()
    return EchelonInfoTemplates
end