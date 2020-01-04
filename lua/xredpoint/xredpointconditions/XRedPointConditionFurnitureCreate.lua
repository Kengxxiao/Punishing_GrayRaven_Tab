--家具建造红点
local XRedPointConditionFurnitureCreate = {}
local Events = nil
function XRedPointConditionFurnitureCreate.GetSubEvents()
    Events =
        Events or
        {
            XRedPointEventElement.New(XEventId.EVENT_FURNITURE_CREATE_CHANGED),
        }
    return Events
end

function XRedPointConditionFurnitureCreate.Check()
    return XDataCenter.FurnitureManager.HasCollectableFurniture()
end

return XRedPointConditionFurnitureCreate
