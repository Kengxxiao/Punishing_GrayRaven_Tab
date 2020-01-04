----------------------------------------------------------------
--单个邮件检测
local XRedPointConditionMailPersonal = {}
local Events = nil
function XRedPointConditionMailPersonal.GetSubEvents()
    Events = Events or
    {
        XRedPointEventElement.New(XEventId.EVENT_MAIL_SYNC),
        XRedPointEventElement.New(XEventId.EVENT_MAIL_GET_ALL_MAIL_REWARD),
        XRedPointEventElement.New(XEventId.EVENT_MAIL_DELETE),
        XRedPointEventElement.New(XEventId.EVENT_MAIL_READ),
        XRedPointEventElement.New(XEventId.EVENT_MAIL_GET_MAIL_REWARD),
    }
    return Events
end

function XRedPointConditionMailPersonal.Check(mailId)
    return XDataCenter.MailManager.IsMailUnReadOrHasReward(mailId)
end

return XRedPointConditionMailPersonal