local XUiBabelTowerFightTips = XLuaUiManager.Register(XLuaUi, "UiFightBabelTower")
local XUiBabelTowerTipsItem = require("XUi/XUiFubenBabelTower/XUiBabelTowerTipsItem")

local BuffShowRate = CS.XGame.ClientConfig:GetInt("BabelTowerBuffShowRate") / 10
local BuffDisapearTime = CS.XGame.ClientConfig:GetInt("BabelTowerBuffDisappearTime")
local ANIM_BEGIN_ENABLE = "AnimBeginEnable"
local ANIM_END_ENABLE = "AnimEndEnable"

function XUiBabelTowerFightTips:OnAwake()
    self.ChallengeBuffList = {}
    self.SupportBuffList = {}

    for i = XFubenBabelTowerConfigs.START_INDEX, XFubenBabelTowerConfigs.MAX_CHALLENGE_BUFF_COUNT do
        self.ChallengeBuffList[i] = XUiBabelTowerTipsItem.New(self[string.format("Challenge%d", i)], XFubenBabelTowerConfigs.TYPE_CHALLENGE)
        self.ChallengeBuffList[i].GameObject:SetActiveEx(false)
    end

    for i = XFubenBabelTowerConfigs.START_INDEX, XFubenBabelTowerConfigs.MAX_SUPPORT_BUFF_COUNT do
        self.SupportBuffList[i] = XUiBabelTowerTipsItem.New(self[string.format("Support%d", i)], XFubenBabelTowerConfigs.TYPE_SUPPORT)
        self.SupportBuffList[i].GameObject:SetActiveEx(false)
    end

    self.BtnBack.CallBack = function() self:OnBtnBackClick() end
    self.BtnPrepareMask.CallBack = function() self:OnBtnBackClick() end
end

function XUiBabelTowerFightTips:OnBtnBackClick()
    self:StopTimer()
    self:PlayAnimation("AnimEffertEnable", function()
        self:Close()
    end)
end


function XUiBabelTowerFightTips:OnStart(stageId, battleStatus)

    self.StageId = stageId
    self.BattleStatus = battleStatus
    self.CurStageId, self.CurStageGuideId, self.CurTeamList, self.ChallengeBuffs, self.SupportBuffs = XDataCenter.FubenBabelTowerManager.GetCurStageInfo()

    if self.StageId ~= self.CurStageId then
        XLog.Error("stageId do not match...self.StageId = " .. tostring(self.StageId) .. "; self.CurStageId = " .. tostring(self.CurStageId))
        self:Close()
        return 
    end

    self:ClearFightTips()

    local animName = self.BattleStatus == XFubenBabelTowerConfigs.BattleReady and ANIM_BEGIN_ENABLE or ANIM_END_ENABLE
    self:PlayAnimation(animName, function()
        self:SetBabelTowerFightTips()
    end)

end

function XUiBabelTowerFightTips:ClearFightTips()
    self.ModeTitle2.gameObject:SetActiveEx(false)
    self.OverTitle.gameObject:SetActiveEx(false)
    self.BtnPrepareMask.gameObject:SetActiveEx(false)
    for i = 1, XFubenBabelTowerConfigs.MAX_CHALLENGE_BUFF_COUNT do
        self.ChallengeBuffList[i].GameObject:SetActiveEx(false)
    end
    for i = 1, XFubenBabelTowerConfigs.MAX_SUPPORT_BUFF_COUNT do
        self.SupportBuffList[i].GameObject:SetActiveEx(false)
    end
end

function XUiBabelTowerFightTips:GetChallengePoints(buffList)
    self.ModeTitle2.gameObject:SetActiveEx(self.BattleStatus == XFubenBabelTowerConfigs.BattleReady)
    self.OverTitle.gameObject:SetActiveEx(self.BattleStatus == XFubenBabelTowerConfigs.BattleEnd)
    local totalChallengePoints = 0
    for k, buffInfo in pairs(buffList) do
        local buffId = buffInfo.BufferId
        local buffTemplates = XFubenBabelTowerConfigs.GetBabelTowerBuffTemplate(buffId)
        totalChallengePoints = totalChallengePoints + buffTemplates.ScoreAdd
    end
    return totalChallengePoints
end

function XUiBabelTowerFightTips:SetBabelTowerFightTips()

    if self.BattleStatus == XFubenBabelTowerConfigs.BattleReady then
        local curActivityNo = XDataCenter.FubenBabelTowerManager.GetCurrentActivityNo()
        local challengePoints = self:GetChallengePoints(self.ChallengeBuffs)
        local difficulty, difficultyTitle, difficultyStatus = XFubenBabelTowerConfigs.GetBabelTowerDifficulty(self.StageId, challengePoints)
        self.TxtStatusTitle.text = difficultyTitle
        self.TxtStatusWarning.text = difficultyStatus

        self:SetBattlePrepareBuff(self.ChallengeBuffs, self.SupportBuffs)
    end

    if self.BattleStatus == XFubenBabelTowerConfigs.BattleEnd then
        -- 拿服务端同步下来的BuffList
        local babelStageInfos = XDataCenter.FubenBabelTowerManager.GetBabelTowerStageInfo(self.StageId)
        local challengeBuffs = (babelStageInfos==nil) and self.ChallengeBuffs or babelStageInfos.ChallengeBuffInfos
        self.TxtFinishLevel.text = self:GetChallengePoints(challengeBuffs)
        self:SetBattleEndBuff()
    end
end

function XUiBabelTowerFightTips:SetBattlePrepareBuff(challengeBuffs, supportBuffs)
    self.ChallengeBuffList[0].GameObject:SetActiveEx(true)
    self.SupportBuffList[0].GameObject:SetActiveEx(true)

    self:StopTimer()
    local currentShowBuffIndex = 0
    local timerGap = CS.XGame.ClientConfig:GetInt("BabelTowerBuffShowTime")
    self.Timer = CS.XScheduleManager.ScheduleForever(function(...)
        if currentShowBuffIndex > #challengeBuffs and currentShowBuffIndex > #supportBuffs then
            self:StopTimer()
            if self.BattleStatus == XFubenBabelTowerConfigs.BattleReady then
                self:SetAutoCloseTimer()
            end
            return 
        end
        if currentShowBuffIndex > XFubenBabelTowerConfigs.START_INDEX then
            if currentShowBuffIndex <= XFubenBabelTowerConfigs.MAX_CHALLENGE_BUFF_COUNT then
                self.ChallengeBuffList[currentShowBuffIndex].GameObject:SetActiveEx(challengeBuffs[currentShowBuffIndex] ~= nil)
                if challengeBuffs[currentShowBuffIndex] then
                    self.ChallengeBuffList[currentShowBuffIndex]:RefreshBuffInfo(challengeBuffs[currentShowBuffIndex], XFubenBabelTowerConfigs.TYPE_CHALLENGE)
                end
            end
            if currentShowBuffIndex <= XFubenBabelTowerConfigs.MAX_SUPPORT_BUFF_COUNT then
                self.SupportBuffList[currentShowBuffIndex].GameObject:SetActiveEx(supportBuffs[currentShowBuffIndex] ~= nil)
                if supportBuffs[currentShowBuffIndex] then
                    self.SupportBuffList[currentShowBuffIndex]:RefreshBuffInfo(supportBuffs[currentShowBuffIndex], XFubenBabelTowerConfigs.TYPE_SUPPORT)
                end
            end
            timerGap = timerGap * BuffShowRate
        end
        currentShowBuffIndex = currentShowBuffIndex + 1
    end, timerGap, 0)
end

function XUiBabelTowerFightTips:SetAutoCloseTimer()

    self:StopAutoCloseTimer()
    self.AutoCloseTimer = CS.XScheduleManager.ScheduleOnce(function()
        self.BtnPrepareMask.gameObject:SetActiveEx(true)
        self:Close()
    end, BuffDisapearTime)
end

function XUiBabelTowerFightTips:SetBattleEndBuff()
    local babelStageInfos = XDataCenter.FubenBabelTowerManager.GetBabelTowerStageInfo(self.StageId)
    if babelStageInfos then
        self.ChallengeBuffs = babelStageInfos.ChallengeBuffInfos
        self.SupportBuffs = babelStageInfos.SupportBuffInfos
    end
    self:SetBattlePrepareBuff(self.ChallengeBuffs, self.SupportBuffs)
end

function XUiBabelTowerFightTips:StopAutoCloseTimer()
    if self.AutoCloseTimer then
        CS.XScheduleManager.UnSchedule(self.AutoCloseTimer)
        self.AutoCloseTimer = nil
    end
end

function XUiBabelTowerFightTips:StopTimer()
    if self.Timer then
        CS.XScheduleManager.UnSchedule(self.Timer)
        self.Timer = nil
    end
end

function XUiBabelTowerFightTips:OnEnable()
    if CS.XFight.IsRunning then
        CS.XFight.Instance:Pause()
    end
end

function XUiBabelTowerFightTips:OnDisable()
    if CS.XFight.Instance then
        CS.XFight.Instance:Resume()
    end
end

function XUiBabelTowerFightTips:OnDestroy()
    self:StopTimer()
    self:StopAutoCloseTimer()
end
