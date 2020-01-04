XUiPanelPersonalDetails = XClass()

function XUiPanelPersonalDetails:Ctor(ui, rootUi)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    self:InitAutoScript()
    self:InitData()
end
function XUiPanelPersonalDetails:InitData(...)
    self.BtnSlider = self.Transform:Find("ImgJBLevelBg/Slider"):GetComponent("Slider")
    self.BtnSlider.interactable = false
    self.BtnDormitory.gameObject:SetActive(false)
    self.BtnDormitoryDis.gameObject:SetActive(true)
    self.BtnAssistance.gameObject:SetActive(false)
    self.BtnAssistanceDis.gameObject:SetActive(true)
    self.BtnPraise.interactable = false
    self.XUiPanelCombat = XUiPanelPersonalDetailsCombat.New(self.PanelPersonalDetailsCombat, self.RootUi)
    self.XUiPanelSupport = XUiPanelSupport.New(self.PanelSupport, self.RootUi)
    self.BtnViewJb.gameObject:SetActive(false)
end
-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelPersonalDetails:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiPanelPersonalDetails:AutoInitUi()
    self.TxtIdcode = self.Transform:Find("TxtIdcode"):GetComponent("Text")
    self.BtnCopy = self.Transform:Find("TxtIdcode/BtnCopy"):GetComponent("Button")
    self.TxtLevel = self.Transform:Find("TxtLevel"):GetComponent("Text")
    self.TxtName = self.Transform:Find("TxtName"):GetComponent("Text")
    self.ImgIcon = self.Transform:Find("ImgIcon"):GetComponent("Image")
    self.TxtBirthday = self.Transform:Find("TxtBirthday"):GetComponent("Text")
    self.ImgJBLevelBg = self.Transform:Find("ImgJBLevelBg"):GetComponent("Image")
    self.TxtJBLevel = self.Transform:Find("ImgJBLevelBg/TxtJBLevel"):GetComponent("Text")
    self.TxtJBPercent = self.Transform:Find("ImgJBLevelBg/TxtJBPercent"):GetComponent("Text")
    self.Slider = self.Transform:Find("ImgJBLevelBg/Slider"):GetComponent("Slider")
    self.BtnViewJb = self.Transform:Find("ImgJBLevelBg/BtnView"):GetComponent("Button")
    self.ImgTeamBg = self.Transform:Find("ImgTeamBg"):GetComponent("Image")
    self.TxtTeamName = self.Transform:Find("ImgTeamBg/TxtTeamName"):GetComponent("Text")
    self.BtnViewTeam = self.Transform:Find("ImgTeamBg/BtnView"):GetComponent("Button")
    self.BtnContent = self.Transform:Find("BtnContent"):GetComponent("Button")
    self.BtnDormitory = self.Transform:Find("BtnContent/BtnDormitory"):GetComponent("Button")
    self.BtnDormitoryDis = self.Transform:Find("BtnContent/BtnDormitoryDis")
    self.BtnPrivateChat = self.Transform:Find("BtnContent/BtnPrivateChat"):GetComponent("Button")
    self.BtnAssistance = self.Transform:Find("BtnContent/BtnAssistance"):GetComponent("Button")
    self.BtnAssistanceDis = self.Transform:Find("BtnContent/BtnAssistanceDis")
    self.BtnDelete = self.Transform:Find("BtnContent/BtnDelete"):GetComponent("Button")
    self.BtnAdd = self.Transform:Find("BtnContent/BtnAdd"):GetComponent("Button")
    self.BtnReport = self.Transform:Find("BtnContent/BtnReport"):GetComponent("Button")
    self.BtnPraise = self.Transform:Find("BtnContent/BtnPraise"):GetComponent("Button")
    self.TxtCount = self.Transform:Find("BtnContent/BtnPraise/TxtCount"):GetComponent("Text")
    self.PanelSupport = self.Transform:Find("PanelSupport")
    self.PanelPersonalDetailsCombat = self.Transform:Find("PanelPersonalDetailsCombat")
end

function XUiPanelPersonalDetails:GetAutoKey(uiNode, eventName)
    if not uiNode then
        return
    end
    return eventName .. uiNode:GetHashCode()
end

function XUiPanelPersonalDetails:RegisterListener(uiNode, eventName, func)
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
            XLog.Error("XUiPanelPersonalDetails:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiPanelPersonalDetails:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterListener(self.BtnCopy, "onClick", self.OnBtnCopyClick)
    self:RegisterListener(self.Slider, "onValueChanged", self.OnSliderValueChanged)
    self:RegisterListener(self.BtnViewTeam, "onClick", self.OnBtnViewClick)
    self:RegisterListener(self.BtnContent, "onClick", self.OnBtnContentClick)
    self:RegisterListener(self.BtnDormitory, "onClick", self.OnBtnDormitoryClick)
    self:RegisterListener(self.BtnPrivateChat, "onClick", self.OnBtnPrivateChatClick)
    self:RegisterListener(self.BtnAssistance, "onClick", self.OnBtnAssistanceClick)
    self:RegisterListener(self.BtnDelete, "onClick", self.OnBtnDeleteClick)
    self:RegisterListener(self.BtnAdd, "onClick", self.OnBtnAddClick)
    self:RegisterListener(self.BtnReport, "onClick", self.OnBtnReportClick)
    self:RegisterListener(self.BtnPraise, "onClick", self.OnBtnPraiseClick)
    self:RegisterListener(self.BtnViewJb, "onClick", self.OnBtnViewJbClick)
end
-- auto

-- function XUiPanelPersonalDetails:OnBtnCopyClick(...)
--     local id = self.Id
--     if id ~= nil then
--         CS.XAppPlatBridge.CopyStringToClipboard(tostring(id))
--     end
--     XUiManager.TipCode(XCode.Success)
-- end

function XUiPanelPersonalDetails:OnSliderValueChanged(...)

end

function XUiPanelPersonalDetails:OnBtnViewClick(...)

end

function XUiPanelPersonalDetails:OnBtnContentClick(...)

end

function XUiPanelPersonalDetails:OnBtnDormitoryClick(...)

end

function XUiPanelPersonalDetails:OnBtnPrivateChatClick(...)
    self.RootUi:OnBtnBackClick()

    XLuaUiManager.Close("UiChatServeMain") 

    if XLuaUiManager.IsUiShow("UiSocial") then
        XLuaUiManager.PopThenOpen("UiSocial", function(view)
            XEventManager.DispatchEvent(XEventId.EVENT_FRIEND_OPEN_PRIVATE_VIEW, self.Id)
        end)
    else
        XLuaUiManager.Open("UiSocial", function(view)
            XEventManager.DispatchEvent(XEventId.EVENT_FRIEND_OPEN_PRIVATE_VIEW, self.Id)
        end)
    end
end

function XUiPanelPersonalDetails:OnBtnAssistanceClick(...)

end

function XUiPanelPersonalDetails:OnBtnDeleteClick(...)
    --确认删除好友的回调
    local sureCallBack = function()
        local callBack = function()
            local uisocial = XUiManager.FindClassType("UiSocial")
            if uisocial ~= nil then
                uisocial:OnBtnBackClick()
            end
        end
        local removeIds = {}
        table.insert(removeIds, self.Id)
        XDataCenter.SocialManager.DeleteFriends(removeIds, callBack)
    end
    local removeTip = CS.XTextManager.GetText("FriendRemoveTip")
    XUiManager.DialogTip("", removeTip, XUiManager.DialogType.Normal, nil, sureCallBack)
end

function XUiPanelPersonalDetails:OnBtnAddClick(...)
    XDataCenter.SocialManager.ApplyFriend(self.Id)
end

function XUiPanelPersonalDetails:OnBtnReportClick(...)
    --举报
    self.RootUi.XUiPanelJubao:Refresh(self.Info)
end

function XUiPanelPersonalDetails:OnBtnViewJbClick(...)
    local sureCallBack = function()

    end
    local data = XDataCenter.SocialManager.GetFetterTableDataByLevel(tonumber(self.Add))
    if data then
        local removeTip = "与这位好友组队参战时，最大生命提升" .. data.Add .. "%"--CS.XTextManager.GetText("FriendRemoveTip")
        XUiManager.DialogTip("", removeTip, XUiManager.DialogType.Normal, nil, sureCallBack)
    end
end

function XUiPanelPersonalDetails:SetIsShow(code)
    self.GameObject.gameObject:SetActive(code)
end

function XUiPanelPersonalDetails:Refresh(personalInfo)
    self.XUiPanelCombat:Refresh(personalInfo.TeamData, self.RootUi)--小队
    self.XUiPanelSupport:Refresh(personalInfo.AssistData, self.RootUi)--助战

    local playerData = personalInfo.PlayerData
    self.Info = playerData
    self.Id = playerData.Id
    self.TxtName.text = playerData.Name
    self.TxtLevel.text = playerData.Level
    self.TxtIdcode.text = playerData.Id
    self.TxtCount.text = playerData.Likes
    if playerData.Birthday == nil then
        self.TxtBirthday.text = "未登记"
    else
        self.TxtBirthday.text = CS.XTextManager.GetText("Birthday", playerData.Birthday.Mon, playerData.Birthday.Day)
    end
    local info = XPlayerManager.GetHeadPortraitInfoById(playerData.CurrHeadPortraitId)
    if (info ~= nil) then
        self.RootUi:SetUiSprite(self.ImgIcon, info.ImgSrc)
    end
    self.TxtTeamName.text = "暂无军团"
    self.BtnViewTeam.gameObject:SetActive(false)

    --羁绊
    local Level = XDataCenter.SocialManager.GetFriendExpLevel(self.Id)
    if personalInfo.FetterExp ~= nil then
        if Level == 1 then
            local template = XDataCenter.SocialManager.GetFetterTableDataByLevel(Level)
            self.TxtJBPercent.text = personalInfo.FetterExp .. "/" .. template.Exp
            self.Slider.value = personalInfo.FetterExp / template.Exp
        else
            local template = XDataCenter.SocialManager.GetFetterTableDataByLevel(Level)
            local lastTemplate = XDataCenter.SocialManager.GetFetterTableDataByLevel(Level - 1)
            self.TxtJBPercent.text = (personalInfo.FetterExp - lastTemplate.Exp) .. "/" .. (template.Exp - lastTemplate.Exp)
            self.Slider.value = (personalInfo.FetterExp - lastTemplate.Exp) / (template.Exp - lastTemplate.Exp)
        end
        self.TxtJBLevel.text = Level
        self.Add = Level
    elseif XDataCenter.SocialManager.CheckIsFriend(self.Id) then
        self.TxtJBLevel.text = 1
        self.TxtJBPercent.text = "0" .. "/" .. XDataCenter.SocialManager.GetFetterTableDataByLevel(2).Exp
        self.Slider.value = 0
        self.Add = 1
    else
        self.BtnViewJb.transform.parent.gameObject:SetActive(false)
    end

    self:SetBtnStatus(personalInfo.IsFriend)

    self:SetIsShow(true)
end

function XUiPanelPersonalDetails:SetBtnStatus(isFriend)
    if self.Id == XPlayer.Id then
        self.BtnAdd.gameObject:SetActive(false)
        self.BtnDelete.gameObject:SetActive(false)
        self.BtnReport.gameObject:SetActive(false)
        self.BtnDormitory.gameObject:SetActive(false)
        self.BtnPrivateChat.gameObject:SetActive(false)
        self.BtnAssistance.gameObject:SetActive(false)
        self.BtnDormitoryDis.gameObject:SetActive(false)
        self.BtnAssistanceDis.gameObject:SetActive(false)
    elseif isFriend then
        self.BtnAdd.gameObject:SetActive(false)
        self.BtnDelete.gameObject:SetActive(true)
        self.BtnReport.gameObject:SetActive(true)
        self.BtnDormitory.gameObject:SetActive(false)
        self.BtnPrivateChat.gameObject:SetActive(true)
        self.BtnAssistance.gameObject:SetActive(false)
        self.BtnDormitoryDis.gameObject:SetActive(true)
        self.BtnAssistanceDis.gameObject:SetActive(true)
    else
        self.BtnAdd.gameObject:SetActive(true)
        self.BtnDelete.gameObject:SetActive(false)
        self.BtnReport.gameObject:SetActive(true)
        self.BtnDormitory.gameObject:SetActive(false)
        self.BtnPrivateChat.gameObject:SetActive(false)
        self.BtnAssistance.gameObject:SetActive(false)
        self.BtnDormitoryDis.gameObject:SetActive(false)
        self.BtnAssistanceDis.gameObject:SetActive(false)
    end
end
return XUiPanelPersonalDetails
