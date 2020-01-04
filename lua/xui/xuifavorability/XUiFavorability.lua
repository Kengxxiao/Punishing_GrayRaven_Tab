local XUiFavorability = XLuaUiManager.Register(XLuaUi, "UiFavorability")

local XFavorabilityType = {
    UILikeMain = 1,
    UILikeSwitchRole = 2,
    UILikeFile = 3,
    UILikePlot = 4,
    UILikeGift = 5,
}

function XUiFavorability:OnAwake()

    local root = self:GetSceneRoot().transform
    self.PanelCamFarrExchange = root:FindTransform("PanelCamFarrExchange")
    self.PanelCamNearrExchange = root:FindTransform("PanelCamNearrExchange")
    self.PanelCamFarrBegin = root:FindTransform("PanelCamFarrBegin")
    self.PanelCamNearBegin = root:FindTransform("PanelCamNearrBegin")

    self:InitUiAfterAuto()
end


function XUiFavorability:OnStart(...)
    self:OpenMainView(true)

    XDataCenter.FavorabilityManager.BoardMutualRequest()

    local characterId = self:GetCurrFavorabilityCharacter()
    self.RedPointSwitchId = XRedPointManager.AddRedPointEvent(self.ImgReddot, nil, self, { XRedPointConditions.Types.CONDITION_FAVORABILITY_RED }, { CharacterId = characterId })
end

function XUiFavorability:OnEnable()
    if self.SignBoard then
        self.SignBoard:OnEnable()
    end
    self:RefreshSelectedModel()
    if self.FavorabilityMain then
        self.FavorabilityMain:UpdateAllInfos()
    end
end

function XUiFavorability:OnDisable()
    if self.SignBoard then
        self.SignBoard:OnDisable()
    end
end

function XUiFavorability:OnDestroy()
    if self.SignBoard then
        self.SignBoard:OnDestroy()
    end
    self.FavorabilityDocument:OnClose()
    self.FavorabilityMain:OnClose()
    self.CurrentCharacterId = nil
end

function XUiFavorability:SetCurrFavorabilityCharacter(characterId)
    self.CurrentCharacterId = characterId
end

function XUiFavorability:GetCurrFavorabilityCharacter()
    return self.CurrentCharacterId
end

function XUiFavorability:OnGetEvents()
    return { XEventId.EVENT_FAVORABILITY_MAIN_REFRESH, XEventId.EVENT_FAVORABILITY_RUMORS_PREVIEW, XEventId.EVENT_FAVORABILITY_ON_GIFT_CHANGED }
end

function XUiFavorability:OnNotify(evt, ...)
    local args = { ... }
    
    if evt == XEventId.EVENT_FAVORABILITY_MAIN_REFRESH then
        self.FavorabilityMain:UpdateAllInfos(true)
        self:OnCurrentCharacterFavorabilityLevelChanged(args[1])
    elseif evt == XEventId.EVENT_FAVORABILITY_RUMORS_PREVIEW then
        self:OnPreView(args)

    elseif evt == XEventId.EVENT_FAVORABILITY_ON_GIFT_CHANGED then
        self.FavorabilityMain:UpdatePreviewExp(args)

    end
end

function XUiFavorability:OnBtnMainUIClick(eventData)
    self:SetCurrFavorabilityCharacter(nil)
    XLuaUiManager.RunMain()
end

function XUiFavorability:OnBtnMaskClick(eventData)
    self.PanelPreView.gameObject:SetActive(false)
end

function XUiFavorability:InitUiAfterAuto()
    local characterId = self:GetCurrFavorabilityCharacter()
    characterId = (characterId == nil) and XDataCenter.DisplayManager.GetDisplayChar().Id or characterId
    self:SetCurrFavorabilityCharacter(characterId)

    self.FavorabilityChangeRole = XUiPanelFavorabilityExchangeRole.New(self.PanelFavorabilityExchangeRole, self)
    self.FavorabilityDocument = XUiPanelFavorabilityDocument.New(self.PanelFavorabilityDocument, self)
    self.FavorabilityPlot = XUiPanelFavorabilityPlot.New(self.PanelFavorabilityPlot, self)
    self.FavorabilityGift = XUiPanelLikeGiveGift.New(self.PanelFavorabilityGift, self)
    
    self.SignBoard = XUiPanelSignBoard.New(self.PanelFavorabilityBoard, self, XUiPanelSignBoard.SignBoardOpenType.FAVOR)
    self.SignBoard.OperateTrigger = false
    self.SignBoard:SetAutoPlay(false)
    self.FavorabilityMain = XUiPanelFavorabilityMain.New(self.PanelFavorabilityMain, self)

    self.BtnMask.CallBack = function() self:OnBtnMaskClick() end
    self.BtnSwitch.CallBack = function() self:OnBtnSwitchClick() end
end

-- [更换模型]
function XUiFavorability:ChangeCharacterModel(templateId)
    self.SignBoard:SetDisplayCharacterId(templateId)
    self.SignBoard:RefreshCharacterModelById(templateId)
    self.SignBoard:ResetPlayList(templateId)
end

function XUiFavorability:RefreshSelectedModel()
    local characterId = self:GetCurrFavorabilityCharacter()
    characterId = (characterId == nil) and XDataCenter.DisplayManager.GetDisplayChar().Id or characterId
    self:SetCurrFavorabilityCharacter(characterId)
    self:ChangeCharacterModel(characterId)
end

-- [预览]
function XUiFavorability:OnPreView(previewArgs)
    if previewArgs and previewArgs[1] then
        self.PanelPreView.gameObject:SetActive(true)
        self:SetUiSprite(self.ImgPreview, previewArgs[1])
    end
end

-- [标记显示的界面]
function XUiFavorability:ChangeViewType(currViewType)
    self.LastViewType = self.CurrViewType
    self.CurrViewType = currViewType
end

-- [打开main:isAnim是否伴随动画]
function XUiFavorability:OpenMainView(isAnim)
    self:RefreshSelectedModel()

    self.FavorabilityMain.GameObject:SetActive(true)
    if isAnim then
        self.FavorabilityMain:RefreshDatas()
    else
        self.FavorabilityMain:UpdateDatas()
    end
    self.LastViewType = self.CurrViewType or XFavorabilityType.UILikeMain
    XRedPointManager.Check(self.RedPointSwitchId)
end

function XUiFavorability:UpdateCamera(isChangeRoleOpen)
    self.PanelCamFarrExchange.gameObject:SetActive(not isChangeRoleOpen)
    self.PanelCamNearrExchange.gameObject:SetActive(isChangeRoleOpen)
end

function XUiFavorability:UpdateBeginCamera(isOpen)
    self.PanelCamFarrBegin.gameObject:SetActive(isOpen)
    self.PanelCamNearBegin.gameObject:SetActive(not isOpen)
end

-- [打开切换角色]
function XUiFavorability:OpenChangeRoleView()
    self:CloseOtherViewWhenExchagneRoleOpen(self.CurrViewType)
    self.FavorabilityChangeRole.GameObject:SetActive(true)
    self.FavorabilityChangeRole:RefreshDatas()
    self:ChangeViewType(XFavorabilityType.UILikeSwitchRole)
    self:UpdateCamera(true)
    self.FavorabilityMain:SetTopControlActive(false)
    self.CharacterExchangeEnable:PlayTimelineAnimation()
end

-- [关闭切换角色,回到上一个界面]
function XUiFavorability:CloseChangeRoleView()
    self.CharacterExchangeDisable:PlayTimelineAnimation(function()
        self.FavorabilityChangeRole.GameObject:SetActive(false)
        self:OpenOtherViewWhenExchangeRoleClose(self.LastViewType)
        self.FavorabilityMain:UpdateAllInfos()
        self.FavorabilityMain:SetTopControlActive(true)
    end)
end

-- [打开档案界面]
function XUiFavorability:OpenInformationView()
    self.FavorabilityDocument:SetViewActive(true)
    self:ChangeViewType(XFavorabilityType.UILikeFile)
    self.FavorabilityPlot:SetViewActive(false)
    self.FavorabilityGift:SetViewActive(false)
end

-- [打开剧情界面]
function XUiFavorability:OpenPlotView()
    self.FavorabilityPlot:SetViewActive(true)
    self:ChangeViewType(XFavorabilityType.UILikePlot)
    self.FavorabilityDocument:SetViewActive(false)
    self.FavorabilityGift:SetViewActive(false)
end

-- [打开礼物界面]
function XUiFavorability:OpenGiftView()
    self.FavorabilityGift:SetViewActive(true)
    self:ChangeViewType(XFavorabilityType.UILikeGift)
    self.FavorabilityDocument:SetViewActive(false)
    self.FavorabilityPlot:SetViewActive(false)
end

-- [关闭换人界面时打开上一个界面]
function XUiFavorability:OpenOtherViewWhenExchangeRoleClose(viewType)
    if viewType == XFavorabilityType.UILikeFile then
        self:OpenInformationView()

    elseif viewType == XFavorabilityType.UILikePlot then
        self:OpenPlotView()
        
    elseif viewType == XFavorabilityType.UILikeGift then
        self:OpenGiftView()
        
    end
    self:OpenMainView()
end

-- [打开换人界面时关闭其他界面]CloseOtherViewWhenExchagneRoleOpen
function XUiFavorability:CloseOtherViewWhenExchagneRoleOpen(viewType)
    self.FavorabilityDocument:SetViewActive(false)
    self.FavorabilityPlot:SetViewActive(false)
    self.FavorabilityGift:SetViewActive(false)
    self.FavorabilityMain:CloseFuncBtns()
end

-- [切换角色]
function XUiFavorability:OnBtnSwitchClick(eventData)
    self:OpenChangeRoleView()
end

function XUiFavorability:UpdateExpFillAmount(lastLevel, lastExp, totalExp)
    self.FavorabilityMain:DoFillAmountTween(lastLevel, lastExp, totalExp)
end

function XUiFavorability:PlayCvContent(cvId)
    if not self.SignBoard then return end
    self.SignBoard:Stop()
    local content = XFavorabilityConfigs.GetCvContent(cvId)
    self.SignBoard:ShowContent(content)
end

function XUiFavorability:StopCvContent()
    if not self.SignBoard then return end
    self.SignBoard:ShowContent(nil)
end

function XUiFavorability:OnCurrentCharacterFavorabilityLevelChanged(currentLevel)
    local characterId = self:GetCurrFavorabilityCharacter()
    local favorUp = XSignBoardConfigs.GetSignBoardConfigByRoldIdAndCondition(characterId, XSignBoardEventType.FAVOR_UP)
    if favorUp and favorUp[1] and (not self.SignBoard:IsPlaying()) then
        self.SignBoard:ForcePlay(favorUp[1].Id)
    end
end

function XUiFavorability:PlaySubTabAnim()
    self.YeMianTwo:PlayTimelineAnimation()
end

function XUiFavorability:PlayBaseTabAnim()
    self.YeMianOne:PlayTimelineAnimation()
end


