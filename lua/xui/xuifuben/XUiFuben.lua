local ANIMATION_TIME = 0.5

local XUiFuben = XLuaUiManager.Register(XLuaUi, "UiFuben")

XUiFuben.BtnTabIndex = {
    Activity = 1,
    Challenge = 2,
    Daily = 3,
    MainLine = 4,
}

function XUiFuben:OnAwake()
    self:InitAutoScript()
    self:InitTabBtnGroup()
end

function XUiFuben:OnStart(type, stageId, subType)
    self.CurType = type
    self.CurSubType = subType
    self.CurStageId = stageId
    self.MainLineChapterInst = nil
    self.ActivityCapterInst = nil
    self.ChallengeChapterInst = nil
    self.BtnTrial.gameObject:SetActive(false)
    self.CurDiff = XDataCenter.FubenManager.DifficultNormal
    CsXUiManager.Instance:SetMask(false)
    self.FirstIn = true
    self:OnOpenInit()
end

function XUiFuben:OnEnable()
    XRedPointManager.Check(self.RedPointId)
    XRedPointManager.Check(self.RedPointChallengeId)

    if self.FirstIn then 
        self.FirstIn = false
        self:PlayAnimation("AnimStartEnable")
    else
        self:PlayAnimation("ExcessiveEnable")
    end
end

function XUiFuben:InitTabBtnGroup()
    self.BtnTabActivity:SetDisable(not XFunctionManager.JudgeCanOpen(XFunctionManager.FunctionName.FubenActivity))
    self.BtnTabChallenge:SetDisable(not XFunctionManager.JudgeCanOpen(XFunctionManager.FunctionName.FubenChallenge))
    self.BtnTabDaily:SetDisable(not XFunctionManager.JudgeCanOpen(XFunctionManager.FunctionName.FubenDaily))

    local tabGroup = {
        self.BtnTabActivity,
        self.BtnTabChallenge,
        self.BtnTabDaily,
        self.BtnTabMainLine,
    }
    self.PanelBottomRight:Init(tabGroup, function(tabIndex) self:OnClickTabCallBack(tabIndex) end)

    self.RedPointId = XRedPointManager.AddRedPointEvent(self.BtnTabMainLine, self.RefreshBtnTabMainLineRedDot, self, { XRedPointConditions.Types.CONDITION_MAIN_CHAPTER })
    self.RedPointChallengeId = XRedPointManager.AddRedPointEvent(self.BtnTabChallenge, self.RefreshBtnTabChallengeRedDot, self,
    { XRedPointConditions.Types.CONDITION_EXPLORE_REWARD, XRedPointConditions.Types.CONDITION_TRIAL_RED })
end

function XUiFuben:OnClickTabCallBack(tabIndex)
    if self.SelectedIndex and self.SelectedIndex == tabIndex then
        return
    end

    if tabIndex == self.BtnTabIndex.Activity then
        if not XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.FubenActivity) then
            return
        end
        self.BtnTrial.gameObject:SetActive(false)
        XDataCenter.FubenBossOnlineManager.RefreshBossData(function()
            self:OpenOneChildUi("UiFubenActivityBanner", true)
        end)
    elseif tabIndex == self.BtnTabIndex.Challenge then
        if not XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.FubenChallenge) then
            return
        end
        self.BtnTrial.gameObject:SetActive(true)
        self:OpenOneChildUi("UiFubenChallengeBanner", true)
    elseif tabIndex == self.BtnTabIndex.Daily then
        if not XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.FubenDaily) then
            return
        end
        self.BtnTrial.gameObject:SetActive(false)
        self:OpenOneChildUi("UiFubenDailyBanner", true)
    elseif tabIndex == self.BtnTabIndex.MainLine then
        self.BtnTrial.gameObject:SetActive(false)
        self:OpenOneChildUi("UiFubenMainLineBanner", true, self.CurSubType)
        self.CurSubType = nil
    end

    self.SelectedIndex = tabIndex
end

function XUiFuben:RefreshBtnTabMainLineRedDot(count)
    self.BtnTabMainLine:ShowReddot(count >= 0)


end

function XUiFuben:RefreshBtnTabChallengeRedDot(count)
    self.BtnTabChallenge:ShowReddot(count >= 0)
end

function XUiFuben:OnOpenInit()
    CsXUiManager.Instance:SetMask(true)
    self.IsLoadFinish = true
    local defaultSelectIndex
    if self.CurStageId then
        -- 指定关卡
        local stageInfo = XDataCenter.FubenManager.GetStageInfo(self.CurStageId)
        if stageInfo.Type == XDataCenter.FubenManager.StageType.Mainline then
            -- chapter
            self.CurDiff = stageInfo.Difficult
            self:RefreshForChangeDiff()
            self.PanelBottomRightRT.gameObject:SetActive(false)
        elseif stageInfo.Type == XDataCenter.FubenManager.StageType.Daily
        or stageInfo.Type == XDataCenter.FubenManager.StageType.Tower
        or stageInfo.Type == XDataCenter.FubenManager.StageType.BossSingle
        or stageInfo.Type == XDataCenter.FubenManager.StageType.Urgent then
            defaultSelectIndex = self.BtnTabIndex.Challenge
        elseif stageInfo.Type == XDataCenter.FubenManager.StageType.BossOnline then
            defaultSelectIndex = self.BtnTabIndex.Activity
        end
    elseif self.CurType then
        -- 副本类型
        if self.CurType == XDataCenter.FubenManager.StageType.Mainline then
            defaultSelectIndex = self.BtnTabIndex.MainLine
        elseif self.CurType == XDataCenter.FubenManager.StageType.Daily then
            defaultSelectIndex = self.BtnTabIndex.Challenge
        elseif self.CurType == XDataCenter.FubenManager.StageType.BossOnline then
            defaultSelectIndex = self.BtnTabIndex.Activity
        elseif self.CurType == XDataCenter.FubenManager.StageType.Resource then
            defaultSelectIndex = self.BtnTabIndex.Daily
        end
    else
        defaultSelectIndex = self.BtnTabIndex.MainLine
    end

    if defaultSelectIndex then
        self.PanelBottomRight:SelectIndex(defaultSelectIndex)
    end
end

function XUiFuben:OpenOneChildUi(childUiName, needAnimation, args)
    self.super.OpenOneChildUi(self, childUiName, args)
    if needAnimation then
        -- self:PlayAnimation("ChildUiParentEnable")
    end
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiFuben:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiFuben:AutoInitUi()
    self.BtnMainUi = self.Transform:Find("SafeAreaContentPane/Root/Top/BtnMainUi"):GetComponent("Button")
    self.BtnBack = self.Transform:Find("SafeAreaContentPane/Root/Top/BtnBack"):GetComponent("Button")
    self.PanelContent = self.Transform:Find("SafeAreaContentPane/PanelContent")
    self.PanelAsset = self.Transform:Find("SafeAreaContentPane/Root/PanelAsset")
    self.BtnTrial = self.Transform:Find("SafeAreaContentPane/Root/BtnTrial"):GetComponent("Button")
end

function XUiFuben:AutoAddListener()
    self:RegisterClickEvent(self.BtnMainUi, self.OnBtnMainUiClick)
    self:RegisterClickEvent(self.BtnBack, self.OnBtnBackClick)
    self:RegisterClickEvent(self.TogActivity, self.OnTogActivityClick)
    self:RegisterClickEvent(self.TogChallenge, self.OnTogChallengeClick)
    self:RegisterClickEvent(self.TogMainLine, self.OnTogMainLineClick)
    self:RegisterClickEvent(self.TogDaily, self.OnTogDailyClick)
    self:RegisterClickEvent(self.BtnTrial, self.OnBtnTrialClick)
end
-- auto
function XUiFuben:OnBtnTrialClick(eventData)
    if not XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.FubenActivityTrial) then
        return
    end
    XLuaUiManager.Open("UiFubenExperiment")
end

-- 播放完动画再打开界面
function XUiFuben:PushUi(cb)
    if self.IsPlaying then return end
    self.IsPlaying = true
    self:PlayAnimation("ExcessiveDisable",function()
        cb()
        self.IsPlaying = false
    end)
end

function XUiFuben:RefreshForChangeDiff()
    if self.MainLineChapterInst then
        self.MainLineChapterInst:InitChapterList(self.CurDiff)
    end
end

function XUiFuben:OnBtnBackClick(...)
    if not self.IsLoadFinish then
        return
    end
    CsXUiManager.Instance:Pop()
end

function XUiFuben:OnBtnMainUiClick(...)
    if not self.IsLoadFinish then
        return
    end
    XLuaUiManager.RunMain()
end