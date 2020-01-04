local XUiFurnitureTypeSelect = XLuaUiManager.Register(XLuaUi, "UiFurnitureTypeSelect")
local XUiGridCategory = require("XUi/XUiFurnitureTypeSelect/XUiGridCategory")

local SelectState = {
    SINGLE = 1,
    MULTIP = 2,
}

local PanelState = {
    FURNITURE = 1,
    SUIT = 2,
}

function XUiFurnitureTypeSelect:OnAwake()
    self:AddListener()

    XEventManager.AddEventListener(XEventId.EVENT_CLICKCATEGORY_GRID, self.OnCategoryGridClick, self)
end

function XUiFurnitureTypeSelect:OnStart(selectIds, selectSuitIds, comfirmCb)
    self.SelectIds = {}
    self.SelectSuitIds = {}

    if selectIds then
        for _, k in pairs(selectIds) do
            table.insert(self.SelectIds, k)
        end
    end

    if selectSuitIds then
        for _, k in pairs(selectSuitIds) do
            table.insert(self.SelectSuitIds, k)
        end
    end

    self.CategoryGrids = {}
    self.CategorySuitGrids = {}
    self.PageRecord = PanelState.FURNITURE

    self.ComfirmCb = comfirmCb
    self.FurnitureTypeAllId = XFurnitureConfigs.FURNITURE_CATEGORY_ALL_ID
    self.FurnitureTypeSuitAllId = XFurnitureConfigs.FURNITURE_SUIT_CATEGORY_ALL_ID
    self:InitTabGroup()
    self:Init()
end

function XUiFurnitureTypeSelect:OnDestroy()
    self.SelectIds = nil
    self.SelectSuitIds = nil
    self.CategoryGrids = nil
    self.CategorySuitGrids = nil
    self.CurSelectState = nil
    self.FurnitureTypeAllId = 0

    XEventManager.RemoveEventListener(XEventId.EVENT_CLICKCATEGORY_GRID, self.OnCategoryGridClick, self)
end

function XUiFurnitureTypeSelect:InitTabGroup()
    self.BtnList = {}
    table.insert(self.BtnList, self.BtnFurnitureType)
    table.insert(self.BtnList, self.BtnFurnitureSuitType)

    self.FurnitureTypeBtnGroup:Init(self.BtnList, function(index)
        self:RefreshSelectedPanel(index)
    end)

    -- 设置默认开启
    self.FurnitureTypeBtnGroup:SelectIndex(self.PageRecord)
end

function XUiFurnitureTypeSelect:RefreshSelectedPanel(index)
    self.PageRecord = index
    self.PanelFurnitureTypeScroll.gameObject:SetActiveEx(self.PageRecord == PanelState.FURNITURE)
    self.PanelFurnitureSuitTypeScroll.gameObject:SetActiveEx(self.PageRecord == PanelState.SUIT)
end

-- 检查是否筛选过Grid
function XUiFurnitureTypeSelect:CheckCategoryGridSelect(id)
    if not self.SelectIds or #self.SelectIds <= 0 then
        return false
    end

    for i = 1, #self.SelectIds do
        if self.SelectIds[i] == id then
            return true
        end
    end

    return false
end

-- 检查套装是否筛选过Grid
function XUiFurnitureTypeSelect:CheckSuitCategoryGridSelect(id)
    if not self.SelectSuitIds or #self.SelectSuitIds <= 0 then
        return false
    end

    for i = 1, #self.SelectSuitIds do
        if self.SelectSuitIds[i] == id then
            return true
        end
    end

    return false
end

function XUiFurnitureTypeSelect:Init()
    self.GridSuitCategory.gameObject:SetActiveEx(false)

    if self.SelectIds and #self.SelectIds > 0 then
        self.CurSelectState = SelectState.MULTIP
        self:InitMultipleSelect()
        self:InitSuitPart()
        return
    end

    self.CurSelectState = SelectState.SINGLE
    self.PanelFurnitureSuitTypeScroll.gameObject:SetActiveEx(false)
    self.BtnFurnitureSuitType.gameObject:SetActiveEx(false)
    self:InitSingleSelect()
end

-- 初始化套装
function XUiFurnitureTypeSelect:InitSuitPart()
    local suitCfg = XFurnitureConfigs.GetFurnitureSuitTemplates()
    self.GridAllSuitCategory = XUiGridCategory.New(self.GridAllSuitCategory)
    local isSelected = self:CheckSuitCategoryGridSelect(self.FurnitureTypeSuitAllId)
    self.GridAllSuitCategory:RefreshSuit(suitCfg[1], isSelected)

    for i = 2, #suitCfg do
        local grid = CS.UnityEngine.Object.Instantiate(self.GridSuitCategory)
        local gridCategory = XUiGridCategory.New(grid)
        grid.transform:SetParent(self.PanelSuitContent, false)
        local isSelected = self:CheckSuitCategoryGridSelect(suitCfg[i].Id)
        gridCategory:RefreshSuit(suitCfg[i], isSelected)
        gridCategory.GameObject:SetActiveEx(true)

        table.insert(self.CategorySuitGrids, gridCategory)
    end
end

-- 单选模式
function XUiFurnitureTypeSelect:InitSingleSelect()
    self.GridCategory.gameObject:SetActiveEx(false)
    self.GridAllCategory.gameObject:SetActiveEx(false)
    self:InitFurniturePart()
end

-- 多选模式
function XUiFurnitureTypeSelect:InitMultipleSelect()
    self.GridCategory.gameObject:SetActiveEx(false)
    self.GridAllCategory.gameObject:SetActiveEx(true)

    self.GridAllCategory = XUiGridCategory.New(self.GridAllCategory)

    -- 全部类型
    local isSelected = self:CheckCategoryGridSelect(self.FurnitureTypeAllId)
    local categoryInfos = {}
    categoryInfos.Id = XFurnitureConfigs.FURNITURE_CATEGORY_ALL_ID
    categoryInfos.CategoryName = CS.XTextManager.GetText("DormAllDesc")
    self.GridAllCategory:Refresh(categoryInfos, isSelected)

    self:InitFurniturePart()
end

function XUiFurnitureTypeSelect:InitFurniturePart()
    self.GridPartSelect.gameObject:SetActiveEx(false)
    local parts = XFurnitureConfigs.GetFurnitureTemplatePartType()
    local setPartInfoFunction = function(categoryInfos, minorName)
        local part = CS.UnityEngine.Object.Instantiate(self.GridPartSelect)
        part.transform:SetParent(self.PanelPartContent, false)

        local content = XUiHelper.TryGetComponent(part, "PanelCategoryContent", "Transform")
        local name = XUiHelper.TryGetComponent(part, "TxtMinorName", "Text")

        name.text = minorName
        part.gameObject:SetActiveEx(true)

        for _, categoryInfo in pairs(categoryInfos) do
            local grid = CS.UnityEngine.Object.Instantiate(self.GridCategory)
            local gridCategory = XUiGridCategory.New(grid)

            local isSelected = self:CheckCategoryGridSelect(categoryInfo.Id)
            gridCategory:Refresh(categoryInfo, isSelected)
            grid.transform:SetParent(content, false)
            gridCategory.GameObject:SetActiveEx(true)

            table.insert(self.CategoryGrids, gridCategory)
        end
    end

    for _, part in pairs(parts) do
        setPartInfoFunction(part.Categorys, part.MinorName)
    end
end

function XUiFurnitureTypeSelect:OnCategoryGridClick(furnitureTypeId, grid)
    -- 处理套装
    if self.PageRecord == PanelState.SUIT then
        self:OnCategorySuitGridClick(furnitureTypeId, grid)
        return
    end

    -- 处理单选
    if self.CurSelectState == SelectState.SINGLE then
        if furnitureTypeId == self.SelectId then
            return
        end

        grid:SetSelected(not grid:IsSelected())
        self.SelectId = furnitureTypeId
        if self.FurnitureSelectTypeGrid then
            self.FurnitureSelectTypeGrid:SetSelected(false)
        end
        --记录选择得Grid
        self.FurnitureSelectTypeGrid = grid

        return
    end

    -- 处理已经是再全选状态下再点击全选不能取消全选
    if self.GridAllCategory:IsSelected() and furnitureTypeId == self.FurnitureTypeAllId  then
        XUiManager.TipMsg(CS.XTextManager.GetText("DormFurnitureAllTypeRepeatClickHint"), XUiManager.UiTipType.Tip)
        return
    end

    grid:SetSelected(not grid:IsSelected())
    -- 处理全选类型逻辑
    if furnitureTypeId == self.FurnitureTypeAllId then
        for _, categoryGrid in ipairs(self.CategoryGrids) do
            categoryGrid:SetSelected(false)
        end

        self.SelectIds = {}
        table.insert(self.SelectIds, furnitureTypeId)
        return
    end

    -- 处理多选其他类型

    -- 1.先移除全选类型ID
    for i = 1, #self.SelectIds do
        if self.SelectIds[i] == self.FurnitureTypeAllId then
            table.remove(self.SelectIds, i)
            self.GridAllCategory:SetSelected(false)
            break
        end
    end

    -- 2.移除点击过的类型
    for i = 1, #self.SelectIds do
        if self.SelectIds[i] == furnitureTypeId then
            table.remove(self.SelectIds, i)

            -- 3.如果没有任何类型，默认选择全部类型
            if #self.SelectIds <= 0 then
                table.insert(self.SelectIds, self.FurnitureTypeAllId)
                self.GridAllCategory:SetSelected(true)
            end

            return
        end
    end

    -- 4.加入未点击过的类型
    table.insert(self.SelectIds, furnitureTypeId)
end

function XUiFurnitureTypeSelect:OnCategorySuitGridClick(furnitureTypeId, grid)
    if self.GridAllSuitCategory:IsSelected() and furnitureTypeId == self.FurnitureTypeSuitAllId  then
        XUiManager.TipMsg(CS.XTextManager.GetText("DormFurnitureAllTypeRepeatClickHint"), XUiManager.UiTipType.Tip)
        return
    end

    grid:SetSelected(not grid:IsSelected())
    if furnitureTypeId == self.FurnitureTypeSuitAllId then
        for _, categoryGrid in ipairs(self.CategorySuitGrids) do
            categoryGrid:SetSelected(false)
        end

        self.SelectSuitIds = {}
        table.insert(self.SelectSuitIds, furnitureTypeId)
        return
    end

    for i = 1, #self.SelectSuitIds do
        if self.SelectSuitIds[i] == self.FurnitureTypeSuitAllId then
            table.remove(self.SelectSuitIds, i)
            self.GridAllSuitCategory:SetSelected(false)
            break
        end
    end

    for i = 1, #self.SelectSuitIds do
        if self.SelectSuitIds[i] == furnitureTypeId then
            table.remove(self.SelectSuitIds, i)

            if #self.SelectSuitIds <= 0 then
                table.insert(self.SelectSuitIds, self.FurnitureTypeSuitAllId)
                self.GridAllSuitCategory:SetSelected(true)
            end

            return
        end
    end

    table.insert(self.SelectSuitIds, furnitureTypeId)
end

function XUiFurnitureTypeSelect:AddListener()
    self:RegisterClickEvent(self.BtnClose, self.OnBtnCloseClick)
    self:RegisterClickEvent(self.BtnCancel, self.OnBtnCloseClick)
    self:RegisterClickEvent(self.BtnSelcet, self.OnBtnSelcetClick)
end

function XUiFurnitureTypeSelect:OnBtnCloseClick()
    self:Close()
end

function XUiFurnitureTypeSelect:OnBtnSelcetClick()
    if self.ComfirmCb then
        local data = nil
        if self.CurSelectState == SelectState.SINGLE then
            data = self.SelectId
        else
            data = self.SelectIds
        end

        if not data then
            XUiManager.TipMsg(CS.XTextManager.GetText("DormFurnitureSelectNull"))
            return
        end
        self.ComfirmCb(data, self.SelectSuitIds)
    end
    self:Close()
end

return XUiFurnitureTypeSelect
