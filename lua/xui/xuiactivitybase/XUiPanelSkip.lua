local ParseToTimestamp = XTime.ParseToTimestamp
local TimestampToGameDateTimeString = XTime.TimestampToGameDateTimeString

local XUiPanelSkip = XClass()

function XUiPanelSkip:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
end

function XUiPanelSkip:Refresh(activityCfg)
    if not activityCfg then return end

    local format = "yyyy-MM-dd HH:mm"
    local beginTime = ParseToTimestamp(activityCfg.BeginTime)
    local endTime = ParseToTimestamp(activityCfg.EndTime)
    if beginTime and endTime then
        local beginTimeStr = TimestampToGameDateTimeString(beginTime, format)
        local endTimeStr = TimestampToGameDateTimeString(endTime, format)
        self.TxtContentTimeNotice.text = beginTimeStr .. "~" .. endTimeStr
    end

    self.TxtContentTitleNotice.text = string.gsub(activityCfg.ActivityTitle, "\\n", "\n")
    self.TxtContentNotice.text = string.gsub(activityCfg.ActivityDes, "\\n", "\n")

    local skipId = activityCfg.Params[1]
    CsXUiHelper.RegisterClickEvent(self.BtnGo, function ()
        XFunctionManager.SkipInterface(skipId)
    end)
end

return XUiPanelSkip