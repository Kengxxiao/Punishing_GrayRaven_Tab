-- local XUiOnLineTranscript = XUiManager.Register("UiOnLineTranscript")
local XUiOnLineTranscript = XLuaUiManager.Register(XLuaUi, "UiOnLineTranscript")

function XUiOnLineTranscript:OnAwake()
    self:InitAutoScript()
    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.FreeGem, XDataCenter.ItemManager.ItemId.ActionPoint, XDataCenter.ItemManager.ItemId.Coin)
end

function XUiOnLineTranscript:OnStart(stage)
    self.CreateObjectList = {}
    self.GridList = {}
    self:Refresh(stage)
    XEventManager.AddEventListener(XEventId.EVENT_ROOM_ENTER_ROOM, self.CloseSelf, self)
    XEventManager.AddEventListener(XEventId.EVENT_ROOM_CANCEL_MATCH, self.OnCancelMatch, self)
end

function XUiOnLineTranscript:OnDestroy()
    XEventManager.RemoveEventListener(XEventId.EVENT_ROOM_ENTER_ROOM, self.CloseSelf, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_ROOM_CANCEL_MATCH, self.OnCancelMatch, self)
end

function XUiOnLineTranscript:OnCancelMatch()
    self:SetIsMatchingStatus(false)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiOnLineTranscript:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiOnLineTranscript:AutoInitUi()
    self.BtnClose = self.Transform:Find("SafeAreaContentPane/BtnClose"):GetComponent("Button")
    self.PanelAsset = self.Transform:Find("SafeAreaContentPane/PanelAsset")
    self.PanelDesc = self.Transform:Find("SafeAreaContentPane/PanelDesc")
    self.TxtTitle = self.Transform:Find("SafeAreaContentPane/PanelDesc/TxtTitle"):GetComponent("Text")
    self.TxtChallengesTimes = self.Transform:Find("SafeAreaContentPane/PanelDesc/PanelChallengeTimes/TxtChallengeTimes"):GetComponent("Text")
    self.TxtMaxChallengesTimes = self.Transform:Find("SafeAreaContentPane/PanelDesc/PanelChallengeTimes/TxtMaxChallengeTimes"):GetComponent("Text")
    self.BtnBuyChallengeTimes = self.Transform:Find("SafeAreaContentPane/PanelDesc/PanelChallengeTimes/BtnBuyChallengeTimes"):GetComponent("Button")
    self.PanelChallengeTimes = self.Transform:Find("SafeAreaContentPane/PanelDesc/PanelChallengeTimes")
    self.TxtLevelVal = self.Transform:Find("SafeAreaContentPane/PanelDesc/TxtLevelVal"):GetComponent("Text")
    self.TxtPeople = self.Transform:Find("SafeAreaContentPane/PanelBottom/TxtPeople"):GetComponent("Text")
    self.ImgNandu = self.Transform:Find("SafeAreaContentPane/PanelDesc/ImgNandu"):GetComponent("Image")
    self.TxtDesc = self.Transform:Find("SafeAreaContentPane/PanelDesc/TxtDesc"):GetComponent("Text")
    self.PanelLineupTips = self.Transform:Find("SafeAreaContentPane/PanelLineupTips")
    self.PanelDesItem = self.Transform:Find("SafeAreaContentPane/PanelLineupTips/PanelDesItem")
    self.TxtDes = self.Transform:Find("SafeAreaContentPane/PanelLineupTips/PanelDesItem/TxtDes"):GetComponent("Text")
    self.PanelDropList = self.Transform:Find("SafeAreaContentPane/PanelDropList")
    self.PanelDrop = self.Transform:Find("SafeAreaContentPane/PanelDropList/PanelDrop")
    self.TxtDrop = self.Transform:Find("SafeAreaContentPane/PanelDropList/PanelDrop/TxtDrop"):GetComponent("Text")
    self.TxtDropEn = self.Transform:Find("SafeAreaContentPane/PanelDropList/PanelDrop/TxtDropEn"):GetComponent("Text")
    self.TxtFirstDrop = self.Transform:Find("SafeAreaContentPane/PanelDropList/PanelDrop/TxtFirstDrop"):GetComponent("Text")
    self.PanelDropContent = self.Transform:Find("SafeAreaContentPane/PanelDropList/DropList/Viewport/PanelDropContent")
    self.GridCommon = self.Transform:Find("SafeAreaContentPane/PanelDropList/DropList/Viewport/PanelDropContent/GridCommon")

    self.PanelBottom = self.Transform:Find("SafeAreaContentPane/PanelBottom")
    self.TxtATNums = self.Transform:Find("SafeAreaContentPane/PanelBottom/TxtATNums"):GetComponent("Text")
    self.BtnMatch = self.Transform:Find("SafeAreaContentPane/PanelBottom/BtnMatch"):GetComponent("Button")
    self.BtnMatching = self.Transform:Find("SafeAreaContentPane/PanelBottom/BtnMatching"):GetComponent("Button")
    self.BtnCreateRoom = self.Transform:Find("SafeAreaContentPane/PanelBottom/BtnCreateRoom"):GetComponent("Button")
    self.BtnNotCreateRoom = self.Transform:Find("SafeAreaContentPane/PanelBottom/BtnNotCreateRoom"):GetComponent("Button")
end

function XUiOnLineTranscript:GetAutoKey(uiNode, eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiOnLineTranscript:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiOnLineTranscript:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiOnLineTranscript:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterClickEvent(self.BtnClose, self.OnBtnCloseClick)
    self:RegisterClickEvent(self.BtnMatch, self.OnBtnMatchClick)
    self:RegisterClickEvent(self.BtnCreateRoom, self.OnBtnCreateRoomClick)
    self:RegisterClickEvent(self.BtnBuyChallengeTimes, self.OnBtnBuyChallengeTimesClick)
end
-- auto
function XUiOnLineTranscript:OnBtnCloseClick(...)
    if XDataCenter.RoomManager.Matching then
        local title = CS.XTextManager.GetText("TipTitle")
        local cancelMatchMsg = CS.XTextManager.GetText("OnlineInstanceQuitRoom")
        XUiManager.DialogTip(title, cancelMatchMsg, XUiManager.DialogType.Normal, nil, function()
            self.CloseSelf()
            XDataCenter.RoomManager.CancelMatch()
        end)
    else
        self:CloseSelf()
    end
end

function XUiOnLineTranscript:CloseSelf()
    self:Close()
    CsXGameEventManager.Instance:Notify(XEventId.EVENT_FUBEN_CLOSE_FUBENSTAGEDETAIL)
end

function XUiOnLineTranscript:OnBtnMatchClick(...)
    if XDataCenter.RoomManager.Matching then
        return
    end
    XDataCenter.FubenManager.RequestMatchRoom(self.Stage, function()
        --匹配房间
        if XDataCenter.RoomManager.Matching then
            XLuaUiManager.Open("UiOnLineMatching", self.Stage)
        end
    end)
end

function XUiOnLineTranscript:OnBtnCreateRoomClick(...)
    if XDataCenter.RoomManager.Matching then
        return
    end
    self:CloseSelf()
    XDataCenter.FubenManager.RequestCreateRoom(self.Stage)
end

function XUiOnLineTranscript:OnBtnBuyChallengeTimesClick(...)
    --@TODO buy challenge times
    --XUiManager.OpenBuyAssetPanel(XDataCenter.ItemManager.ItemId.DailyActiveness, function() self:Refresh() end)
end

function XUiOnLineTranscript:ResetOriStatus(...)--重置原始状态
    self:SetIsMatchingStatus(false)
    self.GridCommon.gameObject:SetActive(false)
end

function XUiOnLineTranscript:SetIsMatchingStatus(actived)
    self.BtnMatching.gameObject:SetActive(actived)
    self.BtnNotCreateRoom.gameObject:SetActive(actived)
    self.BtnMatch.gameObject:SetActive(not actived)
    self.BtnCreateRoom.gameObject:SetActive(not actived)
end

function XUiOnLineTranscript:Refresh(stage)
    self:ResetOriStatus()
    self.Stage = stage
    self.TxtTitle.text = stage.Name
    self.TxtDesc.text = stage.Description
    self.TxtLevelVal.text = stage.RequireLevel
    self.TxtATNums.text = stage.RequireActionPoint
    local leastPlayer = stage.OnlinePlayerLeast <= 0 and 1 or stage.OnlinePlayerLeast
    self.TxtPeople.text = leastPlayer

    local stageInfo = XDataCenter.FubenManager.GetStageInfo(stage.StageId)
    local sectionCfg = XDataCenter.FubenDailyManager.GetDailySection(stageInfo.DailySectionId)
    local sectionData = XDataCenter.FubenDailyManager.GetDailySectionData(stageInfo.DailySectionId)
    if sectionCfg then
        local fightNum = sectionData and sectionData.PassTimesToday or 0
        local rewardNeedFinishCount = sectionCfg.RewardNeedFinishCount or 0
        if fightNum > rewardNeedFinishCount then
            fightNum = rewardNeedFinishCount
        end
        self.TxtChallengesTimes.text = rewardNeedFinishCount - fightNum
        self.TxtMaxChallengesTimes.text = '/' .. rewardNeedFinishCount
        self.BtnBuyChallengeTimes.gameObject:SetActive(false)
    else
        self.PanelChallengeTimes.gameObject:SetActive(false)
    end

    self:UpdateRewards()
end

function XUiOnLineTranscript:UpdateRewards()
    local stage = self.Stage
    local stageInfo = XDataCenter.FubenManager.GetStageInfo(stage.StageId)

    -- 是否首通奖励显示
    local firstDrop = false
    if not stageInfo.Passed then
        local cfg = XDataCenter.FubenManager.GetStageLevelControl(self.Stage.StageId)
        if cfg and cfg.FirstRewardShow > 0 or self.Stage.FirstRewardShow > 0 then
            firstDrop = true
        end
    end
    self.TxtFirstDrop.gameObject:SetActive(firstDrop)
    self.TxtDrop.gameObject:SetActive(not firstDrop)

    -- 获取显示奖励Id
    local rewardId = 0
    local IsFirst = false
    local cfg = XDataCenter.FubenManager.GetStageLevelControl(stage.StageId)
    if not stageInfo.Passed then
        rewardId = cfg and cfg.FirstRewardShow or stage.FirstRewardShow
        if cfg and cfg.FirstRewardShow > 0 or stage.FirstRewardShow > 0 then
            IsFirst = true
        end
    end
    if rewardId == 0 then
        rewardId = cfg and cfg.FinishRewardShow or stage.FinishRewardShow
    end
    if rewardId == 0 then
        for j = 1, #self.GridList do
            self.GridList[j].GameObject:SetActive(false)
        end
        return
    end

    local rewards = IsFirst and XRewardManager.GetRewardList(rewardId) or XRewardManager.GetRewardListNotCount(rewardId)
    for i, item in ipairs(rewards) do
        local grid
        if self.GridList[i] then
            grid = self.GridList[i]
        else
            local ui = CS.UnityEngine.Object.Instantiate(self.GridCommon)
            grid = XUiGridCommon.New(self, ui)
            grid.Transform:SetParent(self.PanelDropContent, false)
            self.GridList[i] = grid
        end
        grid:Refresh(item)
        grid.GameObject:SetActive(true)
    end

    for j = 1, #self.GridList do
        if j > #rewards then
            self.GridList[j].GameObject:SetActive(false)
        end
    end
end