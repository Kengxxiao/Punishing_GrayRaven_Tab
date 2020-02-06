local XUiGridAutoFightMember = XClass()

function XUiGridAutoFightMember:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform

    XTool.InitUiObject(self)
end

function XUiGridAutoFightMember:UpdateMember(characterId, isLock)
    local isExistChar = characterId ~= nil and characterId ~= 0
    self.GameObject:SetActiveEx(isExistChar)

    if isExistChar then
        self.RImgHead:SetRawImage(XDataCenter.CharacterManager.GetCharRoundnessHeadIcon(characterId))
        self.TxtNickName.text = XCharacterConfigs.GetCharacterFullNameStr(characterId)
    end
    self.TxtLock.gameObject:SetActiveEx(isLock)
end

return XUiGridAutoFightMember