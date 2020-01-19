local CsXTextManager = CS.XTextManager

local XUiGridActivityBanner = XClass()

function XUiGridActivityBanner:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
end

function XUiGridActivityBanner:OnDestroy()
    self:DestroyActivityTimer()
    self:StopCommonTimer()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiGridActivityBanner:InitAutoScript()
    XTool.InitUiObject(self)
    self:AutoAddListener()
end

function XUiGridActivityBanner:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiGridActivityBanner:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiGridActivityBanner:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiGridActivityBanner:AutoAddListener()
end
-- auto
function XUiGridActivityBanner:Refresh(chapter, uiRoot)
    if chapter.Type == XDataCenter.FubenManager.ChapterType.BossOnline then
        self.TxtName.text = chapter.Name
        local count = XDataCenter.FubenBossOnlineManager.GetFlopConsumeItemCount()
        self.TxtConsumeCount.text = CsXTextManager.GetText("BossOnlineProcess", count)

        if not XFunctionManager.JudgeCanOpen(XFunctionManager.FunctionName.FubenActivityOnlineBoss) then
            self.PanelLock.gameObject:SetActive(true)
            self.TxtLock.text = XFunctionManager.GetFunctionOpenCondition(XFunctionManager.FunctionName.FubenActivityOnlineBoss)
        else
            self.PanelLock.gameObject:SetActive(false)
        end

        local isActivity = XDataCenter.FubenBossOnlineManager.GetIsActivity()
        self.PanelActivityTag.gameObject:SetActive(isActivity)
        self.RImgIcon:SetRawImage(chapter.Icon)
        local leftTime = XDataCenter.FubenBossOnlineManager.GetOnlineBossUpdateTime()
        if isActivity then
            self:CreateActivityTimer(leftTime, leftTime, XDataCenter.FubenBossOnlineManager.OnActivityEnd)
        else
            self.PanelLeftTime.gameObject:SetActive(false)
        end
    elseif chapter.Type == XDataCenter.FubenManager.ChapterType.ActivtityBranch then
        local sectionId = chapter.Id
        local chapterId = XDataCenter.FubenActivityBranchManager.GetCurChapterId(sectionId)
        local chapterCfg = XFubenActivityBranchConfigs.GetChapterCfg(chapterId)
        local finishCount = XDataCenter.FubenActivityBranchManager.GetChapterFinishCount(chapterId)
        local totalCount = #chapterCfg.StageId

        self.TxtName.text = chapterCfg.Name
        self.PanelActivityTag.gameObject:SetActive(true)
        self.RImgIcon:SetRawImage(chapterCfg.Cover)

        if not XFunctionManager.JudgeCanOpen(XFunctionManager.FunctionName.FubenActivityBranch) then
            self.PanelLock.gameObject:SetActive(true)
            self.TxtLock.text = XFunctionManager.GetFunctionOpenCondition(XFunctionManager.FunctionName.FubenActivityBranch)
        else
            self.PanelLock.gameObject:SetActive(false)
        end
        
        if not XDataCenter.FubenActivityBranchManager.IsSelectDifficult() then
            self.TxtConsumeCount.text = CsXTextManager.GetText("ActivityBranchNormalProcess", finishCount, totalCount)
        else
            self.TxtConsumeCount.text = CsXTextManager.GetText("ActivityBranchDifficultProcess", finishCount, totalCount)
        end

        local fightEndTime = XDataCenter.FubenActivityBranchManager.GetFightEndTime()
        local activityEndTime = XDataCenter.FubenActivityBranchManager.GetActivityEndTime()
        self:CreateActivityTimer(fightEndTime,activityEndTime,XDataCenter.FubenActivityBranchManager.OnActivityEnd)
    elseif chapter.Type == XDataCenter.FubenManager.ChapterType.ActivityBossSingle then
        local sectionId = chapter.Id
        local sectionCfg = XFubenActivityBossSingleConfigs.GetSectionCfg(sectionId)
        local finishCount = XDataCenter.FubenActivityBossSingleManager.GetFinishCount()
        local totalCount = #sectionCfg.ChallengeId

        self.TxtName.text = sectionCfg.ChapterName
        self.PanelActivityTag.gameObject:SetActive(true)
        self.RImgIcon:SetRawImage(sectionCfg.Cover)
        self.TxtConsumeCount.text = CsXTextManager.GetText("ActivityBossSingleProcess", finishCount, totalCount)

        if not XFunctionManager.JudgeCanOpen(XFunctionManager.FunctionName.FubenActivitySingleBoss) then
            self.PanelLock.gameObject:SetActive(true)
            self.TxtLock.text = XFunctionManager.GetFunctionOpenCondition(XFunctionManager.FunctionName.FubenActivitySingleBoss)
        else
            self.PanelLock.gameObject:SetActive(false)
        end

        local fightEndTime = XDataCenter.FubenActivityBossSingleManager.GetFightEndTime()
        local activityEndTime = XDataCenter.FubenActivityBossSingleManager.GetActivityEndTime()
        self:CreateActivityTimer(fightEndTime,activityEndTime,XDataCenter.FubenActivityBossSingleManager.OnActivityEnd)

    elseif chapter.Type == XDataCenter.FubenManager.ChapterType.Christmas or 
            chapter.Type == XDataCenter.FubenManager.ChapterType.BriefDarkStream or 
            chapter.Type == XDataCenter.FubenManager.ChapterType.FestivalNewYear then
        local sectionId = chapter.Id
        local sectionCfg = XFestivalActivityConfig.GetFestivalById(sectionId)
        
        self.TxtName.text = sectionCfg.Name
        self.PanelActivityTag.gameObject:SetActive(true)
        self.RImgIcon:SetRawImage(sectionCfg.BannerBg)

        local finishCount, totalCount = XDataCenter.FubenFestivalActivityManager.GetFestivalProgress(sectionId)
        self.TxtConsumeCount.text = CsXTextManager.GetText("ActivityBossSingleProcess", finishCount, totalCount)

        local startTimeSecond = CS.XDate.GetTime(sectionCfg.BeginTimeStr)
        local endTimeSecond = CS.XDate.GetTime(sectionCfg.EndTimeStr)
        local now = XTime.Now()
        if now >= startTimeSecond and now <= endTimeSecond then
            self:CreateCommonTimer(startTimeSecond, endTimeSecond, function()
                uiRoot:SetupDynamicTable()
            end)
        else
            self.PanelLeftTime.gameObject:SetActiveEx(false)
        end
        
        -- 功能开启AcitvityFestivalProgress
        if sectionCfg.FunctionOpenId > 0 then
            if not XFunctionManager.JudgeCanOpen(sectionCfg.FunctionOpenId) then
            self.PanelLock.gameObject:SetActive(true)
                self.TxtLock.text = XFunctionManager.GetFunctionOpenCondition(sectionCfg.FunctionOpenId)
            else
                self.PanelLock.gameObject:SetActive(false)
            end
        else
            self.PanelLock.gameObject:SetActive(false)
        end
    end
end

function XUiGridActivityBanner:CreateCommonTimer(startTime, endTime, endCb)
    local time = XTime.Now()
    local fightStr = CsXTextManager.GetText("ActivityBranchFightLeftTime")
    self.TxtLeftTime.text = string.format("%s%s", fightStr, XUiHelper.GetTime(endTime - time, XUiHelper.TimeFormatType.ACTIVITY))
    self:StopCommonTimer()
    self.PanelLeftTime.gameObject:SetActiveEx(true)
    self.CommonTimer = CS.XScheduleManager.ScheduleForever(function(...)
        time = XTime.Now()
        if time > endTime then
            self:StopCommonTimer()
            if endCb then endCb() end
            return
        end
        self.TxtLeftTime.text = string.format("%s%s", fightStr, XUiHelper.GetTime(endTime - time, XUiHelper.TimeFormatType.ACTIVITY))
    end, CS.XScheduleManager.SECOND, 0)
end

function XUiGridActivityBanner:StopCommonTimer()
    if self.CommonTimer then
        CS.XScheduleManager.UnSchedule(self.CommonTimer)
        self.CommonTimer = nil
    end
end

function XUiGridActivityBanner:CreateActivityTimer(fightEndTime,activityEndTime,endCb)
    local time = XTime.Now()
    if time > activityEndTime then return end  

    self:DestroyActivityTimer()

    local leftTimeDes = ""
    local shopStr = CsXTextManager.GetText("ActivityBranchShopLeftTime")
    local fightStr = CsXTextManager.GetText("ActivityBranchFightLeftTime")

    if fightEndTime <= time and time < activityEndTime then
        self.TxtLeftTime.text = shopStr .. XUiHelper.GetTime(activityEndTime - time, XUiHelper.TimeFormatType.ACTIVITY)
    else
        self.TxtLeftTime.text = fightStr .. XUiHelper.GetTime(fightEndTime - time, XUiHelper.TimeFormatType.ACTIVITY)
    end

    self.PanelLeftTime.gameObject:SetActive(true)
    self.ActivityTimer = CS.XScheduleManager.ScheduleForever(function(...)
        if XTool.UObjIsNil(self.TxtLeftTime) then
            self:DestroyActivityTimer()
            return
        end

        time = time + 1

        if fightEndTime <= time and time <= activityEndTime then
            local leftTime = activityEndTime - time
            if leftTime > 0 then
                self.TxtLeftTime.text = shopStr .. XUiHelper.GetTime(leftTime, XUiHelper.TimeFormatType.ACTIVITY)
            else
                self:DestroyActivityTimer()
                if endCb then endCb() end
            end
        else
            local leftTime = fightEndTime - time
            if leftTime > 0 then
                self.TxtLeftTime.text = fightStr .. XUiHelper.GetTime(leftTime, XUiHelper.TimeFormatType.ACTIVITY)
            else
                self:DestroyActivityTimer()
                self:CreateActivityTimer(fightEndTime,activityEndTime,endCb)
            end
        end
    end, CS.XScheduleManager.SECOND, 0)
end

function XUiGridActivityBanner:DestroyActivityTimer()
    if self.ActivityTimer then
        CS.XScheduleManager.UnSchedule(self.ActivityTimer)
        self.ActivityTimer = nil
    end
end

function XUiGridActivityBanner:SetActive(active)
    self.GameObject:SetActive(active)
end

return XUiGridActivityBanner