local XUiPanelExpDetail = XClass(XLuaBehaviour)

function XUiPanelExpDetail:Ctor(rootUi, ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.UiRoot = rootUi
    XTool.InitUiObject(self)

    self.OnBtnTouchClickCb = function() self:OnBtnTouchClick() end
    self:InitAddListen()
end

function XUiPanelExpDetail:InitAddListen()
    self.UiRoot:RegisterClickEvent(self.BtnTouch, self.OnBtnTouchClickCb)
end

function XUiPanelExpDetail:InitRoomId(curRoomId)
    self.CurRoomId = curRoomId
    self:Hide()
end

function XUiPanelExpDetail:OnBtnTouchClick()
    self:Hide()
    XDataCenter.DormManager.SetInTouch(true)
    XEventManager.DispatchEvent(XEventId.EVENT_DORM_TOUCH_ENTER, self.CharacterId)
end

function XUiPanelExpDetail:RefreshInfo(isUpdateSpeed)
    local characterData = XDataCenter.DormManager.GetCharacterDataByCharId(self.CharacterId)
    self.TxtStamina.text = characterData.Vitality .. "/" .. XDormConfig.DORM_VITALITY_MAX_VALUE

    if isUpdateSpeed then
        XDataCenter.DormManager.GetDormitoryRecoverSpeed(self.CharacterId, function(moodSpeed, vitalitySpeed, data)
            local vContext = data.VitalitySpeed > 0 and "DormRecovery1" or "DormRecovery2"
            local mContext = data.MoodSpeed > 0 and "DormRecovery1" or "DormRecovery2"

            self.TxtResume.text = CS.XTextManager.GetText(vContext, vitalitySpeed)
            self.TxtMoodResume.text = CS.XTextManager.GetText(mContext, moodSpeed)
        end)
    end

    local charLevelConfig = XDataCenter.DormManager.GetCharRecoveryCurLevel(self.CharacterId)
    self.TxtLevel.text = "Lv." .. charLevelConfig.Pre
end

function XUiPanelExpDetail:UpdateInfo(characterId)
    if not self.CharacterId or self.CharacterId ~= characterId then
        return
    end

    self:RefreshInfo(false)
end

function XUiPanelExpDetail:UpdateExpInfo(characterId)
    if not self.CharacterId or self.CharacterId ~= characterId then
        return
    end

    local characterData = XDataCenter.DormManager.GetCharacterDataByCharId(self.CharacterId)
    local moodConfig = XDormConfig.GetMoodStateByMoodValue(characterData.Mood)

    self.ImgCurEnergy.fillAmount = characterData.Mood / XDormConfig.DORM_MOOD_MAX_VALUE
    self.ImgCurEnergy.color = XDormConfig.GetMoodStateColor(characterData.Mood)
    self.UiRoot:SetUiSprite(self.ImgIcon, moodConfig.Icon)
end

function XUiPanelExpDetail:UpdateFurnitureInfo(characterId)
    local charStyleConfig = XDormConfig.GetCharacterStyleConfigById(characterId)
    if not charStyleConfig then
        return
    end

    local loveTypeConfig = XFurnitureConfigs.GetDormFurnitureType(charStyleConfig.LoveType)
    local likeTypeConfig = XFurnitureConfigs.GetDormFurnitureType(charStyleConfig.LikeType)

    self.UiRoot:SetUiSprite(self.ImgLove, loveTypeConfig.TypeIcon)
    self.UiRoot:SetUiSprite(self.ImgLike, likeTypeConfig.TypeIcon)

    local curRecoveryConfig, nextRecoveryConfig = XDataCenter.DormManager.GetCharRecoveryConfigs(characterId)
    local isMax = curRecoveryConfig == nil and nextRecoveryConfig ~= nil
    self.TxtNextDesc.text = isMax and CS.XTextManager.GetText("DormMaxRecovery") or CS.XTextManager.GetText("DormNextRecovery")

    local scoreA, scoreB, scoreC = XDataCenter.DormManager.GetDormitoryScore(self.CurRoomId)
    local allFurnitureAttrs = XHomeDormManager.GetFurnitureScoresByUnsaveRoom(self.CurRoomId)
    local allScores = allFurnitureAttrs.TotalScore

    local indexA = XFurnitureConfigs.AttrType.AttrA - 1
    local indexB = XFurnitureConfigs.AttrType.AttrB - 1
    local indexC = XFurnitureConfigs.AttrType.AttrC - 1

    if nextRecoveryConfig then
        if nextRecoveryConfig.AttrTotal > 0 then
            self.PanelAll.gameObject:SetActive(true)
            self.TxtAll.gameObject:SetActive(allScores < nextRecoveryConfig.AttrTotal)
            self.TxtAll.text = nextRecoveryConfig.AttrTotal

            self.TxtAllDis.gameObject:SetActive(allScores >= nextRecoveryConfig.AttrTotal)
            self.TxtAllDis.text = nextRecoveryConfig.AttrTotal
        else
            self.PanelAll.gameObject:SetActive(false)
        end

        if nextRecoveryConfig.AttrCondition[indexA] > 0 then
            self.PanelRed.gameObject:SetActive(true)
            self.TxtRed.gameObject:SetActive(scoreA < nextRecoveryConfig.AttrCondition[indexA])
            self.TxtRed.text = nextRecoveryConfig.AttrCondition[indexA]

            self.TxtRedDis.gameObject:SetActive(scoreA >= nextRecoveryConfig.AttrCondition[indexA])
            self.TxtRedDis.text = nextRecoveryConfig.AttrCondition[indexA]
        else
            self.PanelRed.gameObject:SetActive(false)
        end

        if nextRecoveryConfig.AttrCondition[indexB] > 0 then
            self.PanelYellow.gameObject:SetActive(true)
            self.TxtYellow.gameObject:SetActive(scoreB < nextRecoveryConfig.AttrCondition[indexB])
            self.TxtYellow.text = nextRecoveryConfig.AttrCondition[indexB]

            self.TxtYellowDis.gameObject:SetActive(scoreB >= nextRecoveryConfig.AttrCondition[indexB])
            self.TxtYellowDis.text = nextRecoveryConfig.AttrCondition[indexB]
        else
            self.PanelYellow.gameObject:SetActive(false)
        end

        if nextRecoveryConfig.AttrCondition[indexC] > 0 then
            self.PanelBlue.gameObject:SetActive(true)
            self.TxtBlue.gameObject:SetActive(scoreC < nextRecoveryConfig.AttrCondition[indexC])
            self.TxtBlue.text = nextRecoveryConfig.AttrCondition[indexC]

            self.TxtBlueDis.gameObject:SetActive(scoreC >= nextRecoveryConfig.AttrCondition[indexC])
            self.TxtBlueDis.text = nextRecoveryConfig.AttrCondition[indexC]
        else
            self.PanelBlue.gameObject:SetActive(false)
        end
    end
end

function XUiPanelExpDetail:UpdateTransform(transform)
    local pos = transform.position + self.Offset
    local viewPos = XHomeDormManager.GetWorldToViewPoint(self.CurRoomId, pos)

    self.Transform.localPosition = viewPos
end

function XUiPanelExpDetail:Show(characterId, transform)
    self:RemoveTimer()
    self.CharacterId = characterId
    self.TargetTransform = transform

    local styleConfig = XDormConfig.GetCharacterStyleConfigById(characterId)
    self.Offset = CS.UnityEngine.Vector3(0, styleConfig.ExpDetailWidgetHeight, 0)

    self:UpdateTransform(self.TargetTransform)
    self:RefreshInfo(self.CharacterId)
    self:UpdateExpInfo(self.CharacterId)
    self:UpdateFurnitureInfo(self.CharacterId)
    self.GameObject:SetActive(true)

    self.Timer = CS.XScheduleManager.ScheduleOnce(function()
        if XTool.UObjIsNil(self.Transform) or not self.GameObject.activeSelf then
            return
        end

        self:Hide()
    end, XDormConfig.DISPPEAR_TIME)
end

function XUiPanelExpDetail:RemoveTimer()
    if self.Timer then
        CS.XScheduleManager.UnSchedule(self.Timer)
        self.Timer = nil
    end
end

function XUiPanelExpDetail:Hide()
    self:RemoveTimer()
    self.TargetTransform = nil
    self.GameObject:SetActive(false)
end

function XUiPanelExpDetail:Update()
    if not self.GameObject.activeSelf or XTool.UObjIsNil(self.Transform) then
        return
    end

    if XTool.UObjIsNil(self.TargetTransform) then
        return
    end

    self:UpdateTransform(self.TargetTransform)
end

return XUiPanelExpDetail