----------------------------------------------------------------
local XRedPointConditionPurchaseLB = {}
local Events = nil

function XRedPointConditionPurchaseLB.GetSubEvents()
    Events = Events or {
        XRedPointEventElement.New(XEventId.EVENT_LB_UPDATE),
    }
    return Events
end

function XRedPointConditionPurchaseLB.Check()
    return XDataCenter.PurchaseManager.LBRedPoint()
end

return XRedPointConditionPurchaseLB 