XUiPanelJubao = XClass()

function XUiPanelJubao:Ctor(ui, parent)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Parent = parent
    self:InitAutoScript()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelJubao:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiPanelJubao:AutoInitUi()
    self.BtnBack = self.Transform:Find("BtnBack"):GetComponent("Button")
    self.BtnConfirm = self.Transform:Find("BtnConfirm"):GetComponent("Button")
    self.PanelRole = self.Transform:Find("PanelRole")
    self.RImgRole = self.Transform:Find("PanelRole/RImgRole"):GetComponent("RawImage")
    self.PanelTGroup = self.Transform:Find("PanelTGroup")
    self.TogQt = self.Transform:Find("PanelTGroup/TogQt"):GetComponent("Toggle")
    self.TogDs = self.Transform:Find("PanelTGroup/TogDs"):GetComponent("Toggle")
    self.TogZp = self.Transform:Find("PanelTGroup/TogZp"):GetComponent("Toggle")
    self.TogGg = self.Transform:Find("PanelTGroup/TogGg"):GetComponent("Toggle")
    self.PanelInput = self.Transform:Find("PanelInput")
    self.TxtNum = self.Transform:Find("PanelInput/TxtNum"):GetComponent("Text")
    self.InFReason = self.Transform:Find("PanelInput/InFReason"):GetComponent("InputField")
    self.TxtName = self.Transform:Find("TxtName"):GetComponent("Text")
end

function XUiPanelJubao:GetAutoKey(uiNode, eventName)
    if not uiNode then
        return
    end
    return eventName .. uiNode:GetHashCode()
end

function XUiPanelJubao:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then
        return
    end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiPanelJubao:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiPanelJubao:AutoAddListener()
    self.AutoCreateListeners = {}
    XUiHelper.RegisterClickEvent(self, self.BtnBack, self.OnBtnBackClick)
    XUiHelper.RegisterClickEvent(self, self.BtnConfirm, self.OnBtnConfirmClick)
    self:RegisterListener(self.TogQt, "onValueChanged", self.OnTogQtValueChanged)
    self:RegisterListener(self.TogDs, "onValueChanged", self.OnTogDsValueChanged)
    self:RegisterListener(self.TogZp, "onValueChanged", self.OnTogZpValueChanged)
    self:RegisterListener(self.TogGg, "onValueChanged", self.OnTogGgValueChanged)
    self:RegisterListener(self.InFReason, "onValueChanged", self.OnInFReasonValueChanged)
    self:RegisterListener(self.InFReason, "onEndEdit", self.OnInFReasonEndEdit)
end
-- auto
function XUiPanelJubao:OnTogQtValueChanged(...)

end

function XUiPanelJubao:OnTogDsValueChanged(...)

end

function XUiPanelJubao:OnTogZpValueChanged(...)

end

function XUiPanelJubao:OnTogGgValueChanged(...)

end

function XUiPanelJubao:OnInFReasonValueChanged(...)
    local length = string.Utf8Len(self.InFReason.text)
    self.TxtNum.text = length .. "/" .. "100"
end

function XUiPanelJubao:OnInFReasonEndEdit(...)

end

function XUiPanelJubao:OnBtnBackClick(...)
    self:SetIsShow(false)
end

function XUiPanelJubao:OnBtnConfirmClick(...)
    XUiManager.TipCode(XCode.Success)
    self:SetIsShow(false)
end

function XUiPanelJubao:OnBtnInputFieldClick(...)

end

function XUiPanelJubao:SetIsShow(code)
    self.GameObject.gameObject:SetActive(code)
end

function XUiPanelJubao:Refresh(playerData)
    self.playerData = playerData
    self.TogGg.isOn = false
    self.TogZp.isOn = false
    self.TogDs.isOn = false
    self.TogQt.isOn = false

    self.TxtName.text = playerData.Name
    local info = XPlayerManager.GetHeadPortraitInfoById(playerData.CurrHeadPortraitId)
    if (info ~= nil) then
        self.RImgRole:SetRawImage(info.ImgSrc)
    end
    self:SetIsShow(true)

end

return XUiPanelJubao