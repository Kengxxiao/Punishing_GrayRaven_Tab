XUiPanelOnLineLoadingDetailItem = XClass()

function XUiPanelOnLineLoadingDetailItem:Ctor(ui, rootUi, parent)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    self.Parent = parent
    XTool.InitUiObject(self)
    self:InitAutoScript()
    self.ImgCompleted.gameObject:SetActiveEx(false)
    self:UpdateProgress(0)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelOnLineLoadingDetailItem:InitAutoScript()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiPanelOnLineLoadingDetailItem:GetAutoKey(uiNode, eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiPanelOnLineLoadingDetailItem:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiPanelOnLineLoadingDetailItem:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiPanelOnLineLoadingDetailItem:AutoAddListener()
    self.AutoCreateListeners = {}
end
-- auto
function XUiPanelOnLineLoadingDetailItem:SetIsShow(active)
    if self.GameObject then
        self.GameObject.gameObject:SetActiveEx(active)
    end
end

function XUiPanelOnLineLoadingDetailItem:Refresh(data)
    if not data then
        self:SetIsShow(false)
        return
    end
    
    local medalConfig = XMedalConfigs.GetMeadalConfigById(data.MedalId)
    local medalIcon = nil
    if medalConfig then 
        medalIcon = medalConfig.MedalIcon
    end
    if medalIcon ~= nil then
        self.ImgMedalIcon:SetRawImage(medalIcon)
        self.ImgMedalIcon.gameObject:SetActiveEx(true)
    else
        self.ImgMedalIcon.gameObject:SetActiveEx(false)
    end
    
    self.Data = data
    self.TxtName.text = data.Name
    self.TxtPercent.text = "0%"
    local character = data.FightNpcData.Character
    local icon = XDataCenter.CharacterManager.GetCharHalfBodyImage(character.Id)
    if icon then
        self.RootUi:SetUiSprite(self.ImgIcon, icon)
    end
    local npcId = XCharacterConfigs.GetCharNpcId(character.Id, character.Quality)
    local npcTemplate = CS.XNpcManager.GetNpcTemplate(npcId)
    local logo = XCharacterConfigs.GetNpcTypeIcon(npcTemplate.Type)
    if logo then
        self.RootUi:SetUiSprite(self.ImgLogo, logo)
    end
    self:SetIsShow(true)
end

function XUiPanelOnLineLoadingDetailItem:UpdateProgress(progress)
    if progress >= 100 then
        self.ImgCompleted.gameObject:SetActiveEx(true)
        self.TxtPercent.text = "<color=#ffeb04ef>100%</color>"
    else
        self.ImgCompleted.gameObject:SetActiveEx(false)
        self.TxtPercent.text = progress .. "%"
    end
end

return XUiPanelOnLineLoadingDetailItem