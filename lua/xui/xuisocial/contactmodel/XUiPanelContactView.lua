XUiPanelContactView = XClass()
local XUiGridContactItem = require("XUi/XUiSocial/ContactModel/XUiGridContactItem")

function XUiPanelContactView:Ctor(ui, mainPanel)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.MainPanel = mainPanel
    XTool.InitUiObject(self)
    self:InitAutoScript()


    self.FriendList = {}
    self.IsDeleteFriendState = false
    self.BtnGroupThrowCb = function() XUiManager.TipText("FriendThrowSuccess") end

    self.FriendDatas = {}
    self.RemoveIds = {}

    self.DynamicListManager = XDynamicTableNormal.New(self.GameObject)
    self.DynamicListManager:SetProxy(XUiGridContactItem)
    self.DynamicListManager:SetDelegate(self)
end

function XUiPanelContactView:ResetStatus(...)
    self.IsDeleteFriendState = false
    self.PanelShare.gameObject:SetActive(true)
    self.PanelFriendList.gameObject:SetActive(true)
    self.PanelDeleteFriend.gameObject:SetActive(false)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelContactView:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiPanelContactView:AutoInitUi()
    -- self.GridContact = self.Transform:Find("Viewport/ContactList/GridContact")
    -- self.PanelDeleteFriend = self.Transform:Find("PanelDeleteFriend")
    -- self.BtnRemove = self.Transform:Find("PanelDeleteFriend/BtnRemove"):GetComponent("Button")
    -- self.BtnClose = self.Transform:Find("PanelDeleteFriend/BtnClose"):GetComponent("XUiButton")
    -- self.PanelShare = self.Transform:Find("Share")
    -- self.PanelFriendList = self.Transform:Find("PanelFriendList")

    -- self.TxtFriendCount = self.Transform:Find("Share/TxtFriendCount"):GetComponent("Text")
    -- self.Tips = self.Transform:Find("Tips")


    -- self.BtnAdd = self.Transform:Find("Tips/BtnAdd"):GetComponent("Button")

    -- self.BtnDelete = self.Transform:Find("Share/BtnDelete"):GetComponent("XUiButton")
    -- self.BtnAllCharge = self.Transform:Find("PanelFriendList/BtnAllCharge"):GetComponent("XUiButton")
    -- self.BtnGroupThrow = self.Transform:Find("PanelFriendList/BtnGroupThrow"):GetComponent("XUiButton")
end

function XUiPanelContactView:GetAutoKey(uiNode, eventName)
    if not uiNode then
        return
    end
    return eventName .. uiNode:GetHashCode()
end

function XUiPanelContactView:RegisterListener(uiNode, eventName, func)
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
            XLog.Error("XUiPanelContactView:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiPanelContactView:AutoAddListener()
    self.AutoCreateListeners = {}
    XUiHelper.RegisterClickEvent(self, self.BtnAdd, self.OnBtnAddClick)

    self.BtnDelete.CallBack = function () self:OnBtnDeleteClick() end
    self.BtnClose.CallBack = function() self:OnBtnCloseClick() end
    self.BtnAllCharge.CallBack = function () self:OnBtnAllChargeClick() end
    self.BtnGroupThrow.CallBack = function () self:OnBtnGroupThrowClick() end
    self.BtnRemove.CallBack = function () self:OnBtnRemoveClick() end
end
-- auto
function XUiPanelContactView:OnBtnAddClick(...)
    --跳转去添加好友
    self.MainPanel:SetSelectedIndex(self.MainPanel.BtnTabIndex.MainAddContact)
end

function XUiPanelContactView:SetSelectDeleteId(id, isDelete)
    self.RemoveIds[id] = isDelete
end

function XUiPanelContactView:OnBtnRemoveClick(...)
    --确认删除好友
    if not self.IsDeleteFriendState then
        return
    end

    local removeIds = {}
    for k, v in pairs(self.RemoveIds) do
        if v then
            table.insert(removeIds, k)
        end
    end

    if #removeIds <= 0 then
        XUiManager.TipText("FriendSelectRemoveTip")
        self.RemoveIds = {}
        return
    end

    --确认删除好友的回调
    local removeTip = CS.XTextManager.GetText("FriendRemoveTip")
    XUiManager.DialogTip("", removeTip, XUiManager.DialogType.Normal, nil, function()
        local callBack = function()
            self:UpdateDeleteState(false)
            self:RefreshFriendCount()
            self:RefreshDynamicList()
        end
        XDataCenter.SocialManager.DeleteFriends(removeIds, callBack)
        self.RemoveIds = {}
    end)
end

function XUiPanelContactView:OnBtnAllChargeClick(...)
    --群收礼物
    local callback = function(giftInfoList, rewardGoodsList)
        for i, info in ipairs(giftInfoList) do
            local giftCount
            if rewardGoodsList and rewardGoodsList[i] then
                giftCount = rewardGoodsList[i].Count
            end
            XDataCenter.ChatManager.UpdateGiftData(info.FriendId, info.GiftId, ChatGiftState.Received, giftCount)
        end

        if not rewardGoodsList or #rewardGoodsList < 0 then
            return
        end

        XUiManager.OpenUiObtain(rewardGoodsList, nil, function(...)
            self:Refresh()
            CS.UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(self.Tips)
        end, nil)
    end
    XDataCenter.ChatManager.GetAllGiftsRequest(callback)
end

function XUiPanelContactView:OnBtnGroupThrowClick(...)
    -- 判断是否有好友
    local targetIds = XDataCenter.SocialManager.GetFriendIds()
    if targetIds == nil or #targetIds <= 0 then
        return
    end

    --群发礼物
    local sendChat = {}
    sendChat.ChannelType = ChatChannelType.Private
    sendChat.MsgType = ChatMsgType.Gift
    sendChat.Content = ""
    sendChat.TargetIds = targetIds

    XDataCenter.ChatManager.SendChat(sendChat,self.BtnGroupThrowCb)
end

function XUiPanelContactView:OnBtnDeleteClick(...)
    self:UpdateDeleteState(not self.IsDeleteFriendState)
end

function XUiPanelContactView:OnBtnCloseClick(...)
    self:UpdateDeleteState(false)
end

function XUiPanelContactView:UpdateDeleteState(State)
    self.RemoveIds = {}
    --点击删除好友(状态改变)
    self.IsDeleteFriendState = State
    if #self.FriendDatas == 0 then
        return
    end

    self.PanelDeleteFriend.gameObject:SetActive(State)
    self.PanelFriendList.gameObject:SetActive(not State)

    for i, v in ipairs(self.FriendDatas) do
        local grid = self.DynamicListManager:GetGridByIndex(i)
        if grid ~= nil then
            grid:ShowDeleteState(State, self.RemoveIds[v.FriendId])
        end
    end
    if State then
        self.MainPanel:PlayAnimation("DeleteFriendEnable")
    end
end

function XUiPanelContactView:Show()
    if not self.GameObject:Exist() then
        return
    end

    if self.GameObject.activeSelf == false then
        self.GameObject:SetActive(true)
    end
    self.MainPanel:PlayAnimation("ContactViewQieHuan")
    self:Refresh()

    XDataCenter.SocialManager.GetFriendsInfo(function () self:Refresh() end)

    CS.UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(self.Tips)
end

function XUiPanelContactView:RefreshGiftCount()
    self.BtnAllCharge:SetName(CS.XTextManager.GetText("SocialGiftTips", XPlayer.DailyReceiveGiftCount, XDataCenter.SocialManager.GetGiftMaxCount()))
end

function XUiPanelContactView:Hide()
    if not self.GameObject:Exist() then
        return
    end

    if self.GameObject.activeSelf then
        self.GameObject:SetActive(false)
    end
end

function XUiPanelContactView:Refresh()
    XDataCenter.ChatManager.UpdateGiftStatus()

    self:RefreshFriendCount()
    self:RefreshGiftCount()
    self:ResetStatus()

    self:RefreshDynamicList()
end

function XUiPanelContactView:RefreshDynamicList()
    local friendDatas = XDataCenter.SocialManager.GetFriendList()
    if #friendDatas > 0 then
        self.Tips.gameObject:SetActive(false)
    else
        self.Tips.gameObject:SetActive(true)
    end

    self.FriendDatas = self:SortFriendList(friendDatas)

    self.DynamicListManager:SetDataSource(self.FriendDatas)
    self.DynamicListManager:ReloadDataASync()
end

function XUiPanelContactView:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:Init(self.MainPanel, self)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local friend = self.FriendDatas[index]
        if friend then
            grid:Refresh(friend, self.IsDeleteFriendState, self.RemoveIds[friend.FriendId])
        end
    end
end

function XUiPanelContactView:IsDeletingIds(friendId)
    return self.RemoveIds[friendId]
end

function XUiPanelContactView:SortFriendList(friendDatas)
    --对好友进行排序
    if friendDatas == nil or #friendDatas <= 1 then
        return friendDatas
    end

    local function FriendSort(item1, item2)
        if item1.IsOnline ~= item2.IsOnline then
            return item1.IsOnline --and true or false
        end
        return item1.Level > item2.Level
    end
    table.sort(friendDatas, FriendSort)

    return friendDatas
end

function XUiPanelContactView:RefreshFriendCount()
    local friendCountText = CS.XTextManager.GetText("FriendCount")
    local chargeCoinText = CS.XTextManager.GetText("FriendChargeCoin")
    local maxCount = XPlayerManager.GetMaxFriendCount(XPlayer.Level)
    self.TxtFriendCount.text = string.format('%s  %d / %d', friendCountText, XDataCenter.SocialManager.GetFriendCount(), maxCount)
end

--当离开面板的时候调用
function XUiPanelContactView:OnClose()

end
