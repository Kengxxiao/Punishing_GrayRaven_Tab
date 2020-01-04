local XUiGridCharacterIcon = XClass()

function XUiGridCharacterIcon:Ctor(RootUI, index, uiIcon, characterId)
    self.RootUI = RootUI
    self.Index = index
    self.GameObject = uiIcon.gameObject
    self.Transform = uiIcon.transform
    self.CharacterId = characterId
    self.Behaviour = self.GameObject:AddComponent(typeof(CS.XLuaBehaviour))
    XTool.InitUiObject(self)
    self:Refresh(characterId)
    self:AddBtnListener()
end

function XUiGridCharacterIcon:Refresh(characterId)
    self.CharacterId = characterId
    self.RImgIcon:SetRawImage(XDataCenter.ExhibitionManager.GetCharHeadPortrait(self.CharacterId))
    if self.CharacterId == nil or self.CharacterId == 0 then
        self.ImgMask.gameObject:SetActive(false)
        self.LevelPanel.gameObject:SetActive(false)
        self.ImgRedPoint.gameObject:SetActive(false)
    elseif self:IsOwnCharacter(self.CharacterId) then
        self.ImgMask.gameObject:SetActive(false)
        local growUpLevel = XDataCenter.ExhibitionManager.GetCharacterGrowUpLevel(self.CharacterId)
        local levelConfig = XExhibitionConfigs.GetExhibitionGrowUpLevelConfig(growUpLevel)
        if growUpLevel == XCharacterConfigs.GrowUpLevel.New then
            self.LevelPanel.gameObject:SetActive(false)
            self.RootUI:SetUiSprite(self.ImgIconFrame, levelConfig.IconFrame)
        else
            self.RootUI:SetUiSprite(self.ImgLevel, levelConfig.LevelLogo)
            self.RootUI:SetUiSprite(self.ImgLevelFrame, levelConfig.LevelFrame)
            self.RootUI:SetUiSprite(self.ImgIconFrame, levelConfig.IconFrame)
            self.LevelPanel.gameObject:SetActive(true)
        end
        if self.RootUI.IsSelf then
            local showRedPoint = XDataCenter.ExhibitionManager.CheckNewRewardByCharacterId(self.CharacterId)
            self.ImgRedPoint.gameObject:SetActive(showRedPoint)
        else
            self.ImgRedPoint.gameObject:SetActive(false)
        end
    else
        self.ImgMask.gameObject:SetActive(true)
        self.LevelPanel.gameObject:SetActive(false)
        self.ImgRedPoint.gameObject:SetActive(false)
    end
end

function XUiGridCharacterIcon:IsOwnCharacter(characterId)
    return XDataCenter.ExhibitionManager.CheckIsOwnCharacter(characterId)
end

function XUiGridCharacterIcon:AddBtnListener()
    self:RegisterClickEvent(self.BtnSelect, self.BtnSelectClick)
end

function XUiGridCharacterIcon:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiGridExhibition:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiGridExhibition:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiGridCharacterIcon:BtnSelectClick(eventData)
    if self.RootUI.IsSelf then
        if self.CharacterId == nil or self.CharacterId == 0 then
            XUiManager.TipText("ExhibitionUnknownCharacter")
        elseif XDataCenter.CharacterManager.IsOwnCharacter(self.CharacterId) then
            self.RootUI:StartFocus(self.Index, self.CharacterId)
        else
            XUiManager.TipText("ExhibitionNotObtainCharacter")
        end
    end
end

function XUiGridCharacterIcon:CharacterGrowUp()
    self.AnimCharacterIcon:Play()
    self.Behaviour.LuaUpdate = function() self:CheckAnimEnd() end
end

function XUiGridCharacterIcon:CheckAnimEnd()
    if self.AnimCharacterIcon.time > self.AnimCharacterIcon.duration / 2 then
        self:Refresh(self.CharacterId)
        self.Behaviour.LuaUpdate = nil
    end
end

return XUiGridCharacterIcon