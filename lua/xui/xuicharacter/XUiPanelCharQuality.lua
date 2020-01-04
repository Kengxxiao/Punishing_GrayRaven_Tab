XUiPanelCharQuality = XClass()

local INTERAL = 100
local LOOP_NUM = 20

function XUiPanelCharQuality:Ctor(ui, parent)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Parent = parent
    self:InitAutoScript()
    self:InitIcon()
    self.CharQualityUpgrade = XUiPanelQualityUpgrade.New(self.PanelQualityUpgrade, self)
    self.ChangeTime = 0.01
    self.ShowIndex = 0
    self.IsShow = true
    self.FxUiKeJinHua = CS.XGame.ClientConfig:GetString("FxUiKeJinHua")
    self.FxUiJihuo = CS.XGame.ClientConfig:GetString("FxUiJihuo")

    self.ImgClick = {
        [1] = self.ImgClick1,
        [2] = self.ImgClick2,
        [3] = self.ImgClick3,
        [4] = self.ImgClick4,
        [5] = self.ImgClick5,
        [6] = self.ImgClick6,
        [7] = self.ImgClick7,
        [8] = self.ImgClick8,
        [9] = self.ImgClick9,
        [10] = self.ImgClick10
    }

    self.TxtWaferName = {
        [1] = self.TxtWaferName1,
        [2] = self.TxtWaferName2,
        [3] = self.TxtWaferName3,
        [4] = self.TxtWaferName4,
        [5] = self.TxtWaferName5,
        [6] = self.TxtWaferName6,
        [7] = self.TxtWaferName7,
        [8] = self.TxtWaferName8,
        [9] = self.TxtWaferName9,
        [10] = self.TxtWaferName10
    }

    self.PanelHint = {
        [1] = self.PanelHint1,
        [2] = self.PanelHint2,
        [3] = self.PanelHint3,
        [4] = self.PanelHint4,
        [5] = self.PanelHint5,
        [6] = self.PanelHint6,
        [7] = self.PanelHint7,
        [8] = self.PanelHint8,
        [9] = self.PanelHint9,
        [10] = self.PanelHint10,
    }

    self:InitClickEvent()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelCharQuality:InitAutoScript()
    self:AutoInitUi()
    XTool.InitUiObject(self)
    self:AutoAddListener()
end

function XUiPanelCharQuality:AutoInitUi()
    self.PanelQualityUpgrade = self.Transform:Find("PanelQualityUpgrade")
    self.PanelQuality = self.Transform:Find("PanelQuality")
    self.PanelItems = self.Transform:Find("PanelQuality/PanelInfo/PanelItems")
    self.ImgLine1 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/Bg/ImgLine1"):GetComponent("Image")
    self.ImgLine2 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/Bg/ImgLine2"):GetComponent("Image")
    self.ImgLine3 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/Bg/ImgLine3"):GetComponent("Image")
    self.ImgLine4 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/Bg/ImgLine4"):GetComponent("Image")
    self.ImgLine5 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/Bg/ImgLine5"):GetComponent("Image")
    self.ImgLine6 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/Bg/ImgLine6"):GetComponent("Image")
    self.ImgLine7 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/Bg/ImgLine7"):GetComponent("Image")
    self.ImgLine8 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/Bg/ImgLine8"):GetComponent("Image")
    self.ImgLine9 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/Bg/ImgLine9"):GetComponent("Image")
    self.ImgLine10 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/Bg/ImgLine10"):GetComponent("Image")
    self.PanelWaferIcon = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon")
    self.ImgLine1A = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon1/ImgLine1"):GetComponent("Image")
    self.ImgWaferColour1 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon1/ImgWaferColour1"):GetComponent("Image")
    self.ImgSelect1 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon1/ImgSelect1"):GetComponent("Image")
    self.ImgWaferon1 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon1/ImgWaferon1"):GetComponent("Image")
    self.TxtWaferName1 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon1/TxtWaferName1"):GetComponent("Text")
    self.ImgClick1 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon1/ImgClick1"):GetComponent("Image")
    self.PanelHint1 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon1/PanelHint1")
    self.ImgLine2A = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon2/ImgLine2"):GetComponent("Image")
    self.ImgWaferColour2 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon2/ImgWaferColour2"):GetComponent("Image")
    self.ImgSelect2 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon2/ImgSelect2"):GetComponent("Image")
    self.ImgWaferon2 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon2/ImgWaferon2"):GetComponent("Image")
    self.TxtWaferName2 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon2/TxtWaferName2"):GetComponent("Text")
    self.ImgClick2 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon2/ImgClick2"):GetComponent("Image")
    self.PanelHint2 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon2/PanelHint2")
    self.ImgLine3A = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon3/ImgLine3"):GetComponent("Image")
    self.ImgWaferColour3 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon3/ImgWaferColour3"):GetComponent("Image")
    self.ImgSelect3 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon3/ImgSelect3"):GetComponent("Image")
    self.ImgWaferon3 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon3/ImgWaferon3"):GetComponent("Image")
    self.TxtWaferName3 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon3/TxtWaferName3"):GetComponent("Text")
    self.ImgClick3 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon3/ImgClick3"):GetComponent("Image")
    self.PanelHint3 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon3/PanelHint3")
    self.ImgLine4A = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon4/ImgLine4"):GetComponent("Image")
    self.ImgWaferColour4 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon4/ImgWaferColour4"):GetComponent("Image")
    self.ImgSelect4 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon4/ImgSelect4"):GetComponent("Image")
    self.ImgWaferon4 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon4/ImgWaferon4"):GetComponent("Image")
    self.TxtWaferName4 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon4/TxtWaferName4"):GetComponent("Text")
    self.ImgClick4 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon4/ImgClick4"):GetComponent("Image")
    self.PanelHint4 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon4/PanelHint4")
    self.ImgLine5A = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon5/ImgLine5"):GetComponent("Image")
    self.ImgWaferColour5 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon5/ImgWaferColour5"):GetComponent("Image")
    self.ImgSelect5 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon5/ImgSelect5"):GetComponent("Image")
    self.ImgWaferon5 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon5/ImgWaferon5"):GetComponent("Image")
    self.TxtWaferName5 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon5/TxtWaferName5"):GetComponent("Text")
    self.ImgClick5 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon5/ImgClick5"):GetComponent("Image")
    self.PanelHint5 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon5/PanelHint5")
    self.ImgLine6A = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon6/ImgLine6"):GetComponent("Image")
    self.ImgWaferColour6 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon6/ImgWaferColour6"):GetComponent("Image")
    self.ImgSelect6 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon6/ImgSelect6"):GetComponent("Image")
    self.ImgWaferon6 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon6/ImgWaferon6"):GetComponent("Image")
    self.TxtWaferName6 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon6/TxtWaferName6"):GetComponent("Text")
    self.ImgClick6 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon6/ImgClick6"):GetComponent("Image")
    self.PanelHint6 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon6/PanelHint6")
    self.ImgLine7A = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon7/ImgLine7"):GetComponent("Image")
    self.ImgWaferColour7 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon7/ImgWaferColour7"):GetComponent("Image")
    self.ImgSelect7 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon7/ImgSelect7"):GetComponent("Image")
    self.ImgWaferon7 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon7/ImgWaferon7"):GetComponent("Image")
    self.TxtWaferName7 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon7/TxtWaferName7"):GetComponent("Text")
    self.ImgClick7 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon7/ImgClick7"):GetComponent("Image")
    self.PanelHint7 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon7/PanelHint7")
    self.ImgLine8A = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon8/ImgLine8"):GetComponent("Image")
    self.ImgWaferColour8 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon8/ImgWaferColour8"):GetComponent("Image")
    self.ImgSelect8 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon8/ImgSelect8"):GetComponent("Image")
    self.ImgWaferon8 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon8/ImgWaferon8"):GetComponent("Image")
    self.TxtWaferName8 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon8/TxtWaferName8"):GetComponent("Text")
    self.ImgClick8 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon8/ImgClick8"):GetComponent("Image")
    self.PanelHint8 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon8/PanelHint8")
    self.ImgLine9A = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon9/ImgLine9"):GetComponent("Image")
    self.ImgWaferColour9 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon9/ImgWaferColour9"):GetComponent("Image")
    self.ImgSelect9 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon9/ImgSelect9"):GetComponent("Image")
    self.ImgWaferon9 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon9/ImgWaferon9"):GetComponent("Image")
    self.TxtWaferName9 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon9/TxtWaferName9"):GetComponent("Text")
    self.ImgClick9 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon9/ImgClick9"):GetComponent("Image")
    self.PanelHint9 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon9/PanelHint9")
    self.ImgLine10A = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon10/ImgLine10"):GetComponent("Image")
    self.ImgWaferColour10 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon10/ImgWaferColour10"):GetComponent("Image")
    self.ImgSelect10 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon10/ImgSelect10"):GetComponent("Image")
    self.ImgWaferon10 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon10/ImgWaferon10"):GetComponent("Image")
    self.TxtWaferName10 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon10/TxtWaferName10"):GetComponent("Text")
    self.ImgClick10 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon10/ImgClick10"):GetComponent("Image")
    self.PanelHint10 = self.Transform:Find("PanelQuality/PanelInfo/PanelItems/PanelWaferIcon/WaferIcon10/PanelHint10")
    self.BtnPreview = self.Transform:Find("PanelQuality/PanelInfo/BtnPreview"):GetComponent("Button")
    self.RImgQuality = self.Transform:Find("PanelQuality/PanelInfo/WaferCircuit/RImgQuality"):GetComponent("RawImage")
    self.RImgQualityMax = self.Transform:Find("PanelQuality/PanelInfo/WaferCircuit/RImgQualityMax"):GetComponent("RawImage")
    self.BtnAdvanced = self.Transform:Find("PanelQuality/PanelInfo/BtnAdvanced"):GetComponent("Button")
    self.RImgQualityBefore = self.Transform:Find("PanelQuality/PanelInfo/BtnAdvanced/RImgQualityBefore"):GetComponent("RawImage")
    self.RImgQualityAfter = self.Transform:Find("PanelQuality/PanelInfo/BtnAdvanced/RImgQualityAfter"):GetComponent("RawImage")
    self.PanelCountMoney = self.Transform:Find("PanelQuality/PanelInfo/BtnAdvanced/PanelCountMoney")
    self.TxtConditionCountMoney = self.Transform:Find("PanelQuality/PanelInfo/BtnAdvanced/PanelCountMoney/TxtConditionCountMoney"):GetComponent("Text")
    self.BtnMoneyTip = self.Transform:Find("PanelQuality/PanelInfo/BtnAdvanced/PanelCountMoney/BtnMoneyTip"):GetComponent("Button")
    self.PanelCondition = self.Transform:Find("PanelQuality/PanelCondition")
    self.ImgPromoteQulityMax = self.Transform:Find("PanelQuality/PanelCondition/ImgPromoteQulityMax"):GetComponent("Image")
    self.TxtConditionCountMoneyA = self.Transform:Find("PanelQuality/PanelCondition/ImgPromoteQulityMax/TxtConditionCountMoney"):GetComponent("Text")
    self.PanelCountIten = self.Transform:Find("PanelQuality/PanelCondition/PanelCountIten")
    self.RImgIconSuipian = self.Transform:Find("PanelQuality/PanelCondition/PanelCountIten/RImgIconSuipian"):GetComponent("RawImage")
    self.TxtConditionCountItem = self.Transform:Find("PanelQuality/PanelCondition/PanelCountIten/TxtConditionCountItem"):GetComponent("Text")
    self.BtnItemTip = self.Transform:Find("PanelQuality/PanelCondition/PanelCountIten/BtnItemTip"):GetComponent("Button")
    self.BtnActive = self.Transform:Find("PanelQuality/PanelCondition/BtnActive"):GetComponent("Button")
end

function XUiPanelCharQuality:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelCharQuality:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelCharQuality:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelCharQuality:AutoAddListener()
    self:RegisterClickEvent(self.BtnPreview, self.OnBtnPreviewClick)
    self:RegisterClickEvent(self.BtnAdvanced, self.OnBtnAdvancedClick)
    self:RegisterClickEvent(self.BtnMoneyTip, self.OnBtnMoneyTipClick)
    self:RegisterClickEvent(self.BtnItemTip, self.OnBtnItemTipClick)
    self:RegisterClickEvent(self.BtnActive, self.OnBtnActiveClick)
end
-- auto
function XUiPanelCharQuality:OnBtnPreviewClick(eventData)
    local characterId = self.CharacterId
    if XDataCenter.CharacterManager.IsMaxQualityById(characterId) then
        return
    end
    XLuaUiManager.Open("UiPanelQualityPreview", characterId)
end

function XUiPanelCharQuality:OnBtnItemTipClick(...)
    local character = XDataCenter.CharacterManager.GetCharacter(self.CharacterId)
    XLuaUiManager.Open("UiTip", XDataCenter.ItemManager.GetItem(character.CharacterTemplate.ItemId))
end

function XUiPanelCharQuality:OnBtnMoneyTipClick(...)
    local character = XDataCenter.CharacterManager.GetCharacter(self.CharacterId)
    XLuaUiManager.Open("UiTip", XDataCenter.ItemManager.GetItem(XCharacterConfigs.GetPromoteItemId(character.Quality)))
end

function XUiPanelCharQuality:OnBtnActiveClick()
    self:UpdateStarCount()
end

function XUiPanelCharQuality:OnBtnAdvancedClick()
    local characterId = self.CharacterId
    local character = XDataCenter.CharacterManager.GetCharacter(characterId)
    self.CharQualityUpgrade:OldCharUpgradeInfo(character)
    if character.Star == XCharacterConfigs.MAX_QUALITY_STAR then
        XDataCenter.CharacterManager.PromoteQuality(character, function()
            CS.XAudioManager.PlaySound(XSoundManager.UiBasicsMusic.UiCharacter_QualityUp)
            self.QualityUpgradeEnable:PlayTimelineAnimation()
            self.CharQualityUpgrade:ShowLevelInfo(characterId)
            self:InitStarAttrInfo()
            self:UpdateStar()
        end)
    end
end

function XUiPanelCharQuality:InitClickEvent()
    local characterId = self.CharacterId
    local character = XDataCenter.CharacterManager.GetCharacter(characterId)

    self.AnimationState = {}
    for i = 1, 10 do
        self:RegisterClickEvent(self.ImgClick[i],
        function()
            self.TxtWaferName[i].gameObject:SetActive(true)
            local attribs = XCharacterConfigs.GetCharStarAttribs(characterId, character.Quality, i - 1)

            for k, v in pairs(attribs) do
                local value = FixToDouble(v)
                if value > 0 then
                    self.TxtWaferName[i].text = string.format("%s+%s", XAttribManager.GetAttribNameByIndex(k), string.format("%.2f", value))
                    break
                end
            end

            CS.XTimerManager.Add(
            function(timer)
                if not self.GameObject:Exist() then
                    CS.XTimerManager.Remove(timer.Id)
                    return
                end

                -- if timer.Count < 10 then
                --     self.TxtWaferName[i].color.a = timer.Count*25
                -- else
                --     self.TxtWaferName[i].color.a = (20-timer.Count)*25
                -- end
                if timer.Count == 20 then
                    self.TxtWaferName[i].gameObject:SetActive(false)
                    CS.XTimerManager.Remove(timer.Id)
                end
            end,
            INTERAL,
            LOOP_NUM
            )
        end
        )
    end
end

function XUiPanelCharQuality:ShowPanel(characterId)
    self.IsShow = true
    self.GameObject:SetActive(true)
    self.QualityQiehuan:PlayTimelineAnimation()
    self.CharacterId = characterId or self.CharacterId
    self.CharQualityUpgrade:HideLevelInfo()
    self:InitStarAttrInfo()
    self:UpdateStar()
end

function XUiPanelCharQuality:HidePanel()
    self.IsShow = false
    self.GameObject:SetActive(false)
end

function XUiPanelCharQuality:InitIcon()
    self.StarIcon = {}
    self.StarAttr = {}
    self.SelectIcon = {}
    self.Line = {}
    self.StarColour = {}
    for i = 1, XCharacterConfigs.MAX_QUALITY_STAR do
        self.StarColour[i] = self["ImgWaferColour" .. i]
        self.StarIcon[i] = self["ImgWaferon" .. i]
        self.StarAttr[i] = self["TxtWaferName" .. i]
        self.SelectIcon[i] = self["ImgSelect" .. i]
        self.Line[i] = self["ImgLine" .. i]
    end
end

function XUiPanelCharQuality:ClearAttrs()
    for i = 1, XCharacterConfigs.MAX_QUALITY_STAR do
        self.StarAttr[i].text = ""
    end
end

function XUiPanelCharQuality:UpdateStar()
    local character = XDataCenter.CharacterManager.GetCharacter(self.CharacterId)
    local maxStar = XCharacterConfigs.MAX_QUALITY_STAR
    local isMaxStar = character.Star == maxStar
    local isMaxQuality = XDataCenter.CharacterManager.IsMaxQuality(character)
    local qualityIcon = XCharacterConfigs.GetCharQualityIcon(character.Quality)

    self.ImgPromoteQulityMax.gameObject:SetActive(isMaxQuality)
    self.RImgQuality.gameObject:SetActive(not isMaxQuality and not isMaxStar)
    self.RImgQualityMax.gameObject:SetActive(isMaxQuality)
    if isMaxQuality then
        self:ClearAttrs()
        self.BtnAdvanced.gameObject:SetActive(false)
        self.PanelCondition.gameObject:SetActive(false)
        self.PanelWaferIcon.gameObject:SetActive(false)
        self.RImgQualityMax:SetRawImage(qualityIcon)
        return
    else
        self.RImgQuality:SetRawImage(qualityIcon)
        self.PanelWaferIcon.gameObject:SetActive(true)
    end

    self:UpdateStarAttrInfo(character.Star)
    for i = 1, character.Star do
        self.StarIcon[i].gameObject:SetActive(true)
        self.Line[i].gameObject:SetActive(true)
        self.StarColour[i].gameObject:SetActive(false)
    end

    for i = maxStar, character.Star + 1, -1 do
        self.StarIcon[i].gameObject:SetActive(false)
        self.Line[i].gameObject:SetActive(false)
        self.StarColour[i].gameObject:SetActive(true)
    end

    if isMaxStar then
        self.PanelCountIten.gameObject:SetActive(false)
        self.PanelCountMoney.gameObject:SetActive(true)
        self.BtnAdvanced.gameObject:SetActive(true)
        self.PanelCondition.gameObject:SetActive(true)

        self.RImgQualityBefore:SetRawImage(XCharacterConfigs.GetCharQualityIcon(character.Quality))
        self.RImgQualityAfter:SetRawImage(XCharacterConfigs.GetCharQualityIcon(character.Quality + 1))
        self.TxtConditionCountMoney.text = XDataCenter.ItemManager.GetItemName(XCharacterConfigs.GetPromoteItemId(character.Quality)) .. XCharacterConfigs.GetPromoteUseCoin(character.Quality)
        self.BtnActive.gameObject:SetActive(false)
        self.ImgPromoteQulityMax.gameObject:SetActive(true)
        self.PanelWaferIcon.gameObject:SetActive(false)
    else
        self.PanelCountIten.gameObject:SetActive(true)
        self.PanelCountMoney.gameObject:SetActive(false)
        self.BtnActive.gameObject:SetActive(true)
        self.BtnAdvanced.gameObject:SetActive(false)
        self.PanelCondition.gameObject:SetActive(true)
        self.RImgIconSuipian:SetRawImage(XDataCenter.ItemManager.GetItemIcon(character.CharacterTemplate.ItemId))
        self.PanelWaferIcon.gameObject:SetActive(true)

        local curItem = XDataCenter.ItemManager.GetItem(character.CharacterTemplate.ItemId)
        local itemCount = 0

        if curItem ~= nil then
            itemCount = curItem.Count
        end
        self.TxtConditionCountItem.text = itemCount .. "/" .. XCharacterConfigs.GetStarUseCount(character.Quality, character.Star + 1)
        self.ImgPromoteQulityMax.gameObject:SetActive(false)
    end

    for _, hint in pairs(self.PanelHint) do
        hint.gameObject:SetActiveEx(false)        
    end
end

function XUiPanelCharQuality:UpdateStarCount(...)
    local character = XDataCenter.CharacterManager.GetCharacter(self.CharacterId)
    self.CharQualityUpgrade:OldCharUpgradeInfo(character)
    local nextActiveStar = character.Star + 1
    XDataCenter.CharacterManager.ActivateStar(character, function()
        self.StarAttr[nextActiveStar].gameObject:SetActive(false)
        self.SelectIcon[nextActiveStar].gameObject:SetActive(false)
        self:UpdateStar()

        local hint = self.PanelHint[nextActiveStar + 1]
        if hint then
            hint.gameObject:SetActiveEx(true)
        end

        CS.XAudioManager.PlaySound(XSoundManager.UiBasicsMusic.UiCharacter_QualityFragments)
    end)
end

function XUiPanelCharQuality:UpdateStarAttrInfo(star)
    local character = XDataCenter.CharacterManager.GetCharacter(self.CharacterId)
    if star < XCharacterConfigs.MAX_QUALITY_STAR then
        self.StarAttr[star + 1].gameObject:SetActive(true)
        self.SelectIcon[star + 1].gameObject:SetActive(true)

        if star ~= 0 then
            self.StarAttr[star].gameObject:SetActive(false)
            self.SelectIcon[star].gameObject:SetActive(false)
        end

        local attribs = XCharacterConfigs.GetCharStarAttribs(character.Id, character.Quality, character.Star)
        for k, v in pairs(attribs) do
            local value = FixToDouble(v)
            if value > 0 then
                self.StarAttr[star + 1].text = XAttribManager.GetAttribNameByIndex(k) .. "+" .. string.format("%.2f", value)
                break
            end
        end
    end
end

function XUiPanelCharQuality:InitStarAttrInfo()
    local character = XDataCenter.CharacterManager.GetCharacter(self.CharacterId)
    for i = 1, #self.StarAttr do
        self.StarAttr[i].gameObject:SetActive(false)
        self.SelectIcon[i].gameObject:SetActive(false)
    end
    local star = character.Star + 1
    if self.TxtWaferName[star] then
        self.TxtWaferName[star].gameObject:SetActive(true)
    end
end