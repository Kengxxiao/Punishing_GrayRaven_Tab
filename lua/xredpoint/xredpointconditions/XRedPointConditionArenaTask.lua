----------------------------------------------------------------
-- 竞技任务领取检测
local XRedPointConditionArenaTask = {}

function XRedPointConditionArenaTask.Check()
    local dailyTasks = XDataCenter.TaskManager.GetArenaChallengeTaskList()
    for _, dailyTask in ipairs(dailyTasks) do
        if dailyTask.State == XDataCenter.TaskManager.TaskState.Achieved then
            return true
        end
    end

    return false
end

return XRedPointConditionArenaTask