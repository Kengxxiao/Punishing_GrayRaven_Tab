local XUiAutoFightExp = XClass()

local mathfloor = math.floor
local timerManager = CS.XTimerManager
local ticksPerSecond = CS.System.TimeSpan.TicksPerSecond

function XUiAutoFightExp:Ctor(expBar, expBarReward, startPercent, endPercent, time)
    self.ImgExpBar = expBar
    self.ImgExpBarReward = expBarReward
    self.StartPercent = startPercent
    self.EndPercent = endPercent
    self.Time = time
    self.ImgExpBar.fillAmount = self.StartPercent
    self:BindTimer()
end

function XUiAutoFightExp:BindTimer()
    self.StartTime = timerManager.Ticks / ticksPerSecond
    self.Timer = timerManager.Add(function(timer)
        if not self.ImgExpBar or not self.ImgExpBar:Exist() then
            self:RemoveTimer()
            return
        end

        local time = timerManager.Ticks / ticksPerSecond
        local dt = time - self.StartTime
        local lerp = dt / self.Time
        local cur = self.StartPercent + (self.EndPercent - self.StartPercent) * lerp
        if cur > 1 then
            self.ImgExpBar.fillAmount = 0
        end

        self.ImgExpBarReward.fillAmount = cur - mathfloor(cur)

        if lerp >= 1 then
            self:RemoveTimer()
        end
    end, 0, 0)
end

function XUiAutoFightExp:RemoveTimer()
    if self.Timer then
        timerManager.Remove(self.Timer.Id)
    end
end

return XUiAutoFightExp