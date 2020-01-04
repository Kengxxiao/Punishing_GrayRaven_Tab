local CSXDateGetTime = CS.XDate.GetTime
local CSXDateFormatTime = CS.XDate.FormatTime

local XUiPanelSkip = XClass()

function XUiPanelSkip:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
end

function XUiPanelSkip:Refresh(activityCfg)
    if not activityCfg then return end

    local format = "yyyy-MM-dd HH:mm"
    local beginTime = CSXDateGetTime(activityCfg.BeginTime)
    local endTime = CSXDateGetTime(activityCfg.EndTime)
    local beginTimeStr = CSXDateFormatTime(beginTime, format)
    local endTimeStr = CSXDateFormatTime(endTime, format)
    
    self.TxtContentTimeNotice.text = beginTimeStr .. "~" .. endTimeStr
    self.TxtContentTitleNotice.text = string.gsub(activityCfg.ActivityTitle, "\\n", "\n")
    self.TxtContentNotice.text = string.gsub(activityCfg.ActivityDes, "\\n", "\n")

    local skipId = activityCfg.Params[1]
    CsXUiHelper.RegisterClickEvent(self.BtnGo, function ()
        XFunctionManager.SkipInterface(skipId)
    end)
end

return XUiPanelSkip