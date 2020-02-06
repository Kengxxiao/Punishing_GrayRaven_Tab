XUiGridTeam = XClass()

function XUiGridTeam:Ctor(rootUi, ui)
    self.RootUi = rootUi
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
    self.GridTeamRole.gameObject:SetActive(false)
    self.TeamRoles = {}
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiGridTeam:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiGridTeam:AutoInitUi()
    self.TxtIndex = self.Transform:Find("TxtIndex"):GetComponent("Text")
    self.PanelCharContent = self.Transform:Find("PanelCharContent")
    self.GridTeamRole = self.Transform:Find("PanelCharContent/GridTeamRole")
    self.PanelSkill = self.Transform:Find("PanelSkill")
    self.PanelSkillInfo = self.Transform:Find("PanelSkill/PanelSkillInfo")
    self.ImgSkillIcon = self.Transform:Find("PanelSkill/PanelSkillInfo/ImgSkillIcon"):GetComponent("Image")
    self.TxtSkillName = self.Transform:Find("PanelSkill/PanelSkillInfo/TxtSkillName"):GetComponent("Text")
    self.TxtSkillDesc = self.Transform:Find("PanelSkill/PanelSkillInfo/TxtSkillDesc"):GetComponent("Text")
    self.BtnChoices = self.Transform:Find("PanelSkill/BtnChoices"):GetComponent("Button")
end

function XUiGridTeam:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiGridTeam:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiGridTeam:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiGridTeam:AutoAddListener()
    self:RegisterClickEvent(self.BtnChoices, self.OnBtnChoicesClick)
end
-- auto
function XUiGridTeam:Refresh(teamData)
    self.TeamData = teamData
    self.TxtIndex.text = self.TeamData.TeamId
    self:RefreshTeamRoles()
    self:RefreshCaptainSkill()
end

function XUiGridTeam:RefreshCaptainSkill()
    self.PanelSkillInfo.gameObject:SetActive(false)

    -- self.PanelSkillInfo.gameObject:SetActive(true)
    -- local captainId = self.TeamData.TeamData[self.TeamData.CaptainPos]
    -- if captainId <= 0 then
    --     self.PanelSkillInfo.gameObject:SetActive(false)
    --     return
    -- end

    -- local captianSkillInfo = XDataCenter.CharacterManager.GetCaptainSkillInfo(captainId)
    -- self.RootUi:SetUiSprite(self.ImgSkillIcon, captianSkillInfo.Icon)
    -- self.TxtSkillName.text = captianSkillInfo.Name
    -- self.TxtSkillDesc.text = captianSkillInfo.Intro
end

function XUiGridTeam:RefreshTeamRoles()
    self:RefreshRoleGrid(2)
    self:RefreshRoleGrid(1)
    self:RefreshRoleGrid(3)
end

function XUiGridTeam:RefreshRoleGrid(pos)
    local grid = self.TeamRoles[pos]
    if not grid then
        local item = CS.UnityEngine.Object.Instantiate(self.GridTeamRole)
        grid = XUiGridTeamRole.New(self.RootUi, item)
        grid.Transform:SetParent(self.PanelCharContent, false)
        grid.GameObject:SetActive(true)
        self.TeamRoles[pos] = grid
    end
    grid:Refresh(pos, self.TeamData)
end

function XUiGridTeam:SetSelectFasle(pos)
    self.TeamRoles[pos]:SetSelect(false)
    self.TeamRoles[pos].IsClick = false
end

function XUiGridTeam:OnBtnChoicesClick(...)
    XEventManager.DispatchEvent(XEventId.EVENT_TEAM_PREFAB_SELECT, self.TeamData.TeamData)
    self.RootUi:Close()
end