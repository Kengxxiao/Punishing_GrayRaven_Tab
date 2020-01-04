XUiPanelSupport = XClass()

function XUiPanelSupport:Ctor(ui,parent)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Parent = parent
    self:InitAutoScript()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelSupport:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiPanelSupport:AutoInitUi()
    self.PanelInfo = self.Transform:Find("PanelInfo")
    self.PanelHaveData = self.Transform:Find("PanelInfo/PanelHaveData")
    self.TxtName = self.Transform:Find("PanelInfo/PanelHaveData/TxtName"):GetComponent("Text")
    self.ImgRoleQulity = self.Transform:Find("PanelInfo/PanelHaveData/ImgRoleQulity"):GetComponent("Image")
    self.ImgIcon = self.Transform:Find("PanelInfo/PanelHaveData/ImgIcon"):GetComponent("Image")
    self.TxtLevel = self.Transform:Find("PanelInfo/PanelHaveData/TxtLevel"):GetComponent("Text")
    self.PanelNoData = self.Transform:Find("PanelInfo/PanelNoData")
    self.ImgMedalNone = self.Transform:Find("PanelInfo/PanelNoData/ImgMedalNone"):GetComponent("Image")
    self.PanelMedal = self.Transform:Find("PanelMedal")
    self.ImgMedal = self.Transform:Find("PanelMedal/ImgMedal"):GetComponent("Image")
    self.ImgMedalNoneA = self.Transform:Find("PanelMedal/ImgMedalNone"):GetComponent("Image")
end

function XUiPanelSupport:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiPanelSupport:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiPanelSupport:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiPanelSupport:AutoAddListener()
    self.AutoCreateListeners = {}
end
-- auto

function XUiPanelSupport:Refresh(AssistData)
    if AssistData then
        self.TxtLevel.text = AssistData.Level
        self.Parent:SetUiSprite(self.ImgIcon, XDataCenter.CharacterManager.GetCharSmallHeadIcon(AssistData.CharacterId))
        self.Parent:SetUiSprite(self.ImgRoleQulity, XCharacterConfigs.GetCharacterQualityIcon(AssistData.Quality))
        self.TxtName.text = XCharacterConfigs.GetCharacterName(AssistData.CharacterId)
        self.PanelHaveData.gameObject:SetActive(true)
        self.PanelNoData.gameObject:SetActive(false)
    else
        self.PanelHaveData.gameObject:SetActive(false)
        self.PanelNoData.gameObject:SetActive(true)
    end
end
