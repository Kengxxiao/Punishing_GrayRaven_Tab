local XUiFavorabilityLineRoomCharacter = XLuaUiManager.Register(XLuaUi, "UiFavorabilityLineRoomCharacter")


function XUiFavorabilityLineRoomCharacter:OnAwake()
    self:InitUi()

    local root = self:GetSceneRoot().transform
    self.PanelRoleModel = self:GetSceneRoot().transform:FindTransform("PanelRoleModel")
    self.ImgEffectHuanren = root:FindTransform("ImgEffectHuanren")
end

function XUiFavorabilityLineRoomCharacter:InitUi()
    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.FreeGem, XDataCenter.ItemManager.ItemId.ActionPoint, XDataCenter.ItemManager.ItemId.Coin)
    self.BtnBack.CallBack = function()
        self:Close()
    end

    self.BtnMainUi.CallBack = function()
        XLuaUiManager.RunMain()
    end

    self.BtnExchange.CallBack = function()
        self:OnBtnExchangeClick()
    end

    self.BtnFashion.CallBack = function()
        self:OnBtnFashionClick()
    end

    
    self.DynamicTableCharacter = XDynamicTableNormal.New(self.SViewCharacterList.gameObject)
    self.DynamicTableCharacter:SetProxy(XUiGridLineCharacter)
    self.DynamicTableCharacter:SetDelegate(self)
    
end

function XUiFavorabilityLineRoomCharacter:OnStart(...)
    self.RoleModelPanel = XUiPanelRoleModel.New(self.PanelRoleModel, self.Name, nil, true)
    self.Characters = self:LoadDatas()


    local index = 1
    for i,v in ipairs(self.Characters) do
        if v.Selected then
            self.CurCharacter = v
            index = i
            break
        end
    end
    
    self.DynamicTableCharacter:SetDataSource(self.Characters)
    self.DynamicTableCharacter:ReloadDataASync(index)
end

function XUiFavorabilityLineRoomCharacter:OnEnable()

    local curAssistantId = self.CurCharacter and self.CurCharacter.Id or XDataCenter.DisplayManager.GetDisplayChar().Id
    self:UpdateRoleModel(curAssistantId)
    self:UpdateChangeStatus(curAssistantId)
end

function XUiFavorabilityLineRoomCharacter:LoadDatas()
    local curAssistantId = XDataCenter.DisplayManager.GetDisplayChar().Id

    local allCharDatas = XDataCenter.CharacterManager.GetCharacterList()
    local characterList = {}
    for _, v in pairs(allCharDatas or {}) do
        local isOwn = XDataCenter.CharacterManager.IsOwnCharacter(v.Id)
        if isOwn then
            table.insert(characterList, {
                Id = v.Id,
                TrustLv = v.TrustLv or 1,
                Selected = (curAssistantId == v.Id),
            })
        end
    end
    table.sort(characterList, function(characterA, characterB)
        if characterA.TrustLv == characterB.TrustLv then
            return characterA.Id < characterB.Id
        end
        return characterA.TrustLv > characterB.TrustLv
    end)

    return characterList
end

-- [监听动态列表事件]
function XUiFavorabilityLineRoomCharacter:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:Init(self)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local data = self.Characters[index]
        if not data then return end
        grid:OnRefresh(self.Characters[index], index)
        local selected = data.Selected or false
        if selected then
            self.CurCharacter = self.Characters[index]
            self.CurCharacterGrid = grid
        end

        if data.Id == XDataCenter.DisplayManager.GetDisplayChar().Id then
            self.CurAssist = grid
        end

    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then
        if not self.Characters[index] then return end
        if self.CurCharacterGrid then
            if self.CurCharacter then
                self.CurCharacter.Selected = false
            end
            self.CurCharacterGrid:OnSelect()
        end
        self.CurCharacter = self.Characters[index]

        self.CurCharacter.Selected = true
        self.CurCharacterGrid = grid
        grid:OnSelect()
        self:UpdateRoleModel(self.CurCharacter.Id)

        self:UpdateChangeStatus(self.CurCharacter.Id)
    end
end

function XUiFavorabilityLineRoomCharacter:UpdateChangeStatus(characterId)
    local currDisplayId = XDataCenter.DisplayManager.GetDisplayChar().Id
    local isOwn = XDataCenter.CharacterManager.IsOwnCharacter(characterId)
    if not isOwn then
        self.BtnExchange:SetButtonState(CS.UiButtonState.Disable)
        return
    end
    local btnState = (currDisplayId ~= characterId) and CS.UiButtonState.Normal or CS.UiButtonState.Disable
    self.BtnExchange:SetButtonState(btnState)
    
end

function XUiFavorabilityLineRoomCharacter:OnBtnExchangeClick()
    if not self.CurCharacter then return end
    local isOwn = XDataCenter.CharacterManager.IsOwnCharacter(self.CurCharacter.Id)
    if not isOwn then
        XUiManager.TipMsg(CS.XTextManager.GetText("FavorabilityNotOwnChar"))
        return
    end

    local currDisplayId = XDataCenter.DisplayManager.GetDisplayChar().Id
    local characterId = self.CurCharacter.Id
    if currDisplayId ~= characterId then
        XDataCenter.DisplayManager.SetDisplayCharById(characterId, function()

            if self.CurAssist then
                self.CurAssist:RefreshAssist()
            end

            self.CurAssist = self.CurCharacterGrid
            self.CurCharacterGrid:RefreshAssist()

            self:UpdateChangeStatus(characterId)
            local currDisplayCharacterName = XCharacterConfigs.GetCharacterName(characterId)
            local displayTips = CS.XTextManager.GetText("FavorabilitySetAssistSucc", currDisplayCharacterName)
            XUiManager.TipMsg(displayTips)
        end)
    end
end

function XUiFavorabilityLineRoomCharacter:OnBtnFashionClick()
    if not self.CurCharacter then return end
    local isOwn = XDataCenter.CharacterManager.IsOwnCharacter(self.CurCharacter.Id)
    if not isOwn then
        XUiManager.TipMsg(CS.XTextManager.GetText("FavorabilityNotOwnChar"))
        return
    end

    XLuaUiManager.Open("UiFashion", self.CurCharacter.Id)
end

function XUiFavorabilityLineRoomCharacter:UpdateRoleModel(characterId)
    self.RoleModelPanel:UpdateCharacterModel(characterId, self.PanelRoleModel, XModelManager.MODEL_UINAME.XUiFavorabilityLineRoomCharacter, nil, function ()
        self.ImgEffectHuanren.gameObject:SetActive(false)
        self.ImgEffectHuanren.gameObject:SetActive(true)
    end)
end