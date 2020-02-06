local XUiSettleWinSingleBoss = XLuaUiManager.Register(XLuaUi, "UiSettleWinSingleBoss")

function XUiSettleWinSingleBoss:OnAwake()
    self:AutoAddListener()
end

function XUiSettleWinSingleBoss:OnStart(data, cb)
    self:ShowPanel(data)
end

function XUiSettleWinSingleBoss:OnEnable()
    XDataCenter.FunctionEventManager.UnLockFunctionEvent()
    self:PlayAnimation("PanelBossSingleinfo")
    --XUiHelper.PlayAnimation(self, "PanelBossSingleinfo")
end

function XUiSettleWinSingleBoss:OnDestroy()
    XDataCenter.AntiAddictionManager.EndFightAction()
end

function XUiSettleWinSingleBoss:AutoAddListener()
    self:RegisterClickEvent(self.BtnLeft, self.OnBtnLeftClick)
    self:RegisterClickEvent(self.BtnSave, self.OnBtnSaveClick)
    self:RegisterClickEvent(self.BtnCancel, self.OnBtnCancelClick)
end

function XUiSettleWinSingleBoss:ShowPanel(data)
    self.PanelNewTag.gameObject.transform.localScale = CS.UnityEngine.Vector3.zero
    self.StageId = data.StageId
    local time = CS.XGame.ClientConfig:GetFloat("BossSingleAnimaTime")
    local stageCfg = XDataCenter.FubenManager.GetStageCfg(data.StageId)
    local settleData = data.SettleData
    local bossSingleData = XDataCenter.FubenBossSingleManager.GetBoosSingleData()
    local difficultName = XDataCenter.FubenBossSingleManager.GetBossDifficultName(data.StageId)
    self.TxtDifficult.text = difficultName

    local totalTime = stageCfg.PassTimeLimit
    local leftTime = settleData.LeftTime <= 0 and 0 or settleData.LeftTime

    local charLeftHp = 0
    local charTotalHp = 0
    local bossLeftHp = 0
    local bossTotalHp = 0
    XTool.LoopMap(settleData.NpcHpInfo, function(k, v)
        if v.Type == 1 then
            charLeftHp = charLeftHp + v.LeftHp
            charTotalHp = charTotalHp + v.MaxHp
        elseif v.Type == 2 then
            bossLeftHp = bossLeftHp + v.LeftHp
            bossTotalHp = bossTotalHp + v.MaxHp
        end
    end)

    local bossLoseHp = bossTotalHp - bossLeftHp

    local stageData = XDataCenter.FubenManager.GetStageData(self.StageId)
    local myTotalHistory = stageData and stageData.Score or 0
    local stageInfo = XDataCenter.FubenBossSingleManager.GetBossStageInfo(data.StageId)
    local bossTotalSocre = stageInfo and stageInfo.Score or 0
    local bossLoseHpScore = stageInfo and stageInfo.BossLoseHpScore or 0
    local leftTimeScore = stageInfo and stageInfo.LeftTimeScore or 0
    local leftHpScore = stageInfo and stageInfo.LeftHpScore or 0

    local scoreData = {
        BossLoseHp = bossLoseHp,
        BossTotalHp = bossTotalHp,
        LeftTime = leftTime,
        TotalTime = totalTime,
        CharTotalHp = charTotalHp,
        CharLeftHp = charLeftHp
    }
    local scoreInfo = XDataCenter.FubenBossSingleManager.GetScoreInfo(data.StageId, scoreData)
    self.CurAllScore = scoreInfo.AllScore
    self.TxtBossAllLoseHpScore.text = CS.XTextManager.GetText("BossSingleAutoFightDesc10", bossLoseHpScore)
    self.TxAlltLeftTimeScore.text = CS.XTextManager.GetText("BossSingleAutoFightDesc10", leftTimeScore)
    self.TxtAllCharLeftHpScore.text = CS.XTextManager.GetText("BossSingleAutoFightDesc10", leftHpScore)

    self.GameObject:SetActive(true)
    -- 播放音效
    self.AudioInfo = CS.XAudioManager.PlaySound(XSoundManager.UiBasicsMusic.UiSettle_Win_Number)
    XUiHelper.Tween(time, function(f)
        if XTool.UObjIsNil(self.Transform) then
            return
        end

        local totalTimeText = XUiHelper.GetTime(math.floor(f * totalTime))
        local bossLoseHpText = math.floor(f * (bossLoseHp / bossTotalHp * 100)) .. "%"
        local bossLoseHpScoreText = '+' .. math.floor(f * scoreInfo.BossLoseHpScore)
        local leftTimeText = XUiHelper.GetTime(math.floor(f * leftTime))
        local leftTimeScoreText = '+' .. math.floor(f * scoreInfo.LeftTimeScore)
        local charLeftHpText = math.floor(f *  (charLeftHp / charTotalHp * 100)) .. "%"
        local charLeftHpScoreText = '+' .. math.floor(f * scoreInfo.CharLeftHpScore)
        local allSocreText = math.floor(f * scoreInfo.AllScore)
        local historyScoreText = math.floor(f * myTotalHistory) .. "/" .. bossTotalSocre

        self.TxtStageTime.text = totalTimeText
        self.TxtBossLoseHp.text = bossLoseHpText
        self.TxtBossLoseHpScore.text = bossLoseHpScoreText
        self.TxtLeftTime.text = leftTimeText
        self.TxtLeftTimeScore.text = leftTimeScoreText
        self.TxtCharLeftHp.text = charLeftHpText
        self.TxtCharLeftHpScore.text = charLeftHpScoreText
        self.TxtAllScore.text = allSocreText
        self.TxtHistoryScore.text = historyScoreText
    end, function()
        if XTool.UObjIsNil(self.Transform) or XTool.UObjIsNil(self.PanelNewTag) then
            return
        end

        local stageData = XDataCenter.FubenManager.GetStageData(self.StageId)
        local myTotalHistory = stageData and stageData.Score or 0

        if self.CurAllScore > myTotalHistory then
            self.PanelNewTag.gameObject.transform.localScale = CS.UnityEngine.Vector3.one
            self.PanelNewTag.gameObject:PlayTimelineAnimation()
        end

        self:StopAudio()
    end)
end

function XUiSettleWinSingleBoss:SetDefualtText()
    self.TxtStageTime.text = XUiHelper.GetTime(0)
    self.TxtBossLoseHp.text = 0
    self.TxtBossLoseHpScore.text = '+' .. 0
    self.TxtLeftTime.text = XUiHelper.GetTime(0)
    self.TxtLeftTimeScore.text = '+' .. 0
    self.TxtCharLeftHp.text = 0
    self.TxtCharLeftHpScore.text = '+' .. 0
    self.TxtAllScore.text = 0
    self.TxtHistoryScore.text = 0
end

function XUiSettleWinSingleBoss:StopAudio()
    if self.AudioInfo then
        self.AudioInfo:Stop()
    end
end

function XUiSettleWinSingleBoss:OnBtnLeftClick(...)
    self:StopAudio()
    XLuaUiManager.Close("UiSettleWinSingleBoss")
    XTipManager.Execute()
end

function XUiSettleWinSingleBoss:OnBtnSaveClick(...)
    XDataCenter.FubenBossSingleManager.SaveScore(self.StageId, function()
        self:OnBtnLeftClick()
    end)
end

function XUiSettleWinSingleBoss:OnBtnCancelClick(...)
    local stageData = XDataCenter.FubenManager.GetStageData(self.StageId)
    local myTotalHistory = stageData and stageData.Score or 0

    if self.CurAllScore <= myTotalHistory then
        self:OnBtnLeftClick()
    else
        local titletext = CS.XTextManager.GetText("TipTitle")
        local contenttext = CS.XTextManager.GetText("BossSingleReslutDesc")
        XUiManager.DialogTip(titletext, contenttext, XUiManager.DialogType.Normal, nil, function()
            self:OnBtnLeftClick()
        end)
    end
end