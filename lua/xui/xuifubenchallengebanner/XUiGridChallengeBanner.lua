XUiGridChallengeBanner = XClass()

function XUiGridChallengeBanner:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
    self:InitAutoScript()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiGridChallengeBanner:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiGridChallengeBanner:AutoInitUi()
    -- self.RImgChallenge = self.Transform:Find("RImgChallenge"):GetComponent("RawImage")
    -- self.PanelOther = self.Transform:Find("PanelOther")
    -- self.TxtRank = self.Transform:Find("PanelOther/TxtRank"):GetComponent("Text")
    -- self.TxtTime = self.Transform:Find("TxtTime"):GetComponent("Text")
    -- self.TxtDes = self.Transform:Find("TxtDes"):GetComponent("Text")
    -- self.TxtProgress = self.Transform:Find("TxtProgress"):GetComponent("Text")
    -- self.ImgForbidEnter = self.Transform:Find("ImgForbidEnter"):GetComponent("Image")
    -- self.PanelLock = self.Transform:Find("PanelLock")
    -- self.TxtLock = self.Transform:Find("PanelLock/TxtLock"):GetComponent("Text")
    -- self.ImgRedPoint = self.Transform:Find("ImgRedPoint")
end

function XUiGridChallengeBanner:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiGridChallengeBanner:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiGridChallengeBanner:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiGridChallengeBanner:AutoAddListener()
end
-- auto
function XUiGridChallengeBanner:UpdateGrid(chapter, parent)
    self.Chapter = chapter
    local isUrgentEvent = chapter.IsUrgentEvent
    self.RImgChallenge.transform:DestroyChildren()
    self.PanelLock.gameObject:SetActive(false)
    self.ImgRedPoint.gameObject:SetActive(false)
    self:UnBindTimer()
    if chapter.Type == XDataCenter.FubenManager.ChapterType.Urgent then
        -- 紧急事件
        self.TxtRank.text = ""
        self.TxtProgress.text = ""
        self.TxtDes.text = chapter.UrgentCfg.SimpleDesc
        self.ImgForbidEnter.gameObject:SetActive(false)
        self.RImgChallenge:SetRawImage(chapter.UrgentCfg.Icon)
        local refreshTime = function()
            local v = XCountDown.GetRemainTime(tostring(chapter.Id))
            v = v > 0 and v or 0
            local timeText = XUiHelper.GetTime(v, XUiHelper.TimeFormatType.CHALLENGE)
            self.TxtTime.text = CS.XTextManager.GetText("BossSingleLeftTimeIcon", timeText)
        end
        refreshTime()
        self.Timer = CS.XScheduleManager.ScheduleForever(refreshTime, CS.XScheduleManager.SECOND, 0)
    elseif chapter.Type == XDataCenter.FubenManager.ChapterType.ARENA then
        -- 竞技副本
        self.TxtRank.text = ""
        self.TxtDes.text = chapter.SimpleDesc
        self.RImgChallenge:SetRawImage(chapter.Icon)
        self.ImgForbidEnter.gameObject:SetActive(false)

        local functionNameId = XFunctionManager.FunctionName.FubenArena
        if not XFunctionManager.JudgeCanOpen(functionNameId) then
            self.PanelLock.gameObject:SetActive(true)
            self.TxtLock.text = XFunctionManager.GetFunctionOpenCondition(functionNameId)
            self.TxtTime.text = ""
            self.TxtProgress.text = ""
        else    
            local status = XDataCenter.ArenaManager.GetArenaActivityStatus()
            if status == XArenaActivityStatus.Rest then
                self.TxtProgress.text = CS.XTextManager.GetText("ArenaTeamDescription")
            elseif status == XArenaActivityStatus.Fight then
                local isJoin = XDataCenter.ArenaManager.GetIsJoinActivity()
                if isJoin then
                    self.TxtProgress.text = CS.XTextManager.GetText("ArenaFightJoinDescription")
                else
                    self.TxtProgress.text = CS.XTextManager.GetText("ArenaFightNotJoinDescription")
                end
            elseif status == XArenaActivityStatus.Over then
                self.TxtProgress.text = CS.XTextManager.GetText("ArenaOverDescription")
            end

            XCountDown.BindTimer(self, XArenaConfigs.ArenaTimerName, function(v)
                v = v > 0 and v or 0
                local status = XDataCenter.ArenaManager.GetArenaActivityStatus()
                local timeText = ""
                if status == XArenaActivityStatus.Rest then
                    timeText = CS.XTextManager.GetText("ArenaActivityBeginCountDown") .. XUiHelper.GetTime(v, XUiHelper.TimeFormatType.CHALLENGE)
                elseif status == XArenaActivityStatus.Fight then
                    timeText = CS.XTextManager.GetText("ArenaActivityEndCountDown", XUiHelper.GetTime(v, XUiHelper.TimeFormatType.CHALLENGE))
                elseif status == XArenaActivityStatus.Over then
                    timeText = CS.XTextManager.GetText("ArenaActivityResultCountDown") .. XUiHelper.GetTime(v, XUiHelper.TimeFormatType.CHALLENGE)
                end
                self.TxtTime.text = timeText
            end)
        end 
    elseif chapter.Type == XDataCenter.FubenManager.ChapterType.Trial then
        self.TxtTime.text = ""
        self.TxtRank.text = ""
        self.TxtProgress.text = ""
        self.TxtDes.text = chapter.SimpleDesc
        self.RImgChallenge:SetRawImage(chapter.Icon)

        local functionNameId = XFunctionManager.FunctionName.FubenChallengeTrial
        if not XFunctionManager.JudgeCanOpen(functionNameId) then
            self.PanelLock.gameObject:SetActive(true)
            self.TxtLock.text = XFunctionManager.GetFunctionOpenCondition(functionNameId)
            self.TxtTime.text = ""
            self.TxtProgress.text = ""
        else
            if not self.InitRedPoint then
                self.InitRedPoint = true
                self.RedPointId = XRedPointManager.AddRedPointEvent(self.ImgRedPoint, nil, self, { XRedPointConditions.Types.CONDITION_TRIAL_RED })
            end
            XRedPointManager.Check(self.RedPointId)
            if XDataCenter.TrialManager.FinishTrialType() == XDataCenter.TrialManager.TrialTypeCfg.TrialBackEnd and XDataCenter.TrialManager.TrialRewardGetedFinish() then
                self.TxtProgress.text = CS.XTextManager.GetText("TrialBackEndPro", XDataCenter.TrialManager:TrialBackEndFinishLevel(), XTrialConfigs.GetBackEndTotalLength())
            else
                self.TxtProgress.text = CS.XTextManager.GetText("TrialForPro", XDataCenter.TrialManager:TrialForFinishLevel(), XTrialConfigs.GetForTotalLength())

            end
        end
    elseif chapter.Type == XDataCenter.FubenManager.ChapterType.BOSSSINGLE then
        self.RImgChallenge:SetRawImage(chapter.Icon)
        self.TxtRank.text = ""
        self.TxtTime.text = ""
        self.TxtProgress.text = ""
        self.TxtDes.text = chapter.SimpleDesc

        local functionNameId = XFunctionManager.FunctionName.FubenChallengeBossSingle
        if not XFunctionManager.JudgeCanOpen(functionNameId) then
            self.PanelLock.gameObject:SetActive(true)
            self.TxtLock.text = XFunctionManager.GetFunctionOpenCondition(functionNameId)
            self.TxtTime.text = ""
            self.TxtProgress.text = ""
        else
            if not self.InitRedPointBossSingle then
                self.InitRedPointBossSingle = true
                self.RedPointBossSingleId = XRedPointManager.AddRedPointEvent(self.ImgRedPoint, nil, self, { XRedPointConditions.Types.CONDITION_BOSS_SINGLE_REWARD })
            end

            -- 剩余时间
            XCountDown.BindTimer(self, XDataCenter.FubenBossSingleManager.GetResetCountDownName(), function(v)
                v = v > 0 and v or 0
                local timeText = XUiHelper.GetTime(v, XUiHelper.TimeFormatType.CHALLENGE)
                self.TxtTime.text = CS.XTextManager.GetText("BossSingleLeftTimeIcon", timeText)
            end)

            -- 进度
            local allCount = XDataCenter.FubenBossSingleManager.BOSS_SINGLE_CHALLENGE_COUNT
            local challengeCount = XDataCenter.FubenBossSingleManager.GetBoosSingleData().ChallengeCount
            self.TxtProgress.text = CS.XTextManager.GetText("BossSingleProgress", allCount - challengeCount, allCount)
        end
    elseif chapter.Type == XDataCenter.FubenManager.ChapterType.Explore then
        self.RImgChallenge:SetRawImage(chapter.Icon)
        self.TxtRank.text = ""
        self.TxtTime.text = ""
        self.TxtProgress.text = ""
        self.TxtDes.text = chapter.SimpleDesc
        
        local functionNameId = XFunctionManager.FunctionName.FubenExplore
        if not XFunctionManager.JudgeCanOpen(functionNameId) then
            self.PanelLock.gameObject:SetActive(true)
            self.TxtLock.text = XFunctionManager.GetFunctionOpenCondition(functionNameId)
            self.TxtTime.text = ""
            self.TxtProgress.text = ""
        else
            if not self.InitRedPointExplore then
                self.InitRedPointExplore = true
                self.RedPointExploreId = XRedPointManager.AddRedPointEvent(self.ImgRedPoint, nil, self, { XRedPointConditions.Types.CONDITION_EXPLORE_REWARD })
            end
            XRedPointManager.Check(self.RedPointExploreId)
            if XDataCenter.FubenExploreManager.GetCurProgressName() ~= nil then
                self.TxtProgress.text = CS.XTextManager.GetText("ExploreBannerProgress") .. XDataCenter.FubenExploreManager.GetCurProgressName()
            else
                self.TxtProgress.text = CS.XTextManager.GetText("ExploreBannerProgressEnd")
            end
        end
    elseif chapter.Type == XDataCenter.FubenManager.ChapterType.Practice then
        self.RImgChallenge:SetRawImage(chapter.Icon)
        self.TxtRank.text = ""
        self.TxtTime.text = ""
        self.TxtProgress.text = ""
        self.TxtDes.text = chapter.SimpleDesc
        local functionNameId = XFunctionManager.FunctionName.Practice

        if not XFunctionManager.JudgeCanOpen(functionNameId) then
            self.PanelLock.gameObject:SetActive(true)
            self.TxtLock.text = XFunctionManager.GetFunctionOpenCondition(functionNameId)
        end
    end
end

function XUiGridChallengeBanner:OnRecycle()
    self:UnBindTimer()
end


function XUiGridChallengeBanner:UnBindTimer()
    XCountDown.UnBindTimer(self, XArenaConfigs.ArenaTimerName)
    XCountDown.UnBindTimer(self, XDataCenter.FubenBossSingleManager.GetResetCountDownName())
    if self.RedPointExploreId then
        XRedPointManager.RemoveRedPointEvent(self.RedPointExploreId)
        self.InitRedPointExplore = nil
        self.RedPointExploreId = nil
    end

    if self.RedPointId then
        XRedPointManager.RemoveRedPointEvent(self.RedPointId)
        self.InitRedPoint = nil
        self.RedPointId = nil
    end

    if self.RedPointBossSingleId then
        XRedPointManager.RemoveRedPointEvent(self.RedPointBossSingleId)
        self.InitRedPointBossSingle = nil
        self.RedPointBossSingleId = nil
    end
end