XFestivalActivityConfig = {}

local SHARE_FESTIVAL = "Share/Fuben/Festival/FestivalActivity.tab"

local ShareFestival = {}


--活动名称Id
XFestivalActivityConfig.ActivityId = {
    Christmas = 1,
    MainLine = 2,
    NewYear = 3,
}

function XFestivalActivityConfig.Init()
    ShareFestival = XTableManager.ReadByIntKey(SHARE_FESTIVAL, XTable.XTableFestivalActivity, "Id")
end

function XFestivalActivityConfig.GetAllFestivals()
    local activityList = {}
    for k, v in pairs(ShareFestival) do
        table.insert(activityList, {
            Id = v.Id,
            Type = v.ChapterType,
            Name = v.Name,
            Icon = v.BannerBg,
        })
    end
    return activityList
end

function XFestivalActivityConfig.GetFestivalsTemplates()
    return ShareFestival
end

function XFestivalActivityConfig.GetFestivalById(id)
    local festivalDatas = ShareFestival[id]
    if not festivalDatas then
        XLog.Error("XFestivalActivityConfig.GetFestivalById error: not data found by id " .. tostring(id))
        return 
    end
    return festivalDatas
end