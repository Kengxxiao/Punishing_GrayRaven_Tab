XUiPanelFavorabilityPlot = XClass()

function XUiPanelFavorabilityPlot:Ctor(ui, uiRoot)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.UiRoot = uiRoot
    XTool.InitUiObject(self)
end



function XUiPanelFavorabilityPlot:RefreshDatas()
        self:LoadDatas()
end

function XUiPanelFavorabilityPlot:LoadDatas()
    local currentCharacterId = self.UiRoot:GetCurrFavorabilityCharacter()
    local plotDatas = XFavorabilityConfigs.GetCharacterStoryById(currentCharacterId)
    self:UpdatePlotList(plotDatas)
end

function XUiPanelFavorabilityPlot:UpdatePlotList(poltList)
    
    if not poltList then
        XLog.Warning("XUiPanelFavorabilityPlot:UpdatePlotList error: poltList is nil")
    end

    self:SortPlots(poltList)
    self.PoltList = poltList

    if not self.DynamicTablePolt then
        self.DynamicTablePolt = XDynamicTableNormal.New(self.SViewPlotList.gameObject)
        self.DynamicTablePolt:SetProxy(XUiGridLikePlotItem)
        self.DynamicTablePolt:SetDelegate(self)
    end
    
    self.DynamicTablePolt:SetDataSource(self.PoltList)
    self.DynamicTablePolt:ReloadDataASync()
end

function XUiPanelFavorabilityPlot:SortPlots(plotList)
    local characterId = self.UiRoot:GetCurrFavorabilityCharacter()
    for k, plot in pairs(plotList) do
        local isUnlock = XDataCenter.FavorabilityManager.IsStoryUnlock(characterId, plot.Id)
        local canUnlock = XDataCenter.FavorabilityManager.CanStoryUnlock(characterId, plot.Id)
        plot.priority = 1
        if not isUnlock then
            plot.priority = canUnlock and 2 or 3
        end
    end
    table.sort(plotList, function(plotA, plotB)
        if plotA.priority == plotB.priority then
            return plotA.Id < plotB.Id
        else
            return plotA.priority < plotB.priority
        end
    end)
end

-- [列表事件]
function XUiPanelFavorabilityPlot:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:Init(self.UiRoot)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local data = self.PoltList[index]
        if data ~= nil then
            grid:OnRefresh(data, index)
        end
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then
        self.CurPolt = self.PoltList[index]
        if not self.CurPolt then return end
        self:OnPlotClick(self.CurPolt, grid)
    end
end

-- [剧情条目点击事件]
function XUiPanelFavorabilityPlot:OnPlotClick(plotData, grid)
    local characterId = self.UiRoot:GetCurrFavorabilityCharacter()
    local isUnlock = XDataCenter.FavorabilityManager.IsStoryUnlock(characterId, plotData.Id)
    local canUnlock = XDataCenter.FavorabilityManager.CanStoryUnlock(characterId, plotData.Id)

    if isUnlock then
        if CS.Movie.XMovieManager.Instance:CheckMovieExist(plotData.StoryId) then
            CS.Movie.XMovieManager.Instance:PlayById(plotData.StoryId)
        end

    else
        if canUnlock then
                XDataCenter.FavorabilityManager.OnUnlockCharacterStory(characterId, plotData.Id, function()
                    self:LoadDatas()
                end, plotData.Name)
        else
            XUiManager.TipMsg(plotData.ConditionDescript)
        end
    end
end

function XUiPanelFavorabilityPlot:SetViewActive(isActive)
    self.GameObject:SetActive(isActive)
    if isActive then
        self:RefreshDatas()
    end
end


return XUiPanelFavorabilityPlot
