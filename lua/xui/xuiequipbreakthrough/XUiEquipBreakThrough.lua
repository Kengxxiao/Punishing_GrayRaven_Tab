local CONDITION_COLOR = {
    [true] = CS.UnityEngine.Color.black,
    [false] = CS.UnityEngine.Color.gray,
}

local XUiGridCostItem = require("XUi/XUiEquipBreakThrough/XUiGridCostItem")
local XUiGridEquipReplaceAttr = require("XUi/XUiEquipReplaceNew/XUiGridEquipReplaceAttr")

local XUiEquipBreakThrough = XLuaUiManager.Register(XLuaUi, "UiEquipBreakThrough")

function XUiEquipBreakThrough:OnAwake()
    self:InitAutoScript()
    self.GridEquipReplaceAttr.gameObject:SetActive(false)
    self.GridCostItem.gameObject:SetActive(false)
    self.TxtPass.gameObject:SetActive(false)
    self.TxtNotPass.gameObject:SetActive(false)
end

function XUiEquipBreakThrough:OnStart(equipId, rootUi)
    self.EquipId = equipId
    self.RootUi = rootUi
end

function XUiEquipBreakThrough:OnEnable()
    self:InitEquipPreInfo()
    self:InitBreakthroughCondition()
    self:InitBreakthroughConsume()
    self:UpdateEquipBreakThrough()
end

function XUiEquipBreakThrough:OnGetEvents()
    return { XEventId.EVENT_EQUIP_BREAKTHROUGH_NOTYFY }
end

function XUiEquipBreakThrough:OnNotify(evt, ...)
    local args = { ... }
    local equipId = args[1]
    if equipId ~= self.EquipId then return end

    if evt == XEventId.EVENT_EQUIP_BREAKTHROUGH_NOTYFY then
        CS.XAudioManager.PlaySound(XSoundManager.UiBasicsMusic.UiEquip_BreakThroughPopUp)
        XLuaUiManager.Open("UiEquipBreakThroughPopUp", self.NextLevel, self.CurAttrMap, self.PreAttrMap, function()
            self.RootUi:OpenOneChildUi("UiEquipStrengthen", self.EquipId, self.RootUi)
        end)
    end
end

function XUiEquipBreakThrough:InitEquipPreInfo()
    local equip = XDataCenter.EquipManager.GetEquip(self.EquipId)
    self.NextLevel = XDataCenter.EquipManager.GetBreakthroughLevelLimitNext(self.EquipId)
    self.CurAttrMap = XDataCenter.EquipManager.GetBreakthroughPromotedAttrMap(self.EquipId)
    self.PreAttrMap = XDataCenter.EquipManager.GetBreakthroughPromotedAttrMap(self.EquipId, 1)

    self.TxtCurLevel.text = XDataCenter.EquipManager.GetBreakthroughLevelLimit(self.EquipId)
    self.TxtNextLevel.text = self.NextLevel
    self.TxtCurDes.text = CS.XTextManager.GetText("EquipBreakThroughDes" .. equip.Breakthrough)
    self.TxtNextDes.text = CS.XTextManager.GetText("EquipBreakThroughDes" .. (equip.Breakthrough + 1))

    self.AttrGridList = self.AttrGridList or {}
    for attrOrder, attrInfo in pairs(self.CurAttrMap) do
        local attrIndex = attrInfo.AttrIndex
        local grid = self.AttrGridList[attrIndex]
        if not grid then
            local ui = CS.UnityEngine.Object.Instantiate(self.GridEquipReplaceAttr)
            grid = XUiGridEquipReplaceAttr.New(ui, CS.XTextManager.GetText("EquipBreakThroughPopUpAttrPrefix", attrInfo.Name))
            grid.Transform:SetParent(self.PanelAttrParent, false)
            grid.GameObject:SetActive(true)
            self.AttrGridList[attrIndex] = grid
        end
        self.AttrGridList[attrIndex]:UpdateData(attrInfo.Value, self.PreAttrMap[attrOrder].Value)
    end
end

function XUiEquipBreakThrough:InitBreakthroughCondition()
    local conditionId = XDataCenter.EquipManager.GetBreakthroughCondition(self.EquipId)
    if not conditionId or conditionId == 0 then
        return
    end

    local conditionCfg = XConditionManager.GetConditionTemplate(conditionId)
    if XConditionManager.CheckCondition(conditionId) then
        self.TxtPass.text = conditionCfg.Desc
        self.TxtPass.gameObject:SetActive(true)
    else
        self.TxtNotPass.text = conditionCfg.Desc
        self.TxtNotPass.gameObject:SetActive(true)
    end
end

function XUiEquipBreakThrough:InitBreakthroughConsume()
    local costMoney = XDataCenter.EquipManager.GetBreakthroughUseMoney(self.EquipId)
    self.TxtCost.text = costMoney
    self.TxtCost.color = CONDITION_COLOR[XDataCenter.ItemManager.GetCoinsNum() >= costMoney]

    self.GridCostItems = self.GridCostItems or {}
    local consumeItems = XDataCenter.EquipManager.GetBreakthroughConsumeItems(self.EquipId)
    for index, item in ipairs(consumeItems) do
        local grid = self.GridCostItems[index]
        if not grid then
            local ui = CS.UnityEngine.Object.Instantiate(self.GridCostItem)
            grid = XUiGridCostItem.New(self, ui)
            grid.Transform:SetParent(self.PanelCostItem, false)
            grid.GameObject:SetActive(true)
            self.GridCostItems[index] = grid
        end
        grid:Refresh(item.Id, item.Count)
    end

    for i = #consumeItems + 1, #self.GridCostItems do
        self.GridCostItems[i].gameObject:SetActive(false)
    end
end

function XUiEquipBreakThrough:UpdateEquipBreakThrough()
    local preBreakthrough = 1
    self:SetUiSprite(self.ImgBreakthrough, XDataCenter.EquipManager.GetEquipBreakThroughBigIcon(self.EquipId))
    self:SetUiSprite(self.ImgBreakthrough2, XDataCenter.EquipManager.GetEquipBreakThroughBigIcon(self.EquipId, preBreakthrough))
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiEquipBreakThrough:InitAutoScript()
    self:AutoAddListener()
end

function XUiEquipBreakThrough:AutoAddListener()
    self:RegisterClickEvent(self.BtnBreak, self.OnBtnBreakClick)
end
-- auto
function XUiEquipBreakThrough:OnBtnBreakClick(eventData)
    XDataCenter.EquipManager.Breakthrough(self.EquipId)
end