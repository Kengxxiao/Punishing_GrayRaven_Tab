local XUiBabelTowerChildSupport = XLuaUiManager.Register(XLuaUi, "UiBabelTowerChildSupport")

local XUiBabelMemberHead = require("XUi/XUiFubenBabelTower/XUiBabelMemberHead")
local XUiBabelTowerSupportChoice = require("XUi/XUiFubenBabelTower/XUiBabelTowerSupportChoice")
local XUiBabelTowerChallengeSelect = require("XUi/XUiFubenBabelTower/XUiBabelTowerChallengeSelect")

function XUiBabelTowerChildSupport:OnAwake()
    self.BtnBack.CallBack = function() self:OnBtnBackClick() end
    self.BtnGo.CallBack = function() self:OnBtnGoClick() end
    self.BtnSupport.CallBack = function() self:OnBtnSupportClick() end

    self.TeamMemberList = {}
    for i = 1, XFubenBabelTowerConfigs.MAX_TEAM_MEMBER do
        self.TeamMemberList[i] = XUiBabelMemberHead.New(self[string.format("TeamMember%d", i)], i)
        self.TeamMemberList[i]:ClearMemberHead()
        self.TeamMemberList[i]:SetMemberCallBack(function()
            XLuaUiManager.Open("UiBabelTowerTeamTips", self, self.StageId, self.GuideId, self.UiRoot.ChallengeBuffInfos)
        end)
    end

    self.DynamicTableSupportChoice = XDynamicTableNormal.New(self.PanelSupportChoice.gameObject)
    self.DynamicTableSupportChoice:SetProxy(XUiBabelTowerSupportChoice)
    self.DynamicTableSupportChoice:SetDelegate(self)
    self.DynamicTableSupportChoice:SetDynamicEventDelegate(function(event, index, grid)
        self:OnSupportChoiceDynamicTableEvent(event, index, grid)
    end)

    self.DynamicTableSupportSelect = XDynamicTableNormal.New(self.PanelSelectSupport.gameObject)
    self.DynamicTableSupportSelect:SetProxy(XUiBabelTowerChallengeSelect)
    self.DynamicTableSupportSelect:SetDelegate(self)
    self.DynamicTableSupportSelect:SetDynamicEventDelegate(function(event, index, grid)
        self:OnSupportSelectDynamicTableEvent(event, index, grid)
    end)

    self.ChoosedSupportList = {}
    self.SupportBuffSelectGroup = {}
    
    -- 初始化队伍信息
    self.NewTeamList = {}
    self:ClearTeamList()

    XEventManager.AddEventListener(XEventId.EVNET_BABEL_CHALLENGE_BUFF_CHANGED, self.CheckTeamBanCharacterList, self)
end

function XUiBabelTowerChildSupport:OnDestroy()
    XEventManager.RemoveEventListener(XEventId.EVNET_BABEL_CHALLENGE_BUFF_CHANGED, self.CheckTeamBanCharacterList, self)
end

function XUiBabelTowerChildSupport:CheckTeamBanCharacterList()
    local banCharacters = XDataCenter.FubenBabelTowerManager.GetBanCharacterIdsByBuff(self.UiRoot.ChallengeBuffInfos)
    for i = 1, XFubenBabelTowerConfigs.MAX_TEAM_MEMBER do
        local curChar = self.NewTeamList[i]
        if curChar ~= nil and curChar ~= 0 and banCharacters[curChar] then
            self.NewTeamList[i] = 0
            self.TeamMemberList[i]:SetMemberInfo(self.NewTeamList[i])     
        end
    end
end

-- 仅此一份,其他界面都以这个为准
function XUiBabelTowerChildSupport:GetTeamList()
    return self.NewTeamList
end

function XUiBabelTowerChildSupport:ClearTeamList()
    for i=1, XFubenBabelTowerConfigs.MAX_TEAM_MEMBER do
        self.NewTeamList[i] = 0
    end
end

function XUiBabelTowerChildSupport:OnSupportChoiceDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:Init(self)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        if self.SupportBuffGroup[index] then
            grid:SetItemData(self.SupportBuffGroup[index])
        end
    end
end

function XUiBabelTowerChildSupport:OnSupportSelectDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:Init(self)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        if self.ChoosedSupportList[index] then
            grid:SetItemData(self.ChoosedSupportList[index], XFubenBabelTowerConfigs.TYPE_SUPPORT)
        end
    end
end

function XUiBabelTowerChildSupport:OnBtnBackClick()
    self.UiRoot:Switch2ChallengePhase()
end

function XUiBabelTowerChildSupport:OnBtnGoClick()
    -- 前往配置队伍
    XLuaUiManager.Open("UiBabelTowerTeamTips", self, self.StageId, self.GuideId, self.UiRoot.ChallengeBuffInfos)
end

function XUiBabelTowerChildSupport:OnBtnSupportClick()
    -- 支援详情
    XLuaUiManager.Open("UiBabelTowerDetails", XFubenBabelTowerConfigs.TIPSTYPE_SUPPORT, self.StageId)
end

function XUiBabelTowerChildSupport:OnStart(uiRoot, stageId, guideId)
    self.UiRoot = uiRoot
    self.StageId = stageId
    self.GuideId = guideId
    self.BabelTowerStageTemplate = XFubenBabelTowerConfigs.GetBabelTowerStageTemplate(self.StageId)

    self:GetTotalSupportPoint()
    self:SetSupportChoiceDatas()
    
    self:SetTeamListDatas()

    -- 初始化检查一遍阵容
    self:CheckTeamBanCharacterList()
    self:ReportTeamList()
    
    self:OnUpdateTeamMemberEnd()

    XLuaUiManager.Open("UiBabelTowerTeamTips", self, self.StageId, self.GuideId, self.UiRoot.ChallengeBuffInfos)
end

-- 设置支援目标战略组
function XUiBabelTowerChildSupport:SetSupportChoiceDatas()
    self:GenSupportGroupDatas()
    self:GenSupportSelectDatas()
    self.DynamicTableSupportChoice:SetDataSource(self.SupportBuffGroup)
    self.DynamicTableSupportChoice:ReloadDataASync()
end

-- 设置队伍信息:初始化
function XUiBabelTowerChildSupport:SetTeamListDatas()
    local teamRecord = XDataCenter.FubenBabelTowerManager.GetBabelTowerStageInfo(self.StageId)
    if not teamRecord or not teamRecord.TeamList then
        self:ClearTeamList()
        return 
    end
    for i = 1, XFubenBabelTowerConfigs.MAX_TEAM_MEMBER do
        local teamMember = teamRecord.TeamList[i] or 0
        if teamRecord.IsReset then
            teamMember = 0
        end
        self.NewTeamList[i] = teamMember
        self.TeamMemberList[i]:SetMemberInfo(self.NewTeamList[i])
    end
    self:ReportTeamList()
end

-- 更新队伍信息:手动改变队伍
function XUiBabelTowerChildSupport:UpdateTeamMember(member_position, characterId)
    if member_position <= 0 or member_position > XFubenBabelTowerConfigs.MAX_TEAM_MEMBER then return end
    self.NewTeamList[member_position] = characterId or 0
    self.TeamMemberList[member_position]:SetMemberInfo(self.NewTeamList[member_position])
    self:ReportTeamList()
end

function XUiBabelTowerChildSupport:UpdateTeamInfo()
    for i = 1, XFubenBabelTowerConfigs.MAX_TEAM_MEMBER do
        local characterId = self.TeamMemberList[i].CharacterId
        self.TeamMemberList[i]:SetMemberInfo(characterId)
    end
end

-- 切换队伍结束：计算支援点
function XUiBabelTowerChildSupport:OnUpdateTeamMemberEnd()
    -- 计算总的支援点数
    self:GetTotalSupportPoint()
    self:CheckSupportSelectBuffs()
    self:UpdateSupportChooiceState()
    self.TxtChallengeNumber.text = self:GetAvaliableSupportPoint()
end

-- 清理选中支援组
function XUiBabelTowerChildSupport:CheckSupportSelectBuffs()
    local supportSelectBuffs = {}
    local usedSupportPoints = 0

    for i = 1, #self.ChoosedSupportList do
        local datas = self.ChoosedSupportList[i]
        local buffTemplate = XFubenBabelTowerConfigs.GetBabelTowerBuffTemplate(datas.SelectBuffId)
        local curCostSupportPoints = usedSupportPoints + buffTemplate.PointSub
        local isChoose = false
        if curCostSupportPoints <= self.TotalSupportPoint then
            usedSupportPoints = curCostSupportPoints
            table.insert(supportSelectBuffs, datas)
            isChoose = true
        else
            self:UnselectSupportChoice(datas.BuffGroupId)
        end

        for k, v in pairs(self.SupportBuffSelectGroup or {}) do
            if v.BuffGroupId == datas.BuffGroupId then
                local buffId = isChoose and datas.SelectBuffId or nil
                v.SelectBuffId = buffId
                break
            end
        end

    end
    self.ChoosedSupportList = supportSelectBuffs
    self:ReportSupportChoice()
    self.DynamicTableSupportSelect:SetDataSource(self.ChoosedSupportList)
    self.DynamicTableSupportSelect:ReloadDataASync()
    self.ImgEmpty.gameObject:SetActiveEx(#self.ChoosedSupportList <= 0)
end

-- 清理支援选项
function XUiBabelTowerChildSupport:UnselectSupportChoice(buffGroupId)
    for k, v in pairs(self.SupportBuffGroup or {}) do
        if v.BuffGroupId == buffGroupId then
            v.SelectedBuffId = nil
            v.CurSelectId = -1
            break
        end
    end
end

function XUiBabelTowerChildSupport:UpdateSupportChooiceState()
    for i = 1, #self.SupportBuffGroup do
        local grid = self.DynamicTableSupportChoice:GetGridByIndex(i)
        if grid then
            grid:UpdateGridChoiceState(self:GetAvaliableSupportPoint())
        end
    end
end

function XUiBabelTowerChildSupport:CalcUsedSupportPoint()
    local usedSupportPoint = 0

    for _, choosedItem in pairs(self.ChoosedSupportList or {}) do
        local buffTemplate = XFubenBabelTowerConfigs.GetBabelTowerBuffTemplate(choosedItem.SelectBuffId)
        usedSupportPoint = usedSupportPoint + (buffTemplate.PointSub or 0)
    end

    return usedSupportPoint
end

function XUiBabelTowerChildSupport:GetAvaliableSupportPoint()
    return self.TotalSupportPoint - self:CalcUsedSupportPoint()
end

-- 获取支援点数，阵容一旦确定,支援点数也可以确定
function XUiBabelTowerChildSupport:GetTotalSupportPoint()

    self.TotalSupportPoint = self.BabelTowerStageTemplate.BaseSupportPoint or 0

    local characterIds = {}
    for i = 1, XFubenBabelTowerConfigs.MAX_TEAM_MEMBER do
        local characterId = self.TeamMemberList[i].CharacterId
        if characterId ~= nil and characterId ~= 0 then
            table.insert(characterIds, characterId)
        end
    end

    for i = 1, #self.BabelTowerStageTemplate.SupportConditionId do
        local supportConditionId = self.BabelTowerStageTemplate.SupportConditionId[i]
        local supportConditionTemplate = XFubenBabelTowerConfigs.GetBabelTowerSupportConditonTemplate(supportConditionId)
        if supportConditionTemplate.Condition == nil or supportConditionTemplate.Condition == 0 then
            self.TotalSupportPoint = self.TotalSupportPoint + supportConditionTemplate.PointAdd
        else
            local isConditionAvaliable, desc = XConditionManager.CheckCondition(supportConditionTemplate.Condition, characterIds)
            if isConditionAvaliable then
                self.TotalSupportPoint = self.TotalSupportPoint + supportConditionTemplate.PointAdd
            end
        end
    end
    return self.TotalSupportPoint
end

-- 保存一份数据，记录玩家选中的挑战项SelectBuffList = {buffId = isSelect}
function XUiBabelTowerChildSupport:GenSupportGroupDatas()
    if self.SupportBuffGroup then return self.SupportBuffGroup end
    self.SupportBuffGroup = {}
    for i=1, #self.BabelTowerStageTemplate.SupportBuffGroup do
        table.insert(self.SupportBuffGroup, {
            StageId = self.StageId,
            GuideId = self.GuideId,
            BuffGroupId = self.BabelTowerStageTemplate.SupportBuffGroup[i],
            SelectedBuffId = nil,
            CurSelectId = -1
        })
    end
end

function XUiBabelTowerChildSupport:GenSupportSelectDatas()
    self.SupportBuffSelectGroup = {}
    for i = 1, #self.BabelTowerStageTemplate.SupportBuffGroup do
        table.insert(self.SupportBuffSelectGroup, {
            BuffGroupId = self.BabelTowerStageTemplate.SupportBuffGroup[i],
            SelectBuffId = nil
        })
    end
end

-- 设置已选支援组
function XUiBabelTowerChildSupport:UpdateChoosedChallengeDatas(buffGroupId, buffId)
    if not self.SupportBuffSelectGroup then self:GenSupportSelectDatas() end
    self.ChoosedSupportList = {}
    for i = 1, #self.SupportBuffSelectGroup do
        local groupItem = self.SupportBuffSelectGroup[i]
        if groupItem.BuffGroupId == buffGroupId then
            groupItem.SelectBuffId = buffId
        end
        if groupItem.SelectBuffId then
            table.insert(self.ChoosedSupportList, groupItem)
        end
    end

    self:ReportSupportChoice()
    self.DynamicTableSupportSelect:SetDataSource(self.ChoosedSupportList)
    self.DynamicTableSupportSelect:ReloadDataASync()
    self.ImgEmpty.gameObject:SetActiveEx(#self.ChoosedSupportList <= 0)
    self:UpdateSupportChooiceState()
    self.TxtChallengeNumber.text = self:GetAvaliableSupportPoint()
end

function XUiBabelTowerChildSupport:ReportSupportChoice()
    self.UiRoot:UpdateSupportBuffInfos(self.ChoosedSupportList)
end

function XUiBabelTowerChildSupport:ReportTeamList()
    self.UiRoot:UpdateTeamList(self.NewTeamList)
end