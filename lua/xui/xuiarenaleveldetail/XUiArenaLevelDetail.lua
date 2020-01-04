local XUiArenaLevelDetail = XLuaUiManager.Register(XLuaUi, "UiArenaLevelDetail")

local XUiGridArenaLevel = require("XUi/XUiArenaLevelDetail/ArenaLevelDetailCommon/XUiGridArenaLevel")
local XUiGridRegion = require("XUi/XUiArenaLevelDetail/ArenaLevelDetailCommon/XUiGridRegion")

function XUiArenaLevelDetail:OnAwake()
    self:AutoAddListener()
    self.GridArenaLevel.gameObject:SetActive(false)
end


function XUiArenaLevelDetail:OnStart(...)
    self.GridRegionList = {}
    for i = 1, 3 do
        local regionGrid = XUiGridRegion.New(self["GridRegion" .. i], self)
        table.insert(self.GridRegionList, regionGrid)
    end

    self.DynamicTable = XDynamicTableNormal.New(self.SViewArenaLevel.transform)
    self.DynamicTable:SetProxy(XUiGridArenaLevel)
    self.DynamicTable:SetDelegate(self)
end


function XUiArenaLevelDetail:OnEnable()
    self:SetUiMetaData()
end

function XUiArenaLevelDetail:AutoAddListener()
    self:RegisterClickEvent(self.BtnBg, self.OnBtnBgClick)
end

function XUiArenaLevelDetail:OnBtnBgClick(eventData)
    self:Close()
end

--动态列表事件
function XUiArenaLevelDetail:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local data = self.DataList[index]
        grid:ResetData(data, self)
        grid:SetSelect(index == self.CurIndex)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then
        if index == self.CurIndex then
            return
        end

        local lastGrid = self.DynamicTable:GetGridByIndex(self.CurIndex)
        if lastGrid then
            lastGrid:SetSelect(false)
        end
        grid:SetSelect(true)

        self.CurIndex = index
        self:RefreshSelect()
    end
end

function XUiArenaLevelDetail:SetUiMetaData()
    local challengeId = XDataCenter.ArenaManager.GetCurChallengeId()
    local arenaLevel = XDataCenter.ArenaManager.GetCurArenaLevel()

    self.DataList = XArenaConfigs.GetChallengeCfgListById(challengeId)
    local challengeCfg = XDataCenter.ArenaManager.GetCurChallengeCfg()
    if challengeCfg then
        self.TxtGrade.text = "Lv" .. challengeCfg.MinLv .. "-" .. challengeCfg.MaxLv
    end

    self.DynamicTable:SetTotalCount(#self.DataList)
    if #self.DataList > 0 then
        self.DynamicTable:ReloadDataSync(1)
    else
        self.DynamicTable:ReloadDataSync()
    end

    self.CurIndex = 0
    for i, cfg in ipairs(self.DataList) do
        if cfg.ArenaLv == arenaLevel then
            self.CurIndex = i
        end
    end
    self:RefreshSelect()
end

function XUiArenaLevelDetail:RefreshSelect()
    if not self.GameObject:Exist() then
        return
    end

    if not self.DataList then
        return
    end

    if not self.CurIndex or self.CurIndex <= 0 then
        return
    end

    self:RefreshRankRegionGrid()
end

function XUiArenaLevelDetail:RefreshRankRegionGrid()
    local challengeCfg = self.DataList[self.CurIndex]

    for i, grid in ipairs(self.GridRegionList) do
        grid:SetMetaData(i, challengeCfg)
    end
end