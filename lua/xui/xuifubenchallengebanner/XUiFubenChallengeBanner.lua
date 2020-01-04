local XUiFubenChallengeBanner = XLuaUiManager.Register(XLuaUi, "UiFubenChallengeBanner")

function XUiFubenChallengeBanner:OnAwake()
    self:InitAutoScript()
    self.DynamicTable = XDynamicTableNormal.New(self.PanelChapterList)
    self.DynamicTable:SetProxy(XUiGridChallengeBanner)
    self.DynamicTable:SetDelegate(self)
    self.GridChallengeBanner.gameObject:SetActive(false)
end

function XUiFubenChallengeBanner:OnStart()
    XEventManager.AddEventListener(XEventId.EVENT_FUBEN_DAILY_REFRESH, self.SetupDynamicTable, self)
    XEventManager.AddEventListener(XEventId.EVENT_URGENTEVENT_SYNC, self.SetupDynamicTable, self)
    XEventManager.AddEventListener(XEventId.EVENT_FUBEN_SINGLE_BOSS_SYNC, self.SetupDynamicTable, self)

end

function XUiFubenChallengeBanner:OnDestroy()
    XEventManager.RemoveEventListener(XEventId.EVENT_FUBEN_DAILY_REFRESH, self.SetupDynamicTable, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_URGENTEVENT_SYNC, self.SetupDynamicTable, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_FUBEN_SINGLE_BOSS_SYNC, self.SetupDynamicTable, self)
end

function XUiFubenChallengeBanner:OnEnable()
    self:SetupDynamicTable()
    XDataCenter.FubenManager.EnterChallenge()
    self.IsShow = true
    self:PlayAnimation("ChapterQieHuanEnable")
end

function XUiFubenChallengeBanner:OnDisable()
    self.IsShow = false
end

--动态列表事件
function XUiFubenChallengeBanner:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        grid:UpdateGrid(self.PageDatas[index], self)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then
        self:OnClickChapterGrid(self.PageDatas[index])
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_RECYCLE then
        grid:OnRecycle()
    end
end

--设置动态列表
function XUiFubenChallengeBanner:SetupDynamicTable(bReload)
    self.PageDatas = XDataCenter.FubenManager.GetChallengeChapters()
    self.DynamicTable:SetDataSource(self.PageDatas)
    self.DynamicTable:ReloadDataSync(bReload and 1 or -1)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiFubenChallengeBanner:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiFubenChallengeBanner:AutoInitUi()
    self.PanelChallengeChapter = self.Transform:Find("SafeAreaContentPane/PanelChallengeChapter")
    self.PanelChapterList = self.Transform:Find("SafeAreaContentPane/PanelChallengeChapter/PanelChapterList")
    self.PanelChapterContent = self.Transform:Find("SafeAreaContentPane/PanelChallengeChapter/PanelChapterList/Viewport/PanelChapterContent")
    self.GridChallengeBanner = self.Transform:Find("SafeAreaContentPane/PanelChallengeChapter/PanelChapterList/Viewport/GridChallengeBanner")
end

function XUiFubenChallengeBanner:AutoAddListener()
end
-- auto
function XUiFubenChallengeBanner:OnClickChapterGrid(chapter)
    if chapter.IsClose then
        XUiManager.TipText("CommonNotOpen")
        return
    end

    if chapter.Type == XDataCenter.FubenManager.ChapterType.BOSSSINGLE then
        if XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.FubenChallengeBossSingle) then
            self.ParentUi:PushUi(function()
                XDataCenter.FubenBossSingleManager.OpenBossSingleView(chapter)
            end)
        end
    elseif chapter.Type == XDataCenter.FubenManager.ChapterType.Urgent then
        self.ParentUi:PushUi(function()
            XLuaUiManager.Open("UiFubenChallengeMap", chapter)
        end)
    elseif chapter.Type == XDataCenter.FubenManager.ChapterType.Explore then
        if XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.FubenExplore) then
            self.ParentUi:PushUi(function()
                XLuaUiManager.Open("UiFubenExploreChapter")
            end)
        end
    elseif chapter.Type == XDataCenter.FubenManager.ChapterType.ARENA then
        if XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.FubenArena) then
            XDataCenter.ArenaManager.RequestSignUpArena(function()
                self.ParentUi:PushUi(function()
                    XLuaUiManager.Open("UiArena", chapter)
                end)
            end)
        end
    elseif chapter.Type == XDataCenter.FubenManager.ChapterType.Trial then
        if XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.FubenChallengeTrial) then
            if self.IsTrialOpening then
                return
            end
            self.IsTrialOpening = true
            self.ParentUi:PushUi(function()
                XLuaUiManager.OpenWithCallback("UiTrial", function()
                    self.IsTrialOpening = nil
                end)
            end)
        end
    elseif chapter.Type == XDataCenter.FubenManager.ChapterType.Practice then

        if XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.Practice) then
            self.ParentUi:PushUi(function()
                XLuaUiManager.Open(chapter.NameEn)
            end)
        end
    end
end

function XUiFubenChallengeBanner:GuideGetDynamicTableIndex(id)
    return id
end