XUiGridLikeRumorItem = XClass()

local ArrowUp = CS.UnityEngine.Vector3(1, -1, 1)
local ArrowDown = CS.UnityEngine.Vector3.one
local ImgContentSize = CS.UnityEngine.Vector2.zero
local ItemContentSize = CS.UnityEngine.Vector2.zero
local RumorImgSize = CS.UnityEngine.Vector2(648, 366)

function XUiGridLikeRumorItem:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    
    XTool.InitUiObject(self)
    self:InitUiAfterAuto()
end

function XUiGridLikeRumorItem:Init(uiRoot)
    self.UiRoot = uiRoot
end

function XUiGridLikeRumorItem:InitUiAfterAuto()
    self.ImgArrowTransform = self.ImgArrow.transform
    self.ImgArrowTransform.localScale = ArrowDown
    self.ImgContentTransform = self.ImgContent.transform
    self.TxtInfoTransform = self.TxtInfo.transform
    self.RumorImageTransform = self.BtnImage.transform

    self.TransformSizeDelta = self.Transform.sizeDelta
    self.ImgContentSizeDelta = self.ImgContentTransform.sizeDelta

    self.StartPos = self.RumorImageTransform.localPosition

    self.BtnImage.CallBack = function() self.OnBtnImageClick() end
    
end

function XUiGridLikeRumorItem:OnRefresh(rumorData, index)
    self.RumorData = rumorData
    local characterId = self.UiRoot:GetCurrFavorabilityCharacter()
    local isUnlock = XDataCenter.FavorabilityManager.IsRumorUnlock(characterId, rumorData.Id)
    local canUnlock = XDataCenter.FavorabilityManager.CanRumorsUnlock(characterId, rumorData.UnlockType, rumorData.UnlockPara)

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

    self:ToggleContent(self.RumorData.IsToggle or false)
    if self.RumorData.IsToggle then
        self.ImgArrowTransform.localScale = ArrowUp
    else
        self.ImgArrowTransform.localScale = ArrowDown
    end
end

function XUiGridLikeRumorItem:OnToggle()
    self.RumorData.IsToggle = not self.RumorData.IsToggle
end

function XUiGridLikeRumorItem:ToggleContent(isToggle)
    if self.RumorData == nil then return end

    self.ImgContent.gameObject:SetActive(isToggle)

    if isToggle then
        self.TxtInfo.text = string.gsub(self.RumorData.Content, "\\n", "\n")
        local txtHeight = self.TxtInfo.preferredHeight
        if self.RumorData.Picture then
            self.UiRoot:SetUiSprite(self.RumorImage, self.RumorData.Picture)
            self.RumorImageTransform.sizeDelta = RumorImgSize
        else
            self.RumorImageTransform.sizeDelta = CS.UnityEngine.Vector2.zero
        end
        --改变容器大小
        local offsetY = self.RumorImageTransform.sizeDelta.y
        ImgContentSize = CS.UnityEngine.Vector2(self.ImgContentSizeDelta.x, offsetY + txtHeight + 30)
        ItemContentSize = CS.UnityEngine.Vector2(self.TransformSizeDelta.x,ImgContentSize.y+self.TransformSizeDelta.y)
    else
        self.TxtInfo.text = ""
        self.RumorImageTransform.sizeDelta = CS.UnityEngine.Vector2.zero
        ItemContentSize = self.TransformSizeDelta
        ImgContentSize = CS.UnityEngine.Vector2(self.ImgContentSizeDelta.x, 0)
    end

    local rumorImgY = self.RumorImageTransform.sizeDelta.y
    local txtInfoPos = CS.UnityEngine.Vector3(self.StartPos.x, self.StartPos.y-rumorImgY-10, self.StartPos.z)
    self.TxtInfoTransform.localPosition = txtInfoPos
    self:OnResize()
end

function XUiGridLikeRumorItem:OnResize()
    self.Transform.sizeDelta = ItemContentSize
    self.ImgContentTransform.sizeDelta = ImgContentSize
end

function XUiGridLikeRumorItem:OnBtnImageClick(eventData)
    if self.RumorData.Picture then
        CsXGameEventManager.Instance:Notify(XEventId.EVENT_FAVORABILITY_RUMORS_PREVIEW, self.RumorData.PreviewPicture)
    end
end

function XUiGridLikeRumorItem:UpdateNormalStatus(isNormal)
    self.RumorNor.gameObject:SetActive(isNormal)
    if isNormal and self.RumorData then
        self.TxtTitle.text = self.RumorData.Title
    end
end

function XUiGridLikeRumorItem:UpdateAvaliableStatus(isAvaliable)
    self.RumorUnlock.gameObject:SetActive(isAvaliable)
    self.ImgRedDot.gameObject:SetActive(isAvaliable)
end

function XUiGridLikeRumorItem:UpdateLockStatus(isLock)
    self.RumorLock.gameObject:SetActive(isLock)
    if isLock and self.RumorData then
        self.TxtLockTitle.text = self.RumorData.Title
        self.TxtLock.text = self.RumorData.ConditionDescript
    end
end

return XUiGridLikeRumorItem
