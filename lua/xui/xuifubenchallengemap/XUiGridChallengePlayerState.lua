XUiGridChallengePlayerState = XClass()

function XUiGridChallengePlayerState:Ctor(rootUi, ui)
    self.RootUi = rootUi
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RectTransform = ui:GetComponent("RectTransform")
    self:InitAutoScript()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiGridChallengePlayerState:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiGridChallengePlayerState:AutoInitUi()
    self.ImgRoleLoading = self.Transform:Find("ImgRoleLoading"):GetComponent("Image")
    self.ImgRoleBg = self.Transform:Find("ImgRoleBg"):GetComponent("Image")
    self.ImgRole = self.Transform:Find("ImgRole"):GetComponent("Image")
    self.PanelTxtName = self.Transform:Find("PanelTxtName")
    self.TxtName = self.Transform:Find("PanelTxtName/TxtName"):GetComponent("Text")
    self.PanelPlayer = self.Transform:Find("PanelPlayer")
    self.TxtLevel = self.Transform:Find("PanelPlayer/TxtLevel"):GetComponent("Text")
    self.TxtLevelNum = self.Transform:Find("PanelPlayer/TxtLevelNum"):GetComponent("Text")
end

function XUiGridChallengePlayerState:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiGridChallengePlayerState:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiGridChallengePlayerState:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiGridChallengePlayerState:AutoAddListener()
    self.AutoCreateListeners = {}
end
-- auto

function XUiGridChallengePlayerState:Refresh(playerData)
    self.TxtNameE.text = playerData.Name
    if playerData.CharacterData then
        self.TxtLevelNum.text = playerData.CharacterData.Level
        self.RootUi:SetUiSprite(self.ImgRole, XDataCenter.CharacterManager.GetCharSmallHeadIcon(playerData.CharacterData.Id))
    end
end

function XUiGridChallengePlayerState:SetPosition(x, y)
    self.RectTransform.anchoredPosition = CS.UnityEngine.Vector2(x, y)
end

function XUiGridChallengePlayerState:SetActive(active)
    self.GameObject:SetActive(active)
end
