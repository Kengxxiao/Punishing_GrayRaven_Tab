local XUiGridEquip = require("XUi/XUiEquipAwarenessReplace/XUiGridEquip")
local XUiGridSuitDetail = require("XUi/XUiEquipAwarenessReplace/XUiGridSuitDetail")

local XUiPanelBagItem = XClass()

function XUiPanelBagItem:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
    XTool.InitUiObject(self)
end

function XUiPanelBagItem:Init(rootUi, page, isfirstanimation)
    self.GameObject:SetActive(true)
    self.Parent = rootUi
    self.Page = page
    self.IsFirstAnimation = isfirstanimation
    local clickCb = function(data, grid)
        self.Parent:OnGridClick(data, grid)
    end

    self.EquipGrid = XUiGridEquip.New(self.GridEquip, clickCb, rootUi)
    self.SuitGrid = XUiGridSuitDetail.New(self.GridSuitSimple, rootUi, clickCb)
    self.BagItemGrid = XUiBagItem.New(rootUi, self.GridBagItem, nil, clickCb)
end

function XUiPanelBagItem:SetupCommon(data, pageType, operation, gridSize)
    self.BagItemGrid:Refresh(data)
    self.BagItemGrid.GameObject:SetActive(true)
    self.GridBagItemRect.sizeDelta = gridSize
    self.EquipGrid.GameObject:SetActive(false)
    self.SuitGrid.GameObject:SetActive(false)
end

function XUiPanelBagItem:SetupEquip(equipId, gridSize)
    self.EquipGrid:Refresh(equipId)
    self.EquipGrid.GameObject:SetActive(true)
    self.GridEquipRect.sizeDelta = gridSize
    self.SuitGrid.GameObject:SetActive(false)
    self.BagItemGrid.GameObject:SetActive(false)
end

function XUiPanelBagItem:SetupSuit(suitId, defaultSuitIds, gridSize)
    self.SuitGrid:Refresh(suitId, defaultSuitIds, true)
    self.SuitGrid.GameObject:SetActive(true)
    self.GridSuitSimpleRect.sizeDelta = gridSize
    self.EquipGrid.GameObject:SetActive(false)
    self.BagItemGrid.GameObject:SetActive(false)
end

function XUiPanelBagItem:SetSelectedEquip(bSelect)
    self.EquipGrid:SetSelected(bSelect)
end

function XUiPanelBagItem:SetSelectedCommon(bSelect)
    self.BagItemGrid:SetSelectState(bSelect)
end

function XUiPanelBagItem:PlayAnimation()
    if not self.IsFirstAnimation then
        return 
    end

    self.IsFirstAnimation = false
    if self.Page == XBagConfigs.PageType.Equip or self.Page == XBagConfigs.PageType.Awareness then
        self.GridEquipTimeline:PlayTimelineAnimation()
    elseif self.Page == XBagConfigs.PageType.SuitCover then
        self.GridSuitSimpleTimeline:PlayTimelineAnimation()
    else
        self.GridBagItemTimeline:PlayTimelineAnimation()
    end
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelBagItem:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiPanelBagItem:AutoInitUi()
    self.GridEquip = self.Transform:Find("GridEquip")
    self.GridBagItem = self.Transform:Find("GridBagItem")
    self.GridSuitSimple = self.Transform:Find("GridSuitSimple")
end

function XUiPanelBagItem:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelBagItem:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelBagItem:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelBagItem:AutoAddListener()
end
-- auto
return XUiPanelBagItem