local XUiBabelTowerRoomCharacter = XLuaUiManager.Register(XLuaUi, "UiBabelTowerRoomCharacter")

function XUiBabelTowerRoomCharacter:OnAwake()
    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.FreeGem, XDataCenter.ItemManager.ItemId.ActionPoint, XDataCenter.ItemManager.ItemId.Coin)
    self.BtnBack.CallBack = function() self:OnBtnBackClick() end
    self.BtnMainUi.CallBack = function() self:OnBtnMainUiClick() end
    
    self.BtnFashion.CallBack = function() self:OnBtnFashionClick() end
    self.BtnConsciousness.CallBack = function() self:OnBtnConsciousnessClick() end
    self.BtnWeapon.CallBack = function() self:OnBtnWeaponClick() end
    self.BtnJoinTeam.CallBack = function() self:OnBtnJoinTeamClick() end
    self.BtnQuitTeam.CallBack = function() self:OnBtnQuitTeamClick() end

    local root = self:GetSceneRoot().transform
    self.PanelRoleModel = self:GetSceneRoot().transform:FindTransform("PanelRoleModel")
    self.ImgEffectHuanren = root:FindTransform("ImgEffectHuanren")

    -- TxtRequireAbility
    self.CharacterItemList = {}
end

function XUiBabelTowerRoomCharacter:OnBtnBackClick()
    self:Close()
end

function XUiBabelTowerRoomCharacter:OnBtnMainUiClick()
    XLuaUiManager.RunMain()
end

function XUiBabelTowerRoomCharacter:OnBtnFashionClick()
    if not self.CurCharacter then return end
    XLuaUiManager.Open("UiFashion", self.CurCharacter.Id)
end

function XUiBabelTowerRoomCharacter:OnBtnConsciousnessClick()
    if not self.CurCharacter then return end
    XLuaUiManager.Open("UiEquipAwarenessReplace", self.CurCharacter.Id, nil, true)
end

function XUiBabelTowerRoomCharacter:OnBtnWeaponClick()
    if not self.CurCharacter then return end
    XLuaUiManager.Open("UiEquipReplaceNew", self.CurCharacter.Id, nil, true)
end

-- 加入队伍
function XUiBabelTowerRoomCharacter:OnBtnJoinTeamClick()
    if not self.CurCharacter then return end
    if self.CallBack then
        self.CallBack(self.CurCharacter.Id, true)
    end
    self:Close()
end

-- 移出队伍
function XUiBabelTowerRoomCharacter:OnBtnQuitTeamClick()
    if not self.CurCharacter then return end
    if self.CallBack then
        self.CallBack(self.CurCharacter.Id, false)
    end
    self:Close()
end


function XUiBabelTowerRoomCharacter:OnStart(selectableList, currentTeamList, defaultSelect, cb)
    self.RoleModelPanel = XUiPanelRoleModel.New(self.PanelRoleModel, nil, nil, true)
    self.SelectableList = selectableList
    self.CurrentTeamList = currentTeamList
    self.DefaultSelectChar = defaultSelect
    if (not self.DefaultSelectChar or self.DefaultSelectChar == 0) and self.SelectableList[1] then
        self.DefaultSelectChar = self.SelectableList[1].CharacterId
    end
    self.CallBack = cb

    self:SetCharacterList()
end

function XUiBabelTowerRoomCharacter:OnEnable()
    if self.CharacterItemList then
        for i=1, #self.SelectableList do
            local characterId = self.SelectableList[i].CharacterId
            local char = XDataCenter.CharacterManager.GetCharacter(characterId)
            if self.CharacterItemList[characterId] then
                self.CharacterItemList[characterId]:UpdateGrid(char)
            end
        end
    end
    if self.CurCharacter then
        self:UpdateRoleMode(self.CurCharacter.Id)
    end
end

function XUiBabelTowerRoomCharacter:SetCharacterList()
    local defaultCharacter = nil
    for i=1, #self.SelectableList do
        local characterId = self.SelectableList[i].CharacterId
        local char = XDataCenter.CharacterManager.GetCharacter(characterId)
        if self.DefaultSelectChar and characterId == self.DefaultSelectChar then
            defaultCharacter = char
        end
        if not self.CharacterItemList[characterId] then
            local item= CS.UnityEngine.Object.Instantiate(self.GridCharacter)
            local grid = XUiGridCharacter.New(self, item, char, function(character)
                self:OnCharacterClick(character)
            end)
            grid.GameObject:SetActiveEx(true)
            grid.Transform:SetParent(self.PanelRoleContent, false)
            self.CharacterItemList[characterId] = grid
        end
        self.CharacterItemList[characterId]:UpdateGrid(char)
        self.CharacterItemList[characterId]:SetInTeam(self.SelectableList[i].IsInTeam)
    end
    self:SelectCharacter(self.DefaultSelectChar)
end

function XUiBabelTowerRoomCharacter:GetIndexByCharacterId(id)
    for i=1, #self.SelectableList do
        local characterId = self.SelectableList[i].CharacterId
        if characterId == id then
            return i
        end
    end
    return 0
end

function XUiBabelTowerRoomCharacter:OnCharacterClick(character)
    if self.CurCharacter and self.CurCharacter == character then
        return 
    end
    if character then
        self.CurCharacter = character
    end

    if self.CurCharacterItem then
        self.CurCharacterItem:SetSelect(false)
    end

    self.CurCharacterItem = self.CharacterItemList[self.CurCharacter.Id]
    self.CurCharacterItem:UpdateGrid()
    self.CurCharacterItem:SetSelect(true)
    
    -- 更新按钮状态
    self:UpdateBtns(self.CurCharacter.Id)
    
    self:UpdateRoleMode(self.CurCharacter.Id)
end

-- 更新按钮状态
function XUiBabelTowerRoomCharacter:UpdateBtns(curCharacterId)
    local isInTeam = false
    for _, member_char_id in pairs(self.CurrentTeamList or {}) do
        if curCharacterId == member_char_id then
            isInTeam = true
            break
        end
    end
    self.BtnJoinTeam.gameObject:SetActiveEx(not isInTeam)
    self.BtnQuitTeam.gameObject:SetActiveEx(isInTeam)
end

--更新模型
function XUiBabelTowerRoomCharacter:UpdateRoleMode(characterId)
    self.RoleModelPanel:UpdateCharacterModel(characterId, self.PanelRoleModel, XModelManager.MODEL_UINAME.XUiBabelTowerRoomCharacter, function(model)
        self.ImgEffectHuanren.gameObject:SetActiveEx(false)
        self.ImgEffectHuanren.gameObject:SetActiveEx(true)
        if not model then return end
        self.PanelDrag.Target = model.transform
    end)
end

-- 选一个角色
function XUiBabelTowerRoomCharacter:SelectCharacter(id)
    local grid = self.CharacterItemList[id]
    if grid then
        self:CenterToGrid(grid)
    end

    local character = grid and grid.Character
    self:OnCharacterClick(character)
end

function XUiBabelTowerRoomCharacter:CenterToGrid(grid)
    local normalizedPosition
    local count = self.SViewCharacterList.content.transform.childCount
    local index = grid.Transform:GetSiblingIndex()
    if index > count / 2 then
        normalizedPosition = (index + 1) / count
    else
        normalizedPosition = (index - 1) / count
    end

    self.SViewCharacterList.verticalNormalizedPosition = math.max(0, math.min(1, (1 - normalizedPosition)))
end




