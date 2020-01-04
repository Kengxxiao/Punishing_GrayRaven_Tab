local XUiGridActivityStageBanner = XClass()

function XUiGridActivityStageBanner:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
end

function XUiGridActivityStageBanner:SetRootUi(rootUi)
    self.RootUi = rootUi
end

function XUiGridActivityStageBanner:Refresh(challengeId)
    local challengeResCfg = XFubenActivityBossSingleConfigs.GetChallengeResCfg(challengeId)
    local stageId = XFubenActivityBossSingleConfigs.GetStageId(challengeId)
    local stageCfg = XDataCenter.FubenManager.GetStageCfg(stageId)

    self.RImgBanner:SetRawImage(stageCfg.Icon)
    self.RootUi:SetUiSprite(self.ImgIcon, challengeResCfg.Icon)
    self.TxtTitle.text = stageCfg.Name
    self.PanelFinish.gameObject:SetActive(XDataCenter.FubenActivityBossSingleManager.IsChallengePassed(challengeId))

    if not XDataCenter.FubenActivityBossSingleManager.IsChallengeUnlock(challengeId) then
        local preChallengeId = XDataCenter.FubenActivityBossSingleManager.GetPreChallengeId(self.RootUi.SectionId, challengeId)
        if not XDataCenter.FubenActivityBossSingleManager.IsChallengePassed(preChallengeId) then
            local preStageId = XFubenActivityBossSingleConfigs.GetStageId(preChallengeId)
            local preStageCfg = XDataCenter.FubenManager.GetStageCfg(preStageId)
            self.TxtLock.text = CS.XTextManager.GetText("ActivityBossSinglePreStage", preStageCfg.Name)
        end
        self.PanelLock.gameObject:SetActive(true)
    else
        self.PanelLock.gameObject:SetActive(false)
    end
end

return XUiGridActivityStageBanner