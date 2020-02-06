local CONDITION_COLOR = {
    [true] = CS.UnityEngine.Color.white,
    [false] = CS.UnityEngine.Color.red,
}

local XUiGridEchelonMember = XClass()
XUiGridEchelonMember.CAPTIAN_MEMBER_INDEX = 1   --队长位置

--位置对应的颜色框
local MEMBER_POS_COLOR = {
    [1] = "ImgRed",
    [2] = "ImgBlue",
    [3] = "ImgYellow",
}

function XUiGridEchelonMember:Ctor(rootUi, ui, data)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    self:InitAutoScript()
    self:ResetMemberInfo()
    self:UpdateMemberInfo(data)
end

function XUiGridEchelonMember:ResetMemberInfo()
    self.MemberIndex = nil
    self.RequireAbility = nil
    self.StageId = nil
    self.EchelonRequireCharacterNum = nil
    self.EchelonIndex = nil
    self.EchelonType = nil
    self.TeamList = {}
    self.CharacterIdListWrap = {}
    self.TeamHasLeader = false

    self.ImgLeaderTag.gameObject:SetActive(false)
    self.PanelEmpty.gameObject:SetActive(false)
    self.PanelSlect.gameObject:SetActive(false)
    self.PanelLock.gameObject:SetActive(false)
    self.PanelColour.gameObject:SetActive(false)
    self.ImgBlue.gameObject:SetActive(false)
    self.ImgRed.gameObject:SetActive(false)
    self.ImgYellow.gameObject:SetActive(false)
end

function XUiGridEchelonMember:UpdateMemberInfo(data)
    self.MemberIndex = data.MemberIndex
    self.EchelonRequireCharacterNum = data.EchelonRequireCharacterNum
    if self.MemberIndex > self.EchelonRequireCharacterNum then
        return
    end

    self.RequireAbility = data.RequireAbility
    self.StageId = data.StageId
    self.EchelonIndex = data.EchelonIndex
    self.EchelonType = data.EchelonType
    self.TeamList = data.TeamList
    self.CharacterIdListWrap = data.CharacterIdListWrap
    self.TeamHasLeader = data.TeamHasLeader
    self:CheckTeamNum()
    self:InitPanelColour()
    self:UpdateImgLeaderTag()
    self:UpdateCharacterInfo()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiGridEchelonMember:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiGridEchelonMember:AutoInitUi()
    self.BtnClick = self.Transform:Find("BtnClick"):GetComponent("Button")
    self.PanelSlect = self.Transform:Find("PanelSlect")
    self.ImgMask = self.Transform:Find("PanelSlect/ImgMask"):GetComponent("Image")
    self.RImgRoleHead = self.Transform:Find("PanelSlect/ImgMask/RImgRoleHead"):GetComponent("RawImage")
    self.TxtNowAbility = self.Transform:Find("PanelSlect/PanelNotPassCondition/TxtNowAbility"):GetComponent("Text")
    self.PanelEmpty = self.Transform:Find("PanelEmpty")
    self.ImgLeaderTag = self.Transform:Find("ImgLeaderTag"):GetComponent("Image")
    self.PanelColour = self.Transform:Find("PanelColour")
    self.ImgYellow = self.Transform:Find("PanelColour/ImgYellow"):GetComponent("Image")
    self.ImgBlue = self.Transform:Find("PanelColour/ImgBlue"):GetComponent("Image")
    self.ImgRed = self.Transform:Find("PanelColour/ImgRed"):GetComponent("Image")
    self.PanelLock = self.Transform:Find("PanelLock")
end

function XUiGridEchelonMember:GetAutoKey(uiNode, eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiGridEchelonMember:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiGridEchelonMember:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiGridEchelonMember:AutoAddListener()
    self.AutoCreateListeners = {}
    XUiHelper.RegisterClickEvent(self, self.BtnClick, self.OnBtnClickClick)
end
-- auto
function XUiGridEchelonMember:OnBtnClickClick()
    if self.MemberIndex > self.EchelonRequireCharacterNum then
        return
    end

    local viewData = {
        RequireAbility = self.RequireAbility,
        TeamCharacterIdList = self.TeamList[self.EchelonIndex],
        TeamSelectPos = self.MemberIndex,
        EchelonIndex = self.EchelonIndex,
        EchelonType = self.EchelonType,
        CheckIsInTeamListCb = function(characterId)
            return self.RootUi:CheckIsInTeamList(characterId)
        end,
        CharacterSwapEchelonCb = function(oldCharacterId, newCharacterId)
            return self.RootUi:CharacterSwapEchelon(oldCharacterId, newCharacterId)
        end,
        TeamResultCb = function(team)
            self.RootUi:UpdateTeamInfo(team)
        end,
    }
    XLuaUiManager.Open("UiBfrtRoomCharacter", viewData)
end

function XUiGridEchelonMember:UpdateImgLeaderTag()
    if not self.TeamHasLeader then
        return
    end
    if self.MemberIndex <= self.EchelonRequireCharacterNum and self.MemberIndex == XUiGridEchelonMember.CAPTIAN_MEMBER_INDEX then
        self.ImgLeaderTag.gameObject:SetActive(true)
    end
end

function XUiGridEchelonMember:UpdateCharacterInfo()
    if self.MemberIndex > self.EchelonRequireCharacterNum then
        return
    end

    local characterId = self.TeamList[self.EchelonIndex][self.MemberIndex]
    if not characterId or characterId == 0 then
        if self.MemberIndex <= self.EchelonRequireCharacterNum then
            --没出人
            self.PanelSlect.gameObject:SetActive(false)
            self.PanelEmpty.gameObject:SetActive(true)
            self.PanelLock.gameObject:SetActive(false)
        else
            --不能上人（要求两个人，第三个格子的状态）
            self.PanelSlect.gameObject:SetActive(false)
            self.PanelEmpty.gameObject:SetActive(false)
            self.PanelLock.gameObject:SetActive(true)
        end
    else
        --上了人
        self.RImgRoleHead:SetRawImage(XDataCenter.CharacterManager.GetCharSmallHeadIcon(characterId))
        self.PanelSlect.gameObject:SetActive(true)
        self.PanelEmpty.gameObject:SetActive(false)
        self.PanelLock.gameObject:SetActive(false)

        local char = XDataCenter.CharacterManager.GetCharacter(characterId)
        local nowAbility = char and char.Ability or 0
        self.TxtNowAbility.text = math.floor(nowAbility)
        self.TxtNowAbility.color = CONDITION_COLOR[nowAbility >= self.RequireAbility]
    end
end

function XUiGridEchelonMember:InitPanelColour()
    if not self.TeamHasLeader then
        self.PanelColour.gameObject:SetActive(false)
        return
    end
    self[MEMBER_POS_COLOR[self.MemberIndex]].gameObject:SetActive(true)
    self.PanelColour.gameObject:SetActive(true)
end

function XUiGridEchelonMember:CheckTeamNum()
    self.TeamList[self.EchelonIndex] = self.TeamList[self.EchelonIndex] or { 0, 0, 0 }
    for i = #self.TeamList[self.EchelonIndex], self.EchelonRequireCharacterNum + 1, -1 do
        self.TeamList[self.EchelonIndex][i] = 0
    end
end

return XUiGridEchelonMember