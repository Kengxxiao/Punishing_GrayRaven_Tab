local XUiPanelExpBar = require("XUi/XUiSettleWinMainLine/XUiPanelExpBar")
local XUiGridEquipReplaceAttr = require("XUi/XUiEquipReplaceNew/XUiGridEquipReplaceAttr")
local XUiPanelEquipScroll = require("XUi/XUiEquipAwarenessReplace/XUiPanelEquipScroll")

local mathFloor = math.floor
local tableInsert = table.insert
local next = next
local CSTextManager = CS.XTextManager

local XUiEquipStrengthen = XLuaUiManager.Register(XLuaUi, "UiEquipStrengthen")

function XUiEquipStrengthen:OnAwake()
    self:AutoAddListener()

    self.GridEquip.gameObject:SetActiveEx(false)
    self.GridEquipReplaceAttr.gameObject:SetActiveEx(false)
    self.BtnAllSelect.gameObject:SetActiveEx(not XFunctionManager.CheckFunctionFitter(XFunctionManager.FunctionName.EquipStrengthenAutoSelect))
end

function XUiEquipStrengthen:OnStart(equipId, rootUi)
    self.EquipId = equipId
    self.RootUi = rootUi
    self.IsAscendOrder = true --初始升序

    self:InitClassifyPanel()
    self:InitEquipScroll()
    self:InitEquipAttr()
end

function XUiEquipStrengthen:OnEnable()
    self.PreLevel = nil
    self.PreExp = 0
    self.SelectEquipIds = {}

    self:UpdateViewData()
    self:UpdateEquipScroll()
    self:UpdateEquipInfo()
    self:UpdateEquipPreView()

    self.BtnStrengthen:SetDisable(true)
    self:PlayAnimation("PaneCommon")
end

function XUiEquipStrengthen:OnGetEvents()
    return { XEventId.EVENT_EQUIP_STRENGTHEN_NOTYFY, XEventId.EVENT_EQUIP_BREAKTHROUGH_NOTYFY }
end

function XUiEquipStrengthen:OnNotify(evt, ...)
    local args = { ... }
    local equipId = args[1]
    if equipId ~= self.EquipId then return end

    if evt == XEventId.EVENT_EQUIP_STRENGTHEN_NOTYFY then
        if XDataCenter.EquipManager.CanBreakThrough(self.EquipId) then
            return
        end

        if XDataCenter.EquipManager.IsMaxLevel(self.EquipId) then
            return
        end

        self.PreLevel = nil
        self.PreExp = 0
        self.SelectEquipIds = {}

        self:UpdateViewData()
        self:UpdateEquipScroll()
        self:UpdateEquipInfo()
        self:UpdateEquipPreView()
    elseif evt == XEventId.EVENT_EQUIP_BREAKTHROUGH_NOTYFY then
        self:Close()
    end
end

function XUiEquipStrengthen:InitClassifyPanel()
    if XDataCenter.EquipManager.IsClassifyEqual(self.EquipId, XEquipConfig.Classify.Weapon) then
        self.TxtTag.text = CSTextManager.GetText("WeaponStrengthenTitle")
    elseif XDataCenter.EquipManager.IsClassifyEqual(self.EquipId, XEquipConfig.Classify.Awareness) then
        self.TxtTag.text = CSTextManager.GetText("AwarenessStrengthenTitle")
    end
end

function XUiEquipStrengthen:InitEquipAttr()
    self.AttrGridList = {}
    local curAttrMap = XDataCenter.EquipManager.GetEquipAttrMap(self.EquipId)
    for attrIndex, attrInfo in pairs(curAttrMap) do
        local ui = CS.UnityEngine.Object.Instantiate(self.GridEquipReplaceAttr)
        self.AttrGridList[attrIndex] = XUiGridEquipReplaceAttr.New(ui, attrInfo.Name, true)
        self.AttrGridList[attrIndex].Transform:SetParent(self.PanelAttrParent, false)
        self.AttrGridList[attrIndex].GameObject:SetActiveEx(true)
    end
end

function XUiEquipStrengthen:InitEquipScroll()
    local equipTouchCb = function(equipId, isSelect)
        self:OnSelectEquip(equipId, isSelect)
    end

    local gridReloadCb = function()
        self.BtnOrder.enabled = true
    end

    local gridSelectCheckCb = function(equipId)
        return self:CheckCanSelect(equipId)
    end

    self.EquipScroll = XUiPanelEquipScroll.New(self, self.PanelEquipScroll, equipTouchCb, gridReloadCb, true, gridSelectCheckCb)
end

function XUiEquipStrengthen:UpdateViewData()
    if XDataCenter.EquipManager.IsClassifyEqual(self.EquipId, XEquipConfig.Classify.Awareness) then
        self.EquipIdList = XDataCenter.EquipManager.GetCanEatAwarenessIds(self.EquipId)
    elseif XDataCenter.EquipManager.IsClassifyEqual(self.EquipId, XEquipConfig.Classify.Weapon) then
        self.EquipIdList = XDataCenter.EquipManager.GetCanEatWeaponIds(self.EquipId)
    end
    self.EquipIdList = not self.IsAscendOrder and XTool.ReverseList(self.EquipIdList) or self.EquipIdList
end

function XUiEquipStrengthen:UpdateEquipScroll()
    self.EquipScroll:UpdateEquipGridList(self.EquipIdList)
end

function XUiEquipStrengthen:UpdateEquipInfo()
    local equip = XDataCenter.EquipManager.GetEquip(self.EquipId)
    local maxExp = XDataCenter.EquipManager.GetNextLevelExp(equip.TemplateId, equip.Breakthrough, equip.Level)
    local curLv = equip.Level
    local maxLv = XDataCenter.EquipManager.GetBreakthroughLevelLimit(self.EquipId)

    for _, grid in pairs(self.AttrGridList) do
        grid:UpdateData()
    end

    self.TxtCurLv.text = CSTextManager.GetText("EquipStrengthenCurLevel", curLv, maxLv)
    self.TxtExp.text = mathFloor(equip.Exp) .. "/" .. maxExp
    self.TxtPreExp.gameObject:SetActiveEx(false)
    self.ImgPlayerExpFill.fillAmount = equip.Exp / maxExp

    local curAttrMap = XDataCenter.EquipManager.GetEquipAttrMap(self.EquipId)
    for attrIndex, attrInfo in pairs(curAttrMap) do
        if self.AttrGridList[attrIndex] then
            self.AttrGridList[attrIndex]:UpdateData(attrInfo.Value)
        end
    end

    CS.UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(self.PanelLevel)
end

function XUiEquipStrengthen:UpdateEquipPreView()
    local equip = XDataCenter.EquipManager.GetEquip(self.EquipId)
    self.PreLevel = self.PreLevel or equip.Level

    local costMoney = XDataCenter.EquipManager.GetEatEquipsCostMoney(self.SelectEquipIds)
    self.TxtCost.text = costMoney

    local maxLv = XDataCenter.EquipManager.GetBreakthroughLevelLimit(self.EquipId)
    self.TxtCurLv.text = CSTextManager.GetText("EquipStrengthenCurLevel", self.PreLevel, maxLv)

    local maxExp = XDataCenter.EquipManager.GetNextLevelExp(equip.TemplateId, equip.Breakthrough, self.PreLevel)
    local preExp = self.PreExp + equip.Exp
    if self.PreLevel == maxLv then
        preExp = 0
        self.ImgPlayerExpFill.gameObject:SetActiveEx(false)
    else
        if equip.Level ~= self.PreLevel then
            for lv = equip.Level, self.PreLevel - 1 do
                preExp = preExp - XDataCenter.EquipManager.GetNextLevelExp(equip.TemplateId, equip.Breakthrough, lv)
            end
            self.ImgPlayerExpFill.gameObject:SetActiveEx(false)
        else
            self.ImgPlayerExpFill.gameObject:SetActiveEx(true)
        end
    end
    self.TxtExp.text = mathFloor(preExp) .. "/" .. maxExp
    self.ImgPlayerExpFillAdd.fillAmount = preExp / maxExp

    local addExp = mathFloor(self.PreExp)
    if addExp > 0 then
        self.TxtPreExp.text = "+" .. addExp
        self.TxtPreExp.gameObject:SetActiveEx(true)
    else
        self.TxtPreExp.gameObject:SetActiveEx(false)
    end

    local preAttrMap = XDataCenter.EquipManager.GetEquipAttrMap(self.EquipId, self.PreLevel)
    for attrIndex, attrInfo in pairs(preAttrMap) do
        if self.AttrGridList[attrIndex] then
            self.AttrGridList[attrIndex]:UpdateData(nil, attrInfo.Value, true)
        end
    end

    self.ExpBar = self.ExpBar or XUiPanelExpBar.New(self.PanelExpBar)
end

function XUiEquipStrengthen:CheckCanSelect(equipId, doNotTip)
    --先插入表检测是否超出范围
    self.SelectEquipIds[equipId] = true
    local preLevel, preExp = XDataCenter.EquipManager.GetEquipPreLevelAndExp(self.EquipId, self.SelectEquipIds)
    local limitLevel = XDataCenter.EquipManager.GetBreakthroughLevelLimit(self.EquipId)

    if self.PreLevel and self.PreLevel >= limitLevel and preExp > 0 then
        --超出范围则移除
        self.SelectEquipIds[equipId] = nil
        if not doNotTip then
            XUiManager.TipMsg(CSTextManager.GetText("EquipStrengthenMaxLevel"))
        end
        return false
    else
        --否则赋值给UI缓存
        self.PreLevel, self.PreExp = preLevel, preExp
        return true
    end
end

function XUiEquipStrengthen:OnSelectEquip(equipId, isSelect)
    --取消选中直接刷新UI缓存
    if not isSelect and equipId then
        self.SelectEquipIds[equipId] = nil
        self.PreLevel, self.PreExp = XDataCenter.EquipManager.GetEquipPreLevelAndExp(self.EquipId, self.SelectEquipIds)
    end

    local canStrengthen = next(self.SelectEquipIds)
    self.BtnStrengthen:SetDisable(not canStrengthen)

    self:UpdateEquipPreView()
end

function XUiEquipStrengthen:AutoAddListener()
    self:RegisterClickEvent(self.BtnOrder, self.OnBtnOrderClick)
    self:RegisterClickEvent(self.BtnStrengthen, self.OnBtnStrengthenClick)
    self:RegisterClickEvent(self.BtnSource, self.OnBtnSourceClick)
    self:RegisterClickEvent(self.BtnAllSelect, self.OnBtnAllSelectClick)
end

function XUiEquipStrengthen:OnBtnOrderClick(eventData)
    self.BtnOrder.enabled = false
    self.IsAscendOrder = not self.IsAscendOrder
    self.ImgAscend.gameObject:SetActiveEx(self.IsAscendOrder)
    self.ImgDescend.gameObject:SetActiveEx(not self.IsAscendOrder)

    self.EquipIdList = XTool.ReverseList(self.EquipIdList)
    self:UpdateEquipScroll()

    self.PreLevel = nil
    self.PreExp = 0
    self.SelectEquipIds = {}
    self:UpdateEquipPreView()
    self.BtnStrengthen:SetDisable(true)
end

function XUiEquipStrengthen:OnBtnMainClick(eventData)
    XLuaUiManager.RunMain()
end

function XUiEquipStrengthen:OnBtnBackClick(eventData)
    self:Close()
end

function XUiEquipStrengthen:OnBtnStrengthenClick(eventData)
    local equip = XDataCenter.EquipManager.GetEquip(self.EquipId)
    local lastLevel = equip.Level
    local lastExp = equip.Exp
    local lastMaxExp = XDataCenter.EquipManager.GetNextLevelExp(equip.TemplateId, equip.Breakthrough, lastLevel)
    local curLevel = self.PreLevel
    local curMaxExp = XDataCenter.EquipManager.GetNextLevelExp(equip.TemplateId, equip.Breakthrough, curLevel)
    local maxLv = XDataCenter.EquipManager.GetBreakthroughLevelLimit(self.EquipId)
    local curExp = self.PreExp + lastExp
    if lastLevel ~= curLevel then
        for lv = lastLevel, curLevel - 1 do
            curExp = curExp - XDataCenter.EquipManager.GetNextLevelExp(equip.TemplateId, equip.Breakthrough, lv)
        end
    end
    if curLevel == maxLv and curExp > curMaxExp then
        curExp = 0
    end

    XDataCenter.EquipManager.LevelUp(self.EquipId, self.SelectEquipIds, function()
        self.ExpBar:SkipRoll(lastLevel, lastExp, lastMaxExp, curLevel, curExp, curMaxExp)
    end)
end

function XUiEquipStrengthen:OnBtnSourceClick(eventData)
    if not self.EquipId then return end
    local skipIds = XDataCenter.EquipManager.GetEquipSkipIds(self.EquipId)
    XLuaUiManager.Open("UiEquipStrengthenSkip", skipIds)
end

function XUiEquipStrengthen:OnBtnAllSelectClick()
    if not XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.EquipStrengthenAutoSelect) then
        return
    end

    local sortedCanEatEquipIds = XDataCenter.EquipManager.GetRecomendEatEquipIds(self.EquipId)
    if not next(sortedCanEatEquipIds) then
        XUiManager.TipText("EquipStrengthenAutoSelectEmpty")
        return
    end

    self.PreLevel = nil
    self.PreExp = 0
    self.SelectEquipIds = {}

    local equipId = self.EquipId
    local equipScroll = self.EquipScroll
    equipScroll:ResetSelectGrids()

    local equipIds = {}
    for _, equipId in ipairs(sortedCanEatEquipIds) do
        if not self:CheckCanSelect(equipId, true) then
            break
        end

        equipIds[equipId] = true
    end

    -- 反选多余的装备
    local limitLevel = XDataCenter.EquipManager.GetBreakthroughLevelLimit(equipId)
    local totalNeedExp = XDataCenter.EquipManager.GetEquipLevelTotalNeedExp(equipId, limitLevel)
    local preLevel, totalExp = XDataCenter.EquipManager.GetEquipPreLevelAndExp(equipId, equipIds, true)
    for _, costEquipId in ipairs(sortedCanEatEquipIds) do
        local addExp = XDataCenter.EquipManager.GetEquipAddExp(costEquipId)
        if totalExp - addExp < totalNeedExp then
            break
        end
        totalExp = totalExp - addExp

        equipIds[costEquipId] = nil
        self.SelectEquipIds[costEquipId] = nil
    end

    self.PreLevel, self.PreExp = XDataCenter.EquipManager.GetEquipPreLevelAndExp(equipId, self.SelectEquipIds)
    equipScroll:SelectGrids(equipIds)
    self:OnSelectEquip(nil, true)
end