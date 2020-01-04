local XUiRoomSingle = XUiManager.Register("UiRoomSingle")

local CHAR_POS1 = 1
local CHAR_POS2 = 2
local CHAR_POS3 = 3
local MAX_CHAR_COUNT = 3

function XUiRoomSingle:OnOpen(stage)
    self:InitAutoScript()
    self.GridFriend.gameObject:SetActive(false)
    self.TypeIdMainLine = CS.XGame.Config:GetInt("TypeIdMainLine")
    self.ImgAddList = {self.ImgAdd1, self.ImgAdd2, self.ImgAdd3}
    self.RoleModelPanelList = {
        XUiPanelRoleModel.New(self.PanelRoleModel1, self.Name),
        XUiPanelRoleModel.New(self.PanelRoleModel2, self.Name),
        XUiPanelRoleModel.New(self.PanelRoleModel3, self.Name)
    }
    self.FriendGridList = {}
    self.Stage = stage
    self:InitPanelData()

    local musicKey =self:GetAutoKey(self.BtnBack,"onClick")
    self.SpecialSoundMap[musicKey] = XSoundManager.UiBasicsMusic.Return
    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.FreeGem, XDataCenter.ItemManager.ItemId.ActionPoint, XDataCenter.ItemManager.ItemId.Coin)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiRoomSingle:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiRoomSingle:AutoInitUi()
    self.PanelButtonTop = self.Transform:Find("PanelButtonTop")
    self.PanelAsset = self.Transform:Find("PanelButtonTop/PanelAsset")
    self.PanelTool1 = self.Transform:Find("PanelButtonTop/PanelAsset/PanelTool1")
    self.ImgTool1 = self.Transform:Find("PanelButtonTop/PanelAsset/PanelTool1/ImgTool1"):GetComponent("Image")
    self.TxtTool1 = self.Transform:Find("PanelButtonTop/PanelAsset/PanelTool1/TxtTool1"):GetComponent("Text")
    self.BtnBuyJump1 = self.Transform:Find("PanelButtonTop/PanelAsset/PanelTool1/BtnBuyJump1"):GetComponent("Button")
    self.PanelTool2 = self.Transform:Find("PanelButtonTop/PanelAsset/PanelTool2")
    self.ImgTool2 = self.Transform:Find("PanelButtonTop/PanelAsset/PanelTool2/ImgTool2"):GetComponent("Image")
    self.TxtTool2 = self.Transform:Find("PanelButtonTop/PanelAsset/PanelTool2/TxtTool2"):GetComponent("Text")
    self.BtnBuyJump2 = self.Transform:Find("PanelButtonTop/PanelAsset/PanelTool2/BtnBuyJump2"):GetComponent("Button")
    self.PanelTool3 = self.Transform:Find("PanelButtonTop/PanelAsset/PanelTool3")
    self.ImgTool3 = self.Transform:Find("PanelButtonTop/PanelAsset/PanelTool3/ImgTool3"):GetComponent("Image")
    self.TxtTool3 = self.Transform:Find("PanelButtonTop/PanelAsset/PanelTool3/TxtTool3"):GetComponent("Text")
    self.BtnBuyJump3 = self.Transform:Find("PanelButtonTop/PanelAsset/PanelTool3/BtnBuyJump3"):GetComponent("Button")
    self.PanelCharTopButton = self.Transform:Find("PanelButtonTop/PanelCharTopButton")
    self.BtnBack = self.Transform:Find("PanelButtonTop/PanelCharTopButton/BtnBack"):GetComponent("Button")
    self.BtnMainUi = self.Transform:Find("PanelButtonTop/PanelCharTopButton/BtnMainUi"):GetComponent("Button")
    self.PanelTeam = self.Transform:Find("PanelTeam")
    self.BtnChar1 = self.Transform:Find("PanelTeam/BtnChar1"):GetComponent("Button")
    self.ImgAdd1 = self.Transform:Find("PanelTeam/BtnChar1/ImgAdd1"):GetComponent("Image")
    self.BtnChar2 = self.Transform:Find("PanelTeam/BtnChar2"):GetComponent("Button")
    self.ImgAdd2 = self.Transform:Find("PanelTeam/BtnChar2/ImgAdd2"):GetComponent("Image")
    self.BtnChar3 = self.Transform:Find("PanelTeam/BtnChar3"):GetComponent("Button")
    self.ImgAdd3 = self.Transform:Find("PanelTeam/BtnChar3/ImgAdd3"):GetComponent("Image")
    self.PanelLeader = self.Transform:Find("PanelLeader")
    self.Slider = self.Transform:Find("PanelLeader/Slider"):GetComponent("Slider")
    self.TxtLeader = self.Transform:Find("PanelLeader/Slider/HandleSlideArea/Handle/TxtLeader"):GetComponent("Text")
    self.PanelFriend = self.Transform:Find("PanelFriend")
    self.TxtFLTitle = self.Transform:Find("PanelFriend/TxtFLTitle"):GetComponent("Text")
    self.ImgLineTop = self.Transform:Find("PanelFriend/ImgLineTop"):GetComponent("Image")
    self.ImgLineBottom = self.Transform:Find("PanelFriend/ImgLineBottom"):GetComponent("Image")
    self.PanelFriendnList = self.Transform:Find("PanelFriend/PanelFriendnList")
    self.PanelFriendContent = self.Transform:Find("PanelFriend/PanelFriendnList/Viewport/PanelFriendContent")
    self.GridFriend = self.Transform:Find("PanelFriend/PanelFriendnList/Viewport/PanelFriendContent/GridFriend")
    self.ScrSection = self.Transform:Find("PanelFriend/PanelFriendnList/ScrSection"):GetComponent("Scrollbar")
    self.SlidingArea = self.Transform:Find("PanelFriend/PanelFriendnList/ScrSection/SlidingArea"):GetComponent("Slider")
    self.PanelSkill = self.Transform:Find("PanelSkill")
    self.ImgSkillIcon = self.Transform:Find("PanelSkill/ImgSkillIcon"):GetComponent("Image")
    self.ImgSkillLine = self.Transform:Find("PanelSkill/ImgSkillLine"):GetComponent("Image")
    self.TxtSkillName = self.Transform:Find("PanelSkill/TxtSkillName"):GetComponent("Text")
    self.TxtSkillLeader = self.Transform:Find("PanelSkill/TxtSkillLeader"):GetComponent("Text")
    self.TxtSkillDesc = self.Transform:Find("PanelSkill/TxtSkillDesc"):GetComponent("Text")
    self.BtnEnterFight = self.Transform:Find("BtnEnterFight"):GetComponent("Button")
    self.PanelRoleModel2 = self.Transform3d:Find("GameObject/PanelRoleModel2")
    self.PanelRoleModel3 = self.Transform3d:Find("GameObject/PanelRoleModel3")
    self.UiBg004 = self.Transform3d:Find("UiBg004")
    self.PanelRoleModel1 = self.Transform3d:Find("GameObject/PanelRoleModel1")
end

function XUiRoomSingle:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiRoomSingle:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiRoomSingle:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiRoomSingle:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterListener(self.BtnBuyJump1, "onClick", self.OnBtnBuyJump1Click)
    self:RegisterListener(self.BtnBuyJump2, "onClick", self.OnBtnBuyJump2Click)
    self:RegisterListener(self.BtnBuyJump3, "onClick", self.OnBtnBuyJump3Click)
    self:RegisterListener(self.BtnBack, "onClick", self.OnBtnBackClick)
    self:RegisterListener(self.BtnMainUi, "onClick", self.OnBtnMainUiClick)
    self:RegisterListener(self.BtnChar1, "onClick", self.OnBtnChar1Click)
    self:RegisterListener(self.BtnChar2, "onClick", self.OnBtnChar2Click)
    self:RegisterListener(self.BtnChar3, "onClick", self.OnBtnChar3Click)
    self:RegisterListener(self.Slider, "onValueChanged", self.OnSliderValueChanged)
    self:RegisterListener(self.ScrSection, "onValueChanged", self.OnScrSectionValueChanged)
    self:RegisterListener(self.SlidingArea, "onValueChanged", self.OnSlidingAreaValueChanged)
    self:RegisterListener(self.BtnEnterFight, "onClick", self.OnBtnEnterFightClick)
end
-- auto

function XUiRoomSingle:OnBtnMainUiClick(...)
    XLuaUiManager.RunMain()
end

function XUiRoomSingle:OnBtnBuyJump3Click(...)

end

function XUiRoomSingle:OnBtnBuyJump2Click(...)

end

function XUiRoomSingle:OnBtnBuyJump1Click(...)

end

function XUiRoomSingle:OnSlidingAreaValueChanged()
    
end

function XUiRoomSingle:OnSliderValueChanged()
    local posId = math.floor(self.Slider.value)
    if posId == self.CurTeam.CaptainPos then
        return
    end
    self:UpdateTeamCaptain(posId)
    self:ShowLeaderDesc()
end

function XUiRoomSingle:OnBtnEnterFightClick()
    local captainId = XDataCenter.TeamManager.GetTeamCaptainId(self.CurTeam.TeamId)
    if captainId == nil or captainId <= 0 then
        XUiManager.TipText("TeamManagerCheckCaptainNil")
        return
    end
    
    self:Close()
    local assistPlayerData = nil
    if self.CurFriendGrid ~= nil then
        assistPlayerData = self.CurFriendGrid.AssistPlayerData
    end

    XDataCenter.FubenManager.EnterFight(self.Stage, self.CurTeam.TeamId, assistPlayerData)
end

function XUiRoomSingle:OnBtnChar3Click()
    self:SkipToUiCharacter(CHAR_POS3)
    
end

function XUiRoomSingle:OnBtnChar2Click()
    self:SkipToUiCharacter(CHAR_POS2)
end

function XUiRoomSingle:OnBtnChar1Click()
    self:SkipToUiCharacter(CHAR_POS1)
end

function XUiRoomSingle:SkipToUiCharacter(charPos)
    local teamData = XTool.Clone(self.CurTeam.TeamData)
    local characterId = teamData[charPos]
    local characterList = XDataCenter.CharacterManager.GetCharacterListInTeam(teamData, characterId > 0)
    local openFromTeamInfo = {
        TeamCharIdMap = teamData,
        TeamSelectPos = charPos,
        TeamResultCb = function(resTeam)
            self:UpdateTeam(resTeam)
        end,
    }
    XLuaUiManager.Open("UiCharacter", characterId, characterList, openFromTeamInfo)
end

function XUiRoomSingle:OnBtnBackClick()
    self:Close()
end

function XUiRoomSingle:OnScrSectionValueChanged()
    
end

-- team Ui 初始化
function XUiRoomSingle:InitPanelTeam()
    for i = 1, MAX_CHAR_COUNT do
        local posData = self.CurTeam.TeamData[i]
        if posData and posData > 0 then
            self:UpdateRoleModel(posData, self.RoleModelPanelList[i])
            self.ImgAddList[i].gameObject:SetActive(false)
        else
            self.ImgAddList[i].gameObject:SetActive(true)
        end
    end
end

--更新模型
function XUiRoomSingle:UpdateRoleModel(charId, roleModelPanel)
    roleModelPanel:UpdateCharacterModel(charId)
    roleModelPanel:ShowRoleModel()
end

-- 滑动条Ui 初始化
function XUiRoomSingle:InitLeaderSlider()
    self.Slider.value = self.CurTeam.CaptainPos
end

-- 初始Ui
function XUiRoomSingle:InitPanelData()
    self:InitTeamData()
    self:InitPanelTeam()
    self:InitLeaderSlider()
    -- self:InitPanelFriend()
end

-- 初始化 team 数据
function XUiRoomSingle:InitTeamData()
    local curTeam = XDataCenter.TeamManager.GetPlayerTeam(self.TypeIdMainLine)
    if curTeam == nil then
        return
    end
    self.CurTeam = curTeam
end

-- 更新队长
function XUiRoomSingle:UpdateTeamCaptain(posId)
    if self.CurTeam.TeamId == nil or self.CurTeam.TeamData == nil then
        XLog.Error("Set Team Error! teamId or team is nil")
        return
    end
    
    if self.CurTeam.TeamData[posId] <= 0 then    -- 该位置没有卡牌
        self.Slider.value = self.CurTeam.CaptainPos
        XUiManager.TipText("TeamManagerCheckCaptainNil")
        return
    end
    
    self.CurTeam.CaptainPos = posId
    XDataCenter.TeamManager.SetPlayerTeam(self.CurTeam, false)
end

-- 更新队伍
function XUiRoomSingle:UpdateTeam(teamData)
    if self.CurTeam.TeamId == nil or self.CurTeam.TeamData == nil then
        XLog.Error("Set Team Error! teamId or team is nil")
        return
    end
    
    if teamData[self.CurTeam.CaptainPos] <= 0 then    -- 该位置卡牌被移除了，重新设置一个队长
        local posId = XDataCenter.TeamManager.GetValidPos(teamData)
        self.Slider.value = posId
        self.CurTeam.CaptainPos = posId
    end
    
    for posId, val in pairs(teamData) do
        local oldCharId = self.CurTeam.TeamData[posId]
        if oldCharId > 0 and oldCharId ~= val then      -- 检查被替换的位置是否有角色，并且不相同
            self.RoleModelPanelList[posId]:HideRoleModel()
        end
    end
    
    self.CurTeam.TeamData = teamData
    self:InitPanelTeam()    -- 更新当前队伍显示状态
    XDataCenter.TeamManager.SetPlayerTeam(self.CurTeam, false)    -- 保存数据
end

-- 更新队长显示内容
function XUiRoomSingle:ShowLeaderDesc()
    -- self.TxtSkillName.text = "dddd"
    -- self.TxtSkillDesc.text = "fff"
end

-- 初始好友Ui列表
function XUiRoomSingle:InitPanelFriend()
    local baseItem = self.GridFriend
    baseItem.gameObject:SetActive(false)
    
    local passerList = XDataCenter.AssistManager.PasserList
    local count = #passerList
    local fieldCount = self.PanelFriendContent.childCount
    local addValue = - 150
    
    for i = 1, count do
        local offerY =(i - 1) * addValue
        
        local item = nil
        local isNew = false
        if fieldCount > i then
            item = self.PanelFriendContent.transform:GetChild(i)  -- 先获取子节点有没有item
        else
            item = CS.UnityEngine.Object.Instantiate(baseItem)  -- 复制一个item
            isNew = true
        end
        
        local grid = XUiGridFriend.New(self, item, passerList[i])
        grid.Transform:SetParent(self.PanelFriendContent, false)
        grid:AddClickListener(self, self.ClickFriendGrid)
        grid:UpdateFriendGrid()
        grid.GameObject:SetActive(true)
        grid:UpdateFriendGridSelected(false)
        -- self:InitFriendSelected(grid)    -- 修改为默认不选中
        if isNew then
            grid.Transform.localPosition = CS.UnityEngine.Vector3(item.transform.localPosition.x, item.transform.localPosition.y + offerY, item.transform.localPosition.z)
        end
        -- i = i + 1
    end
end

-- 点击好友列表item的回调
function XUiRoomSingle:ClickFriendGrid(grid)
    self:UpdateFriendSelected(grid)
end

-- function XUiRoomSingle:InitFriendSelected(grid)
--     if self.CurFriendGrid == nil then
--         grid:UpdateFriendGridSelected(true)
--         self.CurFriendGrid = grid
--     elseif self.CurFriendGrid == grid then
--         grid:UpdateFriendGridSelected(true)
--     else
--         grid:UpdateFriendGridSelected(false)
--     end
-- end
function XUiRoomSingle:UpdateFriendSelected(grid)
    if self.CurFriendGrid ~= nil then
        self.CurFriendGrid:UpdateFriendGridSelected(false)
    end
    
    grid:UpdateFriendGridSelected(true)
    self.CurFriendGrid = grid
end
