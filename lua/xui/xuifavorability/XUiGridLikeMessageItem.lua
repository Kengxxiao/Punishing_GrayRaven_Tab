XUiGridLikeMessageItem = XClass()

local ArrowDown = CS.UnityEngine.Vector3.one
local ArrowUp = CS.UnityEngine.Vector3(1, -1, 1)
local ImgContentSize = CS.UnityEngine.Vector2.zero
local ItemContentSize = CS.UnityEngine.Vector2.zero

function XUiGridLikeMessageItem:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
    self:InitUiAfterAuto()
end

function XUiGridLikeMessageItem:Init(uiRoot)
    self.UiRoot = uiRoot
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiGridLikeMessageItem:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiGridLikeMessageItem:AutoInitUi()
    self.TxtTitle = self.Transform:Find("TxtTitle"):GetComponent("Text")
    self.ImgArrow = self.Transform:Find("ImgArrow"):GetComponent("Image")
    self.ImgContent = self.Transform:Find("ImgContent"):GetComponent("Image")
    self.TxtInfo = self.Transform:Find("ImgContent/TxtInfo"):GetComponent("Text")
    self.BtnOnUnlock = self.Transform:Find("BtnOnUnlock"):GetComponent("Button")
    self.ImgRedDot = self.Transform:Find("ImgRedDot"):GetComponent("Image")
    self.ImgLockBg = self.Transform:Find("ImgLockBg"):GetComponent("Image")
    self.ImgLock = self.Transform:Find("ImgLockBg/ImgLock"):GetComponent("Image")
    self.Txtlock = self.Transform:Find("Txtlock"):GetComponent("Text")
end

function XUiGridLikeMessageItem:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiGridLikeMessageItem:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiGridLikeMessageItem:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiGridLikeMessageItem:AutoAddListener()
    self:RegisterClickEvent(self.BtnOnUnlock, self.OnBtnOnUnlockClick)
end
-- auto

function XUiGridLikeMessageItem:OnBtnOnUnlockClick(eventData)

end
function XUiGridLikeMessageItem:InitUiAfterAuto()
    self.ImgArrowTransform = self.ImgArrow.transform
    self.ImgArrowTransform.localScale = ArrowDown
    self.ImgContentTransform = self.ImgContent.transform
    self.BtnOnUnlockCanvasGroup = self.Transform:Find("BtnOnUnlock"):GetComponent("CanvasGroup")
    self.TransformSizeDelta = self.Transform.sizeDelta
    self.ImgContentSizeDelta = self.ImgContentTransform.sizeDelta
end

function XUiGridLikeMessageItem:OnRefresh(datas, index)
    self.CharacterDatas = datas
    local characterId = self.UiRoot:GetCurrFavorabilityCharacter()
    local isUnlock = XDataCenter.FavorabilityManager.IsInformationUnlock(characterId, self.CharacterDatas.Id)
    local canUnlock = XDataCenter.FavorabilityManager.CanInformationUnlock(characterId, self.CharacterDatas.Id)

    if isUnlock then
        self:ChangeBtnStates(true, false, false, "")
        self.TxtTitle.text = self.CharacterDatas.Title
    else
        self.TxtTitle.text = ""
        if canUnlock then
            self:ChangeBtnStates(false, true, false, "")
        else
            self:ChangeBtnStates(false, false, true, datas.ConditionDescript)
        end
    end

    self:ToggleContent(self.CharacterDatas.IsToggle or false)
    if self.CharacterDatas.IsToggle then
        self.ImgArrowTransform.localScale = ArrowUp
    else
        self.ImgArrowTransform.localScale = ArrowDown
    end
end

function XUiGridLikeMessageItem:OnToggle()
    self.CharacterDatas.IsToggle = not self.CharacterDatas.IsToggle
end

function XUiGridLikeMessageItem:ToggleContent(isToggle)
    if self.CharacterDatas == nil then return end

    self.ImgContent.gameObject:SetActive(isToggle)
    if isToggle then
        self.TxtInfo.text = self.CharacterDatas.Content
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

function XUiGridLikeMessageItem:ChangeBtnStates(arrow, reddot, lockbg, lockTxt)
    self.ImgArrow.gameObject:SetActive(arrow)
    self.ImgRedDot.gameObject:SetActive(reddot)
    self.BtnOnUnlock.gameObject:SetActive(reddot)
    self.ImgLockBg.gameObject:SetActive(lockbg)
    self.Txtlock.text = lockTxt

    if reddot then
        self.BtnOnUnlockCanvasGroup.alpha = 1
    end
end

function XUiGridLikeMessageItem:OnResize()
    self.Transform.sizeDelta = ItemContentSize
    self.ImgContentTransform.sizeDelta = ImgContentSize
end


return XUiGridLikeMessageItem
