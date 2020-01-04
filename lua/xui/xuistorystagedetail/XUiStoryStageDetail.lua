local XUiStoryStageDetail = XLuaUiManager.Register(XLuaUi, "UiStoryStageDetail")

function XUiStoryStageDetail:OnAwake()
    self:InitAutoScript()
    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.FreeGem, XDataCenter.ItemManager.ItemId.ActionPoint, XDataCenter.ItemManager.ItemId.Coin)
end

function XUiStoryStageDetail:OnStart(rootUi)
    self.RootUi = rootUi
end

function XUiStoryStageDetail:OnEnable()
    self:Refresh()
end

function XUiStoryStageDetail:Refresh()
    local stageCfg = self.RootUi.Stage
    local stageId = stageCfg.StageId
    local stageInfo = XDataCenter.FubenManager.GetStageInfo(stageId)
    local chapterOrderId = XDataCenter.FubenMainLineManager.GetChapterOrderIdByStageId(stageId)

    self.TxtTitle.text = chapterOrderId .. "-" .. stageInfo.OrderId .. stageCfg.Name
    self.TxtStoryDes.text = stageCfg.Description
    self.RImgNandu:SetRawImage(stageCfg.Icon)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiStoryStageDetail:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiStoryStageDetail:AutoInitUi()
    self.TxtTitle = self.Transform:Find("SafeAreaContentPane/PaneDesc/TxtTitle"):GetComponent("Text")
    self.PanelAsset = self.Transform:Find("SafeAreaContentPane/PanelAsset")
    self.RImgNandu = self.Transform:Find("SafeAreaContentPane/PaneDesc/RImgNandu"):GetComponent("RawImage")
    self.TxtStoryDes = self.Transform:Find("SafeAreaContentPane/PaneStoryDes/TxtStoryDes"):GetComponent("Text")
    self.BtnEnter = self.Transform:Find("SafeAreaContentPane/PaneBottom/BtnEnter"):GetComponent("Button")
end

function XUiStoryStageDetail:AutoAddListener()
    self:RegisterClickEvent(self.BtnEnter, self.OnBtnEnterClick)
end
-- auto
function XUiStoryStageDetail:OnBtnEnterClick(eventData)
    local stageCfg = self.RootUi.Stage
    local stageId = stageCfg.StageId
    local stageInfo = XDataCenter.FubenManager.GetStageInfo(stageId)

    if stageInfo.Passed then
        if CS.Movie.XMovieManager.Instance:CheckMovieExist(stageCfg.BeginStoryId) then
            CS.Movie.XMovieManager.Instance:PlayById(stageCfg.BeginStoryId)
        end
    else
        XDataCenter.FubenManager.FinishStoryRequest(stageId, function(res)
                if CS.Movie.XMovieManager.Instance:CheckMovieExist(stageCfg.BeginStoryId) then
                    CS.Movie.XMovieManager.Instance:PlayById(stageCfg.BeginStoryId, function()
                            self.RootUi:RefreshRegional()
                        end)
                end
            end)
    end
end

function XUiStoryStageDetail:Hide()
    self:Close()
    CsXGameEventManager.Instance:Notify(XEventId.EVENT_FUBEN_CLOSE_FUBENSTAGEDETAIL)
end