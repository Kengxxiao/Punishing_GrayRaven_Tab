local XUiGridDetailDormCharacter = XClass()

function XUiGridDetailDormCharacter:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
end

function XUiGridDetailDormCharacter:Refresh(characterId, isLike)
    self.CharacterId = characterId

    local charStyleConfig = XDormConfig.GetCharacterStyleConfigById(characterId)
    self.RImgHead:SetRawImage(charStyleConfig.HeadRoundIcon, nil, true)

    self.PanelLikeIcon.gameObject:SetActive(isLike)
    self.PanelHateIcon.gameObject:SetActive(not isLike)

    self.TxtCharacterName.text = charStyleConfig.Name
end

return XUiGridDetailDormCharacter