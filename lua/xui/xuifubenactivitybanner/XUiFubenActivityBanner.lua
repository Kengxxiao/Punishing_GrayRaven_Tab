
local XUiGridActivityBanner = require("XUi/XUiFubenActivityBanner/XUiGridActivityBanner")
local XUiFubenActivityBanner = XLuaUiManager.Register(XLuaUi, "UiFubenActivityBanner")

function XUiFubenActivityBanner:OnAwake()
    self:InitAutoScript()
    self.DynamicTable = XDynamicTableNormal.New(self.PanelChapterList)
    self.DynamicTable:SetProxy(XUiGridActivityBanner)
    self.DynamicTable:SetDelegate(self)
    self.GridActivityBanner.gameObject:SetActive(false)
end

function XUiFubenActivityBanner:OnStart()
end

function XUiFubenActivityBanner:OnEnable()
    self:SetupDynamicTable()
    self:PlayAnimation("ActivityQieHuanEnable")
end

--动态列表事件
function XUiFubenActivityBanner:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        grid:Refresh(self.Chapters[index], self)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then
        self:ClickChapterGrid(self.Chapters[index])
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_RECYCLE then
        grid:OnDestroy()
    end
end

--设置动态列表
function XUiFubenActivityBanner:SetupDynamicTable(bReload)
    self.Chapters = XDataCenter.FubenManager.GetActivityChaptersBySort()
    self.DynamicTable:SetDataSource(self.Chapters)
    self.DynamicTable:ReloadDataSync(bReload and 1 or -1)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiFubenActivityBanner:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiFubenActivityBanner:AutoInitUi()
    -- self.PanelActivity = self.Transform:Find("SafeAreaContentPane/PanelActivity")
    -- self.PanelChapterList = self.Transform:Find("SafeAreaContentPane/PanelActivity/PanelChapterList")
    -- self.PanelChapterContent = self.Transform:Find("SafeAreaContentPane/PanelActivity/PanelChapterList/Viewport/PanelChapterContent")
    -- self.GridActivityBanner = self.Transform:Find("SafeAreaContentPane/PanelActivity/PanelChapterList/Viewport/GridActivityBanner")
end

function XUiFubenActivityBanner:AutoAddListener()
end
-- auto
function XUiFubenActivityBanner:ClickChapterGrid(chapter)
    if chapter.Type == XDataCenter.FubenManager.ChapterType.BossOnline then
        if not XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.FubenActivityOnlineBoss) then
            return
        end

        local _self = self
        -- 先检查更新再开界面
        XDataCenter.FubenBossOnlineManager.RefreshBossData(function()
            if not XDataCenter.FubenBossOnlineManager.CheckBossDataCorrect() then
                return
            end
            _self.ParentUi:PushUi(function()
                XDataCenter.FubenBossOnlineManager.OpenBossOnlineUiWithoutCheck()
            end)
        end)
    elseif chapter.Type == XDataCenter.FubenManager.ChapterType.ActivtityBranch then
        if not XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.FubenActivityBranch) then
            return
        end
        self.ParentUi:PushUi(function()
            XLuaUiManager.Open("UiActivityBranch", chapter.Id)
        end)
    elseif chapter.Type == XDataCenter.FubenManager.ChapterType.ActivityBossSingle then
        if not XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.FubenActivitySingleBoss) then
            return
        end
        self.ParentUi:PushUi(function()
            XLuaUiManager.Open("UiActivityBossSingle", chapter.Id)
        end)
    elseif chapter.Type == XDataCenter.FubenManager.ChapterType.Christmas or 
            chapter.Type == XDataCenter.FubenManager.ChapterType.BriefDarkStream or 
            chapter.Type == XDataCenter.FubenManager.ChapterType.FestivalNewYear then
        self:OnClickFestivalActivity(chapter.Id)
    
    elseif chapter.Type == XDataCenter.FubenManager.ChapterType.ActivityBabelTower then
    
        self:OnClickBabelTowerActivity()
    end
end

function XUiFubenActivityBanner:OnClickFestivalActivity(festivalId)
    local chapterTemplate = XFestivalActivityConfig.GetFestivalById(festivalId)
    if chapterTemplate.FunctionOpenId and (not XFunctionManager.DetectionFunction(chapterTemplate.FunctionOpenId)) then
        return
    end
    
    self.ParentUi:PushUi(function()
        XLuaUiManager.Open("UiFubenChristmasMainLineChapter", festivalId)
    end)
end

function XUiFubenActivityBanner:OnClickBabelTowerActivity()
    
    if not XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.BabelTower) then
        return
    end

    self.ParentUi:PushUi(function()
        XLuaUiManager.Open("UiBabelTowerMainNew")
    end)
end