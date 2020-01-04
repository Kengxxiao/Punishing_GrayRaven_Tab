local XUiPromotionWay = XLuaUiManager.Register(XLuaUi, "UiPromotionWay")

function XUiPromotionWay:OnStart(showAbility, teamData, stageFightControlId, stageId)
    self.StageFightControlId = stageFightControlId
    self.TeamData = teamData
    self.ShowAbility = showAbility
    self.StageId = stageId
    self.BtnClose.CallBack = function() self:OnBtnClose() end
    self.BtnCharacterJump.CallBack = function() self:OnBtnCharacterJump() end
    self.BtnEquipJump.CallBack = function() self:OnBtnEquipJump() end

    local chapterName, stageName = XDataCenter.FubenManager.GetFubenNames(self.StageId)
    self.TxtTitle.text = stageName
end

function XUiPromotionWay:OnEnable()
    self:UpdateData()
end

function XUiPromotionWay:OnBtnClose()
    self:Close()
end

function XUiPromotionWay:OnBtnCharacterJump()
    XLuaUiManager.Open("UiCharacter", self.TeamData[self.TargetCharacter], nil, nil, nil, true)
end

function XUiPromotionWay:OnBtnEquipJump()
    XLuaUiManager.Open("UiCharacter", self.TeamData[self.TargetCharacter])
end

function XUiPromotionWay:UpdateData()
    local data = XFubenConfigs.GetStageFightControl(self.StageFightControlId)
    local targetAbility
    if data.MaxShowFight > 0 then
        targetAbility = data.MaxShowFight
    elseif data.AvgShowFight > 0 then
        targetAbility = data.AvgShowFight
    else
        targetAbility = data.ShowFight
    end
    --找出最接近战力限制的为显示目标
    local teamAbility = {}
    for i = 1, #self.TeamData do
        local character = XDataCenter.CharacterManager.GetCharacter(self.TeamData[i])
        if character == nil then
            table.insert(teamAbility, 0)
        else
            table.insert(teamAbility, character.Ability)
        end
    end

    local targetCharacter = 1
    for i = 2, #self.TeamData do
        if targetAbility - teamAbility[i] > 0 and targetAbility - teamAbility[i] < math.abs(targetAbility - teamAbility[targetCharacter]) then
            targetCharacter = i
        end
    end

    targetCharacter = self.TeamData[targetCharacter] ~= 0 and targetCharacter or self.TargetCharacter

    self.TargetCharacter = targetCharacter
    local targetCharacterAbility = data.CharacterFight
    local targetEquipAbility = data.EquipFight
    local equipAbility = XDataCenter.EquipManager.GetEquipAbility(self.TeamData[targetCharacter])
    local characterAbility = teamAbility[targetCharacter] - equipAbility

    self.TxtCharacter.text = math.floor(characterAbility / targetCharacterAbility * 100) .. "%"
    self.ImgCharacterProgress.fillAmount = 0
    self.ImgCharacterProgress:DOFillAmount(characterAbility / targetCharacterAbility, 0.5)
    self.TxtEquip.text = math.floor(equipAbility / targetEquipAbility * 100) .. "%"
    self.ImgEquipProgress.fillAmount = 0
    self.ImgEquipProgress:DOFillAmount(equipAbility / targetEquipAbility, 0.5)
end