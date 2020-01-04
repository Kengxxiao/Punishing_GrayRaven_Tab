XUiPanelPersonalDetailsCombatItem = XClass()

function XUiPanelPersonalDetailsCombatItem:Ctor(ui,parent)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Parent = parent
    self:InitAutoScript()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelPersonalDetailsCombatItem:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiPanelPersonalDetailsCombatItem:AutoInitUi()
    self.PanelHaveData = self.Transform:Find("PanelHaveData")
    self.ImgIcon = self.Transform:Find("PanelHaveData/ImgIcon"):GetComponent("Image")
    self.ImgRoleQulity = self.Transform:Find("PanelHaveData/ImgRoleQulity"):GetComponent("Image")
    self.TxtLevel = self.Transform:Find("PanelHaveData/TxtLevel"):GetComponent("Text")
    self.PanelNoData = self.Transform:Find("PanelNoData")
end

function XUiPanelPersonalDetailsCombatItem:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiPanelPersonalDetailsCombatItem:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiPanelPersonalDetailsCombatItem:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiPanelPersonalDetailsCombatItem:AutoAddListener()
    self.AutoCreateListeners = {}
end
-- auto

function XUiPanelPersonalDetailsCombatItem:Refresh(data)
    if data then
        self.TxtLevel.text = data.Level
        self.Parent:SetUiSprite(self.ImgIcon, XDataCenter.CharacterManager.GetCharSmallHeadIcon(data.CharacterId))
        self.Parent:SetUiSprite(self.ImgRoleQulity, XCharacterConfigs.GetCharacterQualityIcon(data.Quality))

        self.PanelHaveData.gameObject:SetActive(true)
        self.PanelNoData.gameObject:SetActive(false)
    else
        self.PanelHaveData.gameObject:SetActive(false)
        self.PanelNoData.gameObject:SetActive(true)
    end
    self.GameObject.gameObject:SetActive(true)
end

return XUiPanelPersonalDetailsCombatItem
