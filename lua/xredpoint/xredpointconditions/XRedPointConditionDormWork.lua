----------------------------------------------------------------
local XRedPointConditionDormWork = {}
local Events = nil
function XRedPointConditionDormWork.GetSubEvents()
    Events = Events or
    {
        XRedPointEventElement.New(XEventId.EVENT_DORM_WORK_REDARD),
    }
    return Events
end

function XRedPointConditionDormWork.Check()
    return XDataCenter.DormManager.DormWorkRedFun()
end

return XRedPointConditionDormWork