XUiGridLikeAudioItem = XClass()
local alphaSinScale = 10

function XUiGridLikeAudioItem:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
end

function XUiGridLikeAudioItem:Init(uiRoot)
    self.UiRoot = uiRoot
end

function XUiGridLikeAudioItem:OnRefresh(audioData, index)
    self.AudioData = audioData
    local characterId = self.UiRoot:GetCurrFavorabilityCharacter()
    local isUnlock = XDataCenter.FavorabilityManager.IsVoiceUnlock(characterId, self.AudioData.Id)
    local canUnlock = XDataCenter.FavorabilityManager.CanVoiceUnlock(characterId, self.AudioData.Id)

    self.CurrentState = XFavorabilityConfigs.InfoState.Normal
    if not isUnlock then
        if canUnlock then
            self.CurrentState = XFavorabilityConfigs.InfoState.Avaliable
        else
            self.CurrentState = XFavorabilityConfigs.InfoState.Lock
        end
    end

    if isUnlock then
        self:UpdatePlayStatus()
    else
        self:HidePlayStatus()
    end

    self:UpdateNormalStatus(self.CurrentState == XFavorabilityConfigs.InfoState.Normal)
    self:UpdateAvaliableStatus(self.CurrentState == XFavorabilityConfigs.InfoState.Avaliable)
    self:UpdateLockStatus(self.CurrentState == XFavorabilityConfigs.InfoState.Lock)

    self.ImgCurProgress.fillAmount = 0

end

function XUiGridLikeAudioItem:HidePlayStatus()
    self.IconPlay.gameObject:SetActive(false)
    self.IconPause.gameObject:SetActive(false)
    self.IconMicro.gameObject:SetActive(false)
end

function XUiGridLikeAudioItem:UpdatePlayStatus()
    local isPlay = self.AudioData.IsPlay or false
    self.IconPlay.gameObject:SetActive(not isPlay)
    self.IconPause.gameObject:SetActive(isPlay)
    self.IconMicro.gameObject:SetActive(isPlay)
    self.IconMicroCanvasGroup.alpha = 0
end

function XUiGridLikeAudioItem:UpdateNormalStatus(isNormal)
    self.AudioNor.gameObject:SetActive(isNormal)
    if isNormal and self.AudioData then
        self.TxtTitle.text = self.AudioData.Name
    end
end

function XUiGridLikeAudioItem:UpdateAvaliableStatus(isAvaliable)
    self.AudioUnlock.gameObject:SetActive(isAvaliable)
    self.ImgRedDot.gameObject:SetActive(isAvaliable)
end

function XUiGridLikeAudioItem:UpdateLockStatus(isLock)
    self.AudioLock.gameObject:SetActive(isLock)
    if isLock and self.AudioData then
        self.TxtLockTitle.text = self.AudioData.Name
        self.TxtTLock.text = self.AudioData.ConditionDescript
    end
end

function XUiGridLikeAudioItem:UpdateProgress(progress)
    progress = (progress >= 1) and 1 or progress
    self.ImgCurProgress.fillAmount = progress
end

function XUiGridLikeAudioItem:UpdateMicroAlpha(count)
    local alpha = math.sin( count / alphaSinScale )
    
    self.IconMicroCanvasGroup.alpha = alpha
end

function XUiGridLikeAudioItem:GetAudioDataId()
    if not self.AudioData then return 0 end
    return self.AudioData.Id
end

return XUiGridLikeAudioItem
