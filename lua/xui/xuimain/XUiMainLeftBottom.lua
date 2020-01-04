XUiMainLeftBottom = XClass()
local CSXTextManagerGetText = CS.XTextManager.GetText
local MAX_CHAT_WIDTH = 395
local CHAT_SUB_LENGTH = 18

function XUiMainLeftBottom:Ctor(rootUi)
    self.Transform = rootUi.PanelLeftBottom.gameObject.transform
    XTool.InitUiObject(self)
    --ClickEvent
    self.BtnNotice.CallBack = function() self:OnBtnNotice() end
    self.BtnSocial.CallBack = function() self:OnBtnSocial() end
    self.BtnWelfare.CallBack = function() self:OnBtnWelfare() end
    self.BtnChat.CallBack = function() self:OnBtnChat() end
    --RedPoint
    XRedPointManager.AddRedPointEvent(self.BtnSocial.ReddotObj, self.OnCheckSocialNews, self, { XRedPointConditions.Types.CONDITION_MAIN_FRIEND })
    self.RedPoinWelfareId = XRedPointManager.AddRedPointEvent(self.BtnWelfare.ReddotObj, self.OnCheckWalfarelNews, self, { XRedPointConditions.Types.CONDITION_PURCHASE_GET_RERARGE, XRedPointConditions.Types.CONDITION_PURCHASE_GET_CARD })
    self.RedPoinFristRechargeId = XRedPointManager.AddRedPointEvent(self.BtnWelfare.TagObj, self.OnCheckFristRecharge, self, { XRedPointConditions.Types.CONDITION_PURCHASE_GET_RERARGE })
    XRedPointManager.AddRedPointEvent(self.BtnNotice.ReddotObj, self.OnCheckNoticeNews, self, { XRedPointConditions.Types.CONDITION_MAIN_NOTICE })
    self:InitChatMsg()
end

function XUiMainLeftBottom:OnEnable()
    XEventManager.AddEventListener(XEventId.EVENT_CHAT_RECEIVE_WORLD_MSG, self.RefreshChatMsg, self)
    XEventManager.AddEventListener(XEventId.EVENT_CARD_REFRESH_WELFARE_BTN, self.OnRefreshWalfareId, self)
    XEventManager.AddEventListener(XEventId.EVENT_CARD_REFRESH_WELFARE_BTN, self.OnRefreshFristRechargeId, self)
    self:UpdatePanelAd()
    self:OnRefreshWalfareId()
    self:OnRefreshFristRechargeId()

    self.BtnWelfare:SetDisable(not XFunctionManager.JudgeCanOpen(XFunctionManager.FunctionName.SkipWelfare))
end

function XUiMainLeftBottom:OnDisable()
    XEventManager.RemoveEventListener(XEventId.EVENT_CHAT_RECEIVE_WORLD_MSG, self.RefreshChatMsg, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_CARD_REFRESH_WELFARE_BTN, self.OnRefreshWalfareId, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_CARD_REFRESH_WELFARE_BTN, self.OnRefreshFristRechargeId, self)
end

function XUiMainLeftBottom:OnDestroy()
    if self.PanelAdObj then
        self.PanelAdObj:OnDestroy()
    end
end

function XUiMainLeftBottom:OnNotify(evt, ...)
    if evt == XEventId.EVENT_NOTICE_PIC_CHANGE then
        self:UpdatePanelAd()
    end
end

--公告入口
function XUiMainLeftBottom:OnBtnNotice()
    XLuaUiManager.OpenWithCallback("UiActivityBase", function ()
        if XLuaUiManager.IsUiLoad("UiDialog") or XLuaUiManager.IsUiLoad("UiBuyAsset") or XLuaUiManager.IsUiLoad("UiSystemDialog") or XLuaUiManager.IsUiLoad("UiUsePackage") then
            XLuaUiManager.Close("UiActivityBase")
        end
    end)
end

--好友入口
function XUiMainLeftBottom:OnBtnSocial()
    if not XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.SocialFriend) then
        return
    end
    XLuaUiManager.Open("UiSocial")
end

--福利入口
function XUiMainLeftBottom:OnBtnWelfare()
    if not XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.SkipWelfare) then
        return
    end
    XLuaUiManager.Open("UiSign")
end

--聊天入口
function XUiMainLeftBottom:OnBtnChat()
    if XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.SocialChat) then
        self.BtnWelfare:ShowTag(false)
        XLuaUiManager.Open("UiChatServeMain", true, ChatChannelType.World)
    end
end

-- 设置福利按钮特效可见性
function XUiMainLeftBottom:SetBtnWelfareTagActive(active)
    self.BtnWelfare:ShowTag(active)
end

--更新聊天
function XUiMainLeftBottom:RefreshChatMsg(chatDataLua)
    if not XFunctionManager.JudgeCanOpen(XFunctionManager.FunctionName.SocialChat) then
        return
    end

    if chatDataLua.ChannelType == ChatChannelType.World then
        self.TxtMessageType.text = CSXTextManagerGetText("ChatWorldMsg")
    elseif chatDataLua.ChannelType == ChatChannelType.Private then
        self.TxtMessageType.text = CSXTextManagerGetText("ChatPrivateMsg")
    elseif chatDataLua.ChannelType == ChatChannelType.System then
        self.TxtMessageType.text = CSXTextManagerGetText("ChatSystemMsg")
    elseif chatDataLua.ChannelType == ChatChannelType.Room then
        self.TxtMessageType.text = CSXTextManagerGetText("ChatGuilyMsg")
    end

    if chatDataLua.MsgType == ChatMsgType.Emoji then
        self.TxtMessageContent.text = string.format("%s:%s", chatDataLua.NickName, CSXTextManagerGetText("EmojiText"))
    else
        self.TxtMessageContent.text = string.format("%s:%s", chatDataLua.NickName, chatDataLua.Content)
    end
    self.TxtMessageLabel.gameObject:SetActiveEx(XUiHelper.CalcTextWidth(self.TxtMessageContent) > MAX_CHAT_WIDTH)
end

function XUiMainLeftBottom:InitChatMsg(...)
    self.TxtMessageType.text = ""
    self.TxtMessageContent.text = ""
end

--更新福利红点
function XUiMainLeftBottom:OnRefreshWalfareId()
    if self.RedPoinWelfareId then
        XRedPointManager.Check(self.RedPoinWelfareId)
    end
end

--更新首充特效
function XUiMainLeftBottom:OnRefreshFristRechargeId()
    if XLoginManager.IsFirstOpenMainUi() then
        return
    end

    if self.RedPoinFristRechargeId then
        XRedPointManager.Check(self.RedPoinFristRechargeId)
    end
end

--更新滚动广告
function XUiMainLeftBottom:UpdatePanelAd()
    if self.PanelAdObj then
        self.PanelAdObj:UpdateAdList()
    else
        self.PanelAdObj = XUiPanelAd.New(self, self.PanelAd)
    end
end

--好友红点
function XUiMainLeftBottom:OnCheckSocialNews(count)
    self.BtnSocial:ShowReddot(count >= 0 and XFunctionManager.JudgeCanOpen(XFunctionManager.FunctionName.SocialFriend))
end

--福利红点
function XUiMainLeftBottom:OnCheckWalfarelNews(count)
    self.BtnWelfare:ShowReddot(count >= 0)
end

--首充特效
function XUiMainLeftBottom:OnCheckFristRecharge(count)
    self.BtnWelfare:ShowTag(count >= 0)
end

--公告红点
function XUiMainLeftBottom:OnCheckNoticeNews(count)
    self.BtnNotice:ShowReddot(count >= 0)
end
