local XUiArenaActivityResult = XLuaUiManager.Register(XLuaUi, "UiArenaActivityResult")

function XUiArenaActivityResult:OnAwake()
    self:AutoAddListener()
end


function XUiArenaActivityResult:OnStart(data, callBack, closeCb)
    self.GridCommon.gameObject:SetActive(false)

    self.DynamicTable = XDynamicTableNormal.New(self.SViewReward.transform)
    self.DynamicTable:SetProxy(XUiGridCommon)
    self.DynamicTable:SetDelegate(self)

    self.Data = data
    self.CallBack = callBack
    self.CloseCb = closeCb
end


function XUiArenaActivityResult:OnEnable()
    self:Refresh()
end

function XUiArenaActivityResult:AutoAddListener()
    self:RegisterClickEvent(self.BtnBg, self.OnBtnBgClick)
end

function XUiArenaActivityResult:OnBtnBgClick(eventData)
    self:Close()
    if self.CloseCb then 
        self.CloseCb()
    end
end

function XUiArenaActivityResult:Refresh()
    if not self.Data then
        return
    end

    local arenaLevelCfg = XArenaConfigs.GetArenaLevelCfgByLevel(self.Data.NewArenaLevel)

    local str = ""
    if self.Data.OldArenaLevel < self.Data.NewArenaLevel then
        str = CS.XTextManager.GetText("ArenaActivityResultUp", arenaLevelCfg.Name)
    elseif self.Data.OldArenaLevel == self.Data.NewArenaLevel then
        str = CS.XTextManager.GetText("ArenaActivityResultKeep", arenaLevelCfg.Name)
    else
        str = CS.XTextManager.GetText("ArenaActivityResultDown", arenaLevelCfg.Name)
    end
    self.TxtInfo.text = str
    self.RImgArenaLevel:SetRawImage(arenaLevelCfg.Icon)
    self.DynamicTable:SetDataSource(self.Data.RewardGoodsList)
    self.DynamicTable:ReloadDataASync()

    if self.CallBack then
        self.CallBack()
    end
end

function XUiArenaActivityResult:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local data = self.Data.RewardGoodsList[index]
        grid.RootUi = self
        grid:Refresh(data)
    end
end