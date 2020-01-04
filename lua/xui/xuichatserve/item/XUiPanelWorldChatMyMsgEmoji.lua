XUiPanelWorldChatMyMsgEmoji = XClass()

function XUiPanelWorldChatMyMsgEmoji:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
    self:InitAutoScript()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelWorldChatMyMsgEmoji:InitAutoScript()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiPanelWorldChatMyMsgEmoji:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiPanelWorldChatMyMsgEmoji:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end
    
    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiPanelWorldChatMyMsgEmoji:RegisterListener: func is not a function")
        end
        
        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end
        
        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiPanelWorldChatMyMsgEmoji:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterListener(self.BtnView, "onClick", self.OnBtnViewClick)
end
-- auto

function XUiPanelWorldChatMyMsgEmoji:OnBtnViewClick(...)
    if XDataCenter.RoomManager.RoomData and self.playerId == XPlayer.Id then
        --在房间中不能在聊天打开自己详情面板
        return
    end
    XDataCenter.PersonalInfoManager.ReqShowInfoPanel(self.playerId, function () 
            self.RootUi:SetActive(false) 
        end, function () 
            self.RootUi:SetActive(true) 
        end)
end

function XUiPanelWorldChatMyMsgEmoji:Refresh(chatData)
    self.playerId = chatData.SenderId
    self.TxtName.text = chatData.NickName
    
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
    
    local emojiId = string.match(chatData.Content, "%d%d%d%d%d")
    local icon = XDataCenter.ChatManager.GetEmojiIcon(emojiId)
    local medalConfig = XMedalConfigs.GetMeadalConfigById(chatData.CurrMedalId)
    local medalIcon = nil
    
    if medalConfig then 
        medalIcon = medalConfig.MedalIcon
    end
    
    if icon ~= nil then
        self.RImgEmoji:SetRawImage(icon)
    end
    if medalIcon ~= nil then
        self.ImgMedalIcon:SetRawImage(medalIcon)
        self.ImgMedalIcon.gameObject:SetActiveEx(true)
    else
        self.ImgMedalIcon.gameObject:SetActiveEx(false)
    end
end
