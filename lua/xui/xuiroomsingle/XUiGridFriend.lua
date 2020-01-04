XUiGridFriend = XClass()

function XUiGridFriend:Ctor(rootUi, ui, assistPlayerData)
    self.RootUi = rootUi
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.AssistPlayerData = assistPlayerData
    self:InitAutoScript()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiGridFriend:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiGridFriend:AutoInitUi()
    self.BtnFriend = self.Transform:Find("BtnFriend"):GetComponent("Button")
    self.ImgFirendSelected = self.Transform:Find("BtnFriend/ImgFirendSelected"):GetComponent("Image")
    self.ImgFriendBg = self.Transform:Find("BtnFriend/ImgFriendBg"):GetComponent("Image")
    self.ImgFirendIcon = self.Transform:Find("BtnFriend/ImgFirendIcon"):GetComponent("Image")
    self.TxtName = self.Transform:Find("BtnFriend/TxtName"):GetComponent("Text")
    self.TxtLv = self.Transform:Find("BtnFriend/TxtLv"):GetComponent("Text")
    self.TxtLvNum = self.Transform:Find("BtnFriend/TxtLvNum"):GetComponent("Text")
    self.ImgGrade = self.Transform:Find("BtnFriend/ImgGrade"):GetComponent("Image")
    self.ImgTypePasser = self.Transform:Find("BtnFriend/FriendType/ImgTypePasser"):GetComponent("Image")
    self.ImgTypeFriend = self.Transform:Find("BtnFriend/FriendType/ImgTypeFriend"):GetComponent("Image")
    self.ImgTypeLegion = self.Transform:Find("BtnFriend/FriendType/ImgTypeLegion"):GetComponent("Image")
    self.ImgResourceIcon = self.Transform:Find("BtnFriend/BottomResource/ImgResourceIcon"):GetComponent("Image")
    self.TxtResourceNum = self.Transform:Find("BtnFriend/BottomResource/TxtResourceNum"):GetComponent("Text")
end

function XUiGridFriend:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiGridFriend:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiGridFriend:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiGridFriend:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterListener(self.BtnFriend, "onClick", self.OnBtnFriendClick)
end
-- auto

function XUiGridFriend:AddClickListener(target, func)
    self.ClickCallbackTarget = target
    self.ClickCallback = func
end

function XUiGridFriend:OnBtnFriendClick()
    if self.ClickCallbackTarget and self.ClickCallback then
        self.ClickCallback(self.ClickCallbackTarget, self)
    end
end

function XUiGridFriend:UpdateAssistTypeActive(assistType)
    self.ImgTypePasser.gameObject:SetActive(false)
    self.ImgTypeFriend.gameObject:SetActive(false)
    self.ImgTypeLegion.gameObject:SetActive(false)

    if assistType == XDataCenter.AssistManager.AssistType.Passer then
        self.ImgTypePasser.gameObject:SetActive(true)
    elseif assistType == XDataCenter.AssistManager.AssistType.Friend then
        self.ImgTypeFriend.gameObject:SetActive(true)
    elseif assistType == XDataCenter.AssistManager.AssistType.Legion then
        self.ImgTypeLegion.gameObject:SetActive(true)
    end
end

function XUiGridFriend:UpdateFriendGrid()
    local characterData = self.AssistPlayerData.Character
    local assistType = self.AssistPlayerData.AssistType

    self.TxtName.text = self.AssistPlayerData.Name
    self.TxtLvNum.text = self.AssistPlayerData.Level
    self:UpdateAssistTypeActive(assistType)
    if characterData then
        self.RootUi:SetUiSprite(self.ImgGrade, XCharacterConfigs.GetCharQualityIcon(characterData.Quality))
    end
end

function XUiGridFriend:UpdateFriendGridSelected(flag)
    self.ImgFirendSelected.gameObject:SetActive(flag)
end
