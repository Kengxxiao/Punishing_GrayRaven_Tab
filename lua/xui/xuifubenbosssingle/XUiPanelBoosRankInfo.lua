local XUiPanelBoosRankInfo = XClass()
local XUiPanelMyBossRank = require("XUi/XUiFubenBossSingle/XUiPanelMyBossRank")
local XUiPanelRankReward = require("XUi/XUiFubenBossSingle/XUiPanelRankReward")
local XUiGridBossRank = require("XUi/XUiFubenBossSingle/XUiGridBossRank")

function XUiPanelBoosRankInfo:Ctor(rootUi, ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    XTool.InitUiObject(self)
    self:AutoAddListener()
    self.PanelRankReward.gameObject:SetActive(false)
    self.GridRankList = {}
    self.GridRankLevel.gameObject:SetActive(false)
    self.GridBossRank.gameObject:SetActive(false)
    self.TxtCurTime.text = ""
    self:Init()
end

function XUiPanelBoosRankInfo:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelBoosRankInfo:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelBoosRankInfo:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelBoosRankInfo:AutoAddListener()
    self:RegisterClickEvent(self.BtnRankReward, self.OnBtnRankRewardClick)
end

function XUiPanelBoosRankInfo:Init()
    if self.TabBtnGroup then
        self.TabBtnGroup:Dispose()
    end
    self.TabBtnGroup = nil
    self.BtnTabList = {}
    local Cfgs = XDataCenter.FubenBossSingleManager.GetRankLevelCfgs()

    for i = 1, #Cfgs do
        local grid = CS.UnityEngine.Object.Instantiate(self.GridRankLevel)
        grid.transform:SetParent(self.PanelTags, false)
        grid.gameObject:SetActive(true)
        table.insert(self.BtnTabList, grid)
    end

    self.TabBtnGroup = XUiTabBtnGroup.New(self.BtnTabList, function(levelType)
        self:RefreshRankInfo(levelType)
    end)

    for k, btn in ipairs(self.TabBtnGroup.TabBtnList) do
        local text = CS.XTextManager.GetText("BossSingleRankDesc", Cfgs[k].MinPlayerLevel, Cfgs[k].MaxPlayerLevel)
        btn:SetName(Cfgs[k].LevelName, text)
        local icon = btn.Transform:Find("RImgIcon"):GetComponent("RawImage")
        icon:SetRawImage(Cfgs[k].Icon)
        self.TabBtnGroup:UnLockIndex(k)
    end

    self.MyBossRank = XUiPanelMyBossRank.New(self.RootUi, self.PanelMyBossRank)
    self.MyBossRank:HidePanel()
    self.RankReward = XUiPanelRankReward.New(self.RootUi, self.PanelRankReward)
end


function XUiPanelBoosRankInfo:ShowPanel(levelType)
    self.CurLevelType = levelType
    self.TabBtnGroup:SelectIndex(self.CurLevelType)
    self.GameObject:SetActive(true)
    self:RefreshTime()
end

function XUiPanelBoosRankInfo:HidePanel()
    self:RemoveTimer()
    self.GameObject:SetActive(false)
end

function XUiPanelBoosRankInfo:RefreshRankInfo(levelType)
    self.CurLevelType = levelType
    self:RefreshRank()
end

function XUiPanelBoosRankInfo:RemoveTimer()
    if self.Timer then
        CS.XScheduleManager.UnSchedule(self.Timer)
        self.Timer = nil
    end
end

function XUiPanelBoosRankInfo:RefreshRank()
    local func = function(rankData)
        self:SetRankInfo(rankData)
        self:RefreshMyRankInfo(rankData)
    end
    XDataCenter.FubenBossSingleManager.GetRankData(func, self.CurLevelType)
end

function XUiPanelBoosRankInfo:RefreshTime()
    local func = function(rankData)
        self:SetLeftTime(rankData)
    end
    XDataCenter.FubenBossSingleManager.GetRankData(func, self.CurLevelType)
end

function XUiPanelBoosRankInfo:SetLeftTime(rankData)
    local leftTime = rankData.LeftTime
    if self.Timer then
        self:RemoveTimer()
    end

    self.Timer = CS.XScheduleManager.Schedule(function(...)
        if XTool.UObjIsNil(self.GameObject) then
            return
        end

        leftTime = leftTime - 1
        if leftTime <= 0 then
            local dataTime = XUiHelper.GetTime(0)
            self.TxtCurTime.text = CS.XTextManager.GetText("BossSingleLeftTime", dataTime)
            self:RemoveTimer()
        else
            local dataTime = XUiHelper.GetTime(leftTime)
            self.TxtCurTime.text = CS.XTextManager.GetText("BossSingleLeftTime", dataTime)
        end
    end, 1000, 0, 0)
end

function XUiPanelBoosRankInfo:SetRankInfo(rankData)
    local count = #rankData.rankData
    local maxCount =  XDataCenter.FubenBossSingleManager.MAX_RANK_COUNT

    if #rankData.rankData > maxCount then 
        count = maxCount
    end

    for i = 1, count do
        local grid = self.GridRankList[i]
        if not grid then
            local ui = CS.UnityEngine.Object.Instantiate(self.GridBossRank)
            grid = XUiGridBossRank.New(self.RootUi, ui)
            grid.Transform:SetParent(self.PanelRankContent, false)
            self.GridRankList[i] = grid
        end

        grid:Refresh(rankData.rankData[i], self.CurLevelType)
        grid.GameObject:SetActive(true)
    end

    for i = count + 1, #self.GridRankList do
        self.GridRankList[i].GameObject:SetActive(false)
    end

    self.PanelNoRank.gameObject:SetActive(count <= 0)
end

function XUiPanelBoosRankInfo:RefreshMyRankInfo(rankData)
    local myLevelType = XDataCenter.FubenBossSingleManager.GetBoosSingleData().LevelType
    
    self.MyRankData = {
        MylevelType = myLevelType,
        MineRankNum = rankData.MineRankNum,
        HistoryMaxRankNum = rankData.HistoryMaxRankNum,
        TotalCount = rankData.TotalCount,
    }

    if self.CurLevelType == myLevelType then
        self.MyBossRank:ShowPanel()
        self.MyBossRank:Refresh(self.MyRankData)
    else
        self.MyBossRank:HidePanel()
    end

end

function XUiPanelBoosRankInfo:OnBtnRankRewardClick(...)
    self.RankReward:ShowPanel(self.CurLevelType, self.MyRankData)
end

return XUiPanelBoosRankInfo