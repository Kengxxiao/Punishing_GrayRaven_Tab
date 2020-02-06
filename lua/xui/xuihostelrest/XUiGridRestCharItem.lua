XUiGridRestCharItem = XClass()

function XUiGridRestCharItem:Ctor(rootUi, ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
    self.Slot = 0
    self.CharId = 0
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiGridRestCharItem:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiGridRestCharItem:AutoInitUi()
    self.BtnItem = self.Transform:Find("BtnItem"):GetComponent("Button")
    self.PanelInfo = self.Transform:Find("PanelInfo")
    self.PanelWorking = self.Transform:Find("PanelInfo/PanelWorking")
end

function XUiGridRestCharItem:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiGridRestCharItem:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiGridRestCharItem:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiGridRestCharItem:AutoAddListener()
    self.AutoCreateListeners = {}
    XUiHelper.RegisterClickEvent(self, self.BtnItem, self.OnBtnItemClick)
end
-- auto

function XUiGridRestCharItem:SetData(data)
    self.GameObject:SetActive(true)
    self.Slot = data.Slot
    self.CharId = data.CharId
    if self.CharId == 0 then
        self.PanelWorking.gameObject:SetActive(false)
        return
    end
    local character = XDataCenter.CharacterManager.GetCharacter(self.CharId)
    if XDataCenter.HostelManager.IsCharacterInWork(self.CharId) then
        self.PanelWorking.gameObject:SetActive(true)
    else
        self.PanelWorking.gameObject:SetActive(false)
    end
end

function XUiGridRestCharItem:OnBtnItemClick(...)

end

function XUiGridRestCharItem:GetCharId()
    return self.CharId
end

function XUiGridRestCharItem:GetRectTransform()
    return self.GameObject:GetComponent("RectTransform")
end

