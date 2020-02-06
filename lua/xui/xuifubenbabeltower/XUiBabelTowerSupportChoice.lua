local XUiBabelTowerSupportChoice = XClass()
local UiButtonState = CS.UiButtonState
local XUiGridBabelChallengeItem = require("XUi/XUiFubenBabelTower/XUiGridBabelChallengeItem")

function XUiBabelTowerSupportChoice:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.name = "XUiBabelTowerSupportChoice"

    XTool.InitUiObject(self)
    self.SupportItemList = {}
    self.SupportBtnCompList = {}
end

function XUiBabelTowerSupportChoice:Init(uiRoot)
    self.UiRoot = uiRoot
end

function XUiBabelTowerSupportChoice:SetItemData(itemData)
    self.BuffGoupDatas = itemData
    self.BuffGroupId = itemData.BuffGroupId
    self.GuideId = itemData.GuideId
    self.StageId = itemData.StageId
    self.BuffGroupDetails = XFubenBabelTowerConfigs.GetBabelBuffGroupConfigs(self.BuffGroupId)
    self.BuffGroupTemplate = XFubenBabelTowerConfigs.GetBabelTowerBuffGroupTemplate(self.BuffGroupId)

    self.TxtSupportName.text = self.BuffGroupDetails.Name
    self:InitSupportList()
    self:UpdateGridChoiceState(self.UiRoot:GetAvaliableSupportPoint())
end

function XUiBabelTowerSupportChoice:InitSupportList()
    for i=1, #self.BuffGroupTemplate.BuffId do
        local buffId = self.BuffGroupTemplate.BuffId[i]
        local buffTemplate = XFubenBabelTowerConfigs.GetBabelTowerBuffTemplate(buffId)
        local buffConfigs = XFubenBabelTowerConfigs.GetBabelBuffConfigs(buffId)
        if not self.SupportItemList[i] then
            local go = CS.UnityEngine.Object.Instantiate(self.GridChallenge)
            go.transform:SetParent(self.GridContent.transform, false)
            self.SupportItemList[i] = XUiGridBabelChallengeItem.New(go, self, i, XFubenBabelTowerConfigs.TYPE_SUPPORT)
        end
        self.SupportItemList[i].GameObject:SetActiveEx(true)
        self.SupportItemList[i]:UpdateBuff(buffTemplate, buffConfigs, i, XFubenBabelTowerConfigs.TYPE_SUPPORT)
        self.SupportBtnCompList[i] = self.SupportItemList[i]:GetXUiButtonComp()
    end

    self.GridContent:Init(self.SupportBtnCompList, function(index) self:OnSupportChoiceItemClick(index) end)
    self.GridContent.CanDisSelect = true
    self.GridContent.CurSelectId = self.BuffGoupDatas.CurSelectId

    for i= #self.BuffGroupTemplate.BuffId + 1, #self.SupportItemList do
        self.SupportItemList[i].GameObject:SetActiveEx(false)
    end
end

-- 保存更新buff选中状态
function XUiBabelTowerSupportChoice:OnSupportChoiceItemClick(index)
    -- 取消选中
    -- 选中
    -- 点数不足不可选中
    
    local lastSelctBuffId = self.BuffGoupDatas.SelectedBuffId
    local currentSelectBuffId = self.BuffGroupTemplate.BuffId[index]
    if self.BuffGoupDatas.SelectedBuffId == currentSelectBuffId then
        
        self.BuffGoupDatas.SelectedBuffId = nil
        self.UiRoot:UpdateChoosedChallengeDatas(self.BuffGroupId, self.BuffGoupDatas.SelectedBuffId)
        self.BuffGoupDatas.CurSelectId = -1
    else

        local curbuffTemplate = XFubenBabelTowerConfigs.GetBabelTowerBuffTemplate(currentSelectBuffId)
        local lastPointSub = 0
        if lastSelctBuffId then
            local lastbuffTemplate = XFubenBabelTowerConfigs.GetBabelTowerBuffTemplate(lastSelctBuffId)
            lastPointSub = lastbuffTemplate.PointSub
        end
        if curbuffTemplate.PointSub > self.UiRoot:GetAvaliableSupportPoint() + lastPointSub then return end
        
        self.BuffGoupDatas.SelectedBuffId = currentSelectBuffId
        self.UiRoot:UpdateChoosedChallengeDatas(self.BuffGroupId, self.BuffGoupDatas.SelectedBuffId)
        self.BuffGoupDatas.CurSelectId = index
    end
end

function XUiBabelTowerSupportChoice:GetBuffSelectStatus(buffId)
    if not self.BuffGoupDatas then return false end
    return self.BuffGoupDatas.SelectedBuffId == buffId
end

-- 更新未选中buff可选状态
function XUiBabelTowerSupportChoice:UpdateGridChoiceState(avaliableSupportPoint)
    if self.BuffGoupDatas.SelectedBuffId then
        local lastBuffTemplate = XFubenBabelTowerConfigs.GetBabelTowerBuffTemplate(self.BuffGoupDatas.SelectedBuffId)
        avaliableSupportPoint = avaliableSupportPoint + lastBuffTemplate.PointSub
    end
    self.GridContent.CurSelectId = self.BuffGoupDatas.CurSelectId
    for i=1, #self.BuffGroupTemplate.BuffId do
        local buffId = self.BuffGroupTemplate.BuffId[i]
        local buffTemplate = XFubenBabelTowerConfigs.GetBabelTowerBuffTemplate(buffId)
        
        -- 没有被选中的
        if not self:GetBuffSelectStatus(buffId) and self.SupportBtnCompList[i] then
            local btnStatus = (avaliableSupportPoint >= buffTemplate.PointSub) and UiButtonState.Normal or UiButtonState.Disable
            self.SupportBtnCompList[i]:SetButtonState(btnStatus)
        end
    end
end

return XUiBabelTowerSupportChoice