XUiGridLikeRoleItem = XClass()

function XUiGridLikeRoleItem:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
end

function XUiGridLikeRoleItem:Init(uiRoot)
    self.UiRoot = uiRoot
end

-- [刷新界面]
function XUiGridLikeRoleItem:OnRefresh(data, index)
    self.CharacterData = data
    self.TrustExp = XFavorabilityConfigs.GetTrustExpById(data.Id)
    self.RImgHeadIcon:SetRawImage(XDataCenter.CharacterManager.GetCharSmallHeadIcon(data.Id))
        self.ImgAssist.gameObject:SetActive(XDataCenter.DisplayManager.GetDisplayChar().Id == data.Id)
    
    local isOwn = XDataCenter.CharacterManager.IsOwnCharacter(data.Id)
    self.ImgLock.gameObject:SetActive(not isOwn)
    self.RImgAIxin.gameObject:SetActive(isOwn)
    
    if not isOwn then
        self.TxtDisplayLevel.text = ""
        self.ImgRedPoint.gameObject:SetActive(false)
    else
        local trustLv = data.TrustLv or 1
        self.TxtLevel.text = trustLv
        self.TxtDisplayLevel.text = XFavorabilityConfigs.GetWordsWithColor(trustLv, self.TrustExp[trustLv].Name)
        self.UiRoot:SetUiSprite(self.RImgAIxin, XFavorabilityConfigs.GetTrustLevelIconByLevel(data.TrustLv))

        self.ImgRedPoint.gameObject:SetActive(self:IsRed())
    end
    self:OnSelect()
end

-- [修改选中状态]
function XUiGridLikeRoleItem:OnSelect()
    local isSelect = self.CharacterData and self.CharacterData.Selected or false
    self.ImgSelected.gameObject:SetActive(isSelect)
end

-- [是否有红点]
function XUiGridLikeRoleItem:IsRed()
    if self.CharacterData then
        local characterId = self.CharacterData.Id
        local isOwn = XDataCenter.CharacterManager.IsOwnCharacter(characterId)
        if not isOwn then return false end

        local rumorReddot = XDataCenter.FavorabilityManager.HasRumorsToBeUnlock(characterId)
        local dataReddot = XDataCenter.FavorabilityManager.HasDataToBeUnlock(characterId)
        local audioReddot = XDataCenter.FavorabilityManager.HasAudioToBeUnlock(characterId)
        local documentReddot = (not XFunctionManager.CheckFunctionFitter(XFunctionManager.FunctionName.FavorabilityFile)) and (rumorReddot or dataReddot or audioReddot)

        local storyReddot = XDataCenter.FavorabilityManager.HasStroyToBeUnlock(characterId)
        local plotReddot = (not XFunctionManager.CheckFunctionFitter(XFunctionManager.FunctionName.FavorabilityStory)) and storyReddot
        
        return documentReddot or plotReddot
    end
    return false
end


return XUiGridLikeRoleItem
