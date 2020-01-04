XUiPanelSetHeadPotrait = XClass()

function XUiPanelSetHeadPotrait:Ctor(ui, base)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Base = base
    XTool.InitUiObject(self)
    self:AutoAddListener()
    self.HeadPortraitPrefab = self.PanelHeadPortrait.gameObject
    self.CurrHeadPortraitId = {}
    self.OldSelectGrig = {}
    self:InitDynamicTable()
end

function XUiPanelSetHeadPotrait:InitDynamicTable()
    self.DynamicTable = XDynamicTableNormal.New(self.ScrollView)
    self.DynamicTable:SetProxy(XUiPanelHeadPortrait)
    self.DynamicTable:SetDelegate(self)
    self.PanelHeadPortrait.gameObject:SetActive(false)
end

function XUiPanelSetHeadPotrait:SetupDynamicTable(index)
    self.PageDatas = XPlayer.GetUnlockedHeadPortraitIds()
    self.DynamicTable:SetDataSource(self.PageDatas)
    self.DynamicTable:ReloadDataSync(index and index or 1)
end

function XUiPanelSetHeadPotrait:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        --grid:UpdateGrid(self.PageDatas[index],self)
        --self:SetHeadPortraitRedPoint(grid)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        grid:UpdateGrid(self.PageDatas[index],self)
        self:SetHeadPortraitRedPoint(grid)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then 
    end
end

function XUiPanelSetHeadPotrait:SetHeadPortraitRedPoint(grid)
    grid:ShowRedPoint(XDataCenter.HeadPortraitManager.CheakIsNewHeadPortraitById(grid.HeadPortraitId),false)
end

function XUiPanelSetHeadPotrait:AutoAddListener()
    self.BtnHeadSure.CallBack = function()
        self:OnBtnHeadSureClick()
    end
    self.BtnHeadCancel.CallBack = function()
        self:OnBtnHeadCancelClick()
    end
    self.BtnClose.CallBack = function()
        self:OnBtnHeadCancelClick()
    end
end

function XUiPanelSetHeadPotrait:OnBtnHeadSureClick(...)
    if self.BtnHeadSure.ButtonState == CS.UiButtonState.Disable then
        return
    end
    if self.TempHeadPortraitId ~= nil then
        if self.TempHeadPortraitId == XPlayer.CurrHeadPortraitId then
            self.Base:HidePanelSetHeadPotrait()
        else
            XPlayer.ChangeHeadPortrait(self.TempHeadPortraitId, function()
                self.Base:ChangeHeadPortraitCallback()
            end)
        end
    end
    XEventManager.DispatchEvent(XEventId.EVENT_HEAD_PORTRAIT_RESETINFO)
end

function XUiPanelSetHeadPotrait:OnBtnHeadCancelClick(...)
    self.TempHeadPortraitId = XPlayer.CurrHeadPortraitId
    self.Base:HidePanelSetHeadPotrait()
    XEventManager.DispatchEvent(XEventId.EVENT_HEAD_PORTRAIT_RESETINFO)
end

function XUiPanelSetHeadPotrait:SetImgRole(icon, headPortraitId)
    local info = XPlayerManager.GetHeadPortraitInfoById(headPortraitId)
    if (info ~= nil) then
        self.RImgPlayerIcon:SetRawImage(icon)
        self.TempHeadPortraitId = headPortraitId
        self.TxtHeadName.text = info.Name
        if info.Effect then
            self.HeadIconEffect.gameObject:LoadPrefab(info.Effect)
            self.HeadIconEffect.gameObject:SetActiveEx(true)
            self.HeadIconEffect:Init()
        else
            self.HeadIconEffect.gameObject:SetActiveEx(false)
        end
        self:SetHeadPotraitData(info,headPortraitId)
    end
end

function XUiPanelSetHeadPotrait:ShowPreviewHeadPortrait()
    self.CurrHeadPortraitId = XPlayer.CurrHeadPortraitId
    self.OldSelectGrig = nil
    local info = XPlayerManager.GetHeadPortraitInfoById(self.CurrHeadPortraitId)
    if (info ~= nil) then
        self.RImgPlayerIcon:SetRawImage(info.ImgSrc)
        self.TxtHeadName.text = info.Name
        self.TempHeadPortraitId = self.CurrHeadPortraitId
        if info.Effect then
            self.HeadIconEffect.gameObject:LoadPrefab(info.Effect)
            self.HeadIconEffect.gameObject:SetActiveEx(true)
            self.HeadIconEffect:Init()
        else
            self.HeadIconEffect.gameObject:SetActiveEx(false)
        end
        self:SetHeadPotraitData(info,self.CurrHeadPortraitId)
        self:SetupDynamicTable(XPlayerManager.GetHeadPortraitNumById(self.CurrHeadPortraitId))
    end
end

function XUiPanelSetHeadPotrait:SetHeadPotraitData(info,Id)
    local IsHeadPortraitUnlock = XPlayer.IsHeadPortraitUnlock(Id)
    
    self.TxtDecs.text = info.WorldDesc
    self.TxtCondition.text = XDataCenter.HeadPortraitManager.GetHowToGetTextById(info.LockDescId).Description
    self.TxtConditionLock.text = XDataCenter.HeadPortraitManager.GetHowToGetTextById(info.LockDescId).Description
    
    if Id == self.CurrHeadPortraitId then
        self.BtnHeadSure:SetButtonState(CS.UiButtonState.Disable)
        self.BtnIsUsing.gameObject:SetActive(true)
        self.BtnIsNotHave.gameObject:SetActive(false)
        self.TxtCondition.gameObject:SetActive(false)
        self.TxtConditionLock.gameObject:SetActive(true)
    elseif not IsHeadPortraitUnlock then
        self.BtnHeadSure:SetButtonState(CS.UiButtonState.Disable)
        self.BtnIsUsing.gameObject:SetActive(false)
        self.BtnIsNotHave.gameObject:SetActive(true)
        self.TxtCondition.gameObject:SetActive(true)
        self.TxtConditionLock.gameObject:SetActive(false)
    else
        self.BtnHeadSure:SetButtonState(CS.UiButtonState.Normal)
        self.TxtCondition.gameObject:SetActive(false)
        self.TxtConditionLock.gameObject:SetActive(true)
    end
end

function XUiPanelSetHeadPotrait:Release()
end