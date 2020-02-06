local XUiMissionTeamLimit = XLuaUiManager.Register(XLuaUi, "UiMissionTeamLimit")

function XUiMissionTeamLimit:OnAwake()
    self:InitAutoScript()
end

function XUiMissionTeamLimit:OnStart(curIndex)
    self.CurIndex = curIndex
    self:Init()
    self:SetupContent()
    self:PlayAnimation("AniMissionTeamLimitBegin")
    --XUiHelper.PlayAnimation(self, "AniMissionTeamLimitBegin")

end

function XUiMissionTeamLimit:Init()
    self.CurId = -1
    self.TaskForeData = {}
    self.DynamicTable = XDynamicTableNormal.New(self.PanelScrollView)
    self.DynamicTable:SetProxy(XUiGridLimit)
    self.DynamicTable:SetDelegate(self)
end

function XUiMissionTeamLimit:SetupContent()
    local configs = XDataCenter.TaskForceManager.GetTaskForceConfigInfo()
    if not configs then
        return
    end

    local curCfg = XDataCenter.TaskForceManager.GetTaskForceConfigById(self.CurIndex)
    self.CurId = curCfg.Id
    self.TaskForeData = configs
    self.DynamicTable:SetDataSource(configs)
    self.DynamicTable:ReloadDataASync(curCfg.Id)
end

--动态列表事件
function XUiMissionTeamLimit:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local data = self.TaskForeData[index]
        grid:SetupContent(data, self.CurId)
    end
end


-- auto
-- Automatic generation of code, forbid to edit
function XUiMissionTeamLimit:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiMissionTeamLimit:AutoInitUi()
    -- self.BtnBg = self.Transform:Find("FullScreenBackground/BtnBg"):GetComponent("Button")
    -- self.UiMissionTeamLimitA = self.Transform:Find("SafeAreaContentPane/UiMissionTeamLimit")
    -- self.PanelScrollView = self.Transform:Find("SafeAreaContentPane/UiMissionTeamLimit/PanelScrollView")
    -- self.GridLimit = self.Transform:Find("SafeAreaContentPane/UiMissionTeamLimit/PanelScrollView/Viewport/GridLimit")
end

function XUiMissionTeamLimit:GetAutoKey(uiNode, eventName)
    if not uiNode then
        return
    end
    return eventName .. uiNode:GetHashCode()
end

function XUiMissionTeamLimit:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then
        return
    end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiMissionTeamLimit:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiMissionTeamLimit:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterClickEvent(self.BtnBg, self.OnBtnBgClick)
end
-- auto

function XUiMissionTeamLimit:OnBtnBgClick(...)
    self:PlayAnimation("AniMissionTeamLimitEnd", function()
        --CS.XUiManager.ViewManager:Pop()
        self:Close()
    end)
    -- XUiHelper.PlayAnimation(self, "AniMissionTeamLimitEnd", nil, function()
    --     --CS.XUiManager.ViewManager:Pop()
    --     self:Close()
    -- end)
end
