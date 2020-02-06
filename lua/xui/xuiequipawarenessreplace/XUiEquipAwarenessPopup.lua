local MAX_AWARENESS_ATTR_COUNT = 2

local SKILL_DES_COLOR = {
    [true] = XUiHelper.Hexcolor2Color("188649ff"),
    [false] = XUiHelper.Hexcolor2Color("00000099"),
}

local ATTR_COLOR = {
    BELOW = XUiHelper.Hexcolor2Color("d11e38ff"),
    EQUAL = XUiHelper.Hexcolor2Color("000000ff"),
    OVER = XUiHelper.Hexcolor2Color("188649ff"),
}

local CUR_EQUIP_CLICK_POPUP_POS = {
    [XEquipConfig.EquipSite.Awareness.One] = CS.UnityEngine.Vector2(-230, 14),
    [XEquipConfig.EquipSite.Awareness.Two] = CS.UnityEngine.Vector2(-681, 14),
    [XEquipConfig.EquipSite.Awareness.Three] = CS.UnityEngine.Vector2(-681, 14),
    [XEquipConfig.EquipSite.Awareness.Four] = CS.UnityEngine.Vector2(-230, 14),
    [XEquipConfig.EquipSite.Awareness.Five] = CS.UnityEngine.Vector2(-681, 14),
    [XEquipConfig.EquipSite.Awareness.Six] = CS.UnityEngine.Vector2(-681, 14),
}

local XUiGridEquip = require("XUi/XUiEquipAwarenessReplace/XUiGridEquip")

local XUiEquipAwarenessPopup = XLuaUiManager.Register(XLuaUi, "UiEquipAwarenessPopup")

function XUiEquipAwarenessPopup:OnAwake()
    self:AutoAddListener()
end

function XUiEquipAwarenessPopup:OnStart(rootUi, HideStrengthenBtn, equipId, charaterId, hideAllBtns)
    self.RootUi = rootUi    --子窗口在隐藏/显示时无法再次调到onstart
    self.InitEquipId = equipId
    self.InitCharacterId = charaterId
    self.HideStrengthenBtn = HideStrengthenBtn
    self.HideAllBtns = hideAllBtns
    self.PanelSelectRectTransform = self.PanelSelect:GetComponent("RectTransform")
end

function XUiEquipAwarenessPopup:OnEnable()
    self.EquipId = self.InitEquipId or self.RootUi.SelectEquipId
    self.CharacterId = self.InitCharacterId or self.RootUi.CharacterId

    self:Refresh()
    if self.RootUi.BtnClosePopup then
        self.RootUi.BtnClosePopup.gameObject:SetActiveEx(true)
    end
end

function XUiEquipAwarenessPopup:OnDisable()
    if self.RootUi.BtnClosePopup then
        self.RootUi.BtnClosePopup.gameObject:SetActiveEx(false)
    end
end

function XUiEquipAwarenessPopup:Refresh()
    local equipSite = XDataCenter.EquipManager.GetEquipSite(self.EquipId)
    self.UsingEquipId = XDataCenter.EquipManager.GetWearingEquipIdBySite(self.CharacterId, equipSite)
    self.UsingAttrMap = XDataCenter.EquipManager.GetEquipAttrMap(self.UsingEquipId)

    self:UpdateSelectPanel()
    self:UpdateUsingPanel()
    self:UpdateUsingPanelBtn()
    self:UpdateLockStatues(self.EquipId)
    self:UpdateLockStatues(self.UsingEquipId)
end

function XUiEquipAwarenessPopup:OnGetEvents()
    return { XEventId.EVENT_EQUIP_PUTON_NOTYFY, XEventId.EVENT_EQUIPLIST_TAKEOFF_NOTYFY, XEventId.EVENT_EQUIP_LOCK_STATUS_CHANGE_NOTYFY }
end

function XUiEquipAwarenessPopup:OnNotify(evt, ...)
    local args = { ... }

    if evt == XEventId.EVENT_EQUIP_PUTON_NOTYFY or evt == XEventId.EVENT_EQUIPLIST_TAKEOFF_NOTYFY then
        local equipIds = args[1]
        for _, equipId in pairs(equipIds) do
            if equipId == self.EquipId then
                self:Close()
                return
            end
        end
    elseif evt == XEventId.EVENT_EQUIP_LOCK_STATUS_CHANGE_NOTYFY then
        local equipId = args[1]
        if equipId ~= self.EquipId then return end
        self:UpdateLockStatues(equipId)
    end
end

function XUiEquipAwarenessPopup:UpdateLockStatues(equipId)
    if self.HideAllBtns then
        self.BtnLockSelect.gameObject:SetActiveEx(false)
        self.BtnUnlockSelect.gameObject:SetActiveEx(false)
        self.BtnLockUsing.gameObject:SetActiveEx(false)
        self.BtnUnlockUsing.gameObject:SetActiveEx(false)
        return
    end

    if not equipId then return end

    local isLock = XDataCenter.EquipManager.IsLock(equipId)
    if equipId == self.EquipId then
        self.BtnLockSelect.gameObject:SetActiveEx(isLock)
        self.BtnUnlockSelect.gameObject:SetActiveEx(not isLock)
    end
end

function XUiEquipAwarenessPopup:UpdateSelectPanel()
    if not self.SelectEquipGrid then
        self.SelectEquipGrid = XUiGridEquip.New(self.GridEquipSelect)
        self.SelectEquipGrid:InitRootUi(self)
    end
    self.SelectEquipGrid:Refresh(self.EquipId)

    local equip = XDataCenter.EquipManager.GetEquip(self.EquipId)
    self.TxtNameA.text = XDataCenter.EquipManager.GetEquipName(equip.TemplateId)

    local attrCount = 1
    local attrMap = XDataCenter.EquipManager.GetEquipAttrMap(self.EquipId)
    for attrIndex, attrInfo in pairs(attrMap) do
        if attrCount > MAX_AWARENESS_ATTR_COUNT then break end
        
        local usingAttr = self.UsingAttrMap[attrIndex]
        local usingAttrValue = usingAttr and usingAttr.Value or 0
        local selectAttrValue = attrInfo.Value
        if selectAttrValue > usingAttrValue then
            self["TxtSelectAttrValue" .. attrCount].color = ATTR_COLOR.OVER
            self["ImgArrowUpSelect" .. attrCount].gameObject:SetActiveEx(true)
            self["ImgArrowDownSelect" .. attrCount].gameObject:SetActiveEx(false)
        elseif selectAttrValue == usingAttrValue then
            self["TxtSelectAttrValue" .. attrCount].color = ATTR_COLOR.EQUAL
            self["ImgArrowUpSelect" .. attrCount].gameObject:SetActiveEx(false)
            self["ImgArrowDownSelect" .. attrCount].gameObject:SetActiveEx(false)
        else
            self["TxtSelectAttrValue" .. attrCount].color = ATTR_COLOR.BELOW
            self["ImgArrowUpSelect" .. attrCount].gameObject:SetActiveEx(false)
            self["ImgArrowDownSelect" .. attrCount].gameObject:SetActiveEx(true)
        end
        self["TxtSelectAttrName" .. attrCount].text = attrInfo.Name
        self["TxtSelectAttrValue" .. attrCount].text = selectAttrValue
        self["PanelSelectAttr" .. attrCount].gameObject:SetActiveEx(true)

        attrCount = attrCount + 1
    end
    for i = attrCount, MAX_AWARENESS_ATTR_COUNT do
        self["PanelSelectAttr" .. i].gameObject:SetActiveEx(false)
    end

    --是否激活颜色不同
    local suitId = XDataCenter.EquipManager.GetSuitId(equip.Id)
    local activeEquipsCount = XDataCenter.EquipManager.GetActiveSuitEquipsCount(self.CharacterId, suitId)
    local skillDesList = XDataCenter.EquipManager.GetSuitActiveSkillDesList(suitId, activeEquipsCount)
    for i = 1, XEquipConfig.MAX_SUIT_SKILL_COUNT do
        local componentText = self["TxtSkillDesA" .. i]
        if not skillDesList[i] then
            componentText.gameObject:SetActiveEx(false)
        else
            local color = SKILL_DES_COLOR[skillDesList[i].IsActive]
            componentText.text = skillDesList[i].SkillDes
            componentText.gameObject:SetActiveEx(true)
            componentText.color = color
            self["TxtPosA" .. i].color = color
        end
    end

    --修正弹窗位置
    if self.RootUi.NeedFixPopUpPos and (not self.UsingEquipId or self.UsingEquipId == self.EquipId) then
        local equipSite = XDataCenter.EquipManager.GetEquipSite(self.EquipId)
        self.PanelSelectRectTransform.anchoredPosition = CUR_EQUIP_CLICK_POPUP_POS[equipSite]
    else
        self.PanelSelectRectTransform.anchoredPosition = CUR_EQUIP_CLICK_POPUP_POS[XEquipConfig.EquipSite.Awareness.One]
    end

    self.BtnStrengthen.gameObject:SetActiveEx(not self.HideStrengthenBtn and not self.HideAllBtns)

    CS.UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(self.PanelContentA)
end

function XUiEquipAwarenessPopup:UpdateUsingPanel()
    if not self.UsingEquipId or self.UsingEquipId == self.EquipId then
        self.PanelUsing.gameObject:SetActiveEx(false)
        return
    end

    if not self.UsingEquipGrid then
        self.UsingEquipGrid = XUiGridEquip.New(self.GridEquipUsing)
        self.UsingEquipGrid:InitRootUi(self)
    end
    self.UsingEquipGrid:Refresh(self.UsingEquipId)

    local equip = XDataCenter.EquipManager.GetEquip(self.UsingEquipId)
    self.TxtName.text = XDataCenter.EquipManager.GetEquipName(equip.TemplateId)

    local attrCount = 1
    local attrMap = self.UsingAttrMap
    for _, attrInfo in pairs(attrMap) do
        if attrCount > MAX_AWARENESS_ATTR_COUNT then break end

        self["TxtUsingAttrName" .. attrCount].text = attrInfo.Name
        self["TxtUsingAttrValue" .. attrCount].text = attrInfo.Value
        self["PanelUsingAttr" .. attrCount].gameObject:SetActiveEx(true)
        
        attrCount = attrCount + 1
    end
    for i = attrCount, MAX_AWARENESS_ATTR_COUNT do
        self["PanelUsingAttr" .. i].gameObject:SetActiveEx(false)
    end

    --是否激活颜色不同
    local suitId = XDataCenter.EquipManager.GetSuitId(equip.Id)
    local activeEquipsCount = XDataCenter.EquipManager.GetActiveSuitEquipsCount(self.CharacterId, suitId)
    local skillDesList = XDataCenter.EquipManager.GetSuitActiveSkillDesList(suitId, activeEquipsCount)

    for i = 1, XEquipConfig.MAX_SUIT_SKILL_COUNT do
        local componentText = self["TxtSkillDes" .. i]
        if not skillDesList[i] then
            componentText.gameObject:SetActiveEx(false)
        else
            local color = SKILL_DES_COLOR[skillDesList[i].IsActive]
            componentText.text = skillDesList[i].SkillDes
            componentText.gameObject:SetActiveEx(true)
            componentText.color = color
            self["TxtPos" .. i].color = color
        end
    end

    --去掉穿戴中装备的锁按钮
    self.BtnLockUsing.gameObject:SetActiveEx(false)
    self.BtnUnlockUsing.gameObject:SetActiveEx(false)

    self.PanelUsing.gameObject:SetActiveEx(true)
    
    CS.UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(self.PanelContent)
end

function XUiEquipAwarenessPopup:UpdateUsingPanelBtn()
    if self.HideAllBtns then
        self.BtnPutOn.gameObject:SetActiveEx(false)
        self.BtnTakeOff.gameObject:SetActiveEx(false)
        return
    end

    if self.UsingEquipId and self.UsingEquipId == self.EquipId then
        self.BtnPutOn.gameObject:SetActiveEx(false)
        self.BtnTakeOff.gameObject:SetActiveEx(true)
    else
        self.BtnPutOn.gameObject:SetActiveEx(true)
        self.BtnTakeOff.gameObject:SetActiveEx(false)
    end
end

function XUiEquipAwarenessPopup:AutoAddListener()
    self:RegisterClickEvent(self.BtnLockUsing, self.OnBtnLockUsingClick)
    self:RegisterClickEvent(self.BtnUnlockUsing, self.OnBtnUnlockUsingClick)
    self:RegisterClickEvent(self.BtnStrengthen, self.OnBtnStrengthenClick)
    self:RegisterClickEvent(self.BtnPutOn, self.OnBtnPutOnClick)
    self:RegisterClickEvent(self.BtnTakeOff, self.OnBtnTakeOffClick)
    self:RegisterClickEvent(self.BtnLockSelect, self.OnBtnLockSelectClick)
    self:RegisterClickEvent(self.BtnUnlockSelect, self.OnBtnUnlockSelectClick)
end

function XUiEquipAwarenessPopup:OnBtnUnlockSelectClick(eventData)
    XDataCenter.EquipManager.SetLock(self.EquipId, true)
end

function XUiEquipAwarenessPopup:OnBtnLockSelectClick(eventData)
    XDataCenter.EquipManager.SetLock(self.EquipId, false)
end

function XUiEquipAwarenessPopup:OnBtnLockUsingClick(eventData)
    XDataCenter.EquipManager.SetLock(self.UsingEquipId, false)
end

function XUiEquipAwarenessPopup:OnBtnUnlockUsingClick(eventData)
    XDataCenter.EquipManager.SetLock(self.UsingEquipId, true)
end

function XUiEquipAwarenessPopup:OnBtnStrengthenClick(eventData)
    XLuaUiManager.Open("UiEquipDetail", self.EquipId)
    self:Close()
end

function XUiEquipAwarenessPopup:OnBtnPutOnClick(eventData)
    XDataCenter.EquipManager.PutOn(self.CharacterId, self.EquipId)
end

function XUiEquipAwarenessPopup:OnBtnTakeOffClick(eventData)
    XDataCenter.EquipManager.TakeOff({ self.EquipId })
end