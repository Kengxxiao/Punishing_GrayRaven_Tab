local XUiPanelExpBar = require("XUi/XUiSettleWinMainLine/XUiPanelExpBar")

local XUiSettleWin = XLuaUiManager.Register(XLuaUi, "UiSettleWin")

function XUiSettleWin:OnAwake()
    self:InitAutoScript()
    self.GridReward.gameObject:SetActive(false)
end

function XUiSettleWin:OnStart(data, cb)
    self.WinData = data
    self.StageInfos = XDataCenter.FubenManager.GetStageInfo(data.StageId)
    self.StageCfg = XDataCenter.FubenManager.GetStageCfg(data.StageId)
    self.CurrentStageId = data.StageId
    self.CurrAssistInfo = data.ClientAssistInfo
    self.Cb = cb
    self.IsFirst = true;
    self:InitInfo(data)
    XLuaUiManager.SetMask(true)
    self:PlayRewardAnimation()
end

function XUiSettleWin:OnEnable()
    if not self.IsFirst then
        XLuaUiManager.SetMask(true)
        CS.XScheduleManager.Schedule(function()
                self:PlaySecondAnimation()
            end, 0, 1)
    end
end

function XUiSettleWin:OnDestroy()
    XDataCenter.AntiAddictionManager.EndFightAction()
end

-- 奖励动画
function XUiSettleWin:PlayRewardAnimation()
    local delay = XDataCenter.FubenManager.SettleRewardAnimationDelay
    local interval = XDataCenter.FubenManager.SettleRewardAnimationInterval
    local this = self

    -- 没有奖励则直接播放第二个动画
    if not self.GridRewardList or #self.GridRewardList == 0 then
        CS.XScheduleManager.Schedule(function(timer)
            this:PlaySecondAnimation()
        end, 0, 1, delay)
        return
    end

    self.RewardAnimationIndex = 1
    CS.XScheduleManager.Schedule(function(timer)
        if this.RewardAnimationIndex == #self.GridRewardList then
            this:PlayReward(this.RewardAnimationIndex, function()
                this:PlaySecondAnimation()
            end)
        else
            this:PlayReward(this.RewardAnimationIndex)
        end
        this.RewardAnimationIndex = this.RewardAnimationIndex + 1
    end, interval, #self.GridRewardList, delay)
end


function XUiSettleWin:PlaySecondAnimation()
    local this = self
    self:PlayAnimation("AnimEnable2", function()
        XLuaUiManager.SetMask(false)
        -- this:PlayTipMission()
        XDataCenter.FunctionEventManager.UnLockFunctionEvent()
        this:PlayShowFriend()
        self.IsFirst = false;
    end)
end

-- function XUiSettleWin:PlayRewardAnimation()
--     local this = self
--     local cbList = {}
--     for k, v in ipairs(self.GridRewardList) do
--         table.insert(cbList, function(cb)
--             this:PlayReward(k, cb)
--         end)
--     end
--     table.insert(cbList, function(cb)
--         XLuaUiManager.SetMask(false)
--         this:PlayTipMission()
--     end)
--     XTool.Waterfall(cbList)
-- end
-- function XUiSettleWin:PlayTipMission()
--     if XDataCenter.TaskForceManager.ShowMaxTaskForceTeamCountChangeTips then
--         local missionData = XDataCenter.TaskForceManager.GetTaskForeInfo()
--         local taskForeCfg = XDataCenter.TaskForceManager.GetTaskForceConfigById(missionData.ConfigIndex)
--         XUiManager.TipMsg(string.format(CS.XTextManager.GetText("MissionTaskTeamCountContent"), taskForeCfg.MaxTaskForceCount), nil, handler(self, self.PlayShowFriend))
--         XDataCenter.TaskForceManager.ShowMaxTaskForceTeamCountChangeTips = false
--     else
--         self:PlayShowFriend()
--     end
-- end
function XUiSettleWin:PlayShowFriend()
    if not (self.CurrAssistInfo ~= nil and self.CurrAssistInfo.Id ~= 0 and self.CurrAssistInfo.Id ~= XPlayer.Id) then
        if self.Cb then
            self.Cb()
        end
        return
    end

    if XDataCenter.SocialManager.CheckIsApplyed(self.CurrAssistInfo.Id) or XDataCenter.SocialManager.CheckIsFriend(self.CurrAssistInfo.Id) then
        if self.Cb then
            self.Cb()
        end
        return
    end

    self.TxtName.text = self.CurrAssistInfo.Name
    self.TxtLv.text = self.CurrAssistInfo.Level
    local info = XPlayerManager.GetHeadPortraitInfoById(self.CurrAssistInfo.HeadPortraitId)
    if (info ~= nil) then
        self:SetUiSprite(self.ImgHead, info.ImgSrc)
    end

    self.PanelFriend.gameObject:SetActive(true)
    self:PlayAnimation("PanelFriendEnable", self.Cb)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiSettleWin:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiSettleWin:AutoInitUi()
    self.PanelNorWinInfo = self.Transform:Find("SafeAreaContentPane/PanelNorWinInfo")
    self.PanelNor = self.Transform:Find("SafeAreaContentPane/PanelNorWinInfo/PanelNor")
    self.PanelBtn = self.Transform:Find("SafeAreaContentPane/PanelNorWinInfo/PanelNor/PanelBtn")
    self.PanelBtns = self.Transform:Find("SafeAreaContentPane/PanelNorWinInfo/PanelNor/PanelBtn/PanelBtns")
    self.BtnLeft = self.Transform:Find("SafeAreaContentPane/PanelNorWinInfo/PanelNor/PanelBtn/PanelBtns/BtnLeft"):GetComponent("Button")
    self.TxtLeft = self.Transform:Find("SafeAreaContentPane/PanelNorWinInfo/PanelNor/PanelBtn/PanelBtns/BtnLeft/TxtLeft"):GetComponent("Text")
    self.BtnRight = self.Transform:Find("SafeAreaContentPane/PanelNorWinInfo/PanelNor/PanelBtn/PanelBtns/BtnRight"):GetComponent("Button")
    self.TxtRight = self.Transform:Find("SafeAreaContentPane/PanelNorWinInfo/PanelNor/PanelBtn/PanelBtns/BtnRight/TxtRight"):GetComponent("Text")
    self.PanelTouch = self.Transform:Find("SafeAreaContentPane/PanelNorWinInfo/PanelNor/PanelBtn/PanelTouch")
    self.BtnBlock = self.Transform:Find("SafeAreaContentPane/PanelNorWinInfo/PanelNor/PanelBtn/PanelTouch/BtnBlock"):GetComponent("Button")
    self.TxtLeftA = self.Transform:Find("SafeAreaContentPane/PanelNorWinInfo/PanelNor/PanelBtn/PanelTouch/BtnBlock/TxtLeft"):GetComponent("Text")
    self.PanelLeft = self.Transform:Find("SafeAreaContentPane/PanelNorWinInfo/PanelNor/PanelLeft")
    self.PanelRoleContent = self.Transform:Find("SafeAreaContentPane/PanelNorWinInfo/PanelNor/PanelLeft/Team/PanelRoleContent")
    self.GridWinRole = self.Transform:Find("SafeAreaContentPane/PanelNorWinInfo/PanelNor/PanelLeft/Team/PanelRoleContent/GridWinRole")
    self.PanelRight = self.Transform:Find("SafeAreaContentPane/PanelNorWinInfo/PanelNor/PanelRight")
    self.TxtChapterName = self.Transform:Find("SafeAreaContentPane/PanelNorWinInfo/PanelNor/PanelRight/StageInfo/TxtChapterName"):GetComponent("Text")
    self.TxtStageName = self.Transform:Find("SafeAreaContentPane/PanelNorWinInfo/PanelNor/PanelRight/StageInfo/TxtStageName"):GetComponent("Text")
    self.PanelRewardContent = self.Transform:Find("SafeAreaContentPane/PanelNorWinInfo/PanelNor/PanelRight/RewardList/Viewport/PanelRewardContent")
    self.GridReward = self.Transform:Find("SafeAreaContentPane/PanelNorWinInfo/PanelNor/PanelRight/RewardList/Viewport/PanelRewardContent/GridReward")
    self.PanelFriend = self.Transform:Find("SafeAreaContentPane/PanelFriend")
    self.PanelInf = self.Transform:Find("SafeAreaContentPane/PanelFriend/PanelInf")
    self.PanelHead = self.Transform:Find("SafeAreaContentPane/PanelFriend/PanelInf/PanelHead")
    self.ImgHead = self.Transform:Find("SafeAreaContentPane/PanelFriend/PanelInf/PanelHead/ImgHead"):GetComponent("Image")
    self.TxtName = self.Transform:Find("SafeAreaContentPane/PanelFriend/PanelInf/TxtName"):GetComponent("Text")
    self.TxtLv = self.Transform:Find("SafeAreaContentPane/PanelFriend/PanelInf/TxtLv"):GetComponent("Text")
    self.BtnFriClose = self.Transform:Find("SafeAreaContentPane/PanelFriend/BtnFriClose"):GetComponent("Button")
    self.BtnFriAdd = self.Transform:Find("SafeAreaContentPane/PanelFriend/BtnFriAdd"):GetComponent("Button")
    self.PanelPlayerExpBar = self.Transform:Find("SafeAreaContentPane/PanelNorWinInfo/PanelNor/PanelLeft/PlayerExp/PanelPlayerExpBar")
end

function XUiSettleWin:AutoAddListener()
    self:RegisterClickEvent(self.BtnLeft, self.OnBtnLeftClick)
    self:RegisterClickEvent(self.BtnRight, self.OnBtnRightClick)
    self:RegisterClickEvent(self.BtnBlock, self.OnBtnBlockClick)
    self:RegisterClickEvent(self.BtnFriClose, self.OnBtnFriCloseClick)
    self:RegisterClickEvent(self.BtnFriAdd, self.OnBtnFriAddClick)
end
-- auto
function XUiSettleWin:OnBtnLeftClick(eventData)
    self:SetBtnByType(self.StageCfg.FunctionLeftBtn)
end

function XUiSettleWin:OnBtnFriCloseClick(...)
    self:PlayAnimation("PanelFriendDisable")
    self.PanelFriend.gameObject:SetActive(false)
end

function XUiSettleWin:OnBtnFriAddClick(...)
    if not self.CurrAssistInfo then
        return
    end

    XDataCenter.SocialManager.ApplyFriend(self.CurrAssistInfo.Id)

    self.CurrAssistInfo = nil
    self:PlayAnimation("PanelFriendDisable")
    self.PanelFriend.gameObject:SetActive(false)
end

function XUiSettleWin:InitInfo(data)
    self.PanelFriend.gameObject:SetActive(false)
    XTipManager.Execute()

    self:SetBtnsInfo(data)
    self:SetStageInfo(data)
    self:UpdatePlayerInfo(data)
    self:InitRewardCharacterList(data)
    self:InitRewardList(data.RewardGoodsList)
    local this = self
    XTipManager.Add(function()
        if data.UrgentId > 0 then
            XLuaUiManager.Open("UiSettleUrgentEvent", data.UrgentId)
        end
    end)
end

function XUiSettleWin:SetBtnsInfo(data)
    local stageData = XDataCenter.FubenManager.GetStageData(data.StageId)

    if self.StageCfg.HaveFirstPass and stageData and stageData.PassTimesToday < 2 then
        self.PanelTouch.gameObject:SetActive(true)
        self.PanelBtns.gameObject:SetActive(false)
    else
        local leftType = self.StageCfg.FunctionLeftBtn
        local rightType = self.StageCfg.FunctionRightBtn

        self.BtnLeft.gameObject:SetActive(leftType > 0)
        self.BtnRight.gameObject:SetActive(rightType > 0)
        self.TxtLeft.text = XRoomSingleManager.GetBtnText(leftType)
        self.TxtRight.text = XRoomSingleManager.GetBtnText(rightType)

        self.PanelTouch.gameObject:SetActive(false)
        self.PanelBtns.gameObject:SetActive(true)
    end
end

function XUiSettleWin:SetStageInfo(data)
    local chapterName, stageName = XDataCenter.FubenManager.GetFubenNames(data.StageId)
    self.TxtChapterName.text = chapterName
    self.TxtStageName.text = stageName
end

-- 角色奖励列表
function XUiSettleWin:InitRewardCharacterList(data)
    self.GridWinRole.gameObject:SetActive(false)
    if self.StageCfg.RobotId and #self.StageCfg.RobotId > 0 then
        for i = 1, #self.StageCfg.RobotId do
            if self.StageCfg.RobotId[i] > 0 then
                local ui = CS.UnityEngine.Object.Instantiate(self.GridWinRole)
                local grid = XUiGridWinRole.New(self, ui)
                grid.Transform:SetParent(self.PanelRoleContent, false)
                grid:UpdateRobotInfo(self.StageCfg.RobotId[i])
                grid.GameObject:SetActive(true)
            end
        end
    else
        local charExp = data.CharExp
        local count = #charExp
        if count <= 0 then
            return
        end

        for i = 1, count do
            local ui = CS.UnityEngine.Object.Instantiate(self.GridWinRole)
            local grid = XUiGridWinRole.New(self, ui)
            grid.Transform:SetParent(self.PanelRoleContent, false)
            grid:UpdateRoleInfo(charExp[i], self.StageCfg.CardExp)
            grid.GameObject:SetActive(true)
        end
    end
end

-- 玩家经验
function XUiSettleWin:UpdatePlayerInfo(data)
    if not data or not next(data) then return end

    local lastLevel = data.RoleLevel
    local lastExp = data.RoleExp
    local lastMaxExp = XPlayerManager.GetMaxExp(lastLevel)
    local curLevel = XPlayer.Level
    local curExp = XPlayer.Exp
    local curMaxExp = XPlayerManager.GetMaxExp(curLevel)
    local addExp = self.StageCfg.TeamExp
    self.PlayerExpBar = self.PlayerExpBar or XUiPanelExpBar.New(self.PanelPlayerExpBar)
    self.PlayerExpBar:LetsRoll(lastLevel, lastExp, lastMaxExp, curLevel, curExp, curMaxExp, addExp)
end

-- 物品奖励列表
function XUiSettleWin:InitRewardList(rewardGoodsList)
    rewardGoodsList = rewardGoodsList or {}
    self.GridRewardList = {}
    local rewards = XRewardManager.MergeAndSortRewardGoodsList(rewardGoodsList)
    for i, item in ipairs(rewards) do
        local ui = CS.UnityEngine.Object.Instantiate(self.GridReward)
        local grid = XUiGridCommon.New(self, ui)
        grid.Transform:SetParent(self.PanelRewardContent, false)
        grid:Refresh(item, nil, nil, true)
        grid.GameObject:SetActive(false)
        table.insert(self.GridRewardList, grid)
    end
end

function XUiSettleWin:OnBtnRightClick(...)
    self:SetBtnByType(self.StageCfg.FunctionRightBtn)
end

function XUiSettleWin:SetBtnByType(btnType)
    --CS.XAudioManager.RemoveCueSheet(CS.XAudioManager.BATTLE_MUSIC_CUE_SHEET_ID)
    --CS.XAudioManager.PlayMusic(CS.XAudioManager.MAIN_BGM)
    if btnType == XRoomSingleManager.BtnType.SelectStage then
        self:OnBtnBackClick(false)
    elseif btnType == XRoomSingleManager.BtnType.Again then
        XLuaUiManager.PopThenOpen("UiNewRoomSingle", self.StageCfg.StageId)
    elseif btnType == XRoomSingleManager.BtnType.Next then
        self:OnBtnEnterNextClick()
    elseif btnType == XRoomSingleManager.BtnType.Main then
        self:OnBtnBackClick(true)
    end
end

function XUiSettleWin:OnBtnEnterNextClick()
    if self.StageInfos.Type == XDataCenter.FubenManager.StageType.Tower then
        local stageId = XDataCenter.TowerManager.GetTowerData().CurrentStageId
        if XDataCenter.TowerManager.CheckStageCanEnter(stageId) then
            XLuaUiManager.PopThenOpen("UiNewRoomSingle", stageId)
        else
            local text = CS.XTextManager.GetText("TowerCannotEnter")
            XUiManager.TipMsg(text, XUiManager.UiTipType.Tip)
        end
    else
        if self.StageInfos.NextStageId then
            local nextStageCfg = XDataCenter.FubenManager.GetStageCfg(self.StageInfos.NextStageId)
            self:HidePanel()
            XDataCenter.FubenManager.OpenRoomSingle(nextStageCfg)
        else
            local text = CS.XTextManager.GetText("BattleWinMainCannotEnter")
            XUiManager.TipMsg(text, XUiManager.UiTipType.Tip)
        end
    end
end

function XUiSettleWin:OnBtnBackClick(isRunMain)
    if self.StageInfos.Type == XDataCenter.FubenManager.StageType.Tower then
        if XDataCenter.TowerManager.GetChapterLastMapId(self.CurrentStageId) == self.CurrentStageId then
            XDataCenter.TowerManager.GetTowerChapterReward(function()
                if isRunMain then
                    XLuaUiManager.RunMain()
                else
                    self:HidePanel()
                end
            end, self.CurrentStageId)
        else
            if isRunMain then
                XLuaUiManager.RunMain()
            else
                self:HidePanel()
            end
        end
    elseif self.StageInfos.Type == XDataCenter.FubenManager.StageType.BossSingle then
        if isRunMain then
            XLuaUiManager.RunMain()
        else
            self:HidePanel()
        end
    elseif self.StageInfos.Type == XDataCenter.FubenManager.StageType.Urgent then
        if isRunMain then
            XLuaUiManager.RunMain()
        else
            -- 跳转到挑战界面
            XLuaUiManager.RunMain()
            XFunctionManager.SkipInterface(600)
        end
    else
        if isRunMain then
            XLuaUiManager.RunMain()
        else
            self:HidePanel()
        end
    end
end

function XUiSettleWin:OnBtnBlockClick(...)
    --CS.XAudioManager.RemoveCueSheet(CS.XAudioManager.BATTLE_MUSIC_CUE_SHEET_ID)
    --CS.XAudioManager.PlayMusic(CS.XAudioManager.MAIN_BGM)
    self:HidePanel()
    if self.StageCfg.FirstGotoSkipId > 0 then
        XFunctionManager.SkipInterface(self.StageCfg.FirstGotoSkipId)
    end
end

function XUiSettleWin:HidePanel()
    self:Close()
end

function XUiSettleWin:PlayReward(index, cb)
    self.GridRewardList[index].GameObject:SetActive(true)
    self:PlayAnimation("GridReward", cb)
end