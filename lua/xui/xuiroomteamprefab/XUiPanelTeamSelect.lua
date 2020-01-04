XUiPanelTeamSelect = XClass()

function XUiPanelTeamSelect:Ctor(rootUi, ui)
    self.RootUi = rootUi
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
    self.CharacterGrids = {}
    self:SetCharacterList()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelTeamSelect:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiPanelTeamSelect:AutoInitUi()
    self.GridTeamCharacter = self.Transform:Find("CharacterList/Viewport/GridTeamCharacter")
    self.PanelCharacterContent = self.Transform:Find("CharacterList/Viewport/PanelCharacterContent")
    self.BtnCharDelete = self.Transform:Find("BtnCharDelete"):GetComponent("Button")
    self.BtnCharSelect = self.Transform:Find("BtnCharSelect"):GetComponent("Button")
end

function XUiPanelTeamSelect:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelTeamSelect:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelTeamSelect:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelTeamSelect:AutoAddListener()
    self:RegisterClickEvent(self.BtnCharDelete, self.OnBtnCharDeleteClick)
    self:RegisterClickEvent(self.BtnCharSelect, self.OnBtnCharSelectClick)
end
-- auto
function XUiPanelTeamSelect:ShowPanel(curPos, teamData, index, cb, parntUi)
    self.TeamSelectPos = curPos
    self.TeamData = teamData
    self.IndexTeamPrefab = index
    self.Callback = cb
    self.CurChangeId = self.TeamData.TeamData[self.TeamSelectPos]
    self:UpdateCharaterInTeam()
    self:UpdateTeamBtn()
    self.GameObject:SetActive(true)

    -- 播放界面动画
    -- XUiHelper.PlayAnimation(parntUi, "RoomTeamPreTeamSelectIn", nil, nil)
end



function XUiPanelTeamSelect:SetCharacterList()
    local baseItem = self.GridTeamCharacter
    baseItem.gameObject:SetActive(false)
    local charList = XDataCenter.CharacterManager.GetSpecilOwnCharacterList()

    local count = #charList

    for i = 1, count do
        local char = charList[i]
        local grid = self.CharacterGrids[char.Id]
        if not grid then
            local item = CS.UnityEngine.Object.Instantiate(baseItem)
            grid = XUiGridCharacter.New(self.RootUi, item, char, function(character)
                self:UpdateInfo(character)
            end)
            grid.GameObject.name = char.Id
            grid.Transform:SetParent(self.PanelCharacterContent, false)
            self.CharacterGrids[char.Id] = grid
        else
            grid:UpdateGrid(char)
            grid.GameObject.name = char.Id
        end
        grid:SetSelect(false)
        grid.GameObject:SetActive(true)
        grid.Transform:SetAsLastSibling()
    end
end

function XUiPanelTeamSelect:UpdateInfo(character)
    if character then
        self.CurCharacter = character
    end

    if self.CurCharacterGrid then
        self.CurCharacterGrid:SetSelect(false)
    end

    self.CurCharacterGrid = self.CharacterGrids[self.CurCharacter.Id]
    self.CurCharacterGrid:UpdateGrid()
    self.CurCharacterGrid:SetSelect(true)

    self:UpdateTeamBtn()
end

function XUiPanelTeamSelect:UpdateTeamBtn()
    if not self.CurCharacter then
        self.BtnCharDelete.gameObject:SetActive(false)
        self.BtnCharSelect.gameObject:SetActive(false)
        return
    end

    local isInTeam = self.CurChangeId == self.CurCharacter.Id

    self.BtnCharDelete.gameObject:SetActive(isInTeam)
    self.BtnCharSelect.gameObject:SetActive(not isInTeam)
end

function XUiPanelTeamSelect:UpdateCharaterInTeam()
    for _, item in pairs(self.CharacterGrids) do
        local isInTeam = false
        for k, v in pairs(self.TeamData.TeamData) do
            if item.Character.Id == v then
                isInTeam = true
                break
            end
        end
        item:SetInTeam(isInTeam)
    end
end

function XUiPanelTeamSelect:HidePanel(cb, parntUi)
    -- 播放界面动画
    -- local onFinish = function()
    --     self.GameObject:SetActive(false)
    --     if cb then cb() end
    -- end
    -- XUiHelper.PlayAnimation(parntUi, "RoomTeamPreTeamSelectOut", nil, onFinish)
    self.GameObject:SetActive(false)
    if cb then cb() end
end

function XUiPanelTeamSelect:OnBtnCharSelectClick(...)
    -- 判断编队中是否有此角色
    local teamMap = self.TeamData.TeamData
    local isHave = false
    local exchagePos = 0
    for k, v in pairs(teamMap) do
        if self.CurCharacter.Id == v then
            isHave = true
            exchagePos = k
            break
        end
    end

    -- 设置角色对换
    if isHave then
        self.TeamData.TeamData[exchagePos] = self.TeamData.TeamData[self.TeamSelectPos]
    end

    self:OnService(false, exchagePos)
end

function XUiPanelTeamSelect:OnBtnCharDeleteClick(...)
    self:OnService(true, 0)
end

function XUiPanelTeamSelect:OnService(isDelete, exchagePos)
    self.TeamData.TeamData[self.TeamSelectPos] = isDelete and 0 or self.CurCharacter.Id
    self.CurChangeId = self.TeamData.TeamData[self.TeamSelectPos]
    XDataCenter.TeamManager.SetPlayerTeam(self.TeamData, true, function()
        self:UpdateCharaterInTeam()
        self:UpdateTeamBtn()
        if self.Callback then
            self.Callback(self.TeamSelectPos, self.TeamData, isDelete, self.IndexTeamPrefab, exchagePos)
        end
    end)
end