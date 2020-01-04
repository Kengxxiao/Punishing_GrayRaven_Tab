XUiPanelWorldChatMyMsgItem = XClass()

function XUiPanelWorldChatMyMsgItem:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
    self:InitAutoScript()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelWorldChatMyMsgItem:InitAutoScript()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiPanelWorldChatMyMsgItem:GetAutoKey(uiNode, eventName)
    if not uiNode then
        return
    end
    return eventName .. uiNode:GetHashCode()
end

function XUiPanelWorldChatMyMsgItem:RegisterListener(uiNode, eventName, func)
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
            XLog.Error("XUiPanelWorldChatMyMsgItem:RegisterListener: func is not a function")
        end
        
        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end
        
        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiPanelWorldChatMyMsgItem:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterListener(self.BtnView, "onClick", self.OnBtnViewClick)
    self:RegisterListener(self.TxtWord, "onHrefClick", self.OnBtnHrefClick)
end
-- auto
function XUiPanelWorldChatMyMsgItem:OnBtnViewClick(...)
    if XDataCenter.RoomManager.RoomData and self.playerId == XPlayer.Id then
        --在房间中不能在聊天打开自己详情面板
        return
    end
    XDataCenter.PersonalInfoManager.ReqShowInfoPanel(self.playerId, nil, nil, self.ChatContent)
end

function XUiPanelWorldChatMyMsgItem:OnBtnHrefClick(param)
    XDataCenter.RoomManager.ClickEnterRoomHref(param, self.CreateTime)
end

function XUiPanelWorldChatMyMsgItem:Refresh(chatData)
    self.CreateTime = chatData.CreateTime
    self.playerId = chatData.SenderId
    self.ChatContent = chatData.Content
    self.TxtName.text = chatData.NickName
    self.TxtWord.text = chatData.Content

    if not string.IsNilOrEmpty(chatData.CustomContent) then
        self.TxtWord.supportRichText = true
    else
        self.TxtWord.supportRichText = false
    end

    local medalConfig = XMedalConfigs.GetMeadalConfigById(chatData.CurrMedalId)
    local medalIcon = nil
    
    if medalConfig then 
        medalIcon = medalConfig.MedalIcon
    end
    
    local headInfo = XPlayerManager.GetHeadPortraitInfoById(chatData.Icon)
    if headInfo then
        self.RootUi:SetUiSprite(self.ImgHead, headInfo.ImgSrc)
        if headInfo.Effect then
            self.HeadIconEffect.gameObject:LoadPrefab(headInfo.Effect)
            self.HeadIconEffect.gameObject:SetActiveEx(true)
            self.HeadIconEffect:Init()
        else
            self.HeadIconEffect.gameObject:SetActiveEx(false)
        end
    end
    
    
    
    if medalIcon ~= nil then
        self.ImgMedalIcon:SetRawImage(medalIcon)
        self.ImgMedalIcon.gameObject:SetActiveEx(true)
    else
        self.ImgMedalIcon.gameObject:SetActiveEx(false)
    end
end