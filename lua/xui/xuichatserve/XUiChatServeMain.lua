local XUiChatServeMain = XLuaUiManager.Register(XLuaUi, "UiChatServeMain")

--==============================--
--desc: 此脚本为了二次测试临时加入
--desc：为了解决，相同Prefab卸载后，其他引用同时卸载
--desc：解决资源卸载问题后，请务必删除此脚本和相关逻辑
--desc：同时请务必删除此脚本相关场景
--==============================--
local ToggleName = {
    CS.XTextManager.GetText("World"),
    CS.XTextManager.GetText("Team"),
    -- CS.XTextManager.GetText("System"),
}

local ToggleType = {
    ChatChannelType.World,
    ChatChannelType.Room,
    -- ChatChannelType.System,
}

local DefaultType = ChatChannelType.World
local ChannelRefreshTime = CS.XGame.ClientConfig:GetInt("ChannelInfoRefreshMin")
local FadeTime = CS.XGame.ClientConfig:GetInt("ChannelChangeFadeTime")
local XUiGridChatChannelItem = require("XUi/XUiChatServe/Item/XUiGridChatChannelItem")

function XUiChatServeMain:OnAwake()
    self:InitAutoScript()

    self.BtnRoom.CallBack = function() self:OnBtnRoomClick() end
    self.BtnChannelSure.CallBack = function() self:OnBtnChannelSureClick() end
    self.BtnChannelMask.CallBack = function() self:OnBtnChannelMaskClick() end

    self.DynamicTableChannels = XDynamicTableNormal.New(self.ChannelList.gameObject)
    self.DynamicTableChannels:SetProxy(XUiGridChatChannelItem)
    self.DynamicTableChannels:SetDelegate(self)
end

function XUiChatServeMain:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:Init(self.UiRoot)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local curChannelData = self.ChannelInfos[index]
        if curChannelData then
            grid:SetItemData(curChannelData)
        end
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then
        self:OnChannelInfoClick(index)
    end
end

function XUiChatServeMain:OnStart(isMain, ...)
    local args = { ... }
    self.SelType = args[1] or DefaultType
    self.Inited = true
    self.InputField.characterLimit = XDataCenter.ChatManager.GetWorldChatMaxCount()
    self:CreateObject()
    self.timerId = -1

    self.ChannelSet = {}
    for _, v in pairs(args) do
        self.ChannelSet[v] = true
    end

    self.CurrentSelectedChannel = XDataCenter.ChatManager.GetCurrentChatChannelId()
    

    if isMain then
        self.ImgBgMain:SetActive(true)
        self.ImgBgCommon:SetActive(false)
    else
        self.ImgBgMain:SetActive(false)
        self.ImgBgCommon:SetActive(true)
    end
end

function XUiChatServeMain:OnEnable()
    self:Refresh()
end

function XUiChatServeMain:OnDisable()
    self:StopChannelTimer()
    self:StopMsgTipsTimer()
    self:RemoveTimer()
end

function XUiChatServeMain:OnDestroy()
    self:StopChannelTimer()
    self:StopMsgTipsTimer()
    self:RemoveTimer()
end

function XUiChatServeMain:CreateObject()
    self.UiPanelChatContent = XUiPanelChatContent.New(self, self.PanelChatContent, self)
    self.UiPanelEmoji = XUiPanelEmoji.New(self, self.PanelEmoji, self)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiChatServeMain:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiChatServeMain:AutoInitUi()
    self.PanelChatServe = self.Transform:Find("SafeAreaContentPane/PanelChatServe")
    self.ImgBgleft = self.Transform:Find("SafeAreaContentPane/PanelChatServe/ImgBg/ImgBgleft")
    self.PanelChatContent = self.Transform:Find("SafeAreaContentPane/PanelChatServe/PanelChatContent")
    self.GridChatItem = self.Transform:Find("SafeAreaContentPane/PanelChatServe/PanelLeftToggle/Viewport/Content/GridChatItem")
    self.PanelMsgTips = self.Transform:Find("SafeAreaContentPane/PanelChatServe/PanelMsgTips")
    self.BtnPanelMsgTips = self.Transform:Find("SafeAreaContentPane/PanelChatServe/PanelMsgTips/BtnImgBg"):GetComponent("Button")
    self.TxtMsgCount = self.Transform:Find("SafeAreaContentPane/PanelChatServe/PanelMsgTips/TxtMsgCount"):GetComponent("Text")
    self.BtnSend = self.Transform:Find("SafeAreaContentPane/PanelChatServe/BtnContent/BtnSend"):GetComponent("Button")
    self.BtnAdd = self.Transform:Find("SafeAreaContentPane/PanelChatServe/BtnContent/BtnAdd"):GetComponent("Button")
    self.InputField = self.Transform:Find("SafeAreaContentPane/PanelChatServe/BtnContent/InF_Content"):GetComponent("InputField")
    self.TxtEnter = self.Transform:Find("SafeAreaContentPane/PanelChatServe/BtnContent/InF_Content/TxtEnter"):GetComponent("Text")
    self.PanelEmoji = self.Transform:Find("SafeAreaContentPane/PanelChatServe/BtnContent/PanelEmoji")
    self.BtnBack = self.Transform:Find("SafeAreaContentPane/PanelChatServe/BtnContent/BtnBack"):GetComponent("Button")
    self.BtnChat = self.Transform:Find("SafeAreaContentPane/PanelChatServe/BtnChat"):GetComponent("Button")
    self.ImgBgMain = self.Transform:Find("SafeAreaContentPane/PanelChatServe/ImgBg/ImgBgMain").gameObject
    self.ImgBgCommon = self.Transform:Find("SafeAreaContentPane/PanelChatServe/ImgBg/ImgBgCommon").gameObject
end

function XUiChatServeMain:AutoAddListener()
    self:RegisterClickEvent(self.BtnPanelMsgTips, self.OnBtnPanelMsgTipsClick)
    self:RegisterClickEvent(self.BtnSend, self.OnBtnSendClick)
    self:RegisterClickEvent(self.BtnAdd, self.OnBtnAddClick)
    self:RegisterClickEvent(self.BtnBack, self.OnBtnBackClick)
    self:RegisterClickEvent(self.BtnChat, self.OnBtnChatClick)
end
-- auto
-------------------------------Event beg-------------------------------
function XUiChatServeMain:OnGetEvents()
    return { XEventId.EVENT_CHAT_RECEIVE_WORLD_MSG, XEventId.EVENT_CHAT_RECEIVE_ROOM_MSG, XEventId.EVENT_PULL_SCROLLVIEW_END, XEventId.EVENT_CHAT_CHANNEL_CHANGED, XEventId.EVENT_CHAT_SERVER_CHANNEL_CHANGED }
end

function XUiChatServeMain:OnNotify(evt, ...)
    if evt == XEventId.EVENT_CHAT_RECEIVE_WORLD_MSG then
        self.UiPanelChatContent:ReceiveChatHandler(...)
    elseif evt == XEventId.EVENT_CHAT_RECEIVE_ROOM_MSG then
        self.UiPanelChatContent:ReceiveChatHandler(...)
    elseif evt == XEventId.EVENT_PULL_SCROLLVIEW_END then
        self:ShowNotReadMsgCount(...)

    elseif evt == XEventId.EVENT_CHAT_CHANNEL_CHANGED then
        self:UpdateCurrentChannel()

    elseif evt == XEventId.EVENT_CHAT_SERVER_CHANNEL_CHANGED then
        -- 服务端分配聊天渠道
        if self.SelType == ChatChannelType.World then
            local args = {...}
            local currentChannelId = args[1]
            self:ShowChangeChatChannel(currentChannelId)
            self:UpdateCurrentChannel()
    
            self:OnBtnChannelMaskClick()
        end
    end
end
-------------------------------Event end-------------------------------
--------------------------------Btn Event beg-----------------------------------
function XUiChatServeMain:OnBtnPanelMsgTipsClick(...)
    self.UiPanelChatContent.notReadMsgCount = 0
end

function XUiChatServeMain:OnBtnAddClick(eventData)
    self.UiPanelEmoji:OpenOrClosePanel()
end

function XUiChatServeMain:OnBtnChatClick(eventData)
    self:OnBtnBackClick(eventData)
end

function XUiChatServeMain:OnBtnSendClick(...)
    if self.SelType == ChatChannelType.World and not XDataCenter.ChatManager.CheckCd() then
        return
    end
    local content = self.InputField.text
    if string.IsNilOrEmpty(content) then
        self.InputField.text = ''
        return
    end

    local sendChat = {}
    sendChat.ChannelType = self.SelType
    sendChat.MsgType = ChatMsgType.Normal
    sendChat.Content = content
    sendChat.TargetIds = { XPlayer.Id }
    self.InputField.text = ''

    self:SendChat(sendChat)
end

function XUiChatServeMain:SendChat(sendChat)
    if not sendChat then
        return
    end

    --发送聊天信息
    local callBack = function(refreshCoolingTime)
        self:RefreshCoolTime(refreshCoolingTime)
    end
    XDataCenter.ChatManager.SendChat(sendChat, callBack, true)
end

function XUiChatServeMain:OnBtnBackClick(...)
    --关闭聊天
    XLuaUiManager.SetMask(true)
    self:PlayAnimation("AnimChatOut", function(...)
        XLuaUiManager.SetMask(false)
        self:Close()
        XEventManager.DispatchEvent(XEventId.EVENT_CARD_REFRESH_WELFARE_BTN)
    end)
   
    CsXGameEventManager.Instance:Notify(XEventId.EVENT_CHAT_CLOSE)
end
--------------------------------Btn Event end-----------------------------------
function XUiChatServeMain:Refresh(...)
    self:InitializationView()
    self:InitTabBtnGroup()
    self:RefreshMsgPanel()
    self:UpdateCurrentChannel()
end

function XUiChatServeMain:InitializationView()
    --初始化界面
    self.PanelMsgTips.gameObject:SetActive(false)

    XLuaUiManager.SetMask(true)
    self:PlayAnimation("AnimChatEnter", function()
        XLuaUiManager.SetMask(false)

        if self.SelType == ChatChannelType.World then
            self:ShowChangeChatChannel(self.CurrentSelectedChannel)
        end
    end)

    CsXGameEventManager.Instance:Notify(XEventId.EVENT_CHAT_OPEN)
end

function XUiChatServeMain:InitTabBtnGroup(...)
    if self.TabGroup then
        return
    end

    self.TabGroup = {}
    for i = 1, #ToggleType do
        local uiButton
        if i == 1 then
            uiButton = self.BtnTabMatch
        else
            local itemGo = CS.UnityEngine.Object.Instantiate(self.BtnTabMatch.gameObject)
            itemGo.transform:SetParent(self.ContentRT, false)
            uiButton = itemGo.transform:GetComponent("XUiButton")
        end

        local title = ToggleName[i]
        local type = ToggleType[i]
        local unlock = self.ChannelSet[type]
        uiButton:SetName(title)
        uiButton:SetDisable(not unlock)

        table.insert(self.TabGroup, uiButton)
    end

    self.Content:Init(self.TabGroup, function(tabIndex) self:OnClickTabCallBack(tabIndex) end)
    self.Content:SelectIndex(self:TypeToTabIndex(self.SelType))
end

function XUiChatServeMain:TypeToTabIndex(type)
    for i = 1, #ToggleType do
        if ToggleType[i] == type then
            return i
        end
    end
    return 0
end

function XUiChatServeMain:OnClickTabCallBack(tabIndex)
    local type = ToggleType[tabIndex]
    if not type or not self.ChannelSet[type] then
        return
    end

    self.SelType = type
    self.UiPanelChatContent:RefreshChatList(type)

    self.PanelChannelLabel.gameObject:SetActiveEx(self.SelType == ChatChannelType.World)
    -- 部队频道清除cd
    if self.SelType == ChatChannelType.Room then
        self:SetInputFieldText()
        self:SetInputInteractable(true)
        self:RemoveTimer()
    end
end

function XUiChatServeMain:RefreshMsgPanel()
    self.UiPanelChatContent:RefreshChatList(self.SelType)
end

function XUiChatServeMain:RefreshCoolTime(refreshCoolingTime)
    if refreshCoolingTime <= 0 then
        return
    end

    -- 部队不走冷却时间逻辑
    if self.SelType == ChatChannelType.Room then return end

    self:SetInputInteractable(false)
    self:SetInputFieldText(CS.XTextManager.GetText("CountDownTips", refreshCoolingTime))

    self:RemoveTimer()

    local refresh = function(timer)
        refreshCoolingTime = refreshCoolingTime - 1
        local stop = refreshCoolingTime <= 0 or XTool.UObjIsNil(self.InputField)
        if stop then
            self:SetInputFieldText()
            self:SetInputInteractable(true)
            self:RemoveTimer()
        else
            self:SetInputFieldText(CS.XTextManager.GetText("CountDownTips", refreshCoolingTime))
        end
    end
    self.timerId = CS.XScheduleManager.ScheduleForever(refresh, CS.XScheduleManager.SECOND)
end

function XUiChatServeMain:SetInputInteractable(flag)
    self.InputField.interactable = flag
    self.BtnSend.interactable = flag
    self.BtnAdd.interactable = flag
end

function XUiChatServeMain:SetInputFieldText(text)
    if not XTool.UObjIsNil(self.InputField) then
        self.InputField.text = text or ""
    end
end

function XUiChatServeMain:RemoveTimer()
    if self.timerId ~= -1 then
        CS.XScheduleManager.UnSchedule(self.timerId)
        self.timerId = -1
    end
end

function XUiChatServeMain:ShowNotReadMsgCount(count)
    if XTool.UObjIsNil(self.GameObject) then
        return
    end

    if count <= 0 then
        -- 如果计时器开着，直接return
        self.UiPanelChatContent.notReadMsgCount = 0
        if self.showMsgTimer and self.showMsgTimer ~= -1 then return end
        self.PanelMsgTips.gameObject:SetActive(false)
    else
        -- 关计时器如果有
        self:StopMsgTipsTimer()
        self.PanelMsgTips.gameObject:SetActive(true)
        self.TxtMsgCount.text = CS.XTextManager.GetText("ChatWorldNewMsg", count)
    end
end

function XUiChatServeMain:ShowChangeChatChannel(channelId)
    if XTool.UObjIsNil(self.GameObject) then
        return
    end

    self.PanelMsgTips.gameObject:SetActive(true)
    self.TxtMsgCount.text = CS.XTextManager.GetText("ChannelChanged", tostring(channelId))
    -- 开计时器关闭
    self:StartMsgTipsTimer()
end

function XUiChatServeMain:StartMsgTipsTimer()
    self:StopMsgTipsTimer()
    self.showMsgTimer = CS.XScheduleManager.ScheduleOnce(function()
        self.PanelMsgTips.gameObject:SetActive(false)
    end, FadeTime * 1000)
end

function XUiChatServeMain:StopMsgTipsTimer()
    if self.showMsgTimer and self.showMsgTimer ~= -1 then
        CS.XScheduleManager.UnSchedule(self.showMsgTimer)
        self.showMsgTimer = -1
    end
end

function XUiChatServeMain:SetChannelData()
    XDataCenter.ChatManager.GetWorldChannelInfos(function(channelInfos)
        -- 加载频道数据
        self.ChannelInfos = channelInfos
        self:InitChannelInfos(self.ChannelInfos)
        self.DynamicTableChannels:SetDataSource(self.ChannelInfos)
        self.DynamicTableChannels:ReloadDataASync()
        self:UpdateChannelTotalCount()
    end)
end

function XUiChatServeMain:InitChannelInfos(channelInfos)
    local currentChannelId = XDataCenter.ChatManager.GetCurrentChatChannelId()
    for k, info in pairs(channelInfos) do
        info.IsSelected = currentChannelId == info.ChannelId
    end
end

function XUiChatServeMain:OnChannelInfoClick(index)
    if self.ChannelInfos[index] then
        self.CurrentSelectedChannel = self.ChannelInfos[index].ChannelId
    end
    for i=1, #self.ChannelInfos do
        local grid = self.DynamicTableChannels:GetGridByIndex(i)
        local info = self.ChannelInfos[i]
        info.IsSelected = i == index
        if grid then
            grid:SetChannelSelected(i == index)
        end
    end
end

function XUiChatServeMain:OnBtnRoomClick()
    self.PanelChannel.gameObject:SetActive(true)

    -- 1分钟之内不重复请求
    local now = XTime.GetServerNowTimestamp()
    if now - XDataCenter.ChatManager.GetLastRequestChannelTime() <= 60 then
        self.ChannelInfos = XDataCenter.ChatManager.GetAllChannelInfos()
        self:InitChannelInfos(self.ChannelInfos)
        self.DynamicTableChannels:SetDataSource(self.ChannelInfos)
        self.DynamicTableChannels:ReloadDataASync()
        self:UpdateChannelTotalCount()
    else
        self:SetChannelData()
        XDataCenter.ChatManager.SetLastRequestChannelTime(now)
    end

    self:StartChannelTimer()
end

function XUiChatServeMain:StartChannelTimer()
    self:StopChannelTimer()
    self.channelTimer = CS.XScheduleManager.Schedule(function()
        self:SetChannelData()
    end, ChannelRefreshTime * 60 * 1000, 0, 0)
end

function XUiChatServeMain:StopChannelTimer()
    if self.channelTimer and self.channelTimer ~= -1 then
        CS.XScheduleManager.UnSchedule(self.channelTimer)
        self.channelTimer = -1
    end
end

-- 切换窗口
function XUiChatServeMain:OnBtnChannelMaskClick()
    self:StopChannelTimer()
    self.PanelChannel.gameObject:SetActive(false)

end

function XUiChatServeMain:OnBtnChannelSureClick()
    self:StopChannelTimer()
    self.PanelChannel.gameObject:SetActive(false)

    if self.CurrentSelectedChannel then
        XDataCenter.ChatManager.SelectChatChannel(self.CurrentSelectedChannel, function()
            self:ShowChangeChatChannel(self.CurrentSelectedChannel)
            self:UpdateCurrentChannel()
        end, function()
            -- 发生服务端房间数量变化（例如当前房间不存在了）重新请求
            self:SetChannelData()
        end)
    end
end

function XUiChatServeMain:UpdateCurrentChannel()
    self.TxtRoomNumber.text = XDataCenter.ChatManager.GetCurrentChatChannelId()
end

function XUiChatServeMain:UpdateChannelTotalCount()
    self.TextTotalCount.text = #XDataCenter.ChatManager.GetAllChannelInfos()
end

return XUiChatServeMain