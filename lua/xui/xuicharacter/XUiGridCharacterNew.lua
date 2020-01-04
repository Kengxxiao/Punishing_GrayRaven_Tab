XUiGridCharacterNew = XClass()

function XUiGridCharacterNew:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform

    self.RectTransform = ui:GetComponent("RectTransform")
    self:InitAutoScript()

end

function XUiGridCharacterNew:Init(rootUi, isShowStamina)
    self.RootUi = rootUi
    self.IsShowStamina = isShowStamina
end
-- auto
-- Automatic generation of code, forbid to edit
function XUiGridCharacterNew:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiGridCharacterNew:AutoInitUi()
    self.PanelHead = self.Transform:Find("PanelHead")
    self.RImgHeadIcon = self.Transform:Find("PanelHead/RImgHeadIcon"):GetComponent("RawImage")
    self.PanelLevel = self.Transform:Find("PanelLevel")
    self.TxtLevel = self.Transform:Find("PanelLevel/TxtLevel"):GetComponent("Text")
    self.PanelGrade = self.Transform:Find("PanelGrade")
    self.RImgGrade = self.Transform:Find("PanelGrade/RImgGrade"):GetComponent("RawImage")
    self.RImgQuality = self.Transform:Find("RImgQuality"):GetComponent("RawImage")
    self.PanelFragment = self.Transform:Find("PanelFragment")
    self.TxtCurCount = self.Transform:Find("PanelFragment/TxtCurCount"):GetComponent("Text")
    self.TxtNeedCount = self.Transform:Find("PanelFragment/TxtNeedCount"):GetComponent("Text")
    self.ImgLock = self.Transform:Find("ImgLock"):GetComponent("Image")
    self.BtnCharacter = self.Transform:Find("BtnCharacter"):GetComponent("Button")
    self.ImgInTeam = self.Transform:Find("ImgInTeam"):GetComponent("Image")
    self.PanelSelected = self.Transform:Find("PanelSelected")
    self.ImgSelected = self.Transform:Find("PanelSelected/ImgSelected"):GetComponent("Image")
    self.ImgRedPoint = self.Transform:Find("ImgRedPoint"):GetComponent("Image")
    self.TxtCur = self.Transform:Find("TxtCur"):GetComponent("Text")
end

function XUiGridCharacterNew:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiGridCharacterNew:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiGridCharacterNew:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiGridCharacterNew:AutoAddListener()
    self:RegisterClickEvent(self.BtnCharacter, self.OnBtnCharacterClick)
end
-- auto
function XUiGridCharacterNew:OnBtnCharacterClick(...)

end

function XUiGridCharacterNew:OnBtnCharacterClick()

end

function XUiGridCharacterNew:UpdateOwnInfo()
    self.TxtLevel.text = self.Character.Level
    self.RImgGrade:SetRawImage(XCharacterConfigs.GetCharGradeIcon(self.Character.Id, self.Character.Grade))
    self.RImgQuality:SetRawImage(XCharacterConfigs.GetCharacterQualityIcon(self.Character.Quality))
    self.RImgHeadIcon:SetRawImage(XDataCenter.CharacterManager.GetCharSmallHeadIcon(self.Character.Id))
end

function XUiGridCharacterNew:UpdateUnOwnInfo()
    self.TxtCurCount.text = XDataCenter.CharacterManager.GetCharUnlockFragment(self.Character.Id)
    local bornQuality = XCharacterConfigs.GetCharMinQuality(self.Character.Id)
    self.TxtNeedCount.text = XCharacterConfigs.GetComposeCount(bornQuality)
    self.RImgHeadIcon:SetRawImage(XDataCenter.CharacterManager.GetCharSmallHeadIcon(self.Character.Id))
end

function XUiGridCharacterNew:UpdateGrid(character)
    if character then
        self.Character = character
    end

    local isOwn = XDataCenter.CharacterManager.IsOwnCharacter(self.Character.Id)
    XRedPointManager.CheckOnce(self.OnCheckCharacterRedPoint, self, { XRedPointConditions.Types.CONDITION_CHARACTER }, self.Character.Id)
    self.PanelLevel.gameObject:SetActive(isOwn)
    self.PanelGrade.gameObject:SetActive(isOwn)
    self.RImgQuality.gameObject:SetActive(isOwn)
    self.ImgLock.gameObject:SetActive(not isOwn)
    self.PanelFragment.gameObject:SetActive(not isOwn)

    if isOwn then
        self:UpdateOwnInfo()
    else
        self:UpdateUnOwnInfo()
    end
end

function XUiGridCharacterNew:OnCheckCharacterRedPoint(count)
    if self.ImgRedPoint then
        self.ImgRedPoint.gameObject:SetActive(count >= 0)
    end
end

function XUiGridCharacterNew:SetSelect(isSelect)
    self.ImgSelected.gameObject:SetActive(isSelect)
end

function XUiGridCharacterNew:SetInTeam(isInTeam)

    if self.ImgInTeam then
        self.ImgInTeam.gameObject:SetActive(isInTeam)
    end
end

function XUiGridCharacterNew:SetCurSignState(state)
    self.TxtCur.gameObject:SetActive(state)
end

function XUiGridCharacterNew:Reset()
    self:SetSelect(false)
    self:SetInTeam(false)
    self.TxtCur.gameObject:SetActive(false)
end

function XUiGridCharacterNew:SetPosition(x, y)
    self.RectTransform.anchoredPosition = CS.UnityEngine.Vector2(x, y)
end