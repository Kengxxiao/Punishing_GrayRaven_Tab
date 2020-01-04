local XUiPanelRankReward = XClass()
local XUiGridBossRankReward = require("XUi/XUiFubenBossSingle/XUiGridBossRankReward")

function XUiPanelRankReward:Ctor(rootUi, ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    self.GridBossRankList = {}
    XTool.InitUiObject(self)
    self:AutoAddListener()
    self.GridBossRankReward.gameObject:SetActive(false)
end

function XUiPanelRankReward:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelRankReward:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelRankReward:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelRankReward:AutoAddListener()
    self:RegisterClickEvent(self.BtnBlock, self.OnBtnBlockClick)
end

function XUiPanelRankReward:ShowPanel(levelType, myRankData)
    local cfgs = XDataCenter.FubenBossSingleManager.GetRankRewardCfg(levelType)
    for i = 1, #cfgs do
        local grid = self.GridBossRankList[i]
        if not grid then
            local ui = CS.UnityEngine.Object.Instantiate(self.GridBossRankReward)
            grid = XUiGridBossRankReward.New(self.RootUi, ui)
            grid.Transform:SetParent(self.PanelRankContent, false)
            self.GridBossRankList[i] = grid
        end

        grid:Refresh(cfgs[i], myRankData.MineRankNum, myRankData.MylevelType, myRankData.TotalCount)
        grid.GameObject:SetActive(true)
    end

    for i = #cfgs + 1, #self.GridBossRankList do
        self.GridBossRankList[i].GameObject:SetActive(false)
    end

    self.GameObject:SetActive(true)
    self.RootUi:PlayAnimation("AnimRankRewardEnable")
end

function XUiPanelRankReward:OnBtnBlockClick(...)
    self:HidePanel()
end

function XUiPanelRankReward:HidePanel()
    self.RootUi:PlayAnimation("AnimRankRewardDisable", function()
        self.GameObject:SetActive(false)
    end)
end

return XUiPanelRankReward

