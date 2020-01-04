----------------------------------------------------------------
local XRedPointConditionDormRed = {}
local SubCondition = nil
local Events = nil
function XRedPointConditionDormRed.GetSubConditions()
    SubCondition =
        SubCondition or
        {
            XRedPointConditions.Types.CONDITION_DORM_TASK,
            XRedPointConditions.Types.CONDITION_DORM_WORK_RED,
            XRedPointConditions.Types.CONDITION_FURNITURE_CREATE,
        }
    return SubCondition
end


function XRedPointConditionDormRed.Check()
    local red = XRedPointConditionDormWork.Check()
    if red then
        return true
    end

    red = XRedPointConditionFurnitureCreate.Check()
    if red then
        return true
    end
    red = XRedPointConditionDormTaskType.Check(XDataCenter.TaskManager.TaskType.DormNormal) or XRedPointConditionDormTaskType.Check(XDataCenter.TaskManager.TaskType.DormDaily)
    if red then
        return true
    end
    return false
end

return XRedPointConditionDormRed
