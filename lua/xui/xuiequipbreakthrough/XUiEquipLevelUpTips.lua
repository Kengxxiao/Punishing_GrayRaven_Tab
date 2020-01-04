local CLOSE_TIME = 2

local XUiEquipLevelUpTips = XLuaUiManager.Register(XLuaUi, "UiEquipLevelUpTips")

function XUiEquipLevelUpTips:OnStart(tipStr, closeCb)
    self.TipStr = tipStr
    self.CloseCb = closeCb
    self.BtnClose.CallBack = function()
        self:Close()
    end
end

function XUiEquipLevelUpTips:OnEnable()
    self:UpdateView()
    self:AddCloseTimer()
end

function XUiEquipLevelUpTips:OnDisable()
    self:ClearCloseTimer()
end

function XUiEquipLevelUpTips:OnDestroy()
    if self.CloseCb then self.CloseCb() end
end

function XUiEquipLevelUpTips:UpdateView()
    self.TxtDes.text = self.TipStr
end

function XUiEquipLevelUpTips:AddCloseTimer()
    self:ClearCloseTimer()
    local time = 0
    local function action()
        time = time + 1
        if time == CLOSE_TIME then
            self:Close()
        end
    end
    self.Timer = CS.XScheduleManager.Schedule(action, CS.XScheduleManager.SECOND, CLOSE_TIME, 0)
end

function XUiEquipLevelUpTips:ClearCloseTimer()
    if self.Timer then
        CS.XScheduleManager.UnSchedule(self.Timer)
        self.Timer = nil
    end
end