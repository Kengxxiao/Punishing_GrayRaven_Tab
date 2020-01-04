local XUiPanelPrepare = XClass()

function XUiPanelPrepare:Ctor(ui, rootUi)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    XTool.InitUiObject(self)
    self:AutoAddListener()

    self.IsShow = false
    self.GameObject:SetActiveEx(false)

    self.RedPointApplyId = XRedPointManager.AddRedPointEvent(self.ImgRed, nil, self, { XRedPointConditions.Types.CONDITION_ARENA_APPLY })
end

function XUiPanelPrepare:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelPrepare:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelPrepare:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelPrepare:AutoAddListener()
    self:RegisterClickEvent(self.BtnCreateTeam, self.OnBtnCreateTeamClick)
    self:RegisterClickEvent(self.BtnTeamRank, self.OnBtnTeamRankClick)
    self:RegisterClickEvent(self.BtnLevelReward, self.OnBtnLevelRewardClick)
    self:RegisterClickEvent(self.BtnShop, self.OnBtnShopClick)
end

function XUiPanelPrepare:OnBtnCreateTeamClick(eventData)
    if not XDataCenter.ArenaManager.CheckInTeamState() then
        XUiManager.TipText("ArenaActivityTeamStatusWrong")
        return
    end

    XDataCenter.ArenaManager.RequestMyTeamInfo(function()
        XLuaUiManager.Open("UiArenaTeam")
    end)
    XDataCenter.ArenaManager.RequestApplyData()
end

function XUiPanelPrepare:OnBtnTeamRankClick(eventData)
    XDataCenter.ArenaManager.RequestTeamRankData(function()
        XLuaUiManager.Open("UiArenaTeamRank")
    end)
end

function XUiPanelPrepare:OnBtnLevelRewardClick(eventData)
    XLuaUiManager.Open("UiArenaLevelDetail")
end

function XUiPanelPrepare:OnBtnShopClick(eventData)
    XLuaUiManager.Open("UiShop", XShopManager.ShopType.Arena)
end

function XUiPanelPrepare:Show()
    if self.IsShow then
        return
    end

    self.IsShow = true
    self.GameObject:SetActiveEx(true)
    self:Refresh()
end

function XUiPanelPrepare:Hide()
    if not self.IsShow then
        return
    end

    self.IsShow = false
    self.GameObject:SetActiveEx(false)
end

function XUiPanelPrepare:OnCheckApplyData(count)
    self.ImgRed.gameObject:SetActiveEx(count > 0)
end

function XUiPanelPrepare:Refresh()
    local arenaLevel = XDataCenter.ArenaManager.GetCurArenaLevel()
    local arenaLevelCfg = XArenaConfigs.GetArenaLevelCfgByLevel(arenaLevel)
    if arenaLevelCfg then
        self.RImgLevel:SetRawImage(arenaLevelCfg.Icon)
    end

    local isEnd = XDataCenter.ArenaManager.GetArenaActivityStatus() == XArenaActivityStatus.Over
    self.PanelNorResult.gameObject:SetActiveEx(not isEnd)
    self.PanelSelectResult.gameObject:SetActiveEx(isEnd)
    self.PanelNorTeam.gameObject:SetActiveEx(isEnd)
    self.PanelSelectTeam.gameObject:SetActiveEx(not isEnd)
    self.TxtSelectResultTime.gameObject:SetActiveEx(isEnd)
    self.TxtNorResultTime.gameObject:SetActiveEx(isEnd)

    local resultTime = XDataCenter.ArenaManager.GetResultStartTime()
    self.TxtNorResultTime.text = resultTime
    self.TxtSelectResultTime.text = resultTime

    local fightTime = XDataCenter.ArenaManager.GetFightStartTime()
    self.TxtNorFightTime.text = fightTime

    local teamTime = XDataCenter.ArenaManager.GetTeamStartTime()
    self.TxtNorTeamTime.text = teamTime
    self.TxtSelectTeamTime.text = teamTime
end

return XUiPanelPrepare
