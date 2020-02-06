local XUiPanelAutoFight = XClass()

function XUiPanelAutoFight:Ctor(ui, stageId)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.StageId = stageId
    self:InitAutoScript()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelAutoFight:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiPanelAutoFight:AutoInitUi()
    self.TxtCountdown = self.Transform:Find("TxtCountdown"):GetComponent("Text")
end

function XUiPanelAutoFight:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelAutoFight:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelAutoFight:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelAutoFight:AutoAddListener()
end
-- auto
function XUiPanelAutoFight:OnAutoFightStart(stageId)
    if self.StageId == stageId then
        self.AutoFightRecord = XDataCenter.AutoFightManager.GetRecordByStageId(stageId)
        self:BindTimer()
        self.GameObject:SetActiveEx(true)
    end
end

function XUiPanelAutoFight:OnAutoFightRemove(stageId)
    if self.StageId == stageId then
        self:RemoveTimer()
        if not XTool.UObjIsNil(self.GameObject) then
            self.GameObject:SetActiveEx(false)
        end
    end
end

function XUiPanelAutoFight:BindTimer()
    local stageId = self.StageId
    if not self.AutoFightRecord then return end
    local now = XTime.GetServerNowTimestamp()
    local leftTime = self.AutoFightRecord.CompleteTime - now
    if leftTime < 0 then
        leftTime = 0
    end
    local complete = false
    self:RemoveTimer()
    self.TimerName = "XUiPanelAutoFight" .. stageId
    XCountDown.CreateTimer(self.TimerName, leftTime, now)
    XCountDown.BindTimer(self.GameObject, self.TimerName, function(v)
        if v == 0 and not complete then
            XEventManager.DispatchEvent(XEventId.EVENT_AUTO_FIGHT_COMPLETE, stageId)
            complete = true
        end
        self.TxtCountdown.text = XUiHelper.GetTime(v)
    end)
end

function XUiPanelAutoFight:RemoveTimer()
    if not self.TimerName then
        return
    end
    XCountDown.RemoveTimer(self.TimerName)
    self.TimerName = nil
end

function XUiPanelAutoFight:AddEventListener()
    XEventManager.AddEventListener(XEventId.EVENT_AUTO_FIGHT_START, self.OnAutoFightStart, self)
    XEventManager.AddEventListener(XEventId.EVENT_AUTO_FIGHT_REMOVE, self.OnAutoFightRemove, self)
end

function XUiPanelAutoFight:RemoveEventListener()
    XEventManager.RemoveEventListener(XEventId.EVENT_AUTO_FIGHT_START, self.OnAutoFightStart, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_AUTO_FIGHT_REMOVE, self.OnAutoFightRemove, self)
end

function XUiPanelAutoFight:OnEnable(stageId)
    self.StageId = stageId
    self.AutoFightRecord = XDataCenter.AutoFightManager.GetRecordByStageId(stageId)
    self.GameObject:SetActiveEx(self.AutoFightRecord ~= nil)

    if self.Enabled then
        return
    end

    self:BindTimer()
    self:AddEventListener()

    self.Enabled = true
end

function XUiPanelAutoFight:OnDisable()
    if not self.Enabled then
        return
    end

    self:RemoveTimer()
    self:RemoveEventListener()

    self.Enabled = false
end

return XUiPanelAutoFight