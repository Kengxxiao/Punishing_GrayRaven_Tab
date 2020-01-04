XUiPanelFashionInfo = XClass()

function XUiPanelFashionInfo:Ctor(rootUi, ui, fashion)
    self.RootUi = rootUi
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
    self:UpdateInfo(fashion)
    self:InitBtnSound()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelFashionInfo:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiPanelFashionInfo:AutoInitUi()
    self.BtnGet = self.Transform:Find("BtnGet"):GetComponent("Button")
    self.TxtDescription = self.Transform:Find("TxtDescription"):GetComponent("Text")
    self.TxtName = self.Transform:Find("TxtName"):GetComponent("Text")
    self.ImgInfoIcon = self.Transform:Find("ImgInfoIcon"):GetComponent("Image")
    self.ImgInfoQuality = self.Transform:Find("ImgInfoQuality"):GetComponent("Image")
    self.BtnBlock = self.Transform:Find("BtnBlock"):GetComponent("Button")
    self.PanelBlur = self.Transform:Find("PanelBlur")
end

function XUiPanelFashionInfo:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiPanelFashionInfo:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiPanelFashionInfo:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiPanelFashionInfo:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterListener(self.BtnGet, "onClick", self.OnBtnGetClick)
    self:RegisterListener(self.BtnBlock, "onClick", self.OnBtnBlockClick)
end
-- auto

function XUiPanelFashionInfo:InitBtnSound()
    self.SpecialSoundMap[self:GetAutoKey(self.BtnGet, "onClick")] = XSoundManager.UiBasicsMusic.UiFashion_Click
    self.SpecialSoundMap[self:GetAutoKey(self.BtnBlock, "onClick")] = XSoundManager.UiBasicsMusic.UiFashion_Click
end

function XUiPanelFashionInfo:UpdateInfo(fashion)
    if fashion then
        self.Fashion = fashion
    else
        return 
    end

    self.TxtDescription.text = self.Fashion.Description
    self.TxtName.text = self.Fashion.Name
    XUiHelper.SetQualityIcon(self.RootUi, self.ImgInfoQuality, self.Fashion.Quality)
    self.RootUi:SetUiSprite(self.ImgInfoIcon, self.Fashion.Icon)
end

function XUiPanelFashionInfo:HidePanel()
    self.GameObject:SetActive(false)
end

function XUiPanelFashionInfo:ShowPanel()
    --CS.XUiManager.ViewManager:Push("UiSkip", true, false, self.Fashion.Id)
    XLuaUiManager.Open("UiSkip",self.Fashion.Id)
end

function XUiPanelFashionInfo:OnBtnGetClick(...)
    --CS.XUiManager.ViewManager:Push("UiSkip", true, false, self.Fashion.Id)
    XLuaUiManager.Open("UiSkip",self.Fashion.Id)
end

function XUiPanelFashionInfo:OnBtnBlockClick(...)
    self:HidePanel()
end
