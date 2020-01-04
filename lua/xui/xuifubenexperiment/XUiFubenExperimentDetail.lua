local XUiFubenExperimentDetail = XLuaUiManager.Register(XLuaUi, "UiFubenExperimentDetail")

function XUiFubenExperimentDetail:OnAwake()
    self:AddListener()
end


function XUiFubenExperimentDetail:OnStart(trialLevelInfo, curType)
    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset,
    XDataCenter.ItemManager.ItemId.FreeGem,
    XDataCenter.ItemManager.ItemId.ActionPoint,
    XDataCenter.ItemManager.ItemId.Coin)
    self.TrialLevelInfo = trialLevelInfo
    XDataCenter.FubenExperimentManager.SetCurExperimentLevelId(self.TrialLevelInfo.Id)
    
    if self.TrialLevelInfo.Type ~= XDataCenter.FubenExperimentManager.TrialLevelType.Switch then
        self.BtnSingle.gameObject:SetActive(false)
        self.BtnMult.gameObject:SetActive(false)
        if curType == XDataCenter.FubenExperimentManager.TrialLevelType.Mult then
            self.MultStageCfg = XDataCenter.FubenManager.GetStageCfg(self.TrialLevelInfo.MultStageId)
        end
    else
        self.MultStageCfg = XDataCenter.FubenManager.GetStageCfg(self.TrialLevelInfo.MultStageId)
    end
    XEventManager.AddEventListener(XEventId.EVENT_ROOM_CANCEL_MATCH, self.OnCancelMatch, self)
    self.CurType = curType
    self:UpdateInfo()
    self:UpdateMode()
end

function XUiFubenExperimentDetail:OnEnable()
    self.BtnQuickMatch:SetDisable(false)
end

function XUiFubenExperimentDetail:OnDestroy()
    if XDataCenter.RoomManager.Matching then
        XDataCenter.RoomManager.CancelMatch()
    end
    XEventManager.RemoveEventListener(XEventId.EVENT_ROOM_CANCEL_MATCH, self.OnCancelMatch, self)
end

function XUiFubenExperimentDetail:AddListener()
    self:RegisterClickEvent(self.BtnBack, self.OnBtnBackClick)
    self:RegisterClickEvent(self.BtnMainUi, self.OnBtnMainUiClick)
    self:RegisterClickEvent(self.BtnSingle, self.OnBtnSingleClick)
    self:RegisterClickEvent(self.BtnSingleEnter, self.OnBtnSingleEnterClick)
    self:RegisterClickEvent(self.BtnMult, self.OnBtnMultClick)
    self:RegisterClickEvent(self.BtnMultCreateRoom, self.OnBtnMultCreateRoomClick)
    self:RegisterClickEvent(self.BtnQuickMatch, self.OnBtnQuickMatchClick)
end

function XUiFubenExperimentDetail:OnBtnMainUiClick(...)
    local title = CS.XTextManager.GetText("TipTitle")
    local cancelMatchMsg = CS.XTextManager.GetText("OnlineInstanceCancelMatch")
    if XDataCenter.RoomManager.Matching then
        XUiManager.DialogTip(title, cancelMatchMsg, XUiManager.DialogType.Normal, nil, function()
            XDataCenter.RoomManager.CancelMatch()
            XLuaUiManager.RunMain()
        end)
    else
        XLuaUiManager.RunMain()
    end
end

function XUiFubenExperimentDetail:OnBtnBackClick(...)
    local title = CS.XTextManager.GetText("TipTitle")
    local cancelMatchMsg = CS.XTextManager.GetText("OnlineInstanceCancelMatch")
    if XDataCenter.RoomManager.Matching then
        XUiManager.DialogTip(title, cancelMatchMsg, XUiManager.DialogType.Normal, nil, function()
            XDataCenter.RoomManager.CancelMatch()
            self:Close()
        end)
    else
        self:Close()
    end
end

function XUiFubenExperimentDetail:OnBtnSingleClick(...)
    self:OnSwitchButton()
end

function XUiFubenExperimentDetail:OnBtnSingleEnterClick(...)
    XLuaUiManager.Open("UiNewRoomSingle", self.TrialLevelInfo.SingStageId, nil, nil, nil, nil, XDataCenter.FubenManager.StageType.Experiment)
end

function XUiFubenExperimentDetail:OnBtnMultClick(...)
    self:OnSwitchButton()
end

function XUiFubenExperimentDetail:OnBtnMultCreateRoomClick(...)
    XDataCenter.FubenManager.RequestCreateRoom(self.MultStageCfg)
end

function XUiFubenExperimentDetail:OnBtnQuickMatchClick(...)
    if XDataCenter.RoomManager.Matching then
        return
    end

    XDataCenter.FubenManager.RequestMatchRoom(self.MultStageCfg, function()--匹配房间
        self:RefreshMatching()
        self.BtnQuickMatch:SetDisable(true)
    end)
end

function XUiFubenExperimentDetail:OnCancelMatch()
    self.BtnQuickMatch:SetDisable(false)
end

function XUiFubenExperimentDetail:RefreshMatching()
    if XDataCenter.RoomManager.Matching then
        XLuaUiManager.Open("UiOnLineMatching", self.MultStageCfg)
    end
end

function XUiFubenExperimentDetail:OnSwitchButton()
    if self.TrialLevelInfo.Type == XDataCenter.FubenExperimentManager.TrialLevelType.Switch then
        if self.CurType == XDataCenter.FubenExperimentManager.TrialLevelType.Signle then
            self.CurType = XDataCenter.FubenExperimentManager.TrialLevelType.Mult
        else
            self.CurType = XDataCenter.FubenExperimentManager.TrialLevelType.Signle
        end
    end
    self:UpdateMode()
    self:UpdateDes()
end

function XUiFubenExperimentDetail:UpdateMode()
    if self.CurType == XDataCenter.FubenExperimentManager.TrialLevelType.Signle then
        self.PanelSingle.gameObject:SetActive(true)
        self.PanelTeam.gameObject:SetActive(false)
    else
        self.PanelSingle.gameObject:SetActive(false)
        self.PanelTeam.gameObject:SetActive(true)
    end
end

function XUiFubenExperimentDetail:UpdateInfo()
    self.TxtTitle.text = self.TrialLevelInfo.Name
    self.TxtRecommendLevel.text = self.TrialLevelInfo.RecommendLevel
    self.ImgFullScreen:SetRawImage(self.TrialLevelInfo.DetailBackGroundIco)
    self:UpdateDes()
end

function XUiFubenExperimentDetail:UpdateDes()
    if self.CurType == XDataCenter.FubenExperimentManager.TrialLevelType.Signle then
        self.TxtDes.text = string.gsub(self.TrialLevelInfo.SingleDescription, "\\n", "\n")
    else
        self.TxtDes.text = string.gsub(self.TrialLevelInfo.MultDescription, "\\n", "\n")
    end
end