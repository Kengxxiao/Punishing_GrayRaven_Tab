local XUiPanelBagItem = require("XUi/XUiBag/XUiPanelBagItem")
local XUiPanelSidePopUp = require("XUi/XUiBag/XUiPanelSidePopUp")
local XUiPanelBagRecycle = require("XUi/XUiBag/XUiPanelBagRecycle")
local XUiPanelSelectGift = require("XUi/XUiBag/XUiPanelSelectGift")

local XUiBag = XLuaUiManager.Register(XLuaUi, "UiBag")
local PageRecordCache = XBagConfigs.PageType.Equip --这个东西退出背包的时候要记录，怪怪的需求。。。
local GridTimeAnimation = 10

function XUiBag:OnAwake()
    self:AutoAddListener()
    XUiBag.PageType = XBagConfigs.PageType
    XUiBag.OperationType = XBagConfigs.OperationType
end

function XUiBag:OnStart(record)
    self.PageRecord = record or PageRecordCache

    self:PlayAnimation("AnimStartEnable")
    self.IsFirstAnimation = true
    self:Init()

    --打开背包时如果上次选择是意识那么回到套装封面
    if self.PageRecord == XUiBag.PageType.Awareness then
        self.PageRecord = XUiBag.PageType.SuitCover
    end

    if self.PageRecord == XUiBag.PageType.Awareness then
        self:PageTurn(XUiBag.PageType.Awareness)
    else
        self.TabBtnGroup:SelectIndex(self.PageRecord, false)
    end

    self.SortBtnGroup:SelectIndex(self.SortType + 1, false)

    self:UpdateRecyclePanel()
end

function XUiBag:OnEnable()
    self.GridCount = 1
    self:Refresh(false)
end

function XUiBag:OnDestroy()
    PageRecordCache = self.PageRecord
end

--注册监听事件
function XUiBag:OnGetEvents()
    return {
        XEventId.EVENT_ITEM_USE,
        XEventId.EVENT_ITEM_RECYCLE,
    }
end

--处理事件监听
function XUiBag:OnNotify(evt, ...)
    if evt == XEventId.EVENT_ITEM_USE then
        self:UpdateDynamicTable()
    elseif evt == XEventId.EVENT_ITEM_RECYCLE then
        self:UpdateRecyclePanel()
    end
end

--回收道具弹窗
function XUiBag:UpdateRecyclePanel()
    local recycleItemList = XDataCenter.ItemManager.GetRecycleItemList()
    if not recycleItemList then return end

    local recycleItems = recycleItemList.RecycleItems
    local rewardGoodsList = recycleItemList.RewardGoodsList

    self.BagRecyclePanel:Refresh(recycleItems, rewardGoodsList)
    self:UpdateDynamicTable()

    XDataCenter.ItemManager.ResetRecycleItemList()
end

function XUiBag:Init()
    self.ItemPageToTypes = {
        [XUiBag.PageType.Material] = {
            XItemConfigs.ItemType.Gift,
            XItemConfigs.ItemType.CardExp,
            XItemConfigs.ItemType.EquipExp,
            XItemConfigs.ItemType.Material
        },
        [XUiBag.PageType.Fragment] = { XItemConfigs.ItemType.Fragment },
    }

    self.IsAscendOrder = false
    self.Operation = XUiBag.OperationType.Common
    self.SortType = XEquipConfig.PriorSortType.Star
    self.StarCheckList = {true, true, true, true, true, true }
    self.SelectList = {}

    local togs = { self.BtnTog0, self.BtnTog1, self.BtnTog2, self.BtnTog3 }
    self.TabBtnGroup:Init(togs, function(index) self:PageTurn(index) end)
    local sorttogs = { self.BtnTogSortStar, self.BtnTogSortBreakthrough, self.BtnTogSortLevel, self.BtnTogSortProceed }
    self.SortBtnGroup = XUiTabBtnGroup.New(sorttogs, function(index) self:SortTypeTurn(index) end)

    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.FreeGem, XDataCenter.ItemManager.ItemId.ActionPoint, XDataCenter.ItemManager.ItemId.Coin)
    self.SidePopUpPanel = XUiPanelSidePopUp.New(self.PanelSidePopUp, self)
    self.BagRecyclePanel = XUiPanelBagRecycle.New(self, self.PanelBagRecycle)
    self.SelectGiftPanel = XUiPanelSelectGift.New(self, self.PanelSelectGift)

    self.DynamicTable = XDynamicTableNormal.New(self.PanelDynamicTable)
    self.DynamicTable:SetProxy(XUiPanelBagItem)
    self.DynamicTable:SetDelegate(self)

    self.PanelBagItem.gameObject:SetActive(false)
    self.GridBagItemRect = self.PanelBagItem.transform:Find("GridEquip"):GetComponent("RectTransform").rect
    self.GridSuitSimpleRect = self.PanelBagItem.transform:Find("GridSuitSimple"):GetComponent("RectTransform").rect
end

function XUiBag:Refresh(bReload)
    self:UpdateDynamicTable(bReload)
    self:UpdatePanels()
end

--设置动态列表
function XUiBag:UpdateDynamicTable(bReload)
    --刷新数据
    self.PageDatas = self:GetDataByPage()
    local gridSize
    if self.PageRecord == XUiBag.PageType.SuitCover then
        --套装的格子比较大
        gridSize = CS.UnityEngine.Vector2(self.GridSuitSimpleRect.width, self.GridSuitSimpleRect.height)
    else
        gridSize = CS.UnityEngine.Vector2(self.GridBagItemRect.width, self.GridBagItemRect.height)
    end

    self.DynamicTable:SetGridSize(gridSize)
    self.DynamicTable:SetDataSource(self.PageDatas)
    self.DynamicTable:ReloadDataASync(bReload and 1 or -1)

    --刷新容量文本
    local curPageCount = #self.PageDatas
    local maxCount
    local capacityDes = ""

    if self.PageRecord == XUiBag.PageType.Equip then
        maxCount = CS.XGame.Config:GetInt("EquipWeaponMaxCount")
        capacityDes = CS.XTextManager.GetText("EquipCapacityDes")
    elseif self.PageRecord == XUiBag.PageType.Awareness then
        maxCount = CS.XGame.Config:GetInt("EquipChipMaxCount")
        capacityDes = CS.XTextManager.GetText("AwarenessCapacityDes")
    elseif self.PageRecord == XUiBag.PageType.SuitCover then
        curPageCount = curPageCount - 1 --去掉默认全部套装特殊Id
        maxCount = XDataCenter.EquipManager.GetMaxSuitCount()
        capacityDes = CS.XTextManager.GetText("SuitCapacityDes")
    elseif self.PageRecord == XUiBag.PageType.Material then
        capacityDes = CS.XTextManager.GetText("MaterialCapacityDes")
    elseif self.PageRecord == XUiBag.PageType.Fragment then
        capacityDes = CS.XTextManager.GetText("FragmentCapacityDes")
    end

    self.TxtCapacityDes.text = capacityDes
    if maxCount then
        self.TxtNowCapacity.text = curPageCount
        self.TxtMaxCapacity.text = "/" .. maxCount
    end
end

--动态列表事件
function XUiBag:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        if self.IsFirstAnimation then
            grid:Init(self, self.PageRecord, true)
        else
            grid:Init(self, self.PageRecord, false)
        end
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local gridSize = self.DynamicTable:GetGridSize()
        local data = self.PageDatas[index]
        if self.PageRecord == XUiBag.PageType.Equip or self.PageRecord == XUiBag.PageType.Awareness then
            grid:SetupEquip(data, gridSize)
            grid:SetSelectedEquip(self.SelectList[data])
        elseif self.PageRecord == XUiBag.PageType.SuitCover then
            grid:SetupSuit(data, self.PageDatas, gridSize)
        else
            grid:SetupCommon(data, self.PageRecord, self.Operation, gridSize)
            grid:SetSelectedCommon(self.SelectList[data.GridIndex] and self.SelectList[data.GridIndex] == data.Data.Id)
        end
        self.GridCount = self.GridCount + 1
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_RELOAD_COMPLETED then
        local grids = self.DynamicTable:GetGrids()
        self.GridIndex = 1
        self.CurAnimationTimerId = CS.XScheduleManager.Schedule(function()
            local item = grids[self.GridIndex]
            if item then
                item:PlayAnimation()
            end
            self.GridIndex = self.GridIndex + 1
        end, GridTimeAnimation, self.GridCount, 0)
    end
end

function XUiBag:OnDisable()
    self.IsFirstAnimation = nil
    if self.CurAnimationTimerId then
        CS.XScheduleManager.UnSchedule(self.CurAnimationTimerId)
        self.CurAnimationTimerId = nil
    end
end

--刷新面板状态
function XUiBag:UpdatePanels()
    local isEmpty = #self.PageDatas <= 0

    self.PanelTag.gameObject:SetActive(self.Operation == XUiBag.OperationType.Common)
    self.PanelSort.gameObject:SetActive(self.PageRecord == XUiBag.PageType.Equip or self.PageRecord == XUiBag.PageType.Awareness)
    self.PanelFilter.gameObject:SetActive(self.PageRecord == XUiBag.PageType.SuitCover)
    self.PanelEmpty.gameObject:SetActive(isEmpty)
    self.TxtNowCapacity.gameObject:SetActive(self.PageRecord == XUiBag.PageType.Equip or self.PageRecord == XUiBag.PageType.Awareness or self.PageRecord == XUiBag.PageType.SuitCover)
    self.TxtMaxCapacity.gameObject:SetActive(self.PageRecord == XUiBag.PageType.Equip or (self.PageRecord == XUiBag.PageType.Awareness and self.SelectSuitId == XEquipConfig.DEFAULT_SUIT_ID) or self.PageRecord == XUiBag.PageType.SuitCover)
    self.SidePopUpPanel:Refresh()

    --操作按钮
    if self.PageRecord == XUiBag.PageType.Equip or self.PageRecord == XUiBag.PageType.Awareness then
        self.PanelDecomposionBtn.gameObject:SetActive(true)
        self.BtnDecomposion.gameObject:SetActive(not isEmpty)
        self.ImgCantDecomposion.gameObject:SetActive(isEmpty)
    else
        self.PanelDecomposionBtn.gameObject:SetActive(false)
    end

    if self.PageRecord == XUiBag.PageType.Material then
        self.PanelSellBtn.gameObject:SetActive(true)
        self.BtnSell.gameObject:SetActive(not isEmpty)
        self.ImgCantSell.gameObject:SetActive(isEmpty)
    else
        self.PanelSellBtn.gameObject:SetActive(false)
    end

    if self.PageRecord == XUiBag.PageType.Fragment then
        self.PanelConvertBtn.gameObject:SetActive(true)
        self.BtnConvert.gameObject:SetActive(not isEmpty)
        self.ImgCantConvert.gameObject:SetActive(isEmpty)
    else
        self.PanelConvertBtn.gameObject:SetActive(false)
    end
end

--获取数据
function XUiBag:GetDataByPage()
    --武器
    if self.PageRecord == XUiBag.PageType.Equip then
        local equipIds = {}

        if self.Operation == XUiBag.OperationType.Decomposion then
            equipIds = XDataCenter.EquipManager.GetCanDecomposeWeaponIds()
        else
            equipIds = XDataCenter.EquipManager.GetWeaponIds()
        end

        XDataCenter.EquipManager.SortEquipIdListByPriorType(equipIds, self.SortType)
        if self.IsAscendOrder then
            equipIds = XTool.ReverseList(equipIds)
        end

        return equipIds
    end

    --套装
    if self.PageRecord == XUiBag.PageType.SuitCover then
        local suitIds = XDataCenter.EquipManager.GetSuitIdsByStars(self.StarCheckList)
        return suitIds
    end

    --意识
    if self.PageRecord == XUiBag.PageType.Awareness then
        local awarenessIds = {}

        if self.Operation == XUiBag.OperationType.Decomposion then
            awarenessIds = XDataCenter.EquipManager.GetCanDecomposeAwarenessIdsBySuitId(self.SelectSuitId)
        else
            awarenessIds = XDataCenter.EquipManager.GetEquipIdsBySuitId(self.SelectSuitId)
        end

        XDataCenter.EquipManager.SortEquipIdListByPriorType(awarenessIds, self.SortType)
        if self.IsAscendOrder then
            awarenessIds = XTool.ReverseList(awarenessIds)
        end

        return awarenessIds
    end

    --材料和碎片
    if self.PageRecord == XUiBag.PageType.Fragment or self.PageRecord == XUiBag.PageType.Material then
        local types = self.ItemPageToTypes[self.PageRecord]
        local originData
        if self.Operation == XUiBag.OperationType.Sell then
            originData = XDataCenter.ItemManager.GetCanSellItemsByTypes(types)
        elseif self.Operation == XUiBag.OperationType.Convert then
            originData = XDataCenter.ItemManager.GetCanConvertItemsByTypes(types)
        else
            originData = XDataCenter.ItemManager.GetItemsByTypes(types)
        end
        return XDataCenter.ItemManager.ConvertToGridData(originData)
    end
end

function XUiBag:OnGridClick(data, grid)
    if self.Operation == XUiBag.OperationType.Common then
        self:OpenDetailUi(data)
    else
        self:SelectGrid(data, grid)
    end
end

function XUiBag:OpenDetailUi(data)
    if self.PageRecord == XUiBag.PageType.Equip or self.PageRecord == XUiBag.PageType.Awareness then
        XLuaUiManager.Open("UiEquipDetail", data)
    elseif self.PageRecord == XUiBag.PageType.SuitCover then
        self.SelectSuitId = data
        self:PageTurn(XUiBag.PageType.Awareness)
    elseif self.PageRecord == XUiBag.PageType.Material or self.PageRecord == XUiBag.PageType.Fragment then
        if XDataCenter.ItemManager.IsSelectGift(data.Data.Id) then
            self.SelectGiftPanel:Refresh(data.Data.Id)
        else
            XLuaUiManager.Open("UiBagItemInfoPanel", data)
        end
    end
end

--选中Grid
function XUiBag:SelectGrid(data, grid)
    if self.Operation == XUiBag.OperationType.Decomposion then
        local cancelStar

        if self.SelectList[data] then
            self.SelectList[data] = nil
            grid:SetSelected(false)

            local equip = XDataCenter.EquipManager.GetEquip(data)
            cancelStar = XDataCenter.EquipManager.GetEquipStar(equip.TemplateId)
        else
            self.SelectList[data] = data
            grid:SetSelected(true)
        end
        self.SidePopUpPanel:RefreshDecomposionPreView(self.SelectList, cancelStar)
    elseif self.Operation == XUiBag.OperationType.Sell or self.Operation == XUiBag.OperationType.Convert then
        if self.SelectList[data.GridIndex] and self.SelectList[data.GridIndex] == data.Data.Id then return end

        self.SelectList = {}    --单选
        self.SelectList[data.GridIndex] = data.Data.Id

        if self.LastSelectCommonGrid then
            self.LastSelectCommonGrid:SetSelectState(false)
        end
        self.LastSelectCommonGrid = grid
        self.LastSelectCommonGrid:SetSelectState(true)

        self.SidePopUpPanel:RefreshSellPreView(self.SelectList[data.GridIndex], 1, grid)
    end
end

--选中一个品质
function XUiBag:SelectByStar(star, state)
    if self.Operation ~= XUiBag.OperationType.Decomposion then return end

    for index, equipId in ipairs(self.PageDatas) do
        local equip = XDataCenter.EquipManager.GetEquip(equipId)
        local equipStar = XDataCenter.EquipManager.GetEquipStar(equip.TemplateId)

        if equipStar == star then
            if state then
                if not self.SelectList[equipId] then
                    self.SelectList[equipId] = equipId
                end
            else
                if self.SelectList[equipId] then
                    self.SelectList[equipId] = nil
                end
            end

            local grid = self.DynamicTable:GetGridByIndex(index)
            if grid then
                grid:SetSelectedEquip(state)
            end
        end
    end

    self.SidePopUpPanel:RefreshDecomposionPreView(self.SelectList)
end

function XUiBag:OnSell()
    local items = {}
    local dataCount = 0
    for index, item in pairs(self.SelectList) do
        local selectCount = item.Count
        if selectCount > 0 then
            local data = {}
            data.Id = item.Id
            data.Count = selectCount
            if items[data.Id] then
                items[data.Id] = items[data.Id] + data.Count
            else
                items[data.Id] = data.Count
                dataCount = dataCount + 1
            end
        end
    end

    if dataCount == 0 then
        return
    end

    local callback = function(money)
        XUiManager.TipMsg(CS.XTextManager.GetText("CharacterUpgradeSkillConsumeCoin") .. "+" .. money)
        self:OperationTurn(XUiBag.OperationType.Common)
    end

    XDataCenter.ItemManager.Sell(items, dataCount, callback)
end

function XUiBag:AutoAddListener()
    self:RegisterClickEvent(self.BtnSell, self.OnBtnSellClick)
    self:RegisterClickEvent(self.BtnOrder, self.OnBtnOrderClick)
    self:RegisterClickEvent(self.TogStar6, self.OnTogStar6Click)
    self:RegisterClickEvent(self.TogStar5, self.OnTogStar5Click)
    self:RegisterClickEvent(self.TogStar4, self.OnTogStar4Click)
    self:RegisterClickEvent(self.TogStar3, self.OnTogStar3Click)
    self:RegisterClickEvent(self.BtnBack, self.OnBtnBackClick)
    self:RegisterClickEvent(self.BtnMainUi, self.OnBtnMainUiClick)
    self:RegisterClickEvent(self.BtnDecomposion, self.OnBtnDecomposionClick)
    self:RegisterClickEvent(self.BtnConvert, self.OnBtnConvertClick)
end
-- auto
function XUiBag:OnBtnMainUiClick(...)
    XLuaUiManager.RunMain()
end

function XUiBag:OnBtnBackClick(...)
    if self.Operation ~= XUiBag.OperationType.Common then
        self:OperationTurn(XUiBag.OperationType.Common)
    elseif self.PageRecord == XUiBag.PageType.Awareness then
        self:PageTurn(XUiBag.PageType.SuitCover)
    else
        self:Close()
    end
end

function XUiBag:OnBtnSellClick(...)
    self:OperationTurn(XUiBag.OperationType.Sell)
end

function XUiBag:OnBtnDecomposionClick(...)
    self:OperationTurn(XUiBag.OperationType.Decomposion)
end

function XUiBag:OnBtnConvertClick(eventData)
    local types = self.ItemPageToTypes[XUiBag.OperationType.Convert]
    local originData = XDataCenter.ItemManager.GetCanConvertItemsByTypes(types)
    if not originData or #originData == 0 then
        XUiManager.TipText("BagNoOverFragment")
        return
    end

    self:OperationTurn(XUiBag.OperationType.Convert)
end

function XUiBag:OnBtnOrderClick(eventData)
    self:OrderTypeTurn(not self.IsAscendOrder)
end

function XUiBag:OnTogStar6Click(eventData)
    self:StarToggleStateChange(6, self.TogStar6.isOn)
end

function XUiBag:OnTogStar5Click(eventData)
    self:StarToggleStateChange(5, self.TogStar5.isOn)
end

function XUiBag:OnTogStar4Click(eventData)
    self:StarToggleStateChange(4, self.TogStar4.isOn)
end

function XUiBag:OnTogStar3Click(eventData)
    self:StarToggleStateChange(3, self.TogStar3.isOn)
    self:StarToggleStateChange(2, self.TogStar3.isOn)
    self:StarToggleStateChange(1, self.TogStar3.isOn)
end

--切换页签
function XUiBag:PageTurn(page)
    if self.PageRecord == page then
        return
    end

    if self.CurAnimationTimerId then
        CS.XScheduleManager.UnSchedule(self.CurAnimationTimerId)
        self.CurAnimationTimerId = nil
    end

    self.IsFirstAnimation = false
    self.PageRecord = page
    self:Refresh(true)
    if not self.SidePopUpPanel.CurState and not self.IsFirstAnimation then
        self:PlayAnimation("AnimNeiRongEnable")
    end

end

--切换操作
function XUiBag:OperationTurn(operation)
    self.Operation = operation
    self.SelectList = {}

    local isAscendOrder = self.Operation ~= XUiBag.OperationType.Common
    self:OrderTypeTurn(isAscendOrder)

    self:UpdatePanels()
end

--切换排序
function XUiBag:SortTypeTurn(index)
    self.SortType = index - 1
    self:UpdateDynamicTable(true)
    if not self.SidePopUpPanel.CurState and not self.IsFirstAnimation then
        self:PlayAnimation("AnimNeiRongEnable")
    end
end

--切换顺序
function XUiBag:OrderTypeTurn(isAscendOrder)
    self.IsAscendOrder = isAscendOrder
    self.ImgAscend.gameObject:SetActive(self.IsAscendOrder)
    self.ImgDescend.gameObject:SetActive(not self.IsAscendOrder)
    self:UpdateDynamicTable(true)
    if not self.SidePopUpPanel.CurState and not self.IsFirstAnimation then
        self:PlayAnimation("AnimNeiRongEnable")
    end
end

--筛选同星级套装
function XUiBag:StarToggleStateChange(star, state)
    self.StarCheckList[star] = state
    self:UpdateDynamicTable(true)
    if not self.SidePopUpPanel.CurState and not self.IsFirstAnimation then
        self:PlayAnimation("AnimNeiRongEnable")
    end
end