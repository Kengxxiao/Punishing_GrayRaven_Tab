XMailManagerCreator = function()

    local XMailManager = {}

    local tableInsert = table.insert

    local MAIL_SERVICE_NAME = "XMailService"
    local METHOD_NAME = {
        MailReadRequest = "MailReadRequest",
        MailGetRewardRequest = "MailGetRewardRequest",
        MailGetSingleRewardRequest = "MailGetSingleRewardRequest",
        MailDeleteRequest = "MailDeleteRequest",
    }

    local MailCache = {}
    local lastSyncServerTime = 0
    local NewMailMark = false

    XMailManager.MAIL_STATUS_UNREAD = 0
    XMailManager.MAIL_STATUS_READ = 1
    XMailManager.MAIL_STATUS_GETREWARD = 3
    XMailManager.MAIL_STATUS_DELETE = 4

    local STATUS_UNREAD = 0
    local STATUS_READ = 1 << 0
    local STATUS_GETREWARD = STATUS_READ | (1 << 1)
    local STATUS_DELETE = 1 << 2

    function XMailManager.GetRewardList(mailId)
        return XMailConfigs.GetRewardList(mailId)
    end

    --==============================--
    --desc: 检查邮件是否过期或失效
    --@mailId: 邮件id
    --@return
    --==============================--
    local function CheckMailExpire(mailId)
        local mail = MailCache[mailId]
        if not mail then
            return true
        end

        if mail.Status == STATUS_DELETE then
            return true
        end

        if not mail.ExpireTime or mail.ExpireTime <= 0 then
            return false
        end

        return XTime.Now() > mail.ExpireTime
    end

    --==============================--
    --desc: 删除邮件数据
    --@mailId: 邮件id
    --@return
    --==============================--
    local function DeleteMail(mailId)
        MailCache[mailId] = nil
    end

    --==============================--
    --desc: 更新邮件数据
    --@mailData: 邮件数据
    --@return
    --==============================--
    local function UpdateMail(mailData)
        MailCache[mailData.Id] = mailData
    end

    --==============================--
    --desc: 处理邮件数据
    --@return
    --==============================--
    local function DealMailDatas(mailList, expireIdList)
        if mailList then
            for _, mail in pairs(mailList) do
                UpdateMail(mail)
            end
        end

        if expireIdList then
            for _, id in pairs(expireIdList) do
                DeleteMail(id)
            end
        end
        XEventManager.DispatchEvent(XEventId.EVENT_MAIL_SYNC)
    end

    function XMailManager.SyncMailEvent()
        XEventManager.DispatchEvent(XEventId.EVENT_MAIL_SYNC)
    end
    
    function XMailManager.IsRead(status)
        return (status & STATUS_READ) == STATUS_READ
    end

    function XMailManager.IsGetReward(status)
        return (status & STATUS_GETREWARD) == STATUS_GETREWARD
    end

    function XMailManager.IsDelete(status)
        return (status & STATUS_DELETE) == STATUS_DELETE
    end

    function XMailManager.SetMailStatus(id, status)
        local mail = MailCache[id]
        if not mail then
            return
        end

        if status == STATUS_UNREAD or (mail.Status & status) == status then
            return
        end

        mail.Status = mail.Status | status
    end

    function XMailManager.GetNewMailMark()
        return NewMailMark
    end

    function XMailManager:GetIsUnReadMail()
        local mailList = XMailManager.GetMailList()
        for _, mailInfo in pairs(mailList) do
            if mailInfo.Status == XMailManager.MAIL_STATUS_UNREAD then
                return true
            end
        end
        return false
    end

    function XMailManager.ReadMail(mailId)
        if CheckMailExpire(mailId) then
            return
        end

        local mail = MailCache[mailId]
        if XMailManager.IsRead(mail.Status) or XMailManager.IsDelete(mail.Status) then
            return
        end

        XNetwork.Call(METHOD_NAME.MailReadRequest, { Id = mailId }, function(res)
            if res.Code == XCode.Success then
                if XMailManager.HasMailReward(mailId) then
                    XMailManager.SetMailStatus(mailId, STATUS_READ)
                        XEventManager.DispatchEvent(XEventId.EVENT_MAIL_READ, mailId)
                else
                    XMailManager.SetMailStatus(mailId, STATUS_GETREWARD)
                        XEventManager.DispatchEvent(XEventId.MAIL_STATUS_GETREWARD, mailId)
                end
            end
        end)
    end

    function XMailManager.GetMailReward(mailId, cb)
        if not XMailManager.HasMailReward(mailId) then
            XUiManager.TipText("MailGetRewardEmpty")
            return
        end

        local mailData = MailCache[mailId]
        if XMailManager.IsGetReward(mailData.Status) then
            XUiManager.TipCode(XCode.MailManagerGetRewardRepeat)
            return
        end


        if CheckMailExpire(mailId) then
            DeleteMail(mailId)
            XUiManager.TipCode(XCode.MailManagerMailWasInvalid)
            cb(mailId)
            return
        end

        XNetwork.Call(METHOD_NAME.MailGetSingleRewardRequest, { Id = mailId }, function(res)
            local func = function ()
                if res.Status == XMailManager.MAIL_STATUS_DELETE then
                    DeleteMail(mailId)
                    XUiManager.TipCode(XCode.MailManagerMailWasInvalid)
                    cb(mailId)
                    return
                end
                XMailManager.SetMailStatus(mailId, res.Status)
                XEventManager.DispatchEvent(XEventId.EVENT_MAIL_GET_MAIL_REWARD)
                cb()
            end

            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                func()
            else
                XUiManager.OpenUiObtain(res.RewardGoodsList, nil, func)
            end
        end)
    end

    function XMailManager.GetAllMailReward(cb)
        local mailIds = {}
        for id, mail in pairs(MailCache) do
            if CheckMailExpire(id) then
                DeleteMail(id)
            elseif XMailManager.HasMailReward(id) and not XMailManager.IsGetReward(mail.Status) then
                tableInsert(mailIds, id)
            end
        end

        if #mailIds <= 0 then
            XUiManager.TipText("MailGetRewardEmpty")
            cb()
            return
        end

        XNetwork.Call(METHOD_NAME.MailGetRewardRequest, { IdList = mailIds }, function(res)
            local func = function(resCode)
                if resCode == XCode.Success then
                    if cb then
                        cb()
                    end

                    XEventManager.DispatchEvent(XEventId.EVENT_MAIL_GET_ALL_MAIL_REWARD)

                elseif resCode == XCode.MailManagerGetMailRewardSomeGoodsMoreThanCapacity then
                    XUiManager.DialogTip("", CS.XTextManager.GetCodeText(resCode), XUiManager.DialogType.Normal, nil, cb)
                else
                    XUiManager.TipCode(resCode)
                    if cb then
                        cb()
                    end
                end
            end

            if res.MailStatus then
                for id, status in pairs(res.MailStatus) do
                    if status ==  XMailManager.MAIL_STATUS_DELETE then
                        DeleteMail(id)
                    else
                        XMailManager.SetMailStatus(id, status)
                    end
                end
            end

            if res.RewardGoodsList and #res.RewardGoodsList > 0 then
                XUiManager.OpenUiObtain(res.RewardGoodsList, nil, function(...)
                    func(res.Code)
                end)
            else
                func(res.Code)
            end
        end)
    end

    function XMailManager.DeleteMail(cb)
        XNetwork.Call(METHOD_NAME.MailDeleteRequest, nil, function(res)
            if res.DelIdList then
                for _, id in pairs(res.DelIdList) do
                    DeleteMail(id)
                end
            end

            XEventManager.DispatchEvent(XEventId.EVENT_MAIL_DELETE, mailId)
            cb()
        end)
    end

    --==============================--
    --desc: 获取邮件列表 （未读未领奖 > 已读未领奖 > 已读已领奖（没附件相当于已领奖）>  创建时间 > 过期时间）
    --@return
    --==============================--
    function XMailManager.GetMailList()
        local list = {}
        for k, mail in pairs(MailCache) do
            
            if mail.Status == STATUS_READ then
                if XMailManager.HasMailReward(mail.Id) then
                    XMailManager.SetMailStatus(mail.Id, STATUS_READ)
                else
                    XMailManager.SetMailStatus(mail.Id, STATUS_GETREWARD)
                end
            end
                
            if not CheckMailExpire(k) then
                tableInsert(list, mail)
            end
        end

        table.sort(list, function(a, b)
            if a.Status ~= b.Status then
                return a.Status < b.Status
            else
                return a.ExpireTime < b.ExpireTime
            end
        end)

        return list
    end

    function XMailManager.GetMailCache(mailId)
        return MailCache[mailId]
    end

    function XMailManager.HasMailReward(mailId)
        local mail = MailCache[mailId]
        if not mail then
            return false
        end

        local rewardList = mail.RewardGoodsList
        if not rewardList then
            return false
        end

        if #rewardList > 0 then
            return true
        end

        return false
    end

    function XMailManager.IsMailGetReward(mailId)
        local mail = MailCache[mailId]
        if not mail then
            return
        end

        return XMailManager.IsGetReward(mail.Status)
    end

    --检查红点-----------------------------------
    --有未读或者有奖励未领取
    function XMailManager.IsMailUnReadOrHasReward(mailId)
        if not mailId then
            return false
        end

        local mailData = MailCache[mailId]
        if not mailData then
            return false
        end

        if CheckMailExpire(mailId) then
            return false
        end
        
        if not XMailManager.IsRead(mailData.Status) then
            return true
        end

        if not XMailManager.IsGetReward(mailData.Status) and XMailManager.HasMailReward(mailId) then
            return true
        end

        return false
    end

    --获取没处理的邮件
    function XMailManager.GetHasUnDealMail()
        local mailList = XMailManager.GetMailList()
        local result = 0
        for _, mailInfo in pairs(mailList) do
            if XMailManager.IsMailUnReadOrHasReward(mailInfo.Id) then
                result = result + 1
            end
        end
        return result
    end

    function XMailManager.NotifyMails(data)
        lastSyncServerTime = XTime.Now()
        DealMailDatas(data.NewMailList, data.ExpireIdList)
    end
    
    return XMailManager
end

XRpc.NotifyMails = function(data)
    XDataCenter.MailManager.NotifyMails(data)
end