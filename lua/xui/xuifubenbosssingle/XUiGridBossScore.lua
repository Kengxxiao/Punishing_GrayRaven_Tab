local XUiGridBossScore = XClass()

function XUiGridBossScore:Ctor(rootUi, ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    self.GridRewardList = {}
    XTool.InitUiObject(self)
    self:AutoAddListener()
end

function XUiGridBossScore:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiGridBossScore:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiGridBossScore:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiGridBossScore:AutoAddListener()
    self:RegisterClickEvent(self.BtnReceive, self.OnBtnReceiveClick)
end

function XUiGridBossScore:OnBtnReceiveClick(...)
    local canGet = self.TotalScore >= self.SocreCfg.Score
    if not canGet then 
        XUiManager.TipText("BossSingleCannotReward")
        return
    end

    XDataCenter.FubenBossSingleManager.GetRankRewardReq(self.SocreCfg.Id, function(rewards)
        if rewards and #rewards> 0 then
            XUiManager.OpenUiObtain(rewards)
        end

        XEventManager.DispatchEvent(XEventId.EVENT_BOSS_SINGLE_GET_REWARD)        
        self.PanelAlreadyGet.gameObject:SetActive(true)
        self.BtnReceive.gameObject:SetActive(false)
    end)
end

function XUiGridBossScore:Refresh(socreCfg, totalScore)
    self.TotalScore = totalScore
    self.SocreCfg = socreCfg
    self.GridReward.gameObject:SetActive(false)
    local isGet = XDataCenter.FubenBossSingleManager.CheckRewardGet(socreCfg.Id)
    local rewardList = XRewardManager.GetRewardList(socreCfg.RewardId)

    self.TxtScore.text = socreCfg.Score
    self.PanelAlreadyGet.gameObject:SetActive(isGet)
    self.BtnReceive.gameObject:SetActive(not isGet)

    local canGet = self.TotalScore >= self.SocreCfg.Score
    if not canGet then
        self.BtnReceive:SetButtonState(CS.UiButtonState.Disable)
    else
        self.BtnReceive:SetButtonState(CS.UiButtonState.Normal)
    end

    for i = 1, #rewardList do
        local grid = self.GridRewardList[i]
        if not grid then
            local ui = CS.UnityEngine.Object.Instantiate(self.GridReward)
            grid = XUiGridCommon.New(self.RootUi, ui)
            grid.Transform:SetParent(self.PanelRewardContent, false)
            self.GridRewardList[i] = grid
        end

        grid:Refresh(rewardList[i])
        grid.GameObject:SetActive(true)
    end

    for i = #rewardList + 1, #self.GridRewardList do
        self.GridRewardList[i].GameObject:SetActive(false)
    end
end

return XUiGridBossScore