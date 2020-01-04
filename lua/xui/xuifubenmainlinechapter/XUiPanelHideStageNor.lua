local XUiPanelHideStageNor = XClass()

function XUiPanelHideStageNor:Ctor(ui, stageId, rootUi)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.StageId = stageId
    self.RootUi = rootUi
    XTool.InitUiObject(self)
    self.BtnOnHideLock.CallBack = function() self:OnBtnOnHideLockClick() end
    self:Refresh()
end

function XUiPanelHideStageNor:Refresh()
    local stagecfg = XDataCenter.FubenManager.GetStageCfg(self.StageId)
    local stageInfo = XDataCenter.FubenManager.GetStageInfo(self.StageId)
    self.RImgHideStageNor:SetRawImage(stagecfg.Icon)
    self.TxtHideStageNor.text = stagecfg.Name
    self.PanelPass.gameObject:SetActiveEx(stageInfo.Passed)
end

function XUiPanelHideStageNor:UpdateStageId(stageId)
    self.StageId = stageId
    self:Refresh()
end

function XUiPanelHideStageNor:OnBtnOnHideLockClick(eventData)
    if not self.StageId then return end

    local stageCfg = XDataCenter.FubenManager.GetStageCfg(self.StageId)
    local stageInfo = XDataCenter.FubenManager.GetStageInfo(self.StageId)

    if not XDataCenter.PrequelManager.CheckPrequelStageOpen(self.StageId) then
        if stageCfg.RequireLevel > 0 and XPlayer.Level < stageCfg.RequireLevel then
            XUiManager.TipError(CS.XTextManager.GetText("TeamLevelToOpen", stageCfg.RequireLevel))
            return
        end
        XUiManager.TipError(CS.XTextManager.GetText("PrequelUnTrigger"))
        return
    end

    if stageCfg.StageType == XFubenConfigs.STAGETYPE_STORYEGG then
        if stageInfo.Passed then
            self.RootUi:OnEnterStory(self.StageId, function()
                if CS.Movie.XMovieManager.Instance:CheckMovieExist(stageCfg.BeginStoryId) then
                    CS.Movie.XMovieManager.Instance:PlayById(stageCfg.BeginStoryId)
                end
            end)
        else
            self.RootUi:OnEnterStory(self.StageId, function()
                XDataCenter.PrequelManager.FinishStoryRequest(self.StageId, function(res)
                    if CS.Movie.XMovieManager.Instance:CheckMovieExist(stageCfg.BeginStoryId) then
                        CS.Movie.XMovieManager.Instance:PlayById(stageCfg.BeginStoryId, function()
                            self.RootUi:RefreshRegional()
                        end)
                    end
                end)
            end)
        end
        XDataCenter.PrequelManager.UpdateShowChapter(self.StageId)
    end

    if stageCfg.StageType == XFubenConfigs.STAGETYPE_FIGHTEGG then
        if not stageCfg then
            XLog.Error("XUiGridPrequelStage:OnBtnStageClick error: stageId error " .. tostring(self.StageId))
            return
        end
        self.RootUi:OnEnterFight(self.StageId, function()
            XDataCenter.FubenManager.EnterPrequelFight(self.StageId)
        end)
    end
end

return XUiPanelHideStageNor