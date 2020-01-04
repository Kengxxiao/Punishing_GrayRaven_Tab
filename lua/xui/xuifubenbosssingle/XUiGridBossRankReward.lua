local XUiGridBossRankReward = XClass()

function XUiGridBossRankReward:Ctor(rootUi, ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    self.GridRewardList = {}
    XTool.InitUiObject(self)
    self.GridReward.gameObject:SetActive(false)
end

function XUiGridBossRankReward:Refresh(cfg, myRankNum, myLevelType, totalCount)
    local rewardList = XDataCenter.MailManager.GetRewardList(cfg.MailID)

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

    if cfg.MinRank < 1 and cfg.MaxRank < 1 then
        local min
        if cfg.MinRank > 0 then
            min = math.floor(cfg.MinRank * 100) .. "%" .. "-"
        else
            min = ""
        end
        local max = math.floor(cfg.MaxRank * 100) .. "%"
        self.TxtScore.text = min .. max
    else
        if cfg.MinRank == cfg.MaxRank then
            self.TxtScore.text = cfg.MinRank
        else
            self.TxtScore.text = cfg.MinRank .. "-" .. cfg.MaxRank
        end
    end

    if myLevelType ~= cfg.LevelType then
        self.PanelCurRank.gameObject:SetActive(false)
        return
    end

    if myRankNum >= 1 and totalCount > 0 then
        myRankNum = myRankNum / totalCount
    end

    local isCur = myRankNum > cfg.MinRank and myRankNum <= cfg.MaxRank
    self.PanelCurRank.gameObject:SetActive(isCur)
end

return XUiGridBossRankReward

