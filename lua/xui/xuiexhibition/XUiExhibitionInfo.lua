local ConditionDesNum = 3
local TabIndexToGrowUpLevel = {
    XCharacterConfigs.GrowUpLevel.Lower,
    XCharacterConfigs.GrowUpLevel.Middle,
    XCharacterConfigs.GrowUpLevel.Higher,
}

local XUiGridCondition = require("XUi/XUiExhibition/XUiGridCondition")

local XUiExhibitionInfo = XLuaUiManager.Register(XLuaUi, "UiExhibitionInfo")

function XUiExhibitionInfo:OnAwake()
    self.GridRewardItem.gameObject:SetActive(false)
    self:InitListener()
end

function XUiExhibitionInfo:OnStart(characterId)
    self.CharacterId = characterId
    self:InitModelRoot()
    self:InitTabBtnGroup()
    self:RegisterRedPointEvent()
end

function XUiExhibitionInfo:OnEnable()
    CS.XGraphicManager.UseUiLightDir = true
end

function XUiExhibitionInfo:OnDisable()
    CS.XGraphicManager.UseUiLightDir = false
end

function XUiExhibitionInfo:InitModelRoot()
    local root = self:GetSceneRoot().transform
    self.PanelRoleModel = root:FindTransform("PanelRoleModel")
    self.RoleModelPanel = XUiPanelRoleModel.New(self.PanelRoleModel, nil, nil, true, nil, true)
end

function XUiExhibitionInfo:InitListener()
    self:RegisterClickEvent(self.BtnBack, self.OnBtnBackClick)
    self:RegisterClickEvent(self.BtnMainUi, self.OnBtnMainUiClick)
    self.BtnBreak.CallBack = function() self:OnBtnBreakClick() end
    self.BtnShowInfoToggle.CallBack = function(value) self:OnBtnShowInfoToggleClick(value) end
end

function XUiExhibitionInfo:RegisterRedPointEvent()
    local characterId = self.CharacterId
    XRedPointManager.AddRedPointEvent(self.BtnTog1, self.OnCheckExhibitionRedPoint, self, { XRedPointConditions.Types.CONDITION_EXHIBITION_NEW }, { characterId, 1 })
    XRedPointManager.AddRedPointEvent(self.BtnTog2, self.OnCheckExhibitionRedPoint, self, { XRedPointConditions.Types.CONDITION_EXHIBITION_NEW }, { characterId, 2 })
    XRedPointManager.AddRedPointEvent(self.BtnTog3, self.OnCheckExhibitionRedPoint, self, { XRedPointConditions.Types.CONDITION_EXHIBITION_NEW }, { characterId, 3 })
end

function XUiExhibitionInfo:OnCheckExhibitionRedPoint(count, args)
    local characterId = args[1]
    local index = args[2]
    local growUpLevel = XDataCenter.ExhibitionManager.GetCharacterGrowUpLevel(characterId)
    self["BtnTog" .. index]:ShowReddot(count >= 0 and growUpLevel == index)
end

function XUiExhibitionInfo:InitTabBtnGroup()
    local tabGroup = {
        self.BtnTog1,
        self.BtnTog2,
        self.BtnTog3,
    }
    self.PanelTogs:Init(tabGroup, function(tabIndex) self:OnClickTabCallBack(tabIndex) end)

    local selected, lastIndex = false
    local growUpLevel = XDataCenter.ExhibitionManager.GetCharacterGrowUpLevel(self.CharacterId)
    for index, level in pairs(TabIndexToGrowUpLevel) do
        if level == growUpLevel + 1 then
            self.PanelTogs:SelectIndex(index)
            selected = true
            break
        end
        lastIndex = index
    end
    if not selected then
        self.PanelTogs:SelectIndex(lastIndex)
    end
end

function XUiExhibitionInfo:OnClickTabCallBack(tabIndex)
    if self.SelectedIndex and self.SelectedIndex == tabIndex then
        return
    end
    self.SelectedIndex = tabIndex

    self:UpdateView()
    self:PlayAnimation("ExhibitionTaskQiehuan")
end

function XUiExhibitionInfo:UpdateView()
    self.BtnShowInfoToggle:SetButtonState(XUiButtonState.Select)
    self:UpdateCharacterInfo()
    self:UpdateCharacterModel(TabIndexToGrowUpLevel[self.SelectedIndex])
    self:ShowTaskInfo()
end

function XUiExhibitionInfo:UpdateCharacterInfo()
    local characterId = self.CharacterId
    self.TxtName.text = XCharacterConfigs.GetCharacterName(characterId)
    self.TxtType.text = XCharacterConfigs.GetCharacterTradeName(characterId)
    self.TxtNumber.text = XCharacterConfigs.GetCharacterCodeStr(characterId)

    local growUpLevel = XDataCenter.ExhibitionManager.GetCharacterGrowUpLevel(characterId)
    local levelIcon = XExhibitionConfigs.GetExhibitionLevelIconByLevel(growUpLevel)
    if not levelIcon or levelIcon == "" then
        self.ImgClassIcon.gameObject:SetActive(false)
    else
        self:SetUiSprite(self.ImgClassIcon, levelIcon)
        self.ImgClassIcon.gameObject:SetActive(true)
    end
end

function XUiExhibitionInfo:UpdateCharacterModel(growUpLevel)
    local characterId = self.CharacterId
    growUpLevel = growUpLevel or XDataCenter.ExhibitionManager.GetCharacterGrowUpLevel(characterId)
    local modelId = XDataCenter.CharacterManager.GetCharLiberationLevelModelId(characterId, growUpLevel)

    self.RoleModelPanel:UpdateCharacterModelByModelId(modelId, characterId, self.PanelRoleModel, nil, function(model)
        self.PanelDrag.Target = model.transform
    end, growUpLevel)
end

function XUiExhibitionInfo:ShowTaskInfo()
    local characterId = self.CharacterId
    local curSelectLevel = TabIndexToGrowUpLevel[self.SelectedIndex]
    local taskConfig = XExhibitionConfigs.GetCharacterGrowUpTask(characterId, curSelectLevel)

    local levelId = taskConfig.LevelId
    self.TxtTitle.text = XExhibitionConfigs.GetExhibitionLevelNameByLevel(levelId)
    self.TxtDesc.text = XExhibitionConfigs.GetExhibitionLevelDescByLevel(levelId)

    local passed = true
    self.ConditionGrids = self.ConditionGrids or {}
    local conditionIds = taskConfig.ConditionIds
    for i = 1, ConditionDesNum do
        local conditionGrid = self.ConditionGrids[i]
        if not conditionGrid then
            conditionGrid = XUiGridCondition.New(self["GridCondition" .. i])
            self.ConditionGrids[i] = conditionGrid
        end

        local conditionId = conditionIds[i]
        local subPassed = conditionGrid:Refresh(conditionId, characterId)
        passed = passed and subPassed
    end

    local rewardItems = XRewardManager.GetRewardList(taskConfig.RewardId)
    self.RewardPool = self.RewardPool or {}
    XUiHelper.CreateTemplates(self, self.RewardPool, rewardItems, XUiGridCommon.New, self.GridRewardItem, self.PanelRewardItem, function(grid, data)
        grid:Refresh(data)
    end)

    local taskId = taskConfig.Id
    local taskFinished = XDataCenter.ExhibitionManager.CheckGrowUpTaskFinish(taskId)
    local canGetReward = passed and not taskFinished
    self.BtnBreak:SetDisable(not canGetReward, canGetReward)
    self.PanelAlreadyBreak.gameObject:SetActive(taskFinished)
    self.BtnBreak.gameObject:SetActive(not taskFinished)

    -- local growUpLevel = XDataCenter.ExhibitionManager.GetCharacterGrowUpLevel(characterId)
    -- self.BtnShowInfoToggle.gameObject:SetActiveEx(curSelectLevel > growUpLevel)
    self.BtnShowInfoToggle.gameObject:SetActiveEx(false)
end

function XUiExhibitionInfo:OnBtnBackClick()
    self:Close()
end

function XUiExhibitionInfo:OnBtnMainUiClick()
    XLuaUiManager.RunMain()
end

function XUiExhibitionInfo:OnBtnBreakClick()
    local characterId = self.CharacterId
    local curSelectLevel = TabIndexToGrowUpLevel[self.SelectedIndex]
    local growUpLevel = XDataCenter.ExhibitionManager.GetCharacterGrowUpLevel(characterId)
    if curSelectLevel ~= growUpLevel + 1 then
        XUiManager.TipText("CharacterLiberateShouldFollowOrder")
        return
    end

    XDataCenter.ExhibitionManager.GetGatherReward(characterId, curSelectLevel, function()
        CS.XAudioManager.PlaySound(XSoundManager.UiBasicsMusic.UiCharacter_Liberation)
        self:UpdateView()
    end)
end

function XUiExhibitionInfo:OnBtnShowInfoToggleClick(value)
    local characterId = self.CharacterId
    local growUpLevel = value == XUiButtonState.Press and TabIndexToGrowUpLevel[self.SelectedIndex]
    self:UpdateCharacterModel(growUpLevel)
end

return XUiExhibitionInfo