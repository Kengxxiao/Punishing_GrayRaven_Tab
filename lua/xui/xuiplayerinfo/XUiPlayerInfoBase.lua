XUiPlayerInfoBase = XClass()
local MAX_SHOW_CHARACTER = 3
function XUiPlayerInfoBase:Ctor(ui, rootUi)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    XTool.InitUiObject(self)

    self.BtnCopy.CallBack = function() self:OnBtnCopy() end
    self.BtnFriendLevel.CallBack = function() self:OnBtnFriendLevel() end
    self.BtnDorm.CallBack = function() self:OnBtnDorm() end
    self.BtnExhibition.CallBack = function() self:OnBtnExhibition() end
    if self.RootUi.Data.Id == XPlayer.Id then
        self.BtnFriendLevel.gameObject:SetActive(false)
    else
        self.BtnFriendLevel.gameObject:SetActive(true)
    end
    
    self:UpdateInfo()
    self:CreateMedalList() 
end

function XUiPlayerInfoBase:UpdateInfo()
    --更新展示厅的临时数据
    XDataCenter.ExhibitionManager.SetCharacterInfo(self.RootUi.Data.GatherIds)
    local data = self.RootUi.Data
    local info = XPlayerManager.GetHeadPortraitInfoById(data.CurrHeadPortraitId)
    self.MedalInfos = data.MedalInfos
    if info ~= nil then
        self.RImgHead:SetRawImage(info.ImgSrc)
        if info.Effect then
            self.HeadIconEffect.gameObject:LoadPrefab(info.Effect)
            self.HeadIconEffect.gameObject:SetActiveEx(true)
            self.HeadIconEffect:Init()
        else
            self.HeadIconEffect.gameObject:SetActiveEx(false)
        end
    end
    self.TxtName.text = data.Name
    self.TxtLevel.text = data.Level
    self.TxtAchievement.text = data.AchievementDetail.Achievement .. "/" .. data.AchievementDetail.TotalAchievement
    self.TxtId.text = data.Id
    if (data.Birthday == nil) then
        self.TxtBirthday.text = CS.XTextManager.GetText("Birthday", "--", "--")
    else
        self.TxtBirthday.text = CS.XTextManager.GetText("Birthday", data.Birthday.Mon, data.Birthday.Day)
    end
    if data.Likes > 9999 then
        self.TxtLikeNum.text = "9999+"
    else
        self.TxtLikeNum.text = data.Likes
    end
    if data.Id == XPlayer.Id then
        self.TxtFriendLevel.text = "-"
    elseif XDataCenter.SocialManager.CheckIsFriend(data.Id) then
        self.TxtFriendLevel.text = XDataCenter.SocialManager.GetFriendExpLevel(data.Id)
    else
        self.TxtFriendLevel.text = CS.XTextManager.GetText("IsNotFriend")
    end

    if data.DormDetail then
        self.BtnDorm.gameObject:SetActive(true)
        self.TxtDormName.text = data.DormDetail.DormitoryName
    else
        self.BtnDorm.gameObject:SetActive(false)
        self.TxtDormName.text = CS.XTextManager.GetText("DormDisable")
    end
    
    local sign = data.Sign
    if sign == nil or string.len(sign) == 0 then
        local text = CS.XTextManager.GetText('CharacterSignTip')
        self.TxtSign.text = text
    else
        self.TxtSign.text = sign
    end
        
    local collectionRate = XDataCenter.ExhibitionManager.GetCollectionRate()
    self.TxtExhibition.text = math.floor(collectionRate * 100) .. "%"
    self:UpdateTeam()
end

--更新支援角色以及构造体展示
function XUiPlayerInfoBase:UpdateTeam()
    local data = self.RootUi.Data
    --支援角色
    local charIcon = XDataCenter.CharacterManager.GetCharSmallHeadIcon(data.AssistCharacterDetail.Id)
    self.RImgSupportHead:SetRawImage(charIcon)
    self.TxtSupportLevel.text = data.AssistCharacterDetail.Level
    self.TxtSupportName.text = XCharacterConfigs.GetCharacterName(data.AssistCharacterDetail.Id)
    self.RImgSupportQuality:SetRawImage(XCharacterConfigs.GetCharQualityIcon(data.AssistCharacterDetail.Quality))
    --构造体展示
    if data.AppearanceShowType == XUiAppearanceShowType.ToAll then
        for i = 1, #data.CharacterShow do
            self["PanelShow" .. i].gameObject:SetActive(true)
            local charId = data.CharacterShow[i].Id
            local charIcon = XDataCenter.CharacterManager.GetCharSmallHeadIcon(charId)
            self["RImgShow" .. i]:SetRawImage(charIcon)
        end

        for i = #data.CharacterShow + 1, MAX_SHOW_CHARACTER do
            self["PanelShow" .. i].gameObject:SetActive(false)
        end
    elseif data.AppearanceShowType == XUiAppearanceShowType.ToFriend and XDataCenter.SocialManager.CheckIsFriend(data.Id) then
        for i = 1, #data.CharacterShow do
            self["PanelShow" .. i].gameObject:SetActive(true)
            local charId = data.CharacterShow[i].Id
            local charIcon = XDataCenter.CharacterManager.GetCharSmallHeadIcon(charId)
            self["RImgShow" .. i]:SetRawImage(charIcon)
        end

        for i = #data.CharacterShow + 1, MAX_SHOW_CHARACTER do
            self["PanelShow" .. i].gameObject:SetActive(false)
        end
    else
        for i = 1, MAX_SHOW_CHARACTER do
            self["PanelShow" .. i].gameObject:SetActive(false)
        end
    end
end

function XUiPlayerInfoBase:CreateMedalList()
    local medalConfigs = XMedalConfigs.GetMeadalConfigs()
    self.PanelBaseInfo = {}
    for k,v in pairs(medalConfigs) do
        local tempTab
        tempTab = CS.UnityEngine.Object.Instantiate(self.PanelMedal)
        tempTab.transform:SetParent(self.PanelMedalList, false)
        tempTab.gameObject:SetActive(true)
        self.PanelBaseInfo[k] = XUiOtherPlayerGridMedal.New(tempTab, self)
        self.PanelBaseInfo[k]:UpdateGrid(v,self.MedalInfos)
    end
end

function XUiPlayerInfoBase:OnBtnCopy()
    CS.XAppPlatBridge.CopyStringToClipboard(tostring(self.TxtId.text))
    XUiManager.TipText("Clipboard", XUiManager.UiTipType.Tip)
end

function XUiPlayerInfoBase:OnBtnFriendLevel()
    local data = self.RootUi.Data
    if not self.PanelPlayerInfoFetters then
        local obj = CS.UnityEngine.Object.Instantiate(self.Obj:GetPrefab("PlayerInfoFetters"))
        obj.transform:SetParent(self.PlayerInfoBase, false)
        self.PanelPlayerInfoFetters = XUiPlayerInfoFetters.New(obj, XDataCenter.SocialManager.CheckIsFriend(data.Id), XDataCenter.SocialManager.GetFriendExp(data.Id))
    else
        self.PanelPlayerInfoFetters:UpdateInfo(XDataCenter.SocialManager.CheckIsFriend(data.Id), XDataCenter.SocialManager.GetFriendExp(data.Id))
        self.PanelPlayerInfoFetters.GameObject:SetActive(true)
    end
end

function XUiPlayerInfoBase:OnBtnDorm()
    if XDataCenter.RoomManager.RoomData then
        XUiManager.TipError(CS.XTextManager.GetText("InTeamCantLookDorm"))
        return
    end
    
    local data = self.RootUi.Data
    XHomeDormManager.EnterDorm(data.Id, data.DormDetail.DormitoryId, true)
end

function XUiPlayerInfoBase:OnBtnExhibition()
    if XDataCenter.RoomManager.RoomData then
        XUiManager.TipError(CS.XTextManager.GetText("InTeamCantLookExhibition"))
        return
    end
    if XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.CharacterExhibition) then
        XLuaUiManager.Open("UiExhibition", false)
    end
end
return XUiPlayerInfoBase