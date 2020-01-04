local XUiGridWaitPassItem = XClass()

function XUiGridWaitPassItem:Ctor(ui, mainPanel)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
    self:InitAutoScript()
end

function XUiGridWaitPassItem:Init(mainPanel)
    self.MainPanel = mainPanel
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiGridWaitPassItem:InitAutoScript()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiGridWaitPassItem:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiGridWaitPassItem:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiGridWaitPassItem:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiGridWaitPassItem:AutoAddListener()
    self.AutoCreateListeners = {}

    self:RegisterListener(self.BtnView, "onClick", self.OnBtnViewClick)

    self.BtnRefused.CallBack = function () self:OnBtnRefusedClick() end
    self.BtnAgreed.CallBack = function () self:OnBtnAgreedClick() end
end
-- auto

function XUiGridWaitPassItem:OnBtnRefusedClick(...)
    local callBack = function()
        self.MainPanel:RefreshApplyList()
    end
    XDataCenter.SocialManager.AcceptApplyFriend(self.Id, false, callBack)
end

function XUiGridWaitPassItem:OnBtnAgreedClick(...)
    local callBack = function()
        if self.Callback then
            self.Callback()
        end
        self.MainPanel:RefreshApplyList()
    end
    XDataCenter.SocialManager.AcceptApplyFriend(self.Id, true, callBack)
end

function XUiGridWaitPassItem:OnBtnViewClick(...)--个人信息
   XDataCenter.PersonalInfoManager.ReqShowInfoPanel(self.Id)
end

function XUiGridWaitPassItem:Refresh(data, cb)
    if data == nil then
        return
    end

    local medalConfig = XMedalConfigs.GetMeadalConfigById(data.CurrMedalId)
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
    
    self.Callback = cb
    self.TxtName.text = data.NickName
    self.Id = data.FriendId
    if data.Sign == nil or (string.len(data.Sign) == 0) then
        local text = CS.XTextManager.GetText("CharacterSignTip")
        self.TxtSign.text = text
    else
        self.TxtSign.text = data.Sign
    end
    self.TxtTime.text = CS.XTextManager.GetText("FriendLatelyLogin")..XUiHelper.CalcLatelyLoginTime(data.LastLoginTime)
    self.TxtLevel.text = data.Level
    if data.IsOnline then
        self.TxtOnline.gameObject:SetActiveEx(true)
        self.PanelRoleOffLine.gameObject:SetActiveEx(false)
        self.PanelRoleOnLine.gameObject:SetActiveEx(true)
        self.TxtTime.gameObject:SetActiveEx(false)
    else
        self.TxtOnline.gameObject:SetActiveEx(false)
        self.PanelRoleOffLine.gameObject:SetActiveEx(true)
        self.PanelRoleOnLine.gameObject:SetActiveEx(false)
        self.TxtTime.gameObject:SetActiveEx(true)
    end

    local headInfo = XPlayerManager.GetHeadPortraitInfoById(data.Icon)
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

function XUiGridWaitPassItem:Show()
    if self.GameObject:Exist() then
        self.GameObject:SetActiveEx(true)
    end
end

return XUiGridWaitPassItem