XUiPanelSocialMyMsgGiftItem = XClass()

function XUiPanelSocialMyMsgGiftItem:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelSocialMyMsgGiftItem:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiPanelSocialMyMsgGiftItem:AutoInitUi()
    self.PanelRole = self.Transform:Find("PanelRole")
    self.RImgHead = self.Transform:Find("PanelRole/RImgHead"):GetComponent("RawImage")
    self.HeadIconEffect = self.Transform:Find("PanelRole/RImgHead/Effect"):GetComponent("XUiEffectLayer")
    self.BtnView = self.Transform:Find("PanelRole/BtnView"):GetComponent("Button")
    self.PanelMsg = self.Transform:Find("PanelMsg")
    self.TxtName = self.Transform:Find("PanelMsg/TxtName"):GetComponent("Text")
    self.RImgIcon = self.Transform:Find("PanelMsg/Content/RImgIcon"):GetComponent("RawImage")
    self.BtnClick = self.Transform:Find("PanelMsg/Content/BtnClick"):GetComponent("Button")
    self.ImgGet = self.Transform:Find("PanelMsg/Content/ImgGet"):GetComponent("Image")
    self.ImgNoGet = self.Transform:Find("PanelMsg/Content/ImgNoGet"):GetComponent("Image")
    self.ImgFetch = self.Transform:Find("PanelMsg/Content/ImgFetch"):GetComponent("Image")
end

function XUiPanelSocialMyMsgGiftItem:GetAutoKey(uiNode, eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiPanelSocialMyMsgGiftItem:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiPanelSocialMyMsgGiftItem:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiPanelSocialMyMsgGiftItem:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterListener(self.BtnView, "onClick", self.OnBtnViewClick)
    self:RegisterListener(self.BtnClick, "onClick", self.OnBtnClickClick)
end
-- auto
function XUiPanelSocialMyMsgGiftItem:OnBtnViewClick(...)--查看个人信息
    if XDataCenter.RoomManager.RoomData and self.playerId == XPlayer.Id then
        --在房间中不能在聊天打开自己详情面板
        return
    end
    XDataCenter.PersonalInfoManager.ReqShowInfoPanel(self.playerId)
end

function XUiPanelSocialMyMsgGiftItem:OnBtnClickClick(...)
    if self.playerId == XPlayer.Id then
        return
    end

    local callback = function(rewardGoodsList)
        XUiManager.OpenUiObtain(rewardGoodsList, nil, function(...)
            self.ImgGet.gameObject:SetActive(false)
            self.ImgNoGet.gameObject:SetActive(true)

            local giftCount
            if rewardGoodsList and rewardGoodsList[1] then
                giftCount = rewardGoodsList[1].Count
            end    
            XDataCenter.ChatManager.UpdateGiftData(self.playerId, self.ChatData.GiftId, ChatGiftState.Received, giftCount)

            self.Parent:UpdatePrivateDynamicList()
        end, nil)
    end
    XDataCenter.ChatManager.GetGift(self.ChatData.GiftId, callback)
end

function XUiPanelSocialMyMsgGiftItem:Refresh(chatData)
    self.playerId = chatData.SenderId
    self:SetShow(true)
    self.ChatData = chatData
    self.CreateTime = chatData.CreateTime
    self.SenderId = chatData.SenderId
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

    if chatData:CheckIsSelfChat() then
        self.ImgGet.gameObject:SetActive(false)
        self.ImgNoGet.gameObject:SetActive(false)
        self.ImgFetch.gameObject:SetActive(false)
        return
    end
    if chatData.GiftStatus == ChatGiftState.WaitReceive then
        self.ImgGet.gameObject:SetActive(true)
        self.ImgNoGet.gameObject:SetActive(false)
        self.ImgFetch.gameObject:SetActive(false)
    elseif chatData.GiftStatus == ChatGiftState.Fetched then
        self.ImgGet.gameObject:SetActive(false)
        self.ImgNoGet.gameObject:SetActive(false)
        self.ImgFetch.gameObject:SetActive(true)
    else
        self.ImgGet.gameObject:SetActive(false)
        self.ImgNoGet.gameObject:SetActive(true)
        self.ImgFetch.gameObject:SetActive(false)
    end
end

function XUiPanelSocialMyMsgGiftItem:SetShow(code)
    self.GameObject.gameObject:SetActive(code)
end