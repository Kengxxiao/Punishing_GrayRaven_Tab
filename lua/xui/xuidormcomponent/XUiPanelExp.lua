local XUiPanelExp = XClass(XLuaBehaviour)

function XUiPanelExp:Ctor(rootUi, ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi

    XTool.InitUiObject(self)
end

function XUiPanelExp:InitRoomId(curRoomId)
    self.CurRoomId = curRoomId
    self:Hide(true)
end

function XUiPanelExp:RefreshExpInfo(changeValue)
    self:RemoveTimer()
    local characterData = XDataCenter.DormManager.GetCharacterDataByCharId(self.CharacterId)
    local moodConfig = XDormConfig.GetMoodStateByMoodValue(characterData.Mood)

    self.ImgCurEnergy.fillAmount = characterData.Mood / XDormConfig.DORM_MOOD_MAX_VALUE
    self.ImgCurEnergy.color = XDormConfig.GetMoodStateColor(characterData.Mood)
    self.RootUi:SetUiSprite(self.ImgIcon, moodConfig.Icon)
    self.TxtMoodAdd.gameObject:SetActive(false)

    XDataCenter.DormManager.GetDormitoryRecoverSpeed(self.CharacterId, function(moodSpeed, vitalitySpeed, data)
        local vContext = data.VitalitySpeed > 0 and "DormRecovery1" or "DormRecovery2"
        local mContext = data.MoodSpeed > 0 and "DormRecovery1" or "DormRecovery2"

        self.TxtResume.text = CS.XTextManager.GetText(vContext, vitalitySpeed)
        self.TxtMoodResume.text = CS.XTextManager.GetText(mContext, moodSpeed)
    end)

    local charLevelConfig = XDataCenter.DormManager.GetCharRecoveryCurLevel(self.CharacterId)
    self.TxtLevel.text = "Lv." .. charLevelConfig.Pre

    -- 不展示心情值减少事件
    if changeValue and changeValue > 0 then
        self.TxtMoodAdd.text = "+" .. changeValue
        self.TxtMoodAdd.gameObject:SetActive(true)

        self.Timer = CS.XScheduleManager.ScheduleOnce(function()
            if XTool.UObjIsNil(self.Transform) or not self.GameObject.activeSelf then
                return
            end

            self.TxtMoodAdd.gameObject:SetActive(false)
        end, XDormConfig.DISPPEAR_TIME)
    end
end

function XUiPanelExp:RemoveTimer()
    if self.Timer then
        CS.XScheduleManager.UnSchedule(self.Timer)
        self.Timer = nil
    end
end

function XUiPanelExp:UpdateExpInfo(characterId, changeValue)
    if not self.CharacterId or self.CharacterId ~= characterId then
        return
    end

    self:RefreshExpInfo(changeValue)
end

function XUiPanelExp:UpdateTransform(transform)
    local pos = transform.position + self.Offset
    local viewPos = XHomeDormManager.GetWorldToViewPoint(self.CurRoomId, pos)
    self.Transform.localPosition = viewPos
end

function XUiPanelExp:Show(characterId, transform)
    if characterId and not self.CharacterId then
        self.CharacterId = characterId
    end

    if transform and not self.TargetTransform then
        self.TargetTransform = transform
    end

    self.StyleConfig = XDormConfig.GetCharacterStyleConfigById(self.CharacterId)
    self:UpdateOffset()

    self:UpdateTransform(self.TargetTransform)
    self:RefreshExpInfo()
    self.GameObject:SetActive(true)
end

function XUiPanelExp:UpdateOffset()
    local offsetHight = self.StyleConfig.ExpFondleWidgetHeight
    self.Offset = CS.UnityEngine.Vector3(0, offsetHight, 0)
 end

function XUiPanelExp:Hide(clearId)
    self:RemoveTimer()
    self.TargetTransform = nil
    if clearId then
        self.CharacterId = nil
    end
    self.GameObject:SetActive(false)
end

function XUiPanelExp:Update()
    if not self.GameObject.activeSelf or XTool.UObjIsNil(self.Transform) then
        return
    end

    if XTool.UObjIsNil(self.TargetTransform) then
        return
    end

    self:UpdateTransform(self.TargetTransform)
end

return XUiPanelExp