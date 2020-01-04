local XUiPanelActive = XClass()

function XUiPanelActive:Ctor(ui, rootUi)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    XTool.InitUiObject(self)
    self:AutoAddListener()
    self:RegisterRedPointEvent()

    self.TeamMemberList = {}
    table.insert(self.TeamMemberList, self.GridMember1)
    table.insert(self.TeamMemberList, self.GridMember2)

    self.GridTitleCache = {}
    table.insert(self.GridTitleCache, self.GridTitle)
    self.GridPlayerCache = {}

    self.GridPlayer.gameObject:SetActive(false)
    self.IsShow = false
    self.GameObject:SetActive(false)
end

function XUiPanelActive:CheckRedPoint()
    if self.EventId then
        XRedPointManager.Check(self.EventId)
    end
end

function XUiPanelActive:RegisterRedPointEvent()
   self.EventId = XRedPointManager.AddRedPointEvent(self.ImgRedLegion, self.OnCheckTaskNews, self, { XRedPointConditions.Types.CONDITION_ARENA_MAIN_TASK })
end

function XUiPanelActive:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelActive:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelActive:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelActive:AutoAddListener()
    self:RegisterClickEvent(self.BtnDetail, self.OnBtnDetailClick)
    self:RegisterClickEvent(self.BtnTeamRank, self.OnBtnTeamRankClick)
    self:RegisterClickEvent(self.BtnSelectWarZone, self.OnBtnSelectWarZoneClick)
    self:RegisterClickEvent(self.BtnArenaTask, self.OnBtnArenaTaskClick)
    self:RegisterClickEvent(self.BtnArenaLevelDetail, self.OnBtnArenaLevelDetailClick)
    self:RegisterClickEvent(self.BtnShop, self.OnBtnShopClick)
end

function XUiPanelActive:OnBtnArenaLevelDetailClick(eventData)
    XLuaUiManager.Open("UiArenaLevelDetail")
end

function XUiPanelActive:OnBtnDetailClick(eventData)
    XUiManager.UiFubenDialogTip("", CS.XTextManager.GetText("ArenaActivityStrategyContent") or "")
end

function XUiPanelActive:OnBtnTeamRankClick(eventData)
    XDataCenter.ArenaManager.RequestTeamRankData(function()
        XLuaUiManager.Open("UiArenaTeamRank")
    end)
end

function XUiPanelActive:OnBtnSelectWarZoneClick(eventData)
    XLuaUiManager.Open("UiArenaWarZone")
end

function XUiPanelActive:OnBtnArenaTaskClick(eventData)
    XLuaUiManager.Open("UiArenaTask")
end

function XUiPanelActive:OnBtnShopClick(eventData)
    XLuaUiManager.Open("UiShop", XShopManager.ShopType.Arena)
end

function XUiPanelActive:Show()
    if self.IsShow then
        XDataCenter.ArenaManager.RequestGroupMember()
        return
    end

    self.IsShow = true
    self.GameObject:SetActive(true)

    XEventManager.AddEventListener(XEventId.EVENT_ARENA_MAIN_INFO, self.RefreshMainInfo, self)

    XDataCenter.ArenaManager.RequestGroupMember()
    self:Refresh()
end

function XUiPanelActive:Hide()
    if not self.IsShow then
        return
    end

    self.IsShow = false
    self.GameObject:SetActive(false)

    XEventManager.RemoveEventListener(XEventId.EVENT_ARENA_MAIN_INFO, self.RefreshMainInfo, self)
end

function XUiPanelActive:Refresh()
    local challengeCfg = XDataCenter.ArenaManager.GetCurChallengeCfg()
    if challengeCfg then
        self.TxtLevelRange.text = CS.XTextManager.GetText("ArenaPlayerLevelRange", challengeCfg.MinLv, challengeCfg.MaxLv)
        self.TxtArenaRegion.text = challengeCfg.Name
    end

    local arenaLevel = XDataCenter.ArenaManager.GetCurArenaLevel()
    local arenaLevelCfg = XArenaConfigs.GetArenaLevelCfgByLevel(arenaLevel)
    if arenaLevelCfg then
        self.RImgArenaLevel:SetRawImage(arenaLevelCfg.Icon)
    end

    XCountDown.BindTimer(self.TxtCountDownTime.gameObject, XArenaConfigs.ArenaTimerName, function(v, oldV)
        self.TxtCountDownTime.text = CS.XTextManager.GetText("ArenaActivityEndCountDown", XUiHelper.GetTime(v, XUiHelper.TimeFormatType.CHALLENGE))
    end)
end

function XUiPanelActive:UnBindTimer()
    XCountDown.UnBindTimer(self.TxtCountDownTime.gameObject, XArenaConfigs.ArenaTimerName)
end

function XUiPanelActive:RefreshMainInfo()
    if not self.GameObject:Exist() then
        return
    end

    self:RefreshTeamInfo()
    self:RefreshArenaPlayerRank()
end

function XUiPanelActive:RefreshTeamInfo()
    local wave = XDataCenter.ArenaManager.GetWaveRate()
    self.TxtWave.text = CS.XTextManager.GetText("ArenaWaveRate", wave)

    -- 自身
    local selfInfo = XDataCenter.ArenaManager.GetPlayerArenaInfo()
    self.TxtSelfNickname.text = selfInfo.Name
    local info = XPlayerManager.GetHeadPortraitInfoById(selfInfo.CurrHeadPortraitId)
    if (info ~= nil) then
        self.RImgHeadIcon:SetRawImage(info.ImgSrc)
        
        if info.Effect then
            self.HeadIconEffect.gameObject:LoadPrefab(info.Effect)
            self.HeadIconEffect.gameObject:SetActiveEx(true)
            self.HeadIconEffect:Init()
        else
            self.HeadIconEffect.gameObject:SetActiveEx(false)
        end
    end
    self.TxtPoint.text = selfInfo.Point

    local rank, region = XDataCenter.ArenaManager.GetPlayerArenaRankAndRegion()
    self.TxtRank.text = "No." .. rank
    self.TxtRankRange.text = XArenaConfigs.GetRankRegionText(region)

    -- 队伍
    self.TxtTeamPoint.text = XDataCenter.ArenaManager.GetArenaTeamTotalPoint()
    local teamMemberList = XDataCenter.ArenaManager.GetPlayerArenaTeamMemberInfo()
    for i, grid in ipairs(self.TeamMemberList) do
        local headIcon = XUiHelper.TryGetComponent(grid.transform, "RImgHeadIcon", "RawImage")
        local headIconEffect = XUiHelper.TryGetComponent(grid.transform, "RImgHeadIcon/Effect", "XUiEffectLayer")
        local nickname = XUiHelper.TryGetComponent(grid.transform, "TxtNickname", "Text")
        local btnHead = XUiHelper.TryGetComponent(grid.transform, "BtnHead", "Button")

        CsXUiHelper.RegisterClickEvent(btnHead, function()
            local memberInfo = teamMemberList[i]
            if memberInfo then
                XDataCenter.PersonalInfoManager.ReqShowInfoPanel(memberInfo.Id)
            end
        end , true)

        local member = teamMemberList[i]
        if member then
            nickname.text = member.Name
            headIcon.gameObject:SetActive(true)
            local memberInfo = XPlayerManager.GetHeadPortraitInfoById(member.CurrHeadPortraitId)
            if (memberInfo ~= nil) then
                headIcon:SetRawImage(memberInfo.ImgSrc)
                if memberInfo.Effect then
                    headIconEffect.gameObject:LoadPrefab(memberInfo.Effect)
                    headIconEffect.gameObject:SetActiveEx(true)
                    headIconEffect:Init()
                else
                    headIconEffect.gameObject:SetActiveEx(false)
                end
            end
        else
            nickname.text = ""
            headIcon.gameObject:SetActive(false)
        end
    end
end

function XUiPanelActive:RefreshArenaPlayerRank()
    local challengeCfg = XDataCenter.ArenaManager.GetCurChallengeCfg()
    local rankData = XDataCenter.ArenaManager.GetPlayerArenaRankList()

    for i, v in ipairs(self.GridTitleCache) do
        v.gameObject:SetActive(false)
    end
    for i, v in ipairs(self.GridPlayerCache) do
        v.gameObject:SetActive(false)
    end

    if not challengeCfg then
        return
    end

    self.Index = 1
    local titleIndex = 1
    local playerIndex = 1

    -- 晋级区
    if challengeCfg.DanUpRank > 0 then
        self:AddTitle(titleIndex, challengeCfg.UpRewardId)
        for i, info in ipairs(rankData.UpList) do
            self:AddPlayer(playerIndex, info, i)
            playerIndex = playerIndex + 1
        end
    end

    -- 保级区
    titleIndex = titleIndex + 1
    self:AddTitle(titleIndex, challengeCfg.KeepRewardId)
    for i, info in ipairs(rankData.KeepList) do
        self:AddPlayer(playerIndex, info, i)
        playerIndex = playerIndex + 1
    end

    -- 降级区
    if challengeCfg.DanDownRank > 0 then
        titleIndex = titleIndex + 1
        self:AddTitle(titleIndex, challengeCfg.DownRewardId)
        for i, info in ipairs(rankData.DownList) do
            self:AddPlayer(playerIndex, info, i)
            playerIndex = playerIndex + 1
        end
    end
end

function XUiPanelActive:AddTitle(rankRegion, rewardId)
    local grid = self.GridTitleCache[rankRegion]
    if not grid then
        local go = CS.UnityEngine.GameObject.Instantiate(self.GridTitle.gameObject)
        grid = go.transform
        grid:SetParent(self.PanelContent, false)
        table.insert(self.GridTitleCache, grid)
    end
    grid.gameObject:SetActive(true)

    grid:SetSiblingIndex(self.Index - 1)
    self.Index = self.Index + 1

    -- 界面显示
    local rankRange = XUiHelper.TryGetComponent(grid.transform, "TxtRankRange", "Text")
    local rewardIcon = XUiHelper.TryGetComponent(grid.transform, "ImgReward", "Image")
    local rewardCount = XUiHelper.TryGetComponent(grid.transform, "ImgRewardCount", "Text")
    local btnTitle = XUiHelper.TryGetComponent(grid.transform, "BtnTitle", "Button")
    local btnReward = XUiHelper.TryGetComponent(grid.transform, "ImgReward/BtnReward", "Button")

    CsXUiHelper.RegisterClickEvent(btnTitle, function()
        XLuaUiManager.Open("UiArenaLevelDetail")
    end , true)

    CsXUiHelper.RegisterClickEvent(btnReward, function()
        local list = XRewardManager.GetRewardList(rewardId)
        if not list or #list <= 0 then
            return
        end
        local goodsShowParams = XGoodsCommonManager.GetGoodsShowParamsByTemplateId(list[1].TemplateId)
        if goodsShowParams.RewardType == XRewardManager.XRewardType.Character then
            --从Tips的ui跳转需要关闭Tips的UI
            XLuaUiManager.Open("UiCharacterDetail", list[1].TemplateId)
        elseif goodsShowParams.RewardType == XRewardManager.XRewardType.Equip then
            XLuaUiManager.Open("UiEquipDetail", list[1].TemplateId, true)
            --从Tips的ui跳转需要关闭Tips的UI
        else
            XLuaUiManager.Open("UiTip", list[1] and list[1] or list[1].TemplateId)
        end
    end , true)

    rankRange.text = XArenaConfigs.GetRankRegionText(rankRegion)
    local rewards = XRewardManager.GetRewardList(rewardId)
    if not rewards or #rewards <= 0 then
        return
    end
    local iconPath = XGoodsCommonManager.GetGoodsIcon(rewards[1].TemplateId)
    self.RootUi:SetUiSprite(rewardIcon, iconPath)
    rewardCount.text = rewards[1].Count
end

function XUiPanelActive:AddPlayer(index, playerInfo, regionIndex)
    local grid = self.GridPlayerCache[index]
    if not grid then
        local go = CS.UnityEngine.GameObject.Instantiate(self.GridPlayer.gameObject)
        grid = go.transform
        grid:SetParent(self.PanelContent, false)
        table.insert(self.GridPlayerCache, grid)
    end
    grid.gameObject:SetActive(true)

    -- 排序
    grid:SetSiblingIndex(self.Index - 1)
    self.Index = self.Index + 1

    -- 界面显示
    local panelInfo = XUiHelper.TryGetComponent(grid.transform, "PanelInfo", nil)
    local headIcon = XUiHelper.TryGetComponent(grid.transform, "PanelInfo/Bg/RImgHeadIcon", "RawImage")
    local headIconEffect = XUiHelper.TryGetComponent(grid.transform, "PanelInfo/Bg/RImgHeadIcon/Effect", "XUiEffectLayer")
    local nickname = XUiHelper.TryGetComponent(grid.transform, "PanelInfo/TxtNickname", "Text")
    local rank = XUiHelper.TryGetComponent(grid.transform, "PanelInfo/TxtRank", "Text")
    local point = XUiHelper.TryGetComponent(grid.transform, "PanelInfo/TxtPoint", "Text")
    local pos1 = XUiHelper.TryGetComponent(grid.transform, "PanelPos1", nil)
    local pos2 = XUiHelper.TryGetComponent(grid.transform, "PanelPos2", nil)
    local pos3 = XUiHelper.TryGetComponent(grid.transform, "PanelPos3", nil)
    local btnHead = XUiHelper.TryGetComponent(grid.transform, "PanelInfo/Bg/BtnHead", "Button")

    CsXUiHelper.RegisterClickEvent(btnHead, function()
        if playerInfo.Id == XPlayer.Id then
            return
        end
        XDataCenter.PersonalInfoManager.ReqShowInfoPanel(playerInfo.Id)
    end , true)

    local pos = regionIndex % 3
    if pos == 1 then
        panelInfo.localPosition = pos1.localPosition
    elseif pos == 2 then
        panelInfo.localPosition = pos2.localPosition
    else
        panelInfo.localPosition = pos3.localPosition
    end

    nickname.text = playerInfo.Name
    local memberInfo = XPlayerManager.GetHeadPortraitInfoById(playerInfo.CurrHeadPortraitId)-------要重新改一下
    if (memberInfo ~= nil) then
        headIcon:SetRawImage(memberInfo.ImgSrc)
        if memberInfo.Effect then
            headIconEffect.gameObject:LoadPrefab(memberInfo.Effect)
            headIconEffect.gameObject:SetActiveEx(true)
            headIconEffect:Init()
        else
            headIconEffect.gameObject:SetActiveEx(false)
        end
    end
    rank.text = "No." .. index
    point.text = playerInfo.Point
end

-- 红点
function XUiPanelActive:OnCheckTaskNews(count)
    if self.ImgRedLegion then
        self.ImgRedLegion.gameObject:SetActive(count >= 0)
    end
end

return XUiPanelActive
