XUiGridLikeInfoItem = XClass()

local ArrowDown = CS.UnityEngine.Vector3.one
local ArrowUp = CS.UnityEngine.Vector3(1, -1, 1)
local ImgContentSize = CS.UnityEngine.Vector2.zero
local ItemContentSize = CS.UnityEngine.Vector2.zero

function XUiGridLikeInfoItem:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform

    XTool.InitUiObject(self)
    
    self:InitUiAfterAuto()
end

function XUiGridLikeInfoItem:Init(uiRoot)
    self.UiRoot = uiRoot
end

function XUiGridLikeInfoItem:InitUiAfterAuto()
    self.ImgArrowTransform = self.ImgArrow.transform
    self.ImgArrowTransform.localScale = ArrowDown
    self.ImgContentTransform = self.ImgContent.transform
    self.TransformSizeDelta = self.Transform.sizeDelta
    self.ImgContentSizeDelta = self.ImgContentTransform.sizeDelta
end

function XUiGridLikeInfoItem:OnRefresh(datas, index)
    self.CharacterDatas = datas
    local characterId = self.UiRoot:GetCurrFavorabilityCharacter()
    local isUnlock = XDataCenter.FavorabilityManager.IsInformationUnlock(characterId, self.CharacterDatas.Id)
    local canUnlock = XDataCenter.FavorabilityManager.CanInformationUnlock(characterId, self.CharacterDatas.Id)
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

    self:ToggleContent(self.CharacterDatas.IsToggle or false)
    if self.CharacterDatas.IsToggle then
        self.ImgArrowTransform.localScale = ArrowUp
    else
        self.ImgArrowTransform.localScale = ArrowDown
    end
end

function XUiGridLikeInfoItem:OnToggle()
    if not self.CharacterDatas then return end
    self.CharacterDatas.IsToggle = not self.CharacterDatas.IsToggle
end

function XUiGridLikeInfoItem:ToggleContent(isToggle)
    if self.CharacterDatas == nil then return end

    self.ImgContent.gameObject:SetActive(isToggle)
    if isToggle then
        self.TxtInfo.text = string.gsub(self.CharacterDatas.Content, "\\n", "\n")
        local txtHeight = self.TxtInfo.preferredHeight
        ImgContentSize = CS.UnityEngine.Vector2(self.ImgContentSizeDelta.x, txtHeight+30)
        ItemContentSize = CS.UnityEngine.Vector2(self.TransformSizeDelta.x,ImgContentSize.y+self.TransformSizeDelta.y)
    else
        self.TxtInfo.text = ""
        ItemContentSize = self.TransformSizeDelta
        ImgContentSize = CS.UnityEngine.Vector2(self.ImgContentSizeDelta.x, 0)
    end
    
    self:OnResize()
end

function XUiGridLikeInfoItem:OnResize()
    self.Transform.sizeDelta = ItemContentSize
    self.ImgContentTransform.sizeDelta = ImgContentSize
end


function XUiGridLikeInfoItem:UpdateNormalStatus(isNormal)
    self.InfoNor.gameObject:SetActive(isNormal)
    if isNormal and self.CharacterDatas then
        self.TxtTitle.text = self.CharacterDatas.Title
    end
end

function XUiGridLikeInfoItem:UpdateAvaliableStatus(isAvaliable)
    self.InfoUnlock.gameObject:SetActive(isAvaliable)
    self.ImgRedDot.gameObject:SetActive(isAvaliable)
end

function XUiGridLikeInfoItem:UpdateLockStatus(isLock)
    self.InfoLock.gameObject:SetActive(isLock)
    if isLock and self.CharacterDatas then
        self.TxtLock.text = self.CharacterDatas.ConditionDescript
        self.TxtLockTitle.text = self.CharacterDatas.Title
    end
end

return XUiGridLikeInfoItem
