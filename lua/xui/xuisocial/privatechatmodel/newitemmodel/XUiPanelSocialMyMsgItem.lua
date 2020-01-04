XUiPanelSocialMyMsgItem = XClass()

function XUiPanelSocialMyMsgItem:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelSocialMyMsgItem:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiPanelSocialMyMsgItem:AutoInitUi()
    self.PanelMsg = self.Transform:Find("PanelMsg")
    self.TxtName = self.Transform:Find("PanelMsg/TxtName"):GetComponent("Text")
    self.TxtWord = self.Transform:Find("PanelMsg/Content/TxtWord"):GetComponent("XUiHrefText")
    self.PanelRole = self.Transform:Find("PanelRole")
    self.RImgHead = self.Transform:Find("PanelRole/RImgHead"):GetComponent("RawImage")
    self.HeadIconEffect = self.Transform:Find("PanelRole/RImgHead/Effect"):GetComponent("XUiEffectLayer")
    self.BtnView = self.Transform:Find("PanelRole/BtnView"):GetComponent("Button")
end

function XUiPanelSocialMyMsgItem:GetAutoKey(uiNode, eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiPanelSocialMyMsgItem:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiPanelSocialMyMsgItem:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiPanelSocialMyMsgItem:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterListener(self.BtnView, "onClick", self.OnBtnViewClick)
    self:RegisterListener(self.TxtWord, "onHrefClick", self.OnBtnHrefClick)
end
-- auto
function XUiPanelSocialMyMsgItem:OnBtnViewClick(...)
    if XDataCenter.RoomManager.RoomData and self.playerId == XPlayer.Id then
        --在房间中不能在聊天打开自己详情面板
        return
    end
    XDataCenter.PersonalInfoManager.ReqShowInfoPanel(self.playerId, nil, nil, self.ChatContent)
end

function XUiPanelSocialMyMsgItem:OnBtnHrefClick(param)
    XDataCenter.RoomManager.ClickEnterRoomHref(param, self.CreateTime)
end

function XUiPanelSocialMyMsgItem:Refresh(chatData)
    if chatData == nil then
        return
    end
    self.playerId = chatData.SenderId
    self.ChatContent = chatData.Content

    self.TxtName.text = chatData.NickName
    local info = XPlayerManager.GetHeadPortraitInfoById(chatData.Icon)
    if (info ~= nil) then
        self.RImgHead:SetRawImage(info.ImgSrc)
        
        if info.Effect then
            self.HeadIconEffect.gameObject:LoadPrefab(info.Effect)
            self.HeadIconEffect.gameObject:SetActiveEx(true)
            self.HeadIconEffect:Init()
        else
            self.HeadIconEffect.gameObject:SetActiveEx(false)
        end
    end

    if not string.IsNilOrEmpty(chatData.CustomContent) then
        self.TxtWord.supportRichText = true
    else
        self.TxtWord.supportRichText = false
    end

    self.TxtWord.text = chatData.Content
    self.CreateTime = chatData.CreateTime
    self:SetShow(true)
end

function XUiPanelSocialMyMsgItem:SetShow(code)
    self.GameObject.gameObject:SetActive(code)
end
