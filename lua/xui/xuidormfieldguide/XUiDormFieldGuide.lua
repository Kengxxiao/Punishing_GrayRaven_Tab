local Object = CS.UnityEngine.Object
local Vector3 = CS.UnityEngine.Vector3
local V3O = Vector3.one
local XUiDormFieldGuide = XLuaUiManager.Register(XLuaUi, "UiDormFieldGuide")
local XUiDormFieldGuideListItem = require("XUi/XUiDormFieldGuide/XUiDormFieldGuideListItem")
local XUiDormFieldGuideSeleItem = require("XUi/XUiDormFieldGuide/XUiDormFieldGuideSeleItem")
local XUiDormFieldGuideDes = require("XUi/XUiDormFieldGuide/XUiDormFieldGuideDes")
local XUiDormFieldGuideTab = require("XUi/XUiDormFieldGuide/XUiDormFieldGuideTab")

local TextManager = CS.XTextManager
local Next = _G.next
local DormManager
local FurnitureManager

function XUiDormFieldGuide:OnAwake()
    DormManager = XDataCenter.DormManager
    FurnitureManager = XDataCenter.FurnitureManager
    XTool.InitUiObject(self)
    self.TabDicIndex = {}
    self.TabObs = {}
    self.TabObs[1] = self.BtnTab1
    -- self.TabObs[2] = self.BtnTab2
    -- self.TabObs[3] = self.BtnTab3
    self:InitUI()
end

function XUiDormFieldGuide:InitEnterCfg()
    self.TabTypeCfg = {}

    local cfg = XFurnitureConfigs.GetFurnitureSuitTemplates()
    for k, v in pairs(cfg) do
        if self.FileGuideData[k] then
            table.insert(self.TabTypeCfg, v)
        end
    end

    self:CreateTypeItems(self.TabTypeCfg)
end

function XUiDormFieldGuide:CreateTypeItems(tabTypeCfg)
    if self.PanelTab then
        local index = 1
        for k, v in pairs(tabTypeCfg) do
            local obj = self.TabObs[k]
            if not obj then
                obj = Object.Instantiate(self.BtnTab1)
                obj.transform:SetParent(self.PanelTab.transform, false)
                obj.transform.localScale = V3O
                table.insert(self.TabObs, obj)
            end
            self.TabDicIndex[v.Id] = index
            index = index + 1
            obj.gameObject:SetActive(true)

            local uiTab = XUiDormFieldGuideTab.New(obj)
            uiTab:SetName(v.SuitName)
            local suitBgmInfo = XDormConfig.GetDormSuitBgmInfo(v.Id)
            uiTab:SetSuitBgm(suitBgmInfo)
        end

        self.Tabgroup = self.PanelTab:GetComponent("XUiButtonGroup")
        self.Tabgroup:Init(self.TabObs, function(tab) self:TabSkip(tab) end)
    end
end

function XUiDormFieldGuide:TabSkip(tab)
    if tab == self.PreSeleTab then
        return
    end

    self.PreSeleTab = tab
    local cfg = self.TabTypeCfg[tab]
    self:OnClickEnterSetListData(cfg.Id)
    self:PlayAnimation("QieHuan")
    local suitBgmInfo = XDormConfig.GetDormSuitBgmInfo(cfg.Id)

    self.MusicText.gameObject:SetActiveEx(suitBgmInfo ~= nil)
    if suitBgmInfo then
        self.MusicText.text = string.format(CS.XGame.ClientConfig:GetString("DormSuitBgmDesc"), suitBgmInfo.SuitNum, ",", suitBgmInfo.Name)
    end
end

function XUiDormFieldGuide:OpenDesUI(data)
    self.PanelDes.gameObject:SetActive(true)
    self:PlayAnimation("PanelDesEnable")
    if not self.InitDes then
        self.PanelDesUI = XUiDormFieldGuideDes.New(self.PanelDes, self)
    end
    self.PanelDesUI:OnRefresh(data)
end

function XUiDormFieldGuide:InitList()
    self.DynamicTable = XDynamicTableNormal.New(self.PanelItemCommon.gameObject)
    self.DynamicTable:SetProxy(XUiDormFieldGuideListItem)
    self.DynamicTable:SetDelegate(self)
end

-- [监听动态列表事件]
function XUiDormFieldGuide:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:Init(self)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local data = self.ListData[index]
        grid:OnRefresh(data, self.HaveFurIds)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then
        local data = self.ListData[index]
        self:OpenDesUI(data)
    end
end

function XUiDormFieldGuide:OnClickEnterSetListData(t)
    if not t then
        return
    end

    if t == self.PreSeleId then
        return
    end

    self.PreSeleId = t
    local data = self.FileGuideData[t] or {}
    if Next(data) ~= nil then
        table.sort(data, function(a, b) return self:Fielguildsortfun(a, b) end)
    end
    self:SetMaterials(data)
    self.ListData = data
    self.DynamicTable:SetDataSource(data)
    self.DynamicTable:ReloadDataASync(1)
end

function XUiDormFieldGuide:SetMaterials(data)
    local totalcount = 0
    local havecount = 0
    local f = false
    for _, v in pairs(data) do
        totalcount = totalcount + 1
        if not f and self.HaveFurIds[v.Id] then
            havecount = havecount + 1
        else
            f = true
        end
    end

    if havecount ~= self.CurHaveCount or totalcount ~= self.CurTotalCount then
        self.CurHaveCount = havecount
        self.CurTotalCount = totalcount
        self.TxtMaterials.text = TextManager.GetText("DormFieldGuildeCountText", havecount, totalcount)
    end

end

function XUiDormFieldGuide:Fielguildsortfun(a, b)
    if self.HaveFurIds[a.Id] and not self.HaveFurIds[b.Id] then
        return true
    end

    if not self.HaveFurIds[a.Id] and self.HaveFurIds[b.Id] then
        return false
    end

    return a.Id > b.Id
end

function XUiDormFieldGuide:OnStart(suitId)
    self.HaveFurIds = DormManager.FurnitureUnlockList or {}
    self.FileGuideData = XFurnitureConfigs.GetFieldGuideDatas()
    self:InitEnterCfg()
    local id = suitId
    if not suitId and self.TabTypeCfg[1] then
        id = self.TabTypeCfg[1].Id
    end
    local index = 1
    if id and self.TabDicIndex[id] then
        index = self.TabDicIndex[id]
    end
    self.Tabgroup:SelectIndex(index)
end

function XUiDormFieldGuide:OnEnable()
end

function XUiDormFieldGuide:OnDisable()
end

function XUiDormFieldGuide:OnDestroy()
end

function XUiDormFieldGuide:OnGetEvents()
end

function XUiDormFieldGuide:OnNotify(evt, ...)
end

function XUiDormFieldGuide:InitUI()
    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.DormCoin, XDataCenter.ItemManager.ItemId.FurnitureCoin)
    self:InitList()
    self:AddListener()
end

function XUiDormFieldGuide:AddListener()
    self.OnBtnMainUIClickCb = function() self:OnBtnMainUIClick() end
    self.OnBtnReturnClickCb = function() self:OnBtnReturnClick() end
    self.OnBtnHelpClickCb = function() self:OnBtnHelpClick() end
    self:RegisterClickEvent(self.BtnMainUi, self.OnBtnMainUIClickCb)
    self:RegisterClickEvent(self.BtnBack, self.OnBtnReturnClickCb)
end

function XUiDormFieldGuide:OnBtnMainUIClick()
    XLuaUiManager.RunMain()
end

function XUiDormFieldGuide:OnBtnReturnClick()
    self:Close()
end