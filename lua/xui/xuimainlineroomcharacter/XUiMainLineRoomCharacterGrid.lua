XUiMainLineRoomCharacterGrid = XClass()

function XUiMainLineRoomCharacterGrid:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RectTransform = ui:GetComponent("RectTransform")

    self:InitAutoScript()
    XTool.InitUiObject(self)
    
    if self.PanelStaminaBar then
        self.PanelStaminaBar.gameObject:SetActive(false)
    end

    self:SetSelect(false)
    self:SetInTeam(false)
end
-- auto
-- Automatic generation of code, forbid to edit
function XUiMainLineRoomCharacterGrid:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiMainLineRoomCharacterGrid:AutoInitUi()
    self.BtnCharacter = XUiHelper.TryGetComponent(self.Transform, "BtnCharacter", "Button")
    self.PanelSelected = XUiHelper.TryGetComponent(self.Transform, "PanelSelected", nil)
    self.ImgSelected = XUiHelper.TryGetComponent(self.Transform, "PanelSelected/ImgSelected", "Image")
    self.PanelLevel = XUiHelper.TryGetComponent(self.Transform, "PanelLevel", nil)
    self.TxtLevel = XUiHelper.TryGetComponent(self.Transform, "PanelLevel/TxtLevel", "Text")
    self.TxtGradeLevel = XUiHelper.TryGetComponent(self.Transform, "TxtGradeLevel", "Text")
    self.PanelGrade = XUiHelper.TryGetComponent(self.Transform, "PanelGrade", nil)
    self.RImgGrade = XUiHelper.TryGetComponent(self.Transform, "PanelGrade/RImgGrade", "RawImage")
    self.RImgQuality = XUiHelper.TryGetComponent(self.Transform, "RImgQuality", "RawImage")
    self.ImgLock = XUiHelper.TryGetComponent(self.Transform, "ImgLock", "Image")
    self.PanelHead = XUiHelper.TryGetComponent(self.Transform, "PanelHead", nil)
    self.RImgHeadIcon = XUiHelper.TryGetComponent(self.Transform, "PanelHead/RImgHeadIcon", "RawImage")
    self.ImgHeadIconBg = XUiHelper.TryGetComponent(self.Transform, "PanelHead/ImgHeadIconBg", "Image")
    self.PanelFragment = XUiHelper.TryGetComponent(self.Transform, "PanelFragment", nil)
    self.TxtCurCount = XUiHelper.TryGetComponent(self.Transform, "PanelFragment/TxtCurCount", "Text")
    self.TxtNeedCount = XUiHelper.TryGetComponent(self.Transform, "PanelFragment/TxtNeedCount", "Text")
    self.ImgInTeam = XUiHelper.TryGetComponent(self.Transform, "ImgInTeam", "Image")
    self.ImgRedPoint = XUiHelper.TryGetComponent(self.Transform, "ImgRedPoint", "Image")
    self.ImgStaminaExpFill = XUiHelper.TryGetComponent(self.Transform, "PanelStaminaBar/ImgStaminaExpFill", "Image")
    self.PanelStaminaBar = XUiHelper.TryGetComponent(self.Transform, "PanelStaminaBar", nil)
    self.PanelFight = XUiHelper.TryGetComponent(self.Transform, "PanelFight", nil)
    self.TxtFight = XUiHelper.TryGetComponent(self.Transform, "PanelFight/TxtFight", "Text")
end

function XUiMainLineRoomCharacterGrid:GetAutoKey(uiNode, eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiMainLineRoomCharacterGrid:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiMainLineRoomCharacterGrid:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiMainLineRoomCharacterGrid:AutoAddListener()
    self.AutoCreateListeners = {}
   -- self:RegisterListener(self.BtnCharacter, "onClick", self.OnBtnCharacterClick)
end
-- auto
function XUiMainLineRoomCharacterGrid:OnBtnCharacterClick()
    if self.ClickCallback then
        if XCharacterConfigs.GetCharacterTemplate(self.Character.Id).Foreshow == 0 then
            self.ClickCallback(self.Character)
        else
            XUiManager.TipMsg(CS.XTextManager.GetText("ComingSoon"), XUiManager.UiTipType.Tip)
        end
    end
end

function XUiMainLineRoomCharacterGrid:UpdateOwnInfo()
    if self.TxtLevel then
        self.TxtLevel.text = self.Character.Level
    end

    if self.TxtGradeLevel then
        self.TxtGradeLevel.text = XCharacterConfigs.GetCharGradeName(self.Character.Id, self.Character.Grade)
    end

    if self.RImgGrade then
        self.RImgGrade:SetRawImage(XCharacterConfigs.GetCharGradeIcon(self.Character.Id, self.Character.Grade))
    end

    if self.RImgQuality then
        self.RImgQuality:SetRawImage(XCharacterConfigs.GetCharacterQualityIcon(self.Character.Quality))
    end

    if self.RImgHeadIcon then
        self.RImgHeadIcon:SetRawImage(XDataCenter.CharacterManager.GetCharSmallHeadIcon(self.Character.Id))
    end

    if self.TxtTradeName then
        self.TxtTradeName.text = XCharacterConfigs.GetCharacterTradeName(self.Character.Id)
    end
end

function XUiMainLineRoomCharacterGrid:UpdateStamina(curStamina, maxStamina)
    if self.PanelStaminaBar then
        self.PanelStaminaBar.gameObject:SetActive(true)
    end
    self.ImgStaminaExpFill.fillAmount = curStamina / maxStamina
end

function XUiMainLineRoomCharacterGrid:UpdateUnOwnInfo()
    if self.TxtCurCount then
        self.TxtCurCount.text = XDataCenter.CharacterManager.GetCharUnlockFragment(self.Character.Id)
    end

    local bornQuality = XCharacterConfigs.GetCharMinQuality(self.Character.Id)

    if self.TxtNeedCount then
        self.TxtNeedCount.text = XCharacterConfigs.GetComposeCount(bornQuality)
    end

    if self.RImgHeadIcon then
        self.RImgHeadIcon:SetRawImage(XDataCenter.CharacterManager.GetCharSmallHeadIcon(self.Character.Id))
    end
end

function XUiMainLineRoomCharacterGrid:UpdateGrid(character)
    if character then
        self.Character = character
    end

    local isOwn = XDataCenter.CharacterManager.IsOwnCharacter(self.Character.Id)
    XRedPointManager.CheckOnce(self.OnCheckCharacterRedPoint, self, { XRedPointConditions.Types.CONDITION_CHARACTER }, self.Character.Id)

    if self.PanelLevel then
        self.PanelLevel.gameObject:SetActive(isOwn)
    end

    if self.PanelGrade then
        self.PanelGrade.gameObject:SetActive(isOwn)
    end

    if self.RImgQuality then
        self.RImgQuality.gameObject:SetActive(isOwn)
    end

    if self.ImgLock then
        self.ImgLock.gameObject:SetActive(not isOwn)
    end

    if self.PanelFragment then
        self.PanelFragment.gameObject:SetActive(not isOwn)
    end

    if self.PanelFight then
        self.TxtFight.text = math.floor(self.Character.Ability)
    end

    if isOwn then
        self:UpdateOwnInfo()
    else
        self:UpdateUnOwnInfo()
    end
end

function XUiMainLineRoomCharacterGrid:OnCheckCharacterRedPoint(count)
    if self.ImgRedPoint then
        self.ImgRedPoint.gameObject:SetActive(count >= 0)
    end
end

function XUiMainLineRoomCharacterGrid:SetSelect(isSelect)
    if self.ImgSelected then
        self.ImgSelected.gameObject:SetActive(isSelect)
    end
end

function XUiMainLineRoomCharacterGrid:SetInTeam(isInTeam)
    if self.ImgInTeam then
        self.ImgInTeam.gameObject:SetActive(isInTeam)
    end
end

function XUiMainLineRoomCharacterGrid:Reset()
    --self.GameObject:SetActive(false)
    self:SetSelect(false)
    self:SetInTeam(false)
end

return XUiMainLineRoomCharacterGrid