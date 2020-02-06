local XUiBabelMemberSmallHead = XClass()

function XUiBabelMemberSmallHead:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform

    XTool.InitUiObject(self)
end

function XUiBabelMemberSmallHead:UpdateMember(characterId)
    self.ImgIcon:SetRawImage(XDataCenter.CharacterManager.GetCharRoundnessHeadIcon(characterId))
    local character = XDataCenter.CharacterManager.GetCharacter(characterId)
end

return XUiBabelMemberSmallHead