local XUiFubenChallengeMap = XLuaUiManager.Register(XLuaUi, "UiFubenChallengeMap")
local XUiPanelJieduan = require("XUi/XUiFubenChallengeMap/XUiPanelJieduan")

local MAX_PLAYER_GRID_COUNT = 4
local MAX_REWARD_COUNT = 4
local LOCAL_CHALLENGE_TIMER_NAME = "XUiFubenChallengeMapTitleTimer"

function XUiFubenChallengeMap:OnAwake()
    self:InitAutoScript()
end

function XUiFubenChallengeMap:OnStart(challenge, timeOutCb)
    self.TimeOutCb = timeOutCb
    self:InitWithCfg(challenge)
    XEventManager.AddEventListener(XEventId.EVENT_FUBEN_DAILY_REFRESH, self.RefreshReward, self)
    XEventManager.AddEventListener(XEventId.EVENT_ROOM_CANCEL_MATCH, self.RefreshMatching, self)
end

function XUiFubenChallengeMap:OnDestroy()
    XCountDown.RemoveTimer(LOCAL_CHALLENGE_TIMER_NAME)
    XEventManager.RemoveEventListener(XEventId.EVENT_FUBEN_DAILY_REFRESH, self.RefreshReward, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_ROOM_CANCEL_MATCH, self.RefreshMatching, self)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiFubenChallengeMap:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiFubenChallengeMap:AutoInitUi()
    self.PanelContent = self.Transform:Find("FullScreenBackground/PanelContent")
    self.PanelBottom = self.Transform:Find("SafeAreaContentPane/LayerWrap/PanelBottom")
    self.BtnReward = self.Transform:Find("SafeAreaContentPane/LayerWrap/PanelBottom/GameObject/BtnReward"):GetComponent("Button")
    self.ImgSlide = self.Transform:Find("SafeAreaContentPane/LayerWrap/PanelBottom/GameObject/ImgSlide"):GetComponent("Image")
    self.TxtProgress = self.Transform:Find("SafeAreaContentPane/LayerWrap/PanelBottom/GameObject/TxtProgress"):GetComponent("Text")
    self.Panelreceived = self.Transform:Find("SafeAreaContentPane/LayerWrap/PanelBottom/GameObject/Panelreceived")
    self.PanelEffect = self.Transform:Find("SafeAreaContentPane/LayerWrap/PanelBottom/GameObject/PanelEffect")
    self.BtnBack = self.Transform:Find("SafeAreaContentPane/LayerWrap/Top/BtnBack"):GetComponent("Button")
    self.PanelAsset = self.Transform:Find("SafeAreaContentPane/LayerWrap/PanelAsset")
    self.PanelTip = self.Transform:Find("SafeAreaContentPane/LayerWrap/PanelTip")
    self.BtnCancelMatch = self.Transform:Find("SafeAreaContentPane/LayerWrap/PanelTip/BtnCancelMatch"):GetComponent("Button")
    self.TxtPipei = self.Transform:Find("SafeAreaContentPane/LayerWrap/PanelTip/TxtPipei"):GetComponent("Text")
    self.PanelEvent = self.Transform:Find("SafeAreaContentPane/LayerWrap/PanelEvent")
    self.TxtEventDesc = self.Transform:Find("SafeAreaContentPane/LayerWrap/PanelEvent/head/TxtEventDesc"):GetComponent("Text")
    self.PanelTitle = self.Transform:Find("SafeAreaContentPane/LayerWrap/PanelTitle")
    self.BtnActDesc = self.Transform:Find("SafeAreaContentPane/LayerWrap/PanelTitle/BtnActDesc"):GetComponent("Button")
    self.TxtShuaxin = self.Transform:Find("SafeAreaContentPane/LayerWrap/PanelTitle/TxtShuaxin"):GetComponent("Text")
    self.TxtCurTime = self.Transform:Find("SafeAreaContentPane/LayerWrap/PanelTitle/TxtCurTime"):GetComponent("Text")
    self.TxtBt = self.Transform:Find("SafeAreaContentPane/LayerWrap/PanelTitle/TxtBt"):GetComponent("Text")
    self.BtnMainUi = self.Transform:Find("SafeAreaContentPane/LayerWrap/Top/BtnMainUi"):GetComponent("Button")
end

function XUiFubenChallengeMap:GetAutoKey(uiNode, eventName)
    if not uiNode then
        return
    end
    return eventName .. uiNode:GetHashCode()
end

function XUiFubenChallengeMap:RegisterListener(uiNode, eventName, func)
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
            XLog.Error("XUiFubenChallengeMap:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiFubenChallengeMap:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterListener(self.BtnReward, "onClick", self.OnBtnRewardClick)
    self:RegisterListener(self.BtnBack, "onClick", self.OnBtnBackClick)
    self:RegisterListener(self.BtnCancelMatch, "onClick", self.OnBtnCancelMatchClick)
    self:RegisterListener(self.BtnActDesc, "onClick", self.OnBtnActDescClick)
    self:RegisterListener(self.BtnMainUi, "onClick", self.OnBtnMainUiClick)
end
-- auto
function XUiFubenChallengeMap:OnBtnRewardClick(...)
    if not self.SectionCfg then
        return
    end

    if self.isGetChallengeReward then
        XUiManager.TipText("ChallengeRewardIsGetted")
    else
        if self.curFightNum >= self.SectionCfg.RewardNeedFinishCount then
            XDataCenter.FubenDailyManager.ReceiveDailyReward(function(reward)
                self.isGetChallengeReward = true
                XUiManager.OpenUiObtain(reward, CS.XTextManager.GetText("Award"))
                self:RefreshReward()
            end, self.SectionCfg.Id)
        else
            local data = XRewardManager.GetRewardList(self.SectionCfg.RewardId)
            XUiManager.OpenUiTipReward(data)
        end
    end
end

function XUiFubenChallengeMap:OnBtnActDescClick(...)
    --详细介绍
    XUiManager.UiFubenDialogTip("", self.ChallengeCfg.DetailDesc or "")
end

function XUiFubenChallengeMap:OnBtnCancelMatchClick(...)
    XDataCenter.RoomManager.CancelMatch()
end

function XUiFubenChallengeMap:RefreshPlayerState()
    if XDataCenter.RoomManager.UiRoom then
        -- self.PanelPlayerState.gameObject:SetActive(true)
        local roomData = XDataCenter.RoomManager.RoomData
        local index = 1
        if roomData.PlayerDataList then
            for i = 0, roomData.PlayerDataList.Count - 1 do
                if roomData.PlayerDataList[i].Id ~= XPlayer.Id then
                    local grid = self.PlayerStateGridList[index]
                    grid:SetActive(true)
                    grid:RefreshUI(roomData.PlayerDataList[i])
                    index = index + 1
                end
            end
        end
        for index = index, MAX_PLAYER_GRID_COUNT do
            local grid = self.PlayerStateGridList[index]
            grid:SetActive(false)
        end
    else
        -- self.PanelPlayerState.gameObject:SetActive(false)
    end
end

function XUiFubenChallengeMap:RefreshUI()
    self:RefreshReward()
    self:RefreshMatching()
    self:RefreshShow()
end

function XUiFubenChallengeMap:RefreshShow()
    self.PanelTitle.gameObject:SetActive(self.ChallengeCfg.Type ~= XDataCenter.FubenManager.ChapterType.Urgent)
    self:RefreshPlayerState()
end

function XUiFubenChallengeMap:OnBtnBackClick(...)
    local title = CS.XTextManager.GetText("TipTitle")
    local cancelMatchMsg = CS.XTextManager.GetText("OnlineInstanceQuitRoom")
    if XDataCenter.RoomManager.UiRoom then
        CS.XUiManager.ViewManager:ShowNext()
    else
        if XDataCenter.RoomManager.Matching then
            XUiManager.DialogTip(title, cancelMatchMsg, XUiManager.DialogType.Normal, nil, function()
                XDataCenter.RoomManager.CancelMatch()
                self:Close()
            end)
        else
            self:Close()
        end
    end
end

function XUiFubenChallengeMap:OnBtnMainUiClick(...)
    local title = CS.XTextManager.GetText("TipTitle")
    local quitRoomMsg = CS.XTextManager.GetText("OnlineInstanceQuitRoom")
    local cancelMatchMsg = CS.XTextManager.GetText("OnlineInstanceCancelMatch")
    if XDataCenter.RoomManager.UiRoom then
        XUiManager.DialogTip(title, quitRoomMsg, XUiManager.DialogType.Normal, nil, function()
            XLuaUiManager.RunMain()
        end)
    else
        if XDataCenter.RoomManager.Matching then
            XUiManager.DialogTip(title, cancelMatchMsg, XUiManager.DialogType.Normal, nil, function()
                XDataCenter.RoomManager.CancelMatch()
                XLuaUiManager.RunMain()
            end)
        else
            XLuaUiManager.RunMain()
        end
    end
end

function XUiFubenChallengeMap:InitTitle()
    if self.ChallengeCfg.Type == XDataCenter.FubenManager.ChapterType.Urgent then
        self.PanelTitle.gameObject:SetActive(false)
        return
    end

    if self.TxtShuaxin then
        self.TxtShuaxin.text = CS.XTextManager.GetText("FubenChallengeResetTime")
    end

    if self.ChallengeCfg.Type == XDataCenter.FubenManager.ChapterType.YSHTX or
    self.ChallengeCfg.Type == XDataCenter.FubenManager.ChapterType.EMEX then
        self.TxtBt.text = self.SectionCfg.Name or ""
    end

    XCountDown.CreateTimer(LOCAL_CHALLENGE_TIMER_NAME, XDataCenter.FubenDailyManager.GetDailyRemainTime(self.ChallengeCfg.Id))
    XCountDown.BindTimer(self, LOCAL_CHALLENGE_TIMER_NAME, function(v)
        if v > 0 then
            self.TxtCurTime.text = XUiHelper.GetTime(v, XUiHelper.TimeFormatType.CHALLENGE)
        else
            if XLuaUiManager.IsUiShow("UiFubenChallengeMap") then
                XUiManager.TipText("FubenDailyIsAlreadyReset")
                self:Close()
                if self.TimeOutCb then
                    self.TimeOutCb()
                end
            else
                self:Remove()
            end
        end
    end)
end

function XUiFubenChallengeMap:InitWithCfg(challenge)
    self.ChallengeCfg = challenge
    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.FreeGem, XDataCenter.ItemManager.ItemId.ActionPoint, XDataCenter.ItemManager.ItemId.Coin)
    if self.ChallengeCfg.Type == XDataCenter.FubenManager.ChapterType.Urgent then
        self.SectionCfg = nil
    else
        self.SectionCfg = XDataCenter.FubenDailyManager.GetDailySectionByChapterId(challenge.Id)
    end

    self:InitTitle()
    self:InitChallengeEventDesc()
    self:LoadContent()
    self:InitRewardItem()
    self:RefreshUI()
end

function XUiFubenChallengeMap:InitRewardItem()
    self.Panelreceived.gameObject:SetActive(false)
    self.PanelEffect.gameObject:SetActive(false)
    self.curFightNum = 0
    self.isGetChallengeReward = false
end

function XUiFubenChallengeMap:RefreshReward()
    --TODO 临时删除奖励
    self.PanelBottom.gameObject:SetActive(false)
    -- local isGetChallengeReward = false
    -- if not self.SectionCfg then
    --     self.PanelBottom.gameObject:SetActive(false)
    --     return
    -- end
    -- local sectionData = XDataCenter.FubenDailyManager.GetDailySectionData(self.SectionCfg.Id)
    -- local curFightNum = 0
    -- if sectionData then
    --     curFightNum = sectionData.PassTimesToday
    --     isGetChallengeReward = sectionData.ReceiveReward
    -- end
    -- local rewardNeedFinishCount = self.SectionCf .RewardNeedFinishCount or 0
    -- if curFightNum > rewardNeedFinishCount then
    --     curFightNum = rewardNeedFinishCount
    -- end
    -- self.ImgSlide.fillAmount = curFightNum / rewardNeedFinishCount
    -- self.TxtProgress.text = (rewardNeedFinishCount - curFightNum) .. "/" .. rewardNeedFinishCount
    -- if curFightNum >= rewardNeedFinishCount then
    --     if isGetChallengeReward then
    --         self.Panelreceived.gameObject:SetActive(true)
    --         self.PanelEffect.gameObject:SetActive(false)
    --     else
    --         self.PanelEffect.gameObject:SetActive(true)
    --         self.Panelreceived.gameObject:SetActive(false)
    --     end
    -- else
    --     self.PanelEffect.gameObject:SetActive(false)
    --     self.Panelreceived.gameObject:SetActive(false)
    -- end
    -- self.isGetChallengeReward = isGetChallengeReward
    -- self.curFightNum = curFightNum
end

function XUiFubenChallengeMap:RefreshMatching()
    self.PanelTip.gameObject:SetActive(XDataCenter.RoomManager.Matching)
end

function XUiFubenChallengeMap:LoadContent()
    if self.ChallengeCfg.Type == XDataCenter.FubenManager.ChapterType.YSHTX then
        self:OpenChildUi("UiFubenChallengeYSHTX", self, self.ChallengeCfg)
        self.ContentViewInst = self:FindChildUiObj("UiFubenChallengeYSHTX")
    elseif self.ChallengeCfg.Type == XDataCenter.FubenManager.ChapterType.EMEX then
        self:OpenChildUi("UiFubenChallengeEMEX", self, self.ChallengeCfg)
        self.ContentViewInst = self:FindChildUiObj("UiFubenChallengeEMEX")
    elseif self.ChallengeCfg.Type == XDataCenter.FubenManager.ChapterType.Urgent then
        self:OpenChildUi("UiFubenChallengeUrgent", self, self.ChallengeCfg)
        self.ContentViewInst = self:FindChildUiObj("UiFubenChallengeUrgent")
    end
end

function XUiFubenChallengeMap:OpenPanelStageDetail(stageCfg, stageInfo)
    self.CurStageCfg = stageCfg
    self.CurStageData = stageInfo
    self.PanelAsset.gameObject:SetActive(false)
    self.Stage = stageCfg
    self.PanelEvent.gameObject:SetActive(false)
    XLuaUiManager.Open("UiFubenStageDetail", stageCfg)
end

function XUiFubenChallengeMap:OnCloseStageDetail()
    self.PanelAsset.gameObject:SetActive(true)
    if self.ContentViewInst and self.ContentViewInst.OnCloseStageDetail then
        self.ContentViewInst:OnCloseStageDetail()
    end

    if self.HasChallengeEvent then
        self.PanelEvent.gameObject:SetActive(true)
    else
        self.PanelEvent.gameObject:SetActive(false)
    end
end

function XUiFubenChallengeMap:InitChallengeEventDesc()
    local envenId = 0
    if self.ChallengeCfg.Type == XDataCenter.FubenManager.ChapterType.Urgent then
        envenId = self.ChallengeCfg.UrgentInfo.EventId
    end

    if envenId > 0 then
        local fightEventCfg = CS.XNpcManager.GetFightEventTemplate(envenId)
        self.TxtEventDesc.text = fightEventCfg.Description
        self.ChallengeEventCfg = fightEventCfg
        self.PanelEvent.gameObject:SetActive(true)
        self.HasChallengeEvent = true
    else
        self.PanelEvent.gameObject:SetActive(false)
    end
end

function XUiFubenChallengeMap:EnterFight(stage)
    local conditions
    if self.ChallengeEventCfg and self.ChallengeEventCfg.ConditionId then
        conditions = XTool.CsList2LuaTable(self.ChallengeEventCfg.ConditionId)
    end
    if XDataCenter.FubenManager.OpenRoomSingle(stage, nil, conditions) then
        if self.ContentViewInst and self.ContentViewInst.OnEnterFight then
            self.ContentViewInst:OnEnterFight()
        end
        XLuaUiManager.Remove("UiFubenStageDetail")
        self:OnCloseStageDetail()
    end
end

function XUiFubenChallengeMap:OnGetEvents()
    return { XEventId.EVENT_FUBEN_CLOSE_FUBENSTAGEDETAIL, XEventId.EVENT_FUBEN_ENTERFIGHT }
end

--事件监听
function XUiFubenChallengeMap:OnNotify(evt, ...)
    local args = { ... }
    if evt == XEventId.EVENT_FUBEN_CLOSE_FUBENSTAGEDETAIL then
        self:OnCloseStageDetail()
    elseif evt == XEventId.EVENT_FUBEN_ENTERFIGHT then
        self:EnterFight(args[1])
    end
end

return XUiFubenChallengeMap