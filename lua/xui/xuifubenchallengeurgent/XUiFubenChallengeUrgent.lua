local XUiFubenChallengeUrgent = XLuaUiManager.Register(XLuaUi, "UiFubenChallengeUrgent")

function XUiFubenChallengeUrgent:OnAwake()
    self:InitAutoScript()
end

function XUiFubenChallengeUrgent:OnStart(parent, config)
    self.Parent = parent
    self:Init(config)
    self.timer = CS.XScheduleManager.ScheduleForever(function(...)
        self:Refresh()
    end, 0)
    self.PanelHover.gameObject:SetActive(false)
    self.orgPosition = self.PanelMapContainer.transform.localPosition
    self.targetPosition = self.PanelTargetFlag.transform.position
end

function XUiFubenChallengeUrgent:OnDestroy()
    if self.timer then
        CS.XScheduleManager.UnSchedule(self.timer)
        self.timer = nil
    end

    if self.TimerTween then
        CS.XScheduleManager.UnSchedule(self.TimerTween)
        self.TimerTween = nil
    end
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiFubenChallengeUrgent:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiFubenChallengeUrgent:AutoInitUi()
    self.PanelMapContainer = self.Transform:Find("FullScreenBackground/PanelMapContainer")
    self.SViewStage = self.Transform:Find("FullScreenBackground/PanelMapContainer/SViewStage"):GetComponent("ScrollRect")
    self.PanelContent = self.Transform:Find("FullScreenBackground/PanelMapContainer/SViewStage/Viewport/PanelContent")
    self.PanelStage = self.Transform:Find("FullScreenBackground/PanelMapContainer/SViewStage/Viewport/PanelContent/PanelStage")
    self.PanelStageA = self.Transform:Find("FullScreenBackground/PanelMapContainer/SViewStage/Viewport/PanelContent/PanelStage/PanelStageA")
    self.ImgOpen = self.Transform:Find("FullScreenBackground/PanelMapContainer/SViewStage/Viewport/PanelContent/PanelStage/PanelStageA/ImgOpen"):GetComponent("Image")
    self.TxtName = self.Transform:Find("FullScreenBackground/PanelMapContainer/SViewStage/Viewport/PanelContent/PanelStage/PanelStageA/StageOpen/TxtName"):GetComponent("Text")
    self.TxtTime = self.Transform:Find("FullScreenBackground/PanelMapContainer/SViewStage/Viewport/PanelContent/PanelStage/PanelStageA/StageOpen/TxtTime"):GetComponent("Text")
    self.BtnEnter = self.Transform:Find("FullScreenBackground/PanelMapContainer/SViewStage/Viewport/PanelContent/PanelStage/PanelStageA/BtnEnter"):GetComponent("Button")
    self.PanelHover = self.Transform:Find("FullScreenBackground/PanelHover")
    self.PanelTargetFlag = self.Transform:Find("FullScreenBackground/PanelTargetFlag")
end

function XUiFubenChallengeUrgent:AutoAddListener()
    self:RegisterClickEvent(self.SViewStage, self.OnSViewStageClick)
    self:RegisterClickEvent(self.BtnEnter, self.OnBtnEnterClick)
end
-- auto

function XUiFubenChallengeUrgent:OnSViewStageClick(eventData)

end

function XUiFubenChallengeUrgent:OnBtnEnterClick(...)
    self:FocusStage()
    self.Parent:OpenPanelStageDetail(self.StageCfg, self.StageInfo)
end

function XUiFubenChallengeUrgent:Init(config)
    local urgentCfg = config.UrgentCfg
    self.StageCfg = XDataCenter.FubenManager.GetStageCfg(config.UrgentInfo.StageId)
    self.StageInfo = XDataCenter.FubenManager.GetStageInfo(config.UrgentInfo.StageId)
    self:SetUiSprite(self.ImgOpen, urgentCfg.StageIcon)
    self.TxtName.text =  self.StageCfg.Name
    XCountDown.BindTimer(self, tostring(urgentCfg.Id), function(v)
        if v > 1 then
            self.TxtTime.text = XUiHelper.GetTime(v, XUiHelper.TimeFormatType.CHALLENGE)
        else
            self.TxtTime.text = XUiHelper.GetTime(0)
        end
    end)
end

function XUiFubenChallengeUrgent:OnCloseStageDetail()
    self:UnFocus()
end

function XUiFubenChallengeUrgent:FocusStage()
    local worldPos = self.PanelStageA.transform.position
    local localPos = self.PanelMapContainer.transform:InverseTransformPoint(worldPos)
    local tPos = self.PanelMapContainer.transform:InverseTransformPoint(self.targetPosition)
    local deltaPos = tPos - localPos
    local lineAni = CS.UnityEngine.AnimationCurve.Linear(0, 0, 1, 1)
    local startPos = self.PanelMapContainer.localPosition
    self.PanelHover.gameObject:SetActive(true)
    XUiHelper.Tween(0.3, function(t)
        if XTool.UObjIsNil(self.PanelMapContainer) then 
            return
        end

        self.PanelMapContainer.localPosition = startPos + deltaPos * lineAni:Evaluate(t)
    end, function()
        if XTool.UObjIsNil(self.PanelMapContainer) then 
            return
        end

        self.PanelMapContainer.localPosition = startPos + deltaPos
    end)
end

function XUiFubenChallengeUrgent:UnFocus()
    local startPos = self.PanelMapContainer.localPosition
    local deltaPos = self.orgPosition - startPos
    local lineAni = CS.UnityEngine.AnimationCurve.Linear(0, 0, 1, 1)
    self.TimerTween = XUiHelper.Tween(0.3, function(t)
        if XTool.UObjIsNil(self.PanelMapContainer) then 
            return 
        end

        self.PanelMapContainer.localPosition = startPos + deltaPos * lineAni:Evaluate(t)
    end, function()
        if XTool.UObjIsNil(self.PanelMapContainer) then 
            return 
        end
        
        self.PanelMapContainer.localPosition = self.orgPosition
        self.PanelHover.gameObject:SetActive(false)
    end)
end

function XUiFubenChallengeUrgent:Refresh()
    --self.SViewBg.horizontalNormalizedPosition = self.SViewStage.horizontalNormalizedPosition
    --self.SViewBg.verticalNormalizedPosition = self.SViewStage.verticalNormalizedPosition
end
