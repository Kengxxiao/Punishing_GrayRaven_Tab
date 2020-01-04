
local CSXTextManagerGetText = CS.XTextManager.GetText

local XUiCharacterUnOwnedInfo = XLuaUiManager.Register(XLuaUi, "UiCharacterUnOwnedInfo")

function XUiCharacterUnOwnedInfo:OnAwake()
    self:AddListener()
end

function XUiCharacterUnOwnedInfo:OnStart(characterId)
    self.CharacterId = characterId
    self:RegisterRedPointEvent()
end

function XUiCharacterUnOwnedInfo:OnEnable()
    self:UpdateView(self.CharacterId)
end

function XUiCharacterUnOwnedInfo:PreSetCharacterId(characterId)
    self.CharacterId = characterId
end

function XUiCharacterUnOwnedInfo:RegisterRedPointEvent()
    self.RedPointId = XRedPointManager.AddRedPointEvent(self.ImgRedPointUnlock, self.OnCheckCharacterUnlockRedPoint, self, { XRedPointConditions.Types.CONDITION_CHARACTER_UNLOCK }, self.CharacterId)
end

function XUiCharacterUnOwnedInfo:OnCheckCharacterRedPoint(count, args)
    self.ImgRedPoint.gameObject:SetActive(count >= 0)
end

function XUiCharacterUnOwnedInfo:UpdateView(characterId)
    self.CharacterId = characterId
    
    local curFragment = XDataCenter.CharacterManager.GetCharUnlockFragment(characterId)
    local bornQuality = XCharacterConfigs.GetCharMinQuality(characterId)
    local bornGrade = XCharacterConfigs.GetCharMinGrade(characterId)
    local needFragment = XCharacterConfigs.GetComposeCount(bornQuality)
    local npcId = XCharacterConfigs.GetCharNpcId(characterId, bornQuality)
    local npc = CS.XNpcManager.GetNpcTemplate(npcId)

    self.TxtIntroduce.text = CSXTextManagerGetText("CharacterUnowenedIntroduce"
    , XCharacterConfigs.GetCharacterName(characterId)
    , XCharacterConfigs.GetCharacterTradeName(characterId)
    , XCharacterConfigs.GetCharacterIntro(characterId))
    self.TxtOwnFragmentNumber.text = curFragment .. ""
    self.TxtNeedFragmentNumber.text = "/" .. needFragment
    self.ImgFill.fillAmount = curFragment / needFragment

    local isCanUnlock = curFragment >= needFragment
    self.BtnUnlock:SetDisable(not isCanUnlock)

    self.RImgBornQuality:SetRawImage(XCharacterConfigs.GetCharQualityIcon(bornQuality))
    self.RImgBornGradeIcon:SetRawImage(XCharacterConfigs.GetCharGradeIcon(characterId, bornGrade))
    self.RImgUnownedTypeIcon:SetRawImage(XCharacterConfigs.GetNpcTypeIcon(npc.Type))
end

function XUiCharacterUnOwnedInfo:AddListener()
    self:RegisterClickEvent(self.BtnGet, self.OnBtnGetClick)
    self:RegisterClickEvent(self.BtnUnlock, self.OnBtnUnlockClick)
end

function XUiCharacterUnOwnedInfo:OnBtnUnlockClick()
    local characterId = self.CharacterId
    local curFragment = XDataCenter.CharacterManager.GetCharUnlockFragment(characterId)
    local bornQuality = XCharacterConfigs.GetCharMinQuality(characterId)
    local needFragment = XCharacterConfigs.GetComposeCount(bornQuality)
    if curFragment >= needFragment then
        CS.XAudioManager.PlaySound(XSoundManager.UiBasicsMusic.UiCharacter_UnlockBegin)
        XLuaUiManager.Open("UiUnlockShow", characterId, function()
            local title = CSXTextManagerGetText("CharacterUnlockNewCharacter")
            local content = XCharacterConfigs.GetCharacterFullNameStr(characterId)
            XLuaUiManager.Open("UiLeftPopupTip", title, content)
            CS.XAudioManager.PlaySound(XSoundManager.UiBasicsMusic.UiCharacter_UnlockEnd)
        end)
    end
end

function XUiCharacterUnOwnedInfo:OnBtnGetClick()
    local useItemId = XCharacterConfigs.GetCharacterTemplate(self.CharacterId).ItemId
    XLuaUiManager.Open("UiTip", XDataCenter.ItemManager.GetItem(useItemId))
end