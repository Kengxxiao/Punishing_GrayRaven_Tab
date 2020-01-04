XUiPanelFavorabilityFile = XClass()

function XUiPanelFavorabilityFile:Ctor(ui, uiRoot, parent)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.UiRoot = uiRoot
    self.Parent = parent
    XTool.InitUiObject(self)
end

function XUiPanelFavorabilityFile:OnRefresh()
    self:RefreshDatas()
end

function XUiPanelFavorabilityFile:RefreshDatas()
    local characterId = self.UiRoot:GetCurrFavorabilityCharacter()
    if not characterId then return end
    local fileData = XFavorabilityConfigs.GetCharacterBaseDataById(characterId)
    
    if fileData == nil then
        return 
    end

    self.TxtRoleName.text = XDataCenter.FavorabilityManager.GetNameWithTitleById(characterId)
    self.TxtServiceTime.text = fileData.ServerTime
    self.TxtStartup.text = fileData.StartupTime
    self.TxtRoleType.text = fileData.LoopType
    self.TxtPsycAge.text = fileData.MentalAge
    self.TxtWeight.text = fileData.Weight
    self.TxtHeight.text = fileData.Height
end

function XUiPanelFavorabilityFile:SetViewActive(isActive)
    self.GameObject:SetActive(isActive)
    if isActive then
        self:RefreshDatas()
    end
end

return XUiPanelFavorabilityFile
