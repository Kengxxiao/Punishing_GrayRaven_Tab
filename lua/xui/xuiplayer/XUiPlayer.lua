local XUiPlayer = XLuaUiManager.Register(XLuaUi, "UiPlayer")

function XUiPlayer:OnStart(closeCb, selectIdx, achiveIdx, playerMedal, isSelf)
    self.TagPage = {
        PlayerInfo = 1,
        Achievement = 2,
        Setting = 3,
        Collect = 4,
    }
    self.BtnBack.CallBack = function() self:OnBtnBackClick() end
    self.BtnMainUi.CallBack = function() self:OnBtnMainUiClick() end
    self.BtnAchievement:SetDisable(not XFunctionManager.JudgeCanOpen(XFunctionManager.FunctionName.PlayerAchievement))
    self.BtnCollect:SetDisable(not XFunctionManager.JudgeCanOpen(XFunctionManager.FunctionName.Medal))
    self.TagBtns = { self.BtnPlayerInfo, self.BtnAchievement, self.BtnSetting, self.BtnCollect }
    self.TabBtnGroup:Init(self.TagBtns, function(index) self:OnTabBtnGroup(index) end)
    self.closeCb = closeCb
    self.AchiveIdx = achiveIdx
    self.PlayerMedal = playerMedal
    self.IsSelf = isSelf
    if self.PlayerMedal then
        self.InType = self.PlayerMedal.InType
    else
        self.InType = XDataCenter.MedalManager.InType.Normal
    end

    self.TabBtnGroup:SelectIndex(selectIdx or self.TagPage.PlayerInfo)
    XRedPointManager.AddRedPointEvent(self.ImgSetNameTag, self.OnCheckSetName, self, { XRedPointConditions.Types.CONDITION_PLAYER_SETNAME, XRedPointConditions.Types.CONDITION_HEADPORTRAIT_RED })
    XRedPointManager.AddRedPointEvent(self.BtnAchievement, self.OnCheckAcchiveRedPoint, self, { XRedPointConditions.Types.CONDITION_PLAYER_ACHIEVE })
    XRedPointManager.AddRedPointEvent(self.BtnCollect, self.OnCheckMedalRedPoint, self, { XRedPointConditions.Types.CONDITION_MEDAL_RED })
end

function XUiPlayer:OnCheckSetName(count)
    self.ImgSetNameTag.gameObject:SetActive(count >= 0)
end

function XUiPlayer:OnCheckAcchiveRedPoint(count)
    self.BtnAchievement:ShowReddot(count >= 0)
end

function XUiPlayer:OnCheckMedalRedPoint(count)
    if XFunctionManager.JudgeCanOpen(XFunctionManager.FunctionName.Medal) then
        self.BtnCollect:ShowReddot(count >= 0)
    else
        self.BtnCollect:ShowReddot(false)
    end
end

function XUiPlayer:OnTabBtnGroup(index)
    if self.NeedSave then
        self:CheckSave(function() self:OnTabBtnGroup(index) end)
        return
    end

    if index == self.TagPage.PlayerInfo then
        self:ShowPanelPlayer()
    elseif index == self.TagPage.Achievement then
        if XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.PlayerAchievement) then
            self:ShowPanelAchv()
        end
    elseif index == self.TagPage.Setting then
        self:ShowSetting()
    elseif index == self.TagPage.Collect then
        if self.IsSelf == false then
            self:ShowCollect()
        else
            if XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.Medal) then
                self:ShowCollect()
            end
        end
    end
    self:PlayAnimation("QieHuan")
end

function XUiPlayer:OnBtnMainUiClick()
    if self.NeedSave then
        self:CheckSave(function() self:OnBtnMainUiClick() end)
        return
    end

    if self.InType == XDataCenter.MedalManager.InType.GetMedal then
        XDataCenter.GuideManager.ResetGuide()
    end
    XLuaUiManager.RunMain()
    if self.InType == XDataCenter.MedalManager.InType.GetMedal then
        XEventManager.DispatchEvent(XEventId.EVENT_FUNCTION_EVENT_COMPLETE)
    end
end

function XUiPlayer:OnBtnBackClick()
    if self.InType ~= XDataCenter.MedalManager.InType.OtherPlayer then
        if self.InType == XDataCenter.MedalManager.InType.GetMedal then
            XDataCenter.GuideManager.ResetGuide()
            XLuaUiManager.RunMain()
            XEventManager.DispatchEvent(XEventId.EVENT_FUNCTION_EVENT_COMPLETE)
        else
            if not self.IsMedalDetailOpen then
                if self.NeedSave then
                    self:CheckSave(function() self:OnBtnBackClick() end)
                    return
                end

                self:Close()

                if self.closeCb then
                    self.closeCb()
                end
            else
                if self.MedalDetailClose then
                    self:MedalDetailClose()
                end
            end
        end
    else
        self:Close()
    end
end

function XUiPlayer:ShowPanelPlayer()
    self:OpenOneChildUi("UiPanelPlayerInfo")
end

function XUiPlayer:ShowPanelAchv()
    self:OpenOneChildUi("UiPanelAchieve", self, self.AchiveIdx)
    self.AchiveIdx = nil
end

function XUiPlayer:ShowSetting()
    self:OpenOneChildUi("UiPanelSetting", self)
end

function XUiPlayer:ShowCollect()
    self:OpenOneChildUi("UiPanelMedal", self, self.PlayerMedal)
end

function XUiPlayer:CheckSave(cb)
    self.NeedSave = false
    XUiManager.DialogTip(
    CS.XTextManager.GetText("TipTitle"),
    CS.XTextManager.GetText("SaveShowSetting"),
    XUiManager.DialogType.Normal,
    function()
        self.UiPanelSetting.CharacterList = XPlayer.ShowCharacters
        if cb then
            cb()
        end
    end,
    function()
        self.UiPanelSetting:OnBtnSave()
        if cb then
            cb()
        end
    end)
end