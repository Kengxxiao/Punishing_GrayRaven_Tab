XUiPanelFavorabilityExchangeRole = XClass()

function XUiPanelFavorabilityExchangeRole:Ctor(ui, uiRoot)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.UiRoot = uiRoot
    XTool.InitUiObject(self)
    
    self.BtnCancel.CallBack = function() self:OnBtnCancelClick() end
end


-- [刷新切换角色界面]
function XUiPanelFavorabilityExchangeRole:RefreshDatas()
    self:LoadDatas()
end

function XUiPanelFavorabilityExchangeRole:LoadDatas()
    local characterId = self.UiRoot:GetCurrFavorabilityCharacter()
    local allCharDatas = XDataCenter.CharacterManager.GetCharacterList()
    local characterList = {}
    for _, v in pairs(allCharDatas or {}) do
        local isOwn = XDataCenter.CharacterManager.IsOwnCharacter(v.Id)
        if isOwn then
            table.insert(characterList, {
                Id = v.Id,
                TrustLv = v.TrustLv or 1,
                Selected = (characterId == v.Id)
            })
        end
    end
    table.sort(characterList, function(characterA, characterB)
        if characterA.TrustLv == characterB.TrustLv then
            return characterA.Id < characterB.Id
        end
        return characterA.TrustLv > characterB.TrustLv
    end)

    self:UpdateCharacterList(characterList)
end

-- [刷新角色ListView]
function XUiPanelFavorabilityExchangeRole:UpdateCharacterList(charList)
    if not charList then
        XLog.Warning("XUiPanelFavorabilityExchangeRole:UpdateCharacterList error: charList is nil")
        return 
    end

    self.CharList = charList
    
    if not self.DynamicTabelCharacters then
        self.DynamicTabelCharacters = XDynamicTableNormal.New(self.SViewSelectRole.gameObject)
        self.DynamicTabelCharacters:SetProxy(XUiGridLikeRoleItem)
        self.DynamicTabelCharacters:SetDelegate(self)
    end

    self.DynamicTabelCharacters:SetDataSource(self.CharList)
    self.DynamicTabelCharacters:ReloadDataASync()
    
end

-- [监听动态列表事件]
function XUiPanelFavorabilityExchangeRole:OnDynamicTableEvent(event, index, grid)
    local characterId = self.UiRoot:GetCurrFavorabilityCharacter()
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:Init(self.UiRoot)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local data = self.CharList[index]
        if not data then return end
        grid:OnRefresh(self.CharList[index], index)
        if characterId == data.Id then
            self.CurCharacter = self.CharList[index]
            self.CurCharacterGrid = grid
        end
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then
        self.CurCharacter = self.CharList[index]
        local isOwn = XDataCenter.CharacterManager.IsOwnCharacter(self.CurCharacter.Id)
        if not isOwn then
            XUiManager.TipMsg(CS.XTextManager.GetText("FavorabilityNotOwnChar"))
            return
        end

        if self.CurCharacterGrid then
            if self.CurCharacter then
                self.CurCharacter.Selected = false
            end
            self.CurCharacterGrid:OnSelect()
        end

        self.CurCharacter.Selected = true
        grid:OnSelect()
        self.CurCharacterGrid = grid
        self:OnChangeCharacter()
    end
end

-- [换人确定按钮]
function XUiPanelFavorabilityExchangeRole:OnChangeCharacter()
    if self.CurCharacter == nil then
        return 
    end
    
    local isOwn = XDataCenter.CharacterManager.IsOwnCharacter(self.CurCharacter.Id)
    if not isOwn then
        XUiManager.TipError(CS.XTextManager.GetText("FavorabilityNotOwnChar"))
        return 
    end

    self.UiRoot:SetCurrFavorabilityCharacter(self.CurCharacter.Id)
    self.UiRoot:UpdateCamera(false)
    self.UiRoot:CloseChangeRoleView()
end

-- [取消按钮]
function XUiPanelFavorabilityExchangeRole:OnBtnCancelClick(eventData)
    local characterId = self.UiRoot:GetCurrFavorabilityCharacter()
    self.UiRoot:ChangeCharacterModel(characterId)
    self.UiRoot:UpdateCamera(false)
    self.UiRoot:CloseChangeRoleView()
end

return XUiPanelFavorabilityExchangeRole
