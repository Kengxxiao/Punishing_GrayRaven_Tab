local XUiBabelMemberHead = XClass()

function XUiBabelMemberHead:Ctor(ui, index)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Index = index

    XTool.InitUiObject(self)
    self.UiButtonComp = self.Transform:GetComponent("XUiButton")
end

function XUiBabelMemberHead:ClearMemberHead()
    self.RImgRole.gameObject:SetActiveEx(false)
    self.ImgLeader.gameObject:SetActiveEx(self:IsLeader())
    self.ImgSword.gameObject:SetActiveEx(false)
end

function XUiBabelMemberHead:SetMemberInfo(characterId, isHalf)
    self.CharacterId = characterId
    if not characterId or characterId == 0 then 
        self:ClearMemberHead()
        return 
    end
    local character = XDataCenter.CharacterManager.GetCharacter(self.CharacterId)
    if not character then
        self:ClearMemberHead()
        return 
    end
    
    self.RImgRole.gameObject:SetActiveEx(true)
    self.ImgLeader.gameObject:SetActiveEx(self:IsLeader())
    self.ImgSword.gameObject:SetActiveEx(true)

    if isHalf then
        self.RImgRole:SetRawImage(XDataCenter.CharacterManager.GetCharHalfBodyImage(self.CharacterId))
    else
        self.RImgRole:SetRawImage(XDataCenter.CharacterManager.GetCharSmallHeadIcon(self.CharacterId))
    end

    self.TxtSword.text = math.floor(character.Ability)
end

function XUiBabelMemberHead:SetMemberCallBack(cb)
    if cb and self.UiButtonComp then
        self.UiButtonComp.CallBack = function() cb() end
    end
end

function XUiBabelMemberHead:IsLeader()
    return self.Index == XFubenBabelTowerConfigs.LEADER_POSITION
end

return XUiBabelMemberHead