XUiGridFubenStageDetailStar = XClass()

function XUiGridFubenStageDetailStar:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiGridFubenStageDetailStar:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiGridFubenStageDetailStar:AutoInitUi()
    self.TxtStarActive = XUiHelper.TryGetComponent(self.Transform, "TxtStarActive", "Text")
    self.ImgStarActive = XUiHelper.TryGetComponent(self.Transform, "ImgStarActive", "Image")
end

function XUiGridFubenStageDetailStar:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiGridFubenStageDetailStar:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiGridFubenStageDetailStar:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiGridFubenStageDetailStar:AutoAddListener()
    self.AutoCreateListeners = {}
end
-- auto

function XUiGridFubenStageDetailStar:Refresh(desc)
    if desc == nil or desc =="" then
        desc = "-"
    end

    self.ImgStarActive.gameObject:SetActive(true)
    local text = XUiHelper.TryGetComponent(self.Transform, "ImgStarActive/Text", "Text")
    self.TxtStarActive.text = desc
    text.text = desc
end