XHelpCourseConfig = {}

local TABLE_HELP_COURSE_PATH = "Client/HelpCourse/HelpCourse.tab"
local HelpCourseTemplate = {}
local HelpCourseTemplateIndex = {}

function XHelpCourseConfig.Init()
    HelpCourseTemplate = XTableManager.ReadByIntKey(TABLE_HELP_COURSE_PATH, XTable.XTableHelpCourse, "Id")
    for k,v in pairs(HelpCourseTemplate) do
        HelpCourseTemplateIndex[v.Function] = v
    end
 end

--获取帮助教程表
function XHelpCourseConfig.GetHelpCourseTemplate()
    return HelpCourseTemplate
end

--通过Id获取
function XHelpCourseConfig.GetHelpCourseTemplateById(id)
    if HelpCourseTemplate == nil then
        return
    end

    if not HelpCourseTemplate[id] then
        XLog.Error("HelpCourseTemplate can not found Id:"..tostring(id))
    end

    return HelpCourseTemplate[id]
end

--通过功能获取
function XHelpCourseConfig.GetHelpCourseTemplateByFunction(key)
    if HelpCourseTemplateIndex == nil then
        return
    end

    if not HelpCourseTemplateIndex[key] then
        XLog.Error("HelpCourseTemplateIndex can not found Function:"..tostring(key))
    end

    return HelpCourseTemplateIndex[key]
end