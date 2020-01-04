local XUiPanelAutoFight = XClass()

function XUiPanelAutoFight:Ctor(ui, rootUi, autoFightCb)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    self.AutoFightCb = autoFightCb

    XTool.InitUiObject(self)
    self.TeamMemberList = {}
    table.insert(self.TeamMemberList, self.GridBossAutoFight1)
    table.insert(self.TeamMemberList, self.GridBossAutoFight2)
    table.insert(self.TeamMemberList, self.GridBossAutoFight3)
    self:AutoAddListener()
end

function XUiPanelAutoFight:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelAutoFight:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelAutoFight:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelAutoFight:AutoAddListener()
    self:RegisterClickEvent(self.BtnAutoFight, self.OnBtnAutoFightClick)
    self:RegisterClickEvent(self.BtnClose, self.OnBtnCloseClick)
    self:RegisterClickEvent(self.BtnHelp, self.OnBtnHelpClick)
end

function XUiPanelAutoFight:OnBtnCloseClick(...)
    if self.CloseCb then
        self.CloseCb()
    end
    self:Close()
end

function XUiPanelAutoFight:OnBtnHelpClick(...)
    XUiManager.UiFubenDialogTip("", CS.XTextManager.GetText("BossSingleAutoFightDesc") or "")
end

function XUiPanelAutoFight:OnBtnAutoFightClick(...)
    if not self.StaminaEnough then
        XUiManager.TipText("BossSingleAutoFightDesc7")
        return
    end

    if not self.ChallengeCountEnough then
        XUiManager.TipText("BossSingleAutoFightDesc8")
        return
    end

    local titletext = CS.XTextManager.GetText("TipTitle")
    local stageData = XDataCenter.FubenManager.GetStageData(self.StageId)
    local curScore = stageData and stageData.Score or 0
    local contenttext = curScore > 0 and CS.XTextManager.GetText("BossSingleAutoFightDesc11") or CS.XTextManager.GetText("BossSingleAutoFightDesc9")
    XUiManager.DialogTip(titletext, contenttext, XUiManager.DialogType.Normal, nil, function()
        XDataCenter.FubenBossSingleManager.AutoFight(self.StageId, function()
            XEventManager.DispatchEvent(XEventId.EVENT_BOSS_SINGLE_GET_REWARD)
            if self.CloseCb then
                self.CloseCb()
            end

            self:Close()

            if self.AutoFightCb then
                self.AutoFightCb()
            end
        end)
    end)
end

function XUiPanelAutoFight:Close()
    self.GameObject:SetActive(false)
end

function XUiPanelAutoFight:Open(autoFightData, challengeCount, cfg, closeCb)
    self.CloseCb = closeCb
    self.StaminaEnough = true
    self.ChallengeCountEnough = true
    self.StageId = autoFightData.StageId

    local score = cfg.Score
    local curScore = autoFightData.Score or 0
    curScore = math.floor(XFubenBossSingleConfigs.AUTO_FIGHT_REBATE * curScore / 100)
    local scoreDesc = XFubenBossSingleConfigs.AUTO_FIGHT_REBATE .. "%"

    self.TxtScore.text = CS.XTextManager.GetText("BossSingleAutoFightDesc3", curScore, score)
    self.TxtScoreDesc.text = CS.XTextManager.GetText("BossSingleAutoFightRateDesc", scoreDesc)

    local allCount = XDataCenter.FubenBossSingleManager.BOSS_SINGLE_CHALLENGE_COUNT
    local leftCount = allCount - challengeCount
    self.TxtCount.text = CS.XTextManager.GetText("BossSingleAutoFightDesc4", leftCount, allCount)
    if leftCount <= 0 then
        self.ChallengeCountEnough = false
    end

    for _, v in pairs(self.TeamMemberList) do
        v.gameObject:SetActive(false)
    end

    for i, v in pairs(autoFightData.Characters) do
        if v > 0 then
            local grid = self.TeamMemberList[i]

            local nickname = XUiHelper.TryGetComponent(grid, "TxtNickName", "Text")
            local enough = XUiHelper.TryGetComponent(grid, "TxtCountEnough", "Text")
            local notEnough = XUiHelper.TryGetComponent(grid, "TxtCountNotEnough", "Text")
            local head = XUiHelper.TryGetComponent(grid, "Gouzaoti/RImgHead", "RawImage")

            local info = XDataCenter.CharacterManager.GetCharBigRoundnessNotItemHeadIcon(v)
            if info ~= nil then
                head:SetRawImage(info)
            end

            local fullName = XCharacterConfigs.GetCharacterFullNameStr(v)
            nickname.text = fullName

            local maxStamina = XDataCenter.FubenBossSingleManager.MAX_STAMINA
            local curStamina = maxStamina - XDataCenter.FubenBossSingleManager.GetCharacterChallengeCount(v)

            enough.text = CS.XTextManager.GetText("BossSingleAutoFightDesc5", curStamina, maxStamina)
            notEnough.text = CS.XTextManager.GetText("BossSingleAutoFightDesc6", curStamina, maxStamina)
            enough.gameObject:SetActive(curStamina > 0)
            notEnough.gameObject:SetActive(curStamina <= 0)
            if curStamina <= 0 then
                self.StaminaEnough = false
            end

            grid.gameObject:SetActive(true)
        end
    end

    self.GameObject:SetActive(true)
end

return XUiPanelAutoFight