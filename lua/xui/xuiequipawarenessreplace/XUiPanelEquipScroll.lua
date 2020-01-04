local XUiGridEquip = require("XUi/XUiEquipAwarenessReplace/XUiGridEquip")
local XUiPanelEquipScroll = XClass()

--multiSelect复用
function XUiPanelEquipScroll:Ctor(rootUi, ui, gridTouchCb, gridReloadCb, multiSelect, gridSelectCheckCb)
    self.RootUi = rootUi
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.GridTouchCb = gridTouchCb
    self.GridReloadCb = gridReloadCb
    self.MultiSelect = multiSelect
    self.GridSelectCheckCb = gridSelectCheckCb
    self:InitDynamicTable()
end

function XUiPanelEquipScroll:InitDynamicTable()
    self.DynamicTable = XDynamicTableNormal.New(self.GameObject)
    self.DynamicTable:SetDelegate(self)
    self.DynamicTable:SetProxy(XUiGridEquip)
    self.LastSelectIds = {}
end

function XUiPanelEquipScroll:UpdateEquipGridList(equipIdList, notResetSelect)
    if not notResetSelect then
       self.LastSelectIds = {}
    end
    self.EquipIdList = equipIdList or {}
    self.DynamicTable:UpdateViewSize()
    self.DynamicTable:SetDataSource(self.EquipIdList)
    self.DynamicTable:ReloadDataSync(#self.EquipIdList > 0 and not notResetSelect and 1 or -1)
end

function XUiPanelEquipScroll:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:InitRootUi(self.RootUi)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local equipId = self.EquipIdList[index]
        grid:Refresh(equipId)

        if self.LastSelectIds[equipId] then
            grid:SetSelected(true)
            self.LastSelectGrid = grid
        else
            grid:SetSelected(false)
        end
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then
        local equipId = self.EquipIdList[index]

        --不是多选
        if not self.MultiSelect and self.LastSelectGrid then
            self.LastSelectGrid:SetSelected(false)
        end

        local isSelected = grid:IsSelected()
        --不能选中return
        if not isSelected and self.GridSelectCheckCb and not self.GridSelectCheckCb(equipId) then
            return
        end

        --复选取消
        if self.MultiSelect then
            isSelected = not isSelected
        else
            isSelected = true
        end

        --普通选中时清除上一条记录
        if not self.MultiSelect and self.LastSelectId then
            self.LastSelectIds[self.LastSelectId] = nil
        end

        self.LastSelectId = equipId
        self.LastSelectIds[self.LastSelectId] = isSelected

        self.LastSelectGrid = grid
        self.LastSelectGrid:SetSelected(isSelected)

        if self.GridTouchCb then
            self.GridTouchCb(equipId, isSelected)
        end
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_RELOAD_COMPLETED then
        if self.GridReloadCb then
            self.GridReloadCb()
        end
    end
end

function XUiPanelEquipScroll:SelectGrids(equipIds)
    self.LastSelectIds = equipIds
    self.DynamicTable:ReloadDataSync(#self.EquipIdList > 0 and 1 or -1)
end

function XUiPanelEquipScroll:ResetSelectGrids()
    self.LastSelectIds = {}
    self.LastSelectGrid = nil
    self.LastSelectId = nil
    self.DynamicTable:ReloadDataSync(#self.EquipIdList > 0 and 1 or -1)
end

function XUiPanelEquipScroll:ResetSelectGrid()
    if self.LastSelectGrid then
        self.LastSelectGrid:SetSelected(false)
        self.LastSelectGrid = nil
        self.LastSelectIds[self.LastSelectId] = nil
        self.LastSelectId = nil
    end
end

function XUiPanelEquipScroll:GuideGetDynamicTableIndex(id)
    for i, v in ipairs(self.EquipIdList) do
        local equip = XDataCenter.EquipManager.GetEquip(v)
        if tostring(equip.TemplateId) == id then
            return i
        end
    end

    return -1
end

return XUiPanelEquipScroll