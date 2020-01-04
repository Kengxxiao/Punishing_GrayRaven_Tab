local pairs = pairs

local XUiPanelPutOnShowTip = XClass()

function XUiPanelPutOnShowTip:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelPutOnShowTip:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiPanelPutOnShowTip:AutoInitUi()
    self.BtnClick = self.Transform:Find("BtnClick"):GetComponent("Button")
    self.PanelDetails = self.Transform:Find("PanelDetails")
    self.PanelAttrib1 = self.Transform:Find("PanelDetails/PanelAttrib1")
    self.PanelAttrib2 = self.Transform:Find("PanelDetails/PanelAttrib2")
end

function XUiPanelPutOnShowTip:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelPutOnShowTip:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelPutOnShowTip:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelPutOnShowTip:AutoAddListener()
    self:RegisterClickEvent(self.BtnClick, self.OnBtnClickClick)
end
-- auto

function XUiPanelPutOnShowTip:OnBtnClickClick(...)
    self:HidePanel()
end

function XUiPanelPutOnShowTip:ShowPanelArrtib(panel, attribInfo)
    if not panel or not attribInfo then
        return
    end

    local txtName = XUiHelper.TryGetComponent(panel, "TxtAttribName", "Text")
    if txtName then
        txtName.text = attribInfo.Name
    end

    local txtValue = XUiHelper.TryGetComponent(panel, "TxtAttribValue", "Text")
    if txtValue then
        txtValue.text = attribInfo.Value
    end
end

function XUiPanelPutOnShowTip:ShowAttribChangeIcon(panel, status)
    local imgUp = XUiHelper.TryGetComponent(panel, "ImgUp", "Image")
    local imgDown = XUiHelper.TryGetComponent(panel, "ImgDown", "Image")

    imgUp.gameObject:SetActive(status == XDataCenter.BaseEquipManager.XATTRIB_CHANGE.Up)
    imgDown.gameObject:SetActive(status == XDataCenter.BaseEquipManager.XATTRIB_CHANGE.Down)
end

function XUiPanelPutOnShowTip:ShowPanel(newBaseEquipId, oldBaseEquipId)
    if not newBaseEquipId then
        return
    end

    local showInfo = XDataCenter.BaseEquipManager.GetEvaluatedAttribShowInfo(newBaseEquipId)
    local compareResultList = XDataCenter.BaseEquipManager.CompareAttrib(newBaseEquipId, oldBaseEquipId)
    local attriDescList = showInfo.AttriDescList

    for index, descInfo in pairs(attriDescList) do
        local attrPanel = self["PanelAttrib" .. index]
        if not attrPanel then
            break
        end

        self:ShowPanelArrtib(attrPanel, descInfo)
        self:ShowAttribChangeIcon(attrPanel, compareResultList[index])
    end

    self.GameObject:SetActive(true)
end

function XUiPanelPutOnShowTip:HidePanel()
    self.GameObject:SetActive(false)
end

return XUiPanelPutOnShowTip
