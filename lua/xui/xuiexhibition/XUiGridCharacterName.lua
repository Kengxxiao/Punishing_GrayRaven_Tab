local XUiGridExhibitionName = XClass()

function XUiGridExhibitionName:Ctor(RootUI, index, uiName, characterId)
    self.RootUI = RootUI
    self.Index = index
    self.GameObject = uiName.gameObject
    self.Transform = uiName.transform
    self.CharacterId = characterId
    XTool.InitUiObject(self)
    self:Refresh(characterId)
end

function XUiGridExhibitionName:Refresh(characterId)
    self.CharacterId = characterId
    local name
    if self.CharacterId == nil or self.CharacterId == 0 then
        name = "???"
    else
        name = XCharacterConfigs.GetCharacterFullNameStr(self.CharacterId)
    end
    self.TxtName.text = name
end

function XUiGridExhibitionName:ResetPosition(position)
    self.Transform.position = position
end

return XUiGridExhibitionName