local timer

local function RemoveTimer()
    if timer then
        CS.XScheduleManager.UnSchedule(timer)
        timer = nil
    end
end

local function Init(txt, txtName, time)
    if not txt or not txt:Exist() then
        return
    end
    txt.text = CS.XTextManager.GetText(txtName, XUiHelper.GetTime(time))
    
    local refresh = function()
        if not txt or not txt:Exist() then
            RemoveTimer()
        end
        time = time - 1
        txt.text = CS.XTextManager.GetText(txtName, XUiHelper.GetTime(time))
    end

    timer = CS.XScheduleManager.ScheduleForever(refresh, CS.XScheduleManager.SECOND)
end

local DrawRemainTime = {}

DrawRemainTime.Init = Init
DrawRemainTime.RemoveTimer = RemoveTimer

return DrawRemainTime