local XUiFubenDailyDrop = XLuaUiManager.Register(XLuaUi, "UiFubenDailyDrop")
local WEEK = 7
local DROP_VIEW_MAX = 5
function XUiFubenDailyDrop:OnAwake()
    self.DropGroupDatas = {}
    self.BtnTabGoList = {}
    
    self.RandomDorpDynamicTable = XDynamicTableNormal.New(self.RandomDorpList)
    self.RandomDorpDynamicTable:SetDynamicEventDelegate(function(event, index, grid)
        self:OnRandomDropEvent(event, index, grid) 
            end)
    self.RandomDorpDynamicTable:SetProxy(XUiGridCommon)
    self.RandomDorpDynamicTable:SetDelegate(self)
    self.RandomDropGrid.gameObject:SetActive(false)
    
    self.FixedDorpDynamicTable = XDynamicTableNormal.New(self.FixedDorpList)
    self.FixedDorpDynamicTable:SetDynamicEventDelegate(function(event, index, grid)
        self:OnFixedDropEvent(event, index, grid) 
            end)
    self.FixedDorpDynamicTable:SetProxy(XUiGridCommon)
    self.FixedDorpDynamicTable:SetDelegate(self)
    self.FixedDropGrid.gameObject:SetActive(false)
end

function XUiFubenDailyDrop:OnStart(dungeon)
    self.Rule = dungeon.Rule
    self.DungeonId = dungeon.DungeonId
    self.CurSelectIndex = XDataCenter.FubenDailyManager.GetNowDayOfWeekByRefreshTime()--默认选中本日
    self:SetupDynamicTable(false, self.CurSelectIndex);
    self:InitTab()
end

function XUiFubenDailyDrop:OnRandomDropEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        self:InitDropData(grid)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        self:RefreshDropData(true, index, grid)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then
        self:RefreshDropData(true, index, grid)
    end
end

function XUiFubenDailyDrop:OnFixedDropEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        self:InitDropData(grid)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        self:RefreshDropData(false, index, grid)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then
        self:RefreshDropData(false, index, grid)
    end
end

function XUiFubenDailyDrop:OnDynamicTableEvent(event, index, grid)
end

function XUiFubenDailyDrop:InitTab()
    for i = 1, WEEK do
        if not self.BtnTabGoList[i] then
            local tempBtnTab
            tempBtnTab = CS.UnityEngine.Object.Instantiate(self.BtnDayOfWeek)
            tempBtnTab.transform:SetParent(self.BtnDayOfWeekGroup.transform, false)
            local uiButton = tempBtnTab:GetComponent("XUiButton")
            table.insert(self.BtnTabGoList, uiButton)
        end
        self.BtnTabGoList[i].gameObject:SetActive(true)
    end
    
    self.BtnDayOfWeekGroup:Init(self.BtnTabGoList, function(index) self:OnSelectedTog(index) end)
    self.BtnTanchuangClose.CallBack = function() 
        self:OnBtnCloseClick() 
    end
    
    for k, v in pairs(self.DropGroupDatas) do
        self.BtnTabGoList[k]:SetName(v.Remark)
        self.BtnTabGoList[k]:SetButtonState(CS.UiButtonState.Normal)
    end
    
    local tmpOpen = XDataCenter.FubenDailyManager.GetEventOpen(self.DungeonId).IsOpen
    if not tmpOpen then
        for i = 1, WEEK do
            if self.Rule.OpenDayOfWeek[i] == 0 then
                self.BtnTabGoList[i]:SetButtonState(CS.UiButtonState.Disable)
            end
        end
    end
    
    self.BtnDayOfWeekGroup:SelectIndex(self.CurSelectIndex);
    
end



function XUiFubenDailyDrop:SetupDynamicTable(bReload, dayOfWeek)--设置动态表属性
    self:GetDropGroupList()
    self.RandomDropDatas, self.FixedDropDatas = XDataCenter.FubenDailyManager.GetDropDataList(self.DungeonId, dayOfWeek)
    
    self.RandomDorpDynamicTable:SetDataSource(self.RandomDropDatas)
    self.RandomDorpDynamicTable:ReloadDataSync(bReload and 1 or - 1)
    if #self.RandomDropDatas < DROP_VIEW_MAX then
        self.RandomDorpListScroll.enabled = false
    else
        self.RandomDorpListScroll.enabled = true
    end
    
    self.FixedDorpDynamicTable:SetDataSource(self.FixedDropDatas)
    self.FixedDorpDynamicTable:ReloadDataSync(bReload and 1 or - 1)
    if #self.FixedDropDatas < DROP_VIEW_MAX then
        self.FixedDorpListScroll.enabled = false
    else
        self.FixedDorpListScroll.enabled = true
    end
end


function XUiFubenDailyDrop:GetDropGroupList()--获取当前副本的掉落组
    local AllGroup = XDataCenter.FubenDailyManager:GetDailyDropGroupList()
    for k, v in pairs(AllGroup) do
        if v.DungeonId == self.DungeonId then
            table.insert(self.DropGroupDatas, v)
        end
    end
end


function XUiFubenDailyDrop:RefreshDropData(isRandom, index, grid)--将动态表内容加载进容器中
    if isRandom then
        grid:Refresh(self.RandomDropDatas[index])
    else
        grid:Refresh(self.FixedDropDatas[index])
    end
end

function XUiFubenDailyDrop:InitDropData(grid)
    grid:Init(self)
end

function XUiFubenDailyDrop:OnSelectedTog(index)
    if self.BtnTabGoList[index].ButtonState ~= CS.UiButtonState.Disable then
        self.CurSelectIndex = index
        self:SetupDynamicTable(true, index);
    end
end

function XUiFubenDailyDrop:OnBtnCloseClick()
    self:Close()
end
