local XUiGridBossRank = XClass()

local MAX_SPECIAL_NUM = 3

function XUiGridBossRank:Ctor(rootUi, ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    XTool.InitUiObject(self)
    self:AutoAddListener()
end

function XUiGridBossRank:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiGridBossRank:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiGridBossRank:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiGridBossRank:AutoAddListener()
    self:RegisterClickEvent(self.BtnDetail, self.OnBtnDetailClick)
end

function XUiGridBossRank:Refresh(rankMetaData, curLevelType)
    if rankMetaData then
        self.RankMetaData = rankMetaData
    else
        return
    end

    if curLevelType then
        self.CurLevelType = curLevelType
    end

    self.TxtRankNormal.gameObject:SetActive(self.RankMetaData.RankNum > MAX_SPECIAL_NUM)
    self.ImgRankSpecial.gameObject:SetActive(self.RankMetaData.RankNum <= MAX_SPECIAL_NUM)
    if self.RankMetaData.RankNum <= MAX_SPECIAL_NUM then
        local icon = XDataCenter.FubenBossSingleManager.GetRankSpecialIcon(math.floor(self.RankMetaData.RankNum), self.CurLevelType)
        self.RootUi:SetUiSprite(self.ImgRankSpecial, icon)
    else
        self.TxtRankNormal.text = math.floor(self.RankMetaData.RankNum)
    end
    local text = CS.XTextManager.GetText("BossSingleBossRankSocre", self.RankMetaData.Score)
    self.TxtRankScore.text = text
    self.TxtPlayerName.text = self.RankMetaData.Name

    if self.RankMetaData.HeadPortraitId and self.RankMetaData.HeadPortraitId > 0 then
        local headInfo = XPlayerManager.GetHeadPortraitInfoById(self.RankMetaData.HeadPortraitId)
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
    end

    for i = 1, #self.RankMetaData.CharacterHeadData do
        self["RImgTeam" .. i].gameObject:SetActive(true)
        local charId = self.RankMetaData.CharacterHeadData[i]
        local charIcon = XDataCenter.CharacterManager.GetCharSmallHeadIcon(charId)
        self["RImgTeam" .. i]:SetRawImage(charIcon)
    end

    for i = #self.RankMetaData.CharacterHeadData + 1, 3 do
        self["RImgTeam" .. i].gameObject:SetActive(false)
    end

end

function XUiGridBossRank:OnBtnDetailClick(...)
    XDataCenter.PersonalInfoManager.ReqShowInfoPanel(self.RankMetaData.PlayerId)
end

return XUiGridBossRank