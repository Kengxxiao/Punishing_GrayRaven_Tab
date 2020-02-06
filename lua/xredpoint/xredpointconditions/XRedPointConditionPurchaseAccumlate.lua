----------------------------------------------------------------
local XRedPointConditionPurchaseAccumlate = {}
local Events = nil

function XRedPointConditionPurchaseAccumlate.GetSubEvents()
    Events = Events or {
        XRedPointEventElement.New(XEventId.EVENT_ACCUMLATED_UPTATE),
        XRedPointEventElement.New(XEventId.EVENT_ACCUMLATED_REWARD)
    }
    return Events
end

function XRedPointConditionPurchaseAccumlate.Check()
    if XFunctionManager.CheckFunctionFitter(XFunctionManager.FunctionName.PurchaseAdd) then
        return false
    end
    return XDataCenter.PurchaseManager.AccumlatePayRedPoint()
end

return XRedPointConditionPurchaseAccumlate 