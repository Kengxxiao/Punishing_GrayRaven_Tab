local XUiFubenDailyBanner = XLuaUiManager.Register(XLuaUi, "UiFubenDailyBanner")

function XUiFubenDailyBanner:OnAwake()
    self.DynamicTable = XDynamicTableNormal.New(self.PanelChapterList)
    self.DynamicTable:SetProxy(XUiGridDailyBanner)
    self.DynamicTable:SetDelegate(self)
    self.GridDailyBanner.gameObject:SetActive(false)
end

function XUiFubenDailyBanner:OnStart()
    self:SetupDynamicTable()
end

function XUiFubenDailyBanner:OnEnable()
    self:SetupDynamicTable()
    self:PlayAnimation("DailyQieHuanEnable")
end

--动态列表事件
function XUiFubenDailyBanner:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:UpdateGrid(self.PageDatas[index], self)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        grid:UpdateGrid(self.PageDatas[index], self)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then
        self:OnClickChapterGrid(self.PageDatas[index])
    end
end

--设置动态列表
function XUiFubenDailyBanner:SetupDynamicTable(bReload)
    self.PageDatas = XDataCenter.FubenManager.GetDailyDungeonRules()
    self.DynamicTable:SetDataSource(self.PageDatas)
    self.DynamicTable:ReloadDataSync(bReload and 1 or - 1)
end

function XUiFubenDailyBanner:OnClickChapterGrid(chapter)
    
    local tmpDay = XDataCenter.FubenDailyManager.IsDayLock(chapter.Id)
    local tmpCon = XDataCenter.FubenDailyManager.GetConditionData(chapter.Id)
    local tmpOpen = XDataCenter.FubenDailyManager.GetEventOpen(chapter.Id).IsOpen
    
    if tmpCon.IsLock then
        XUiManager.TipError(XFunctionManager.GetFunctionOpenCondition(tmpCon.functionNameId))
        return
    end
    if tmpDay and not tmpOpen then
        XUiManager.TipError(CS.XTextManager.GetText("FubenDailyOpenHint", 
                XDataCenter.FubenDailyManager.GetOpenDayString(chapter)))
        return
    end
    
    self.ParentUi:PushUi(function()
        XLuaUiManager.Open("UiFubenDaily", chapter)
    end)
    
    local IsCanOpen = false
end
