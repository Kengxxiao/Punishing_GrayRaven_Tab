local XUiFubenFlopReward = XLuaUiManager.Register(XLuaUi, "UiFubenFlopReward")

local PanelStatus = {
    SelectTime = 0,
    WaitForClose = 1
}

function XUiFubenFlopReward:OnAwake()
    self:InitAutoScript()
end

function XUiFubenFlopReward:OnStart(cb, winData)
    self.Cb = cb
    self.WinData = winData
    self.Animation = self.Transform:GetComponent("Animation")
    self.PanelRewardBox.gameObject:SetActive(false)
    self.RewardBox = {}
    self:InitRewardBox()
    self.Selected = false
    self.Status = PanelStatus.SelectTime
    self:StartTimer()
    self.SelectedPlayerId = {}
    self.SelectedPos = {}
    for k, v in pairs(self.WinData.FlopRewardList)  do
        if v.PlayerId and v.PlayerId ~= 0 then
            self.SelectedPlayerId[v.PlayerId] = false
        end
    end

    XEventManager.AddEventListener(XEventId.EVENT_ONLINEBOSS_DROPREWARD_NOTIFY, self.OnDropReaward, self)
end

function XUiFubenFlopReward:OnEnable()
    for k, v in pairs(self.RewardBox) do
        v:OnEnable()
    end
end

function XUiFubenFlopReward:OnDisable()
    for k, v in pairs(self.RewardBox) do
        v:OnDisable()
    end
end

function XUiFubenFlopReward:CheckAllSelected()
    for k, v in pairs(self.SelectedPlayerId) do
        if not v then
            return false
        end
    end
    return true
end

--选取奖励推送
function XUiFubenFlopReward:OnDropReaward(dropData)
    if not self.RewardBox then
        return
    end

    local pos = dropData.Pos
    local playerId = dropData.PlayerId
    local flopRewardList = self.WinData.FlopRewardList

    if playerId == XPlayer.Id then
        self.Animation:Stop()
        self.Selected = true
        self.TxtDesc.color = CS.UnityEngine.Color(1, 1, 1, 1)
        self.TxtDesc.text = CS.XTextManager.GetText("FlopRewardWait")
    end

    self.SelectedPlayerId[playerId] = true

    for k, v in pairs(flopRewardList) do
        if v and playerId == v.PlayerId then
            self.RewardBox[pos]:Refresh(v)
            self.SelectedPos[pos] = true
            break
        end
    end

    if self:CheckAllSelected() then
        self:AutoDrawReward()
    end
end

--自动选择奖励
function XUiFubenFlopReward:AutoDrawReward()
    self.Animation:Stop()
    self.Selected = true
    self.TotalTime = CS.XGame.Config:GetFloat("FlopRewardCloseTime")
    self.Time = self.TotalTime
    self.StartTicks = CS.XTimerManager.Ticks

    self.TxtDesc.text = CS.XTextManager.GetText("FlopRewardWaitClose")
    self.Status = PanelStatus.WaitForClose
    self.TxtDesc.color = CS.UnityEngine.Color(1, 1, 1, 1)

    local flopRewardList = self.WinData.FlopRewardList
    if not flopRewardList then
        return
    end

    for key, var in pairs(flopRewardList) do
        if not self.SelectedPlayerId[var.PlayerId] then
            for k, v in pairs(self.RewardBox) do
                if var and not self.SelectedPos[k] then
                    v:Refresh(var)
                    self.SelectedPos[k] = true
                    break
                end
            end
        end
    end
end

function XUiFubenFlopReward:StartTimer()
    if self.Timers then
        self:StopTimer()
    end

    self.TotalTime = CS.XGame.Config:GetInt("OnlineBossResultSelectTime")
    self.Time = self.TotalTime
    self.StartTicks = CS.XTimerManager.Ticks

    self.Timers = CS.XScheduleManager.ScheduleForever(function(timer)
        self:OnUpdateTime(timer)
    end, 0)
end

function XUiFubenFlopReward:StopTimer()
    if self.Timers then
        CS.XScheduleManager.UnSchedule(self.Timers)
        self.ImgCountDownBarRight.fillAmount = 0
        self.ImgCountDownBarLeft.fillAmount = 0

        self.Timers = nil
        self:OnBtnBgClick()
    end
end

function XUiFubenFlopReward:OnUpdateTime(timer)
    if not self.ImgCountDownBarRight.gameObject:Exist() or not self.ImgCountDownBarLeft.gameObject:Exist() then
        self:StopTimer()
        return
    end

    self.ImgCountDownBarRight.fillAmount = self.Time / self.TotalTime
    self.ImgCountDownBarLeft.fillAmount = self.Time / self.TotalTime

    local t = self.TotalTime - (CS.XTimerManager.Ticks - self.StartTicks) / CS.System.TimeSpan.TicksPerSecond
    self.Time = t
    if self.Time <= 0 then
        if self.Status == PanelStatus.SelectTime then
            self:AutoDrawReward()
        else
            self:StopTimer()
        end
    end
end


-- auto
-- Automatic generation of code, forbid to edit
function XUiFubenFlopReward:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiFubenFlopReward:AutoInitUi()
    self.PanelBase = self.Transform:Find("SafeAreaContentPane/PanelBase")
    self.PanelCountDown = self.Transform:Find("SafeAreaContentPane/PanelBase/PanelCountDown")
    self.ImgCountDownBarRight = self.Transform:Find("SafeAreaContentPane/PanelBase/PanelCountDown/ImgCountDownBarRight"):GetComponent("Image")
    self.ImgCountDownBarLeft = self.Transform:Find("SafeAreaContentPane/PanelBase/PanelCountDown/ImgCountDownBarLeft"):GetComponent("Image")
    self.TxtDesc = self.Transform:Find("SafeAreaContentPane/PanelBase/TxtDesc"):GetComponent("Text")
    self.PanelReward = self.Transform:Find("SafeAreaContentPane/PanelReward")
    self.PanelLayout = self.Transform:Find("SafeAreaContentPane/PanelReward/PanelLayout")
    self.PanelRewardBox = self.Transform:Find("SafeAreaContentPane/PanelReward/PanelLayout/PanelRewardBox")
    self.BtnBg = self.Transform:Find("FullScreenBackground/BtnBg"):GetComponent("Button")
end

function XUiFubenFlopReward:GetAutoKey(uiNode, eventName)
    if not uiNode then
        return
    end
    return eventName .. uiNode:GetHashCode()
end

function XUiFubenFlopReward:RegisterListener(uiNode, eventName, func)
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
            XLog.Error("XUiFubenFlopReward:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiFubenFlopReward:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterListener(self.BtnBg, "onClick", self.OnBtnBgClick)
end
-- auto
function XUiFubenFlopReward:OnBtnBgClick(...)
    if self.Time > 0 then
        return
    end

    if self.Selected == false then
        return
    end

    if self.Cb then
        self.Cb()
    else
        self:Close()
    end
end

function XUiFubenFlopReward:InitRewardBox()
    local rewardCount = XDataCenter.FubenManager.FubenFlopCount
    local canSelect = XDataCenter.FubenManager.CheckHasFlopReward(self.WinData, true)
    local stage = XDataCenter.FubenManager.GetStageCfg(self.WinData.StageId)
    for i = 1, rewardCount, 1 do
        local ui = CS.UnityEngine.Object.Instantiate(self.PanelRewardBox)
        local grid = XUiPanelRewardBox.New(ui, self, i, canSelect, stage.IsMultiplayer)
        grid.Transform:SetParent(self.PanelLayout, false)
        grid.GameObject:SetActive(true)
        self.RewardBox[i] = grid
    end
    self.Animation:Stop()

    if XDataCenter.FubenManager.CheckHasFlopReward(self.WinData, true) then
        self.TxtDesc.text = CS.XTextManager.GetText("FlopRewardSelect")
        self.Animation:Play("UiTxtTips")
    else
        self.TxtDesc.text = CS.XTextManager.GetText("FlopRewardWait")
    end
end

function XUiFubenFlopReward:OnDestroy()
    self:StopTimer()
    XEventManager.RemoveEventListener(XEventId.EVENT_ONLINEBOSS_DROPREWARD_NOTIFY, self.OnDropReaward, self)
end