local XUiPanelScoreInfo = XClass()
local XUiGridBossScore = require("XUi/XUiFubenBossSingle/XUiGridBossScore")

function XUiPanelScoreInfo:Ctor(rootUi, ui, bossSingleData)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.BossSingleData = bossSingleData
    self.RootUi = rootUi
    self.GridBossScoreList = {}
    XTool.InitUiObject(self)
    self:AutoAddListener()
    self:Init()
end

function XUiPanelScoreInfo:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelScoreInfo:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelScoreInfo:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelScoreInfo:AutoAddListener()
    self:RegisterClickEvent(self.BtnBlock, self.OnBtnBlockClick)
end

function XUiPanelScoreInfo:Init()
    self.GridBossScore.gameObject:SetActive(false)
    self:Rrefrsh()
end

function XUiPanelScoreInfo:ShowPanel(bossSingleData)
    self.BossSingleData = bossSingleData
    self:Rrefrsh()
    self.GameObject:SetActive(true)
    self.RootUi:PlayAnimation("AnimScoreInfoEnable")
end

function XUiPanelScoreInfo:Rrefrsh()
    local cfgs = XDataCenter.FubenBossSingleManager.GetScoreRewardCfg(self.BossSingleData.LevelType)
    local canGetList = {}
    local unGetList = {}
    local gotList = {}

    for i = 1, #cfgs do
        local canGet = self.BossSingleData.TotalScore >= cfgs[i].Score
        local isGet = XDataCenter.FubenBossSingleManager.CheckRewardGet(cfgs[i].Id)
        if canGet and not isGet then
            table.insert(canGetList, cfgs[i])
        elseif not canGet then
            table.insert(unGetList, cfgs[i])
        else 
            table.insert(gotList, cfgs[i])
        end
    end

    for i = 1, #unGetList do
        table.insert(canGetList, unGetList[i])
    end

    for i = 1, #gotList do
        table.insert(canGetList, gotList[i])
    end

    local curScore = CS.XTextManager.GetText("BossSingleScore2", self.BossSingleData.TotalScore)
    self.TxtCurScore.text = curScore

    for i = 1, #canGetList do
        local grid = self.GridBossScoreList[i]
        if not grid then
            local ui = CS.UnityEngine.Object.Instantiate(self.GridBossScore)
            grid = XUiGridBossScore.New(self.RootUi, ui)
            grid.Transform:SetParent(self.PanelScoreContent, false)
            self.GridBossScoreList[i] = grid
        end

        grid:Refresh(canGetList[i], self.BossSingleData.TotalScore)
        grid.GameObject:SetActive(true)
    end

    for i = #canGetList + 1, #self.GridBossScoreList do
        self.GridBossScoreList[i].GameObject:SetActive(false)
    end
end

function XUiPanelScoreInfo:OnBtnBlockClick(...)
    self:HidePanel()
end

function XUiPanelScoreInfo:HidePanel()
    self.RootUi:PlayAnimation("AnimScoreInfoDisable", function()
        self.GameObject:SetActive(false)
    end)
end

return XUiPanelScoreInfo