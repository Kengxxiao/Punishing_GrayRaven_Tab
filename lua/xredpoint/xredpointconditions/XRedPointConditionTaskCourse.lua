----------------------------------------------------------------
--单个类型任务奖励检测
local XRedPointConditionTaskCourse = {}
local Events = nil
function XRedPointConditionTaskCourse.GetSubEvents()
    Events = Events or
    { 
        XRedPointEventElement.New(XEventId.EVENT_TASK_COURSE_REWAED),
    }
    return Events
end

function XRedPointConditionTaskCourse.Check()
    return XDataCenter.TaskManager.CheckAllCourseCanGet()
end

return XRedPointConditionTaskCourse