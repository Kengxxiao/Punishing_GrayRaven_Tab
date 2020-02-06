XUiGridIdleCharacter = XClass()

function XUiGridIdleCharacter:Ctor(rootUi, ui)
    self.RootUi = rootUi
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
    self.Index = 0
    self.CharId = 0
    self.ClickCallBack = nil
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiGridIdleCharacter:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiGridIdleCharacter:AutoInitUi()
    self.BtnItem = self.Transform:Find("BtnItem"):GetComponent("Button")
    self.ImgIcon = self.Transform:Find("ImgIcon"):GetComponent("Image")
    self.PanelCondition = self.Transform:Find("PanelCondition")
    self.BtnCondition = self.Transform:Find("PanelCondition/BtnCondition"):GetComponent("Button")
    self.TxtCondition = self.Transform:Find("PanelCondition/TxtCondition"):GetComponent("Text")
    self.PanelVitality = self.Transform:Find("PanelVitality")
    self.TxtVitality = self.Transform:Find("PanelVitality/TxtVitality"):GetComponent("Text")
    self.PanelInSlot = self.Transform:Find("PanelInSlot")
    self.ImgInSlot = self.Transform:Find("PanelInSlot/ImgInSlot"):GetComponent("Image")
    self.TxtInSlot = self.Transform:Find("PanelInSlot/TxtInSlot"):GetComponent("Text")
    self.PanelTag = self.Transform:Find("PanelTag")
    self.TxtTag = self.Transform:Find("PanelTag/TxtTag"):GetComponent("Text")
    self.ImgWorking = self.Transform:Find("PanelTag/ImgWorking"):GetComponent("Image")
    self.ImgSelect = self.Transform:Find("ImgSelect"):GetComponent("Image")
end

function XUiGridIdleCharacter:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiGridIdleCharacter:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiGridIdleCharacter:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiGridIdleCharacter:AutoAddListener()
    self.AutoCreateListeners = {}
    XUiHelper.RegisterClickEvent(self, self.BtnItem, self.OnBtnItemClick)
    XUiHelper.RegisterClickEvent(self, self.BtnCondition, self.OnBtnConditionClick)
end
-- auto

function XUiGridIdleCharacter:OnBtnItemClick(...)
    if self.ClickCallBack then
        self.ClickCallBack(self.Index, self.CharId)
    end
end

function XUiGridIdleCharacter:OnSliVitalityValueChanged(...)

end

function XUiGridIdleCharacter:OnBtnConditionClick(...)

end

function XUiGridIdleCharacter:SetClickCallBack(funcCallBack)
    self.ClickCallBack = funcCallBack
end

function XUiGridIdleCharacter:SetData(index, charId, showFloor)
    self.ImgSelect.gameObject:SetActive(false)
    self.GameObject:SetActive(true)
    self.PanelCondition.gameObject:SetActive(false)
    self.Index = index
    self.CharId = charId
    local character = XDataCenter.CharacterManager.GetCharacter(self.CharId)
    if not character then return end
    if character.Vitality >= XDataCenter.HostelManager.GetMaxCharacterVitality() or not character.InitVittality then
        self.TxtVitality.text = CS.XTextManager.GetText("HostelFullVitality")
    else
        self.TxtVitality.text = character.Vitality .."/"..XDataCenter.HostelManager.GetMaxCharacterVitality()
    end

    self.RootUi:SetUiSprite(self.ImgIcon, XDataCenter.CharacterManager.GetCharSmallHeadIcon(character.Id))
    local isRest, floor = XDataCenter.HostelManager.IsCharacterInRest(self.CharId)
    if isRest and showFloor then
        local config  = XDataCenter.HostelManager.GetHostelRestTemplate(floor)
        if not config then return end
        self.TxtInSlot.text = config.Name
        self.PanelInSlot.gameObject:SetActive(true)
    else
        self.PanelInSlot.gameObject:SetActive(false)
    end
    local isInWork = XDataCenter.HostelManager.IsCharacterInWork(self.CharId)
    if isInWork then
        self.PanelTag.gameObject:SetActive(true)
    else
        self.PanelTag.gameObject:SetActive(false)
    end
end

function XUiGridIdleCharacter:GetCharId()
    return self.CharId
end

function XUiGridIdleCharacter:SetSelect(value)
    self.ImgSelect.gameObject:SetActive(value)
end