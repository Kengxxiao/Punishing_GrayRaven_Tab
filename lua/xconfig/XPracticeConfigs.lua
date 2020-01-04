XPracticeConfigs = XPracticeConfigs or {}

local CLIENT_PRACTICE_CHAPTERDETAIL = "Client/Fuben/Practice/PracticeChapterDetail.tab"
local CLIENT_PRACTICE_SKILLDETAIL = "Client/Fuben/Practice/PracticeSkillDetails.tab"

local SHARE_PRACTICE_CHAPTER = "Share/Fuben/Practice/PracticeChapter.tab"

local PracticeChapterDetails = {}
local PracticeSkillDetails = {}

local PracticeChapters = {}

XPracticeConfigs.PracticeMode = {
    Basics = 1,
    Advanced = 2,
    Character = 3,
}

function XPracticeConfigs.Init()
    PracticeChapterDetails = XTableManager.ReadByIntKey(CLIENT_PRACTICE_CHAPTERDETAIL, XTable.XTablePracticeChapterDetail, "Id")
    PracticeSkillDetails = XTableManager.ReadByIntKey(CLIENT_PRACTICE_SKILLDETAIL, XTable.XTablePracticeSkillDetails, "StageId")
    
    PracticeChapters = XTableManager.ReadByIntKey(SHARE_PRACTICE_CHAPTER, XTable.XTablePracticeChapter, "Id")
end

function XPracticeConfigs.GetPracticeChapters()
    return PracticeChapters
end

function XPracticeConfigs.GetPracticeChapterById(id)
    local currentChapter = PracticeChapters[id]

    if not currentChapter then
        XLog.Error("XPracticeConfigs.GetPracticeChapterById error not found by Id : " .. tostring(id))
        return 
    end

    return currentChapter
end

function XPracticeConfigs.GetPracticeChapterConditionById(id)
    local currentChapter = XPracticeConfigs.GetPracticeChapterById(id)
    return currentChapter.ConditionId
end

function XPracticeConfigs.GetPracticeChapterDetails()
    return PracticeChapterDetails
end

function XPracticeConfigs.GetPracticeChapterDetailById(id)
    local currentChapterDetail = PracticeChapterDetails[id]

    if not currentChapterDetail then
        XLog.Error("XPracticeConfigs.GetPracticeChapterDetailById error not found by Id : " .. tostring(id))
        return
    end

    return currentChapterDetail
end

function XPracticeConfigs.GetPracticeDescriptionById(id)
    local details = XPracticeConfigs.GetPracticeChapterDetailById(id)
    if not details then return "" end
    return details.Description or ""
end

function XPracticeConfigs.GetPracticeSkillDetailById(id)
    local currentDetail = PracticeSkillDetails[id]
    if not currentDetail then
        XLog.Error("XPracticeConfigs.GetPracticeSkillDetailById error not found by Id : " .. tostring(id))
        return 
    end
    return currentDetail
end
