XNoticeManagerCreator = function()
    local Json = require("XCommon/Json")

    local XNoticeManager = {}

    local NoticePicList = {}

    local NowTextNotice = nil
    local NowPicNotice = nil

    local InGameNoticeReadList = {}
    local InGameNoticeMap = {}
    local InGameNoticeReadKey = "_InGameNoticeReadKey"

    local NoticeRequestTimer = nil
    local NoticeRequestTimerInterval = 10 * 1000
    local NoticeRequestTimeOut = 30

    local HaveNewPicNotice = false

    local ScrollCountList = {}
    local ScrollCountSaveKey = "_NoticeScrollCountList"

    local NoticeTitlePrefix = "NoticeTypeTitle"

    local DefaultTextScrollInterval = 10

    local LoginNotice = nil
    local LoginNoticeTimeInfo = {}
    local LoginNoticeCacheKey = "LoginNotice"

    local TextNoticeHideCache = {}
    local TextNoticeHideCacheKey = "_TextNotice"

    local SceenShotFlag = false

    local XNoticeStatus =
    {
        -- 未发布
        Unpublished = 0,
        -- 等待发布
        PublishWait = 1,
        -- 发布成功
        Published = 2,
        -- 发布失败
        PublishFail = 3,
        -- 过期
        OverTime = 4,
    }

    local XNoticeType =
    {
        -- 顶部文字滚动公告
        ScrollText = 0,
        -- 主界面广告图
        ScrollPic = 1,
        -- 游戏内公告
        InGame = 2,
        -- 登陆公告
        Login = 3
    }

    local RequestInterval = {
        [XNoticeType.ScrollText] = 30,
        [XNoticeType.ScrollPic] = 60,
        [XNoticeType.InGame] = 120,
    }

    local LastRequestTime = {
        [XNoticeType.ScrollText] = 0,
        [XNoticeType.ScrollPic] = 0,
        [XNoticeType.InGame] = 0,
    }

    local NoticeRequestHandler = {
        [XNoticeType.ScrollText] = function (notice) XNoticeManager.HandleRequestScrollTextNotice(notice) end,
        [XNoticeType.ScrollPic] = function (notice) XNoticeManager.HandleRequestScrollPicNotice(notice) end,
        [XNoticeType.InGame] = function (notice) XNoticeManager.HandleRequestInGameNotice(notice) end,
    }

    local NoticeRequestFailHandler = {
        [XNoticeType.ScrollText] = function () XNoticeManager.HandleRequestScrollTextNotice() end,
        [XNoticeType.ScrollPic] = function () XNoticeManager.HandleRequestScrollPicNoticeFail() end,
        [XNoticeType.InGame] = function () XNoticeManager.HandleRequestInGameNotice() end,
    }

    local NoticeData = {
        [XNoticeType.ScrollText] = nil,
        [XNoticeType.ScrollPic] = nil,
        [XNoticeType.InGame] = nil,
    }

    ----------------------------------初始化公告cdn路径 beg----------------------------------
    local NoticeCdnUrl = {}
    local NoticeFileName = {
        [XNoticeType.ScrollText] = "ScrollTextNotice.json",
        [XNoticeType.ScrollPic] = "ScrollPicNotice.json",
        [XNoticeType.InGame] = "GameNotice.json",
        [XNoticeType.Login] = "LoginNotice.json",
    }

    function XNoticeManager.GetNoticeUrl(noticeType)
        return NoticeCdnUrl[noticeType]
    end

    function XNoticeManager.InitNoticeCdnUrl()
        local noticePathPrefix = CS.XGame.ClientConfig:GetString("NoticePathPrefix")
        for k, v in pairs(NoticeFileName) do
            NoticeCdnUrl[k] = noticePathPrefix .. CS.XInfo.Identifier .. "/" .. CS.XRemoteConfig.ApplicationVersion .. "/" .. v
        end
    end
    ----------------------------------初始化公告cdn路径 end----------------------------------

    ----------------------------------获取公网ip地址 beg----------------------------------
    local Ip = ""
    local IpUrlIndex = 0
    local IpUrls = {
        "http://icanhazip.com/",
        "http://ifconfig.me/ip",
        "http://ifconfig.co/ip",
        "http://inet-ip.info/ip"
    }

    function XNoticeManager.RequestIp()
        IpUrlIndex = IpUrlIndex + 1
        if IpUrlIndex > #IpUrls then
            return
        end

        local request = CS.UnityEngine.Networking.UnityWebRequest.Get(IpUrls[IpUrlIndex])
        local requestEnd = function()
            if request.isNetworkError or request.isHttpError then
                XNoticeManager.RequestIp()
            end

            Ip = request.downloadHandler.text

            request:Dispose()
        end

        CS.XTool.WaitNativeCoroutine(request:SendWebRequest(), requestEnd)
    end

    function XNoticeManager.GetIp()
        return Ip
    end
    ----------------------------------获取公网ip地址 end----------------------------------


    --------------------------cache beg--------------------------
    function XNoticeManager.GetInGameNoticeReadKey()
        return tostring(XPlayer.Id) .. InGameNoticeReadKey
    end

    function XNoticeManager.SaveInGameNoticeReadList()
        if not InGameNoticeReadList then
            return
        end

        local saveContent = ""
        for k, v in pairs(InGameNoticeReadList) do
            saveContent = saveContent .. v.Id .. '\t'
            saveContent = saveContent .. v.Index .. '\t'
            saveContent = saveContent .. (v.IsRead and 1 or 0) .. '\t'
            saveContent = saveContent .. v.EndTime .. '\t'
            saveContent = saveContent .. v.ModifyTime .. '\n'
        end

        CS.UnityEngine.PlayerPrefs.SetString(XNoticeManager.GetInGameNoticeReadKey(), saveContent)
        CS.UnityEngine.PlayerPrefs.Save()

        XEventManager.DispatchEvent(XEventId.EVENT_ACTIVITY_NOTICE_READ_CHAGNE)
    end

    function XNoticeManager.ReadInGameNoticeReadList()
        InGameNoticeReadList = {}
        if not CS.UnityEngine.PlayerPrefs.HasKey(XNoticeManager.GetInGameNoticeReadKey()) then
            return
        end

        local dataStr = CS.UnityEngine.PlayerPrefs.GetString(XNoticeManager.GetInGameNoticeReadKey())

        local msgTab = string.Split(dataStr, '\n')
        if not msgTab or #msgTab <= 0 then
            return
        end

        for i, content in ipairs(msgTab) do
            if (not string.IsNilOrEmpty(content)) then
                local tab = string.Split(content, '\t')
                if tab then
                    local readInfo = {
                        Id = tostring(tab[1]),
                        Index = tonumber(tab[2]),
                        IsRead = tonumber(tab[3]) > 0,
                        EndTime = tonumber(tab[4]),
                        ModifyTime = tonumber(tab[5]),
                    }
                    if readInfo.ModifyTime and readInfo.EndTime and readInfo.EndTime > XTime.Now() then
                        local dataKey = XNoticeManager.GetGameNoticeReadDataKey(readInfo, readInfo.Index)
                        InGameNoticeReadList[dataKey] = readInfo
                    end
                end
            end
        end
    end

    function XNoticeManager.GetScrollCountSaveKey()
        return tostring(XPlayer.Id) .. ScrollCountSaveKey
    end

    function XNoticeManager.SaveScrollCountList()
        if not ScrollCountList then
            return
        end
        local saveContent = ''
        for k, v in pairs(ScrollCountList) do
            saveContent = saveContent .. v.id .. '\t'
            saveContent = saveContent .. v.maxCount .. '\t'
            saveContent = saveContent .. v.nowCount .. '\t'
            saveContent = saveContent .. v.overTime .. '\n'
        end

        CS.UnityEngine.PlayerPrefs.SetString(XNoticeManager.GetScrollCountSaveKey(), saveContent)
        CS.UnityEngine.PlayerPrefs.Save()
    end

    function XNoticeManager.ReadScrollCountList()
        ScrollCountList = {}
        if not CS.UnityEngine.PlayerPrefs.HasKey(XNoticeManager.GetScrollCountSaveKey()) then
            return
        end
        local dataStr = CS.UnityEngine.PlayerPrefs.GetString(XNoticeManager.GetScrollCountSaveKey())
        local msgTab = string.Split(dataStr, '\n')
        if not msgTab or #msgTab <= 0 then
            return
        end

        for i, content in ipairs(msgTab) do
            if (not string.IsNilOrEmpty(content)) then
                local tab = string.Split(content, '\t')
                if tab then
                    local countInfo = {
                        id = tostring(tab[1]),
                        maxCount = tonumber(tab[2]),
                        nowCount = tonumber(tab[3]),
                        overTime = tonumber(tab[4]),
                    }
                    if countInfo.overTime and countInfo.overTime > XTime.Now() then
                        ScrollCountList[countInfo.id] = countInfo
                    end
                end
            end
        end
    end
    --------------------------cache end--------------------------

    --------------------------text beg--------------------------
    function XNoticeManager.HandleRequestScrollTextNotice(notice)
        NowTextNotice = notice

        if not XNoticeManager.CheckTextNoticeInvalid(notice) then
            XLuaUiManager.Close("UiNoticeTips")
        else
            XLuaUiManager.Open("UiNoticeTips")
        end

        if NowTextNotice then
            local key = XNoticeManager.GetTextNoticeKey(NowTextNotice)
            if not ScrollCountList or not ScrollCountList[key] then
                XNoticeManager.CreateDefaultScrollCountData(NowTextNotice)
            end
        end
    end

    function XNoticeManager.GetTextNoticeKey(notice)
        return notice.Id .. "_" .. notice.ModifyTime
    end

    function XNoticeManager.CreateDefaultScrollCountData(notice)
        local key = XNoticeManager.GetTextNoticeKey(notice)
        local countInfo = {
            id = key,
            maxCount = notice.ScrollTimes,
            nowCount = 0,
            overTime = notice.EndTime,
        }
        ScrollCountList[key] = countInfo
    end

    function XNoticeManager.CheckTextNoticeInvalid(notice)
        notice = notice or NowTextNotice

        if not XNoticeManager.CheckNoticeInvalid(notice) then
            return false
        end

        if not XNoticeManager.CheckTextNoticeHideCache(notice) then
            return false
        end

        if notice.ShowInFight < 1 and not CS.XFight.IsOutFight then
            return false
        end

        if notice.ShowInPhotograph < 1 and SceenShotFlag then
            return false
        end

        local key = XNoticeManager.GetTextNoticeKey(notice)
        if ScrollCountList[key]
            and ScrollCountList[key].nowCount > ScrollCountList[key].maxCount then

            return false
        end

        return true
    end

    function XNoticeManager.GetTextNoticeContent()
        if not NowTextNotice then
            return
        end
        return NowTextNotice.Content
    end

    function XNoticeManager.AddTextNoticeCount()
        if not NowTextNotice then
            return
        end

        local key = XNoticeManager.GetTextNoticeKey(NowTextNotice)

        if not ScrollCountList[key] then
            XNoticeManager.CreateDefaultScrollCountData(NowTextNotice)
        end

        ScrollCountList[key].nowCount = ScrollCountList[key].nowCount + 1

        XNoticeManager.SaveScrollCountList()
    end

    function XNoticeManager.GetTextNoticeScrollInterval()
        if not NowTextNotice then
            return DefaultTextScrollInterval
        end
        return tonumber(NowTextNotice.ScrollInterval) or DefaultTextScrollInterval
    end

    function XNoticeManager.ReadTextNoticeHideCache()
        local cache = CS.UnityEngine.PlayerPrefs.GetString(tostring(XPlayer.Id) .. TextNoticeHideCacheKey)
        if string.IsNilOrEmpty(cache) then
            return
        end

        TextNoticeHideCache = Json.decode(cache)

        for _, v in pairs(TextNoticeHideCache) do
            if XTime.Now() > v.EndTime then
                v = nil
            end
        end

    end

    function XNoticeManager.ChangeTextNoticeHideCache(notice)
        notice = notice or NowTextNotice
        if not notice then
            return
        end

        local key = XNoticeManager.GetTextNoticeKey(notice)
        if not TextNoticeHideCache[key] then
            TextNoticeHideCache[key] = {
                Id = key,
                IsHide = 1,
                EndTime = notice.EndTime
            }
        else
            TextNoticeHideCache[key].IsHide = not TextNoticeHideCache[key].IsHide
        end

        XNoticeManager.SaveTextNoticeHideCache()
    end

    function XNoticeManager.SaveTextNoticeHideCache()
        if not TextNoticeHideCache then
            return
        end

        CS.UnityEngine.PlayerPrefs.SetString(tostring(XPlayer.Id) .. TextNoticeHideCacheKey, Json.encode(TextNoticeHideCache))
        CS.UnityEngine.PlayerPrefs.Save()
    end

    function XNoticeManager.CheckTextNoticeHideCache(notice)
        notice = notice or NowTextNotice
        if not notice then
            return false
        end

        local key = XNoticeManager.GetTextNoticeKey(notice)
        if not TextNoticeHideCache[key] then
            return true
        end

        return TextNoticeHideCache[key].IsHide < 0
    end
    --------------------------text end--------------------------


    function XNoticeManager.HaveNewPicNotice()
        return HaveNewPicNotice
    end


    function XNoticeManager.CheckRedPoint(type)
        if not InGameNoticeMap or not InGameNoticeMap[type] then
            return false
        end

        for _, notice in pairs(InGameNoticeMap[type]) do
            for i, v in ipairs(notice.Content) do
                if XNoticeManager.CheckHasRedPoint(notice, i) then
                    return true
                end
            end
        end
        return false
    end

    function XNoticeManager.InitInGameReadList(noticeList)
        if not noticeList then
            return
        end

        if not InGameNoticeReadList then
            InGameNoticeReadList = {}
        end

        for k, noticeData in pairs(noticeList) do
            for i, v in pairs(noticeData.Content) do
                local dataKey = XNoticeManager.GetGameNoticeReadDataKey(noticeData, i)
                if not InGameNoticeReadList[dataKey] then
                    InGameNoticeReadList[dataKey] = {}
                    InGameNoticeReadList[dataKey].Id = noticeData.Id
                    InGameNoticeReadList[dataKey].EndTime = noticeData.EndTime
                    InGameNoticeReadList[dataKey].Index = i
                    InGameNoticeReadList[dataKey].IsRead = false
                    InGameNoticeReadList[dataKey].ModifyTime = noticeData.ModifyTime
                end
            end
        end

        XEventManager.DispatchEvent(XEventId.EVENT_ACTIVITY_NOTICE_READ_CHAGNE)
    end

    function XNoticeManager.GetGameNoticeReadDataKey(noticeData, index)
        return noticeData.Id .. "_" .. noticeData.ModifyTime .. "_" .. index
    end


    function XNoticeManager.CheckHasRedPoint(notice, index)
        if not InGameNoticeReadList then
            return false
        end

        local redPointKey = XNoticeManager.GetGameNoticeReadDataKey(notice, index)
        if not InGameNoticeReadList[redPointKey] then
            return false
        end

        return not InGameNoticeReadList[redPointKey].IsRead
    end

    function XNoticeManager.ChangeInGameNoticeReadStatus(dataKey, isRead)
        if not InGameNoticeReadList then
            return
        end

        InGameNoticeReadList[dataKey].IsRead = isRead
        XNoticeManager.SaveInGameNoticeReadList()
    end

----------------------------------------login beg----------------------------------------
    function XNoticeManager.OpenLoginNotice()
        if not XNoticeManager.CheckNoticeInvalid(LoginNotice) then
            return
        end

        XLuaUiManager.Open("UiLoginNotice", LoginNotice)
    end

    function XNoticeManager.ReadLoginNoticeTime()
        local cache = CS.UnityEngine.PlayerPrefs.GetString(LoginNoticeCacheKey)
        if string.IsNilOrEmpty(cache) then
            return
        end

        LoginNoticeTimeInfo = Json.decode(cache)
    end

    function XNoticeManager.CheckLoginNoticeDailyAutoShow(notice)
        if not notice then
            return
        end

        local id = notice.Id .. notice.ModifyTime
        local resetTime = CS.XReset.GetNextDailyResetTime() - CS.XDate.ONE_DAY_SECOND
        if LoginNoticeTimeInfo[id] and LoginNoticeTimeInfo[id].Time > resetTime then
            return false
        end

        return true
    end

    function XNoticeManager.RefreshLoginNoticeTime()
        if not LoginNotice then
            return
        end

        local id = LoginNotice.Id .. LoginNotice.ModifyTime
        LoginNoticeTimeInfo[id] = {
            Id = id,
            Time = XTime.Now()
        }

        CS.UnityEngine.PlayerPrefs.SetString(LoginNoticeCacheKey, Json.encode(LoginNoticeTimeInfo))
        CS.UnityEngine.PlayerPrefs.Save()
    end

    function XNoticeManager.RequestLoginNotice(cb)
        local requestCb = function (notice)
            local invalid = XNoticeManager.CheckNoticeInvalid(notice)
            if not invalid then
                if cb then
                    cb(invalid)
                end

                local msgtab = {}
                msgtab["error"] = tostring(invalid)
                local jsonstr = Json.encode(msgtab)
                CS.XRecord.Record("24000", "RequestLoginNoticeError",jsonstr)
                return
            end

            if LoginNotice and LoginNotice.Id == notice.Id and LoginNotice.ModifyTime == notice.ModifyTime then
                if cb then
                    cb(invalid)
                end

                local msgtab = {}
                msgtab["error"] = tostring(invalid)
                local jsonstr = Json.encode(msgtab)
                CS.XRecord.Record("24006", "RequestLoginNoticeError",jsonstr)
                return
            end

            LoginNotice = notice

            if XNoticeManager.CheckLoginNoticeDailyAutoShow(notice) then
                XNoticeManager.OpenLoginNotice()
                XNoticeManager.RefreshLoginNoticeTime()
            end

            CS.XRecord.Record("24005", "RequestLoginNoticeEnd")
            if cb then
                cb(invalid)
            end
        end
        CS.XRecord.Record("24004", "RequestLoginNoticeStart")
        XNoticeManager.RequestNotice(XNoticeType.Login, requestCb, requestCb)
    end
----------------------------------------login end----------------------------------------

    function XNoticeManager.CheckHaveNotice(type)
        if not InGameNoticeMap then
            return false
        end

        if not InGameNoticeMap[type] or not next(InGameNoticeMap[type]) then
            return false
        end

        return true
    end

    function XNoticeManager.UrlDecode(s)
        s = string.gsub(s, '%%(%x%x)', function(h)
            return string.char(tonumber(h, 16))
        end)
        return s
    end

    function XNoticeManager.GetInGameNoticeMap(type)
        return InGameNoticeMap[type]
    end

    function XNoticeManager.GetMainAdList()
        if not NowPicNotice then
            return
        end

        HaveNewPicNotice = false

        local adList = {}
        for i, v in ipairs(NowPicNotice.Content) do
            local isOpen = true

            if not v.BeginTime or not v.EndTime or not v.AppearanceDay or not v.AppearanceTime or not v.DisappearanceCondition or not v.AppearanceCondition then
                isOpen = false
            end

            if isOpen then
                isOpen = false
                if XTime.Now() >= tonumber(v.BeginTime) and XTime.Now() < tonumber(v.EndTime) then--是否在开放区间内（日期）
                    isOpen = true
                end
            end

            if isOpen then
                isOpen = false
                if #v.AppearanceDay > 0 then
                    for k,day in ipairs(v.AppearanceDay) do
                        if day == XDataCenter.FubenDailyManager.GetNowDayOfWeekByRefreshTime() then--是否位于可以显示的周目
                            isOpen = true
                        end
                    end
                else
                    isOpen = true
                end
            end

            if isOpen then
                isOpen = false
                if #v.AppearanceTime > 0 then
                    for k,time in ipairs(v.AppearanceTime) do
                        if XTime.Now() - XTime.GetTodayTime(0,0,0) >= time[1] and XTime.Now() - XTime.GetTodayTime(0,0,0) < time[2] then--是否位于可以显示的时间段
                            isOpen = true
                        end
                    end
                else
                    isOpen = true
                end
            end

            if isOpen then
                if #v.DisappearanceCondition > 0 then
                    for k,condition in ipairs(v.DisappearanceCondition) do--是否符合不显示的条件
                        if XConditionManager.CheckCondition(condition) then
                            isOpen = false
                        end
                    end
                end
            end

            if isOpen then
                if #v.AppearanceCondition > 0 then
                    for k,condition in ipairs(v.AppearanceCondition) do
                        if not XConditionManager.CheckCondition(condition) then--是否不符合显示条件
                            isOpen = false
                        end
                    end
                end
            end

            if isOpen then
                if not XNoticeManager.IsWhiteIp(v.WhiteLists) then
                    isOpen = false
                end
            end

            if isOpen then
                v.Interval = tonumber(v.Interval)
                table.insert(adList, v)
            end
        end

        return adList
    end

    function XNoticeManager.HandleRequestInGameNotice(notice)
        InGameNoticeMap = {}
        if not notice then
            return
        end

        for k, v in ipairs(notice) do
            if XNoticeManager.CheckNoticeInvalid(v) then
                if not InGameNoticeMap[v.Type] then
                    InGameNoticeMap[v.Type] = {}
                end

                local content = {}
                for _, item in ipairs(v.Content) do
                    if XNoticeManager.IsWhiteIp(item.WhiteLists) then
                        table.insert(content, item)
                    end
                end

                if #content > 0 then
                    v.Content = content
                    table.insert(InGameNoticeMap[v.Type], v)
                end
            end
        end

        for k, v in pairs(InGameNoticeMap) do
            XNoticeManager.InitInGameReadList(v)

            local sortFunc = function (l, r)
                return l.Order > r.Order
            end
            table.sort(v, sortFunc)
        end
    end

    function XNoticeManager.CheckNoticeInvalid(notice)
        if not notice then
            return false
        end

        if XTime.Now() < notice.BeginTime then
            return false
        end

        if XTime.Now() > notice.EndTime then
            return false
        end

        if not XNoticeManager.IsWhiteIp(notice.WhiteLists) then
            return false
        end

        return true
    end

    function XNoticeManager.IsWhiteIp(whiteList)
        if not whiteList then
            return true
        end

        if string.IsNilOrEmpty(Ip) then
            return false
        end

        for _, whiteIp in pairs(whiteList) do
            if string.find(Ip, whiteIp) then
                return true
            end
        end

        return false
    end

    function XNoticeManager.RequestNotice(noticeType, successCb, failCb)
        if not noticeType then
            return
        end

        if LastRequestTime[noticeType] and LastRequestTime[noticeType] > 0 and XTime.Now() - LastRequestTime[noticeType] > RequestInterval[noticeType] then
            return
        end

        local url = XNoticeManager.GetNoticeUrl(noticeType)
        if string.IsNilOrEmpty(url) then
            return
        end

        local request = CS.XUriPrefixRequest.Get(url, nil, NoticeRequestTimeOut, false, true)
        CS.XTool.WaitCoroutine(request:SendWebRequest(), function()
            if not request then
                if failCb then
                    failCb()
                end
                return
            end

            if request.isNetworkError or request.isHttpError then
                if failCb then
                    failCb()
                end
                return
            end

            if not request.downloadHandler then
                if failCb then
                    failCb()
                end
                return
            end

            if string.IsNilOrEmpty(request.downloadHandler.text) then
                if failCb then
                    failCb()
                end
                return
            end

            local notice = Json.decode(request.downloadHandler.text)
            if not notice then
                if failCb then
                    failCb()
                end
                return
            end

            if successCb then
                successCb(notice)
            end

            request:Dispose()
        end)
    end

    function XNoticeManager.HandleRequestScrollPicNoticeFail()
        if not NowPicNotice then
            return
        end

        NowPicNotice = nil

        HaveNewPicNotice = true

        CsXGameEventManager.Instance:Notify(XEventId.EVENT_NOTICE_PIC_CHANGE)
    end

    function XNoticeManager.HandleRequestScrollPicNotice(notice)
        if not notice then
            return
        end

        if NowPicNotice and NowPicNotice.Id == notice.Id and NowPicNotice.ModifyTime == notice.ModifyTime then
            return
        end

        NowPicNotice = notice

        CsXGameEventManager.Instance:Notify(XEventId.EVENT_NOTICE_PIC_CHANGE)
    end

    function XNoticeManager.LoadPic(url, successCb)
        if NoticePicList and NoticePicList[url] then
            if successCb then
                successCb(NoticePicList[url])
            end
            return NoticePicList[url]
        end

        local request = CS.XUriPrefixRequest.Get(url, function () 
            return CS.UnityEngine.Networking.DownloadHandlerTexture(true) 
        end, NoticeRequestTimeOut, false)
        CS.XTool.WaitCoroutine(request:SendWebRequest(), function()
            if request.isNetworkError or request.isHttpError then
                return
            end
            
            local texture = request.downloadHandler.texture;
            if not texture then
                return
            end

            NoticePicList[url] = texture
            if successCb then
                successCb(texture)
            end
        end)
    end


    function XNoticeManager.InitTimer()
        if NoticeRequestTimer then
            return
        end

        for noticeType, _ in pairs(RequestInterval) do
            local successCb = NoticeRequestHandler[noticeType]
            local failCb = NoticeRequestFailHandler[noticeType]
            XNoticeManager.RequestNotice(noticeType, successCb, failCb)
        end

        NoticeRequestTimer = CS.XScheduleManager.ScheduleForever(function(timer)
            for noticeType, _ in pairs(RequestInterval) do
                local successCb = NoticeRequestHandler[noticeType]
                local failCb = NoticeRequestFailHandler[noticeType]
                XNoticeManager.RequestNotice(noticeType, successCb, failCb)
            end
        end, NoticeRequestTimerInterval)
    end

    function XNoticeManager.OnLogin()
        XNoticeManager.ReadScrollCountList()
        XNoticeManager.ReadInGameNoticeReadList()
        XNoticeManager.ReadTextNoticeHideCache()

        XNoticeManager.InitTimer()
    end

    function XNoticeManager.OnLogout()
        if NoticeRequestTimer then
            CS.XScheduleManager.UnSchedule(NoticeRequestTimer)
            NoticeRequestTimer = nil
        end

        for k,v in pairs(NoticePicList) do
            if v and v:Exist() then
                CS.UnityEngine.Object.Destroy(v)
            end
        end
        NoticePicList = {}
    end

    function XNoticeManager.Init()
        XNoticeManager.InitNoticeCdnUrl()
        XNoticeManager.RequestIp()
        XNoticeManager.ReadLoginNoticeTime()

        XEventManager.AddEventListener(XEventId.EVENT_USER_LOGOUT, XNoticeManager.OnLogout)
        XEventManager.AddEventListener(XEventId.EVENT_LOGIN_DATA_LOAD_COMPLETE, XNoticeManager.OnLogin)
        XEventManager.AddEventListener(XEventId.EVENT_PHOTO_ENTER, function ()
            SceenShotFlag = true
        end)
        XEventManager.AddEventListener(XEventId.EVENT_PHOTO_LEAVE, function ()
            SceenShotFlag = false
        end)
    end

    XNoticeManager.Init()
    return XNoticeManager
end
