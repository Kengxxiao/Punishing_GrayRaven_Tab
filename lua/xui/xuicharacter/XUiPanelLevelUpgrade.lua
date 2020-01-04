XUiPanelLevelUpgrade = XClass()

function XUiPanelLevelUpgrade:Ctor(ui, parent)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Parent = parent
    self:InitAutoScript()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelLevelUpgrade:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiPanelLevelUpgrade:AutoInitUi()
    self.BtnBg = self.Transform:Find("BtnBg"):GetComponent("Button")
    self.RImgRoleUpgradeMsg = self.Transform:Find("BtnBg/RImgRoleUpgradeMsg"):GetComponent("RawImage")
    self.PanelCharAttack = self.Transform:Find("BtnBg/Properties/PanelCharAttack")
    self.TxtOldAttack = self.Transform:Find("BtnBg/Properties/PanelCharAttack/TxtOldAttack"):GetComponent("Text")
    self.TxtCurAttack = self.Transform:Find("BtnBg/Properties/PanelCharAttack/TxtCurAttack"):GetComponent("Text")
    self.PanelCharLife = self.Transform:Find("BtnBg/Properties/PanelCharLife")
    self.TxtOldLife = self.Transform:Find("BtnBg/Properties/PanelCharLife/TxtOldLife"):GetComponent("Text")
    self.TxtCurLife = self.Transform:Find("BtnBg/Properties/PanelCharLife/TxtCurLife"):GetComponent("Text")
    self.PanelCharDefense = self.Transform:Find("BtnBg/Properties/PanelCharDefense")
    self.TxtOldDefense = self.Transform:Find("BtnBg/Properties/PanelCharDefense/TxtOldDefense"):GetComponent("Text")
    self.TxtCurDefense = self.Transform:Find("BtnBg/Properties/PanelCharDefense/TxtCurDefense"):GetComponent("Text")
    self.PanelCharCrit = self.Transform:Find("BtnBg/Properties/PanelCharCrit")
    self.TxtOldCrit = self.Transform:Find("BtnBg/Properties/PanelCharCrit/TxtOldCrit"):GetComponent("Text")
    self.TxtCurCrit = self.Transform:Find("BtnBg/Properties/PanelCharCrit/TxtCurCrit"):GetComponent("Text")
    self.PanelTxtLevel = self.Transform:Find("BtnBg/PanelTxtLevel")
    self.TxtCurLevelA = self.Transform:Find("BtnBg/PanelTxtLevel/TxtCurLevel"):GetComponent("Text")
    self.TxtOldLevel = self.Transform:Find("BtnBg/PanelTxtLevel/TxtOldLevel"):GetComponent("Text")
    self.BtnDarkBg = self.Transform:Find("BtnDarkBg"):GetComponent("Button")
end

function XUiPanelLevelUpgrade:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelLevelUpgrade:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelLevelUpgrade:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelLevelUpgrade:AutoAddListener()
    self:RegisterClickEvent(self.BtnDarkBg, self.OnBtnDarkBgClick)
end
-- auto
function XUiPanelLevelUpgrade:OnBtnDarkBgClick()
    self.Parent.LevelUpgradeDisable:PlayTimelineAnimation(function()
        self:HideLevelInfo()
    end)
end

function XUiPanelLevelUpgrade:ShowLevelInfo(character)
    self.IsShow = true
    self.GameObject:SetActive(true)
    self:CurCharUpgradeInfo(character)
    CS.XAudioManager.PlaySound(XSoundManager.UiBasicsMusic.Success)   -- 成功
end

function XUiPanelLevelUpgrade:HideLevelInfo()
    self.IsShow = false

    if self.GameObject:Exist() then
        self.GameObject:SetActive(false)
    end

   -- XDataCenter.GuideManager.OpenSubPanel(self.Parent.Parent.Parent.Parent.Name, "PanelLevelUpgrade", false)
end

function XUiPanelLevelUpgrade:OldCharUpgradeInfo(character)
    self.TxtOldAttack.text = XMath.ToMinInt(FixToDouble(character.Attribs[XNpcAttribType.AttackNormal]) or 0)
    self.TxtOldLife.text = XMath.ToMinInt(FixToDouble(character.Attribs[XNpcAttribType.Life]) or 0)
    self.TxtOldDefense.text = XMath.ToMinInt(FixToDouble(character.Attribs[XNpcAttribType.DefenseNormal]) or 0)
    self.TxtOldCrit.text = XMath.ToMinInt(FixToDouble(character.Attribs[XNpcAttribType.Crit]) or 0)
    self.TxtOldLevel.text = "LV." .. character.Level
end

function XUiPanelLevelUpgrade:CurCharUpgradeInfo(character)
    self.TxtCurAttack.text = XMath.ToMinInt(FixToDouble(character.Attribs[XNpcAttribType.AttackNormal]) or 0)
    self.TxtCurLife.text = XMath.ToMinInt(FixToDouble(character.Attribs[XNpcAttribType.Life]) or 0)
    self.TxtCurDefense.text = XMath.ToMinInt(FixToDouble(character.Attribs[XNpcAttribType.DefenseNormal]) or 0)
    self.TxtCurCrit.text = XMath.ToMinInt(FixToDouble(character.Attribs[XNpcAttribType.Crit]) or 0)
    self.TxtCurLevelA.text = "LV." .. character.Level
    self.RImgRoleUpgradeMsg:SetRawImage(XDataCenter.CharacterManager.GetCharBigHeadIcon(character.Id))
end