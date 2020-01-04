local table = table
local tableInsert = table.insert

XUiPanelCharGrade = XClass()

local Show_Part = {
    [1] = XNpcAttribType.Life,
    [2] = XNpcAttribType.AttackNormal,
    [3] = XNpcAttribType.DefenseNormal,
    [4] = XNpcAttribType.Crit,
}

local MAX_CONDITION_NUM = 5

function XUiPanelCharGrade:Ctor(ui, parent)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Parent = parent

    self:InitAutoScript()
    self.ConditionGrids = {}
    self.CharGradeUpgradePanel = XUiPanelGradeUpgrade.New(self.PanelGradeUpgrade, self.Parent, self)
    self.CharGradeUpgradePanel.GameObject:SetActive(false)
    self.CanvasGroup = self.PanelGrades:GetComponent("CanvasGroup")
    self.Star = { self.ImgStar1, self.ImgStar2, self.ImgStar3, self.ImgStar4 }
    self.OnStar = { self.ImgOnStar1, self.ImgOnStar2, self.ImgOnStar3, self.ImgOnStar4 }
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

    self.GradeStarCheck = {
        [self.Grading.RecruitStar] = true,
        [self.Grading.PickedStar] = true,
        [self.Grading.MainForceStar] = true,
        [self.Grading.AceStar] = true,
        [self.Grading.TheChosenStar] = true,
    }

    self.TxtAttrib = {
        [1] = self.TxtAttrib1,
        [2] = self.TxtAttrib2,
        [3] = self.TxtAttrib3,
        [4] = self.TxtAttrib4
    }

    self.TxtNormal = {
        [1] = self.TxtNormal1A,
        [2] = self.TxtNormal2A,
        [3] = self.TxtNormal3A,
        [4] = self.TxtNormal4A
    }

    self.TxtLevel = {
        [1] = self.TxtLevel1A,
        [2] = self.TxtLevel2A,
        [3] = self.TxtLevel3A,
        [4] = self.TxtLevel4A
    }

    self.PanelCondition = {
        [1] = self.PanelCondition1,
        [2] = self.PanelCondition2,
        [3] = self.PanelCondition3,
        [4] = self.PanelCondition4,
        [5] = self.PanelCondition5,
    }

    self.TxtOffSatisfy = {
        [1] = self.TxtOffSatisfy1,
        [2] = self.TxtOffSatisfy2,
        [3] = self.TxtOffSatisfy3,
        [4] = self.TxtOffSatisfy4,
        [5] = self.TxtOffSatisfy5,
    }

    self.TxtOnSatisfy = {
        [1] = self.TxtOnSatisfy1,
        [2] = self.TxtOnSatisfy2,
        [3] = self.TxtOnSatisfy3,
        [4] = self.TxtOnSatisfy4,
        [5] = self.TxtOnSatisfy5,
    }

    self.PanelOff = {
        [1] = self.PanelOff1,
        [2] = self.PanelOff2,
        [3] = self.PanelOff3,
        [4] = self.PanelOff4,
        [5] = self.PanelOff5,
    }

    self.PanelOn = {
        [1] = self.PanelOn1,
        [2] = self.PanelOn2,
        [3] = self.PanelOn3,
        [4] = self.PanelOn4,
        [5] = self.PanelOn5,
    }
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelCharGrade:InitAutoScript()
    self:AutoInitUi()
    XTool.InitUiObject(self)
    self:AutoAddListener()
end

function XUiPanelCharGrade:AutoInitUi()
    self.PanelGrades = self.Transform:Find("PanelGrades")
    self.PanelParts = self.Transform:Find("PanelGrades/PanelParts")
    self.PanelPartsItems = self.Transform:Find("PanelGrades/PanelParts/PanelPartsItems")
    self.GridPart1 = self.Transform:Find("PanelGrades/PanelParts/PanelPartsItems/GridPart1")
    self.TxtAttrib1 = self.Transform:Find("PanelGrades/PanelParts/PanelPartsItems/GridPart1/Image/TxtAttrib1"):GetComponent("Text")
    self.TxtNormal1A = self.Transform:Find("PanelGrades/PanelParts/PanelPartsItems/GridPart1/Image/TxtNormal1"):GetComponent("Text")
    self.TxtLevel1A = self.Transform:Find("PanelGrades/PanelParts/PanelPartsItems/GridPart1/Image/TxtLevel1"):GetComponent("Text")
    self.GridPart2 = self.Transform:Find("PanelGrades/PanelParts/PanelPartsItems/GridPart2")
    self.TxtAttrib2 = self.Transform:Find("PanelGrades/PanelParts/PanelPartsItems/GridPart2/Image/TxtAttrib2"):GetComponent("Text")
    self.TxtNormal2A = self.Transform:Find("PanelGrades/PanelParts/PanelPartsItems/GridPart2/Image/TxtNormal2"):GetComponent("Text")
    self.TxtLevel2A = self.Transform:Find("PanelGrades/PanelParts/PanelPartsItems/GridPart2/Image/TxtLevel2"):GetComponent("Text")
    self.GridPart3 = self.Transform:Find("PanelGrades/PanelParts/PanelPartsItems/GridPart3")
    self.TxtAttrib3 = self.Transform:Find("PanelGrades/PanelParts/PanelPartsItems/GridPart3/Image/TxtAttrib3"):GetComponent("Text")
    self.TxtNormal3A = self.Transform:Find("PanelGrades/PanelParts/PanelPartsItems/GridPart3/Image/TxtNormal3"):GetComponent("Text")
    self.TxtLevel3A = self.Transform:Find("PanelGrades/PanelParts/PanelPartsItems/GridPart3/Image/TxtLevel3"):GetComponent("Text")
    self.GridPart4 = self.Transform:Find("PanelGrades/PanelParts/PanelPartsItems/GridPart4")
    self.TxtAttrib4 = self.Transform:Find("PanelGrades/PanelParts/PanelPartsItems/GridPart4/Image/TxtAttrib4"):GetComponent("Text")
    self.TxtNormal4A = self.Transform:Find("PanelGrades/PanelParts/PanelPartsItems/GridPart4/Image/TxtNormal4"):GetComponent("Text")
    self.TxtLevel4A = self.Transform:Find("PanelGrades/PanelParts/PanelPartsItems/GridPart4/Image/TxtLevel4"):GetComponent("Text")
    self.PanelTitle = self.Transform:Find("PanelGrades/DetailPanel/PanelTitle")
    self.PanelConditions = self.Transform:Find("PanelGrades/DetailPanel/PanelConditions")
    self.PanelCondition5 = self.Transform:Find("PanelGrades/DetailPanel/PanelConditions/PanelCondition5")
    self.PanelOff5 = self.Transform:Find("PanelGrades/DetailPanel/PanelConditions/PanelCondition5/PanelOff5")
    self.TxtOffSatisfy5 = self.Transform:Find("PanelGrades/DetailPanel/PanelConditions/PanelCondition5/PanelOff5/TxtOffSatisfy5"):GetComponent("Text")
    self.PanelOn5 = self.Transform:Find("PanelGrades/DetailPanel/PanelConditions/PanelCondition5/PanelOn5")
    self.TxtOnSatisfy5 = self.Transform:Find("PanelGrades/DetailPanel/PanelConditions/PanelCondition5/PanelOn5/TxtOnSatisfy5"):GetComponent("Text")
    self.PanelCondition4 = self.Transform:Find("PanelGrades/DetailPanel/PanelConditions/PanelCondition4")
    self.PanelOff4 = self.Transform:Find("PanelGrades/DetailPanel/PanelConditions/PanelCondition4/PanelOff4")
    self.TxtOffSatisfy4 = self.Transform:Find("PanelGrades/DetailPanel/PanelConditions/PanelCondition4/PanelOff4/TxtOffSatisfy4"):GetComponent("Text")
    self.PanelOn4 = self.Transform:Find("PanelGrades/DetailPanel/PanelConditions/PanelCondition4/PanelOn4")
    self.TxtOnSatisfy4 = self.Transform:Find("PanelGrades/DetailPanel/PanelConditions/PanelCondition4/PanelOn4/TxtOnSatisfy4"):GetComponent("Text")
    self.PanelCondition3 = self.Transform:Find("PanelGrades/DetailPanel/PanelConditions/PanelCondition3")
    self.PanelOff3 = self.Transform:Find("PanelGrades/DetailPanel/PanelConditions/PanelCondition3/PanelOff3")
    self.TxtOffSatisfy3 = self.Transform:Find("PanelGrades/DetailPanel/PanelConditions/PanelCondition3/PanelOff3/TxtOffSatisfy3"):GetComponent("Text")
    self.PanelOn3 = self.Transform:Find("PanelGrades/DetailPanel/PanelConditions/PanelCondition3/PanelOn3")
    self.TxtOnSatisfy3 = self.Transform:Find("PanelGrades/DetailPanel/PanelConditions/PanelCondition3/PanelOn3/TxtOnSatisfy3"):GetComponent("Text")
    self.PanelCondition2 = self.Transform:Find("PanelGrades/DetailPanel/PanelConditions/PanelCondition2")
    self.PanelOff2 = self.Transform:Find("PanelGrades/DetailPanel/PanelConditions/PanelCondition2/PanelOff2")
    self.TxtOffSatisfy2 = self.Transform:Find("PanelGrades/DetailPanel/PanelConditions/PanelCondition2/PanelOff2/TxtOffSatisfy2"):GetComponent("Text")
    self.PanelOn2 = self.Transform:Find("PanelGrades/DetailPanel/PanelConditions/PanelCondition2/PanelOn2")
    self.TxtOnSatisfy2 = self.Transform:Find("PanelGrades/DetailPanel/PanelConditions/PanelCondition2/PanelOn2/TxtOnSatisfy2"):GetComponent("Text")
    self.PanelCondition1 = self.Transform:Find("PanelGrades/DetailPanel/PanelConditions/PanelCondition1")
    self.PanelOff1 = self.Transform:Find("PanelGrades/DetailPanel/PanelConditions/PanelCondition1/PanelOff1")
    self.TxtOffSatisfy1 = self.Transform:Find("PanelGrades/DetailPanel/PanelConditions/PanelCondition1/PanelOff1/TxtOffSatisfy1"):GetComponent("Text")
    self.PanelOn1 = self.Transform:Find("PanelGrades/DetailPanel/PanelConditions/PanelCondition1/PanelOn1")
    self.TxtOnSatisfy1 = self.Transform:Find("PanelGrades/DetailPanel/PanelConditions/PanelCondition1/PanelOn1/TxtOnSatisfy1"):GetComponent("Text")
    self.ImgMax1 = self.Transform:Find("PanelGrades/ImgMax1"):GetComponent("Image")
    self.ImgMaxPartGrade = self.Transform:Find("PanelGrades/DetailPanel/Advanced/ImgMaxPartGrade"):GetComponent("Image")
    self.PanelGrade = self.Transform:Find("PanelGrades/PanelGrade")
    self.RImgIconTitle = self.Transform:Find("PanelGrades/PanelGrade/RImgIconTitle"):GetComponent("RawImage")
    self.PanelStarGoup = self.Transform:Find("PanelGrades/PanelGrade/PanelStarGoup")
    self.ImgStar1 = self.Transform:Find("PanelGrades/PanelGrade/PanelStarGoup/Star1/ImgStar1"):GetComponent("Image")
    self.ImgOnStar1 = self.Transform:Find("PanelGrades/PanelGrade/PanelStarGoup/Star1/ImgOnStar1"):GetComponent("Image")
    self.ImgStar2 = self.Transform:Find("PanelGrades/PanelGrade/PanelStarGoup/Star2/ImgStar2"):GetComponent("Image")
    self.ImgOnStar2 = self.Transform:Find("PanelGrades/PanelGrade/PanelStarGoup/Star2/ImgOnStar2"):GetComponent("Image")
    self.ImgStar3 = self.Transform:Find("PanelGrades/PanelGrade/PanelStarGoup/Star3/ImgStar3"):GetComponent("Image")
    self.ImgOnStar3 = self.Transform:Find("PanelGrades/PanelGrade/PanelStarGoup/Star3/ImgOnStar3"):GetComponent("Image")
    self.ImgStar4 = self.Transform:Find("PanelGrades/PanelGrade/PanelStarGoup/Star4/ImgStar4"):GetComponent("Image")
    self.ImgOnStar4 = self.Transform:Find("PanelGrades/PanelGrade/PanelStarGoup/Star4/ImgOnStar4"):GetComponent("Image")
    self.BtnWisdom = self.Transform:Find("PanelGrades/DetailPanel/Advanced/BtnWisdom"):GetComponent("Button")
    self.TxtCosume = self.Transform:Find("PanelGrades/DetailPanel/TxtCosume"):GetComponent("Text")
    self.TxtCosumeOn = self.Transform:Find("PanelGrades/DetailPanel/TxtCosumeOn"):GetComponent("Text")
    self.PanelMaxLevelShow = self.Transform:Find("PanelGrades/DetailPanel/PanelMaxLevelShow")
    self.PanelGradeUpgrade = self.Transform:Find("PanelGradeUpgrade")
end

function XUiPanelCharGrade:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelCharGrade:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelCharGrade:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelCharGrade:AutoAddListener()
    self:RegisterClickEvent(self.BtnWisdom, self.OnBtnWisdomClick)
end
-- auto
function XUiPanelCharGrade:OnBtnCancelClick(eventData)

end

function XUiPanelCharGrade:OnBtnConfirmClick(eventData)

end
function XUiPanelCharGrade:OnBtnWisdomClick(...)
    self:UpgradePart()
end

function XUiPanelCharGrade:ShowPanel(characterId)
    self.GameObject:SetActive(true)
    self.CharacterId = characterId or self.CharacterId
    self.IsShow = true
    self.PanelGrades.gameObject:SetActive(true)
    self.GradeQiehuan:PlayTimelineAnimation()
    self.PanelPartsItems.gameObject:SetActive(true)
    self.CharGradeUpgradePanel.GameObject:SetActive(false)
    self:UpdateGradeData()
    self.CanvasGroup.alpha = 1
end

function XUiPanelCharGrade:HidePanel()
    local playAnimation = self.IsShow
    self.IsShow = false
    self.CurPartPos = nil
    if (self.GridParts) then
        for _, grid in pairs(self.GridParts) do
            grid:SetSelect(false)
        end
    end
    self.GameObject:SetActive(false)
    self.PanelGrades.gameObject:SetActive(false)
end

-- 重新刷新级别数据
function XUiPanelCharGrade:UpdateGradeData()
    local character = XDataCenter.CharacterManager.GetCharacter(self.CharacterId)
    local isMaxGrade = XDataCenter.CharacterManager.IsMaxCharGrade(character)
    if isMaxGrade then
        self:UpdateAttribMax()
        self:UpdateGradeInfo()
    else
        self.PanelMaxLevelShow.gameObject:SetActive(false)
        self.PanelTitle.gameObject:SetActive(true)
        self.PanelConditions.gameObject:SetActive(true)
        self.BtnWisdom.gameObject:SetActive(true)
        self.ImgMaxPartGrade.gameObject:SetActive(false)
        self.TxtCosumeOn.gameObject:SetActive(true)
        self.TxtCosume.gameObject:SetActive(true)

        self:UpdateGradeInfo()
        self:UpdateAttribs()
        self:UpdateConditions()
        self:UpdateUseItemView()
    end
end

-- 刷新主面板信息
function XUiPanelCharGrade:UpdateGradeInfo()
    local characterId = self.CharacterId
    local character = XDataCenter.CharacterManager.GetCharacter(characterId)

    local charGradeTemplates = XCharacterConfigs.GetGradeTemplates(characterId, character.Grade)
    self.RImgIconTitle:SetRawImage(charGradeTemplates.GradeBigIcon)
    self:UpdateStarSprite(charGradeTemplates.NoStar, charGradeTemplates.Star)

    if character.Grade > self.Grading.TheChosenStar then
        self:UpdateStarInfo(self.Grading.TheChosen, character.Grade - self.Grading.AceStar)
        return
    end

    if character.Grade > self.Grading.AceStar then
        self:UpdateStarInfo(self.Grading.TheChosen, character.Grade - self.Grading.AceStar)
        return
    end

    if character.Grade > self.Grading.MainForceStar then
        self:UpdateStarInfo(self.Grading.Ace, character.Grade - self.Grading.MainForceStar)
        return
    end

    if character.Grade > self.Grading.PickedStar then
        self:UpdateStarInfo(self.Grading.MainForce, character.Grade - self.Grading.PickedStar)
        return
    end

    if character.Grade > self.Grading.RecruitStar then
        self:UpdateStarInfo(self.Grading.Picked, character.Grade - self.Grading.RecruitStar)
        return
    end

    if character.Grade <= self.Grading.RecruitStar then
        self:UpdateStarInfo(self.Grading.Recruit, character.Grade)
        return
    end
end

function XUiPanelCharGrade:UpdateStarSprite(starSprite, onStarSprite)
    for i = 1, #self.Star do
        self.Parent:SetUiSprite(self.Star[i], starSprite)
        self.Parent:SetUiSprite(self.OnStar[i], onStarSprite)
    end
end

-- 刷新星星界面
function XUiPanelCharGrade:UpdateStarInfo(index, onIndex)
    for i = 1, #self.Star do
        self.Star[i].gameObject:SetActive(false)
        self.OnStar[i].gameObject:SetActive(false)
    end

    if onIndex > #self.Star then
        for i = 1, #self.Star do
            self.Star[i].gameObject:SetActive(false)
            self.OnStar[i].gameObject:SetActive(true)
        end
        return
    end

    for i = 1, index do
        self.Star[i].gameObject:SetActive(true)
    end

    for i = 1, onIndex do
        self.OnStar[i].gameObject:SetActive(true)
    end
end

function XUiPanelCharGrade:UpdateAttribs()
    local characterId = self.CharacterId
    local character = XDataCenter.CharacterManager.GetCharacter(characterId)

    local curGradeConfig = XCharacterConfigs.GetGradeTemplates(characterId, character.Grade)
    local nextGradeConfig = XCharacterConfigs.GetGradeTemplates(characterId, character.Grade + 1)
    local nextAttrib = XAttribManager.GetBaseAttribs(nextGradeConfig.AttrId)
    local curAttrib = XAttribManager.GetBaseAttribs(curGradeConfig.AttrId)

    for i = 1, 4 do
        local name = XAttribManager.GetAttribNameByIndex(Show_Part[i])
        local attribType = Show_Part[i]
        self.TxtAttrib[i].text = name
        self.TxtNormal[i].text = XMath.ToMinInt(FixToDouble(curAttrib[attribType]))
        self.TxtLevel[i].text = string.format("(%s)", XMath.ToMinInt(FixToDouble(nextAttrib[attribType])))
    end
end

function XUiPanelCharGrade:UpdateAttribMax()
    local characterId = self.CharacterId
    local character = XDataCenter.CharacterManager.GetCharacter(characterId)

    self.PanelTitle.gameObject:SetActive(false)
    self.PanelConditions.gameObject:SetActive(false)
    self.PanelMaxLevelShow.gameObject:SetActive(true)
    self.ImgMaxPartGrade.gameObject:SetActive(true)
    self.BtnWisdom.gameObject:SetActive(false)
    self.TxtCosumeOn.gameObject:SetActive(false)
    self.TxtCosume.gameObject:SetActive(false)

    local curGradeConfig = XCharacterConfigs.GetGradeTemplates(characterId, character.Grade)
    local curAttrib = XAttribManager.GetBaseAttribs(curGradeConfig.AttrId)
    for i = 1, 4 do
        local name = XAttribManager.GetAttribNameByIndex(Show_Part[i])
        local attribType = Show_Part[i]
        self.TxtAttrib[i].text = name
        self.TxtNormal[i].text = XMath.ToMinInt(FixToDouble(curAttrib[attribType]))
        self.TxtLevel[i].text = ""
    end
end

function XUiPanelCharGrade:UpdateConditions()
    local characterId = self.CharacterId
    local character = XDataCenter.CharacterManager.GetCharacter(characterId)

    local gradeTemplate = XCharacterConfigs.GetGradeTemplates(characterId, character.Grade)
    local conditions = gradeTemplate.ConditionId

    if not conditions then
        return
    end

    for i = 1, MAX_CONDITION_NUM do
        if conditions[i] then
            local config = XConditionManager.GetConditionTemplate(conditions[i])
            if config then
                self.PanelCondition[i].gameObject:SetActive(true)
                self.TxtOnSatisfy[i].text = config.Desc
                self.TxtOffSatisfy[i].text = config.Desc

                local isCompleted = XConditionManager.CheckCondition(conditions[i], characterId)
                self.PanelOn[i].gameObject:SetActive(isCompleted)
                self.PanelOff[i].gameObject:SetActive(not isCompleted)
            end
        else
            self.PanelCondition[i].gameObject:SetActive(false)
        end
    end
end

function XUiPanelCharGrade:UpdateUseItemView()
    local characterId = self.CharacterId
    if not characterId then return end
    local character = XDataCenter.CharacterManager.GetCharacter(characterId)

    local gradeConfig = XCharacterConfigs.GetGradeTemplates(characterId, character.Grade)
    local itemCode = gradeConfig.UseItemKey
    local itemNum = gradeConfig.UseItemCount
    local item = XDataCenter.ItemManager.GetItemTemplate(itemCode)
    local consumeText = CS.XTextManager.GetText("CharGradeUseItem", item.Name, itemNum)
    self.TxtCosume.text = consumeText
    self.TxtCosumeOn.text = consumeText

    local isCoinEnough = XDataCenter.CharacterManager.IsUseItemEnough(itemCode, itemNum)

    if isCoinEnough then
        self.TxtCosumeOn.gameObject:SetActive(true)
        self.TxtCosume.gameObject:SetActive(false)
    else
        self.TxtCosumeOn.gameObject:SetActive(false)
        self.TxtCosume.gameObject:SetActive(true)
    end
end

function XUiPanelCharGrade:CloseBtn()
    self.BtnWisdom.gameObject:SetActive(false)
end

function XUiPanelCharGrade:UpgradePart()
    local characterId = self.CharacterId
    local character = XDataCenter.CharacterManager.GetCharacter(characterId)

    local isMaxGrade = XDataCenter.CharacterManager.IsMaxCharGrade(character)
    if isMaxGrade then
        return
    end

    local gradeConfig = XCharacterConfigs.GetGradeTemplates(characterId, character.Grade)
    local conditions = gradeConfig.ConditionId

    for i = 1, MAX_CONDITION_NUM do
        if conditions[i] then
            local isConditionEnough = XConditionManager.CheckCondition(conditions[i], characterId)
            if (not isConditionEnough) then
                XUiManager.TipText("CharacterPromotePartItemLimit")
                return
            end
        end
    end

    if not XDataCenter.ItemManager.DoNotEnoughBuyAsset(gradeConfig.UseItemKey,
            gradeConfig.UseItemCount,
            1,
            function() 
                self:UpgradePart() 
            end,
            "CharacterPromotePartCoinLimit") then
        return
    end

    self.CharGradeUpgradePanel:OldCharUpgradeInfo(character)
    XDataCenter.CharacterManager.PromoteGrade(characterId, function(oldGrade)
        CS.XAudioManager.PlaySound(XSoundManager.UiBasicsMusic.UiCharacter_GradeUp)

        self:UpdateGradeData()
        self.GradeUpgradeEnable:PlayTimelineAnimation()

        if self.GradeStarCheck[oldGrade] then
            self.CharGradeUpgradePanel:ShowLevelInfo(characterId)
        else
            XEventManager.DispatchEvent(XEventId.EVENT_CHARACTER_INCREASE_TIP, CS.XTextManager.GetText("CharacterUpgradeComplete"))
        end
    end)

end