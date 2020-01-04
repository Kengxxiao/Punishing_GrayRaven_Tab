local Object = CS.UnityEngine.Object
local Vector3 = CS.UnityEngine.Vector3
local Vector2 = CS.UnityEngine.Vector2
local V3O = Vector3.one
local Next = _G.next
local XUiPurchase = XLuaUiManager.Register(XLuaUi, "UiPurchase")
local TextManager = CS.XTextManager
local PurchaseManager
local TabsConfig
local PanelNameConfig
local PanelExNameConfig
local LBUitypes
local TabExConfig
local UITypeCfg = {}
local XUiPurchasePay = require("XUi/XUiPurchase/XUiPurchasePay")
local XUiPurchasePayAdd = require("XUi/XUiPurchase/XUiPurchasePayAdd")
local XUiPurchaseLB = require("XUi/XUiPurchase/XUiPurchaseLB")
local XUiPurchaseYK = require("XUi/XUiPurchase/XUiPurchaseYK")
local XUiPurchaseHK = require("XUi/XUiPurchase/XUiPurchaseHK")
local XUiPurchaseHKShop = require("XUi/XUiPurchase/XUiPurchaseHKShop")
local XUiPurchaseHKExchange = require("XUi/XUiPurchase/XUiPurchaseHKExchange")

function XUiPurchase:OnAwake()
    TabsConfig = XPurchaseConfigs.TabsConfig
    PanelNameConfig = XPurchaseConfigs.PanelNameConfig
    PanelExNameConfig = XPurchaseConfigs.PanelExNameConfig
    PurchaseManager = XDataCenter.PurchaseManager
    TabExConfig = XPurchaseConfigs.TabExConfig
    self:GetLBUiTypesList()
    XTool.InitUiObject(self)
    UITypeCfg = XPurchaseConfigs.GetTabControlUiTypeConfig()
    self:InitUI()
    XRedPointManager.AddRedPointEvent(self.GameObject, self.LBRedPoint, self, {XRedPointConditions.Types.CONDITION_PURCHASE_LB_RED})
    XRedPointManager.AddRedPointEvent(self.GameObject, self.AccumulateRedPoint, self, {XRedPointConditions.Types.CONDITION_ACCUMULATEPAY_RED})
end

function XUiPurchase:GetLBUiTypesList()
    local t = XPurchaseConfigs.GetLBUiTypesList()
    LBUitypes = {}
    for _,v in pairs(t)do
        LBUitypes[v] = v
    end
end

function XUiPurchase:AccumulateRedPoint(result)
    if self.BtnLjcz then
        self.BtnLjcz:ShowReddot(result == 0)
    end
end

function XUiPurchase:LBRedPoint(result)
    if self.LBBtn then
        self.LBBtn:ShowReddot(result == 0)
    end

    local lbreduitypes = PurchaseManager.LBRedPointUiTypes()
    if self.Btns and Next(self.LBtnIndex) and Next(lbreduitypes) then
        for index,uitype in pairs(self.LBtnIndex)do
            if v and self.Btns[index] then
                self.Btns[index]:ShowReddot(lbreduitypes[uitype] ~= nil)
            end
        end
    else
        if self.Btns and Next(self.Btns) then
            for _,btn in pairs(self.Btns)do
                if btn then
                    btn:ShowReddot(false)
                end
            end
        end
    end
end

-- [监听动态列表事件]
function XUiPurchase:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:Init(self)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local data = self.ListData[index]
        grid:OnRefresh(data)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then
    end
end

function XUiPurchase:InitFunction()
    self.StartseleTabCb = function(tab) self:OnStartSelTab(tab) end
end

function XUiPurchase:OnStart(tab,isClearData,childtabIndex)
    self.IsClearData = isClearData
    if isClearData == nil then
        self.IsClearData = true
    end
    
    self.ChildtabIndex = childtabIndex or 1

    PurchaseManager.GetPurchaseListRequest(XPurchaseConfigs.GetLBUiTypesList())
    local t = tab or 1
    self:OnStartSelTab(t)

    local flage = PurchaseManager.IsAccumulateEnterOpen()
    self.BtnLjcz.gameObject:SetActive(flage)
    if flage then
        local f = XDataCenter.PurchaseManager.AccumlatePayRedPoint()
        self.BtnLjcz:ShowReddot(f)
    end
end

function XUiPurchase:OnStartSelTab(t)
    local uitypes = XPurchaseConfigs.GetUiTypesByTab(t)
    local cfg = self.TabsCfg
    local index = 1
    for k, v in pairs(cfg)do
        local childs = v.Childs
        for _,c in pairs(childs)do
            for _,a in pairs(uitypes)do
                if a.UiType == c.UiType then
                    index = k
                    break
                end
            end
        end
    end

    self.IsStartAnmation = true
    self:TabSkip(index)
    self.Tabgroup:SelectIndex(index)
end

function XUiPurchase.UiTypeTabSort(a,b)
    if UITypeCfg[a] and UITypeCfg[b] then
        return UITypeCfg[a].GroupOrder < UITypeCfg[b].GroupOrder
    end
    return false
end

function XUiPurchase:InitGroupTab(uitypes)
    if not self.Btns then
        self.Btns = {}
    end

    self.LBtnIndex = {}
    local lbreduitypes = PurchaseManager.LBRedPointUiTypes()
    local i = 0
    for k, v in pairs(uitypes) do
        if not self.TabBtns[k] then
            local btn = Object.Instantiate(self.BtnTab)
            btn.transform:SetParent(self.PanelTabGroup.transform, false)
            self.Btns[k] = btn
            local btncs = btn:GetComponent("XUiButton")
            self.TabBtns[k] = btncs
        end
        if lbreduitypes and lbreduitypes[v] then
            self.Btns[k]:ShowReddot(true)
            self.LBtnIndex[k] = v
        else
            self.Btns[k]:ShowReddot(false)
        end
        self.Btns[k].gameObject:SetActive(true)
        self.TabBtns[k]:SetName(UITypeCfg[v].Name)
        i = i + 1
    end

    local len = #self.Btns
    if i < len then
        for index = i+1, len do
            self.Btns[index].gameObject:SetActive(false)
        end
    end
 
    self.GroupTabgroup:Init(self.TabBtns, function(tab) self:GroupTabSkip(tab) end)
    self.GroupTabgroup:SelectIndex(self.ChildtabIndex)
end

function XUiPurchase:GroupTabSkip(tab)
    if self.SignleTab == tab then
        return
    end

    local cfgs = self.TabsCfg[self.CurGroupTab]
    if not cfgs or not cfgs.Childs[tab] then
        return 
    end

    local cfg = XPurchaseConfigs.GetUiTypeConfigByType(cfgs.Childs[tab].UiType)
    if not cfg or not cfg.UiPrefabStyle then
        return
    end

    self.SignleTab =  tab

    if self.CurLuaUI then
        self.CurLuaUI:HidePanel()
    end

    local n = PanelExNameConfig[cfg.UiPrefabStyle]
    self.CurLuaUI = self.LuaUIs[n]
    self.CurLuaUI:OnRefresh(cfg.UiType)
    self:PlayAnimation("QieHuanSmall")
end

function XUiPurchase:OnEnable()
    if self.CurLuaUI then
        self.CurLuaUI:ShowPanel()
    end
    XEventManager.AddEventListener(XEventId.EVENT_ACCUMLATED_UPTATE,self.OnAccumlatedUpdate,self)
    XEventManager.AddEventListener(XEventId.EVENT_ACCUMLATED_REWARD,self.OnAccumlatedGeted,self)
end

function XUiPurchase:OnDisable()
    if self.CurLuaUI then
        self.CurLuaUI:HidePanel()
    end
    XEventManager.RemoveEventListener(XEventId.EVENT_ACCUMLATED_UPTATE,self.OnAccumlatedUpdate,self)
    XEventManager.RemoveEventListener(XEventId.EVENT_ACCUMLATED_REWARD, self.OnAccumlatedGeted,self)
end

function XUiPurchase:OnAccumlatedUpdate()
end

function XUiPurchase:OnAccumlatedGeted()
    self.UiPurchasePayAdd:SetListData()
end

function XUiPurchase:OnDestroy()
    self.Btns = nil
    if self.IsClearData then
        PurchaseManager.ClearData()
    end
end

function XUiPurchase:OnGetEvents()
end

function XUiPurchase:OnNotify(evt, ...)
end

function XUiPurchase:IsLBUitype(cfg)
    if Next(cfg) then
        for _, v in pairs(cfg)do
            if LBUitypes[v.UiType] then
                return true
            end
        end
    end
    return false
end

function XUiPurchase:InitUI()
    self.TabBtns = {}
    self.LBtnIndex = {}

    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAssetPay, XDataCenter.ItemManager.ItemId.FreeGem, XDataCenter.ItemManager.ItemId.HongKa)
    
    local grouptabBtns = {}
    self.TabsCfg = XPurchaseConfigs.GetGroupConfigType()
    self.Tabgroup = self.PanelTopTabGroup:GetComponent("XUiButtonGroup")
    for k, v in ipairs(self.TabsCfg) do
        local btn = Object.Instantiate(self.BtnPayTab)
        btn.gameObject:SetActive(true)
        btn.transform:SetParent(self.PanelTopTabGroup.transform, false)
        local btncs = btn:GetComponent("XUiButton")
        btncs:SetName(v.GroupName)
        local assetpath = XPurchaseConfigs.GetIconPathByIconName(v.GroupIcon)
        if assetpath and assetpath.AssetPath then
            btn:SetRawImage(assetpath.AssetPath)
        end 
        if self:IsLBUitype(v.Childs) then
            btn:ShowReddot(PurchaseManager.LBRedPoint())
            self.LBBtn = btn
        else
            btn:ShowReddot(false)
        end
        table.insert(grouptabBtns, btncs)
    end
   
    self.Tabgroup:Init(grouptabBtns, function(tab) self:TabSkip(tab) end)

    self.LuaUIs = {}
    self.LuaUIs[PanelNameConfig.PanelRecharge] = XUiPurchasePay.New(self.PanelRecharge,self,XPurchaseConfigs.TabExConfig.Sample)
    self.LuaUIs[PanelNameConfig.PanelLb] = XUiPurchaseLB.New(self.PanelLb,self)
    self.LuaUIs[PanelNameConfig.PanelYk] = XUiPurchaseYK.New(self.PanelYk,self)
    self.LuaUIs[PanelNameConfig.PanelDh] = XUiPurchaseHKExchange.New(self.PanelDh,self)
    self.LuaUIs[PanelNameConfig.PanelHksd] = XUiPurchaseHKShop.New(self.PanelHksd,self)

    self.LuaUIs[PanelExNameConfig.PanelRecharge] = XUiPurchasePay.New(self.PanelRechargeEx,self,XPurchaseConfigs.TabExConfig.EXTable)
    self.LuaUIs[PanelExNameConfig.PanelLb] = XUiPurchaseLB.New(self.PanelLbEx,self)
    self.LuaUIs[PanelExNameConfig.PanelDh] = XUiPurchaseHKExchange.New(self.PanelDhEx,self)
    self.LuaUIs[PanelExNameConfig.PanelYk] = XUiPurchaseYK.New(self.PanelYkEx,self)
    self.LuaUIs[PanelExNameConfig.PanelHksd] = XUiPurchaseHKShop.New(self.PanelHksdEx,self)

    self.UiPurchasePayAdd = XUiPurchasePayAdd.New(self.PanelLjcz,self)
    self:AddListener()
end

function XUiPurchase:SetData() 
    local cfg = self.TabsCfg[self.CurGroupTab]
    if not cfg then
        return
    end

    local names = XPurchaseConfigs.PanelNameConfig
    local childs = cfg.Childs or {}
    if #childs > 1 then
        names = XPurchaseConfigs.PanelExNameConfig
        self.Panels.gameObject:SetActive(false)
        self.PanelsEx.gameObject:SetActive(true)
        self.ImgBgEx.gameObject:SetActive(true)
        self.PanelTabGroup.gameObject:SetActive(true)
        self:InitGroupTab(self.CurUitypes)
        if self.IsStartAnmation then
            self.IsStartAnmation = false
            self:PlayAnimation("AnimEnableSmall")
        else
            self:PlayAnimation("QieHuanSmall")
        end
    else
        self.PanelTabGroup.gameObject:SetActive(false)
        self.ImgBgEx.gameObject:SetActive(false)
        self.Panels.gameObject:SetActive(true)
        self.PanelsEx.gameObject:SetActive(false)
        for k,v in pairs(names)do
            if k ~= self.CurUinames[k] then
                self.LuaUIs[k]:HidePanel()
            else
                self.CurLuaUI = self.LuaUIs[v]
                self.CurLuaUI:OnRefresh(self.CurUitypes[1])
            end
        end
        if self.IsStartAnmation then
            self.IsStartAnmation = false
            self:PlayAnimation("AnimEnableBig")
        else
            self:PlayAnimation("QieHuanBig")
        end
    end
end

function XUiPurchase:TabSkip(tab)
    if self.CurGroupTab == tab then
        return 
    end

    local cfg = self.TabsCfg[tab]
    if not cfg then
        return
    end

    local childs = cfg.Childs or {}
    if Next(childs) == nil then
        return 
    end

    self.CurGroupTab = tab
    self.SignleTab  = nil

    local names = XPurchaseConfigs.PanelNameConfig
    local senduitypes = {}
    self.CurUitypes = {}
    self.CurUinames = {}

    -- 充值的读表不需后端数据
    local payuitypes = XPurchaseConfigs.GetPayUiTypes()
    for _, v in pairs(childs) do
        if not payuitypes[v.UiType] then
            table.insert(senduitypes, v.UiType)
        end

        table.insert(self.CurUitypes, v.UiType)
        local cfg = XPurchaseConfigs.GetUiTypeConfigByType(v.UiType)
        if cfg and cfg.UiPrefabStyle then
            self.CurUinames[cfg.UiPrefabStyle] = cfg.UiPrefabStyle
        end
    end

    if self.CurLuaUI then
        self.CurLuaUI:HidePanel()
    end

    if Next(senduitypes) ~= nil then
        if PurchaseManager.IsHaveDataByUiTypes(senduitypes) then
            self:SetData()
        else
            PurchaseManager.GetPurchaseListRequest(senduitypes,function() 
                self:SetData()
            end)
        end
    else
        if #childs > 1 then
            names = XPurchaseConfigs.PanelExNameConfig
            self.Panels.gameObject:SetActive(false)
            self.PanelsEx.gameObject:SetActive(true)
            self.ImgBgEx.gameObject:SetActive(true)
            self.PanelTabGroup.gameObject:SetActive(true)
            self:InitGroupTab(self.CurUitypes)
            if self.IsStartAnmation then
                self.IsStartAnmation = false
                self:PlayAnimation("AnimEnableSmall")
            else
                self:PlayAnimation("QieHuanSmall")
            end
        else
            self.PanelTabGroup.gameObject:SetActive(false)
            self.ImgBgEx.gameObject:SetActive(false)
            self.Panels.gameObject:SetActive(true)
            self.PanelsEx.gameObject:SetActive(false)
            for k,v in pairs(names)do
                if k ~= self.CurUinames[k] then
                    self.LuaUIs[k]:HidePanel()
                else
                    self.CurLuaUI = self.LuaUIs[v]
                    self.CurLuaUI:OnRefresh(self.CurUitypes[1])
                end
            end
            if self.IsStartAnmation then
                self.IsStartAnmation = false
                self:PlayAnimation("AnimEnableBig")
            else
                self:PlayAnimation("QieHuanBig")
            end
        end
    end
end

function XUiPurchase:AddListener()
    self:RegisterClickEvent(self.BtnMainUi, self.OnBtnMainUIClick)
    self:RegisterClickEvent(self.BtnBack, self.OnBtnReturnClick)
    self:RegisterClickEvent(self.BtnLjcz, self.OnBtnPayAddClick)
end

function XUiPurchase:OnBtnReturnClick()
    self:Close()
end

function XUiPurchase:OnBtnMainUIClick()
    XLuaUiManager.RunMain()
end

function XUiPurchase:OnBtnPayAddClick()
    self.PanelLjcz.gameObject:SetActive(true)
    self.UiPurchasePayAdd:OnRefresh()
end