XUiPanelMatch = XClass()

function XUiPanelMatch:Ctor(ui, parent)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)

    XUiHelper.RegisterClickEvent(self, self.BtnInfo, self.OnBtnInfoClick)
    XUiHelper.RegisterClickEvent(self, self.BtnCreateRoom, self.OnBtnCreateRoomClick)
    XUiHelper.RegisterClickEvent(self, self.BtnMatch, self.OnBtnMatchClick)
    XUiHelper.RegisterClickEvent(self, self.BtnMatching, self.OnBtnMatchingClick)
    XUiHelper.RegisterClickEvent(self, self.BtnBossInfo, self.OnBtnBossInfoClick)

    self.ArmsTips = {
        self.RImgArms1,
        self.RImgArms2,
        self.RImgArms3,
    }
    self.Parent = parent
    self.GridList = {}
    self.GridCommon.gameObject:SetActive(false)
    self.BtnMatching.interactable = false
    self.StageDescs = {}
    self.TxtDes.text = ""
end

function XUiPanelMatch:OnBtnInfoClick(...)
    local itemId = XDataCenter.FubenManager.GetFlopConsumeItemId(self.SectionCfg.StageId)
    local item = XDataCenter.ItemManager.GetItem(itemId)
    XLuaUiManager.Open("UiTip", item)
end

function XUiPanelMatch:Refresh(sectionCfg)
    self:ResetState()
    sectionCfg = sectionCfg or self.SectionCfg
    local stageCfg = XDataCenter.FubenManager.GetStageCfg(sectionCfg.StageId)
    self.SectionCfg = sectionCfg
    self.CurStageCfg = stageCfg
    self.TxtBossName.text = stageCfg.Name
    self.TxtDesc.text = stageCfg.Description
    local itemId = XDataCenter.FubenManager.GetFlopConsumeItemId(sectionCfg.StageId)
    local item = XDataCenter.ItemManager.GetItem(itemId)
    local count = 0
    if item ~= nil and item:GetCount() >= 0 then
        count = item:GetCount()
    end
    if itemId > 0 then
        self.PanelScavenger.gameObject:SetActive(true)
        local icon = XDataCenter.ItemManager.GetItemIcon(itemId)
        self.RImgIcon:SetRawImage(icon)
        self.TxtCount.text = count
        self.TxtATNums.text = XDataCenter.FubenManager.GetStageActionPointConsume(sectionCfg.StageId)
    else
        self.PanelScavenger.gameObject:SetActive(false)
    end

    local leastPlayer = stageCfg.OnlinePlayerLeast <= 0 and 1 or stageCfg.OnlinePlayerLeast
    self.TxtPeople.text = leastPlayer

    for i, var in ipairs(self.StageDescs) do
        if self.StageDescs[i] then
            self.StageDescs[i].gameObject:SetActive(false)
        end
    end

    for i, v in ipairs(sectionCfg.Description) do
        local textTemp = nil

        if self.StageDescs[i] then
            textTemp = self.StageDescs[i]

        else
            local obj = CS.UnityEngine.Object.Instantiate(self.TxtDes.gameObject)
            obj.transform:SetParent(self.PanelLineupTips, false)
            textTemp = obj:GetComponent("Text")
            self.StageDescs[i] = textTemp
        end
        textTemp.text = v
        textTemp.gameObject:SetActive(true)
    end

    self:UpdateArmsTips()
    self:UpdateRewards()
end

function XUiPanelMatch:UpdateArmsTips()
    local stage = self.CurStageCfg

    for index = 1, 3 do
        local arms = stage.NeedJobType[index]
        if arms then
            self.ArmsTips[index].gameObject:SetActive(true)
            self.ArmsTips[index]:SetRawImage(XCharacterConfigs.GetNpcTypeIconTranspose(arms))
        else
            self.ArmsTips[index].gameObject:SetActive(false)
        end
    end
end

function XUiPanelMatch:UpdateRewards()
    local stage = self.CurStageCfg
    local stageInfo = XDataCenter.FubenManager.GetStageInfo(stage.StageId)

    -- 是否首通奖励显示
    local firstDrop = false
    if not stageInfo.Passed then
        local cfg = XDataCenter.FubenManager.GetStageLevelControl(stage.StageId)
        if cfg and cfg.FirstRewardShow > 0 or stage.FirstRewardShow > 0 then
            firstDrop = true
        end
    end
    self.TxtFirstDrop.gameObject:SetActive(firstDrop)
    self.TxtDrop.gameObject:SetActive(not firstDrop)

    -- 获取显示奖励Id
    local rewardId = 0
    local cfg = XDataCenter.FubenManager.GetStageLevelControl(stage.StageId)
    if not stageInfo.Passed then
        rewardId = cfg and cfg.FirstRewardShow or stage.FirstRewardShow
    end
    if rewardId == 0 then
        rewardId = cfg and cfg.FinishRewardShow or stage.FinishRewardShow
    end
    if rewardId == 0 then
        for j = 1, #self.GridList do
            self.GridList[j].GameObject:SetActive(false)
        end
    end

    local rewards = {}
    if rewardId > 0 then
        rewards = XRewardManager.GetRewardList(rewardId)
    end

    --显示的奖励
    if XDataCenter.FubenManager.CheckCanFlop(stage.StageId) then
        local showRewards = XRewardManager.GetRewardList(XDataCenter.FubenManager.GetFlopShowId(stage.StageId))
        rewards = XTool.MergeArray(showRewards, rewards)
    end

    --关卡掉落
    for i, item in ipairs(rewards) do
        local grid
        if self.GridList[i] then
            grid = self.GridList[i]
        else
            local ui = CS.UnityEngine.Object.Instantiate(self.GridCommon)
            grid = XUiGridCommon.New(self.Parent, ui)
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

function XUiPanelMatch:OnBtnBossInfoClick(...)
    self.Parent:OnShowBossInfo(self.SectionCfg)
    self:Refresh(self.SectionCfg)
end


function XUiPanelMatch:OnBtnMatchingClick(...)

end

function XUiPanelMatch:OnBtnCreateRoomClick(...)
    if XDataCenter.FubenBossOnlineManager.CheckOnlineBossTimeOut() then
        XUiManager.TipMsg(CS.XTextManager.GetText("OnlineBossTimeOut"))
        return
    end

    if XDataCenter.FubenManager.CheckCanFlop(self.CurStageCfg.StageId) then
        XDataCenter.FubenManager.RequestCreateRoom(self.CurStageCfg)
    else
        local _self = self
        XUiManager.DialogTip(CS.XTextManager.GetText("TipTitle"), CS.XTextManager.GetText("BossOnlineConsumeTips"), XUiManager.DialogType.Normal, nil, function()
            XDataCenter.FubenManager.RequestCreateRoom(_self.CurStageCfg)
        end)
    end
end

function XUiPanelMatch:OnBtnMatchClick(...)
    if XDataCenter.FubenBossOnlineManager.CheckOnlineBossTimeOut() then
        XUiManager.TipMsg(CS.XTextManager.GetText("OnlineBossTimeOut"))
        return
    end

    if XDataCenter.RoomManager.Matching then
        return
    end

    if XDataCenter.FubenManager.CheckCanFlop(self.CurStageCfg.StageId) then
        self:Match()
    else
        XUiManager.DialogTip(CS.XTextManager.GetText("TipTitle"), CS.XTextManager.GetText("BossOnlineConsumeTips"), XUiManager.DialogType.Normal, nil, handler(self, self.Match))
    end
end

function XUiPanelMatch:Match()
    XDataCenter.FubenManager.RequestMatchRoom(self.CurStageCfg, function()--匹配房间
        self:RefreshMatching()
        self.BtnCreateRoom.interactable = false
        self.BtnMatch.gameObject:SetActive(false)
        self.BtnMatching.gameObject:SetActive(true)
    end)
end

function XUiPanelMatch:RefreshMatching()
    if XDataCenter.RoomManager.Matching then
        XLuaUiManager.Open("UiOnLineMatching", self.CurStageCfg)
    end
end

function XUiPanelMatch:OnCancelMatch()
    self.BtnCreateRoom.interactable = true
    self.BtnMatch.gameObject:SetActive(true)
    self.BtnMatching.gameObject:SetActive(false)
end


function XUiPanelMatch:ResetState()
    self.BtnMatch.gameObject:SetActive(true)
    self.BtnMatching.gameObject:SetActive(false)
    self.BtnCreateRoom.interactable = true
end

return XUiPanelMatch