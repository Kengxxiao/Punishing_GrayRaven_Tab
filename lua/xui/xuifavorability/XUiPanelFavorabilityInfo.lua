XUiPanelFavorabilityInfo = XClass()

function XUiPanelFavorabilityInfo:Ctor(ui, uiRoot, parent)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.UiRoot = uiRoot
    self.Parent = parent
    XTool.InitUiObject(self)
end

function XUiPanelFavorabilityInfo:OnRefresh()
    -- 动画加这里
    self:RefreshDatas()
end

function XUiPanelFavorabilityInfo:RefreshDatas()
    local characterId = self.UiRoot:GetCurrFavorabilityCharacter()
    local informations = XFavorabilityConfigs.GetCharacterInformationById(characterId)
    self:UpdateDataList(informations)
end

function XUiPanelFavorabilityInfo:GetProxyType(index)
    return "XUiGridLikeInfoItem"
end

function XUiPanelFavorabilityInfo:UpdateDataList(dataList)

    if not dataList then
        XLog.Warning("XUiPanelFavorabilityInfo:UpdateDataList error: dataList is nil")
        return
    end

    self:SortInformation(dataList)
    self.DataList = dataList

    if not self.DynamicTableData then
        self.DynamicTableData = XDynamicTableIrregular.New(self.PanelDataList)
        self.DynamicTableData:SetProxy("XUiGridLikeInfoItem", XUiGridLikeInfoItem, self.GridLikeInfoItem.gameObject)
        self.DynamicTableData:SetDelegate(self)
    end

    self.DynamicTableData:SetDataSource(self.DataList)
    self.DynamicTableData:ReloadDataASync()
    
end

function XUiPanelFavorabilityInfo:SortInformation(dataList)
    local characterId = self.UiRoot:GetCurrFavorabilityCharacter()
    for k, dataItem in pairs(dataList) do
        local isUnlock = XDataCenter.FavorabilityManager.IsInformationUnlock(characterId, dataItem.Id)
        local canUnlock = XDataCenter.FavorabilityManager.CanInformationUnlock(characterId, dataItem.Id)
        dataItem.priority = 2
        if not isUnlock then
            dataItem.priority = canUnlock and 1 or 3
        end
    end
    table.sort(dataList, function(dataItemA,dataItemB)
        if dataItemA.priority == dataItemB.priority then
            return dataItemA.Id < dataItemB.Id
        else
            return dataItemA.priority < dataItemB.priority
        end
    end)
end

-- [监听动态列表事件]
function XUiPanelFavorabilityInfo:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:Init(self.UiRoot)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local data = self.DataList[index]
        if data ~= nil then
            grid:OnRefresh(self.DataList[index], index)
        end
        
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then
        self.CurData = self.DataList[index]
        self:OnDataClick(index, grid)
    end
end

-- [打开一个item,关闭其他打开中的item效果]
function XUiPanelFavorabilityInfo:ResetOtherItems(index)
    for k, v in pairs(self.DataList) do
        if index ~= k then
            v.IsToggle = false
        end
    end
end

-- [点击资料]
function XUiPanelFavorabilityInfo:OnDataClick(index, grid)
    if not self.CurData then return end
    local characterId = self.UiRoot:GetCurrFavorabilityCharacter()
    local isUnlock = XDataCenter.FavorabilityManager.IsInformationUnlock(characterId, self.CurData.Id)
    local canUnlock = XDataCenter.FavorabilityManager.CanInformationUnlock(characterId, self.CurData.Id)
    if isUnlock then
        self:ResetOtherItems(index)
        grid:OnToggle()
        self.DynamicTableData:ReloadDataASync()
    else
        if canUnlock then
            XDataCenter.FavorabilityManager.OnUnlockCharacterInfomatin(characterId, self.CurData.Id, function()
                self:RefreshDatas()
            end, self.CurData.Title)
        else
            -- 提示解锁条件
            XUiManager.TipMsg(self.CurData.ConditionDescript)
        end
    end
end

function XUiPanelFavorabilityInfo:SetViewActive(isActive)
    self.GameObject:SetActive(isActive)
    if isActive then
        self:RefreshDatas()
    end
end


return XUiPanelFavorabilityInfo
