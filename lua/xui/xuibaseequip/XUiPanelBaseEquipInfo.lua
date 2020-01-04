local XUiPanelBaseEquipInfo = XClass()

function XUiPanelBaseEquipInfo:Ctor(ui, rootUI)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUI
    self:InitAutoScript()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelBaseEquipInfo:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiPanelBaseEquipInfo:AutoInitUi()
    self.BtnOk = self.Transform:Find("BtnOk"):GetComponent("Button")
    self.BtnGet = self.Transform:Find("BtnGet"):GetComponent("Button")
    self.ImgQuality = self.Transform:Find("ImgQuality"):GetComponent("Image")
    self.RImgIcon = self.Transform:Find("RImgIcon"):GetComponent("RawImage")
    self.TxtName = self.Transform:Find("TxtName"):GetComponent("Text")
    self.PanelShowAttr1 = self.Transform:Find("PanelShowAttr1")
    self.TxtAttrTitle1 = self.Transform:Find("PanelShowAttr1/TxtAttrTitle1"):GetComponent("Text")
    self.TxtAttr1 = self.Transform:Find("PanelShowAttr1/TxtAttr1"):GetComponent("Text")
    self.PanelShowAttr2 = self.Transform:Find("PanelShowAttr2")
    self.TxtAttrTitle2 = self.Transform:Find("PanelShowAttr2/TxtAttrTitle2"):GetComponent("Text")
    self.TxtAttr2 = self.Transform:Find("PanelShowAttr2/TxtAttr2"):GetComponent("Text")
    self.TxtStar = self.Transform:Find("TxtStar"):GetComponent("Text")
    self.TxtLevelLimit = self.Transform:Find("TxtLevelLimit"):GetComponent("Text")
    self.TxtPartB = self.Transform:Find("TxtPart"):GetComponent("Text")
    self.TxtDescB = self.Transform:Find("TxtDesc"):GetComponent("Text")
    self.TxtType = self.Transform:Find("TxtType"):GetComponent("Text")
end

function XUiPanelBaseEquipInfo:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelBaseEquipInfo:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelBaseEquipInfo:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelBaseEquipInfo:AutoAddListener()
    self:RegisterClickEvent(self.BtnOk, self.OnBtnOkClick)
    self:RegisterClickEvent(self.BtnGet, self.OnBtnGetClick)
end
-- auto

function XUiPanelBaseEquipInfo:ShowPanel(equip)
    self.CurEquip = equip
    local template = XDataCenter.BaseEquipManager.GetBaseEquipTemplate(equip.TemplateId)
    local showInfo = XDataCenter.BaseEquipManager.GetEvaluatedAttribShowInfo(equip.Id)

    if showInfo then
        local attriDescList = showInfo.AttriDescList
        if attriDescList then
            local index = 1
            for _, descInfo in pairs(attriDescList) do
                if not self["TxtAttrTitle" .. index] then
                    break
                end
                self["TxtAttrTitle" .. index].text = descInfo.Name
                self["TxtAttr" .. index].text = descInfo.Value
                index = index + 1
            end
        end
    end

    if self.RImgIcon and template.Icon then
        self.RImgIcon:SetRawImage(template.Icon)
    end

    if self.ImgQuality and template.Quality then
        self.RootUi:SetUiSprite(self.ImgQuality, XArrangeConfigs.GeQualityBgPath(template.Quality))
    end

    if self.TxtStar and template.Star then
        self.TxtStar.text = template.Star
    end

    if self.TxtName and template.Name then
        self.TxtName.text = template.Name
    end

    if self.TxtLevelLimit and template.Level then
        self.TxtLevelLimit.text = template.Level
    end

    if self.TxtDescB and template.Description then
        self.TxtDescB.text = template.Description
    end

    if self.TxtPartB and self.TxtType then
        self.TxtPartB.text = template.Part
        local curType = math.ceil(template.Part /2)
        self.TxtType.text = CS.XTextManager.GetText("BaseEquipType" .. curType)
    end

    self.GameObject:SetActive(true)
end

function XUiPanelBaseEquipInfo:HidePanel()
    self.GameObject:SetActive(false)
end

function XUiPanelBaseEquipInfo:OnBtnOkClick(eventData)
    self:HidePanel()
end

function XUiPanelBaseEquipInfo:OnBtnGetClick(eventData)
    XLuaUiManager.Open("UiSkip", self.CurEquip.TemplateId)
end

return XUiPanelBaseEquipInfo
