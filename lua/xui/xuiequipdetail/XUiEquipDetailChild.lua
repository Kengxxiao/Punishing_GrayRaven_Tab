
local CsXTextManager = CS.XTextManager

local MAX_AWARENESS_ATTR_COUNT = 2 --不包括共鸣属性，最大有2条
local XUiGridResonanceSkill = require("XUi/XUiEquipResonanceSkill/XUiGridResonanceSkill")

local XUiEquipDetailChild = XLuaUiManager.Register(XLuaUi, "UiEquipDetailChild")

XUiEquipDetailChild.BtnTabIndex = {
    SuitSkill = 1,
    ResonanceSkill = 2,
}

function XUiEquipDetailChild:OnAwake()
    self:InitAutoScript()

    local tabGroupList = {
        self.BtnSuitSkill,
        self.BtnResonanceSkill,
    }
    self.TabGroupRight:Init(tabGroupList, function(tabIndex) self:OnClickTabCallBack(tabIndex) end)
end

function XUiEquipDetailChild:OnStart(equipId, isPreview)
    self.IsPreview = isPreview
    self.EquipId = equipId
    self.TemplateId = isPreview and self.EquipId or XDataCenter.EquipManager.GetEquipTemplateId(equipId)
    self.GridResonanceSkills = {}

    self:InitTabBtns()
    self:InitClassifyPanel()
    self:InitEquipInfo()
end

function XUiEquipDetailChild:OnEnable()
    self:UpdateEquipAttr()
    self:UpdateEquipLevel()
    self:UpdateEquipBreakThrough()
    self:UpdateEquipLock()
    self:UpdateEquipSkillDes()
    self:UpdateResonanceSkills()
end

function XUiEquipDetailChild:OnGetEvents()
    return { XEventId.EVENT_EQUIP_STRENGTHEN_NOTYFY, XEventId.EVENT_EQUIP_LOCK_STATUS_CHANGE_NOTYFY }
end

function XUiEquipDetailChild:OnNotify(evt, ...)
    local args = { ... }
    local equipId = args[1]
    if self.IsPreview or equipId ~= self.EquipId then return end

    if evt == XEventId.EVENT_EQUIP_STRENGTHEN_NOTYFY then
        self:UpdateEquipLevel()
        self:UpdateEquipAttr()
    elseif evt == XEventId.EVENT_EQUIP_LOCK_STATUS_CHANGE_NOTYFY then
        self:UpdateEquipLock()
    elseif evt == XEventId.EVENT_EQUIP_BREAKTHROUGH_NOTYFY then
        self:UpdateEquipBreakThrough()
    end
end

function XUiEquipDetailChild:OnClickTabCallBack(tabIndex)
    if tabIndex == XUiEquipDetailChild.BtnTabIndex.SuitSkill then
        self.PanelSuitSkill.gameObject:SetActive(true)
        self.PanelResonanceSkill.gameObject:SetActive(false)
        self:UpdateEquipSkillDes()
        self:PlayAnimation("SuitSkill")
    elseif tabIndex == XUiEquipDetailChild.BtnTabIndex.ResonanceSkill then
        if not XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.EquipResonance) then
            return
        end
        self.PanelSuitSkill.gameObject:SetActive(false)
        self.PanelResonanceSkill.gameObject:SetActive(true)
        self:UpdateResonanceSkills()
        self:PlayAnimation("ResonanceSkill")
    end
end

function XUiEquipDetailChild:InitTabBtns()
    if not XDataCenter.EquipManager.CanResonanceByTemplateId(self.TemplateId) then
        self.BtnResonanceSkill.gameObject:SetActive(false)
        self.BtnSuitSkill.gameObject:SetActive(false)
        return
    end

    self.BtnResonanceSkill:SetDisable(not XFunctionManager.JudgeCanOpen(XFunctionManager.FunctionName.EquipResonance))
    self.TabGroupRight:SelectIndex(XUiEquipDetailChild.BtnTabIndex.SuitSkill)
end

function XUiEquipDetailChild:InitClassifyPanel()
    if XDataCenter.EquipManager.IsClassifyEqualByTemplateId(self.TemplateId, XEquipConfig.Classify.Weapon) then
        self.TxtTitle.text = CsXTextManager.GetText("WeaponDetailTitle")
        self.PanelPainter.gameObject:SetActive(false)
    else
        local breakthroughTimes = not self.IsPreview and XDataCenter.EquipManager.GetBreakthroughTimes(self.EquipId) or 0
        self.TxtPainter.text = XDataCenter.EquipManager.GetEquipPainterName(self.TemplateId, breakthroughTimes)
        self.PanelPainter.gameObject:SetActive(true)
        self.TxtTitle.text = CsXTextManager.GetText("AwarenessDetailTitle")
    end
end

function XUiEquipDetailChild:UpdateEquipSkillDes()
    if XDataCenter.EquipManager.IsClassifyEqualByTemplateId(self.TemplateId, XEquipConfig.Classify.Weapon) then
        local weaponSkillInfo = XDataCenter.EquipManager.GetOriginWeaponSkillInfo(self.TemplateId)
        local noWeaponSkill = not weaponSkillInfo.Name and not weaponSkillInfo.Description

        self.TxtSkillName.text = weaponSkillInfo.Name
        self.TxtSkillDes.text = weaponSkillInfo.Description

        self.PanelAwarenessSkillDes.gameObject:SetActive(false)
        self.PanelNoAwarenessSkill.gameObject:SetActive(false)
        self.PanelWeaponSkillDes.gameObject:SetActive(not noWeaponSkill)
        self.PanelNoWeaponSkill.gameObject:SetActive(noWeaponSkill)
    elseif XDataCenter.EquipManager.IsClassifyEqualByTemplateId(self.TemplateId, XEquipConfig.Classify.Awareness) then
        local suitId = XDataCenter.EquipManager.GetSuitIdByTemplateId(self.TemplateId)
        local skillDesList = XDataCenter.EquipManager.GetSuitSkillDesList(suitId)

        local noSuitSkill = true
        for i = 1, XEquipConfig.MAX_SUIT_SKILL_COUNT do
            if skillDesList[i * 2] then
                self["TxtSkillDes" .. i].text = skillDesList[i * 2]
                self["TxtSkillDes" .. i].gameObject:SetActive(true)
                noSuitSkill = false
            else
                self["TxtSkillDes" .. i].gameObject:SetActive(false)
            end
        end
        
        self.PanelNoAwarenessSkill.gameObject:SetActive(noSuitSkill)
        self.PanelAwarenessSkillDes.gameObject:SetActive(not noSuitSkill)
        self.PanelWeaponSkillDes.gameObject:SetActive(false)
        self.PanelNoWeaponSkill.gameObject:SetActive(false)
    end
end

function XUiEquipDetailChild:UpdateEquipLock()
    if self.IsPreview then
        self.BtnUnlock.gameObject:SetActive(false)
        self.BtnLock.gameObject:SetActive(false)
        return
    end

    local isLock = XDataCenter.EquipManager.IsLock(self.EquipId)
    self.BtnUnlock.gameObject:SetActive(not isLock)
    self.BtnLock.gameObject:SetActive(isLock)
end

function XUiEquipDetailChild:UpdateEquipLevel()
    local level, levelLimit
    local equipId = self.EquipId

    if self.IsPreview then
        level = 1
        levelLimit = XDataCenter.EquipManager.GetBreakthroughLevelLimitByTemplateId(self.TemplateId)
        self.PanelMaxLevel.gameObject:SetActive(false)
    else
        local equip = XDataCenter.EquipManager.GetEquip(equipId)
        level = equip.Level
        levelLimit = XDataCenter.EquipManager.GetBreakthroughLevelLimit(equipId)
        self.PanelMaxLevel.gameObject:SetActive(XDataCenter.EquipManager.IsMaxLevel(equipId) and not XDataCenter.EquipManager.CanBreakThrough(equipId))
    end

    if level and levelLimit then
        self.TxtLevel.text = CsXTextManager.GetText("EquipLevelText", level, levelLimit)
    end
end

function XUiEquipDetailChild:UpdateEquipBreakThrough()
    if self.IsPreview then
        self:SetUiSprite(self.ImgBreakThrough, XEquipConfig.GetEquipBreakThroughIcon(0))
        return
    end

    self:SetUiSprite(self.ImgBreakThrough, XDataCenter.EquipManager.GetEquipBreakThroughIcon(self.EquipId))
end

function XUiEquipDetailChild:InitEquipInfo()
    local star = XDataCenter.EquipManager.GetEquipStar(self.TemplateId)
    for i = 1, XEquipConfig.MAX_STAR_COUNT do
        if i <= star then
            self["ImgStar" .. i].gameObject:SetActive(true)
        else
            self["ImgStar" .. i].gameObject:SetActive(false)
        end
    end

    self.TxtEquipName.text = XDataCenter.EquipManager.GetEquipName(self.TemplateId)

    local equipSite = XDataCenter.EquipManager.GetEquipSiteByTemplateId(self.TemplateId)
    if equipSite ~= XEquipConfig.EquipSite.Weapon then
        local breakthrough = 0
        if not self.IsPreview then
            local equip = XDataCenter.EquipManager.GetEquip(self.EquipId)
            breakthrough = equip.Breakthrough
        end
        self.RImgIcon:SetRawImage(XDataCenter.EquipManager.GetEquipIconBagPath(self.TemplateId, breakthrough))
        self.TxtPos.text = "0" .. equipSite
        self.PanelPos.gameObject:SetActive(true)
        self.RImgType.gameObject:SetActive(false)
    else
        self.RImgType:SetRawImage(XEquipConfig.GetWeaponTypeIconPath(self.TemplateId))
        self.RImgType.gameObject:SetActive(true)
        self.PanelPos.gameObject:SetActive(false)
    end

    local equipSpecialCharacterId = XDataCenter.EquipManager.GetEquipSpecialCharacterIdByTemplateId(self.TemplateId)
    if equipSpecialCharacterId then
        self.RImgHead:SetRawImage(XDataCenter.CharacterManager.GetCharSmallHeadIcon(equipSpecialCharacterId))
        self.PanelSpecialCharacter.gameObject:SetActive(true)
    else
        self.PanelSpecialCharacter.gameObject:SetActive(false)
    end
end

function XUiEquipDetailChild:UpdateEquipAttr()
    local attrMap = {}

    if self.IsPreview then
        attrMap = XDataCenter.EquipManager.GetTemplateEquipAttrMap(self.EquipId)
    else
        attrMap = XDataCenter.EquipManager.GetEquipAttrMap(self.EquipId)
    end

    local attrCount = 1
    for _, attrInfo in pairs(attrMap) do
        if attrCount > MAX_AWARENESS_ATTR_COUNT then break end
        self["TxtName" .. attrCount].text = attrInfo.Name
        self["TxtAttr" .. attrCount].text = attrInfo.Value
        self["PanelAttr" .. attrCount].gameObject:SetActive(true)
        attrCount = attrCount + 1
    end
    for i = attrCount, MAX_AWARENESS_ATTR_COUNT do
        self["PanelAttr" .. i].gameObject:SetActive(false)
    end
end

function XUiEquipDetailChild:UpdateResonanceSkills()
    local count = 1
    local resonanceSkillNum = XDataCenter.EquipManager.GetResonanceSkillNumByTemplateId(self.TemplateId)
    for pos = 1, resonanceSkillNum do
        self["PanelSkill" .. pos].gameObject:SetActive(true)
        self["PanelEmptySkill" .. pos].gameObject:SetActive(true)
        count = count + 1
        self:UpdateResonanceSkill(pos)
    end
    for pos = count, XEquipConfig.MAX_RESONANCE_SKILL_COUNT do
        self["PanelSkill" .. pos].gameObject:SetActive(false)
    end
end

function XUiEquipDetailChild:UpdateResonanceSkill(pos)
    if self.IsPreview then return end
    if XDataCenter.EquipManager.CheckEquipPosResonanced(self.EquipId, pos) then
        local grid = self.GridResonanceSkills[pos]
        if not grid then
            local item = CS.UnityEngine.Object.Instantiate(self.GridResonanceSkill)
            grid = XUiGridResonanceSkill.New(item, self.EquipId, pos)
            grid.Transform:SetParent(self["PanelSkill" .. pos], false)
            self.GridResonanceSkills[pos] = grid
        end

        grid:Refresh()
        grid.GameObject:SetActive(true)
        self["PanelEmptySkill" .. pos].gameObject:SetActive(false)
    else
        if grid then
            grid.GameObject:SetActive(false)
        end
    end
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiEquipDetailChild:InitAutoScript()
    self:AutoAddListener()
end

function XUiEquipDetailChild:AutoAddListener()
    self:RegisterClickEvent(self.BtnLock, self.OnBtnLockClick)
    self:RegisterClickEvent(self.BtnUnlock, self.OnBtnUnlockClick)
end
-- auto

function XUiEquipDetailChild:OnBtnLockClick(eventData)
    XDataCenter.EquipManager.SetLock(self.EquipId, false)
end

function XUiEquipDetailChild:OnBtnUnlockClick(eventData)
    XDataCenter.EquipManager.SetLock(self.EquipId, true)
end