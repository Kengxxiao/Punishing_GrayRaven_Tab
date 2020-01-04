local XUiPanelFurnitureLike = XClass()

function XUiPanelFurnitureLike:Ctor(rootUi, ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    XTool.InitUiObject(self)

    self.OnBtnDetailClickCb = function() self:OnBtnDetailClick() end
    self:InitAddListen()
end

function XUiPanelFurnitureLike:InitAddListen()
    self.RootUi:RegisterClickEvent(self.BtnDetail, self.OnBtnDetailClickCb)
end

function XUiPanelFurnitureLike:OnBtnDetailClick()
    XLuaUiManager.Open("UiDormCharacterLikeInfo", self.CharacterId)
end

function XUiPanelFurnitureLike:Refresh(characterId, curRoomId)
    self.CharacterId = characterId

    local curRecoveryConfig, nextRecoveryConfig = XDataCenter.DormManager.GetCharRecoveryConfigs(characterId)
    local isMax = curRecoveryConfig == nil and nextRecoveryConfig ~= nil
    self.TxtNextDesc.text = isMax and CS.XTextManager.GetText("DormMaxRecovery") or CS.XTextManager.GetText("DormNextRecovery2")

    local scoreA, scoreB, scoreC = XDataCenter.DormManager.GetDormitoryScore(curRoomId)
    local allFurnitureAttrs = XHomeDormManager.GetFurnitureScoresByUnsaveRoom(curRoomId)
    local allScores = allFurnitureAttrs.TotalScore

    local indexA = XFurnitureConfigs.AttrType.AttrA - 1
    local indexB = XFurnitureConfigs.AttrType.AttrB - 1
    local indexC = XFurnitureConfigs.AttrType.AttrC - 1

    if nextRecoveryConfig then
        local vitalitySpeed = XFurnitureConfigs.GetRecoverSpeed(nextRecoveryConfig.VitalityRecovery)
        local moodSpeed = XFurnitureConfigs.GetRecoverSpeed(nextRecoveryConfig.MoodRecovery)

        local vContext = nextRecoveryConfig.VitalityRecoveryType > 0 and "DormVitalityRecovery1" or "DormVitalityRecovery"
        local mContext = nextRecoveryConfig.MoodRecoveryType > 0 and "DormMoodRecovery1" or "DormMoodRecovery"

        self.TxtResume.text = CS.XTextManager.GetText(vContext, vitalitySpeed)
        self.TxtMoodResume.text = CS.XTextManager.GetText(mContext, moodSpeed)

        if nextRecoveryConfig.AttrTotal > 0 then
            self.PanelAll.gameObject:SetActive(true)
            self.TxtAllScore.gameObject:SetActive(allScores >= nextRecoveryConfig.AttrTotal)
            self.TxtAllScore.text = "≥" .. nextRecoveryConfig.AttrTotal

            self.TxtAllDisScore.gameObject:SetActive(allScores < nextRecoveryConfig.AttrTotal)
            self.TxtAllDisScore.text = "≥" .. nextRecoveryConfig.AttrTotal
        else
            self.PanelAll.gameObject:SetActive(false)
        end

        if nextRecoveryConfig.AttrCondition[indexA] > 0 then
            self.PanelRed.gameObject:SetActive(true)
            self.TxtRedScore.gameObject:SetActive(scoreA >= nextRecoveryConfig.AttrCondition[indexA])
            self.TxtRedScore.text = "≥" ..  nextRecoveryConfig.AttrCondition[indexA]

            self.TxtRedDisScore.gameObject:SetActive(scoreA < nextRecoveryConfig.AttrCondition[indexA])
            self.TxtRedDisScore.text = "≥" ..  nextRecoveryConfig.AttrCondition[indexA]
        else
            self.PanelRed.gameObject:SetActive(false)
        end

        if nextRecoveryConfig.AttrCondition[indexB] > 0 then
            self.PanelYellow.gameObject:SetActive(true)
            self.TxtYellowScore.gameObject:SetActive(scoreB >= nextRecoveryConfig.AttrCondition[indexB])
            self.TxtYellowScore.text = "≥" ..  nextRecoveryConfig.AttrCondition[indexB]

            self.TxtYellowDisScore.gameObject:SetActive(scoreB < nextRecoveryConfig.AttrCondition[indexB])
            self.TxtYellowDisScore.text = "≥" ..  nextRecoveryConfig.AttrCondition[indexB]
        else
            self.PanelYellow.gameObject:SetActive(false)
        end

        if nextRecoveryConfig.AttrCondition[indexC] > 0 then
            self.PanelBlue.gameObject:SetActive(true)
            self.TxtBlueScore.gameObject:SetActive(scoreC >= nextRecoveryConfig.AttrCondition[indexC])
            self.TxtBlueScore.text = "≥" ..  nextRecoveryConfig.AttrCondition[indexC]

            self.TxtBlueDisScore.gameObject:SetActive(scoreC < nextRecoveryConfig.AttrCondition[indexC])
            self.TxtBlueDisScore.text = "≥" ..  nextRecoveryConfig.AttrCondition[indexC]
        else
            self.PanelBlue.gameObject:SetActive(false)
        end
    end
end

return XUiPanelFurnitureLike