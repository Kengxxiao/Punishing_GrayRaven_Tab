local XUiPanelBossEnter = XClass()
local XUiPanelScoreInfo = require("XUi/XUiFubenBossSingle/XUiPanelScoreInfo")
local XUiPanelGroupInfo = require("XUi/XUiFubenBossSingle/XUiPanelGroupInfo")

function XUiPanelBossEnter:Ctor(rootUi, ui, bossSingleData, challCfg)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.ChallCfg = challCfg
    self.BossSingleData = bossSingleData
    self.CurScoreRewardId = -1
    self.RootUi = rootUi
    self.GridRewardList = {}
    XTool.InitUiObject(self)
    self:AutoAddListener()
    self:RegisterRedPointEvent()
    self:Init()
end

function XUiPanelBossEnter:CheckRedPoint()
    if self.EventId then
        XRedPointManager.Check(self.EventId)
    end
end

function XUiPanelBossEnter:RegisterRedPointEvent()
   self.EventId = XRedPointManager.AddRedPointEvent(self.ImgRedHint, self.OnCheckRewardNews, self, { XRedPointConditions.Types.CONDITION_BOSS_SINGLE_REWARD })
end

function XUiPanelBossEnter:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelBossEnter:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelBossEnter:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelBossEnter:AutoAddListener()
    self:RegisterClickEvent(self.BtnActDesc, self.OnBtnActDescClick)
    self:RegisterClickEvent(self.BtnRank, self.OnBtnRankClick)
    self:RegisterClickEvent(self.BtnReward, self.OnBtnRewardClick)
    self:RegisterClickEvent(self.BtnShop, self.OnBtnShopClick)
end

function XUiPanelBossEnter:Init()
    local rankLevelCfg = XDataCenter.FubenBossSingleManager.GetRankLevelCfgByType(self.BossSingleData.LevelType)

    self.RootUi:SetUiSprite(self.ImgLevelIcon, rankLevelCfg.Icon)
    self.TxtLevelName.text = rankLevelCfg.LevelName
    local text = CS.XTextManager.GetText("BossSingleRankDesc", rankLevelCfg.MinPlayerLevel, rankLevelCfg.MaxPlayerLevel)
    self.TxtLevel.text = "（" .. text .. "）"
    self.GridReward.gameObject:SetActive(false)
    self.ScoreInfo = XUiPanelScoreInfo.New(self.RootUi, self.PanelScoreInfo, self.BossSingleData)
    self.GroupInfo = XUiPanelGroupInfo.New(self.RootUi, self.PanelGroupInfo)
    self.RootUi:PlayAnimation("AnimScoreInfoDisable")
    self.ScoreInfo:HidePanel()
    self.GroupInfo:HidePanel()
    self:ShowPanel(true, self.BossSingleData)
end

function XUiPanelBossEnter:ShowPanel(refresh, bossSingleData, isAutoFight, isSync)
    if bossSingleData then
        self.BossSingleData = bossSingleData
    end

    self:CheckRedPoint()
    if refresh then
        local allCount = XDataCenter.FubenBossSingleManager.BOSS_SINGLE_CHALLENGE_COUNT
        local numText = CS.XTextManager.GetText("BossSingleChallengeCount", allCount - self.BossSingleData.ChallengeCount, allCount)

        self.TxtLeftCount.text = numText
        self.TxtScore.text = self.BossSingleData.TotalScore
        local maxCount =  XDataCenter.FubenBossSingleManager.MAX_RANK_COUNT

        if self.BossSingleData.Rank <= maxCount and self.BossSingleData.Rank > 0 then
            self.TxtRank.text = math.floor(self.BossSingleData.Rank)
        else
            if not self.BossSingleData.TotalRank or self.BossSingleData.TotalRank <= 0 or self.BossSingleData.Rank <= 0 then
                self.TxtRank.text = CS.XTextManager.GetText("None")
            else
                local num = math.floor(self.BossSingleData.Rank / self.BossSingleData.TotalRank * 100)
                if num < 1 then 
                    num = 1
                end

                self.TxtRank.text = CS.XTextManager.GetText("BossSinglePrecentDesc", num)
            end
        end
        self:SetRewardInfo()
    end

    if not isAutoFight then
        if not isSync then
            self.RootUi:PlayAnimation("AnimEnable")
        end
        self.GameObject:SetActive(true)
    end
end

function XUiPanelBossEnter:SetRewardInfo()
    local scoreReardCfg = XDataCenter.FubenBossSingleManager.GetCurScoreRewardCfg()
    local rewardList = {}

    if scoreReardCfg then
        local needScore = CS.XTextManager.GetText("BossSingleScore", scoreReardCfg.Score)
        self.TxtReward.text = needScore
        rewardList = XRewardManager.GetRewardList(scoreReardCfg.RewardId)
    else
        local needScore = CS.XTextManager.GetText("BossSingleNoNeedScore")
        self.TxtReward.text = needScore
    end

    if scoreReardCfg and self.CurScoreRewardId == scoreReardCfg.Id then
        return
    end

    self.CurScoreRewardId = scoreReardCfg and scoreReardCfg.Id or -1

    for i = 1, #rewardList do
        local grid = self.GridRewardList[i]
        if not grid then
            local ui = CS.UnityEngine.Object.Instantiate(self.GridReward)
            grid = XUiGridCommon.New(self.RootUi, ui)
            grid.Transform:SetParent(self.PanelRewardContent, false)
            self.GridRewardList[i] = grid
        end

        grid:Refresh(rewardList[i])
        grid.GameObject:SetActive(true)
    end

    for i = #rewardList + 1, #self.GridRewardList do
        self.GridRewardList[i].GameObject:SetActive(false)
    end
end

function XUiPanelBossEnter:HidePanel()
    self.GameObject:SetActive(false)
end

function XUiPanelBossEnter:OnBtnActDescClick(...)
    local text = CS.XTextManager.GetText("BossSingleDesc")
    XUiManager.UiFubenDialogTip("", text or "")
end

function XUiPanelBossEnter:OnBtnRankClick(...)
    local func = function(rankData)
        self.RootUi:ShowBossRank(self.BossSingleData.LevelType, self.BossSingleData.RankPlatform)
    end
    XDataCenter.FubenBossSingleManager.GetRankData(func, self.BossSingleData.LevelType)
end

function XUiPanelBossEnter:OnBtnRewardClick(...)
    self.ScoreInfo:ShowPanel(self.BossSingleData)
    self.RootUi:PlayAnimation("AnimScoreInfoEnable")
end

function XUiPanelBossEnter:OnBtnShopClick(...)
    XLuaUiManager.Open("UiShop", XShopManager.ShopType.Boss)
end

function XUiPanelBossEnter:ShowBossGroupInfo(groupId)
    self.GroupInfo:ShowBossGroupInfo(groupId)
end

-- 红点
function XUiPanelBossEnter:OnCheckRewardNews(count)
    if self.ImgRedHint then
        self.ImgRedHint.gameObject:SetActive(count > 0)
    end
end

return XUiPanelBossEnter