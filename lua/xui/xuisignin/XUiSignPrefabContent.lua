local XUiSignPrefabContent = XClass()
local XUiSignPrefab = require("XUi/XUiSignIn/XUiSignPrefab")
local MAX_COUNT = 10

function XUiSignPrefabContent:Ctor(ui, rootUi)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    self.PanelSignPrefabs = {}
    self.SetTomorrowRound = -1
end

function XUiSignPrefabContent:Refresh(signId, isShow)
    local panelRounds = {}

    for i = 1, MAX_COUNT do
        local panelRound = XUiHelper.TryGetComponent(self.Transform, "PanelRound" .. i, nil)
        if not panelRound then
            break
        end
        panelRound.gameObject:SetActive(false)
        table.insert(panelRounds, panelRound)
    end

    local signInInfos = XSignInConfigs.GetSignInInfos(signId)
    for i = 1, #signInInfos do
        local panelRound = panelRounds[i]
        if not panelRound then
            XLog.Error("XUiSignPrefabContent Init Error prefab is not enough round is " .. tostring(i))
            break
        end
        local signPrefab = self.PanelSignPrefabs[i]
        if not signPrefab then
            signPrefab = XUiSignPrefab.New(panelRound, self.RootUi, self)
        end
        self.PanelSignPrefabs[i] = signPrefab

        signPrefab:SetTomorrowForce(self.SetTomorrowRound == i)
        signPrefab:Refresh(signId, i, isShow)
    end

    local curRound = XDataCenter.SignInManager.GetSignRound(signId, true)
    self:RefreshPanel(curRound)
end

function XUiSignPrefabContent:RefreshPanel(round)
    for k,v in pairs(self.PanelSignPrefabs) do
        v:SetSignActive(k == round, round)
    end
end

function XUiSignPrefabContent:SetTomorrowOpen(dayRewardConfig)
    local isRoundLastDay, curRound = XSignInConfigs.JudgeLastRoundDay(dayRewardConfig.SignId, dayRewardConfig.Round, dayRewardConfig.Day)
    if isRoundLastDay then
        self.SetTomorrowRound = curRound + 1
    end

    local round = isRoundLastDay and curRound + 1 or curRound
    for k,v in pairs(self.PanelSignPrefabs) do
        if v.Round == round then
            v:SetTomorrowForce(true)
            v:SetTomorrowOpen(dayRewardConfig, isRoundLastDay, curRound)
            return
        end
    end
end

function XUiSignPrefabContent:OnHide()
end

function XUiSignPrefabContent:OnShow()
end

return XUiSignPrefabContent