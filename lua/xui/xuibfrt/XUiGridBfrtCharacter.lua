local XUiGridBfrtCharacter = XClass()

function XUiGridBfrtCharacter:Ctor(rootUi, ui, character)
    self.RootUi = rootUi
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
    self:InitComponentState()
    self:Refresh(character)
end

function XUiGridBfrtCharacter:InitComponentState()
    self.PanelTeam.gameObject:SetActive(false)
    self.PanelSelected.gameObject:SetActive(false)
end

function XUiGridBfrtCharacter:Refresh(character)
    self:UpdateViewData(character)
    self:UpdateGameObject()
    self:UpdateCharacterInfo()
end

function XUiGridBfrtCharacter:UpdateViewData(character)
    self.Character = character
end

function XUiGridBfrtCharacter:UpdateGameObject()
    self.GameObject.name = self.Character.Id
    self.GameObject:SetActive(true)
end

function XUiGridBfrtCharacter:UpdateCharacterInfo()
    self.TxtFight.text = math.floor(self.Character.Ability) 
    self.TxtLevel.text = self.Character.Level
    self.RImgHeadIcon:SetRawImage(XDataCenter.CharacterManager.GetCharSmallHeadIcon(self.Character.Id))
    self.RImgQuality:SetRawImage(XCharacterConfigs.GetCharacterQualityIcon(self.Character.Quality))
end

function XUiGridBfrtCharacter:SetInTeam(inEchelonIndex, inEchelonType)
    if inEchelonIndex then
        if inEchelonType == XDataCenter.BfrtManager.EchelonType.Fight then
            self.TxtEchelonIndex.text = CS.XTextManager.GetText("BfrtFightEchelonTitleSimple", inEchelonIndex)
            self.PanelTeam.gameObject:SetActive(true)
            self.PanelTeamSupport.gameObject:SetActive(false)
        elseif inEchelonType == XDataCenter.BfrtManager.EchelonType.Logistics then
            self.TxtEchelonIndexA.text = CS.XTextManager.GetText("BfrtLogisticEchelonTitleSimple", inEchelonIndex)
            self.PanelTeamSupport.gameObject:SetActive(true)
            self.PanelTeam.gameObject:SetActive(false)
        end
    else
        self.PanelTeam.gameObject:SetActive(false)
        self.PanelTeamSupport.gameObject:SetActive(false)
    end
end

function XUiGridBfrtCharacter:SetSelect(isSelect)
    self.PanelSelected.gameObject:SetActive(isSelect)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiGridBfrtCharacter:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiGridBfrtCharacter:AutoInitUi()
    self.PanelSelected = self.Transform:Find("PanelSelected")
    self.TxtFight = self.Transform:Find("PaneFight/TxtFight"):GetComponent("Text")
    self.TxtLevel = self.Transform:Find("PaneLevel/TxtLevel"):GetComponent("Text")
    self.RImgQuality = self.Transform:Find("RImgQuality"):GetComponent("RawImage")
    self.RImgHeadIcon = self.Transform:Find("PaneHead/RImgHeadIcon"):GetComponent("RawImage")
    self.BtnCharacter = self.Transform:Find("BtnCharacter"):GetComponent("Button")
    self.PanelTeam = self.Transform:Find("PanelTeam")
    self.TxtEchelonIndex = self.Transform:Find("PanelTeam/TxtEchelonIndex"):GetComponent("Text")
    self.PanelTeamSupport = self.Transform:Find("PanelTeamSupport")
    self.TxtEchelonIndexA = self.Transform:Find("PanelTeamSupport/TxtEchelonIndex"):GetComponent("Text")
end

function XUiGridBfrtCharacter:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiGridBfrtCharacter:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiGridBfrtCharacter:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiGridBfrtCharacter:AutoAddListener()
    self:RegisterClickEvent(self.BtnCharacter, self.OnBtnCharacterClick)
end
-- auto
function XUiGridBfrtCharacter:OnBtnCharacterClick(...)
    self.RootUi:OnSelectCharacter(self.Character.Id)
end

return XUiGridBfrtCharacter