local stringFormat = string.format

XUiPanelQualityUpgrade = XClass()

function XUiPanelQualityUpgrade:Ctor(ui, parent)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Parent = parent
    self:InitAutoScript()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelQualityUpgrade:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiPanelQualityUpgrade:AutoInitUi()
    self.BtnDarkBg = self.Transform:Find("BtnDarkBg"):GetComponent("Button")
    self.BtnBgImage = self.Transform:Find("BtnBgImage"):GetComponent("Button")
    self.PanelCharLife = self.Transform:Find("BtnBgImage/Properties/PanelCharLife")
    self.TxtOldLife = self.Transform:Find("BtnBgImage/Properties/PanelCharLife/TxtOldLife"):GetComponent("Text")
    self.TxtCurLife = self.Transform:Find("BtnBgImage/Properties/PanelCharLife/TxtCurLife"):GetComponent("Text")
    self.PanelCharAttack = self.Transform:Find("BtnBgImage/Properties/PanelCharAttack")
    self.TxtOldAttack = self.Transform:Find("BtnBgImage/Properties/PanelCharAttack/TxtOldAttack"):GetComponent("Text")
    self.TxtCurAttack = self.Transform:Find("BtnBgImage/Properties/PanelCharAttack/TxtCurAttack"):GetComponent("Text")
    self.PanelCharDefense = self.Transform:Find("BtnBgImage/Properties/PanelCharDefense")
    self.TxtOldDefense = self.Transform:Find("BtnBgImage/Properties/PanelCharDefense/TxtOldDefense"):GetComponent("Text")
    self.TxtCurDefense = self.Transform:Find("BtnBgImage/Properties/PanelCharDefense/TxtCurDefense"):GetComponent("Text")
    self.PanelCharCrit = self.Transform:Find("BtnBgImage/Properties/PanelCharCrit")
    self.TxtOldCrit = self.Transform:Find("BtnBgImage/Properties/PanelCharCrit/TxtOldCrit"):GetComponent("Text")
    self.TxtCurCrit = self.Transform:Find("BtnBgImage/Properties/PanelCharCrit/TxtCurCrit"):GetComponent("Text")
    self.PanelTxt = self.Transform:Find("BtnBgImage/PanelTxt")
    self.RImgQuality = self.Transform:Find("BtnBgImage/PanelTxt/RImgQuality"):GetComponent("RawImage")
    self.RImgQuality1 = self.Transform:Find("BtnBgImage/PanelTxt/RImgQuality1"):GetComponent("RawImage")
end

function XUiPanelQualityUpgrade:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelQualityUpgrade:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelQualityUpgrade:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelQualityUpgrade:AutoAddListener()
    self:RegisterClickEvent(self.BtnDarkBg, self.OnBtnDarkBgClick)
end

function XUiPanelQualityUpgrade:OnBtnDarkBgClick()
    self.Parent.QualityUpgradeDisable:PlayTimelineAnimation(function()
        self:HideLevelInfo()
    end)
end
function XUiPanelQualityUpgrade:ShowLevelInfo(characterId)
    self.GameObject:SetActive(true)
    self.IsShow = true
    local character = XDataCenter.CharacterManager.GetCharacter(characterId)
    self:CurCharUpgradeInfo(character)
    CS.XAudioManager.PlaySound(XSoundManager.UiBasicsMusic.Success)   -- 成功
end

function XUiPanelQualityUpgrade:HideLevelInfo()
    self.IsShow = false
    if self.GameObject:Exist() then
        self.GameObject:SetActive(false)
    end
end

function XUiPanelQualityUpgrade:OldCharUpgradeInfo(character)
    local attrbis = XCharacterConfigs.GetNpcPromotedAttribByQuality(character.Id, character.Quality)
    self.TxtOldAttack.text = stringFormat("%.2f", FixToDouble(attrbis[XNpcAttribType.AttackNormal]))
    self.TxtOldLife.text = stringFormat("%.2f", FixToDouble(attrbis[XNpcAttribType.Life]))
    self.TxtOldDefense.text = stringFormat("%.2f", FixToDouble(attrbis[XNpcAttribType.DefenseNormal]))
    self.TxtOldCrit.text = stringFormat("%.2f", FixToDouble(attrbis[XNpcAttribType.Crit]))
    self.RImgQuality:SetRawImage(XCharacterConfigs.GetCharQualityIcon(character.Quality))
end

function XUiPanelQualityUpgrade:CurCharUpgradeInfo(character)
    local attrbis = XCharacterConfigs.GetNpcPromotedAttribByQuality(character.Id, character.Quality or 0)
    self.TxtCurAttack.text = stringFormat("%.2f", FixToDouble(attrbis[XNpcAttribType.AttackNormal]))
    self.TxtCurLife.text = stringFormat("%.2f", FixToDouble(attrbis[XNpcAttribType.Life]))
    self.TxtCurDefense.text = stringFormat("%.2f", FixToDouble(attrbis[XNpcAttribType.DefenseNormal]))
    self.TxtCurCrit.text = stringFormat("%.2f", FixToDouble(attrbis[XNpcAttribType.Crit]))
    self.RImgQuality1:SetRawImage(XCharacterConfigs.GetCharQualityIcon(character.Quality))
end