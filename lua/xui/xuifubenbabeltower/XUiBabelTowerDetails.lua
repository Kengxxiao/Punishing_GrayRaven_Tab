local XUiBabelTowerDetails = XLuaUiManager.Register(XLuaUi, "UiBabelTowerDetails")
local XUiGridInfoEnvironmentItem = require("XUi/XUiFubenBabelTower/XUiGridInfoEnvironmentItem")
local XUiGridInfoChallengeItem = require("XUi/XUiFubenBabelTower/XUiGridInfoChallengeItem")

function XUiBabelTowerDetails:OnAwake()
    self.BtnTanchuangClose.CallBack = function() self:OnBtnTanchuangClose() end

    self.DynamicTableTipsBaseBuff = XDynamicTableNormal.New(self.PanelAmbientText.gameObject)
    self.DynamicTableTipsBaseBuff:SetProxy(XUiGridInfoEnvironmentItem)
    self.DynamicTableTipsBaseBuff:SetDelegate(self)
    self.DynamicTableTipsBaseBuff:SetDynamicEventDelegate(function(event, index, grid)
        self:OnEnvironmentDynamicTableEvent(event, index, grid)
    end)

    self.GridChallengeList = {}
    self.GridSupportList = {}
    
end

function XUiBabelTowerDetails:OnBtnTanchuangClose()
    self:Close()
end

function XUiBabelTowerDetails:OnStart(tipsType, stageId)
    self.StageId = stageId
    self.TipsType = tipsType
    self.BabelStageTemplate = XFubenBabelTowerConfigs.GetBabelTowerStageTemplate(self.StageId)

    self.IsEnvironmentTips = XFubenBabelTowerConfigs.TIPSTYPE_ENVIRONMENT == self.TipsType
    self.IsChallengeTips = XFubenBabelTowerConfigs.TIPSTYPE_CHALLENGE == self.TipsType
    self.IsSupportTips = XFubenBabelTowerConfigs.TIPSTYPE_SUPPORT == self.TipsType

    self.PanelAmbient.gameObject:SetActiveEx(self.IsEnvironmentTips)
    self.PanelChallenge.gameObject:SetActiveEx(self.IsChallengeTips)
    self.PanelSupport.gameObject:SetActiveEx(self.IsSupportTips)
    
    if self.IsEnvironmentTips then
        self:SetEnvironmentTipsInfo()
    end

    if self.IsChallengeTips then
        self:SetChallengeTipsInfo()
    end

    if self.IsSupportTips then
        self:SetSupportTipsInfo()
    end
end

-- 环境情报
function XUiBabelTowerDetails:SetEnvironmentTipsInfo()
    self.BaseBuffs = self.BabelStageTemplate.BaseBuffId
    self.DynamicTableTipsBaseBuff:SetDataSource(self.BaseBuffs)
    self.DynamicTableTipsBaseBuff:ReloadDataASync()
end

function XUiBabelTowerDetails:OnEnvironmentDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:Init(self)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        if self.BaseBuffs[index] then
            grid:SetItemInfo(self.BaseBuffs[index], index)
        end
    end
end

-- 挑战详情
function XUiBabelTowerDetails:SetChallengeTipsInfo()
    for i=1, #self.BabelStageTemplate.ChallengeBuffGroup do
        if not self.GridChallengeList[i] then
            local go = CS.UnityEngine.Object.Instantiate(self.GridChallengeDetails)
            go.transform:SetParent(self.PanelChallengeContainer, false)
            go.gameObject:SetActiveEx(true)
            local challengeItem = XUiGridInfoChallengeItem.New(go, self.BabelStageTemplate.ChallengeBuffGroup[i], XFubenBabelTowerConfigs.TYPE_CHALLENGE)
            table.insert(self.GridChallengeList, challengeItem)
        else
            self.GridChallengeList[i]:Refresh(self.BabelStageTemplate.ChallengeBuffGroup[i], XFubenBabelTowerConfigs.TYPE_CHALLENGE)
        end
    end
    for i = #self.BabelStageTemplate.ChallengeBuffGroup + 1, #self.GridChallengeList do
        self.GridChallengeList[i].GameObject:SetActiveEx(false)
    end
end

-- 支援详情
function XUiBabelTowerDetails:SetSupportTipsInfo()
    for i=1, #self.BabelStageTemplate.SupportBuffGroup do
        if not self.GridSupportList[i] then
            local go = CS.UnityEngine.Object.Instantiate(self.GridSupportDetails)
            go.transform:SetParent(self.PanelSupportContainer, false)
            go.gameObject:SetActiveEx(true)
            local challengeItem = XUiGridInfoChallengeItem.New(go, self.BabelStageTemplate.SupportBuffGroup[i], XFubenBabelTowerConfigs.TYPE_SUPPORT)
            table.insert(self.GridSupportList, challengeItem)
        else
            self.GridSupportList[i]:Refresh(self.BabelStageTemplate.SupportBuffGroup[i], XFubenBabelTowerConfigs.TYPE_SUPPORT)
        end
    end
    for i = #self.BabelStageTemplate.SupportBuffGroup + 1, #self.GridSupportList do
        self.GridSupportList[i].GameObject:SetActiveEx(false)
    end
end
