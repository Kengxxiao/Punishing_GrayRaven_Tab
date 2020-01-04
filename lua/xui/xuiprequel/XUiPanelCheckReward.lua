XUiPanelCheckReward = XClass()

local ANIPREQUELCHECKREWARDEND = "AniPrequelCheckRewardEnd"

function XUiPanelCheckReward:Ctor(ui, rootUi)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    self:InitAutoScript()
    if not self.DynamicRewardList then
        self.DynamicRewardList = XDynamicTableNormal.New(self.SViewRewardList.gameObject)
        self.DynamicRewardList:SetProxy(XUiGridPrequelCheckPointReward)
        self.DynamicRewardList:SetDelegate(self)
    end
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelCheckReward:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiPanelCheckReward:AutoInitUi()
    self.BtnMask = self.Transform:Find("BtnMask"):GetComponent("Button")
    self.PanelReward = self.Transform:Find("PanelReward")
    self.SViewRewardList = self.Transform:Find("PanelReward/SViewRewardList"):GetComponent("ScrollRect")
    self.GridPrequelCheckPointReward = self.Transform:Find("PanelReward/SViewRewardList/Viewport/GridPrequelCheckPointReward")
    self.Scrollbar = self.Transform:Find("PanelReward/SViewRewardList/Scrollbar"):GetComponent("Scrollbar")
    self.PanelBg = self.Transform:Find("PanelReward/PanelBg")
end

function XUiPanelCheckReward:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelCheckReward:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelCheckReward:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelCheckReward:AutoAddListener()
    self:RegisterClickEvent(self.BtnMask, self.OnBtnMaskClick)
    self:RegisterClickEvent(self.SViewRewardList, self.OnSViewRewardListClick)
    self:RegisterClickEvent(self.Scrollbar, self.OnScrollbarClick)
end
-- auto

function XUiPanelCheckReward:OnSViewRewardListClick(eventData)

end

function XUiPanelCheckReward:OnScrollbarClick(eventData)

end

function XUiPanelCheckReward:OnBtnMaskClick(eventData)
    self.GameObject:SetActive(false)
end

-- [刷新奖励界面]
function XUiPanelCheckReward:UpdateRewardList(chapterId)
    self.ChapterId = chapterId
    self.RegionalDatas = XPrequelConfigs.GetPrequelChapterById(chapterId)
    self.RewardStages = self:FilterNotRewardStage(self.RegionalDatas.StageId)
    if self.DynamicRewardList then
        self.DynamicRewardList:SetDataSource(self.RewardStages)
        self.DynamicRewardList:ReloadDataASync()
    end
end

function XUiPanelCheckReward:RefreshReward()
    if self.ChapterId then
        self.RegionalDatas = XPrequelConfigs.GetPrequelChapterById(self.ChapterId)
        self.RewardStages = self:FilterNotRewardStage(self.RegionalDatas.StageId)
        if self.DynamicRewardList then
            self.DynamicRewardList:SetDataSource(self.RewardStages)
            self.DynamicRewardList:ReloadDataASync()
        end
    end
end

function XUiPanelCheckReward:FilterNotRewardStage(stages)
    local rewardStages = {}
    local index = 1
    for _, stageId in pairs(stages or {}) do
        local stageCfg = XDataCenter.FubenManager.GetStageCfg(stageId)
        if stageCfg.FirstRewardShow > 0 then
            table.insert(rewardStages, index, stageId)
            index = index + 1
        end
    end
    return rewardStages
end

function XUiPanelCheckReward:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:Init(self.RootUi, self)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local data = self.RewardStages[index]
        if data ~= nil then
            grid:OnRefreshDatas(data, self.ChapterId)
        end
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then
        -- 点击事件交由按钮处理
    end
end

return XUiPanelCheckReward
