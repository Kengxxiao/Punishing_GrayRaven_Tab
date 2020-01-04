local XUiOnLineMatching = XLuaUiManager.Register(XLuaUi, "UiOnLineMatching")

function XUiOnLineMatching:OnAwake()

end

function XUiOnLineMatching:OnStart(cfgData)
    self:InitAutoScript()
    self.CsUiList = {}
    self.CfgData = cfgData
    self.timerId = -1
    self:StartMatching()
    XEventManager.AddEventListener(XEventId.EVENT_ROOM_ENTER_ROOM, self.OnBack, self)
    XEventManager.AddEventListener(XEventId.EVENT_ROOM_CANCEL_MATCH, self.OnCancelMatch, self)
end

function XUiOnLineMatching:OnDestroy()
    self:RemoveTimer()--移除计时器
    XEventManager.RemoveEventListener(XEventId.EVENT_ROOM_ENTER_ROOM, self.OnBack, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_ROOM_CANCEL_MATCH, self.OnCancelMatch, self)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiOnLineMatching:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiOnLineMatching:AutoInitUi()
    self.PanelMatchingNormal = self.Transform:Find("SafeAreaContentPane/PanelMatchingNormal")
    self.BtnBack = self.Transform:Find("SafeAreaContentPane/PanelMatchingNormal/BtnBack"):GetComponent("Button")
    self.TxtTime = self.Transform:Find("SafeAreaContentPane/PanelMatchingNormal/TxtTime"):GetComponent("Text")
    self.PanelMatchingSimplified = self.Transform:Find("SafeAreaContentPane/PanelMatchingSimplified")
end

function XUiOnLineMatching:GetAutoKey(uiNode, eventName)
    if not uiNode then
        return
    end
    return eventName .. uiNode:GetHashCode()
end

function XUiOnLineMatching:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then
        return
    end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiOnLineMatching:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiOnLineMatching:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterListener(self.BtnBack, "onClick", self.OnBtnBackClick)
    self:RegisterListener(self.BtnReturn, "onClick", self.OnBtnReturnClick)
end
-- auto
function XUiOnLineMatching:OnBtnBackClick()
    --取消匹配
    XDataCenter.RoomManager.CancelMatch()
end

function XUiOnLineMatching:OnCancelMatch()
    -- self:SetIsShow(false)
    self:Close()
end

function XUiOnLineMatching:OnBtnReturnClick(...)
    if self.characterUi ~= nil then
        self.characterUi:OnBtnBackClick()
        self.characterUi.GameObject:SetActive(false)
    end
    if self.bagUi ~= nil then
        self.bagUi:OnBtnBackClick()
        self.bagUi.GameObject:SetActive(false)
    end
    self:SetSimplifiedPanelView(false)
end

function XUiOnLineMatching:OnBack(...)
    self:Close()
end

function XUiOnLineMatching:SetIsShow(code)
    if self.GameObject ~= nil then
        self.GameObject.gameObject:SetActive(code)
    end
    self:SetSimplifiedPanelView(false)
end

function XUiOnLineMatching:SetSimplifiedPanelView(code)
    if self.PanelMatchingNormal == nil or self.PanelMatchingSimplified == nil then
        return
    end
    self.PanelMatchingSimplified.gameObject:SetActive(code)
    self.PanelMatchingNormal.gameObject:SetActive(not code)
end

function XUiOnLineMatching:RemoveTimer()
    if self.timerId ~= -1 then
        CS.XScheduleManager.UnSchedule(self.timerId)
        self.timerId = -1
    end
end

function XUiOnLineMatching:StartCountDown(...)
    --倒计时开始
    self.TxtTime.text = "00:00"
    local startTicks = CS.XTimerManager.Ticks
    local refresh = function(timer)
        if not XDataCenter.RoomManager.Matching then
            self:OnBack()
            return
        end
        local t = math.floor((CS.XTimerManager.Ticks - startTicks) / CS.System.TimeSpan.TicksPerSecond)
        local m = math.floor(t / 60)
        local s = math.floor(t - m * 60)
        local formatTime = string.format("%02d:%02d", m, s)
        self.TxtTime.text = formatTime
        --  self.TxtTimeSimplified.text = formatTime
    end
    self.timerId = CS.XScheduleManager.ScheduleForever(refresh, 0)
end

function XUiOnLineMatching:StartMatching(...)
    self:StartCountDown()
    self:SetIsShow(true)
end

return XUiOnLineMatching