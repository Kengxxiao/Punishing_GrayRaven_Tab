local PANEL_INDEX = {
    Level = 1,
    Grade = 2,
    Quality = 3,
    Skill = 4,
}

local XUiPanelCharProperty = XLuaUiManager.Register(XLuaUi, "UiPanelCharProperty")

function XUiPanelCharProperty:OnAwake()
    self:AddListener()
end

function XUiPanelCharProperty:OnStart(parent, defaultIdx)
    self.Parent = parent
    self.DefaultIdx = defaultIdx

    self:InitChildUiInfos()
    self:InitBtnTabGroup()
    self:RegisterOtherEvent()
    self:RegisterRedPointEvent()
end

function XUiPanelCharProperty:OnEnable()
    self.CharacterId = self.Parent.CharacterId
    self.Parent.SViewCharacterList.gameObject:SetActiveEx(false)
    self.Parent.BtnFashion.gameObject:SetActiveEx(false)
    self.Parent.BtnOwnedDetail.gameObject:SetActiveEx(false)
    self.PanelPropertyButtons:SelectIndex(self.DefaultIdx or self.SelectedIndex or PANEL_INDEX.Level)
end

function XUiPanelCharProperty:OnDisable()
    self.Parent.SViewCharacterList.gameObject:SetActiveEx(true)
    self.Parent.BtnFashion.gameObject:SetActiveEx(true)
    self.Parent.BtnOwnedDetail.gameObject:SetActiveEx(true)
end

function XUiPanelCharProperty:OnDestroy()
    self:RemoveOtherEvent()
end

function XUiPanelCharProperty:InitChildUiInfos()
    self.PanelsMap = {}
    self.ChildUiInitInfos = {
        [PANEL_INDEX.Level] = {
            ChildClass = XUiPanelCharLevel,
            UiParent = self.PanelCharLevel,
            AssetPath = XUiConfigs.GetComponentUrl(self.Name .. PANEL_INDEX.Level),
        },
        [PANEL_INDEX.Skill] = {
            ChildClass = XUiPanelCharSkill,
            UiParent = self.PanelCharSkill,
            AssetPath = XUiConfigs.GetComponentUrl(self.Name .. PANEL_INDEX.Skill),
        },
        [PANEL_INDEX.Quality] = {
            ChildClass = XUiPanelCharQuality,
            UiParent = self.PanelCharQuality,
            AssetPath = XUiConfigs.GetComponentUrl(self.Name .. PANEL_INDEX.Quality),
        },
        [PANEL_INDEX.Grade] = {
            ChildClass = XUiPanelCharGrade,
            UiParent = self.PanelCharGrade,
            AssetPath = XUiConfigs.GetComponentUrl(self.Name .. PANEL_INDEX.Grade),
        },
    }
end

function XUiPanelCharProperty:InitBtnTabGroup()
    self.BtnTabGrade:SetDisable(not XFunctionManager.JudgeOpen(XFunctionManager.FunctionName.CharacterGrade))
    self.BtnTabQuality:SetDisable(not XFunctionManager.JudgeOpen(XFunctionManager.FunctionName.CharacterQuality))
    self.BtnTabSkill:SetDisable(not XFunctionManager.JudgeOpen(XFunctionManager.FunctionName.CharacterSkill))

    local tabGroup = {
        [PANEL_INDEX.Level] = self.BtnTabLevel,
        [PANEL_INDEX.Grade] = self.BtnTabGrade,
        [PANEL_INDEX.Quality] = self.BtnTabQuality,
        [PANEL_INDEX.Skill] = self.BtnTabSkill,
    }
    self.PanelPropertyButtons:Init(tabGroup, function(tabIndex) self:OnClickTabCallBack(tabIndex) end)
end

function XUiPanelCharProperty:OnClickTabCallBack(tabIndex)
    if tabIndex == PANEL_INDEX.Level then
        self.Parent.GameObject:PlayLegacyAnimation("LevelBegan")
        self.PreCameraType = XCharacterConfigs.XUiCharacter_Camera.LEVEL
    elseif tabIndex == PANEL_INDEX.Grade then
        if not XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.CharacterGrade) then
            return
        end
        self.Parent.GameObject:PlayLegacyAnimation("AniPanelGradesBegin")
        self.PreCameraType = XCharacterConfigs.XUiCharacter_Camera.GRADE
    elseif tabIndex == PANEL_INDEX.Quality then
        if not XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.CharacterQuality) then
            return
        end
        self.Parent.GameObject:PlayLegacyAnimation("AniPanelQualityBegin")
        self.PreCameraType = XCharacterConfigs.XUiCharacter_Camera.QULITY
    elseif tabIndex == PANEL_INDEX.Skill then
        if not XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.CharacterSkill) then
            return
        end
        self.PreCameraType = XCharacterConfigs.XUiCharacter_Camera.SKILL
        self.Parent.GameObject:PlayLegacyAnimation("SkillBegan")
    end

    self.SelectedIndex = tabIndex
    self:UpdateShowPanel()
end

function XUiPanelCharProperty:UpdateShowPanel()
    self.Parent:UpdateCamera(self.PreCameraType)

    local index = self.SelectedIndex
    for k, panel in pairs(self.PanelsMap) do
        if k ~= index then
            panel:HidePanel()
        end
    end

    local panel = self.PanelsMap[index]
    if not panel then
        local childUiInfo = self.ChildUiInitInfos[index]
        local ui = childUiInfo.UiParent:LoadPrefab(childUiInfo.AssetPath)
        panel = childUiInfo.ChildClass.New(ui, self)
        self.PanelsMap[index] = panel
    end
    panel:ShowPanel(self.CharacterId)

    self:OnCheckRedPoint()
end

function XUiPanelCharProperty:OnCheckRedPoint()
    local characterId = self.CharacterId
    XRedPointManager.CheckByNode(self.BtnTabGrade, characterId)
    XRedPointManager.CheckByNode(self.BtnTabQuality, characterId)
    XRedPointManager.CheckByNode(self.BtnTabSkill, characterId)
    XRedPointManager.CheckByNode(self.BtnTabLevel, characterId)
end

function XUiPanelCharProperty:RegisterOtherEvent()
    XEventManager.AddEventListener(XEventId.EVENT_ITEM_BUYASSET, self.UpdateCondition, self)
    XEventManager.AddEventListener(XEventId.EVENT_CHARACTER_INCREASE_TIP, self.ShowTip, self)
end

function XUiPanelCharProperty:RegisterRedPointEvent()
    local characterId = self.CharacterId
    XRedPointManager.AddRedPointEvent(self.BtnTabGrade, self.OnCheckCharacterGradeRedPoint, self, { XRedPointConditions.Types.CONDITION_CHARACTER_GRADE }, characterId)
    XRedPointManager.AddRedPointEvent(self.BtnTabQuality, self.OnCheckCharacterQualityRedPoint, self, { XRedPointConditions.Types.CONDITION_CHARACTER_QUALITY }, characterId)
    XRedPointManager.AddRedPointEvent(self.BtnTabSkill, self.OnCheckCharacterSkillRedPoint, self, { XRedPointConditions.Types.CONDITION_CHARACTER_SKILL }, characterId)
    XRedPointManager.AddRedPointEvent(self.BtnTabLevel, self.OnCheckCharacterLevelRedPoint, self, { XRedPointConditions.Types.CONDITION_CHARACTER_LEVEL }, characterId)
end

function XUiPanelCharProperty:RemoveOtherEvent()
    XEventManager.RemoveEventListener(XEventId.EVENT_ITEM_BUYASSET, self.UpdateCondition, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_CHARACTER_INCREASE_TIP, self.ShowTip, self)
end

function XUiPanelCharProperty:UpdateCondition()
    local gradePanel = self.PanelsMap[PANEL_INDEX.Grade]
    if gradePanel then
        gradePanel:UpdateUseItemView()
    end
end

function XUiPanelCharProperty:OnCheckCharacterGradeRedPoint(count, args)
    self.BtnTabGrade:ShowReddot(count >= 0)
end

function XUiPanelCharProperty:OnCheckCharacterQualityRedPoint(count, args)
    self.BtnTabQuality:ShowReddot(count >= 0)
end

function XUiPanelCharProperty:OnCheckCharacterSkillRedPoint(count, args)
    self.BtnTabSkill:ShowReddot(count >= 0)
end

function XUiPanelCharProperty:OnCheckCharacterLevelRedPoint(count, args)
    self.BtnTabLevel:ShowReddot(count >= 0)
end

function XUiPanelCharProperty:AddListener()
    self:RegisterClickEvent(self.BtnExchange, self.OnBtnExchangeClick)
end

function XUiPanelCharProperty:OnBtnExchangeClick()
    self.Parent:OpenChangeCharacterView()
end

function XUiPanelCharProperty:RecoveryPanel()
    local levelPanel = self.PanelsMap[PANEL_INDEX.Level]
    if levelPanel and levelPanel.SelectLevelItems.IsShow then
        levelPanel.SelectLevelItems:HidePanel()
        levelPanel:ShowPanel()
        self.Parent.GameObject:PlayLegacyAnimation("LevelBegan")
        return true
    end

    local skillPanel = self.PanelsMap[PANEL_INDEX.Skill]
    if skillPanel and skillPanel.SkillInfoPanel.IsShow then
        skillPanel.SkillInfoPanel:HidePanel()
        skillPanel:ShowPanel()
        self.Parent.GameObject:PlayLegacyAnimation("SkillBegan")
        return true
    end

    return false
end

function XUiPanelCharProperty:ShowTip(stringDescribe, attrib, oldLevel)
    local character = XDataCenter.CharacterManager.GetCharacter(self.CharacterId)
    if oldLevel and oldLevel < character.Level then
        CS.XAudioManager.PlaySound(XSoundManager.UiBasicsMusic.UiCharacter_LevelUp)
        return
    end

    stringDescribe = stringDescribe or ""
    attrib = attrib or ""
    XLuaUiManager.Open("UiLeftPopupTip", stringDescribe, attrib)
end