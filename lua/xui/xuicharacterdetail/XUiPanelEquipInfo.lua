local XUiPanelEquipInfo = XLuaUiManager.Register(XLuaUi, "UiPanelEquipInfo")

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelEquipInfo:InitAutoScript()
    self:AutoInitUi()
    XTool.InitUiObject(self)
    self:AutoAddListener()
end

function XUiPanelEquipInfo:AutoInitUi()
    self.PanelTaskList = self.Transform:Find("PanelTaskList")
    self.PanelDetailEquipItem = self.Transform:Find("PanelTaskList/Viewport/PanelDetailEquipItem")
end

function XUiPanelEquipInfo:AutoAddListener()
end
-- auto
function XUiPanelEquipInfo:OnAwake()
    self:InitAutoScript()
end

function XUiPanelEquipInfo:OnStart(CharacterId, rootUi)
    self.RootUi = rootUi
    self.CharacterId = CharacterId
    self.DynamicTable = XDynamicTableNormal.New(self.PanelTaskList)
    self.DynamicTable:SetProxy(XUiPanelDetailEquipItem)
    self.DynamicTable:SetDelegate(self)
    self.PanelDetailEquipItem.gameObject:SetActive(false)
    self:InitTabBtnGroup()

    if not XDataCenter.VoteManager.IsInit() then
        XDataCenter.VoteManager.GetVoteGroupListRequest()
    end
end

function XUiPanelEquipInfo:OnEnable()
    self:SetupDynamicTable()
    XEventManager.AddEventListener(XEventId.EVENT_VOTE_REFRESH, self.SetupDynamicTable, self)
    self.RootUi:PlayAnimation("EquipInfoEnable")
end

function XUiPanelEquipInfo:OnDisable()
    XEventManager.RemoveEventListener(XEventId.EVENT_VOTE_REFRESH, self.SetupDynamicTable, self)
    self.DynamicTable:Clear()
end

function XUiPanelEquipInfo:InitTabBtnGroup()
    local tabIdList = XCharacterConfigs.GetRecommendTabList(self.CharacterId, XCharacterConfigs.RecommendType.Equip)
    if not tabIdList then
        return
    end

    local tabGroup = {}
    for i = 1, #tabIdList do
        local uiButton
        if i == 1 then
            uiButton = self.BtnTabMatch
        else
            local itemGo = CS.UnityEngine.Object.Instantiate(self.BtnTabMatch.gameObject)
            itemGo.transform:SetParent(self.PanelTagsLayoutRT, false)
            uiButton = itemGo.transform:GetComponent("XUiButton")
        end
        
        local config = XCharacterConfigs.GetRecommendTabTemplate(self.CharacterId, tabIdList[i], XCharacterConfigs.RecommendType.Equip)
        uiButton:SetName(config.TabName)

        table.insert(tabGroup, uiButton)
    end

    self.PanelTagsLayout:Init(tabGroup, function(tabIndex) self:OnClickTabCallBack(tabIndex) end)
    self.PanelTagsLayout:SelectIndex(1)
end

function XUiPanelEquipInfo:OnClickTabCallBack(tabIndex)
    if self.CurTabId and self.CurTabId == tabIndex then
        return
    end
    self.CurTabId = tabIndex
    -- XUiHelper.PlayAnimation(self.RootUi, "AniPanelDynamicLayoutBegin")
    self.RootUi:PlayAnimation("TaskListQiehuan")
    self:SetupDynamicTable()
end

function XUiPanelEquipInfo:SetupDynamicTable()
    if not XDataCenter.VoteManager.IsInit() then
        return
    end

    local recommendEquipGroupId = XCharacterConfigs.GetRecommendGroupId(self.CharacterId, self.CurTabId, XCharacterConfigs.RecommendType.Equip)
    local voteIds = XDataCenter.VoteManager.GetVoteIdListByGroupId(recommendEquipGroupId)
    self.PageDatas = XCharacterConfigs.GetEquipRecommendListByIds(voteIds)

    if not self.PageDatas then
        self.PageDatas = {}
    end

    self.DynamicTable:SetDataSource(self.PageDatas)
    self.DynamicTable:ReloadDataASync()
end

function XUiPanelEquipInfo:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:Init(self.UiProxy)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        grid:UpdateView(self.PageDatas[index], index)
    end
end

return XUiPanelEquipInfo