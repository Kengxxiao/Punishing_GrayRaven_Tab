local XUiGridSuitPrefab = require("XUi/XUiEquipAwarenessReplace/XUiGridSuitPrefab")
local XUiGridEquip = require("XUi/XUiEquipAwarenessReplace/XUiGridEquip")
local XUiGridResonanceSkill = require("XUi/XUiEquipResonanceSkill/XUiGridResonanceSkill")

local tableInsert = table.insert
local CSXTextManagerGetText = CS.XTextManager.GetText

local CUR_SUIT_PREFAB_INDEX = 0
local MAX_MERGE_ATTR_COUNT = 4
local ShowPropertyIndex = {
    Attr = 1,
    SuitSkill = 2,
    ResonanceSkill = 3,
}

local XUiEquipAwarenessSuitPrefab = XLuaUiManager.Register(XLuaUi, "UiEquipAwarenessSuitPrefab")

function XUiEquipAwarenessSuitPrefab:OnAwake()
    self:AutoAddListener()
    self.GridSuitPrefab.gameObject:SetActiveEx(false)
end

function XUiEquipAwarenessSuitPrefab:OnStart(characterId)
    self.CharacterId = characterId
    self.CurPrefabIndex = CUR_SUIT_PREFAB_INDEX
    self.SelectShowProperty = ShowPropertyIndex.Attr
    self.GridResonanceSkills = {}

    self:InitDynamicTable()
    self:InitCurEquipGrids()
    self:InitPropertyBtnGroup()
end

function XUiEquipAwarenessSuitPrefab:OnEnable()
    self:Refresh()
end

function XUiEquipAwarenessSuitPrefab:OnGetEvents()
    return { XEventId.EVENT_EQUIP_SUIT_PREFAB_DATA_UPDATE_NOTIFY, XEventId.EVENT_EQUIP_DATA_LIST_UPDATE_NOTYFY }
end

function XUiEquipAwarenessSuitPrefab:OnNotify(evt, ...)
    local args = { ... }
    if evt == XEventId.EVENT_EQUIP_SUIT_PREFAB_DATA_UPDATE_NOTIFY
    or evt == XEventId.EVENT_EQUIP_DATA_LIST_UPDATE_NOTYFY then
        self:Refresh(nil, true)
    end
end
function XUiEquipAwarenessSuitPrefab:AutoAddListener()
    self.BtnTanchuangClose.CallBack = function() self:OnBtnTanchuangClose() end
    self.BtnClosePopup.CallBack = function() self:ClosePopup() end
    self.BtnSetName.CallBack = function() self:OnBtnSetName() end
    self.BtnSave.CallBack = function() self:OnBtnSave() end
    self.BtnEquip.CallBack = function() self:OnBtnEquip() end
    self.BtnChangeName.CallBack = function() self:OnBtnChangeName() end
    self.BtnDelete.CallBack = function() self:OnBtnDelete() end
    self:RegisterClickEvent(self.BtnPos1, function() self:OnSelectEquipSite(XEquipConfig.EquipSite.Awareness.One) end)
    self:RegisterClickEvent(self.BtnPos2, function() self:OnSelectEquipSite(XEquipConfig.EquipSite.Awareness.Two) end)
    self:RegisterClickEvent(self.BtnPos3, function() self:OnSelectEquipSite(XEquipConfig.EquipSite.Awareness.Three) end)
    self:RegisterClickEvent(self.BtnPos4, function() self:OnSelectEquipSite(XEquipConfig.EquipSite.Awareness.Four) end)
    self:RegisterClickEvent(self.BtnPos5, function() self:OnSelectEquipSite(XEquipConfig.EquipSite.Awareness.Five) end)
    self:RegisterClickEvent(self.BtnPos6, function() self:OnSelectEquipSite(XEquipConfig.EquipSite.Awareness.Six) end)
    self:RegisterClickEvent(self.PanelDynamicTable, self.OnPanelDynamicTable)
end

function XUiEquipAwarenessSuitPrefab:OnBtnTanchuangClose()
    self:ClosePopup()
    self:Close()
end

function XUiEquipAwarenessSuitPrefab:OnPanelDynamicTable()
    self:ClosePopup()
end

function XUiEquipAwarenessSuitPrefab:OnBtnSetName()
    self:ClosePopup()
    XLuaUiManager.Open("UiEquipSuitPrefabRename", function(newName)
        self.UnSavedPrefabInfo:SetName(newName)
        self:Refresh(true)
    end)
end

function XUiEquipAwarenessSuitPrefab:OnBtnSave()
    self:ClosePopup()
    XDataCenter.EquipManager.EquipSuitPrefabSave(self.UnSavedPrefabInfo)
end

function XUiEquipAwarenessSuitPrefab:OnBtnEquip()
    self:ClosePopup()

    local equipFunc = function()
        XDataCenter.EquipManager.EquipSuitPrefabEquip(self.CurPrefabIndex, self.CharacterId, function()
            self.CurPrefabIndex = CUR_SUIT_PREFAB_INDEX
        end)
    end

    local conflictInfoList = {}
    local suitPrefabInfo = self:GetShowingPrefabInfo()
    local equipIds = suitPrefabInfo:GetEquipIds()
    for _, equipId in pairs(equipIds) do
        local characterId = XDataCenter.EquipManager.GetEquipWearingCharacterId(equipId)
        if characterId and characterId ~= self.CharacterId then
            local conflictInfo = {
                EquipId = equipId,
                CharacterId = characterId,
            }
            tableInsert(conflictInfoList, conflictInfo)
        end
    end

    if not next(conflictInfoList) then
        equipFunc()
    else
        XLuaUiManager.Open("UiEquipSuitPrefabConflict", conflictInfoList, equipFunc)
    end
end

function XUiEquipAwarenessSuitPrefab:OnBtnChangeName()
    self:ClosePopup()
    XLuaUiManager.Open("UiEquipSuitPrefabRename", function(newName)
        XDataCenter.EquipManager.EquipSuitPrefabRename(self.CurPrefabIndex, newName)
    end)
end

function XUiEquipAwarenessSuitPrefab:OnBtnDelete()
    self:ClosePopup()

    local suitPrefabInfo = self:GetShowingPrefabInfo()
    local content = suitPrefabInfo:GetName()
    XLuaUiManager.Open("UiEquipSuitPrefabConfirm", content, function()
        local prefabIndex = self.CurPrefabIndex
        self.CurPrefabIndex = CUR_SUIT_PREFAB_INDEX
        XDataCenter.EquipManager.EquipSuitPrefabDelete(prefabIndex)
    end)
end

function XUiEquipAwarenessSuitPrefab:InitDynamicTable()
    self.DynamicTable = XDynamicTableNormal.New(self.PanelDynamicTable)
    self.DynamicTable:SetProxy(XUiGridSuitPrefab)
    self.DynamicTable:SetDelegate(self)
end

function XUiEquipAwarenessSuitPrefab:InitCurEquipGrids()
    local clickCb = function(equipId)
        self:OnSelectEquip(equipId)
    end

    self.CurEquipGirds = {}
    self.GridCurAwareness.gameObject:SetActiveEx(false)
    for _, equipSite in pairs(XEquipConfig.EquipSite.Awareness) do
        local item = CS.UnityEngine.Object.Instantiate(self.GridCurAwareness)
        self.CurEquipGirds[equipSite] = XUiGridEquip.New(item, clickCb)
        self.CurEquipGirds[equipSite]:InitRootUi(self)
        self.CurEquipGirds[equipSite].Transform:SetParent(self["PanelPos" .. equipSite], false)
    end
end

function XUiEquipAwarenessSuitPrefab:InitPropertyBtnGroup()
    self.EquipBtnGroup:Init({
        self.BtnEquipProperty,
        self.BtnEquipSkill,
        self.BtnEquipResonance,
    }, function(tabIndex) self:OnSelectShowProperty(tabIndex) end)
end

function XUiEquipAwarenessSuitPrefab:OnSelectShowProperty(selectShowProperty)
    self.SelectShowProperty = selectShowProperty

    if selectShowProperty == ShowPropertyIndex.Attr then
        self:UpdateCurEquipAttr()
        self.PanelAttrParent.gameObject:SetActiveEx(true)
        self.PanelSuitSkill.gameObject:SetActiveEx(false)
        self.PanelResonanceSkill.gameObject:SetActiveEx(false)
    elseif selectShowProperty == ShowPropertyIndex.SuitSkill then
        self:UpdateCurEquipSkill()
        self.PanelAttrParent.gameObject:SetActiveEx(false)
        self.PanelSuitSkill.gameObject:SetActiveEx(true)
        self.PanelResonanceSkill.gameObject:SetActiveEx(false)
    elseif selectShowProperty == ShowPropertyIndex.ResonanceSkill then
        self:UpdateCurEquipResonanceSkill()
        self.PanelAttrParent.gameObject:SetActiveEx(false)
        self.PanelSuitSkill.gameObject:SetActiveEx(false)
        self.PanelResonanceSkill.gameObject:SetActiveEx(true)
    end

    self:ClosePopup()
end

function XUiEquipAwarenessSuitPrefab:Refresh(doNotResetUnsaved, resetScroll)
    self.UnSavedPrefabInfo = not doNotResetUnsaved and XDataCenter.EquipManager.GetUnSavedSuitPrefabInfo(self.CharacterId) or self.UnSavedPrefabInfo
    self.SuitPrefabInfoList = XDataCenter.EquipManager.GetSuitPrefabIndexList()

    self:UpdateDynamicTable(resetScroll)
    self:UpdateCurEquipGrids(self.CurPrefabIndex)
end

function XUiEquipAwarenessSuitPrefab:UpdateCurEquipAttr()
    local suitPrefabInfo = self:GetShowingPrefabInfo()
    local attrMap = XDataCenter.EquipManager.GetAwarenessMergeAttrMap(suitPrefabInfo:GetEquipIds())
    local attrCount = 0

    for _, attr in pairs(attrMap) do
        attrCount = attrCount + 1
        if attrCount > MAX_MERGE_ATTR_COUNT then
            break
        end
        self["TxtName" .. attrCount].text = attr.Name
        self["TxtAttr" .. attrCount].text = attr.Value
        self["PanelAttr" .. attrCount].gameObject:SetActiveEx(true)
    end

    for i = attrCount + 1, MAX_MERGE_ATTR_COUNT do
        self["PanelAttr" .. i].gameObject:SetActiveEx(false)
    end
end

function XUiEquipAwarenessSuitPrefab:UpdateCurEquipSkill()
    local suitPrefabInfo = self:GetShowingPrefabInfo()
    local activeSkillDesInfoList = XDataCenter.EquipManager.GetSuitMergeActiveSkillDesInfoList(suitPrefabInfo:GetEquipIds())
    local skillCount = 0

    for i = 1, XEquipConfig.MAX_SUIT_SKILL_COUNT do
        if not activeSkillDesInfoList[i] then
            self["TxtSkillDes" .. i].gameObject:SetActiveEx(false)
        else
            self["TxtPos" .. i].text = activeSkillDesInfoList[i].PosDes
            self["TxtSkillDes" .. i].text = activeSkillDesInfoList[i].SkillDes
            self["TxtSkillDes" .. i].gameObject:SetActiveEx(true)
            skillCount = skillCount + 1
        end
    end

    if skillCount == 0 then
        self.PanelNoSkill.gameObject:SetActiveEx(true)
    else
        self.PanelNoSkill.gameObject:SetActiveEx(false)
    end

    CS.UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(self["TxtSkillDes1"].transform.parent)
end

function XUiEquipAwarenessSuitPrefab:UpdateCurEquipResonanceSkill()
    local suitPrefabInfo = self:GetShowingPrefabInfo()
    local equipIds = suitPrefabInfo:GetEquipIds()
    local skillCount = 0
    local characterId = self.CharacterId
    for _, equipId in pairs(equipIds) do
        local resonanceSkillNum = XDataCenter.EquipManager.GetResonanceSkillNum(equipId)
        for pos = resonanceSkillNum, 1, -1 do
            if XDataCenter.EquipManager.CheckEquipPosResonanced(equipId, pos) then
                local grid = self.GridResonanceSkills[skillCount]
                if not grid then
                    local item = CS.UnityEngine.Object.Instantiate(self.GridResonanceSkill)
                    grid = XUiGridResonanceSkill.New(item, equipId, pos, characterId, function(equipId, pos, characterId)
                        XLuaUiManager.Open("UiEquipResonanceSkillDetailInfo", equipId, pos, characterId)
                    end)
                    grid.Transform:SetParent(self.PanelResonanceSkillParent, false)
                    self.GridResonanceSkills[skillCount] = grid
                end

                grid:SetEquipIdAndPos(equipId, pos)
                grid:Refresh()
                grid.GameObject:SetActiveEx(true)

                skillCount = skillCount + 1
            end
        end
    end

    for i = 1, #self.GridResonanceSkills do
        self.GridResonanceSkills[i].GameObject:SetActiveEx(i <= skillCount)
    end

    local noResonanceSkill = skillCount == 0
    self.PanelResonanceSkillParent.gameObject:SetActiveEx(not noResonanceSkill)
    self.PanelNoResonanceSkill.gameObject:SetActiveEx(noResonanceSkill)
end

function XUiEquipAwarenessSuitPrefab:UpdateSavePanel()
    local isPreafabSaved = self.CurPrefabIndex ~= CUR_SUIT_PREFAB_INDEX
    self.PanelSavedPrefab.gameObject:SetActiveEx(isPreafabSaved)
    self.PanelUnSavedPrefab.gameObject:SetActiveEx(not isPreafabSaved)

    if not isPreafabSaved then
        local suitPrefabInfo = self:GetShowingPrefabInfo()
        self.BtnSetName:SetName(suitPrefabInfo:GetName())
    end
end

function XUiEquipAwarenessSuitPrefab:UpdateDynamicTable(resetScroll)
    self.TxtTotalNum.text = CSXTextManagerGetText("EquipSuitPrefabNum", XDataCenter.EquipManager.GetSuitPrefabNum(), XDataCenter.EquipManager.GetSuitPrefabNumMax())
    self.DynamicTable:SetDataSource(self.SuitPrefabInfoList)
    self.DynamicTable:ReloadDataASync(resetScroll and 1)
end

function XUiEquipAwarenessSuitPrefab:OnDynamicTableEvent(event, index, grid)
    local suitPrefabIndex = self.SuitPrefabInfoList[index]
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local suitPrefabInfo = self:GetShowingPrefabInfo(suitPrefabIndex)
        local isPreafabSaved = suitPrefabIndex ~= CUR_SUIT_PREFAB_INDEX
        grid:Refresh(suitPrefabInfo, suitPrefabIndex, isPreafabSaved)
        if self.CurPrefabIndex == suitPrefabIndex then
            grid:SetSelected(true)
            self.LastSelectSuitPrefabGird = grid
        else
            grid:SetSelected(false)
        end
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then
        if self.LastSelectSuitPrefabGird then
            self.LastSelectSuitPrefabGird:SetSelected(false)
        end
        self.LastSelectSuitPrefabGird = grid
        if self.LastSelectSuitPrefabGird then
            self.LastSelectSuitPrefabGird:SetSelected(true)
        end
        self:UpdateCurEquipGrids(suitPrefabIndex)
        self:ClosePopup()
    end
end

function XUiEquipAwarenessSuitPrefab:UpdateCurEquipGrids(suitPrefabIndex)
    self.CurPrefabIndex = suitPrefabIndex

    self:UpdateSavePanel()
    self.EquipBtnGroup:SelectIndex(self.SelectShowProperty)
    for _, equipSite in pairs(XEquipConfig.EquipSite.Awareness) do
        self:UpdateCurEquipGrid(equipSite)
    end
end

function XUiEquipAwarenessSuitPrefab:UpdateCurEquipGrid(equipSite)
    local suitPrefabInfo = self:GetShowingPrefabInfo()

    local equipId = suitPrefabInfo:GetEquipId(equipSite)
    if not equipId or equipId == 0 then
        self.CurEquipGirds[equipSite].GameObject:SetActiveEx(false)
        self["PanelNoEquip" .. equipSite].gameObject:SetActiveEx(true)
    else
        self.CurEquipGirds[equipSite]:Refresh(equipId)
        self.CurEquipGirds[equipSite].GameObject:SetActiveEx(true)
        self["PanelNoEquip" .. equipSite].gameObject:SetActiveEx(false)
    end
end

function XUiEquipAwarenessSuitPrefab:ClosePopup()
    if XLuaUiManager.IsUiShow("UiEquipAwarenessPopup") then
        XLuaUiManager.Close("UiEquipAwarenessPopup")
    end
end

function XUiEquipAwarenessSuitPrefab:OnSelectEquip(equipId)
    local equipSite = XDataCenter.EquipManager.GetEquipSite(equipId)
    self:OnSelectEquipSite(equipSite)

    if self.CurEquipGirds[equipSite] then
        XLuaUiManager.Open("UiEquipAwarenessPopup", self, nil, equipId, self.CharacterId, true)
    end
end

function XUiEquipAwarenessSuitPrefab:OnSelectEquipSite(equipSite)
    if self.LastSelectPos then
        local go = self["ImgSelect" .. self.LastSelectPos]
        local set = go and go.gameObject:SetActiveEx(false)
    end
    self.LastSelectPos = equipSite
    if self.LastSelectPos then
        local go = self["ImgSelect" .. self.LastSelectPos]
        local set = go and go.gameObject:SetActiveEx(true)
    end

    if self.LastSelectCurGrid then
        self.LastSelectCurGrid:SetSelected(false)
    end
    self.LastSelectCurGrid = self.CurEquipGirds[equipSite]
    if self.LastSelectCurGrid then
        self.LastSelectCurGrid:SetSelected(true)
    end

    self:ClosePopup()
end

function XUiEquipAwarenessSuitPrefab:GetShowingPrefabInfo(prefabIndex)
    prefabIndex = prefabIndex or self.CurPrefabIndex
    return XDataCenter.EquipManager.GetSuitPrefabInfo(prefabIndex) or self.UnSavedPrefabInfo
end