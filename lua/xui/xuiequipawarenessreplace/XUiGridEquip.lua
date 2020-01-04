local XUiGridEquip = XClass()

function XUiGridEquip:Ctor(ui, clickCb, rootUi)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    self.ClickCb = clickCb
    self:InitAutoScript()
    self:SetSelected(false)

    XEventManager.AddEventListener(XEventId.EVENT_EQUIP_PUTON_NOTYFY, self.UpdateUsing, self)
    XEventManager.AddEventListener(XEventId.EVENT_EQUIP_TAKEOFF_NOTYFY, self.UpdateUsing, self)
    XEventManager.AddEventListener(XEventId.EVENT_EQUIP_LOCK_STATUS_CHANGE_NOTYFY, self.UpdateIsLock, self)
    XEventManager.AddEventListener(XEventId.EVENT_EQUIP_BREAKTHROUGH_NOTYFY, self.UpdateBreakthrough, self)
end

function XUiGridEquip:InitRootUi(rootUi)
    self.RootUi = rootUi
end

function XUiGridEquip:Refresh(equipId)
    self.EquipId = equipId
    local equip = XDataCenter.EquipManager.GetEquip(equipId)
    if not equip then
        return
    end
    
    local templateId = equip.TemplateId

    if self.RImgIcon and self.RImgIcon:Exist() then
        self.RImgIcon:SetRawImage(XDataCenter.EquipManager.GetEquipIconBagPath(templateId, equip.Breakthrough), nil, true)
    end

    --通用的横条品质色
    if self.ImgQuality then
        self.RootUi:SetUiSprite(self.ImgQuality, XDataCenter.EquipManager.GetEquipQualityPath(templateId))
    end

    --装备专用的竖条品质色
    if self.ImgEquipQuality then
        self.RootUi:SetUiSprite(self.ImgEquipQuality, XDataCenter.EquipManager.GetEquipBgPath(templateId))
    end

    if self.TxtName then
        self.TxtName.text = XDataCenter.EquipManager.GetEquipName(templateId)
    end

    if self.TxtLevel then
        self.TxtLevel.text = equip.Level
    end

    if self.PanelSite and self.TxtSite then
        local equipSite = XDataCenter.EquipManager.GetEquipSite(equipId)
        if equipSite and equipSite ~= XEquipConfig.EquipSite.Weapon then
            self.TxtSite.text = "0" .. equipSite
            self.PanelSite.gameObject:SetActive(true)
        else
            self.PanelSite.gameObject:SetActive(false)
        end
    end

    for i = 1, XEquipConfig.MAX_STAR_COUNT do
        if self["ImgGirdStar" .. i] then
            if i <= XDataCenter.EquipManager.GetEquipStar(templateId) then
                self["ImgGirdStar" .. i].transform.parent.gameObject:SetActive(true)
            else
                self["ImgGirdStar" .. i].transform.parent.gameObject:SetActive(false)
            end
        end
    end

    for i = 1, XEquipConfig.MAX_RESONANCE_SKILL_COUNT do
        local obj = self["ImgResonance" .. i]
        local set = obj and obj.gameObject:SetActive(XDataCenter.EquipManager.CheckEquipPosResonanced(equipId, i))
    end

    self:UpdateIsLock(equipId)
    self:UpdateUsing(equipId)
    self:UpdateBreakthrough(equipId)
end

function XUiGridEquip:SetSelected(status)
    if XTool.UObjIsNil(self.ImgSelect) then
        return
    end
    self.ImgSelect.gameObject:SetActive(status)
end

function XUiGridEquip:IsSelected()
    return not XTool.UObjIsNil(self.ImgSelect) and self.ImgSelect.gameObject.activeSelf
end

function XUiGridEquip:UpdateUsing(equipId)
    if equipId ~= self.EquipId then
        return
    end
    if XTool.UObjIsNil(self.PanelUsing) then
        return
    end
    self.PanelUsing.gameObject:SetActive(XDataCenter.EquipManager.IsWearing(self.EquipId))
end

function XUiGridEquip:UpdateIsLock(equipId)
    if equipId ~= self.EquipId then
        return
    end
    if XTool.UObjIsNil(self.ImgLock) then
        return
    end
    self.ImgLock.gameObject:SetActive(XDataCenter.EquipManager.IsLock(self.EquipId))
end

function XUiGridEquip:UpdateBreakthrough(equipId)
    if equipId ~= self.EquipId then
        return
    end
    if XTool.UObjIsNil(self.ImgBreakthrough) then
        return
    end

    local icon = XDataCenter.EquipManager.GetEquipBreakThroughSmallIcon(self.EquipId)
    if icon then
        self.RootUi:SetUiSprite(self.ImgBreakthrough, icon)
        self.ImgBreakthrough.gameObject:SetActive(true)
    else
        self.ImgBreakthrough.gameObject:SetActive(false)
    end
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiGridEquip:InitAutoScript()
    XTool.InitUiObject(self)
    self:AutoAddListener()
end

function XUiGridEquip:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiGridEquip:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiGridEquip:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiGridEquip:AutoAddListener()
    self:RegisterClickEvent(self.BtnClick, self.OnBtnClickClick)
end
-- auto
function XUiGridEquip:OnBtnClickClick(eventData)
    if self.ClickCb then
        self.ClickCb(self.EquipId, self)
    end
end

return XUiGridEquip