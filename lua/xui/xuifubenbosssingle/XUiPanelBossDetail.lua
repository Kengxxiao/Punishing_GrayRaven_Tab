local XUiPanelBossDetail = XClass()
local XUiGridBossSkill = require("XUi/XUiFubenBossSingle/XUiGridBossSkill")
local XUiPanelAutoFight = require("XUi/XUiFubenBossSingle/XUiPanelAutoFight")

local ONE_MINUTE_SECOND = 60

function XUiPanelBossDetail:Ctor(rootUi, ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    self.SkillGridList = {}
    XTool.InitUiObject(self)
    self:AutoAddListener()
    self.ToggleTabList = {
        self.GridBoosLevel1,
        self.GridBoosLevel2,
        self.GridBoosLevel3,
        self.GridBoosLevel4,
        self.GridBoosLevel5,
    }
    self.GridBossSkill.gameObject:SetActive(false)
    self:InitAutoFight()
end

function XUiPanelBossDetail:OnShow()
    self:OnBtnClickClick()
end

function XUiPanelBossDetail:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelBossDetail:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelBossDetail:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelBossDetail:AutoAddListener()
    self:RegisterClickEvent(self.BtnStart, self.OnBtnStartClick)
    self:RegisterClickEvent(self.BtnClick, self.OnBtnClickClick)
    self:RegisterClickEvent(self.BtnAuto, self.OnBtnAutoClick)
end

function XUiPanelBossDetail:HidePanel()
    self.GameObject:SetActive(false)
end

function XUiPanelBossDetail:InitAutoFight()
    self.PanelAutoFight = XUiPanelAutoFight.New(self.PanelAutoFight, self.RootUi, function()
        local text = CS.XTextManager.GetText("BossSingleAutoSuccess")
        local msgType = XUiManager.UiTipType.Success
        XUiManager.TipMsg(text, msgType, function()
            local time = CS.XGame.ClientConfig:GetFloat("BossSingleAnimaTime")
            XUiHelper.Tween(time, function(f)
                if XTool.UObjIsNil(self.Transform) or not self.GameObject.activeSelf then
                    return
                end

                local score = self.CurBossStageCfg.Score
                local stageData = XDataCenter.FubenManager.GetStageData(self.CurBossStageCfg.StageId)
                local curScore = stageData and stageData.Score or 0
                local text = CS.XTextManager.GetText("BossSingleBossScore",  math.floor(f * curScore), score)
                self.TxtMyScore.text = text
            end)
        end)
    end)
    self.PanelAutoFight:Close()
end

function XUiPanelBossDetail:ShowPanel(bossSingleData, bossId)
    self.Index = nil
    if bossId then 
        self.BossId = bossId
    end

    if bossSingleData then
        self.BossSingleData = bossSingleData
    end

    self.TxtAllScore.text = self.BossSingleData.TotalScore
    self:SetToggle()
    self.GameObject:SetActive(true)
    self.RootUi:PlayAnimation("AnimDeatilEnable")
end

function XUiPanelBossDetail:Refresh(bossSingleData)
    self.BossSingleData = bossSingleData
    self.TxtAllScore.text = self.BossSingleData.TotalScore

    -- 刷新挑战次数
    self.TxtAllNums.text = "/" .. XDataCenter.FubenBossSingleManager.BOSS_SINGLE_CHALLENGE_COUNT
    self.TxtLeftNums.text = XDataCenter.FubenBossSingleManager.BOSS_SINGLE_CHALLENGE_COUNT - self.BossSingleData.ChallengeCount

    -- 刷新分数
    if not self.CurBossStageCfg then
        return
    end

    local score = self.CurBossStageCfg.Score
    local stageData = XDataCenter.FubenManager.GetStageData(self.CurBossStageCfg.StageId)
    local curScore = stageData and stageData.Score or 0
    local text = CS.XTextManager.GetText("BossSingleBossScore",  curScore, score)
    self.TxtMyScore.text = text
end

function XUiPanelBossDetail:SetToggle()
    if self.TabBtnGroup then
        self.TabBtnGroup:Dispose()
    end
    self.TabBtnGroup = nil
    self.BtnTabList = {}
    local sectionInfo = XDataCenter.FubenBossSingleManager.GetBossSectionInfo(self.BossId)
    for i = 1, #sectionInfo do
        local bossStageCfg = sectionInfo[i]
        local grid = self.ToggleTabList[i]
        if not grid then
            grid = CS.UnityEngine.Object.Instantiate(self.GridBoosLevel)
            grid.transform:SetParent(self.PanelTags, false)
            self.ToggleTabList[i] = grid
        end
        grid.gameObject:SetActive(true)
        table.insert(self.BtnTabList, grid)
    end

    for i = #sectionInfo + 1, #self.ToggleTabList do
        self.ToggleTabList[i].GameObject:SetActive(false)
    end

    -- 设置Togge按钮
    self.TabBtnGroup = XUiTabBtnGroup.New(self.BtnTabList, function(index)
        self:RefrshBossInfo(index)
    end, function(index)
        return self:CheckClick(index, true)
    end, true)

    -- 设置Toggle名字
    for k, btn in ipairs(self.TabBtnGroup.TabBtnList) do
        local bossStageCfg = XDataCenter.FubenBossSingleManager.GetBossStageCfg(sectionInfo[k].StageId)
        btn:SetName(bossStageCfg.DifficultyDesc, bossStageCfg.DifficultyDescEn)

        if k ~= XGlobalVar.BossSingleIndex.experiment then
            if self:CheckClick(k, false) then
                self.TabBtnGroup:UnLockIndex(k)
            else
                self.TabBtnGroup:LockIndex(k)
            end
        end
    end

    -- 设置默认Toggle
    if self.Index then
        self.TabBtnGroup:SelectIndex(self.Index)
    else
        local index = XDataCenter.FubenBossSingleManager.GetCurBossIndex(self.BossId)
        self.TabBtnGroup:SelectIndex(index)
    end
end

function XUiPanelBossDetail:RefrshBossInfo(index)
    self.RootUi:PlayAnimation("AnimQieHuan")
    local sectionInfo = XDataCenter.FubenBossSingleManager.GetBossSectionInfo(self.BossId)
    self.Index = index
    self.CurBossStageCfg = sectionInfo[index]
    self:RefreshDesc()
    self:RefreshInfo()
    self.RootUi:RefreshModel(self.CurBossStageCfg.ModelId)
end

function XUiPanelBossDetail:RefreshDesc()
    local stageId = self.CurBossStageCfg.StageId
    local stageCfg = XDataCenter.FubenManager.GetStageCfg(stageId)

    local time = math.floor(stageCfg.PassTimeLimit / ONE_MINUTE_SECOND)
    local text = CS.XTextManager.GetText("BossSingleMinute", time)
    local sectionCfg = XDataCenter.FubenBossSingleManager.GetBossSectionCfg(self.BossId)
    local recommendationLevel = XDataCenter.FubenBossSingleManager.GetProposedLevel(stageId)
    self.TxtTimeLimit.text = text
    self.TxtBossName.text = self.CurBossStageCfg.BossName
    self.TxtBossDes.text = sectionCfg.Desc
    self.TxtLevel.text = recommendationLevel
    self.TxtATNums.text = stageCfg.RequireActionPoint
    self.TxtAllNums.text = "/" .. XDataCenter.FubenBossSingleManager.BOSS_SINGLE_CHALLENGE_COUNT
    self.TxtLeftNums.text = XDataCenter.FubenBossSingleManager.BOSS_SINGLE_CHALLENGE_COUNT - self.BossSingleData.ChallengeCount
    self.TxtRepeatDesc.text = string.gsub(CS.XTextManager.GetText("BossSingleRepeartDesc"), "\\n", "\n")

    for i = 1, #self.CurBossStageCfg.SkillTitle do
        local grid = self.SkillGridList[i]
        if not grid then
            local ui = CS.UnityEngine.Object.Instantiate(self.GridBossSkill)
            grid = XUiGridBossSkill.New(ui)
            grid.Transform:SetParent(self.PanelSkill, false)
            self.SkillGridList[i] = grid
        end

        grid:Refresh(self.CurBossStageCfg.SkillTitle[i], self.CurBossStageCfg.SkillDesc[i])
        grid.GameObject:SetActive(true)
    end

    for i = #self.CurBossStageCfg.SkillTitle + 1, #self.SkillGridList do
        self.SkillGridList[i].GameObject:SetActive(false)
    end

    if #stageCfg.ForceConditionId <= 0 then
        self.PanelCondition.gameObject:SetActive(false)
    else
        self.PanelCondition.gameObject:SetActive(true)

        if stageCfg.ForceConditionId[1] then
            self.ImgCondition1.gameObject:SetActive(true)
            self.ImgCondition1.gameObject:SetActive(false)
            local text = XConditionManager.GetConditionTemplate(stageCfg.ForceConditionId[1]).Desc
            self.TxtConditon1.text = text
        else
            self.TxtConditon1.text = ""
        end

        if stageCfg.ForceConditionId[2] then
            self.ImgCondition1.gameObject:SetActive(false)
            self.ImgCondition2.gameObject:SetActive(true)
            local text = XConditionManager.GetConditionTemplate(stageCfg.ForceConditionId[2]).Desc
            self.TxtConditon2.text = text
        else
            self.TxtConditon2.text = ""
        end
    end
end

function XUiPanelBossDetail:RefreshInfo()
    local score = self.CurBossStageCfg.Score
    local stageData = XDataCenter.FubenManager.GetStageData(self.CurBossStageCfg.StageId)
    local curScore = stageData and stageData.Score or 0
    local text = CS.XTextManager.GetText("BossSingleBossScore", curScore, score)
    self.TxtMyScore.text = text
    self.ImgEffect.gameObject:SetActive(self.Index > XGlobalVar.BossSingleIndex.kinght)

    -- 设置自动按钮状态
    local maxCount = XFubenBossSingleConfigs.AUTO_FIGHT_COUNT
    local curCount = XFubenBossSingleConfigs.AUTO_FIGHT_COUNT - self.BossSingleData.AutoFightCount

    if maxCount > 0 then
        self.BtnAuto:SetName(CS.XTextManager.GetText("BossSingleAutoFightCount2", curCount, maxCount))
    else
        self.BtnAuto:SetName(CS.XTextManager.GetText("BossSingleAutoFightCount1"))
    end
   
    self.BtnAuto.gameObject:SetActive(self.CurBossStageCfg.AutoFight)
    local autoFightData = XDataCenter.FubenBossSingleManager.CheckAtuoFight(self.CurBossStageCfg.StageId)
    if autoFightData then
        self.BtnAuto:SetButtonState(CS.UiButtonState.Normal)
    else
        self.BtnAuto:SetButtonState(CS.UiButtonState.Disable)
    end
end

function XUiPanelBossDetail:CheckClick(index, isLogTip)
    local isPassed = XDataCenter.FubenBossSingleManager.CheckStagePassed(self.BossId, index)
    if not isPassed and isLogTip then
        local text = CS.XTextManager.GetText("FubenPreStage", "")
        XUiManager.TipError(text)
    end
    return isPassed
end

function XUiPanelBossDetail:OnBtnStartClick(...)
    local stageId = self.CurBossStageCfg.StageId
    local stageCfg = XDataCenter.FubenManager.GetStageCfg(stageId)
    XDataCenter.FubenManager.OpenRoomSingle(stageCfg)
end

function XUiPanelBossDetail:OnBtnClickClick(...)
    -- TODO::播放模型动画
end

function XUiPanelBossDetail:OnBtnAutoClick(...)
    if not self.CurBossStageCfg.AutoFight then
        local text = CS.XTextManager.GetText("BossSingleAutoFightDesc2", self.CurBossStageCfg.DifficultyDesc)
        XUiManager.TipMsg(text)
        return
    end

    local autoFightData = XDataCenter.FubenBossSingleManager.CheckAtuoFight(self.CurBossStageCfg.StageId)
    if not autoFightData then
        XUiManager.TipText("BossSingleAutoFightDesc1")
        return
    end

    local maxCount = XFubenBossSingleConfigs.AUTO_FIGHT_COUNT
    local curCount = XFubenBossSingleConfigs.AUTO_FIGHT_COUNT - self.BossSingleData.AutoFightCount

    if maxCount > 0 and curCount <= 0 then
        XUiManager.TipText("BossSingleAutoFightCount3")
        return
    end

    self.AutoFightOpen = true
    self.PanelAutoFight:Open(autoFightData, self.BossSingleData.ChallengeCount, self.CurBossStageCfg, function()
        for k, btn in ipairs(self.TabBtnGroup.TabBtnList) do
            if self:CheckClick(k, false) then
                self.TabBtnGroup:UnLockIndex(k)
            else
                self.TabBtnGroup:LockIndex(k)
            end
        end

        self:SetAutoFightClose()

        if self.Index then
            self.TabBtnGroup:SelectIndex(self.Index)
        else
            local index = XDataCenter.FubenBossSingleManager.GetCurBossIndex(self.BossId)
            self.TabBtnGroup:SelectIndex(index)
        end

    end)
    self.RootUi:PlayAnimation("PanelAutoFightEnable")
end

function XUiPanelBossDetail:CheckAutoFightOpen()
    return self.AutoFightOpen
end

function XUiPanelBossDetail:SetAutoFightClose()
    self.AutoFightOpen = false
end

return XUiPanelBossDetail