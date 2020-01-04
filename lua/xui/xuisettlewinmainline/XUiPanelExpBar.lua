local FILL_SPEED = 1
local MathfLerp = CS.UnityEngine.Mathf.Lerp
local CSTime = CS.UnityEngine.Time

local XUiPanelExpBar = XClass()

function XUiPanelExpBar:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
    self:InitView()
end

function XUiPanelExpBar:InitView()
    self.ImgPlayerExpFillAdd.fillAmount = 0
    self.GameObject:ScheduleForever(function()
        if not self.FullTimes then return end
        local beginFillAmount = self.BeginFillAmount
        if not beginFillAmount then return end
        local finalFillAmount = self.FinalFillAmount
        if not finalFillAmount then return end
        local curLevel = self.CurLevel
        if not curLevel then return end
        local lastLevel = self.LastLevel
        if not lastLevel then return end
        
        local lerpPercent = FILL_SPEED * (self.StartTime)
        self.StartTime = self.StartTime + CSTime.deltaTime
        if curLevel > lastLevel then
            local finalFullTimes = curLevel - lastLevel

            if self.FullTimes == 0 then
                self.ImgPlayerExpFill.fillAmount = MathfLerp(beginFillAmount, 1, lerpPercent)
            elseif self.FullTimes < finalFullTimes then
                self.ImgPlayerExpFill.fillAmount = MathfLerp(0, 1, lerpPercent)
            else
                self.ImgPlayerExpFill.fillAmount = MathfLerp(0, finalFillAmount, lerpPercent)
                if lerpPercent >= 1 then
                    self.FullTimes = nil
                end
            end

            if self.FullTimes and lerpPercent >= 1 then
                -- self.FullTimes = self.FullTimes + 1    --这里是一条条涨上去的动画
                self.FullTimes = finalFullTimes  --跳过中间过程，只播首尾
                if self.FullTimes >= finalFullTimes then
                    self.StartTime = 0
                    self.ImgPlayerExpFillAdd.fillAmount = finalFillAmount
                end
            end
        else
            self.ImgPlayerExpFill.fillAmount = MathfLerp(beginFillAmount, finalFillAmount, lerpPercent)
            if lerpPercent >= 1 then
                self.FullTimes = nil
            end
        end
    end, 0)
end

function XUiPanelExpBar:LetsRoll(lastLevel, lastExp, lastMaxExp, curLevel, curExp, curMaxExp, addExp)
    self.BeginFillAmount = lastExp / lastMaxExp
    self.FinalFillAmount = curExp / curMaxExp
    self.CurLevel = curLevel
    self.LastLevel = lastLevel
    self.StartTime = 0
    self.FullTimes = 0

    if curLevel <= lastLevel then
        self.ImgPlayerExpFillAdd.fillAmount = self.FinalFillAmount
    end
    self.ImgPlayerExpFill.gameObject:SetActiveEx(true)

    if self.TxtPlayerLevel then
        self.TxtPlayerLevel.text = curLevel
    end

    if self.TxtPlayerExp then
        self.TxtPlayerExp.text = "+ " .. addExp
    end
end

function XUiPanelExpBar:SkipRoll(lastLevel, lastExp, lastMaxExp, curLevel, curExp, curMaxExp, addExp)
    local finalFillAmount = curExp / curMaxExp

    self.ImgPlayerExpFill.fillAmount = finalFillAmount
    self.ImgPlayerExpFillAdd.fillAmount = finalFillAmount
    self.ImgPlayerExpFill.gameObject:SetActiveEx(true)
    if self.TxtPlayerExp then
        self.TxtPlayerExp.text = "+ " .. addExp
    end
end

return XUiPanelExpBar