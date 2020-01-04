XUiGridDelegateReporter = XClass()

function XUiGridDelegateReporter:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiGridDelegateReporter:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiGridDelegateReporter:AutoInitUi()
    self.TxtDesc = XUiHelper.TryGetComponent(self.Transform, "TxtDesc", "Text")
    self.TxtDelegateType = XUiHelper.TryGetComponent(self.Transform, "TxtDelegateType", "Text")
    self.TxtNickname = XUiHelper.TryGetComponent(self.Transform, "TxtNickname", "Text")
    self.ImgHeadIcon = XUiHelper.TryGetComponent(self.Transform, "ImgHeadIcon", "Image")
    self.ImgRewardIcon = XUiHelper.TryGetComponent(self.Transform, "ImgRewardIcon", "Image")
    self.TxtRewardCount = XUiHelper.TryGetComponent(self.Transform, "TxtRewardCount", "Text")
    self.TxtContent = XUiHelper.TryGetComponent(self.Transform, "ImageBg/TxtContent", "Text")
end

function XUiGridDelegateReporter:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiGridDelegateReporter:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiGridDelegateReporter:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiGridDelegateReporter:AutoAddListener()
    self.AutoCreateListeners = {}
end
-- auto
