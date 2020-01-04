local table = table
local pairs = pairs
local ipairs = ipairs
local ANIMATION_OPEN = "AniBfrtDeployBegin"

local XUiGridEchelon = require("XUi/XUiBfrt/XUiGridEchelon")
local XUiBfrtDeploy = XLuaUiManager.Register(XLuaUi, "UiBfrtDeploy")

function XUiBfrtDeploy:OnAwake()
    self:InitAutoScript()
    self:InitComponent()
    self:ResetGroupInfo()
end

function XUiBfrtDeploy:OnStart(groupId)
    self:InitGroupInfo(groupId)
    XUiHelper.PlayAnimation(self, ANIMATION_OPEN, nil, nil)
end

function XUiBfrtDeploy:OnDestroy()
    self:ResetGroupInfo()
end

function XUiBfrtDeploy:InitComponent()
    self.GridEchelon.gameObject:SetActive(false)
end

function XUiBfrtDeploy:ResetGroupInfo()
    self.GroupId = nil
    self.FightInfoIdList = {}
    self.LogisticsInfoIdList = {}
    self.FightTeamList = {}
    self.LogisticsTeamList = {}
    self.CharacterIdListWrap = {}
    self.FightTeamGridList = {}
    self.LogisticsTeamGridList = {}
end

function XUiBfrtDeploy:InitGroupInfo(groupId)
    if not groupId then
        XLog.Error("XUiBfrtDeploy:InitGroupInfo error: groupId not Exist.")
        return
    end
    self.GroupId = groupId
    self.FightInfoIdList = XDataCenter.BfrtManager.GetFightInfoIdList(groupId)
    self.LogisticsInfoIdList = XDataCenter.BfrtManager.GetLogisticsInfoIdList(groupId)
    self.FightTeamList = {}
    self.LogisticsTeamList = {}

    self:UpdateEchelonList()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiBfrtDeploy:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiBfrtDeploy:AutoInitUi()
    self.BtnMainUi = self.Transform:Find("SafeAreaContentPane/PaneButtonTop/BtnMainUi"):GetComponent("Button")
    self.BtnFight = self.Transform:Find("SafeAreaContentPane/BtnFight"):GetComponent("Button")
    self.BtnBack = self.Transform:Find("SafeAreaContentPane/PaneButtonTop/BtnBack"):GetComponent("Button")
    self.PanelEchelonContent = self.Transform:Find("SafeAreaContentPane/PaneEchelon/EchelonList/Viewport/PanelEchelonContent")
    self.GridEchelon = self.Transform:Find("SafeAreaContentPane/PaneEchelon/EchelonList/Viewport/PanelEchelonContent/GridEchelon")
end

function XUiBfrtDeploy:GetAutoKey(uiNode, eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiBfrtDeploy:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiBfrtDeploy:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiBfrtDeploy:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterListener(self.BtnMainUi, "onClick", self.OnBtnMainUiClick)
    self:RegisterListener(self.BtnBack, "onClick", self.OnBtnBackClick)
    self.BtnAutoTeam.CallBack = function ()
        self:OnBtnAutoTeamClick()
    end
    self.BtnFight.CallBack = function ()
        self:OnBtnFightClick()
    end
end
-- auto
function XUiBfrtDeploy:OnBtnFightClick(...)
    --先检查挑战次数
    local groupId = self.GroupId
    local baseStageId = XDataCenter.BfrtManager.GetBaseStage(groupId)
    local chanllengeNum = XDataCenter.BfrtManager.GetGroupFinishCount(baseStageId)
    local maxChallengeNum = XDataCenter.BfrtManager.GetGroupMaxChallengeNum(baseStageId)
    if maxChallengeNum > 0 and chanllengeNum >= maxChallengeNum then
        XUiManager.TipMsg(CS.XTextManager.GetText("FubenChallengeCountNotEnough"))
        return
    end

    --再检查队伍
    local fightTeamList = self.FightTeamList
    local logisticsTeamList = self.LogisticsTeamList
    local checkTeamCb = function()
        self:Close()
        XLuaUiManager.Open("UiBfrtInfo", groupId, fightTeamList)
    end

    XDataCenter.BfrtManager.CheckTeam(groupId, fightTeamList, logisticsTeamList, checkTeamCb)
end

function XUiBfrtDeploy:OnBtnAutoTeamClick()
    local fightTeamList, logisticsTeamList, anyMemberInTeam = XDataCenter.BfrtManager.AutoTeam(self.GroupId)
    if not anyMemberInTeam then
        XUiManager.TipMsg(CS.XTextManager.GetText("BfrtAutoTeamNoMember"))
        return
    end

    self.FightTeamList,self.LogisticsTeamList = fightTeamList, logisticsTeamList
    self:UpdateEchelonList()
end

function XUiBfrtDeploy:OnBtnBackClick(...)
    self:Close()
end

function XUiBfrtDeploy:OnBtnMainUiClick(...)
    XLuaUiManager.RunMain()
end

function XUiBfrtDeploy:UpdateEchelonList()
    local passCondition = true

    local data = {
        EchelonType = nil,
        EchelonId = nil,
        EchelonIndex = nil,
        BaseStage = XDataCenter.BfrtManager.GetBaseStage(self.GroupId),
    }

    for index, echelonId in ipairs(self.FightInfoIdList) do
        data.EchelonType = XDataCenter.BfrtManager.EchelonType.Fight
        data.EchelonId = echelonId
        data.EchelonIndex = index
        data.TeamList = self.FightTeamList
        data.CharacterIdListWrap = self.CharacterIdListWrap

        local grid = self.FightTeamGridList[index]
        if not grid then
            local ui = CS.UnityEngine.Object.Instantiate(self.GridEchelon)
            grid = XUiGridEchelon.New(self, ui, data)
            grid.Transform:SetParent(self.PanelEchelonContent, false)
            grid.GameObject:SetActive(true)
            grid.GameObject.name = tostring(echelonId)
            self.FightTeamGridList[index] = grid
        else
            grid:UpdateEchelonInfo(data)
        end

        passCondition = passCondition and grid.ConditionPassed
    end

    for i = #self.FightInfoIdList + 1, #self.FightTeamList do
        self.FightTeamList[i] = nil
    end

    for index, echelonId in ipairs(self.LogisticsInfoIdList) do
        data.EchelonType = XDataCenter.BfrtManager.EchelonType.Logistics
        data.EchelonId = echelonId
        data.EchelonIndex = index
        data.TeamList = self.LogisticsTeamList
        data.CharacterIdListWrap = self.CharacterIdListWrap

        local grid = self.LogisticsTeamGridList[index]
        if not grid then
            local ui = CS.UnityEngine.Object.Instantiate(self.GridEchelon)
            grid = XUiGridEchelon.New(self, ui, data)
            grid.Transform:SetParent(self.PanelEchelonContent, false)
            grid.GameObject:SetActive(true)
            grid.GameObject.name = tostring(echelonId)
            self.LogisticsTeamGridList[index] = grid
        else
            grid:UpdateEchelonInfo(data)
        end

        passCondition = passCondition and grid.ConditionPassed
    end

    for i = #self.LogisticsInfoIdList + 1, #self.LogisticsTeamList do
        self.LogisticsTeamList[i] = nil
    end

    -- self.PanelDanger.gameObject:SetActive(not passCondition)
    self.PanelDanger.gameObject:SetActive(false)
end

function XUiBfrtDeploy:CheckIsInTeamList(characterId)
    if not characterId or characterId == 0 then
        return
    end

    for echelonIndex, team in pairs(self.FightTeamList) do
        for _, id in pairs(team) do
            if id == characterId then
                return echelonIndex, XDataCenter.BfrtManager.EchelonType.Fight
            end
        end
    end

    for echelonIndex, team in pairs(self.LogisticsTeamList) do
        for _, id in pairs(team) do
            if id == characterId then
                return echelonIndex, XDataCenter.BfrtManager.EchelonType.Logistics
            end
        end
    end
end

function XUiBfrtDeploy:CharacterSwapEchelon(oldCharacterId, newCharacterId)
    local oldTeam, oldCharacterPos

    for echelonIndex, team in pairs(self.FightTeamList) do
        for pos, id in pairs(team) do
            if id == oldCharacterId then
                oldTeam = team
                oldCharacterPos = pos
                break
            end
        end
    end

    if not oldTeam then
        for echelonIndex, team in pairs(self.LogisticsTeamList) do
            for pos, id in pairs(team) do
                if id == oldCharacterId then
                    oldTeam = team
                    oldCharacterPos = pos
                    break
                end
            end
        end
    end

    oldTeam[oldCharacterPos] = newCharacterId
end