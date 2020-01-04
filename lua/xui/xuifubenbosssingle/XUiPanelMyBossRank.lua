local XUiPanelMyBossRank = XClass()

local MAX_SPECIAL_NUM = 3

function XUiPanelMyBossRank:Ctor(rootUi, ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    XTool.InitUiObject(self)
end

function XUiPanelMyBossRank:Refresh(rankMyData)
    if rankMyData then
        self.RankMyData = rankMyData
    else
        return
    end

    local boosSingleData = XDataCenter.FubenBossSingleManager.GetBoosSingleData()
    local maxCount =  XDataCenter.FubenBossSingleManager.MAX_RANK_COUNT 
    
    if rankMyData.MineRankNum <= maxCount and rankMyData.MineRankNum > 0 then
        self.TxtRankPrecent.gameObject:SetActive(false)
        self.TxtRankNormal.gameObject:SetActive(math.floor(rankMyData.MineRankNum) > MAX_SPECIAL_NUM)
        self.ImgRankSpecial.gameObject:SetActive(rankMyData.MineRankNum <= MAX_SPECIAL_NUM)

        if rankMyData.MineRankNum <= MAX_SPECIAL_NUM then
            local icon = XDataCenter.FubenBossSingleManager.GetRankSpecialIcon(math.floor(rankMyData.MineRankNum))
            self.RootUi:SetUiSprite(self.ImgRankSpecial, icon)
        else
            self.TxtRankNormal.text = math.floor(rankMyData.MineRankNum)
        end
    else
        self.TxtRankPrecent.gameObject:SetActive(true)
        self.TxtRankNormal.gameObject:SetActive(false)
        self.ImgRankSpecial.gameObject:SetActive(false)
        local text = ""
        if rankMyData.MineRankNum > 0 then
            if not rankMyData.TotalCount or rankMyData.TotalCount == 0 then
                text = CS.XTextManager.GetText("None")
            else
                local num = math.floor(rankMyData.MineRankNum / rankMyData.TotalCount * 100)
                if num < 1 then 
                    num = 1
                end

                text = CS.XTextManager.GetText("BossSinglePrecentDesc", num)
            end   
        else
            text = CS.XTextManager.GetText("None")
        end
        self.TxtRankPrecent.text = text
    end

    local text = CS.XTextManager.GetText("BossSingleBossRankSocre", boosSingleData.TotalScore)
    self.TxtRankScore.text = text
    local name = XPlayer.Name
    self.TxtPlayerName.text = name
    local headId = XPlayer.CurrHeadPortraitId
    local headInfo = XPlayerManager.GetHeadPortraitInfoById(headId)
    if headInfo then
        local icon = headInfo.ImgSrc
        self.RImgPlayerHead:SetRawImage(icon)
        if headInfo.Effect then
            self.HeadIconEffect.gameObject:LoadPrefab(headInfo.Effect)
            self.HeadIconEffect.gameObject:SetActiveEx(true)
            self.HeadIconEffect:Init()
        else
            self.HeadIconEffect.gameObject:SetActiveEx(false)
        end
    end
    
    if rankMyData.HistoryMaxRankNum <= maxCount and rankMyData.HistoryMaxRankNum > 0 then
        self.TxtHighistRank.text = math.floor(rankMyData.HistoryMaxRankNum)
    else
        self.TxtHighistRank.text = CS.XTextManager.GetText("None")
    end
end

function XUiPanelMyBossRank:HidePanel()
    self.GameObject:SetActive(false)
end

function XUiPanelMyBossRank:ShowPanel()
    self.GameObject:SetActive(true)
end

return XUiPanelMyBossRank