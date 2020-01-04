----------------------------------------------------------------
--单个邮件检测
local XRedPointConditionMainMail = {}
local SubConditions = nil

function XRedPointConditionMainMail.GetSubConditions()
    SubConditions = SubConditions or { XRedPointConditions.Types.CONDITION_MAIL_PERSONAL }
    return SubConditions
end

function XRedPointConditionMainMail.Check()
    return XDataCenter.MailManager.GetHasUnDealMail()
end

return XRedPointConditionMainMail