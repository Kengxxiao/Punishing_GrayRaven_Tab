--local XUiMissionTeamSelect_New = XUiManager.Register("UiMissionTeamSelect")
local XUiMissionTeamSelect = XLuaUiManager.Register(XLuaUi, "UiMissionTeamSelect")

function XUiMissionTeamSelect:OnAwake()
    self:InitAutoScript()
end

function XUiMissionTeamSelect:OnStart(characterIds, memberCount, index, callback)
   
    self.Index = index

    self:Init(characterIds)
    self.MemberLimit = memberCount
    self.CallBack = callback
    self.CurSelectGrid = nil
    self:SetupCharacterList()

    self:PlayAnimation("AniMissionTeamSelectBegin")
    --XUiHelper.PlayAnimation(self, "AniMissionTeamSelectBegin")

end

function XUiMissionTeamSelect:Init(characterIds)
    --self.SelectCount = #characterIds
    self.CharacterIds = {}
    for i,v in pairs(characterIds) do
        self.CharacterIds[i] = v
    end

    self.SelectedIdMap = {}
    for i, v in pairs(characterIds) do
        if self.Index ~= i then
            self.SelectedIdMap[v] = i
        end
    end

    self.DynamicTable = XDynamicTableNormal.New(self.PanelScrollView)
    self.DynamicTable:SetProxy(XUiGridMisssionTeam)
    self.DynamicTable:SetDelegate(self)
end

-- 角色信息面板 begin --
function XUiMissionTeamSelect:SetupCharacterList()
    local charlist = XDataCenter.TaskForceManager.GetOwnCharacterList()

    if not charlist then
        XLog.Error("XUiMissionTeamSelect:SetupCharacterList error: character list is nil")
        return
    end

    self.CharList = {}
    for i, v in ipairs(charlist) do
        if self.CharacterIds and self.CharacterIds[self.Index] and self.CharacterIds[self.Index] == v.Id then
            table.insert(self.CharList, 1, v)
        else
            table.insert(self.CharList, v)
        end
    end

    self.DynamicTable:SetDataSource(self.CharList)
    self.DynamicTable:ReloadDataASync()
end

--动态列表事件
function XUiMissionTeamSelect:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:Init(self)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local data = self.CharList[index]
        grid:Reset()
        grid:UpdateGrid(data)
        if self.CharacterIds[self.Index] and self.CharacterIds[self.Index] == data.Id then
            self.CurSelectGrid = grid
            grid:SetSelect(true)
        else
            grid:SetSelect(false)
        end

    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then
        local charData = self.CharList[index]

        if charData.IsWorking and charData.IsWorking > 0 then
            return
        end

        if self.CharacterIds[self.Index] and self.CharacterIds[self.Index] == charData.Id then
            self.CurSelectGrid:SetSelect(false)
            self.CharacterIds[self.Index] = nil
            return
        end

        if self.CurSelectGrid then
            self.CurSelectGrid:SetSelect(false)
        end

        self.CharacterIds[self.Index] = charData.Id
        self.CurSelectGrid = grid
        self.CurSelectGrid:SetSelect(true)
    end
end
-- auto
-- Automatic generation of code, forbid to edit
function XUiMissionTeamSelect:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiMissionTeamSelect:AutoInitUi()
    -- self.BtnBg = self.Transform:Find("FullScreenBackground/BtnBg"):GetComponent("Button")
    -- self.PanelMissionTeamSelect = self.Transform:Find("SafeAreaContentPane/PanelMissionTeamSelect")
    -- self.PanelScrollView = self.Transform:Find("SafeAreaContentPane/PanelMissionTeamSelect/PanelScrollView")
    -- self.GridMisssionTeam = self.Transform:Find("SafeAreaContentPane/PanelMissionTeamSelect/PanelScrollView/Viewport/GridMisssionTeam")
    -- self.BtnSure = self.Transform:Find("SafeAreaContentPane/PanelMissionTeamSelect/BtnSure"):GetComponent("Button")
end

function XUiMissionTeamSelect:GetAutoKey(uiNode, eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiMissionTeamSelect:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiMissionTeamSelect:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiMissionTeamSelect:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterClickEvent(self.BtnBg, self.OnBtnBgClick)
    self:RegisterClickEvent(self.BtnSure, self.OnBtnSureClick)
end
-- auto
function XUiMissionTeamSelect:OnBtnBgClick(...)
    self:PlayAnimation("AniMissionTeamSelectEnd", function()
        --CS.XUiManager.ViewManager:Pop()
        self:Close()
    end)
    -- XUiHelper.PlayAnimation(self, "AniMissionTeamSelectEnd", nil, function()
    --     --CS.XUiManager.ViewManager:Pop()
    --     self:Close()
    -- end)
end

function XUiMissionTeamSelect:OnBtnSureClick(...)

    local id = self.CharacterIds[self.Index]
    if id then
        local index = self.SelectedIdMap[id]
        if index ~= nil then
            self.CharacterIds[index] = nil
        end
    end

    self:PlayAnimation("AniMissionTeamSelectEnd", function()
        if self.CallBack then
            self.CallBack(self.CharacterIds)
        end

        --CS.XUiManager.ViewManager:Pop()
        self:Close()

    end)
    -- XUiHelper.PlayAnimation(self, "AniMissionTeamSelectEnd", nil, function()
    --     if self.CallBack then
    --         self.CallBack(self.CharacterIds)
    --     end

    --     --CS.XUiManager.ViewManager:Pop()
    --     self:Close()

    -- end)

end