local XUiGridEquip = require("XUi/XUiEquipAwarenessReplace/XUiGridEquip")

local XUiEquipResonanceSelectEquip = XLuaUiManager.Register(XLuaUi, "UiEquipResonanceSelectEquip")

function XUiEquipResonanceSelectEquip:OnAwake()
    self:InitAutoScript()
end

function XUiEquipResonanceSelectEquip:OnStart(equipId, confirmCb)
    self.EquipId = equipId
    self.ConfirmCb = confirmCb
    self.LastSelectId = nil
    self.SelectEquipId = nil

    self:InitDynamicTable()
end

function XUiEquipResonanceSelectEquip:OnEnable()
    self.EquipIdList = XDataCenter.EquipManager.GetResonanceCanEatEquipIds(self.EquipId)
    self.EquipIdList = XTool.ReverseList(self.EquipIdList) --这个UI要初始升序

    self:UpdateEquipGridList()
end

function XUiEquipResonanceSelectEquip:Reset()
    self.LastSelectId = nil
    self.SelectEquipId = nil
end

function XUiEquipResonanceSelectEquip:InitDynamicTable()
    self.DynamicTable = XDynamicTableNormal.New(self.PanelEquipScroll)
    self.DynamicTable:SetDelegate(self)
    self.DynamicTable:SetProxy(XUiGridEquip)
end

function XUiEquipResonanceSelectEquip:UpdateEquipGridList()
    self.DynamicTable:SetDataSource(self.EquipIdList)
    self.DynamicTable:ReloadDataASync(#self.EquipIdList > 0 and 1 or -1)

    if not self.EquipIdList or not next(self.EquipIdList) then
        if XDataCenter.EquipManager.IsClassifyEqual(self.EquipId, XEquipConfig.Classify.Weapon) then
            self.TxtNoEquip.text = CS.XTextManager.GetText("EquipResonanceNoWeaponTip")
        else
            self.TxtNoEquip.text = CS.XTextManager.GetText("EquipResonanceNoAwarenessTip")
        end
        self.PanelNoEquip.gameObject:SetActive(true)
    else
        self.PanelNoEquip.gameObject:SetActive(false)
    end
end

function XUiEquipResonanceSelectEquip:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:InitRootUi(self)
        grid:SetSelected(false)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local equipId = self.EquipIdList[index]
        grid:Refresh(equipId)

        local isSelected = self.LastSelectId and self.LastSelectId == equipId
        if isSelected then
            self.LastSelectGrid = grid
        end
        grid:SetSelected(isSelected)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then
        local equipId = self.EquipIdList[index]
        if self.LastSelectGrid then
            self.LastSelectGrid:SetSelected(false)
        end

        self.SelectEquipId = equipId
        self.LastSelectGrid = grid
        self.LastSelectGrid:SetSelected(true)
    end
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiEquipResonanceSelectEquip:InitAutoScript()
    self:AutoAddListener()
end

function XUiEquipResonanceSelectEquip:AutoAddListener()
    self:RegisterClickEvent(self.BtnConfirm, self.OnBtnConfirmClick)
    self:RegisterClickEvent(self.BtnClose, self.OnBtnCloseClick)
    self:RegisterClickEvent(self.Btncancel, self.OnBtnCloseClick)
end
-- auto

function XUiEquipResonanceSelectEquip:OnBtnCloseClick(eventData)

    self:Close()
end

function XUiEquipResonanceSelectEquip:OnBtnConfirmClick(eventData)
    local equipId = self.SelectEquipId
    if self.ConfirmCb and equipId then
        self.ConfirmCb(equipId)
        self.LastSelectId = equipId
    end
    self:Close()
end
