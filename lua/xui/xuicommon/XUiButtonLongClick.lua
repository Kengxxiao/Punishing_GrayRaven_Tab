XUiButtonLongClick = XClass()

-- AddPointerDownListener
-- AddPointerUpListener
-- AddPointerExitListener
-- AddPointerClickListener
-- AddDragListener
-- RemoveAllListeners
local LONG_CLICK_START_OFFSET = 0.5

function XUiButtonLongClick:Ctor(widget, interval, caller, clickCallback, longClickCallback, longClickUpCallback, isCanExit)
    self.GameObject = widget.gameObject
    self.Transform = widget.transform
    self.Widget = widget
    self:SetInterval(interval)
    self.ClickCallbacks = {}
    self.Caller = caller
    if clickCallback then
        table.insert(self.ClickCallbacks, clickCallback)
    end
    self.LongClickCallback = {}
    if longClickCallback then
        table.insert(self.LongClickCallback, longClickCallback)
    end
    self.longClickUpCallbacks = {}
    if longClickUpCallback then
        table.insert(self.longClickUpCallbacks, longClickUpCallback)
    end
    self.Widget:AddPointerDownListener(
    function(eventData)
        self:OnDown(eventData)
    end
    )
    self.Widget:AddPointerExitListener(
    function(eventData)
        if isCanExit then
            self:OnUp(eventData)
        end
    end
    )
    self.Widget:AddPointerUpListener(
    function(eventData)
        self:OnUp(eventData)
    end
    )
end

function XUiButtonLongClick:OnDown(eventData)
    if self.IsPressing then
        return
    end
    self.PointerId = eventData.pointerId
    self.IsPressing = true
    self.frameCount = 0
    self.PressTime = 0
    self.Timer = CS.XScheduleManager.ScheduleForever(
    function() self:Tick() end,
    self.Interval
    )
    self.DownTime = CS.UnityEngine.Time.time
end

function XUiButtonLongClick:OnUp(eventData)
    if eventData and eventData.pointerId ~= self.PointerId then
        return
    end
    self.PointerId = -1
    self.IsPressing = false
    if self.Timer then
        CS.XScheduleManager.UnSchedule(self.Timer)
        self.Timer = nil
    end
    if self.DownTime and CS.UnityEngine.Time.time - self.DownTime < LONG_CLICK_START_OFFSET then
        for i = 1, #self.ClickCallbacks do
            local callback = self.ClickCallbacks[i]
            if callback then
                callback(self.Caller)
            end
        end
    end

    for i = 1, #self.longClickUpCallbacks do
        local callback = self.longClickUpCallbacks[i]
        if callback then
            callback(self.Caller)
        end
    end
end

function XUiButtonLongClick:SetInterval(interval)
    if interval == nil or interval < 0 then
        self.Interval = 100
    else
        self.Interval = interval
    end
end

function XUiButtonLongClick:Tick()
    if not self.GameObject:Exist() or not self.GameObject.activeSelf then
        self:OnUp()
        return
    end
    self.PressTime = self.PressTime + self.Interval
    local pressingTime = self.PressTime - LONG_CLICK_START_OFFSET
    if pressingTime > 0 then
        for i = 1, #self.LongClickCallback do
            local callback = self.LongClickCallback[i]
            if callback then
                callback(self.Caller, pressingTime)
            end
        end
    end
end