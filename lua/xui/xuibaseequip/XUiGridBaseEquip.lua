local pairs = pairs

local XUiGridBaseEquip = XClass()

function XUiGridBaseEquip:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
    self:ResetUi()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiGridBaseEquip:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiGridBaseEquip:AutoInitUi()
    self.ImgSelect = XUiHelper.TryGetComponent(self.Transform, "ImgSelect", "Image")
    self.RImgIcon = XUiHelper.TryGetComponent(self.Transform, "RImgIcon", "RawImage")
    self.ImgQuality = XUiHelper.TryGetComponent(self.Transform, "ImgQuality", "Image")
    self.TxtStar = XUiHelper.TryGetComponent(self.Transform, "TxtStar", "Text")
    self.TxtName = XUiHelper.TryGetComponent(self.Transform, "TxtName", "Text")
    self.PanelAttrib1 = XUiHelper.TryGetComponent(self.Transform, "PanelAttrib1", nil)
    self.PanelAttrib2 = XUiHelper.TryGetComponent(self.Transform, "PanelAttrib2", nil)
    self.ImgPutOn = XUiHelper.TryGetComponent(self.Transform, "ImgPutOn", "Image")
    self.PanelRedPoint = XUiHelper.TryGetComponent(self.Transform, "PanelRedPoint", "Image")
    self.ImgRecycle = XUiHelper.TryGetComponent(self.Transform, "ImgRecycle", nil)
    self.ImgLevelLimit = XUiHelper.TryGetComponent(self.Transform, "ImgLevelLimit", "Image")
    self.TxtLevelLimit = XUiHelper.TryGetComponent(self.Transform, "TxtLevelLimit", "Text")
    self.TxtPart = XUiHelper.TryGetComponent(self.Transform, "TxtPart", "Text")
    self.TxtDesc = XUiHelper.TryGetComponent(self.Transform, "TxtDesc", "Text")
end

function XUiGridBaseEquip:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiGridBaseEquip:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiGridBaseEquip:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiGridBaseEquip:AutoAddListener()
    self.AutoCreateListeners = {}
end
-- auto

function XUiGridBaseEquip:SetUiActive(ui, active)
    if not ui or not ui.gameObject then
        return
    end

    if ui.gameObject.activeSelf == active then
        return
    end

    ui.gameObject:SetActive(active)
end

function XUiGridBaseEquip:ResetUi()
    self:SetUiActive(self.PanelAttrib1, false)
    self:SetUiActive(self.PanelAttrib2, false)
    self:SetUiActive(self.ImgSelect, false)
    self:SetUiActive(self.PanelRedPoint, false)
    self:SetUiActive(self.ImgPutOn, false)
end

function XUiGridBaseEquip:ShowPanelArrtib(panel, attribInfo)
    if not panel or not attribInfo then
        return
    end

    self:SetUiActive(XUiHelper.TryGetComponent(panel, "TxtNotEvaluated", "Text"), false)

    local txtName = XUiHelper.TryGetComponent(panel, "TxtAttribName", "Text")
    if txtName then
        txtName.text = attribInfo.Name
        self:SetUiActive(txtName, true)
    end

    local txtValue = XUiHelper.TryGetComponent(panel, "TxtAttribValue", "Text")
    if txtValue then
        txtValue.text = attribInfo.Value
        self:SetUiActive(txtValue, true)
    end

    self:SetUiActive(panel, true)
end

function XUiGridBaseEquip:ShowEvaluated(id)
    local info = XDataCenter.BaseEquipManager.GetEvaluatedAttribShowInfo(id)
    if not info then
        return
    end

    local attriDescList = info.AttriDescList
    if attriDescList then
        local index = 1
        for _, descInfo in pairs(attriDescList) do
            local panelAttrib = self["PanelAttrib" .. index]
            if not panelAttrib then
                return
            end

            self:ShowPanelArrtib(panelAttrib, descInfo)
            index = index + 1
        end
    end
end

function XUiGridBaseEquip:Init(rootUi, parent)
    self.RootUi = rootUi
    self.Parent = parent
end

function XUiGridBaseEquip:Refresh(baseEquip)
    if not baseEquip then
        self.GameObject:SetActive(false)
        return
    end

    local templateId = baseEquip.TemplateId
    self:ShowEvaluated(baseEquip.Id)

    local template = XDataCenter.BaseEquipManager.GetBaseEquipTemplate(templateId)
    if not template then
        return
    end

    if self.RImgIcon and template.Icon then
        self.RImgIcon:SetRawImage(template.Icon)
        self:SetUiActive(self.RImgIcon, true)
    end

    if self.ImgQuality and template.Quality then
        self.RootUi:SetUiSprite(self.ImgQuality, XArrangeConfigs.GeQualityBgPath(template.Quality))
        self:SetUiActive(self.ImgQuality, true)
    end

    if self.TxtStar and template.Star then
        self.TxtStar.text = template.Star
        self:SetUiActive(self.TxtStar, true)
    end

    if self.TxtName and template.Name then
        self.TxtName.text = template.Name
        self:SetUiActive(self.TxtName, true)
    end

    if self.ImgLevelLimit and self.TxtLevelLimit then
        if template.Level > XPlayer.Level then
            self.TxtLevelLimit.text = CS.XTextManager.GetText("BaseEquipNeedLevel", template.Level)
            self:SetUiActive(self.ImgLevelLimit, true)
            self:SetUiActive(self.TxtLevelLimit, true)
        else
            self:SetUiActive(self.ImgLevelLimit, false)
            self:SetUiActive(self.TxtLevelLimit, false)
        end
    end

    if self.TxtPart and self.TxtDesc then
        self.TxtPart.text = template.Part
        local curType = math.ceil(template.Part /2)
        self.TxtDesc.text = CS.XTextManager.GetText("BaseEquipType" .. curType)
        self:SetUiActive(self.TxtPart, true)
    end

    if XDataCenter.BaseEquipManager.CheckNewHint(baseEquip.Id) then
        self:SetUiActive(self.PanelRedPoint, true)
        XDataCenter.BaseEquipManager.AddNewHint(baseEquip.Id)
    else
        self:SetUiActive(self.PanelRedPoint, false)
    end

    if self.Parent:CheckRecycle(baseEquip.Id) then
        self:SetRecycle(true)
    else
        self:SetRecycle(false)
    end

    self:SetPutOn(XDataCenter.BaseEquipManager.IsBaseEquipPutOn(baseEquip.Id))
    self.GameObject:SetActive(true)
end

function XUiGridBaseEquip:SetSelect(isSelect)
    self:SetUiActive(self.ImgSelect, isSelect)
end

function XUiGridBaseEquip:SetRecycle(isSelect)
    self:SetUiActive(self.ImgRecycle, isSelect)
end
function XUiGridBaseEquip:SetPutOn(isPutOn)
    self:SetUiActive(self.ImgPutOn, isPutOn)
end

return XUiGridBaseEquip