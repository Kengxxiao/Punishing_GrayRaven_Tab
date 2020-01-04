local XUiMultiplayerFightGrade = XLuaUiManager.Register(XLuaUi, "UiMultiplayerFightGrade")
local XUiGridFightGradeItem = require("XUi/XUiMultiplayerFightGrade/XUiGridFightGradeItem")

local countDownTime = CS.XGame.Config:GetInt("OnlinePraiseCountDown")

function XUiMultiplayerFightGrade:OnAwake()
    self:RegisterClickEvent(self.BtnContinue, self.OnBtnContinueClick)
end

function XUiMultiplayerFightGrade:OnStart(cb)
    self:Init()
    self.Cb = cb
end

function XUiMultiplayerFightGrade:OnBtnContinueClick(eventData)
    if not self.IsCountDownFinish then
        return
    end
    
    if self.Cb then
        self.Cb()
    else
        self:Close()
    end
end

function XUiMultiplayerFightGrade:Init()
    local beginData = XDataCenter.FubenManager.GetFightBeginData()
    local PlayerList = beginData.PlayerList
    local dpsTable = XDataCenter.FubenManager.LastDpsTable

    local index = 1
    self.GridList = {}
    for k, v in pairs(PlayerList) do
        local ui
        if index == 1 then
            ui = self.GridFightGradeItem
        else
            ui = CS.UnityEngine.GameObject.Instantiate(self.GridFightGradeItem, self.PanelFightGradeContainer)
        end
        self.GridList[v.Id] = XUiGridFightGradeItem.New(ui, self)
        index = index + 1
    end

    for k, v in pairs(PlayerList) do
        local dps = dpsTable[v.Id]
        local grid = self.GridList[v.Id]
        grid:Init(v)
        grid:Refresh(dps)
        if v.Id == XPlayer.Id then
            grid:SwitchMyself()
        else
            grid:SwitchNormal()
        end
    end

    self:StartCountDown()
end

function XUiMultiplayerFightGrade:StartCountDown()
    self.IsCountDownFinish = false
    self.TxtContinue.gameObject:SetActive(false)
    self.PanelCountDown.gameObject:SetActive(true)
    local startTicks = CS.XTimerManager.Ticks
    local refresh = function(timer)
        if not self.GameObject or not self.GameObject:Exist() then
            self.IsCountDownFinish = true
            CS.XScheduleManager.UnSchedule(timer)
            return
        end
        local t = countDownTime - (CS.XTimerManager.Ticks - startTicks) / CS.System.TimeSpan.TicksPerSecond
        self.ImgCountDownBarRight.fillAmount = t / countDownTime
        self.ImgCountDownBarLeft.fillAmount = t / countDownTime
        if t <= 0 then
            self.IsCountDownFinish = true
            CS.XScheduleManager.UnSchedule(timer)
            self.TxtContinue.gameObject:SetActive(true)
            self.PanelCountDown.gameObject:SetActive(false)
        end
    end
    CS.XScheduleManager.ScheduleForever(refresh, 0)
end

function XUiMultiplayerFightGrade:OnAddLike(playerId)
    XDataCenter.RoomManager.AddLike(playerId)
    for k, v in pairs(self.GridList) do
        if k ~= XPlayer.Id then
            if k == playerId then
                v:SwitchAlreadyLike()
            else
                v:SwitchDisabledLike()
            end
        end
    end
end

function XUiMultiplayerFightGrade:OnApplyFriend(playerId)
    XDataCenter.SocialManager.ApplyFriend(playerId)
end
