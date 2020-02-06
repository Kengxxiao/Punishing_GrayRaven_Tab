local XUiBabelTowerChildChallenge = XLuaUiManager.Register(XLuaUi, "UiBabelTowerChildChallenge")

local XUiBabelTowerChallengeChoice = require("XUi/XUiFubenBabelTower/XUiBabelTowerChallengeChoice")
local XUiBabelTowerChallengeSelect = require("XUi/XUiFubenBabelTower/XUiBabelTowerChallengeSelect")

function XUiBabelTowerChildChallenge:OnAwake()
    self.BtnNext.CallBack = function() self:OnBtnNextClick() end

    self.BtnChallenge.CallBack = function() self:OnBtnChallengeClick() end

    self.DynamicTableChallengeChoice = XDynamicTableNormal.New(self.PanelChallengeChoice.gameObject)
    self.DynamicTableChallengeChoice:SetProxy(XUiBabelTowerChallengeChoice)
    self.DynamicTableChallengeChoice:SetDelegate(self)
    self.DynamicTableChallengeChoice:SetDynamicEventDelegate(function(event, index, grid)
        self:OnChallengeChoiceDynamicTableEvent(event, index, grid)
    end)


    self.DynamicTableChallengeSelect = XDynamicTableNormal.New(self.PanelSelectChallenge.gameObject)
    self.DynamicTableChallengeSelect:SetProxy(XUiBabelTowerChallengeSelect)
    self.DynamicTableChallengeSelect:SetDelegate(self)
    self.DynamicTableChallengeSelect:SetDynamicEventDelegate(function(event, index, grid)
        self:OnChallengeSelectDynamicTableEvent(event, index, grid)
    end)

    self.ChoosedChallengeList = {}
    self.ChallengeBuffSelectGroup = {}
end

function XUiBabelTowerChildChallenge:OnChallengeChoiceDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:Init(self)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        if self.ChallengeBuffGroup[index] then
            grid:SetItemData(self.ChallengeBuffGroup[index])
        end
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then
    end
end

function XUiBabelTowerChildChallenge:OnChallengeSelectDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:Init(self)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        if self.ChoosedChallengeList[index] then
            grid:SetItemData(self.ChoosedChallengeList[index], XFubenBabelTowerConfigs.TYPE_CHALLENGE)
        end
    end
end

function XUiBabelTowerChildChallenge:OnBtnNextClick()
    self.UiRoot:Switch2SupportPhase()
end

function XUiBabelTowerChildChallenge:OnBtnChallengeClick()
    XLuaUiManager.Open("UiBabelTowerDetails", XFubenBabelTowerConfigs.TIPSTYPE_CHALLENGE, self.StageId)
end

function XUiBabelTowerChildChallenge:OnStart(uiRoot, stageId, guideId)
    self.UiRoot = uiRoot
    self.StageId = stageId
    self.GuideId = guideId
    self.BabelTowerStageTemplate = XFubenBabelTowerConfigs.GetBabelTowerStageTemplate(self.StageId)

    self:SetChallengeChoiceDatas()
    
    self:SetChallengeScore(self.StageId)
    if XDataCenter.FubenBabelTowerManager.IsStageGuideAuto(self.GuideId) then
        self:InitDefaultSelect()
    else
        self:UpdateChoosedChallengeDatasByStageGuide()
    end
end

function XUiBabelTowerChildChallenge:InitDefaultSelect()
    self.ChoosedChallengeList = {}
    local cache = XDataCenter.FubenBabelTowerManager.GetBuffListCacheByStageId(self.StageId)
    for i = 1, #self.ChallengeBuffSelectGroup do
        local groupItem = self.ChallengeBuffSelectGroup[i]
        groupItem.SelectBuffId = cache[groupItem.BuffGroupId]
        if groupItem.SelectBuffId then
            table.insert(self.ChoosedChallengeList, groupItem)
        end
    end
  
    self:ReportChallengeChoice()
    self.DynamicTableChallengeSelect:SetDataSource(self.ChoosedChallengeList)
    self.DynamicTableChallengeSelect:ReloadDataASync()
    self.ImgEmpty.gameObject:SetActiveEx(#self.ChoosedChallengeList <= 0)
    self:UpdateCurChallengeScore(self.ChoosedChallengeList)
end

function XUiBabelTowerChildChallenge:SetChallengeScore(stageId)
    local maxScore = 0
    local curScore = 0
    local stageServerInfo = XDataCenter.FubenBabelTowerManager.GetBabelTowerStageInfo(stageId)
    if stageServerInfo then
        maxScore = stageServerInfo.MaxScore
        if not stageServerInfo.IsReset then
            curScore = stageServerInfo.CurScore
        end
    end
    
    self.TxtChallengeTop.text = CS.XTextManager.GetText("BabelTowerCurMaxScore", maxScore)
end

-- 设置目标战略组
function XUiBabelTowerChildChallenge:SetChallengeChoiceDatas()
    self:GenChallengeGroupDatas()
    self:GenChallengeSelectDatas()
    self.DynamicTableChallengeChoice:SetDataSource(self.ChallengeBuffGroup)
    self.DynamicTableChallengeChoice:ReloadDataASync()
end

-- 保存一份数据，记录玩家选中的挑战项SelectBuffList = {buffId = isSelect}
function XUiBabelTowerChildChallenge:GenChallengeGroupDatas()
    if self.ChallengeBuffGroup then return self.ChallengeBuffGroup end
    self.ChallengeBuffGroup = {}
    for i=1, #self.BabelTowerStageTemplate.ChallengeBuffGroup do
        local groupId = self.BabelTowerStageTemplate.ChallengeBuffGroup[i]
        table.insert(self.ChallengeBuffGroup, {
            StageId = self.StageId,
            GuideId = self.GuideId,
            BuffGroupId = groupId,
            SelectedBuffId = nil,
            CurSelectId = -1,
            IsFirstInit = true
        })
    end
end

function XUiBabelTowerChildChallenge:GenChallengeSelectDatas()
    self.ChallengeBuffSelectGroup = {}
    for i = 1, #self.BabelTowerStageTemplate.ChallengeBuffGroup do
        table.insert(self.ChallengeBuffSelectGroup, {
            BuffGroupId = self.BabelTowerStageTemplate.ChallengeBuffGroup[i],
            SelectBuffId = nil,
        })
    end
end

-- 设置已选战略组
-- buffgroup组选中了一个buffId,如果buffId为空，则该buffgroup组没有选中任何一个buff
function XUiBabelTowerChildChallenge:UpdateChoosedChallengeDatas(buffGroupId, buffId)
    if not self.ChallengeBuffSelectGroup then self:GenChallengeSelectDatas() end

    -- isExist
    if self.ChoosedChallengeList and #self.ChoosedChallengeList > 0 then
        for k, v in pairs(self.ChoosedChallengeList) do
            if v.BuffGroupId == buffGroupId and buffId and v.SelectBuffId == buffId then
                return 
            end
        end
    end

    self.ChoosedChallengeList = {}
    for i = 1, #self.ChallengeBuffSelectGroup do
        local groupItem = self.ChallengeBuffSelectGroup[i]
        if groupItem.BuffGroupId == buffGroupId then
            groupItem.SelectBuffId = buffId
        end
        if groupItem.SelectBuffId then
            table.insert(self.ChoosedChallengeList, groupItem)
        end
    end
  
    self:ReportChallengeChoice()
    self.DynamicTableChallengeSelect:SetDataSource(self.ChoosedChallengeList)
    self.DynamicTableChallengeSelect:ReloadDataASync()
    self.ImgEmpty.gameObject:SetActiveEx(#self.ChoosedChallengeList <= 0)
    self:UpdateCurChallengeScore(self.ChoosedChallengeList)
end

-- 非自选战略
function XUiBabelTowerChildChallenge:UpdateChoosedChallengeDatasByStageGuide()
    local stageGuideTemplate = XFubenBabelTowerConfigs.GetBabelTowerStageGuideTemplate(self.GuideId)
    self.ChoosedChallengeList = {}
    for i=1, #stageGuideTemplate.BuffGroup do
        table.insert(self.ChoosedChallengeList, {
            BuffGroupId = stageGuideTemplate.BuffGroup[i],
            SelectBuffId = stageGuideTemplate.BuffId[i]
        })
    end
    self:ReportChallengeChoice()
    self.DynamicTableChallengeSelect:SetDataSource(self.ChoosedChallengeList)
    self.DynamicTableChallengeSelect:ReloadDataASync()
    self.ImgEmpty.gameObject:SetActiveEx(#self.ChoosedChallengeList <= 0)
    self:UpdateCurChallengeScore(self.ChoosedChallengeList)
end

function XUiBabelTowerChildChallenge:UpdateCurChallengeScore(challengeList)
    local totalChallengeScore = 0
    if self.BabelTowerStageTemplate then
        totalChallengeScore = self.BabelTowerStageTemplate.BaseScore
    end
    for k, v in pairs(challengeList or {}) do
        local buffTemplate = XFubenBabelTowerConfigs.GetBabelTowerBuffTemplate(v.SelectBuffId)
        totalChallengeScore = totalChallengeScore + (buffTemplate.ScoreAdd or 0)
    end
    self.TxtChallengeNumber.text = totalChallengeScore
end

function XUiBabelTowerChildChallenge:ReportChallengeChoice()
    self.UiRoot:UpdateChallengeBuffInfos(self.ChoosedChallengeList)
end