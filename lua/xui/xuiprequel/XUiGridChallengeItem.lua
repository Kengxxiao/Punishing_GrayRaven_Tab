XUiGridChallengeItem = XClass()

function XUiGridChallengeItem:Ctor(ui, rootUi, index, clickCb)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    self.Index = index
    self.ClickCb = clickCb
    self:InitAutoScript()
    self.PanelAutoFight.gameObject:SetActive(true)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiGridChallengeItem:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiGridChallengeItem:AutoInitUi()
    self.PanelActive = XUiHelper.TryGetComponent(self.Transform, "PanelActive", nil)
    self.RImgChallengeIcon = XUiHelper.TryGetComponent(self.Transform, "PanelActive/RImgChallengeIcon", "RawImage")
    self.TxtTitle = XUiHelper.TryGetComponent(self.Transform, "PanelActive/TxtTitle", "Text")
    self.PanelLock = XUiHelper.TryGetComponent(self.Transform, "PanelLock", nil)
    self.TxtLockDesc = XUiHelper.TryGetComponent(self.Transform, "PanelLock/TxtLockDesc", "Text")
    self.BtnClickMask = XUiHelper.TryGetComponent(self.Transform, "BtnClickMask", "Button")
    self.TxtLeftTimes = XUiHelper.TryGetComponent(self.Transform, "TxtLeftTimes", "Text")
    self.PanelAutoFight = XUiHelper.TryGetComponent(self.Transform, "PanelAutoFight", nil)
    self.TxtCountdown = XUiHelper.TryGetComponent(self.Transform, "PanelAutoFight/TxtCountdown", "Text")
end

function XUiGridChallengeItem:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiGridChallengeItem:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiGridChallengeItem:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiGridChallengeItem:AutoAddListener()
    self:RegisterClickEvent(self.BtnClickMask, self.OnBtnClickMaskClick)
end
-- auto

function XUiGridChallengeItem:OnBtnClickMaskClick(eventData)
    if self.ChallengeStage then
        local stageId = self.ChallengeStage.ChallengeStage
        -- local isLock = self:IsChallengeStageLock(stageId)
        -- if isLock then
        --     self.RootUi:Switch2UnlockChallengeStage(self.ChallengeStage)
        -- else
        -- end
        --isLock=false
        self.RootUi:OpenOneChildUi("UiPrequelLineDetail")
        self.RootUi:FindChildUiObj("UiPrequelLineDetail"):Refresh(stageId)
        self.RootUi:SetPanelAssetActive(false)
        
        if self.ClickCb then
            self.ClickCb(self.Index)
        end
    end
end

function XUiGridChallengeItem:UpdateChallengeGridInfo(challengeStage)
    self.ChallengeStage = challengeStage
    local stageId = challengeStage.ChallengeStage
    -- local isLock = self:IsChallengeStageLock(stageId)
    self.PanelLock.gameObject:SetActive(false)
    local stageCfg = XDataCenter.FubenManager.GetStageCfg(stageId)
    self.TxtTitle.text = stageCfg.Name
    self.RImgChallengeIcon:SetRawImage(stageCfg.Icon)

    self:UpdateChallangeTimes(stageId)

    self:UpdateAutoFightStatus()
end

function XUiGridChallengeItem:UpdateChallangeTimes(stageId)
    -- local isLock = self:IsChallengeStageLock(stageId)
    local stageCfg = XDataCenter.FubenManager.GetStageCfg(stageId)
    local maxChallengeNums = stageCfg.MaxChallengeNums or 0

    -- if isLock then
    --     self.TxtLeftTimes.text = ""
    -- else
    -- end
    --isLock == false
    local csInfo = XDataCenter.PrequelManager.GetUnlockChallengeStagesByStageId(stageId)
    if csInfo then
        local leftTimes = maxChallengeNums - csInfo.Count
        self.TxtLeftTimes.text = CS.XTextManager.GetText("PrequelChapterTimes", leftTimes)
    else
        self.TxtLeftTimes.text = CS.XTextManager.GetText("PrequelChapterTimes", maxChallengeNums)
    end
end

function XUiGridChallengeItem:UpdateAutoFightStatus()
    if not self.ChallengeStage then return end
    local stageId = self.ChallengeStage.ChallengeStage
    local stageCfg = XDataCenter.FubenManager.GetStageCfg(stageId)

    if self.PanelAutoFight then
        self.PanelAutoFight.localScale = CS.UnityEngine.Vector3.zero
    end

    if stageCfg.AutoFightId > 0 then
        self.AutoFightRecord = XDataCenter.AutoFightManager.GetRecordByStageId(stageId)
        if self.AutoFightRecord and self.PanelAutoFight then
            local now = XTime.Now()
            local showTimes = self.AutoFightRecord.CompleteTime - now
            self.PanelAutoFight.localScale = CS.UnityEngine.Vector3.one
            if showTimes == 0 then
                XEventManager.DispatchEvent(XEventId.EVENT_AUTO_FIGHT_COMPLETE, stageId)
            end
            if showTimes < 0 then
                showTimes = 0
            end
            self.TxtCountdown.text = XUiHelper.GetTime(showTimes)
            self:UpdateChallangeTimes(stageId)
        end
    end
end

function XUiGridChallengeItem:IsChallengeStageLock(stageId)
    return XDataCenter.PrequelManager.GetUnlockChallengeStagesByStageId(stageId) == nil
end

return XUiGridChallengeItem
