local XUiUnlockShow = XLuaUiManager.Register(XLuaUi, "UiUnlockShow")

function XUiUnlockShow:OnAwake()
    self.ImgUnlockShowIcon.fillAmount = 0
end

function XUiUnlockShow:OnStart(characterId, closeCb)
    self.CharacterId = characterId
    self.CloseCb = closeCb
    self:UpdateUnLockPanleInfo()
end

function XUiUnlockShow:OnDestroy()
    if self.CloseCb then self.CloseCb() end
end

function XUiUnlockShow:UpdateUnLockPanleInfo()
    local characterId = self.CharacterId

    local bigIcon = XDataCenter.CharacterManager.GetCharSmallHeadIcon(characterId)
    self.RImgFashionIcon:SetRawImage(bigIcon)

    local fullName = XCharacterConfigs.GetCharacterFullNameStr(characterId)
    self.TxtUnlockFashionName.text = CS.XTextManager.GetText("CharUnlockTips", fullName)

    XUiHelper.PlayAnimation(self, "AniUnlockShowBegin", nil, function()
        XDataCenter.CharacterManager.ExchangeCharacter(characterId, function()
            self:Close()
        end)
    end)
end