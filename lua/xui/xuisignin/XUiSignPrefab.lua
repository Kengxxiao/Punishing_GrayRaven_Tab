local XUiSignGridDay = require("XUi/XUiSignIn/XUiSignGridDay")
local XUiSignPrefab = XClass()


function XUiSignPrefab:Ctor(ui, rootUi, parent, setTomorrow)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    self.Parent = parent
    self.SetTomorrow = setTomorrow

    self.OnBtnHelpClickCb = function() self:OnBtnHelpClick() end
    XTool.InitUiObject(self)
    self:InitAddListen()

    self.DaySamllGrids = {}
    table.insert(self.DaySamllGrids, XUiSignGridDay.New(self.GridDaySmall, self.RootUi))
    self.DayBigGrids = {}
    table.insert(self.DayBigGrids, XUiSignGridDay.New(self.GridDayBig, self.RootUi))
    self.BtnList = {}
    table.insert(self.BtnList, self.BtnTab)
end

function XUiSignPrefab:InitAddListen()
    self.RootUi:RegisterClickEvent(self.BtnHelp, self.OnBtnHelpClickCb)
end

function XUiSignPrefab:OnBtnHelpClick()
    XUiManager.UiFubenDialogTip("", self.SignInInfos[1].Description or "")
end

function XUiSignPrefab:Refresh(signId, round, isShow)
    self.IsShow = isShow
    self.SignId = signId
    self.Round = round

    self:InitTabGroup()
end

function XUiSignPrefab:InitTabGroup()
    for i, v in ipairs(self.BtnList) do
        v.gameObject:SetActive(false)
    end

    self.SignInInfos = XSignInConfigs.GetSignInInfos(self.SignId)
    self:SetRewardInfos(self.Round)
    if #self.SignInInfos <= 1 then
        return
    end

    local btnGroupList = {}
    for i = 1, #self.SignInInfos do
        local grid = self.BtnList[i]
        if not grid then
            grid = CS.UnityEngine.Object.Instantiate(self.BtnTab.gameObject)
            grid.transform:SetParent(self.PanelTabContent.gameObject.transform, false)
            table.insert(self.BtnList, grid)
        end
        local xBtn = grid.transform:GetComponent("XUiButton")
        local rowImg = XUiHelper.TryGetComponent(grid.transform, "RImgIcon", "RawImage")

        table.insert(btnGroupList, xBtn)
        xBtn:SetName(self.SignInInfos[i].RoundName)
        rowImg:SetRawImage(self.SignInInfos[i].Icon)
        xBtn.gameObject:SetActive(true)
    end

    self.PanelTabContent:Init(btnGroupList, function(index)
        self:SelectPanelRound(index)
    end)

    local curRound = XDataCenter.SignInManager.GetSignRound(self.SignId, true)
    if curRound then
        self.PanelTabContent:SelectIndex(curRound, false)
    end
end

function XUiSignPrefab:SelectPanelRound(index)
    self.Parent:RefreshPanel(index)
end

function XUiSignPrefab:SetRewardInfos(index)
    local signInInfo = self.SignInInfos[index]
    local rewardConfigs = XSignInConfigs.GetSignInRewardConfigs(self.SignId, signInInfo.Round, false)

    for i, v in ipairs(self.DaySamllGrids) do
        v.GameObject:SetActive(false)
    end

    for i, v in ipairs(self.DayBigGrids) do
        v.GameObject:SetActive(false)
    end

    local samllIndex = 1
    local bigIndex = 1

    for i, config in ipairs(rewardConfigs) do
        if config.IsGrandPrix then                          -- 设置大奖励
            local dayGrid = self.DayBigGrids[bigIndex]
            if not dayGrid then
                local grid = CS.UnityEngine.GameObject.Instantiate(self.GridDayBig)
                grid.transform:SetParent(self.PanelDayContent, false)
                dayGrid = XUiSignGridDay.New(grid, self.RootUi)
                table.insert(self.DayBigGrids, dayGrid)
            end

            dayGrid:Refresh(config, self.IsShow, self.SetTomorrow)
            dayGrid.Transform:SetAsLastSibling()
            bigIndex = bigIndex + 1
        else                                                -- 设置小奖励
            local dayGrid = self.DaySamllGrids[samllIndex]
            if not dayGrid then
                local grid = CS.UnityEngine.GameObject.Instantiate(self.GridDaySmall)
                grid.transform:SetParent(self.PanelDayContent, false)
                dayGrid = XUiSignGridDay.New(grid, self.RootUi)
                table.insert(self.DaySamllGrids, dayGrid)
            end

            dayGrid:Refresh(config, self.IsShow, self.SetTomorrow)
            dayGrid.Transform:SetAsLastSibling()
            samllIndex = samllIndex + 1
        end
    end
end

function XUiSignPrefab:SetTomorrowOpen(dayRewardConfig, isRoundLastDay)
    local t = XSignInConfigs.GetSignInConfig(dayRewardConfig.SignId)
    local isActive = t.Type == XSignInConfigs.SignType.Activity

    if isRoundLastDay and isActive then
        for i, v in ipairs(self.DaySamllGrids) do
            if v.GameObject.activeSelf and v.Config and
               v.Config.SignId == dayRewardConfig.SignId and
               v.Config.Round == dayRewardConfig.Round + 1 and
               v.Config.Day == 1 then
                v:SetTomorrow()
                return
            end
        end

        for i, v in ipairs(self.DayBigGrids) do
            if v.GameObject.activeSelf and v.Config and
                v.Config.SignId == dayRewardConfig.SignId and
                v.Config.Round == dayRewardConfig.Round + 1 and
                v.Config.Day == 1 then
                v:SetTomorrow()
                return
            end
        end

        return
    end

    for i, v in ipairs(self.DaySamllGrids) do
       if v.GameObject.activeSelf and v.Config and
          v.Config.SignId == dayRewardConfig.SignId and
          v.Config.Round == dayRewardConfig.Round and
          v.Config.Day - 1 == dayRewardConfig.Day then
            v:SetTomorrow()
            return
        end
    end

    for i, v in ipairs(self.DayBigGrids) do
        if v.GameObject.activeSelf and v.Config and
           v.Config.SignId == dayRewardConfig.SignId and
           v.Config.Round == dayRewardConfig.Round and
           v.Config.Day - 1 == dayRewardConfig.Day then
            v:SetTomorrow()
            return
        end
    end
end

function XUiSignPrefab:SetSignActive(active, round)
    if active and self.GameObject.activeSelf then
        return
    end

    if not active and not self.GameObject.activeSelf then
        return
    end

    if #self.SignInInfos > 1 then
        self.PanelTabContent:SelectIndex(round, false)
    end

    self.GameObject:SetActive(active)
end

function XUiSignPrefab:SetTomorrowForce(isForce)
    self.SetTomorrow = isForce
end

return XUiSignPrefab