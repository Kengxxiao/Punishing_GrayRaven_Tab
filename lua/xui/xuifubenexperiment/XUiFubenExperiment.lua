local XUiFubenExperiment = XLuaUiManager.Register(XLuaUi, "UiFubenExperiment")
local ParseToTimestamp = XTime.ParseToTimestamp

function XUiFubenExperiment:OnAwake()
    self:AddListener()
end

function XUiFubenExperiment:OnStart(selectIdx)
    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset,
        XDataCenter.ItemManager.ItemId.FreeGem,
        XDataCenter.ItemManager.ItemId.ActionPoint,
        XDataCenter.ItemManager.ItemId.Coin)
    self.TrialGroup = XDataCenter.FubenExperimentManager.GetTrialGroup()
    self.BtnTabGoList = {}
    self.CurSelectIndex = 1
    self.BannerList = {}
    self:InitDynamicTable()
    self:InitTab(selectIdx)
    XEventManager.AddEventListener(XEventId.EVENT_UPDATE_EXPERIMENT, self.UpdateCurBannerState, self)
end

function XUiFubenExperiment:OnDestroy()
    XCountDown.RemoveTimer(self.GameObject.name)
    XEventManager.RemoveEventListener(XEventId.EVENT_UPDATE_EXPERIMENT, self.UpdateCurBannerState, self)
end

function XUiFubenExperiment:InitTab(selectIdx)
    --CreateGameObject
    for i = 1, #self.TrialGroup do
        if not self.BtnTabGoList[i] then
            local tempBtnTab
            if self.TrialGroup[i].SubIndex > 0 then
                tempBtnTab = CS.UnityEngine.Object.Instantiate(self.Obj:GetPrefab("BtnTab2"))
            else
                tempBtnTab = CS.UnityEngine.Object.Instantiate(self.Obj:GetPrefab("BtnTab1"))
            end
            tempBtnTab.transform:SetParent(self.TabBtnContent, false)
            local uiButton = tempBtnTab:GetComponent("XUiButton")
            uiButton.SubGroupIndex = self.TrialGroup[i].SubIndex
            table.insert(self.BtnTabGoList, uiButton)
        end
        self.BtnTabGoList[i].gameObject:SetActiveEx(self:CheakTime(i))
    end
    for i = #self.TrialGroup + 1, #self.BtnTabGoList do
        self.BtnTabGoList[i].gameObject:SetActiveEx(false)
    end
    --BtnGroup
    self.TabBtnGroup:Init(self.BtnTabGoList, function(index) self:OnSelectedTog(index) end)
    --InitBtn
    for i = 0, #self.TrialGroup - 1 do
        local trialGroupInfo = self.TrialGroup[i + 1]
        if trialGroupInfo then
            self.TabBtnGroup.TabBtnList[i]:SetName(trialGroupInfo.Name)
        end
    end
    --default select
    self.TabBtnGroup:SelectIndex(selectIdx or 1);
end

function XUiFubenExperiment:InitDynamicTable()
    self.DynamicTable = XDynamicTableNormal.New(self.PanelTaskList)
    self.DynamicTable:SetProxy(XUiFubenExperimentBanner)
    self.DynamicTable:SetDelegate(self)
    self.FubenTriallBanner.gameObject:SetActiveEx(false)
end

function XUiFubenExperiment:SetupDynamicTable(id,IsTimeIn)
    if IsTimeIn then
        self.PageDatas = XDataCenter.FubenExperimentManager.GetTrialLevelByGroupID(id)
    else
        self.PageDatas = {}
    end
    
    self.DynamicTable:SetDataSource(self.PageDatas)
    self.DynamicTable:ReloadDataSync(1)
end

function XUiFubenExperiment:CheakTime(id)
    local endTime = XDataCenter.FubenExperimentManager.GetEndTime(id)
    if not endTime then
    else
        endTime = ParseToTimestamp(endTime)
        if (endTime == nil) or (endTime - XTime.GetServerNowTimestamp() <= 0) then
            return false
        end
    end
    local startTime = XDataCenter.FubenExperimentManager.GetStartTime(id)
    if startTime then
        startTime = ParseToTimestamp(startTime)
        if (startTime == nil) or (startTime - XTime.GetServerNowTimestamp() > 0) then
            return false
        end
    end
    return true
end

function XUiFubenExperiment:SetTime(time)
    local timestamp = ParseToTimestamp(time)
    if not timestamp then return end
    local leftTime = timestamp - XTime.GetServerNowTimestamp()
    XCountDown.CreateTimer(self.GameObject.name, leftTime)
    XCountDown.BindTimer(self.GameObject, self.GameObject.name, function(v, oldV)
            self.TxtTime.text = CS.XTextManager.GetText("DrawResetTimeShort", XUiHelper.GetTime(v, XUiHelper.TimeFormatType.DRAW))
        end)
end

function XUiFubenExperiment:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:Init(index,function(index, curType) self:OnBannerClick(index, curType) end)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        grid:UpdateBanner(self.PageDatas[index])
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then 
    end
end

function XUiFubenExperiment:AddListener()
    self:RegisterClickEvent(self.BtnBack, self.OnBtnBackClick)
    self:RegisterClickEvent(self.BtnMainUi, self.OnBtnMainUiClick)
    self:RegisterClickEvent(self.BtnActDesc, self.OnBtnActDescClick)
end

function XUiFubenExperiment:OnBtnActDescClick(...)
    XUiManager.UiFubenDialogTip("", self.TrialGroup[self.CurSelectIndex].Description or "")
end

function XUiFubenExperiment:OnBtnMainUiClick(...)
    XLuaUiManager.RunMain()
end

function XUiFubenExperiment:OnBtnBackClick(...)
    self:Close()
end

function XUiFubenExperiment:OnBannerClick(index, curType)
    XLuaUiManager.Open("UiFubenExperimentDetail", self.PageDatas[index], curType)
end

function XUiFubenExperiment:OnSelectedTog(index)
    local endTime = XDataCenter.FubenExperimentManager.GetEndTime(self.TrialGroup[index].Id)
    local isTimeIn = false
    self.CurSelectIndex = index
    
    for i = 1, #self.BtnTabGoList do
        local tmp = self:CheakTime(i)
        if not tmp then self.BtnTabGoList[i].gameObject:SetActiveEx(tmp) end
        if i == index then isTimeIn = tmp end
    end
    
    self.PanelTime.gameObject:SetActiveEx(isTimeIn)
    if endTime then 
        self:SetTime(endTime)
    else
        self.PanelTime.gameObject:SetActiveEx(false) 
    end

    self:SetupDynamicTable(self.TrialGroup[index].Id,isTimeIn)
end

function XUiFubenExperiment:UpdateCurBannerState()
    self:OnSelectedTog(self.CurSelectIndex)
end
