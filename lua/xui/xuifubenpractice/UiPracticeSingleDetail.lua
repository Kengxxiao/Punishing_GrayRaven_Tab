-- 家具建造主界面
local XUiPracticeSingleDetail = XLuaUiManager.Register(XLuaUi, "UiPracticeSingleDetail")

function XUiPracticeSingleDetail:OnAwake()
    self:InitViews()
    self:AddBtnsListeners()
end

function XUiPracticeSingleDetail:AddBtnsListeners()
    self:RegisterClickEvent(self.BtnEnter, self.OnBtnEnterClick)
end

function XUiPracticeSingleDetail:InitViews()
    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.FreeGem, XDataCenter.ItemManager.ItemId.ActionPoint, XDataCenter.ItemManager.ItemId.Coin)
    self.PanelNums.gameObject:SetActive(false)
    self.GridList = {}
    self.GridListTag = {}
end

function XUiPracticeSingleDetail:OnStart()
end

function XUiPracticeSingleDetail:OnEnable()
end

function XUiPracticeSingleDetail:OnDisable()
end

function XUiPracticeSingleDetail:OnDestroy()
end

function XUiPracticeSingleDetail:Refresh(stageId)
    self.StageId = stageId

    self:UpdateCommon()
    self:UpdateReward()
end

function XUiPracticeSingleDetail:UpdateCommon()
    local stageCfg = XDataCenter.FubenManager.GetStageCfg(self.StageId)
    local nanDuIcon = XDataCenter.FubenManager.GetDiccicultIcon(self.StageId)

    self.TxtTitle.text = stageCfg.Name
    self.RImgNandu:SetRawImage(nanDuIcon)

    for i = 1, 3 do
        self[string.format("TxtActive%d", i)].text = stageCfg.StarDesc[i]
    end

    self.TxtATNums.text = stageCfg.RequireActionPoint or 0
end

function XUiPracticeSingleDetail:OnBtnEnterClick()
    local stageCfg = XDataCenter.FubenManager.GetStageCfg(self.StageId)
    if XDataCenter.FubenManager.CheckPreFight(stageCfg) then
        XLuaUiManager.Open("UiNewRoomSingle", stageCfg.StageId)
        self:Close()
    end
end

function XUiPracticeSingleDetail:UpdateReward()
    local stageCfg = XDataCenter.FubenManager.GetStageCfg(self.StageId)
    local stageInfo = XDataCenter.FubenManager.GetStageInfo(self.StageId)
    local stageLevelControl = XDataCenter.FubenManager.GetStageLevelControl(self.StageId)

    local rewardId = stageLevelControl and  stageLevelControl.FirstRewardShow or stageCfg.FirstRewardShow

    if rewardId == 0 then
        for i = 1, #self.GridList do
            self.GridList[i].GameObject:SetActive(false)
        end
        return 
    end

    local rewards = XRewardManager.GetRewardList(rewardId)
    if rewards then
        for i, item in ipairs(rewards) do
            local grid
            if self.GridList[i] then
                grid = self.GridList[i]
            else
                local ui = CS.UnityEngine.Object.Instantiate(self.GridCommon)
                grid = XUiGridCommon.New(self, ui)
                grid.Transform:SetParent(self.PanelDropContent, false)
                self.GridList[i] = grid
                self.GridListTag[i] = grid.Transform:Find("Received")
            end
            grid:Refresh(item)
            grid.GameObject:SetActive(true)
            if self.GridListTag[i] then
                self.GridListTag[i].gameObject:SetActive(stageInfo.Passed)
            end
        end
    end

    for i = #rewards + 1, #self.GridList do
        self.GridList[j].GameObject:SetActive(false)
    end
end