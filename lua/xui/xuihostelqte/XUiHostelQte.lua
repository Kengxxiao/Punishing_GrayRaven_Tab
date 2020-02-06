local XUiHostelQte = XUiManager.Register("UiHostelQte")

function XUiHostelQte:OnOpen()
    self:InitAutoScript()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiHostelQte:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiHostelQte:AutoInitUi()
    self.ImgHitArea = self.Transform:Find("FullScreenBackground/ImgHitArea"):GetComponent("Image")
    self.ImgSuperHitArea = self.Transform:Find("FullScreenBackground/ImgSuperHitArea"):GetComponent("Image")
    self.ImgLine = self.Transform:Find("FullScreenBackground/ImgLine"):GetComponent("Image")
    self.BtnOk = self.Transform:Find("FullScreenBackground/BtnOk"):GetComponent("Button")
    self.TxtRemainTime = self.Transform:Find("SafeAreaContentPane/TxtRemainTime"):GetComponent("Text")
    self.SliTime = self.Transform:Find("SafeAreaContentPane/SliTime"):GetComponent("Slider")
end

function XUiHostelQte:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiHostelQte:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiHostelQte:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiHostelQte:AutoAddListener()
    self.AutoCreateListeners = {}
    XUiHelper.RegisterClickEvent(self, self.BtnOk, self.OnBtnOkClick)
    self:RegisterListener(self.SliTime, "onValueChanged", self.OnSliTimeValueChanged)
end
-- auto

function XUiHostelQte:OnBtnOkClick(...)

end

function XUiHostelQte:OnSliTimeValueChanged(...)

end
