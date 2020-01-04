XUiPanelFavorabilityMessage = XClass()

function XUiPanelFavorabilityMessage:Ctor(ui, uiRoot, parent)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.UiRoot = uiRoot
    self.Parent = parent
    self:InitAutoScript()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelFavorabilityMessage:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiPanelFavorabilityMessage:AutoInitUi()
    self.PanelDataList = self.Transform:Find("PanelDataList")
    self.GridLikeMessageItem = self.Transform:Find("PanelDataList/Viewport/GridLikeMessageItem")
    self.ScrollbarVertical = self.Transform:Find("PanelDataList/ScrollbarVertical"):GetComponent("Scrollbar")
end

function XUiPanelFavorabilityMessage:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelFavorabilityMessage:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelFavorabilityMessage:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelFavorabilityMessage:AutoAddListener()
end
-- auto

function XUiPanelFavorabilityMessage:OnRefresh()
    self:RefreshDatas()
end

function XUiPanelFavorabilityMessage:RefreshDatas()
    local characterId = self.UiRoot:GetCurrFavorabilityCharacter()
    local informations = XFavorabilityConfigs.GetCharacterInformationById(characterId)
    self:UpdateDataList(informations, 1)
    self.Parent:CheckDataReddot()
end

function XUiPanelFavorabilityMessage:GetProxyType(index)
    return "XUiGridLikeMessageItem"
end

function XUiPanelFavorabilityMessage:UpdateDataList(dataList, selectIdx)

    if not dataList then
        XLog.Warning("XUiPanelFavorabilityMessage:UpdateDataList error: dataList is nil")
        return
    end

    self.DataList = dataList
    self.CurData = self.DataList[selectIdx]

    if not self.DynamicTableData then
        self.DynamicTableData = XDynamicTableIrregular.New(self.PanelDataList)
        self.DynamicTableData:SetProxy("XUiGridLikeMessageItem", XUiGridLikeMessageItem, self.GridLikeMessageItem.gameObject)
        self.DynamicTableData:SetDelegate(self)
    end

    self.DynamicTableData:SetDataSource(self.DataList)
    self.DynamicTableData:ReloadDataASync(selectIdx)
    
end

-- [监听动态列表事件]
function XUiPanelFavorabilityMessage:OnDynamicTableEvent(event, index, grid)
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

-- [策划想要打开一个item,关闭其他打开中的item效果]
function XUiPanelFavorabilityMessage:ResetOtherItems(index)
    for k, v in pairs(self.DataList) do
        if index ~= k then
            v.IsToggle = false
        end
    end
end

-- [点击资料]
function XUiPanelFavorabilityMessage:OnDataClick(index, grid)
    local characterId = self.UiRoot:GetCurrFavorabilityCharacter()
    local isUnlock = XDataCenter.FavorabilityManager.IsInformationUnlock(characterId, self.CurData.Id)
    local canUnlock = XDataCenter.FavorabilityManager.CanInformationUnlock(characterId, self.CurData.Id)
    if isUnlock then
        self:ResetOtherItems(index)
        grid:OnToggle()
        self.DynamicTableData:ReloadDataASync(1)
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


return XUiPanelFavorabilityMessage
