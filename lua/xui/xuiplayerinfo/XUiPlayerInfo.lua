local XUiPlayerInfo = XLuaUiManager.Register(XLuaUi, "UiPlayerInfo")

function XUiPlayerInfo:OnStart(data, chatContent)
    self.Data = data
    self.ChatContent = chatContent
    self.Tab = {
        BaseInfo = 1,
        FightInfo = 2,
        AppearanceInfo = 3,
    }
    --ButtonCallBack
    self.BtnChat.CallBack = function() self:OnBtnChat() end
    self.BtnAddFriend.CallBack = function() self:OnBtnAddFriend() end
    self.BtnReport.CallBack = function() self:OnBtnReport() end
    self.BtnClose.CallBack = function() self:OnBtnClose() end

    self.PanelBaseInfo = nil
    self.PanelFightInfo = nil
    self.PanelAppearanceInfo = nil
    self.TabPanels = {}
    --self.TabGroup:Init({ self.BtnBaseInfo, self.BtnFightInfo, self.BtnAppearance }, function(index) self:OnTabGroupClick(index) end)
    --self.TabGroup:SelectIndex(self.Tab.BaseInfo)
    self.BtnBaseInfo:SetDisable(true)
    self.BtnFightInfo:SetDisable(true)
    self.BtnAppearance:SetDisable(true)
    self:UpdateInfo(self.Tab.BaseInfo)
end

function XUiPlayerInfo:OnDestroy()
    XDataCenter.ExhibitionManager.SetCharacterInfo(XDataCenter.ExhibitionManager.GetSelfGatherRewards())
end

function XUiPlayerInfo:OnTabGroupClick(index)
    --功能未完成，暂时屏蔽
    if index == self.Tab.FightInfo or index == self.Tab.AppearanceInfo then
        XUiManager.TipText("CommonNotOpen")
        return
    end
    self:UpdateInfo(index)
end

function XUiPlayerInfo:OnBtnChat()
    XLuaUiManager.Close("UiChatServeMain") 

    if XLuaUiManager.IsUiShow("UiSocial") then
        XLuaUiManager.CloseWithCallback("UiPlayerInfo", function()
            XEventManager.DispatchEvent(XEventId.EVENT_FRIEND_OPEN_PRIVATE_VIEW, self.Data.Id)
        end)
    else
        XLuaUiManager.Open("UiSocial", function(view)
            XEventManager.DispatchEvent(XEventId.EVENT_FRIEND_OPEN_PRIVATE_VIEW, self.Data.Id)
        end)
    end
end

function XUiPlayerInfo:OnBtnAddFriend()
    XDataCenter.SocialManager.ApplyFriend(self.Data.Id)
end

function XUiPlayerInfo:OnBtnReport()
    XLuaUiManager.Open("UiReport", self.Data.Id, self.Data.Name, self.Data.Level, self.ChatContent)
end

function XUiPlayerInfo:OnBtnClose()
    self:Close()
end

function XUiPlayerInfo:UpdateInfo(index)
    if self.Data.Id == XPlayer.Id then
        self.BtnAddFriend.gameObject:SetActive(false)
        self.BtnChat.gameObject:SetActive(false)
        self.BtnReport.gameObject:SetActive(false)
        self.Mask.gameObject:SetActive(false)
    elseif XDataCenter.SocialManager.CheckIsFriend(self.Data.Id) then
        self.BtnAddFriend.gameObject:SetActive(false)
        self.BtnChat.gameObject:SetActive(true)
        self.BtnReport.gameObject:SetActive(true)
        self.Mask.gameObject:SetActive(true)
    else
        self.BtnAddFriend.gameObject:SetActive(true)
        self.BtnChat.gameObject:SetActive(false)
        self.BtnReport.gameObject:SetActive(true)
        self.Mask.gameObject:SetActive(true)
    end

    if index == self.Tab.BaseInfo then
        if not self.PanelBaseInfo then
            local obj = CS.UnityEngine.Object.Instantiate(self.Obj:GetPrefab("PlayerInfoBase"))
            obj.transform:SetParent(self.PanelContent, false)
            self.PanelBaseInfo = XUiPlayerInfoBase.New(obj, self)
            self.TabPanels[index] = self.PanelBaseInfo
            self.TabPanels[index].Type = self.Tab.BaseInfo
        else
            self.PanelBaseInfo:UpdateInfo()
        end
    elseif index == self.Tab.FightInfo then
        if not self.PanelFightInfo then
            local obj = CS.UnityEngine.Object.Instantiate(self.Obj:GetPrefab("PlayerInfoFight"))
            obj.transform:SetParent(self.PanelContent, false)
            self.PanelFightInfo = XUiPlayerInfoFight.New(obj, self)
            self.TabPanels[index] = self.PanelFightInfo
            self.TabPanels[index].Type = self.Tab.FightInfo
        else
            self.PanelFightInfo:UpdateInfo()
        end
    elseif index == self.Tab.AppearanceInfo then
        if not self.PanelAppearanceInfo then
            local obj = CS.UnityEngine.Object.Instantiate(self.Obj:GetPrefab("PlayerInfoAppearance"))
            obj.transform:SetParent(self.PanelContent, false)
            self.PanelAppearanceInfo = XUiPlayerInfoAppearance.New(obj, self)
            self.TabPanels[index] = self.PanelAppearanceInfo
            self.TabPanels[index].Type = self.Tab.AppearanceInfo
        else
            self.PanelAppearanceInfo:UpdateInfo()
        end
    end
    self:ActivePanel(index)
end

function XUiPlayerInfo:SetGameObjActive(obj, active)
    if obj then
        obj.GameObject:SetActive(active)
    end
end

function XUiPlayerInfo:ActivePanel(index)
    for k, v in pairs(self.TabPanels) do
        if v.Type == index then
            v.GameObject:SetActive(true)
        else
            v.GameObject:SetActive(false)
        end
    end
end