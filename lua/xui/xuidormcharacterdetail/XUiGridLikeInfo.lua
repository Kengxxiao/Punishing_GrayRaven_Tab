local XUiGridLikeInfo = XClass()

function XUiGridLikeInfo:Ctor(ui, rootUi)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    XTool.InitUiObject(self)
end

function XUiGridLikeInfo:Refresh(config)
    if XDataCenter.DormManager.CheckCharInDorm(config.CharacterId) then
        local charLevelConfig = XDataCenter.DormManager.GetCharRecoveryCurLevel(config.CharacterId)
        local isCur = charLevelConfig and charLevelConfig.Pre == config.Pre
        self.PanelCurLevel.gameObject:SetActive(isCur)
    else
        self.PanelCurLevel.gameObject:SetActive(false)
    end
    
    local indexA = XFurnitureConfigs.AttrType.AttrA - 1
    local indexB = XFurnitureConfigs.AttrType.AttrB - 1
    local indexC = XFurnitureConfigs.AttrType.AttrC - 1

    local vitalitySpeed = XFurnitureConfigs.GetRecoverSpeed(config.VitalityRecovery)
    local moodSpeed = XFurnitureConfigs.GetRecoverSpeed(config.MoodRecovery)

    self.TxtLevel.text = "Lv." .. config.Pre
    local vContext = config.VitalityRecoveryType > 0 and "DormVitalityRecovery1" or "DormVitalityRecovery"
    local mContext = config.MoodRecoveryType > 0 and "DormMoodRecovery1" or "DormMoodRecovery"

    self.TxtVitality.text = CS.XTextManager.GetText(vContext, vitalitySpeed)
    self.TxtMood.text = CS.XTextManager.GetText(mContext, moodSpeed)

    if config.AttrTotal > 0 then
        local allConfig = XFurnitureConfigs.GetDormFurnitureType(XFurnitureConfigs.AttrType.AttrAll)
        self.RootUi:SetUiSprite(self.ImgeAllIcon, allConfig.TypeIcon)
        self.TxtAllDesc.text = allConfig.TypeName .. "≥" .. config.AttrTotal
    else
        self.ConditionsAll.gameObject:SetActive(false)
    end

    if config.AttrCondition[indexA] > 0 then
        local redConfig = XFurnitureConfigs.GetDormFurnitureType(XFurnitureConfigs.AttrType.AttrA)
        self.RootUi:SetUiSprite(self.ImgeRedIcon, redConfig.TypeIcon)
        self.TxtRedDesc.text = redConfig.TypeName .. "≥" .. config.AttrCondition[indexA]
    else
        self.ConditionsRed.gameObject:SetActive(false)
    end

    if config.AttrCondition[indexB] > 0 then
        local yellowConfig = XFurnitureConfigs.GetDormFurnitureType(XFurnitureConfigs.AttrType.AttrB)
        self.RootUi:SetUiSprite(self.ImgeYellowIcon, yellowConfig.TypeIcon)
        self.TxtYellowDesc.text = yellowConfig.TypeName .. "≥" .. config.AttrCondition[indexB]
    else
        self.ConditionsYellow.gameObject:SetActive(false)
    end

    if config.AttrCondition[indexC] > 0 then
        local blueConfig = XFurnitureConfigs.GetDormFurnitureType(XFurnitureConfigs.AttrType.AttrC)
        self.RootUi:SetUiSprite(self.ImgeBlueIcon, blueConfig.TypeIcon)
        self.TxtBlueDesc.text = blueConfig.TypeName .. "≥" .. config.AttrCondition[indexC]
    else
        self.ConditionsBlue.gameObject:SetActive(false)
    end
end

return XUiGridLikeInfo