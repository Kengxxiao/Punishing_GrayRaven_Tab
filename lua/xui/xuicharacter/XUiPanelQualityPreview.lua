local stringFormat = string.format

local XUiPanelQualityPreview = XLuaUiManager.Register(XLuaUi, "UiPanelQualityPreview")

local Show_Part = {
    [1] = XNpcAttribType.Life,
    [2] = XNpcAttribType.AttackNormal,
    [3] = XNpcAttribType.DefenseNormal,
    [4] = XNpcAttribType.Crit,
}

function XUiPanelQualityPreview:OnAwake()
    self:AutoAddListener()
end

function XUiPanelQualityPreview:OnStart(characterId)
    self.CharacterId = characterId
end

function XUiPanelQualityPreview:OnEnable()
    self:RefreshAttrib()
end

function XUiPanelQualityPreview:AutoAddListener()
    self:RegisterClickEvent(self.BtnDarkBg, self.OnBtnDarkBgClick)
end

function XUiPanelQualityPreview:RefreshAttrib()
    local characterId = self.CharacterId
    local curCharacter = XDataCenter.CharacterManager.GetCharacter(self.CharacterId)
    local quality = curCharacter.Quality
    local nextQulity = curCharacter.Quality + 1
    local curAttrib = XCharacterConfigs.GetNpcPromotedAttribByQuality(characterId, quality)
    local nextAttrib = XCharacterConfigs.GetNpcPromotedAttribByQuality(characterId, nextQulity)

    for i = 1, 4 do
        local attribType = Show_Part[i]
        local name = XAttribManager.GetAttribNameByIndex(attribType)
        self["TxtInfoName" .. i].text = CS.XTextManager.GetText("CharQuiltyLevelUp", name)
        self["TxtNormal" .. i].text = stringFormat("%.2f", FixToDouble(curAttrib[attribType]))
        self["TxtLevel" .. i].text = stringFormat("%.2f", FixToDouble(nextAttrib[attribType]))
    end
    self.RImgQuality:SetRawImage(XCharacterConfigs.GetCharQualityIcon(quality))
    self.RImgQuality1:SetRawImage(XCharacterConfigs.GetCharQualityIcon(quality + 1))
end

function XUiPanelQualityPreview:OnBtnDarkBgClick()
    self:Close()
end