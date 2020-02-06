local XUiRoomTeamPrefab = XLuaUiManager.Register(XLuaUi, "UiRoomTeamPrefab")

function XUiRoomTeamPrefab:OnAwake()
    self:InitAutoScript()
end

function XUiRoomTeamPrefab:OnStart(captainPos)
    self.CaptainPos = captainPos
    self.TeamPrefabs = {}
    self:RefreshTeamList()
    XEventManager.AddEventListener(XEventId.EVENT_TEAM_PREFAB_CHANGE, self.OnTeamPrefabChange, self)
end

function XUiRoomTeamPrefab:OnDestroy()
    XEventManager.RemoveEventListener(XEventId.EVENT_TEAM_PREFAB_CHANGE, self.OnTeamPrefabChange, self)
end

function XUiRoomTeamPrefab:OnEnable()
end

function XUiRoomTeamPrefab:OnTeamPrefabChange(index, teamData)
    self.TeamPrefabs[index]:Refresh(teamData)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiRoomTeamPrefab:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiRoomTeamPrefab:AutoInitUi()
    self.PanelTeam = self.Transform:Find("SafeAreaContentPane/PanelTeam")
    self.GridTeam = self.Transform:Find("SafeAreaContentPane/PanelTeam/TeamList/Viewport/GridTeam")
    self.PanelTeamContent = self.Transform:Find("SafeAreaContentPane/PanelTeam/TeamList/Viewport/PanelTeamContent")
    self.BtnBack = self.Transform:Find("SafeAreaContentPane/PanelTeam/Top/BtnBack"):GetComponent("Button")
end

function XUiRoomTeamPrefab:AutoAddListener()
    self:RegisterClickEvent(self.BtnBack, self.OnBtnBackClick)
end
-- auto
function XUiRoomTeamPrefab:NewTeamGrid(index)
    local item = CS.UnityEngine.Object.Instantiate(self.GridTeam)
    local grid = XUiGridTeam.New(self, item)
    grid.Transform:SetParent(self.PanelTeamContent, false)
    grid.GameObject:SetActive(true)
    return grid
end

function XUiRoomTeamPrefab:UpdateTeam(curPos, teamData, isDelete, index, exchagePos)
    self.TeamPrefabs[index].TeamRoles[curPos]:UpdateInfo(teamData)
    if exchagePos and exchagePos > 0 then
        self.TeamPrefabs[index].TeamRoles[exchagePos]:UpdateInfo(teamData)
    end
    self.TeamPrefabs[index]:RefreshCaptainSkill()
end

function XUiRoomTeamPrefab:GetSimpleTeamData(index)
    local maxPos = XDataCenter.TeamManager.GetMaxPos()
    local teamData = {}
    teamData.TeamId = index
    teamData.CaptainPos = self.CaptainPos or XDataCenter.TeamManager.GetCaptainPos()
    teamData.TeamData = {}
    for index = 1, maxPos do
        teamData.TeamData[index] = 0
    end
    return teamData
end

function XUiRoomTeamPrefab:RefreshTeamList()
    self.GridTeam.gameObject:SetActive(false)
    local teamDataList = XDataCenter.TeamManager.GetTeamPrefabData()
    local maxPre = CS.XGame.Config:GetInt("MaxTeamPrefab")

    for i = 1, maxPre do
        local grid = self.TeamPrefabs[i]
        if not grid then
            grid = self:NewTeamGrid(i)
            self.TeamPrefabs[i] = grid
        end

        local teamData = teamDataList[i] or self:GetSimpleTeamData(i)
        grid:Refresh(teamData)
    end
end

function XUiRoomTeamPrefab:OnBtnBackClick(...)
    self:Close()
end