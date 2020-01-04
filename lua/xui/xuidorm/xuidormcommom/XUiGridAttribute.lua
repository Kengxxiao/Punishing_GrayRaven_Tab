XUiGridAttribute = XClass()
local attrColors = {
    [1] = CS.XTextManager.GetText("FurnitureColorAttrA"),
    [2] = CS.XTextManager.GetText("FurnitureColorAttrB"),
    [3] = CS.XTextManager.GetText("FurnitureColorAttrC"),
    
}

function XUiGridAttribute:Ctor(rootUi, ui)
    self.RootUi = rootUi
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
end

function XUiGridAttribute:Init(data)
    self:UpdateData(data)
end

function XUiGridAttribute:UpdateData(data)
    local attrTemplates = XFurnitureConfigs.GetDormFurnitureType(data.Id)
    if attrTemplates==nil then return end
    local score = data.Val
    if data.Id == XFurnitureConfigs.AttrType.AttrA then
        score = XDataCenter.FurnitureManager.GetFurnitureRedScore(data.FurnitureId)
    elseif data.Id == XFurnitureConfigs.AttrType.AttrB then
        score = XDataCenter.FurnitureManager.GetFurnitureYellowScore(data.FurnitureId)
    else
        score = XDataCenter.FurnitureManager.GetFurnitureBlueScore(data.FurnitureId)
    end

    self.TxtAttributeScore.text = score
    if self.TxtAttributeName then
        self.TxtAttributeName.text = string.format("<color=%s>%s</color>", attrColors[data.Id], attrTemplates.TypeName)
    end
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiGridAttribute:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiGridAttribute:AutoInitUi()
    self.ImgAttributeIcon = self.Transform:Find("ImgAttributeIcon"):GetComponent("Image")
    self.TxtAttributeName = self.Transform:Find("TxtAttributeName"):GetComponent("Text")
    self.TxtAttributeScore = self.Transform:Find("TxtAttributeScore"):GetComponent("Text")
end

function XUiGridAttribute:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiGridAttribute:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiGridAttribute:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiGridAttribute:AutoAddListener()
    self.AutoCreateListeners = {}
end
-- auto



return XUiGridAttribute
