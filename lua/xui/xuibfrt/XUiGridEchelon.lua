local CONDITION_COLOR = {
    [true] = CS.UnityEngine.Color.black,
    [false] = CS.UnityEngine.Color.red,
}
local MAX_ECHELON_MEMBER_COUNT = 3  --梯队最大成员数量
local XUiGridEchelonMember = require("XUi/XUiBfrt/XUiGridEchelonMember")
local XUiGridEchelon = XClass()

function XUiGridEchelon:Ctor(rootUi, ui, data)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    self:InitAutoScript()
    XTool.InitUiObject(self)
    self:ResetEchelonInfo()
    self:UpdateEchelonInfo(data)
end

function XUiGridEchelon:ResetEchelonInfo()
    self.EchelonType = nil
    self.EchelonId = nil
    self.EchelonIndex = nil
    self.BaseStage = nil
    self.EchelonRequireCharacterNum = nil
    self.GirdEchelonMemberList = {}
    self.TeamList = {}
    self.CharacterIdListWrap = {}

    self.GridEchelonMember.gameObject:SetActive(false)
    self.TxtDoNotNeedFight.gameObject:SetActive(false)
    self.PanelTitleBgFight.gameObject:SetActive(false)
    self.PanelTitleBgLogistic.gameObject:SetActive(false)
    self.PanelLogisticSkill.gameObject:SetActive(false)
    self.PanelLeaderSkill.gameObject:SetActive(false)
    self.TxtLeaderSkill.gameObject:SetActive(false)
end

function XUiGridEchelon:UpdateEchelonInfo(data)
    self.EchelonType = data.EchelonType
    self.EchelonId = data.EchelonId
    self.EchelonIndex = data.EchelonIndex
    self.BaseStage = data.BaseStage
    self.EchelonRequireCharacterNum = XDataCenter.BfrtManager.GetEchelonNeedCharacterNum(self.EchelonId)
    self.ConditionId = XDataCenter.BfrtManager.GetEchelonConditionId(self.EchelonId)

    self.TeamList = data.TeamList
    self.CharacterIdListWrap = data.CharacterIdListWrap

    self:UpdateTitle()
    self:UpdateTxtExtraCondition()
    self:UpdateTxtLeaderSkill()
    self:UpdatePanelEchelonMembers()
    self:UpdateEchelonConditionState()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiGridEchelon:InitAutoScript()
    self:AutoInitUi()
end

function XUiGridEchelon:AutoInitUi()
    self.PanelLeaderSkill = self.Transform:Find("PanelLeaderSkill")
    self.TxtLeaderSkill = self.Transform:Find("PanelLeaderSkill/TxtLeaderSkill"):GetComponent("Text")
    self.PanelRequire = self.Transform:Find("PanelRequire")
    self.TxtExtraCondition = self.Transform:Find("PanelRequire/TxtExtraCondition"):GetComponent("Text")
    self.PanelTitleBgLogistic = self.Transform:Find("PanelTitleBgLogistic")
    self.TxtTitleA = self.Transform:Find("PanelTitleBgLogistic/TxtTitle"):GetComponent("Text")
    self.PanelTitleBgFight = self.Transform:Find("PanelTitleBgFight")
    self.TxtTitle = self.Transform:Find("PanelTitleBgFight/TxtTitle"):GetComponent("Text")
    self.PanelEchelonMembers = self.Transform:Find("PanelEchelonMembers")
    self.GridEchelonMember = self.Transform:Find("PanelEchelonMembers/GridEchelonMember")
    self.TxtDoNotNeedFight = self.Transform:Find("TxtDoNotNeedFight"):GetComponent("Text")
    self.PanelLogisticSkill = self.Transform:Find("PanelLogisticSkill")
    self.TxtLogisticSkill = self.Transform:Find("PanelLogisticSkill/TxtLogisticSkill"):GetComponent("Text")
    self.ImgNotPassCondition = self.Transform:Find("ImgNotPassCondition"):GetComponent("Image")
end

function XUiGridEchelon:UpdateTitle()
    if self.EchelonType == XDataCenter.BfrtManager.EchelonType.Fight then
        self.PanelTitleBgFight.gameObject:SetActive(true)
        self.TxtTitle.text = CS.XTextManager.GetText("BfrtFightEchelonTitle", self.EchelonIndex)
    elseif self.EchelonType == XDataCenter.BfrtManager.EchelonType.Logistics then
        self.PanelTitleBgLogistic.gameObject:SetActive(true)
        self.TxtDoNotNeedFight.gameObject:SetActive(true)
        self.TxtTitleA.text = CS.XTextManager.GetText("BfrtLogisticEchelonTitle", self.EchelonIndex)
    end
end

function XUiGridEchelon:UpdateTxtExtraCondition()
    local hasCondition = self.ConditionId > 0
    self.TxtExtraCondition.gameObject:SetActive(hasCondition)

    if hasCondition then
        local template = XConditionManager.GetConditionTemplate(self.ConditionId)
        if template then
            self.TxtExtraCondition.text = template.Desc
        end
    end
end

function XUiGridEchelon:UpdateTxtLeaderSkill()
    if self.EchelonType == XDataCenter.BfrtManager.EchelonType.Fight then
        local team = self.TeamList[self.EchelonIndex]
        if team then
            local captainId = team[XUiGridEchelonMember.CAPTIAN_MEMBER_INDEX]
            if captainId and captainId > 0 then
                local captianSkillInfo = XDataCenter.CharacterManager.GetCaptainSkillInfo(captainId)
                self.TxtLeaderSkill.text = captianSkillInfo.Intro
                self.TxtLeaderSkill.gameObject:SetActive(true)
            else
                self.TxtLeaderSkill.gameObject:SetActive(false)
            end
        else
            self.TxtLeaderSkill.gameObject:SetActive(false)
        end
        self.PanelLeaderSkill.gameObject:SetActive(true)
    else
        local logisticSkillDes = XDataCenter.BfrtManager.GetLogisticSkillDes(self.EchelonId)
        self.TxtLogisticSkill.text = logisticSkillDes
        self.PanelLogisticSkill.gameObject:SetActive(true)
    end
end

function XUiGridEchelon:UpdatePanelEchelonMembers()
    local data = {
        MemberIndex = nil,
        RequireAbility = nil,
        StageId = self.BaseStage,
        EchelonRequireCharacterNum = self.EchelonRequireCharacterNum,
        EchelonIndex = self.EchelonIndex,
        EchelonType = self.EchelonType,
        TeamList = self.TeamList,
        CharacterIdListWrap = self.CharacterIdListWrap,
        TeamHasLeader = self.EchelonType == XDataCenter.BfrtManager.EchelonType.Fight,
    }

    for i = 1, MAX_ECHELON_MEMBER_COUNT do
        data.MemberIndex = XDataCenter.BfrtManager.TeamPosConvert(i)
        data.RequireAbility = XDataCenter.BfrtManager.GetEchelonRequireAbility(self.EchelonId)

        if not self.GirdEchelonMemberList[i] then
            local ui = CS.UnityEngine.Object.Instantiate(self.GridEchelonMember)
            local grid = XUiGridEchelonMember.New(self, ui, data)
            grid.Transform:SetParent(self.PanelEchelonMembers, false)
            grid.GameObject:SetActive(true)
            grid.GameObject.name = "GridEchelonMember" .. i
            self.GirdEchelonMemberList[i] = grid
        else
            self.GirdEchelonMemberList[i]:UpdateMemberInfo(data)
        end
    end
end

function XUiGridEchelon:UpdateEchelonConditionState()
    local requireAbility = XDataCenter.BfrtManager.GetEchelonRequireAbility(self.EchelonId)
    self.TxtRequireAbility.text = requireAbility

    local characterCount = 0
    local allOverAbility = true
    local team = self.TeamList[self.EchelonIndex]
    for _, characterId in pairs(team) do
        if characterId > 0 then
            characterCount = characterCount + 1
            local char = XDataCenter.CharacterManager.GetCharacter(characterId)
            local nowAbility = char and char.Ability or 0
            if nowAbility < requireAbility then
                allOverAbility = false
                break
            end
        end
    end

    local retRequireNum = characterCount >= self.EchelonRequireCharacterNum

    local retCondition = self.ConditionId <= 0 or XConditionManager.CheckCondition(self.ConditionId, team)
    self.TxtExtraCondition.color = CONDITION_COLOR[retCondition]

    local pass = allOverAbility and retCondition and retRequireNum
    -- self.ImgNotPassCondition.gameObject:SetActive(not pass)
    self.ImgNotPassCondition.gameObject:SetActiveEx(false)
    self.ConditionPassed = pass
end

function XUiGridEchelon:UpdateTeamInfo(team)
    self.TeamList[self.EchelonIndex] = team
    self.RootUi:UpdateEchelonList()
end

function XUiGridEchelon:CheckIsInTeamList(characterId)
    return self.RootUi:CheckIsInTeamList(characterId)
end

function XUiGridEchelon:CharacterSwapEchelon(oldCharacterId, newCharacterId)
    return self.RootUi:CharacterSwapEchelon(oldCharacterId, newCharacterId)
end

return XUiGridEchelon