local CsXTextManagerGetText = CS.XTextManager.GetText

local XUiGridEquip = require("XUi/XUiEquipAwarenessReplace/XUiGridEquip")
local XUiGridResonanceSkill = require("XUi/XUiEquipResonanceSkill/XUiGridResonanceSkill")

local TabConsumeType = {
    Equip = 0,
    Item = 1,
}

local XUiEquipResonanceSelect = XLuaUiManager.Register(XLuaUi, "UiEquipResonanceSelect")

function XUiEquipResonanceSelect:OnAwake()
    self:AutoAddListener()
    self.GridCurAwareness.gameObject:SetActiveEx(false)
    self.GridCurItem.gameObject:SetActiveEx(false)
end

function XUiEquipResonanceSelect:OnStart(equipId, rootUi)
    self.EquipId = equipId
    self.RootUi = rootUi
    self.SelectEquipId = nil
    self.SelectCharacterId = nil
    self.DescriptionTitle = CsXTextManagerGetText("EquipResonanceExplainTitle")
    self.Description = string.gsub(CsXTextManagerGetText("EquipResonanceExplain"), "\\n", "\n")
end

function XUiEquipResonanceSelect:OnEnable()
    self:InitRightView()
    self:UpdateBtnStatus()
    self.TogConsumeType:SetButtonState(TabConsumeType.Equip)
    self:OnTogConsumeTypeClick(TabConsumeType.Equip)
    self:UpdateCurCharacter()
    self:UpdateResonanceSkill()
    self:UpdateResonanceConsumeItem()
end

function XUiEquipResonanceSelect:OnGetEvents()
    return { XEventId.EVENT_EQUIP_RESONANCE_NOTYFY, XEventId.EVENT_EQUIP_RESONANCE_ACK_NOTYFY }
end

function XUiEquipResonanceSelect:OnNotify(evt, ...)
    local args = { ... }
    local equipId = args[1]
    local pos = args[2]
    if equipId ~= self.EquipId then return end
    if pos ~= self.Pos then return end

    if evt == XEventId.EVENT_EQUIP_RESONANCE_NOTYFY then
        self.RootUi:FindChildUiObj("UiEquipResonanceSkill").UiProxy:SetActive(true)
        self.UiProxy:SetActive(false)
        XLuaUiManager.Open("UiEquipResonanceSelectAfter", self.EquipId, self.Pos)

        self.SelectEquipId = nil
        self.SelectCharacterId = nil

        self:UpdateBtnStatus()
        self:OnTogConsumeTypeClick(self.TabConsumeType)
        self:UpdateResonanceSkill()
    elseif evt == XEventId.EVENT_EQUIP_RESONANCE_ACK_NOTYFY then
        self.SelectEquipId = nil
        self.SelectCharacterId = nil

        self:UpdateBtnStatus()
        self:OnTogConsumeTypeClick(self.TabConsumeType)
        self:UpdateResonanceSkill()
    end
end

function XUiEquipResonanceSelect:Refresh(pos)
    self.Pos = pos
    self.SelectCharacterId = nil
    self.SelectEquipId = nil
end

function XUiEquipResonanceSelect:UpdateConsumeTxt()
    local equipId = self.EquipId
    if self.TabConsumeType == TabConsumeType.Item then
        local consumeCount = XDataCenter.EquipManager.GetResonanceConsumeItemCount(equipId)
        self.TxtConsumeWhat.text = CsXTextManagerGetText("EquipResonanceConsumeItemCount", consumeCount)
    elseif self.TabConsumeType == TabConsumeType.Equip then
        if XDataCenter.EquipManager.IsClassifyEqual(equipId, XEquipConfig.Classify.Weapon) then
            self.TxtConsumeWhat.text = CsXTextManagerGetText("WeaponStrengthenTitle")
            self.TogConsumeType:SetNameByGroup(0, CsXTextManagerGetText("TypeWeapon"))
        elseif XDataCenter.EquipManager.IsClassifyEqual(equipId, XEquipConfig.Classify.Awareness) then
            self.TxtConsumeWhat.text = CsXTextManagerGetText("AwarenessStrengthenTitle")
            self.TogConsumeType:SetNameByGroup(0, CsXTextManagerGetText("TypeWafer"))
        end
    end
end

function XUiEquipResonanceSelect:InitRightView()
    local equipId = self.EquipId

    --专属装备自动选择共鸣绑定角色
    local equipSpecialCharacterId = XDataCenter.EquipManager.GetEquipSpecialCharacterId(equipId)
    if equipSpecialCharacterId and equipSpecialCharacterId > 0 then
        self.SelectCharacterId = equipSpecialCharacterId
        self.PanelCharacter.gameObject:SetActive(true)
    else
        --五星以上才可以选择共鸣绑定角色
        if XDataCenter.EquipManager.CanResonanceBindCharacter(equipId) then
            local wearingCharacterId = XDataCenter.EquipManager.GetEquipWearingCharacterId(equipId)
            self.SelectCharacterId = wearingCharacterId
            self.PanelCharacter.gameObject:SetActive(true)
        else
            self.PanelCharacter.gameObject:SetActive(false)
        end
    end

    local clickCb = function()
        self:OnBtnSelectAwarenessClick()
    end
    self.CurEquipGird = self.CurEquipGird or XUiGridEquip.New(self.GridCurAwareness, clickCb)
    self.CurEquipGird:InitRootUi(self)

    local consumeItemId = XDataCenter.EquipManager.GetResonanceConsumeItemId(equipId)
    self.CurItemGird = self.CurItemGird or XUiGridCommon.New(self, self.GridCurItem)
    self.CurItemGird:Refresh(consumeItemId)
end

function XUiEquipResonanceSelect:UpdateCurEquipGrid()
    if not self.SelectEquipId then
        self.CurItemGird.GameObject:SetActive(false)
        self.CurEquipGird.GameObject:SetActive(false)
        self.PanelNoAwareness.gameObject:SetActive(true)
        return
    end
    self.CurEquipGird:Refresh(self.SelectEquipId)
    self.CurEquipGird.GameObject:SetActive(true)
    self.CurItemGird.GameObject:SetActive(false)
    self.PanelNoAwareness.gameObject:SetActive(false)
end

function XUiEquipResonanceSelect:UpdateCurItemGrid()
    self.CurEquipGird.GameObject:SetActive(false)
    self.CurItemGird.GameObject:SetActive(true)
    self.PanelNoAwareness.gameObject:SetActive(false)
end

function XUiEquipResonanceSelect:UpdateCurCharacter()
    if not self.SelectCharacterId then
        self.PanelCurCharacter.gameObject:SetActive(false)
        self.PanelNoCharacter.gameObject:SetActive(true)
    else
        self.PanelCurCharacter.gameObject:SetActive(true)
        self.PanelNoCharacter.gameObject:SetActive(false)

        self.RImgHead:SetRawImage(XDataCenter.CharacterManager.GetCharSmallHeadIcon(self.SelectCharacterId))
    end
end

function XUiEquipResonanceSelect:UpdateResonanceSkill()
    self.TxtSlot.text = self.Pos
    if XDataCenter.EquipManager.CheckEquipPosResonanced(self.EquipId, self.Pos) then
        if not self.ResonanceSkillGrid then
            self.ResonanceSkillGrid = XUiGridResonanceSkill.New(self.GridResonanceSkill, self.EquipId, self.Pos)
        end

        self.ResonanceSkillGrid:SetEquipIdAndPos(self.EquipId, self.Pos)
        self.ResonanceSkillGrid:Refresh()
        self.ResonanceSkillGrid.GameObject:SetActive(true)
        self.TxtNoAwareness.gameObject:SetActive(false)
    else
        if self.ResonanceSkillGrid then
            self.ResonanceSkillGrid.GameObject:SetActive(false)
        end
        self.TxtNoAwareness.gameObject:SetActive(true)
    end
end

function XUiEquipResonanceSelect:UpdateResonanceConsumeItem()
    local itemId = XDataCenter.EquipManager.GetResonanceConsumeItemId(self.EquipId)
    if not itemId then return end

    local consumeItemInfo = {}
    consumeItemInfo.TemplateId = itemId
    consumeItemInfo.Count = XDataCenter.ItemManager.GetCount(itemId)

    self.ConsumeItem = self.ConsumeItem or XUiGridCommon.New(self, self.GridConsumeItem)
    self.ConsumeItem:Refresh(consumeItemInfo)
end

function XUiEquipResonanceSelect:UpdateBtnStatus()
    if self.SelectCharacterId then
        self.BtnSkillPreview.gameObject:SetActive(true)
    else
        self.BtnSkillPreview.gameObject:SetActive(false)
    end

    --一定要选择一个装备消耗
    if self.TabConsumeType == TabConsumeType.Equip and not self.SelectEquipId then
        self.BtnResonance:SetDisable(true, false)
    else
        --五星以上才可以选择共鸣绑定角色
        if not XDataCenter.EquipManager.CanResonanceBindCharacter(self.EquipId) or self.SelectCharacterId then
            self.BtnResonance:SetDisable(false)
        else
            self.BtnResonance:SetDisable(true, false)
        end
    end

    --物品不足时不可切换至消耗物品
    if not XDataCenter.EquipManager.CheckResonanceConsumeItemEnough(self.EquipId) then
        self.TogConsumeType:SetDisable(true)
    else
        local lastState = self.TogConsumeType.ButtonState
        self.TogConsumeType:SetDisable(false)
        self.TogConsumeType:SetButtonState(lastState)
    end
end

function XUiEquipResonanceSelect:AutoAddListener()
    self:RegisterClickEvent(self.BtnSkillPreview, self.OnBtnSkillPreviewClick)
    self:RegisterClickEvent(self.BtnSelectCharacter, self.OnBtnSelectCharacterClick)
    self:RegisterClickEvent(self.BtnCharacterClick, self.OnBtnCharacterClickClick)
    self:RegisterClickEvent(self.BtnSelectAwareness, self.OnBtnSelectAwarenessClick)
    self:RegisterClickEvent(self.BtnHelp, self.OnBtnHelpClick)
    self.BtnResonance.CallBack = function() self:OnBtnResonanceClick() end
    self.TogConsumeType.CallBack = function(value) self:OnTogConsumeTypeClick(value, true) end
end

function XUiEquipResonanceSelect:OnBtnCharacterClickClick()
    local equipSpecialCharacterId = XDataCenter.EquipManager.GetEquipSpecialCharacterId(self.EquipId)
    if equipSpecialCharacterId and equipSpecialCharacterId > 0 then
        XUiManager.TipText("EquipIsBindCharacter")
        return
    end

    self:OnBtnSelectCharacterClick()
end

function XUiEquipResonanceSelect:OnBtnResonanceClick()
    local useItem = self.TabConsumeType == TabConsumeType.Item
    XDataCenter.EquipManager.Resonance(self.EquipId, self.Pos, self.SelectCharacterId, self.SelectEquipId, useItem)
end

function XUiEquipResonanceSelect:OnBtnSkillPreviewClick()
    XLuaUiManager.Open("UiEquipResonanceSkillPreview", self)
end

function XUiEquipResonanceSelect:OnBtnSelectCharacterClick()
    local confirmCb = function(selectCharacterId)
        self.SelectCharacterId = selectCharacterId
        self:UpdateBtnStatus()
        self:UpdateCurCharacter()
    end
    self.RootUi:OpenChildUi("UiEquipResonanceSelectCharacter", self.EquipId, confirmCb)
end

function XUiEquipResonanceSelect:OnBtnSelectAwarenessClick()
    local confirmCb = function(selectEquipId)
        self.SelectEquipId = selectEquipId
        self:UpdateBtnStatus()
        self:OnTogConsumeTypeClick(self.TabConsumeType)
    end
    self.RootUi:OpenChildUi("UiEquipResonanceSelectEquip", self.EquipId, confirmCb)
end

function XUiEquipResonanceSelect:OnBtnHelpClick()
    XUiManager.UiFubenDialogTip(self.DescriptionTitle, self.Description)
end

function XUiEquipResonanceSelect:OnTogConsumeTypeClick(value, doTip)
    if value == TabConsumeType.Equip then
        self:UpdateCurEquipGrid()
    elseif value == TabConsumeType.Item then
        if not XDataCenter.EquipManager.CheckResonanceConsumeItemEnough(self.EquipId) then
            if doTip then
                XUiManager.TipText("EquipResonanceConsumeItemLack")
            end
            return 
        end
        self:UpdateCurItemGrid()
    end
    
    self.TabConsumeType = value
    self:UpdateConsumeTxt()
    self:UpdateBtnStatus()
end