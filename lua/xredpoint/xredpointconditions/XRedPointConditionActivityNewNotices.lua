----------------------------------------------------------------
local XRedPointConditionActivityNewNotices = {}
local Events = nil

function XRedPointConditionActivityNewNotices.GetSubEvents()
    Events = Events or {
        XRedPointEventElement.New(XEventId.EVENT_ACTIVITY_NOTICE_READ_CHAGNE),
    }
    return Events
end

function XRedPointConditionActivityNewNotices.Check()
    return XDataCenter.NoticeManager.CheckRedPoint(1)
end

return XRedPointConditionActivityNewNotices