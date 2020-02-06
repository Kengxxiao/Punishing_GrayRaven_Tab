local XUiBabelTowerBase = XLuaUiManager.Register(XLuaUi, "UiBabelTowerBase")

function XUiBabelTowerBase:OnAwake()
    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.FreeGem, XDataCenter.ItemManager.ItemId.ActionPoint, XDataCenter.ItemManager.ItemId.Coin)
    self.BtnBack.CallBack = function() self:OnBtnBackClick() end
    self.BtnMainUi.CallBack = function() self:OnBtnMainUiClick() end
    self.BtnNext.CallBack = function() self:OnBtnNextClick() end
    self.BtnLast.CallBack = function() self:OnBtnLastClick() end
    self.BtnFight.CallBack = function() self:OnBtnFightClick() end
    self.BtnEnvironment.CallBack = function() self:OnBtnEnvironmentClick() end

    XEventManager.AddEventListener(XEventId.EVENT_BABEL_ACTIVITY_STATUS_CHANGED, self.CheckActivityStatus, self)
end

function XUiBabelTowerBase:OnDestroy()
    XEventManager.RemoveEventListener(XEventId.EVENT_BABEL_ACTIVITY_STATUS_CHANGED, self.CheckActivityStatus, self)
end

function XUiBabelTowerBase:OnEnable()
    self:CheckActivityStatus()
end

function XUiBabelTowerBase:CheckActivityStatus()
    if not XLuaUiManager.IsUiShow("UiBabelTowerBase") then return end
    local curActivityNo = XDataCenter.FubenBabelTowerManager.GetCurrentActivityNo()
    if not curActivityNo or not XDataCenter.FubenBabelTowerManager.IsInActivityTime(curActivityNo) then
        XUiManager.TipMsg(CS.XTextManager.GetText("BabelTowerNoneOpen"))
        XLuaUiManager.RunMain()
    end
end

function XUiBabelTowerBase:OnBtnBackClick()
    if self.CurrentPhase and self.CurrentPhase == XFubenBabelTowerConfigs.SupportPhase then
        self:Switch2ChallengePhase()
    else
        self:Close()
    end
end

function XUiBabelTowerBase:OnBtnMainUiClick()
    XLuaUiManager.RunMain()
end

function XUiBabelTowerBase:OnBtnNextClick()
    self:Switch2SupportPhase()
end

function XUiBabelTowerBase:Switch2SupportPhase()
    self.CurrentPhase = XFubenBabelTowerConfigs.SupportPhase
    self:SetBabelTowerPhase()
end

function XUiBabelTowerBase:OnBtnLastClick()
    self:Switch2ChallengePhase()
end

function XUiBabelTowerBase:Switch2ChallengePhase()
    self.CurrentPhase = XFubenBabelTowerConfigs.ChallengePhase
    self:SetBabelTowerPhase()
end

function XUiBabelTowerBase:OnBtnFightClick()
    -- teamList
    local teamList = {}
    for i=1, #self.TeamList do
        local characterId = self.TeamList[i]
        if characterId ~= nil and characterId ~= 0 then
            table.insert(teamList, characterId)
        end
    end
    -- challenge_buff
    local challengeBuffs = {}
    for i = 1, #self.ChallengeBuffInfos do
        local buffItem = self.ChallengeBuffInfos[i]
        table.insert(challengeBuffs, {
            GroupId = buffItem.BuffGroupId,
            BufferId = buffItem.SelectBuffId
        })
    end
    -- support_buff
    local supportBuffs = {}
    for i = 1, #self.SupportBuffInfos do
        local buffItem = self.SupportBuffInfos[i]
        table.insert(supportBuffs, {
            GroupId = buffItem.BuffGroupId,
            BufferId = buffItem.SelectBuffId
        })
    end

    -- 能否战斗
    local isUnlock, description = XDataCenter.FubenBabelTowerManager.IsBabelStageUnlock(self.StageId)
    if not isUnlock then
        XUiManager.TipMsg(description)
        return
    end

    -- 是否有队长
    local captainPos = XFubenBabelTowerConfigs.LEADER_POSITION
    local captainId = self.TeamList[captainPos]
    if captainId == nil or captainId <= 0 then
        XUiManager.TipMsg(CS.XTextManager.GetText("BabelTowerPleaseSelectALeader"))
        return
    end

    XDataCenter.FubenBabelTowerManager.SelectBabelTowerStage(self.StageId, self.GuideId, self.TeamList, challengeBuffs, supportBuffs, function()
        XDataCenter.FubenBabelTowerManager.SaveCurStageInfo(self.StageId, self.GuideId, self.TeamList, challengeBuffs, supportBuffs)

        if XDataCenter.FubenBabelTowerManager.IsStageGuideAuto(self.GuideId) then
            XDataCenter.FubenBabelTowerManager.UpdateBuffListCache(self.StageId, challengeBuffs)
        end
        XDataCenter.FubenManager.EnterBabelTowerFight(self.StageId, self.TeamList, function()
            self:Close()
        end)
    end)
end

function XUiBabelTowerBase:UpdateTeamList(teamList)
    self.TeamList = teamList
end

function XUiBabelTowerBase:UpdateChallengeBuffInfos(choosedChallengeList)
    self.ChallengeBuffInfos = choosedChallengeList
    
    -- 通知检查当前角色是否被禁用
    XEventManager.DispatchEvent(XEventId.EVNET_BABEL_CHALLENGE_BUFF_CHANGED)
end

function XUiBabelTowerBase:UpdateSupportBuffInfos(choosedSupportBuffList)
    self.SupportBuffInfos = choosedSupportBuffList
end

function XUiBabelTowerBase:OnBtnEnvironmentClick()
    XLuaUiManager.Open("UiBabelTowerDetails", XFubenBabelTowerConfigs.TIPSTYPE_ENVIRONMENT, self.StageId)
end

function XUiBabelTowerBase:OnStart(stageId, guideId)
    self.StageId = stageId
    self.GuideId = guideId
    self.TeamList = {}
    self.ChallengeBuffInfos = {}
    self.SupportBuffInfos = {}
    self.IsFirstOpenChildSupport = true

    self.CurrentPhase = XFubenBabelTowerConfigs.ChallengePhase

    self:SetBabelTowerPhase()

    local stageConfigs = XFubenBabelTowerConfigs.GetBabelStageConfigs(self.StageId)
end

function XUiBabelTowerBase:SetBabelTowerPhase()
    if not self.CurrentPhase then return end
    if XFubenBabelTowerConfigs.ChallengePhase == self.CurrentPhase then
        self.BtnNext.gameObject:SetActiveEx(true)
        self.BtnLast.gameObject:SetActiveEx(false)
        self.BtnFight.gameObject:SetActiveEx(false)
        
        self:OpenOneChildUi(XFubenBabelTowerConfigs.CHALLENGE_CHILD_UI, self, self.StageId, self.GuideId)
        self:FindChildUiObj(XFubenBabelTowerConfigs.CHALLENGE_CHILD_UI):PlayAnimation("AnimStartEnable")
        if XLuaUiManager.IsUiShow(XFubenBabelTowerConfigs.SUPPORT_CHILD_UI) then
            self:FindChildUiObj(XFubenBabelTowerConfigs.SUPPORT_CHILD_UI):Close()
        end
    end

    if XFubenBabelTowerConfigs.SupportPhase == self.CurrentPhase then
        self.BtnNext.gameObject:SetActiveEx(false)
        self.BtnLast.gameObject:SetActiveEx(true)
        self.BtnFight.gameObject:SetActiveEx(true)

        self:OpenOneChildUi(XFubenBabelTowerConfigs.SUPPORT_CHILD_UI, self, self.StageId, self.GuideId)
        if not self.IsFirstOpenChildSupport then
            self:FindChildUiObj(XFubenBabelTowerConfigs.SUPPORT_CHILD_UI):PlayAnimation("AnimStartEnable")
        else
            self.IsFirstOpenChildSupport = false
        end
        if XLuaUiManager.IsUiShow(XFubenBabelTowerConfigs.CHALLENGE_CHILD_UI) then
            self:FindChildUiObj(XFubenBabelTowerConfigs.CHALLENGE_CHILD_UI):Close()
        end
    end
end
