local CLOSE_TIME = 2

local XUiMedalUnlockTips = XLuaUiManager.Register(XLuaUi, "UiMedalUnlockTips")

function XUiMedalUnlockTips:OnStart(Id)
    local meadalConfig = XMedalConfigs.GetMeadalConfigById(Id)
    self.TextMedalName.text = meadalConfig.Name
    if meadalConfig.MedalImg ~= nil then
        self.ImgMedalIcon:SetRawImage(meadalConfig.MedalImg)
    end
    XLuaUiManager.SetMask(true)
    self:AddCloseTimer()
end

function XUiMedalUnlockTips:OnDestroy()
    XLuaUiManager.SetMask(false)
    XEventManager.DispatchEvent(XEventId.EVENT_MEDAL_TIPSOVER)
end

function XUiMedalUnlockTips:AddCloseTimer()
    local time = 0
    local function action()
        time = time + 1
        if time == CLOSE_TIME then
            XLuaUiManager.Remove( "UiMedalUnlockTips")
        end
    end
    CS.XScheduleManager.Schedule(action, CS.XScheduleManager.SECOND, CLOSE_TIME, 0)
end
