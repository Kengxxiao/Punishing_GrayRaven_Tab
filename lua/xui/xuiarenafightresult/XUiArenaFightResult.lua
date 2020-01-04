local XUiArenaFightResult = XLuaUiManager.Register(XLuaUi, "UiArenaFightResult")

function XUiArenaFightResult:OnAwake()
    self:AutoAddListener()
end

function XUiArenaFightResult:OnStart(winData)
    self.WinData = winData
end

function XUiArenaFightResult:OnEnable()
    self:Refresh()
end

function XUiArenaFightResult:AutoAddListener()
    self:RegisterClickEvent(self.BtnNext, self.OnBtnNextClick)
    self:RegisterClickEvent(self.BtnReFight, self.OnBtnReFightClick)
    self:RegisterClickEvent(self.BtnExitFight, self.OnBtnExitFightClick)
end

function XUiArenaFightResult:OnBtnNextClick(eventData)
    if XDataCenter.ArenaManager.JudgeGotoMainWhenFightOver() then
        return
    end

    self:StopAudio()
    self:Close()
    local info = XDataCenter.ArenaManager.GetEnterAreaStageInfo()
    local areaCfg = XArenaConfigs.GetArenaAreaStageCfgByAreaId(info.AreaId)
    local index = info.StageIndex + 1
    XDataCenter.ArenaManager.SetEnterAreaStageInfo(info.AreaId, index)
    XLuaUiManager.Open("UiNewRoomSingle", areaCfg.StageId[index])
end

function XUiArenaFightResult:OnBtnReFightClick(eventData)
    if XDataCenter.ArenaManager.JudgeGotoMainWhenFightOver() then
        return
    end

    self:StopAudio()
    self:Close()
    local info = XDataCenter.ArenaManager.GetEnterAreaStageInfo()
    local areaCfg = XArenaConfigs.GetArenaAreaStageCfgByAreaId(info.AreaId)
    XDataCenter.ArenaManager.SetEnterAreaStageInfo(info.AreaId, info.StageIndex)
    XLuaUiManager.Open("UiNewRoomSingle", areaCfg.StageId[info.StageIndex])
end

function XUiArenaFightResult:OnBtnExitFightClick(eventData)
    if XDataCenter.ArenaManager.JudgeGotoMainWhenFightOver() then
        return
    end

    self:StopAudio()
    self:Close()
end

function XUiArenaFightResult:StopAudio()
    if self.AudioInfo then
        self.AudioInfo:Stop()
    end
end

function XUiArenaFightResult:Refresh()
    if not self.WinData or not self.WinData.SettleData or
        not self.WinData.SettleData.ArenaResult then
        return
    end

    local time = CS.XGame.ClientConfig:GetFloat("BossSingleAnimaTime")
    local data = self.WinData.SettleData.ArenaResult
    local info = XDataCenter.ArenaManager.GetEnterAreaStageInfo()
    self.TxtTile.text = CS.XTextManager.GetText("ArenaActivityStage", info.StageIndex)
    self.PanelNewRecord.gameObject:SetActiveEx(data.Point > data.OldPoint)
    local markCfg = XDataCenter.ArenaManager.GetMarkCfg()

    local isShowEnemyHp = (markCfg and markCfg.EnemyHpPoint ~= nil) and markCfg.EnemyHpPoint ~= ""
    local isShowMyHp = (markCfg and markCfg.MyHpPoint ~= nil) and markCfg.MyHpPoint ~= ""
    local isShowLeftTime = (markCfg and markCfg.TimePoint ~= nil) and markCfg.TimePoint ~= ""
    local isShowGourp = (markCfg and markCfg.NpcGroupPoint ~= nil) and markCfg.NpcGroupPoint ~= ""

    self.PanelBossLoseHp.gameObject:SetActiveEx(isShowEnemyHp)
    self.PanelSurplusHp.gameObject:SetActiveEx(isShowMyHp)
    self.PanelLeftTime.gameObject:SetActiveEx(isShowLeftTime)
    self.PanelGroupCount.gameObject:SetActiveEx(isShowGourp)

    local SetMaxTextDesc = function(text, ponit)
        if ponit > 0 then
            text.text = CS.XTextManager.GetText("ArenaMaxSingleScore", ponit)
        else
            text.text = CS.XTextManager.GetText("ArenaMaxSingleNoScore")
        end
    end

    SetMaxTextDesc(self.TxtHitSocreMax, markCfg ~= nil and markCfg.MaxEnemyHpPoint or 0)
    SetMaxTextDesc(self.TxtRemainHpScoreMax, markCfg ~= nil and markCfg.MaxMyHpPoint or 0)
    SetMaxTextDesc(self.TxtRemainTimeScoreMax, markCfg ~= nil and markCfg.MaxTimePoint or 0)
    SetMaxTextDesc(self.TxtGroupCountScoreMax, markCfg ~= nil and markCfg.MaxNpcGroupPoint or 0)

    if markCfg and data.Point > data.OldPoint then
        XDataCenter.ArenaManager.ChangeArenaStageScore(info.AreaId, info.StageIndex, data.Point)
    end
    -- 刷新副本入口数据
    XDataCenter.ArenaManager.RequestGroupMember()
    -- 播放音效
    self.AudioInfo = CS.XAudioManager.PlaySound(XSoundManager.UiBasicsMusic.UiSettle_Win_Number)

    XUiHelper.Tween(time, function(f)
        if XTool.UObjIsNil(self.Transform) then
            return
        end

        -- 歼敌奖励
        if isShowEnemyHp then
            local hitCombo = math.floor(f * data.EnemyHurt)
            local hitSocre = '+' .. math.floor(f * data.EnemyPoint)
            self.TxtHitCombo.text = hitCombo
            self.TxtHitScore.text = hitSocre
        end

        -- 我方血量
        if isShowMyHp then
            local remainHp = math.floor(f * data.MyHpLeft) .. "%"
            local remainHpScore = '+' .. math.floor(f * data.MyHpPoint)
            self.TxtRemainHp.text = remainHp
            self.TxtRemainHpScore.text = remainHpScore
        end

        -- 剩余时间
        if isShowLeftTime then
            local remainTime = XUiHelper.GetTime(math.floor(f * data.TimeLeft), XUiHelper.TimeFormatType.SHOP)
            local remainTimeSacore = '+' ..  math.floor(f * data.TimePoint)
            self.TxtRemainTime.text = remainTime
            self.TxtRemainTimeScore.text = remainTimeSacore
        end

        -- 波次奖励
        if isShowGourp then
            local groupCount = CS.XTextManager.GetText("ArenaGrouplScore", math.floor(f * data.NpcGroup))
            local groupCountSacore = '+' ..  math.floor(f * data.NpcGroupPoint)
            self.TxtGroupCount.text = groupCount
            self.TxtGroupCountScore.text = groupCountSacore
        end

        -- 通关时间
        local costTime = XUiHelper.GetTime(math.floor(f * data.FightTime), XUiHelper.TimeFormatType.SHOP)
        self.TxtCostTime.text = costTime

        -- 当前总分
        local point = math.floor(f * data.Point)
        if markCfg and data.Point >= markCfg.MaxPoint and  markCfg.MaxPoint > 0 then
            self.TxtPoint.text = CS.XTextManager.GetText("ArenaMaxAllScore", point)
        else
            self.TxtPoint.text = point
        end

        -- 历史最高分
        local highScore = math.floor(f * data.OldPoint)
        if markCfg and data.OldPoint >= markCfg.MaxPoint and  markCfg.MaxPoint > 0 then
            self.TxtHighScore.text = highScore .. "/" .. markCfg.MaxPoint
        else
            self.TxtHighScore.text = highScore
        end
    end, function ()
        self:StopAudio()
    end)
end