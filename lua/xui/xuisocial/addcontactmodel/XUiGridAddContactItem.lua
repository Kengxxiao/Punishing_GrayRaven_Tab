local XUiGridAddContactItem = XClass()
local UiButtonState = CS.UiButtonState

function XUiGridAddContactItem:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Parent = nil
    XTool.InitUiObject(self)
    self:InitAutoScript()
    self.GameObject:SetActive(false)
end

function XUiGridAddContactItem:Init(parent)
    self.Parent = parent
    self.RootUi = parent.RootUi
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiGridAddContactItem:InitAutoScript()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiGridAddContactItem:GetAutoKey(uiNode, eventName)
    if not uiNode then
        return
    end
    return eventName .. uiNode:GetHashCode()
end

function XUiGridAddContactItem:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then
        return
    end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiGridAddContactItem:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiGridAddContactItem:AutoAddListener()
    self.AutoCreateListeners = {}
    self.BtnApplyFor.CallBack = function()
        self:OnBtnApplyForClick()
    end
    self:RegisterListener(self.BtnView, "onClick", self.OnBtnViewClick)
end
-- auto
function XUiGridAddContactItem:OnBtnApplyForClick(...)
    local successCallBack = function()
        XDataCenter.SocialManager.RemoveRecommendPlay(self.Id)
        self.Parent:InitDynamicList()
    end
    XDataCenter.SocialManager.ApplyFriend(self.Id, successCallBack, successCallBack)
end

function XUiGridAddContactItem:OnBtnViewClick(...)
    --个人信息
    XDataCenter.PersonalInfoManager.ReqShowInfoPanel(self.Id)
end

function XUiGridAddContactItem:Hide()
    if self.GameObject:Exist() then
        self.GameObject:SetActive(false)
    end
end

function XUiGridAddContactItem:Show()
    if self.GameObject:Exist() then
        self.GameObject:SetActive(true)
    end
end

function XUiGridAddContactItem:Refresh(info)
    
    local medalConfig = XMedalConfigs.GetMeadalConfigById(info.CurrMedalId)
    local medalIcon = nil
    if medalConfig then 
        medalIcon = medalConfig.MedalIcon
    end
    if medalIcon ~= nil then
        self.MedalRawImage:SetRawImage(medalIcon)
        self.MedalRawImage.gameObject:SetActiveEx(true)
    else
        self.MedalRawImage.gameObject:SetActiveEx(false)
    end
    
    self.Id = info.FriendId
    self.TxtName.text = info.NickName
    if info.Sign == nil or (string.len(info.Sign) == 0) then
        local text = CS.XTextManager.GetText('CharacterSignTip')
        self.TxtSign.text = text
    else
        self.TxtSign.text = info.Sign
    end
    self.TxtLevel.text = info.Level
    if XDataCenter.SocialManager.CheckIsFriend(self.Id) then
        self.BtnApplyFor:SetName(CS.XTextManager.GetText("ApplyButtonName2"))
        --好友
        self.BtnApplyFor:SetDisable(true, false)
    else
        self.BtnApplyFor:SetName(CS.XTextManager.GetText("ApplyButtonName1"))
        -- 申请
        self.BtnApplyFor:SetDisable(false, true)
    end

    if info.IsOnline then
        self.TxtOnline.gameObject:SetActive(true)
        self.PanelRoleOffLine.gameObject:SetActive(false)
        self.PanelRoleOnLine.gameObject:SetActive(true)
        self.TxtTime.text = ""
    else
        self.TxtOnline.gameObject:SetActive(false)
        self.PanelRoleOffLine.gameObject:SetActive(true)
        self.PanelRoleOnLine.gameObject:SetActive(false)
        self.TxtTime.text = CS.XTextManager.GetText("FriendLatelyLogin") .. XUiHelper.CalcLatelyLoginTime(info.LastLoginTime)
    end

    local headInfo = XPlayerManager.GetHeadPortraitInfoById(info.Icon)
    if headInfo ~= nil then
        self.ImgIconOnLine:SetRawImage(headInfo.ImgSrc)
        self.ImgIconOffLine:SetRawImage(headInfo.ImgSrc)
        
        if headInfo.Effect then
            self.HeadIconEffectOn.gameObject:LoadPrefab(headInfo.Effect)
            self.HeadIconEffectOn.gameObject:SetActiveEx(true)
            self.HeadIconEffectOn:Init()
        else
            self.HeadIconEffectOn.gameObject:SetActiveEx(false)
        end
    end
    self:Show()
end
    
return XUiGridAddContactItem