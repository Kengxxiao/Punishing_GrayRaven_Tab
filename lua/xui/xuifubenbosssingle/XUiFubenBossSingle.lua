local XUiFubenBossSingle = XLuaUiManager.Register(XLuaUi, "UiFubenBossSingle")
local XUiPanelBossStgae = require("XUi/XUiFubenBossSingle/XUiPanelBossStgae")
local XUiPanelBossRankInfo = require("XUi/XUiFubenBossSingle/XUiPanelBossRankInfo")
local XUiPanelBossDetail = require("XUi/XUiFubenBossSingle/XUiPanelBossDetail")
local XUiPanelBossEnter = require("XUi/XUiFubenBossSingle/XUiPanelBossEnter")

function XUiFubenBossSingle:OnAwake()
    self:AutoAddListener()
    self.RoleModelPanel = XUiPanelRoleModel.New(self:GetSceneRoot().transform:FindTransform("PanelRoleModel"), self.Name, nil, true)
end

function XUiFubenBossSingle:OnStart(bossSingleData, bossList, cfg)
    self:Init(bossSingleData, bossList, cfg)
    XEventManager.AddEventListener(XEventId.EVENT_FUBEN_REFRESH_STAGE_DATA, self.OnSyncBossData, self)
    XEventManager.AddEventListener(XEventId.EVENT_BOSS_SINGLE_GET_REWARD, self.OnRewardGet, self)
end

function XUiFubenBossSingle:OnDestroy()
    if self.BossRankInfo then
        self.BossRankInfo:RemoveTimer()
    end

    XEventManager.RemoveEventListener(XEventId.EVENT_FUBEN_REFRESH_STAGE_DATA, self.OnSyncBossData, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_BOSS_SINGLE_GET_REWARD, self.OnRewardGet, self)
end

function XUiFubenBossSingle:OnEnable()
    if self.BossDetail and self.BossDetail.GameObject.activeInHierarchy then
        self.BossDetail:ShowPanel()
    end
end

function XUiFubenBossSingle:AutoAddListener()
    self:RegisterClickEvent(self.BtnBack, self.OnBtnBackClick)
    self:RegisterClickEvent(self.BtnMainUi, self.OnBtnMainUiClick)
    self:RegisterClickEvent(self.BtnHelp, self.OnBtnHelpClick)
end

function XUiFubenBossSingle:Init(bossSingleData, bossList, cfg)
    self.BossSingleData = bossSingleData
    self.BossList = XUiPanelBossStgae.New(self, self.PanelBossStgae, bossList)
    self.BossList:PanelBossContentActive(true)
    self.BossEnter = XUiPanelBossEnter.New(self, self.PanelBossEnter, bossSingleData, cfg)
    self.BossRankInfo = XUiPanelBossRankInfo.New(self, self.PanelBossRankInfo)
    self.BossRankInfo:HidePanel()
    self.BossDetail = XUiPanelBossDetail.New(self, self.PanelBossDetail)
    self.BossDetail:HidePanel()
    self.RoleModelPanel:HideRoleModel()
    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.FreeGem, XDataCenter.ItemManager.ItemId.ActionPoint, XDataCenter.ItemManager.ItemId.Coin)
    self:OnSyncBossData()

    local scoreReardCfg = XDataCenter.FubenBossSingleManager.GetCurScoreRewardCfg()
    self.CurScoreRewardId = scoreReardCfg and scoreReardCfg.Id or -1
end

function XUiFubenBossSingle:OnSyncBossData()
    local bossSingleData = XDataCenter.FubenBossSingleManager.GetBoosSingleData()
    self.BossSingleData = bossSingleData
    local isAutoFight = self.BossDetail:CheckAutoFightOpen()

    if isAutoFight then
        self.BossEnter:ShowPanel(true, bossSingleData, isAutoFight)
        self.BossDetail:Refresh(bossSingleData)
        self.BossDetail:SetAutoFightClose()
        self.BossRankInfo:HidePanel()
        self.BossList:PanelBossContentActive(false)
        return
    end

    self.BossEnter:ShowPanel(true, bossSingleData, false, true)
    self.BossDetail:HidePanel()
    self.BossDetail:Refresh(bossSingleData)
    self.RoleModelPanel:HideRoleModel()
    self.BossList:PanelBossContentActive(true)
    self.BossList:RefreshBossDifficult()
    self.BossRankInfo:HidePanel()
end

function XUiFubenBossSingle:OnRewardGet()
    self.BossEnter:CheckRedPoint()
end


function XUiFubenBossSingle:OnBtnHelpClick(...)
    XUiManager.ShowHelpTip("BossSingle")
end

function XUiFubenBossSingle:OnBtnBackClick(...)
    if self.BossEnter.GameObject.activeSelf then
        self:Close()
    elseif self.BossRankInfo.GameObject.activeSelf then
        self:Back2Enter()
    elseif self.BossDetail.GameObject.activeSelf then
        self:Back2Enter()
    end
end

function XUiFubenBossSingle:Back2Enter()
    self.BossEnter:ShowPanel()
    self.BossDetail:HidePanel()
    self.RoleModelPanel:HideRoleModel()
    self.BossList:PanelBossContentActive(true)
    self.BossRankInfo:HidePanel()
end

function XUiFubenBossSingle:OnBtnMainUiClick(...)
    XLuaUiManager.RunMain()
end

function XUiFubenBossSingle:ShowBossDetail(bossId)
    self.BossEnter:HidePanel()
    self.BossRankInfo:HidePanel()
    self.BossList:PanelBossContentActive(false)
    self.BossDetail:ShowPanel(self.BossSingleData, bossId)
    self.RoleModelPanel:ShowRoleModel()
end

function XUiFubenBossSingle:ShowBossRank(levelType, rankPlatform)
    self.BossEnter:HidePanel()
    self.BossDetail:HidePanel()
    self.RoleModelPanel:HideRoleModel()
    self.BossList:PanelBossContentActive(false)
    self.BossRankInfo:ShowPanel(levelType, rankPlatform)
end

function XUiFubenBossSingle:RefreshModel(modelId)
    self.RoleModelPanel:UpdateBossModel(modelId, XModelManager.MODEL_UINAME.XUiBossSingle)
    self.RoleModelPanel:ShowRoleModel()
end

function XUiFubenBossSingle:ShowBossGroupInfo(groupId)
    self.BossEnter:ShowBossGroupInfo(groupId)
end