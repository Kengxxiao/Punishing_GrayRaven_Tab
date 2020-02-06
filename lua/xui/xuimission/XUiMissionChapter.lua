local XUiMissionChapter = XLuaUiManager.Register(XLuaUi, "UiMissionChapter")

function XUiMissionChapter:OnAwake()
    self:InitAutoScript()
end

function XUiMissionChapter:OnStart()
    self:Init()
    self:SetupChapter()

    self:PlayAnimation("AniMissionChapterBegin")
    --XUiHelper.PlayAnimation(self, "AniMissionChapterBegin")

end

function XUiMissionChapter:Init()
    self.DynamicTable = XDynamicTableNormal.New(self.PanelScroll)
    self.DynamicTable:SetProxy(XUiPanelMissionChapterGird)
    self.DynamicTable:SetDelegate(self)
end

function XUiMissionChapter:SetupChapter()
    local chapters = XDataCenter.TaskForceManager.GetTaskForceSectionConfig()
    if not chapters then
        return
    end

    local curSectionId = XDataCenter.TaskForceManager.GetCurTaskForceSectionId()

    self.Chapters = chapters
    self.DynamicTable:SetDataSource(chapters)
    self.DynamicTable:ReloadDataASync(curSectionId)
end

--动态列表事件
function XUiMissionChapter:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local data = self.Chapters[index]
        grid.RootUi = self
        grid:SetupContent(data)
    end
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiMissionChapter:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiMissionChapter:AutoInitUi()
    -- self.PanelChapter = self.Transform:Find("SafeAreaContentPane/PanelChapter")
    -- self.PanelContent = self.Transform:Find("SafeAreaContentPane/PanelChapter/PanelContent")
    -- self.PanelScroll = self.Transform:Find("SafeAreaContentPane/PanelChapter/PanelContent/PanelScroll")
    -- self.PanelMissionChapterGird = self.Transform:Find("SafeAreaContentPane/PanelChapter/PanelContent/PanelScroll/Viewport/PanelMissionChapterGird")
    -- self.BtnBg = self.Transform:Find("FullScreenBackground/BtnBg"):GetComponent("Button")
end

function XUiMissionChapter:GetAutoKey(uiNode, eventName)
    if not uiNode then
        return
    end
    return eventName .. uiNode:GetHashCode()
end

function XUiMissionChapter:RegisterListener(uiNode, eventName, func)
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
            XLog.Error("XUiMissionChapter:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiMissionChapter:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterClickEvent(self.BtnBg, self.OnBtnBgClick)
end
-- auto

function XUiMissionChapter:OnBtnBgClick(...)
    self:PlayAnimation("AniMissionChapterEnd", function()
        --CS.XUiManager.ViewManager:Pop()
        self:Close()
    end)
    -- XUiHelper.PlayAnimation(self, "AniMissionChapterEnd", nil, function()
    --     --CS.XUiManager.ViewManager:Pop()
    --     self:Close()
    -- end)
end
