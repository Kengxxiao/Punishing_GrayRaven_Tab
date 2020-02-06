local XUiBabelTowerChallengeChoice = XClass()
local UiButtonState = CS.UiButtonState
local XUiGridBabelChallengeItem = require("XUi/XUiFubenBabelTower/XUiGridBabelChallengeItem")

function XUiBabelTowerChallengeChoice:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.name = "XUiBabelTowerChallengeChoice"

    XTool.InitUiObject(self)
    self.ChallengeItemList = {}
    self.ChallengeBtnCompList = {}

    self.BtnGuideMask.CallBack = function() self:OnBtnGuideMaskClick() end
end

function XUiBabelTowerChallengeChoice:Init(uiRoot)
    self.UiRoot = uiRoot
end

function XUiBabelTowerChallengeChoice:SetItemData(itemData)
    self.BuffGoupDatas = itemData
    self.BuffGroupId = itemData.BuffGroupId
    self.GuideId = itemData.GuideId
    self.StageId = itemData.StageId
    self.BuffGroupDetails = XFubenBabelTowerConfigs.GetBabelBuffGroupConfigs(self.BuffGroupId)
    self.BuffGroupTemplate = XFubenBabelTowerConfigs.GetBabelTowerBuffGroupTemplate(self.BuffGroupId)

    self.TxtChallengeName.text = self.BuffGroupDetails.Name
    self:InitChallengeList()
end

function XUiBabelTowerChallengeChoice:OnBtnGuideMaskClick()
    if self.GuideId then
        if not XDataCenter.FubenBabelTowerManager.IsStageGuideAuto(self.GuideId) then
            XUiManager.TipMsg(CS.XTextManager.GetText("BabelTowerGuideStageCanntSelect"))
            return
        end
    end
    self.BtnGuideMask.gameObject:SetActiveEx(false)
end

function XUiBabelTowerChallengeChoice:InitChallengeList()
    for i=1, #self.BuffGroupTemplate.BuffId do
        local buffId = self.BuffGroupTemplate.BuffId[i]
        local buffTemplate = XFubenBabelTowerConfigs.GetBabelTowerBuffTemplate(buffId)
        local buffConfigs = XFubenBabelTowerConfigs.GetBabelBuffConfigs(buffId)
        if not self.ChallengeItemList[i] then
            local go = CS.UnityEngine.Object.Instantiate(self.GridChallenge)
            go.transform:SetParent(self.GridContent.transform, false)
            self.ChallengeItemList[i] = XUiGridBabelChallengeItem.New(go, self, i, XFubenBabelTowerConfigs.TYPE_CHALLENGE)
        end
        self.ChallengeItemList[i].GameObject:SetActiveEx(true)
        self.ChallengeItemList[i]:UpdateBuff(buffTemplate, buffConfigs, i, XFubenBabelTowerConfigs.TYPE_CHALLENGE)
        self.ChallengeBtnCompList[i] = self.ChallengeItemList[i]:GetXUiButtonComp()
        self.ChallengeBtnCompList[i]:ShowTag(false)
    end

    local isAutoGuide = XDataCenter.FubenBabelTowerManager.IsStageGuideAuto(self.GuideId)
    if isAutoGuide then
        self.GridContent:Init(self.ChallengeBtnCompList, function(index) self:OnChallengeChoiceItemClick(index) end)
        self.GridContent.CanDisSelect = true
        self.GridContent.CurSelectId = self.BuffGoupDatas.CurSelectId
        
        if self.BuffGoupDatas.IsFirstInit then
            local cache = XDataCenter.FubenBabelTowerManager.GetBuffListCacheByStageId(self.StageId)
            local index = self:GetBuffIndexByGroupId(self.BuffGroupId, cache[self.BuffGroupId])
            if index ~= -1 then
                self.GridContent:SelectIndex(index)
            end
            self.BuffGoupDatas.IsFirstInit = false
        end
    else
       self:InitAutoStageGuide()
    end
    self.BtnGuideMask.gameObject:SetActiveEx(not isAutoGuide)


    for i= #self.BuffGroupTemplate.BuffId + 1, #self.ChallengeItemList do
        self.ChallengeItemList[i].GameObject:SetActiveEx(false)
    end
end

function XUiBabelTowerChallengeChoice:GetBuffIndexByGroupId(groupId, buffId)
    local index = -1
    if not buffId then return index end
    local groupDatas = XFubenBabelTowerConfigs.GetBabelTowerBuffGroupTemplate(groupId)
    for i = 1, #groupDatas.BuffId do
        if buffId == groupDatas.BuffId[i] then
            index = i
            break
        end
    end
    return index
end

function XUiBabelTowerChallengeChoice:InitAutoStageGuide()
    local stageGuideTemplate = XFubenBabelTowerConfigs.GetBabelTowerStageGuideTemplate(self.GuideId)

    local selectBuffId = nil
    for index, buffGroupId in pairs(stageGuideTemplate.BuffGroup or {}) do
        if buffGroupId == self.BuffGroupId then
            selectBuffId = stageGuideTemplate.BuffId[index]
        end
    end

    for i=1, #self.BuffGroupTemplate.BuffId do
        if selectBuffId and selectBuffId == self.BuffGroupTemplate.BuffId[i] then
            self.ChallengeBtnCompList[i]:SetButtonState(UiButtonState.Select)
            self.ChallengeBtnCompList[i]:ShowTag(true)
        else
            self.ChallengeBtnCompList[i]:SetButtonState(UiButtonState.Disable)
            self.ChallengeBtnCompList[i]:ShowTag(false)
        end
        self.ChallengeBtnCompList[i].enabled = false
    end
end

-- buttonGroup方式选中

function XUiBabelTowerChallengeChoice:OnChallengeChoiceItemClick(index)
    local currentSelectBuffId = self.BuffGroupTemplate.BuffId[index]
    if self.BuffGoupDatas.SelectedBuffId == currentSelectBuffId then
        self.BuffGoupDatas.SelectedBuffId = nil
        self.BuffGoupDatas.CurSelectId = -1
    else
        self.BuffGoupDatas.SelectedBuffId = currentSelectBuffId
        self.BuffGoupDatas.CurSelectId = index
    end
    self.UiRoot:UpdateChoosedChallengeDatas(self.BuffGroupId, self.BuffGoupDatas.SelectedBuffId)
end

function XUiBabelTowerChallengeChoice:GetBuffSelectStatus(buffId)
    if not self.BuffGoupDatas then return false end
    return self.BuffGoupDatas.SelectedBuffId == buffId
end

return XUiBabelTowerChallengeChoice