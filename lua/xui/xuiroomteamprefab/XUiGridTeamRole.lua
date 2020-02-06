XUiGridTeamRole = XClass()

function XUiGridTeamRole:Ctor(rootUi, ui)
    self.RootUi = rootUi
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiGridTeamRole:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiGridTeamRole:AutoInitUi()
    self.PanelNull = self.Transform:Find("PanelNull")
    self.PanelNullSelcet = self.Transform:Find("PanelNull/PanelNullSelcet")
    self.BtnPlus = self.Transform:Find("PanelNull/BtnPlus"):GetComponent("Button")
    self.ImgLeftnull = self.Transform:Find("PanelNull/ImgLeftnull"):GetComponent("Image")
    self.ImgRightnull = self.Transform:Find("PanelNull/ImgRightnull"):GetComponent("Image")
    self.PanelHave = self.Transform:Find("PanelHave")
    self.PanelHaveSelcet = self.Transform:Find("PanelHave/PanelHaveSelcet")
    self.ImgLeftSkill = self.Transform:Find("PanelHave/ImgLeftSkill"):GetComponent("Image")
    self.ImgRightSkill = self.Transform:Find("PanelHave/ImgRightSkill"):GetComponent("Image")
    self.ImgIcon = self.Transform:Find("PanelHave/ImageMask/ImgIcon"):GetComponent("Image")
    self.TxtLevel = self.Transform:Find("PanelHave/TxtLevel"):GetComponent("Text")
    self.ImgQuality = self.Transform:Find("PanelHave/ImgQuality"):GetComponent("Image")
    self.BtnClick = self.Transform:Find("PanelHave/BtnClick"):GetComponent("Button")
    self.RImgGrade = self.Transform:Find("PanelHave/RImgGrade"):GetComponent("RawImage")
    self.PanelLeader = self.Transform:Find("PanelLeader")
end

function XUiGridTeamRole:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiGridTeamRole:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiGridTeamRole:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiGridTeamRole:AutoAddListener()
    self:RegisterClickEvent(self.BtnPlus, self.OnBtnPlusClick)
    self:RegisterClickEvent(self.BtnClick, self.OnBtnClickClick)
end
-- auto
function XUiGridTeamRole:SetNull()
    self.ImgLeftnull.color = XDataCenter.TeamManager.GetTeamMemberColor(self.CurPos)
    self.ImgRightnull.color = XDataCenter.TeamManager.GetTeamMemberColor(self.CurPos)

    self.PanelHave.gameObject:SetActive(false)
    self.PanelNull.gameObject:SetActive(true)
end

function XUiGridTeamRole:SetHave(chrId)
    self.PanelHave.gameObject:SetActive(true)
    self.PanelNull.gameObject:SetActive(false)
    local character = XDataCenter.CharacterManager.GetCharacter(chrId)
    if not character then return end

    self.ImgLeftSkill.color = XDataCenter.TeamManager.GetTeamMemberColor(self.CurPos)
    self.ImgRightSkill.color = XDataCenter.TeamManager.GetTeamMemberColor(self.CurPos)
    self.RootUi:SetUiSprite(self.ImgIcon, XDataCenter.CharacterManager.GetCharBigHeadIcon(character.Id))
    self.TxtLevel.text = character.Level
    self.RootUi:SetUiSprite(self.ImgQuality, XCharacterConfigs.GetCharacterQualityIcon(character.Quality))
    self.RImgGrade:SetRawImage(XCharacterConfigs.GetCharGradeIcon(character.Id, character.Grade))
end

function XUiGridTeamRole:Refresh(curPos, teamData)
    self.CurPos = curPos
    self.TeamData = teamData
    local chrId = teamData.TeamData[curPos]
    -- local captainPos = XDataCenter.TeamManager.GetCaptainPos()
    -- self.PanelLeader.gameObject:SetActive(captainPos == self.CurPos)
    self.PanelLeader.gameObject:SetActive(false)
    if chrId > 0 then
        self:SetHave(chrId)
    else
        self:SetNull()
    end
end

function XUiGridTeamRole:OnSelect(teamData)
    self.TeamData.TeamData = teamData
    XDataCenter.TeamManager.SetPlayerTeam(self.TeamData, true)
end

function XUiGridTeamRole:OnBtnClickClick(...)
    XLuaUiManager.Open("UiMainLineRoomCharacter", self.TeamData.TeamData, self.CurPos, handler(self, self.OnSelect))
end

function XUiGridTeamRole:OnBtnPlusClick(...)
    XLuaUiManager.Open("UiMainLineRoomCharacter", self.TeamData.TeamData, self.CurPos, handler(self, self.OnSelect))
end