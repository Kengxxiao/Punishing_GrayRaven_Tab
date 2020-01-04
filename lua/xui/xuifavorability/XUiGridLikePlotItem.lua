XUiGridLikePlotItem = XClass()


function XUiGridLikePlotItem:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
end

function XUiGridLikePlotItem:Init( uiRoot )
    self.UiRoot = uiRoot
end

function XUiGridLikePlotItem:OnRefresh(plotData, idx)
    self.PlotData = plotData
    local characterId = self.UiRoot:GetCurrFavorabilityCharacter()
    local isUnlock = XDataCenter.FavorabilityManager.IsStoryUnlock(characterId, plotData.Id)
    local canUnlock = XDataCenter.FavorabilityManager.CanStoryUnlock(characterId, plotData.Id)

    self.CurrentState = XFavorabilityConfigs.InfoState.Normal
    if not isUnlock then
        if canUnlock then
            self.CurrentState = XFavorabilityConfigs.InfoState.Avaliable
        else
            self.CurrentState = XFavorabilityConfigs.InfoState.Lock
        end
    end

    self:UpdateNormalStatus(self.CurrentState == XFavorabilityConfigs.InfoState.Normal)
    self:UpdateAvaliableStatus(self.CurrentState == XFavorabilityConfigs.InfoState.Avaliable)
    self:UpdateLockStatus(self.CurrentState == XFavorabilityConfigs.InfoState.Lock)
end


function XUiGridLikePlotItem:UpdateNormalStatus(isNoraml)
    self.PlotNor.gameObject:SetActive(isNoraml)

    if isNoraml and self.PlotData then
        self.TxtSerial.text = CS.XTextManager.GetText("FavorabilityStorySectionName", self.PlotData.SectionNumber)
        self.TxtTitle.text = self.PlotData.Name
        self.UiRoot:SetUiSprite(self.ImgPlot, self.PlotData.Icon)
    end
end

function XUiGridLikePlotItem:UpdateAvaliableStatus(isAvaliable)
    self.PlotUnlock.gameObject:SetActive(isAvaliable)
    self.ImgRedDot.gameObject:SetActive(isAvaliable)
end

function XUiGridLikePlotItem:UpdateLockStatus(isLock)
    self.PlotLock.gameObject:SetActive(isLock)

    if isLock and self.PlotData then
        self.TxtLockSerial.text = CS.XTextManager.GetText("FavorabilityStorySectionName", self.PlotData.SectionNumber)
        self.TxtLockTitle.text = self.PlotData.Name
        self.TxtTLock.text = self.PlotData.ConditionDescript
    end
end

return XUiGridLikePlotItem
