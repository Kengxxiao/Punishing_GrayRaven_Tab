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

function XUiEquipAwarenessPopup:OnStart(rootUi, notShowStrengthenBtn)
    self.RootUi = rootUi    --子窗口在隐藏/显示时无法再次调到onstart
    self.NotShowStrengthenBtn = notShowStrengthenBtn or false
    self.PanelSelectRectTransform = self.PanelSelect:GetComponent("RectTransform")
end

function XUiEquipAwarenessPopup:OnEnable()
    self:Refresh()
    if self.RootUi.BtnClosePopup then
        self.RootUi.BtnClosePopup.gameObject:SetActive(true)
    end
end

function XUiEquipAwarenessPopup:OnDisable()
    if self.RootUi.BtnClosePopup then
        self.RootUi.BtnClosePopup.gameObject:SetActive(false)
    end
end

function XUiEquipAwarenessPopup:Refresh()
    local equipSite = XDataCenter.EquipManager.GetEquipSite(self.RootUi.SelectEquipId)
    self.UsingEquipId = XDataCenter.EquipManager.GetWearingEquipIdBySite(self.RootUi.CharacterId, equipSite)
    self.UsingAttrMap = XDataCenter.EquipManager.GetEquipAttrMap(self.UsingEquipId)

    self:UpdateSelectPanel()
    self:UpdateUsingPanel()
    self:UpdateUsingPanelBtn()
    self:UpdateLockStatues(self.RootUi.SelectEquipId)
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
            if equipId == self.RootUi.SelectEquipId then
                self:Close()
                return
            end
        end
    elseif evt == XEventId.EVENT_EQUIP_LOCK_STATUS_CHANGE_NOTYFY then
        local equipId = args[1]
        if equipId ~= self.RootUi.SelectEquipId then return end
        self:UpdateLockStatues(equipId)
    end
end

function XUiEquipAwarenessPopup:UpdateLockStatues(equipId)
    if not equipId then return end
    local isLock = XDataCenter.EquipManager.IsLock(equipId)

    if equipId == self.RootUi.SelectEquipId then
        self.BtnLockSelect.gameObject:SetActive(isLock)
        self.BtnUnlockSelect.gameObject:SetActive(not isLock)
    end
end

function XUiEquipAwarenessPopup:UpdateSelectPanel()
    if not self.SelectEquipGrid then
        self.SelectEquipGrid = XUiGridEquip.New(self.GridEquipSelect)
        self.SelectEquipGrid:InitRootUi(self)
    end
    self.SelectEquipGrid:Refresh(self.RootUi.SelectEquipId)

    local equip = XDataCenter.EquipManager.GetEquip(self.RootUi.SelectEquipId)
    self.TxtNameA.text = XDataCenter.EquipManager.GetEquipName(equip.TemplateId)

    local attrCount = 1
    local attrMap = XDataCenter.EquipManager.GetEquipAttrMap(self.RootUi.SelectEquipId)
    for attrIndex, attrInfo in pairs(attrMap) do
        if attrCount > MAX_AWARENESS_ATTR_COUNT then break end

        local usingAttr = self.UsingAttrMap[attrIndex]
        local usingAttrValue = usingAttr and usingAttr.Value or 0
        local selectAttrValue = attrInfo.Value
        if selectAttrValue > usingAttrValue then
            self["TxtSelectAttrValue" .. attrCount].color = ATTR_COLOR.OVER
            self["ImgArrowUpSelect" .. attrCount].gameObject:SetActive(true)
            self["ImgArrowDownSelect" .. attrCount].gameObject:SetActive(false)
        elseif selectAttrValue == usingAttrValue then
            self["TxtSelectAttrValue" .. attrCount].color = ATTR_COLOR.EQUAL
            self["ImgArrowUpSelect" .. attrCount].gameObject:SetActive(false)
            self["ImgArrowDownSelect" .. attrCount].gameObject:SetActive(false)
        else
            self["TxtSelectAttrValue" .. attrCount].color = ATTR_COLOR.BELOW
            self["ImgArrowUpSelect" .. attrCount].gameObject:SetActive(false)
            self["ImgArrowDownSelect" .. attrCount].gameObject:SetActive(true)
        end
        self["TxtSelectAttrName" .. attrCount].text = attrInfo.Name
        self["TxtSelectAttrValue" .. attrCount].text = selectAttrValue
        self["PanelSelectAttr" .. attrCount].gameObject:SetActive(true)

        attrCount = attrCount + 1
    end
    for i = attrCount, MAX_AWARENESS_ATTR_COUNT do
        self["PanelSelectAttr" .. i].gameObject:SetActive(false)
    end

    --是否激活颜色不同
    local suitId = XDataCenter.EquipManager.GetSuitId(equip.Id)
    local activeEquipsCount = XDataCenter.EquipManager.GetActiveSuitEquipsCount(self.RootUi.CharacterId, suitId)
    local skillDesList = XDataCenter.EquipManager.GetSuitActiveSkillDesList(suitId, activeEquipsCount)
    for i = 1, XEquipConfig.MAX_SUIT_SKILL_COUNT do
        local componentText = self["TxtSkillDesA" .. i]
        if not skillDesList[i] then
            componentText.gameObject:SetActive(false)
        else
            local color = SKILL_DES_COLOR[skillDesList[i].IsActive]
            componentText.text = skillDesList[i].SkillDes
            componentText.gameObject:SetActive(true)
            componentText.color = color
            self["TxtPosA" .. i].color = color
        end
    end

    --修正弹窗位置
    if self.RootUi.NeedFixPopUpPos and (not self.UsingEquipId or self.UsingEquipId == self.RootUi.SelectEquipId) then
        local equipSite = XDataCenter.EquipManager.GetEquipSite(self.RootUi.SelectEquipId)
        self.PanelSelectRectTransform.anchoredPosition = CUR_EQUIP_CLICK_POPUP_POS[equipSite]
    else
        self.PanelSelectRectTransform.anchoredPosition = CUR_EQUIP_CLICK_POPUP_POS[XEquipConfig.EquipSite.Awareness.One]
    end

    self.BtnStrengthen.gameObject:SetActive(not self.NotShowStrengthenBtn)

    CS.UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(self.PanelContentA)
end

function XUiEquipAwarenessPopup:UpdateUsingPanel()
    if not self.UsingEquipId or self.UsingEquipId == self.RootUi.SelectEquipId then
        self.PanelUsing.gameObject:SetActive(false)
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
        self["PanelUsingAttr" .. attrCount].gameObject:SetActive(true)

        attrCount = attrCount + 1
    end
    for i = attrCount, MAX_AWARENESS_ATTR_COUNT do
        self["PanelUsingAttr" .. i].gameObject:SetActive(false)
    end

    --是否激活颜色不同
    local suitId = XDataCenter.EquipManager.GetSuitId(equip.Id)
    local activeEquipsCount = XDataCenter.EquipManager.GetActiveSuitEquipsCount(self.RootUi.CharacterId, suitId)
    local skillDesList = XDataCenter.EquipManager.GetSuitActiveSkillDesList(suitId, activeEquipsCount)

    for i = 1, XEquipConfig.MAX_SUIT_SKILL_COUNT do
        local componentText = self["TxtSkillDes" .. i]
        if not skillDesList[i] then
            componentText.gameObject:SetActive(false)
        else
            local color = SKILL_DES_COLOR[skillDesList[i].IsActive]
            componentText.text = skillDesList[i].SkillDes
            componentText.gameObject:SetActive(true)
            componentText.color = color
            self["TxtPos" .. i].color = color
        end
    end

    --去掉穿戴中装备的锁按钮
    self.BtnLockUsing.gameObject:SetActive(false)
    self.BtnUnlockUsing.gameObject:SetActive(false)

    self.PanelUsing.gameObject:SetActive(true)

    CS.UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(self.PanelContent)
end

function XUiEquipAwarenessPopup:UpdateUsingPanelBtn()
    if self.UsingEquipId and self.UsingEquipId == self.RootUi.SelectEquipId then
        self.BtnPutOn.gameObject:SetActive(false)
        self.BtnTakeOff.gameObject:SetActive(true)
    else
        self.BtnPutOn.gameObject:SetActive(true)
        self.BtnTakeOff.gameObject:SetActive(false)
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
    XDataCenter.EquipManager.SetLock(self.RootUi.SelectEquipId, true)
end

function XUiEquipAwarenessPopup:OnBtnLockSelectClick(eventData)
    XDataCenter.EquipManager.SetLock(self.RootUi.SelectEquipId, false)
end

function XUiEquipAwarenessPopup:OnBtnLockUsingClick(eventData)
    XDataCenter.EquipManager.SetLock(self.UsingEquipId, false)
end

function XUiEquipAwarenessPopup:OnBtnUnlockUsingClick(eventData)
    XDataCenter.EquipManager.SetLock(self.UsingEquipId, true)
end

function XUiEquipAwarenessPopup:OnBtnStrengthenClick(eventData)
    XLuaUiManager.Open("UiEquipDetail", self.RootUi.SelectEquipId)
    self:Close()
end

function XUiEquipAwarenessPopup:OnBtnPutOnClick(eventData)
    XDataCenter.EquipManager.PutOn(self.RootUi.CharacterId, self.RootUi.SelectEquipId)
end

function XUiEquipAwarenessPopup:OnBtnTakeOffClick(eventData)
    XDataCenter.EquipManager.TakeOff({ self.RootUi.SelectEquipId })
end