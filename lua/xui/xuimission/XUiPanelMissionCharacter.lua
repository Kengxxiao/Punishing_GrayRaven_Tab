XUiPanelMissionCharacter = XClass()

local Status = {
    Empty = 1,
    Lock = 2,
    Normal = 3
}

function XUiPanelMissionCharacter:Ctor(ui, parent, index)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
    self:InitAutoScript()
    self.Status = Status.Empty
    self.Parent = parent
    self.Index = index
end

function XUiPanelMissionCharacter:SetEmpty()
    self.PanelEmpty.gameObject:SetActive(true)
    self.PanelLock.gameObject:SetActive(false)
    self.PanelCha.gameObject:SetActive(false)
    self.Status = Status.Empty
end

function XUiPanelMissionCharacter:SetLock()
    self.PanelEmpty.gameObject:SetActive(false)
    self.PanelLock.gameObject:SetActive(true)
    self.PanelCha.gameObject:SetActive(false)
    self.Status = Status.Lock
end

function XUiPanelMissionCharacter:SetCharacter(id)
    self.PanelEmpty.gameObject:SetActive(false)
    self.PanelLock.gameObject:SetActive(false)
    self.PanelCha.gameObject:SetActive(true)
    local character = XDataCenter.CharacterManager.GetCharacter(id)
    self.TxtLevel.text = tostring(character.Level)
    self.Parent:SetUiSprite(self.ImgType, XCharacterConfigs.GetNpcTypeIcon(character.Type))
    --self.Parent:SetUiSprite(self.RImgCharacter, XDataCenter.CharacterManager.GetCharHalfBodyBigImage(id))
    self.RImgCharacter:SetRawImage(XDataCenter.CharacterManager.GetCharHalfBodyBigImage(id))
    self.Status = Status.Normal
end

function XUiPanelMissionCharacter:SetSelectData(memberCount, characterIds)
    self.MemberCount = memberCount
    self.CharacterIds = characterIds
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelMissionCharacter:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiPanelMissionCharacter:AutoInitUi()
    -- self.PanelLock = self.Transform:Find("PanelLock")
    -- self.PanelEmpty = self.Transform:Find("PanelEmpty")
    -- self.PanelCha = self.Transform:Find("PanelCha")
    -- self.ImgBg = self.Transform:Find("PanelCha/ImgBg"):GetComponent("Image")
    -- self.PanelMask = self.Transform:Find("PanelCha/PanelMask")
    -- self.RImgCharacter = self.Transform:Find("PanelCha/PanelMask/RImgCharacter"):GetComponent("RawImage")
    -- self.ImgType = self.Transform:Find("PanelCha/Image/ImgType"):GetComponent("Image")
    -- self.TxtLevel = self.Transform:Find("PanelCha/Image/TxtLevel"):GetComponent("Text")
    -- self.BtnAdd = self.Transform:Find("BtnAdd"):GetComponent("Button")
end

function XUiPanelMissionCharacter:GetAutoKey(uiNode, eventName)
    if not uiNode then
        return
    end
    return eventName .. uiNode:GetHashCode()
end

function XUiPanelMissionCharacter:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then
        return
    end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiPanelMissionCharacter:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiPanelMissionCharacter:AutoAddListener()
    self.AutoCreateListeners = {}
    XUiHelper.RegisterClickEvent(self, self.BtnAdd, self.OnBtnAddClick)
end
-- auto
function XUiPanelMissionCharacter:OnBtnAddClick(...)
    if self.Status == Status.Lock then
        return
    end

    --CS.XUiManager.ViewManager:Push("UiMissionTeamSelect", true, false,self.CharacterIds,self.MemberCount,self.Index,function(ids)
    --    if self.Parent then
    --        self.Parent:Refresh(ids)
    --    end
    --end)

    XLuaUiManager.Open("UiMissionTeamSelect", self.CharacterIds, self.MemberCount, self.Index, function(ids)
        if self.Parent then
            self.Parent:Refresh(ids)
        end
    end)

end

return XUiPanelMissionCharacter