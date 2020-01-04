XUiPanelGradeUpgrade = XClass()

function XUiPanelGradeUpgrade:Ctor(ui, rootUi, parent)
    self.RootUi = rootUi
    self.Parent = parent
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
    self.Grading = {
        Recruit = 1, --新兵
        RecruitStar = 1, --新兵最大等级
        Picked = 2, --精锐
        PickedStar = 3, --精锐最大等级
        MainForce = 3, --主力
        MainForceStar = 6, --主力最大等级
        Ace = 3, --王牌
        AceStar = 9, --王牌最大等级
        TheChosen = 4, --天选
        TheChosenStar = 13, --天选最大等级
    }
    self.OldStar = { self.ImgOldStar1A, self.ImgOldStar2A, self.ImgOldStar3A, self.ImgOldStar4A }
    self.OldOnStar = { self.ImgOldOnStar1A, self.ImgOldOnStar2A, self.ImgOldOnStar3A, self.ImgOldOnStar4A }
    self.CurStar = { self.ImgCurStar1A, self.ImgCurStar2A, self.ImgCurStar3A, self.ImgCurStar4A }
    self.CurOnStar = { self.ImgCurOnStar1A, self.ImgCurOnStar2A, self.ImgCurOnStar3A, self.ImgCurOnStar4A }
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelGradeUpgrade:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiPanelGradeUpgrade:AutoInitUi()
    self.RImgCharacterIcon = self.Transform:Find("BgImage/RImgCharacterIcon"):GetComponent("RawImage")
    self.TxtName = self.Transform:Find("BgImage/RImgCharacterIcon/TxtName"):GetComponent("Text")
    self.BtnDarkBg = self.Transform:Find("BtnDarkBg"):GetComponent("Button")
    self.PanelCharAttack = self.Transform:Find("BgImage/Properties/PanelCharAttack")
    self.TxtOldAttack = self.Transform:Find("BgImage/Properties/PanelCharAttack/TxtOldAttack"):GetComponent("Text")
    self.TxtCurAttack = self.Transform:Find("BgImage/Properties/PanelCharAttack/TxtCurAttack"):GetComponent("Text")
    self.PanelCharLife = self.Transform:Find("BgImage/Properties/PanelCharLife")
    self.TxtOldLife = self.Transform:Find("BgImage/Properties/PanelCharLife/TxtOldLife"):GetComponent("Text")
    self.TxtCurLife = self.Transform:Find("BgImage/Properties/PanelCharLife/TxtCurLife"):GetComponent("Text")
    self.PanelCharDefense = self.Transform:Find("BgImage/Properties/PanelCharDefense")
    self.TxtOldDefense = self.Transform:Find("BgImage/Properties/PanelCharDefense/TxtOldDefense"):GetComponent("Text")
    self.TxtCurDefense = self.Transform:Find("BgImage/Properties/PanelCharDefense/TxtCurDefense"):GetComponent("Text")
    self.PanelCharCrit = self.Transform:Find("BgImage/Properties/PanelCharCrit")
    self.TxtOldCrit = self.Transform:Find("BgImage/Properties/PanelCharCrit/TxtOldCrit"):GetComponent("Text")
    self.TxtCurCrit = self.Transform:Find("BgImage/Properties/PanelCharCrit/TxtCurCrit"):GetComponent("Text")
    self.PanelGradeB = self.Transform:Find("BgImage/PanelGrade")
    self.RImgOldIconTitleA = self.Transform:Find("BgImage/PanelGrade/RImgOldIconTitle"):GetComponent("RawImage")
    self.RImgCurIconTitleA = self.Transform:Find("BgImage/PanelGrade/RImgCurIconTitle"):GetComponent("RawImage")
    self.PanelOldStarGoupA = self.Transform:Find("BgImage/PanelGrade/PanelOldStarGoup")
    self.ImgOldStar1A = self.Transform:Find("BgImage/PanelGrade/PanelOldStarGoup/Star1/ImgOldStar1"):GetComponent("Image")
    self.ImgOldOnStar1A = self.Transform:Find("BgImage/PanelGrade/PanelOldStarGoup/Star1/ImgOldOnStar1"):GetComponent("Image")
    self.ImgOldStar2A = self.Transform:Find("BgImage/PanelGrade/PanelOldStarGoup/Star2/ImgOldStar2"):GetComponent("Image")
    self.ImgOldOnStar2A = self.Transform:Find("BgImage/PanelGrade/PanelOldStarGoup/Star2/ImgOldOnStar2"):GetComponent("Image")
    self.ImgOldStar3A = self.Transform:Find("BgImage/PanelGrade/PanelOldStarGoup/Star3/ImgOldStar3"):GetComponent("Image")
    self.ImgOldOnStar3A = self.Transform:Find("BgImage/PanelGrade/PanelOldStarGoup/Star3/ImgOldOnStar3"):GetComponent("Image")
    self.ImgOldStar4A = self.Transform:Find("BgImage/PanelGrade/PanelOldStarGoup/Star4/ImgOldStar4"):GetComponent("Image")
    self.ImgOldOnStar4A = self.Transform:Find("BgImage/PanelGrade/PanelOldStarGoup/Star4/ImgOldOnStar4"):GetComponent("Image")
    self.PanelCurStarGoupA = self.Transform:Find("BgImage/PanelGrade/PanelCurStarGoup")
    self.ImgCurStar1A = self.Transform:Find("BgImage/PanelGrade/PanelCurStarGoup/Star1/ImgCurStar1"):GetComponent("Image")
    self.ImgCurOnStar1A = self.Transform:Find("BgImage/PanelGrade/PanelCurStarGoup/Star1/ImgCurOnStar1"):GetComponent("Image")
    self.ImgCurStar2A = self.Transform:Find("BgImage/PanelGrade/PanelCurStarGoup/Star2/ImgCurStar2"):GetComponent("Image")
    self.ImgCurOnStar2A = self.Transform:Find("BgImage/PanelGrade/PanelCurStarGoup/Star2/ImgCurOnStar2"):GetComponent("Image")
    self.ImgCurStar3A = self.Transform:Find("BgImage/PanelGrade/PanelCurStarGoup/Star3/ImgCurStar3"):GetComponent("Image")
    self.ImgCurOnStar3A = self.Transform:Find("BgImage/PanelGrade/PanelCurStarGoup/Star3/ImgCurOnStar3"):GetComponent("Image")
    self.ImgCurStar4A = self.Transform:Find("BgImage/PanelGrade/PanelCurStarGoup/Star4/ImgCurStar4"):GetComponent("Image")
    self.ImgCurOnStar4A = self.Transform:Find("BgImage/PanelGrade/PanelCurStarGoup/Star4/ImgCurOnStar4"):GetComponent("Image")
end

function XUiPanelGradeUpgrade:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelGradeUpgrade:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelGradeUpgrade:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelGradeUpgrade:AutoAddListener()
    self:RegisterClickEvent(self.BtnDarkBg, self.OnBtnDarkBgClick)
end
-- auto
function XUiPanelGradeUpgrade:OnBtnDarkBgClick()
    self.Parent.GradeUpgradeDisable:PlayTimelineAnimation(function()
        self:HideLevelInfo()
    end)
end

function XUiPanelGradeUpgrade:ShowLevelInfo(characterId)
    local character = XDataCenter.CharacterManager.GetCharacter(characterId)
    self.IsShow = true
    self.GameObject:SetActive(true)
    self:CurCharUpgradeInfo(character)
    CS.XAudioManager.PlaySound(XSoundManager.UiBasicsMusic.Success) -- 成功
end

function XUiPanelGradeUpgrade:HideLevelInfo()
    self.IsShow = false
    if self.GameObject:Exist() then
        self.GameObject:SetActive(false)
    end
end

function XUiPanelGradeUpgrade:OldCharUpgradeInfo(character)
    self.TxtOldAttack.text = XMath.ToMinInt(FixToDouble(character.Attribs[XNpcAttribType.AttackNormal]) or 0)
    self.TxtOldLife.text = XMath.ToMinInt(FixToDouble(character.Attribs[XNpcAttribType.Life]) or 0)
    self.TxtOldDefense.text = XMath.ToMinInt(FixToDouble(character.Attribs[XNpcAttribType.DefenseNormal]) or 0)
    self.TxtOldCrit.text = XMath.ToMinInt(FixToDouble(character.Attribs[XNpcAttribType.Crit]) or 0)
    self:UpdateGradeIcon(character, self.OldStar, self.OldOnStar, self.RImgOldIconTitleA, true)
end

function XUiPanelGradeUpgrade:CurCharUpgradeInfo(character)
    self.TxtCurAttack.text = XMath.ToMinInt(FixToDouble(character.Attribs[XNpcAttribType.AttackNormal]) or 0)
    self.TxtCurLife.text = XMath.ToMinInt(FixToDouble(character.Attribs[XNpcAttribType.Life]) or 0)
    self.TxtCurDefense.text = XMath.ToMinInt(FixToDouble(character.Attribs[XNpcAttribType.DefenseNormal]) or 0)
    self.TxtCurCrit.text = XMath.ToMinInt(FixToDouble(character.Attribs[XNpcAttribType.Crit]) or 0)
    self.TxtName.text = character.Name
    self.RImgCharacterIcon:SetRawImage(XDataCenter.CharacterManager.GetCharBigHeadIcon(character.Id))
    self:UpdateGradeIcon(character, self.CurStar, self.CurOnStar, self.RImgCurIconTitleA, false)
end
-- 刷新星星界面
function XUiPanelGradeUpgrade:UpdateStarInfo(index, onIndex, starGoup, starOnGoup)
    for i = 1, 4 do
        starGoup[i].transform.parent.gameObject:SetActive(true)
        starGoup[i].gameObject:SetActive(false)
        starOnGoup[i].gameObject:SetActive(false)
    end

    if onIndex > 4 then   --封号特殊处理
        for i = 1, #starOnGoup do
            starOnGoup[i].gameObject:SetActive(true)
        end
        return
    end

    if index < 4 then
        for i = index + 1, 4 do
            starGoup[i].transform.parent.gameObject:SetActive(false)
        end
    end

    for i = 1, index do
        starGoup[i].gameObject:SetActive(true)
    end
    for i = 1, onIndex do
        starOnGoup[i].gameObject:SetActive(true)
    end
end

-- 判断当前显示界面信息
function XUiPanelGradeUpgrade:UpdateGradeIcon(character, starGoup, starOnGoup, rImgIcon, isOld)
    local charGradeTemplates = XCharacterConfigs.GetGradeTemplates(character.Id, character.Grade)
    rImgIcon:SetRawImage(charGradeTemplates.GradeBigIcon)
    self:UpdateStarSprite(charGradeTemplates.NoStar, charGradeTemplates.Star, isOld)
    if character.Grade == self.Grading.TheChosenStar then
        self:UpdateStarInfo(self.Grading.TheChosen, character.Grade - self.Grading.AceStar, starGoup, starOnGoup)
        return
    end
    if character.Grade > self.Grading.AceStar then
        self:UpdateStarInfo(self.Grading.TheChosen, character.Grade - self.Grading.AceStar, starGoup, starOnGoup)
        return
    end
    if character.Grade > self.Grading.MainForceStar then
        self:UpdateStarInfo(self.Grading.Ace, character.Grade - self.Grading.MainForceStar, starGoup, starOnGoup)
        return
    end
    if character.Grade > self.Grading.PickedStar then
        self:UpdateStarInfo(self.Grading.MainForce, character.Grade - self.Grading.PickedStar, starGoup, starOnGoup)
        return
    end
    if character.Grade > self.Grading.RecruitStar then
        self:UpdateStarInfo(self.Grading.Picked, character.Grade - self.Grading.RecruitStar, starGoup, starOnGoup)
        return
    end
    if character.Grade <= self.Grading.RecruitStar then
        self:UpdateStarInfo(self.Grading.Recruit, character.Grade, starGoup, starOnGoup)
        return
    end
end

function XUiPanelGradeUpgrade:UpdateStarSprite(starSprite, onStarSprite, isOld)
    if isOld then
        for i = 1, #self.OldStar do
            self.RootUi:SetUiSprite(self.OldStar[i], starSprite)
            self.RootUi:SetUiSprite(self.OldOnStar[i], onStarSprite)
        end
    else
        for i = 1, #self.CurStar do
            self.RootUi:SetUiSprite(self.CurStar[i], starSprite)
            self.RootUi:SetUiSprite(self.CurOnStar[i], onStarSprite)
        end
    end
end