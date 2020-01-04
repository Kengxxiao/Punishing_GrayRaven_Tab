local XUiEquipResonanceSelectCharacter = XLuaUiManager.Register(XLuaUi, "UiEquipResonanceSelectCharacter")

function XUiEquipResonanceSelectCharacter:OnAwake()
    self:InitAutoScript()
    self.GridCharacter.gameObject:SetActive(false)
end

function XUiEquipResonanceSelectCharacter:OnStart(equipId, confirmCb)
    self.EquipId = equipId
    self.ConfirmCb = confirmCb
    self:InitCharacterList()
end

function XUiEquipResonanceSelectCharacter:InitCharacterList()
    self.CharacterGridDic = {}

    local clickCallback = function(character)
        if self.SelectCharacterId then
            self.CharacterGridDic[self.SelectCharacterId]:SetSelect(false)
        end
        self.SelectCharacterId = character.Id
        self.CharacterGridDic[self.SelectCharacterId]:SetSelect(true)
    end

    local noCharacter = true
    local canResonanceCharacterList = XDataCenter.EquipManager.GetCanResonanceCharacterList(self.EquipId)
    for _, character in pairs(canResonanceCharacterList) do
        if not self.CharacterGridDic[character.Id] then
            local item = CS.UnityEngine.Object.Instantiate(self.GridCharacter)
            local grid = XUiGridCharacter.New(self, item, character, clickCallback)
            grid.GameObject:SetActive(true)
            grid.Transform:SetParent(self.PanelCharacterContent, false)
            grid:UpdateGrid(character)
            self.CharacterGridDic[character.Id] = grid
            noCharacter = noCharacter and false
        end
    end
    self.PanelNoCharacter.gameObject:SetActive(noCharacter)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiEquipResonanceSelectCharacter:InitAutoScript()
    self:AutoAddListener()
end

function XUiEquipResonanceSelectCharacter:AutoAddListener()
    self:RegisterClickEvent(self.BtnConfirm, self.OnBtnConfirmClick)
    self:RegisterClickEvent(self.BtnClose, self.OnBtnCloseClick)
    self:RegisterClickEvent(self.Btncancel, self.OnBtnCloseClick)
end
-- auto
function XUiEquipResonanceSelectCharacter:OnBtnCloseClick(eventData)
    self:Close()
end

function XUiEquipResonanceSelectCharacter:OnBtnConfirmClick(eventData)
    if self.ConfirmCb then
        self.ConfirmCb(self.SelectCharacterId)
    end
    self:Close()
end