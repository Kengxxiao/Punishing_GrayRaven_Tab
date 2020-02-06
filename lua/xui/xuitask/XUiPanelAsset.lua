local XUiPanelAsset = XClass()

function XUiPanelAsset:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelAsset:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiPanelAsset:AutoInitUi()
    self.PanelTool1 = self.Transform:Find("PanelTool1")
    self.ImgTool1 = self.Transform:Find("PanelTool1/ImgTool1"):GetComponent("Image")
    self.TxtTool1 = self.Transform:Find("PanelTool1/TxtTool1"):GetComponent("Text")
    self.BtnBuyJump1 = self.Transform:Find("PanelTool1/BtnBuyJump1"):GetComponent("Button")
    self.PanelTool2 = self.Transform:Find("PanelTool2")
    self.ImgTool2 = self.Transform:Find("PanelTool2/ImgTool2"):GetComponent("Image")
    self.TxtTool2 = self.Transform:Find("PanelTool2/TxtTool2"):GetComponent("Text")
    self.BtnBuyJump2 = self.Transform:Find("PanelTool2/BtnBuyJump2"):GetComponent("Button")
    self.PanelTool3 = self.Transform:Find("PanelTool3")
    self.ImgTool3 = self.Transform:Find("PanelTool3/ImgTool3"):GetComponent("Image")
    self.TxtTool3 = self.Transform:Find("PanelTool3/TxtTool3"):GetComponent("Text")
    self.BtnBuyJump3 = self.Transform:Find("PanelTool3/BtnBuyJump3"):GetComponent("Button")
end

function XUiPanelAsset:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiPanelAsset:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiPanelAsset:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiPanelAsset:AutoAddListener()
    self.AutoCreateListeners = {}
    XUiHelper.RegisterClickEvent(self, self.BtnBuyJump1, self.OnBtnBuyJump1Click)
    XUiHelper.RegisterClickEvent(self, self.BtnBuyJump2, self.OnBtnBuyJump2Click)
    XUiHelper.RegisterClickEvent(self, self.BtnBuyJump3, self.OnBtnBuyJump3Click)
end
-- auto

function XUiPanelAsset:OnBtnBuyJump1Click(...)

end

function XUiPanelAsset:OnBtnBuyJump2Click(...)

end

function XUiPanelAsset:OnBtnBuyJump3Click(...)

end

return XUiPanelAsset
