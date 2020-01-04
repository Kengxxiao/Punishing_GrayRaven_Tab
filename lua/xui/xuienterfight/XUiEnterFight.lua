local XUiEnterFight = XLuaUiManager.Register(XLuaUi, "UiEnterFight")

function XUiEnterFight:OnStart(type, name, dis, icon, rewardId, cb, stageId, areaId)
    self.Callback = cb
    self.RewardId = rewardId
    self.Items = {}
    self:InitAutoScript()
    if type == XFubenExploreConfigs.NodeTypeEnum.Story then
        self:OnShowStoryDialog(name, dis, icon)
    elseif type == XFubenExploreConfigs.NodeTypeEnum.Stage then
        self:OnShowFightDialog(name, dis, icon)
    elseif type == XFubenExploreConfigs.NodeTypeEnum.Arena then
        self:OnShowArenaDialog(stageId, areaId)
    end
    self:UpdateReward()
end

function XUiEnterFight:InitAutoScript()
    self:AutoAddListener()
end

function XUiEnterFight:AutoAddListener()
    self:RegisterClickEvent(self.BtnMaskB, self.OnBtnMaskBClick)
    self:RegisterClickEvent(self.BtnEnterStory, self.OnBtnEnterStoryClick)
    self:RegisterClickEvent(self.BtnEnterFight, self.OnBtnEnterFightClick)
    self:RegisterClickEvent(self.BtnEnterArena, self.OnBtnEnterArenaClick)
end

function XUiEnterFight:OnBtnMaskBClick(eventData)
    self:Close()
end

function XUiEnterFight:OnBtnEnterStoryClick(eventData)
    self:Close()
    self:OnCallback()
end

function XUiEnterFight:OnBtnEnterFightClick(eventData)
    self:Close()
    self:OnCallback()
end

function XUiEnterFight:OnBtnEnterArenaClick(eventData)
    self:Close()
    self:OnCallback()
end

function XUiEnterFight:OnShowStoryDialog(name, dis, icon)
    self.PanelStory.gameObject:SetActive(true)
    self.PanelFight.gameObject:SetActive(false)
    self.PanelArena.gameObject:SetActive(false)

    self.TxtStoryName.text = name
    self.TxtStoryDec.text = dis
    self.RImgStory:SetRawImage(icon)
end

function XUiEnterFight:OnShowFightDialog(name, dis, icon)
    self.PanelFight.gameObject:SetActive(true)
    self.PanelStory.gameObject:SetActive(false)
    self.PanelArena.gameObject:SetActive(false)

    self.TxtFightName.text = name
    self.TxtFightDec.text = string.gsub(dis, "\\n", "\n")
    self.RImgFight:SetRawImage(icon)
end

function XUiEnterFight:OnShowArenaDialog(stageId, areaId)
    self.PanelFight.gameObject:SetActive(false)
    self.PanelStory.gameObject:SetActive(false)
    self.PanelReward.gameObject:SetActive(false)
    self.ImgGqdl.gameObject:SetActive(false)
    self.PanelArena.gameObject:SetActive(true)

    local score = XDataCenter.ArenaManager.GetArenaStageScore(areaId, stageId)
    local config = XArenaConfigs.GetArenaStageConfig(stageId)
    if score > 0 then
        self.TxtArenaScore.text = CS.XTextManager.GetText("ArenaHighDesc", score)
    else
        self.TxtArenaScore.text = score
    end
  
    self.RImgArena:SetRawImage(config.BgIconBig)
    self.ImgArenaDifficulty:SetRawImage(config.DifficuIocn)
    self.TxtArenatName.text = config.Name
end

function XUiEnterFight:UpdateReward()
    self.Grid128.gameObject:SetActive(false)
    if self.RewardId and self.RewardId > 0 then
        self.ImgGqdl.gameObject:SetActive(true)
        self.PanelReward.gameObject:SetActive(true)
        local data = XRewardManager.GetRewardList(self.RewardId)
        data = XRewardManager.MergeAndSortRewardGoodsList(data)
        XUiHelper.CreateTemplates(self, self.Items, data, XUiGridCommon.New, self.Grid128, self.PanelReward, function(grid, data)
            grid:Refresh(data)
        end) 
    else
        self.PanelReward.gameObject:SetActive(false)
        self.ImgGqdl.gameObject:SetActive(false)
    end
end

function XUiEnterFight:OnCallback()
    if self.Callback then
        self.Callback()
    end
end