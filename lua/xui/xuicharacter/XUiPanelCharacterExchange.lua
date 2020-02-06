local XUiPanelCharacterExchange = XLuaUiManager.Register(XLuaUi, "UiPanelCharacterExchange")

function XUiPanelCharacterExchange:OnAwake()
    self:AutoAddListener()
    self.GridCharacterNew.gameObject:SetActive(false)
end

function XUiPanelCharacterExchange:OnStart(parent, closeCb)
    self.DynamicTable = XDynamicTableNormal.New(self.PanelScrollView)
    self.DynamicTable:SetProxy(XUiGridCharacterNew)
    self.DynamicTable:SetDelegate(self)

    self.Parent = parent
    self.CloseCb = closeCb
end

function XUiPanelCharacterExchange:OnEnable()
    self:SetupDynamicTable()
end

function XUiPanelCharacterExchange:SetupDynamicTable()
    self.CharacterId = self.Parent.CharacterId

    self.CharList = XDataCenter.CharacterManager.GetOwnCharacter()
    if not self.CharList then
        return
    end

    local len = #self.CharList
    local index = 1

    for i = 1, len do
        if self.CharList[i].Id == self.CharacterId then
            index = i
            break
        end
    end

    self.DynamicTable:SetDataSource(self.CharList)
    self.DynamicTable:ReloadDataASync(index)
end

function XUiPanelCharacterExchange:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:Init(self)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local data = self.CharList[index]
        grid:Reset()
        grid:UpdateGrid(data)

        if self.CharacterId == data.Id then
            self.CurSelectGrid = grid
        end

        grid:SetSelect(self.CharacterId == data.Id)
        grid:SetCurSignState(self.CharacterId == data.Id)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then
        local charData = self.CharList[index]
        if XCharacterConfigs.GetCharacterTemplate(charData.Id).Foreshow == 0 then
            if self.CharacterId ~= charData.Id then
                self.CharacterId = charData.Id

                if self.CurSelectGrid then
                    self.CurSelectGrid:SetSelect(false)
                    self.CurSelectGrid:SetCurSignState(false)
                end

                grid:SetSelect(true)
                grid:SetCurSignState(true)
                self.CurSelectGrid = grid
            end

            self:OnSelectCharacter()
        else
            XUiManager.TipMsg(CS.XTextManager.GetText("ComingSoon"), XUiManager.UiTipType.Tip)
        end
    end
end

function XUiPanelCharacterExchange:AutoAddListener()
    self:RegisterClickEvent(self.BtnCancel, self.OnBtnCancelClick)
end

function XUiPanelCharacterExchange:OnBtnCancelClick(eventData)
    self:OnSelectCharacter()
end

function XUiPanelCharacterExchange:OnSelectCharacter()
    if self.CloseCb then
        self.CloseCb(self.CharacterId)
    end
end

return XUiPanelCharacterExchange
