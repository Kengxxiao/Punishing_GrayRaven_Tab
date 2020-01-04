XUiGridMisssionTeam = XClass()

function XUiGridMisssionTeam:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
end

function XUiGridMisssionTeam:Init(rootUi)
    self.RootUi = rootUi
    
end

function XUiGridMisssionTeam:Reset()
    self:SetSelect(false)
end

function XUiGridMisssionTeam:UpdateGrid(character)
    self.Character = character
    self.ImgInTeam.gameObject:SetActive(self.Character.IsWorking and self.Character.IsWorking > 0)
    self.TxtLevel.text = self.Character.Level
    self.RootUi:SetUiSprite(self.ImgQuality, XCharacterConfigs.GetCharacterQualityIcon(self.Character.Quality))
    self.RootUi:SetUiSprite(self.ImgHeadIcon, XDataCenter.CharacterManager.GetCharSmallHeadIcon(self.Character.Id))
end

function XUiGridMisssionTeam:SetSelect(isSelect)
    self.ImgSelected.gameObject:SetActive(isSelect)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiGridMisssionTeam:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiGridMisssionTeam:AutoInitUi()
    self.PanelHead = self.Transform:Find("PanelHead")
    self.ImgHeadIconBg = self.Transform:Find("PanelHead/ImgHeadIconBg"):GetComponent("Image")
    self.ImgHeadIcon = self.Transform:Find("PanelHead/ImgHeadIcon"):GetComponent("Image")
    self.PanelLevel = self.Transform:Find("PanelLevel")
    self.TxtLevel = self.Transform:Find("PanelLevel/TxtLevel"):GetComponent("Text")
    self.ImgQuality = self.Transform:Find("ImgQuality"):GetComponent("Image")
    self.ImgInTeam = self.Transform:Find("ImgInTeam"):GetComponent("Image")
    self.PanelSelected = self.Transform:Find("PanelSelected")
    self.ImgSelected = self.Transform:Find("PanelSelected/ImgSelected"):GetComponent("Image")
end

function XUiGridMisssionTeam:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiGridMisssionTeam:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiGridMisssionTeam:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiGridMisssionTeam:AutoAddListener()
    self.AutoCreateListeners = {}
end
-- auto
return XUiGridMisssionTeam