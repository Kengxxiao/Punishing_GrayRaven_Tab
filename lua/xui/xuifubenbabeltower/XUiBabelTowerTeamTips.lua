local XUiBabelTowerTeamTips = XLuaUiManager.Register(XLuaUi, "UiBabelTowerTeamTips")
local XUiGridInfoSupportCondition = require("XUi/XUiFubenBabelTower/XUiGridInfoSupportCondition")
local XUiBabelMemberHead = require("XUi/XUiFubenBabelTower/XUiBabelMemberHead")

function XUiBabelTowerTeamTips:OnAwake()
    self.BtnTanchuangClose.CallBack = function() self:OnBtnBackClick() end
    self.BtnCancel.CallBack = function() self:OnBtnBackClick() end
    self.BtnConfirm.CallBack = function() self:OnBtnConfirmClick() end

    self.TeamMemberList = {}
    for i = 1, XFubenBabelTowerConfigs.MAX_TEAM_MEMBER do
        self.TeamMemberList[i] = XUiBabelMemberHead.New(self[string.format("TeamMember%d", i)], i)
        self.TeamMemberList[i]:ClearMemberHead()
        self.TeamMemberList[i]:SetMemberCallBack(function()
            self:ChooseTeamCharacter(i)
        end)
    end

    self.DynamicTableSupportConditon = XDynamicTableNormal.New(self.PanelCondition.gameObject)
    self.DynamicTableSupportConditon:SetProxy(XUiGridInfoSupportCondition)
    self.DynamicTableSupportConditon:SetDelegate(self)
    
end

function XUiBabelTowerTeamTips:OnEnable()
    for i = 1, XFubenBabelTowerConfigs.MAX_TEAM_MEMBER do
        self.TeamMemberList[i]:SetMemberInfo(self.TeamMemberList[i].CharacterId, true)
    end
    self.SupportConditionList = self:GetStageSupportConditionListSort()
    self.DynamicTableSupportConditon:SetDataSource(self.SupportConditionList)
    self.DynamicTableSupportConditon:ReloadDataASync()
    self.TxtChallengeNumber.text = self:GetTotalSupportPoint()
end

function XUiBabelTowerTeamTips:OnBtnBackClick()
    -- for i = 1, XFubenBabelTowerConfigs.MAX_TEAM_MEMBER do
    --     self.SupportUi:UpdateTeamMember(self.TeamMemberList[i].Index, self.TeamMemberList[i].CharacterId or 0)
    -- end
    -- 刷新支援界面信息
    self.SupportUi:UpdateTeamInfo()
    self.SupportUi:OnUpdateTeamMemberEnd()
    self:Close()
end

-- 确定按钮,将阵容更新到上一个界面
function XUiBabelTowerTeamTips:OnBtnConfirmClick()
    for i = 1, XFubenBabelTowerConfigs.MAX_TEAM_MEMBER do
        self.SupportUi:UpdateTeamMember(self.TeamMemberList[i].Index, self.TeamMemberList[i].CharacterId or 0)
    end
    -- 刷新支援界面信息
    self.SupportUi:OnUpdateTeamMemberEnd()
    self:Close()
end

function XUiBabelTowerTeamTips:OnStart(supportUi, stageId, guideId, challengeInfos)
    self.StageId = stageId
    self.GuideId = guideId
    self.SupportUi = supportUi
    self.StageTemplate = XFubenBabelTowerConfigs.GetBabelTowerStageTemplate(self.StageId)
    self.ChallengeBuffList = challengeInfos

    self:RefreshTeamList()

    -- self.SupportConditionList = self:GetStageSupportConditionListSort()
    -- self.DynamicTableSupportConditon:SetDataSource(self.SupportConditionList)
    -- self.DynamicTableSupportConditon:ReloadDataASync()

end

function XUiBabelTowerTeamTips:GetStageSupportConditionListSort()
    if not self.StageTemplate then return {} end
    local conditionList = {}
    for i = 1, #self.StageTemplate.SupportConditionId do
        local conditionId = self.StageTemplate.SupportConditionId[i]
        local conditionTemplate = XFubenBabelTowerConfigs.GetBabelTowerSupportConditonTemplate(conditionId)
        local isSupport = self:CheckBabelTeamCondition(conditionTemplate.Condition)
        table.insert(conditionList, {
            SupportConditionId = conditionId,
            IsSupport = isSupport
        })
    end
    table.sort(conditionList, function(elementA, elemenbB)
        local priorityA = elementA.IsSupport and 1 or 0
        local priorityB = elemenbB.IsSupport and 1 or 0
        if priorityA == priorityB then
            return elementA.SupportConditionId < elemenbB.SupportConditionId
        end
        return priorityA > priorityB
    end)
    return conditionList
end

-- 刷新队伍列表
function XUiBabelTowerTeamTips:RefreshTeamList()
    local teamList = self.SupportUi:GetTeamList()
    for i = 1, XFubenBabelTowerConfigs.MAX_TEAM_MEMBER do
        self.TeamMemberList[i]:SetMemberInfo(teamList[i], true)
    end
    -- 更新支援条件条件
    -- self:RefreshSupportConditionList()
    self.TxtChallengeNumber.text = self:GetTotalSupportPoint()

    self:RefreshLeaderSkill()
end


function XUiBabelTowerTeamTips:RefreshLeaderSkill()
    -- 如果有队长,增加队长描述
    local captainPos = XFubenBabelTowerConfigs.LEADER_POSITION
    local captainId = self.TeamMemberList[captainPos].CharacterId
    if captainId == nil or captainId <= 0 then
        self.TxtLeaderSkill.text = CS.XTextManager.GetText("BabelTowerPleaseSelectALeader")
    else
        local captianSkillInfo = XDataCenter.CharacterManager.GetCaptainSkillInfo(captainId)
        self.TxtLeaderSkill.text = captianSkillInfo.Intro
    end
end

function XUiBabelTowerTeamTips:GetCurTeamList()
    local teamList = {}
    for i = 1, XFubenBabelTowerConfigs.MAX_TEAM_MEMBER do
        table.insert(teamList, i, self.TeamMemberList[i].CharacterId or 0)
    end
    return teamList
end

-- 打开选人界面:没有角色不打开
function XUiBabelTowerTeamTips:ChooseTeamCharacter(index)
    local currentTeamList = self:GetCurTeamList()
    local selectableList = XDataCenter.FubenBabelTowerManager.GetSelectableTowerTeamListSort(self.StageId, currentTeamList, self.ChallengeBuffList)
    if #selectableList <= 0 then
        XUiManager.TipMsg(CS.XTextManager.GetText("BabelTowerNoneCharacter"))
        return 
    end
    XLuaUiManager.Open("UiBabelTowerRoomCharacter", selectableList, currentTeamList, self.TeamMemberList[index].CharacterId, function(characterId, isJoin)
        self:OnCharacterSelectChanged(index, characterId, isJoin)
    end)
end

-- 某个位置加入或者移出角色,更新当前界面的角色
function XUiBabelTowerTeamTips:OnCharacterSelectChanged(index, characterId, isJoin)
    if isJoin then
        -- 加入角色，替换当前位置
        self.TeamMemberList[index]:SetMemberInfo(characterId, true)
    else
        -- 卸下角色，所有位置检查，有就卸下，没有不用处理
        for i = 1, XFubenBabelTowerConfigs.MAX_TEAM_MEMBER do
            local memberCharId = self.TeamMemberList[i].CharacterId or 0
            if memberCharId == characterId then
                self.TeamMemberList[i]:SetMemberInfo(0)
                break
            end
        end 
    end

    -- 更新支援条件条件
    self.SupportConditionList = self:GetStageSupportConditionListSort()
    self.DynamicTableSupportConditon:SetDataSource(self.SupportConditionList)
    self.DynamicTableSupportConditon:ReloadDataASync()

    self.TxtChallengeNumber.text = self:GetTotalSupportPoint()
    self:RefreshLeaderSkill()
end

-- 更新支援组条件状态
-- function XUiBabelTowerTeamTips:RefreshSupportConditionList()
--     for i=1, #self.SupportConditionList do
--         local grid = self.DynamicTableSupportConditon:GetGridByIndex(i)
--         if grid then
--             grid:RefreshItemInfos()  
--         end
--     end
-- end

function XUiBabelTowerTeamTips:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:Init(self)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        if self.SupportConditionList[index] then
            grid:SetItemInfo(self.SupportConditionList[index])
        end
    end
end

function XUiBabelTowerTeamTips:CheckBabelTeamCondition(conditionId)
    if conditionId == nil or conditionId == 0 then return true end
    local characterIds = {}
    for i = 1, XFubenBabelTowerConfigs.MAX_TEAM_MEMBER do
        local characterId = self.TeamMemberList[i].CharacterId
        if characterId ~= nil and characterId ~= 0 then
            table.insert(characterIds, characterId)
        end
    end
    local isConditionAvaliable, desc = XConditionManager.CheckCondition(conditionId, characterIds)
    return isConditionAvaliable
end


function XUiBabelTowerTeamTips:GetTotalSupportPoint()
    local totalSupportPoint = self.StageTemplate.BaseSupportPoint or 0

    local characterIds = {}
    for i = 1, XFubenBabelTowerConfigs.MAX_TEAM_MEMBER do
        local characterId = self.TeamMemberList[i].CharacterId
        if characterId ~= nil and characterId ~= 0 then
            table.insert(characterIds, characterId)
        end
    end

    for i = 1, #self.StageTemplate.SupportConditionId do
        local supportConditionId = self.StageTemplate.SupportConditionId[i]
        local supportConditionTemplate = XFubenBabelTowerConfigs.GetBabelTowerSupportConditonTemplate(supportConditionId)
        if supportConditionTemplate.Condition == nil or supportConditionTemplate.Condition == 0 then
            totalSupportPoint = totalSupportPoint + supportConditionTemplate.PointAdd
        else
            local isConditionAvaliable, desc = XConditionManager.CheckCondition(supportConditionTemplate.Condition, characterIds)
            if isConditionAvaliable then
                totalSupportPoint = totalSupportPoint + supportConditionTemplate.PointAdd
            end
        end

    end

    return totalSupportPoint
end

