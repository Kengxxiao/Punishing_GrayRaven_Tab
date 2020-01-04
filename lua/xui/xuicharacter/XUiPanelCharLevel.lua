XUiPanelCharLevel = XClass()

function XUiPanelCharLevel:Ctor(ui, parent)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Parent = parent
    XTool.InitUiObject(self)
    self:AutoAddListener()
    self.SelectLevelItems = XUiPanelSelectLevelItems.New(self.PanelSelectLevelItems, self.Parent, self)
end

function XUiPanelCharLevel:AutoAddListener()
    self.BtnLevelUpButton.CallBack = function ()
        self:OnBtnLevelUpButtonClick() 
    end
    self.BtnLiberation.CallBack = function ()
        self:OnBtnLiberationClick() 
    end
end

function XUiPanelCharLevel:OnBtnLevelUpButtonClick()
    self.SelectLevelItems:ShowPanel(self.CharacterId)
    self.SelectLevelItemsEnable:PlayTimelineAnimation()
    self.PanelLeveInfo.gameObject:SetActive(false)
end

function XUiPanelCharLevel:OnBtnLiberationClick()
    local characterId = self.CharacterId
    XLuaUiManager.Open("UiExhibitionInfo", characterId)
end

function XUiPanelCharLevel:OnCheckExhibitionRedPoint(count)
    self.BtnLiberation:ShowReddot(count >= 0)
end

function XUiPanelCharLevel:ShowPanel(characterId)
    self.CharacterId = characterId or self.CharacterId
    self.IsShow = true
    self.GameObject:SetActive(true)
    self.PanelLeveInfo.gameObject:SetActive(true)
    self.LeveInfoQiehuan:PlayTimelineAnimation()
    self:HideSelectLevelItems()
    self:UpdatePanel()
    self:CheckMaxLevel()
    self:UpdateLiberationProgress()
    XRedPointManager.AddRedPointEvent(self.BtnLiberation, self.OnCheckExhibitionRedPoint, self, { XRedPointConditions.Types.CONDITION_EXHIBITION_NEW }, characterId)
end

function XUiPanelCharLevel:HidePanel()
    self.IsShow = false
    self.GameObject:SetActive(false)
    self:HideSelectLevelItems()
end

function XUiPanelCharLevel:HideSelectLevelItems()
    if self.GameObject.activeSelf then
        self.SelectLevelItemsDisable:PlayTimelineAnimation()
    end
    self.SelectLevelItems:HidePanel()
end

function XUiPanelCharLevel:CheckMaxLevel()
    local isMaxLevel = XDataCenter.CharacterManager.IsMaxLevel(self.CharacterId)
    self.BtnLevelUpButton.gameObject:SetActive(not isMaxLevel)
    self.ImgMaxLevel.gameObject:SetActive(isMaxLevel)
end

function XUiPanelCharLevel:UpdatePanel()
    local characterId = self.CharacterId
    local character = XDataCenter.CharacterManager.GetCharacter(characterId)
    local nextLeveExp = XCharacterConfigs.GetNextLevelExp(characterId, character.Level)
    self.TxtCurLevel.text = character.Level
    self.TxtMaxLevel.text = "/" .. XCharacterConfigs.GetCharMaxLevel(characterId)
    self.TxtExp.text = character.Exp .. "/" .. nextLeveExp
    self.ImgFill.fillAmount = character.Exp / nextLeveExp
    self.TxtAttack.text = FixToInt(character.Attribs[XNpcAttribType.AttackNormal])
    self.TxtLife.text = FixToInt(character.Attribs[XNpcAttribType.Life])
    self.TxtDefense.text = FixToInt(character.Attribs[XNpcAttribType.DefenseNormal])
    self.TxtCrit.text = FixToInt(character.Attribs[XNpcAttribType.Crit])
end

function XUiPanelCharLevel:UpdateLiberationProgress()
    local characterId = self.CharacterId
    local growUpLevel = XDataCenter.ExhibitionManager.GetCharacterGrowUpLevel(characterId)
    local progress = (growUpLevel - 1) / (XCharacterConfigs.GrowUpLevel.End - 1)
    self.ImgLiberationProgress.fillAmount = progress
end