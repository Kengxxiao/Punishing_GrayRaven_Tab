local XUiFubenChallengeEMEX = XLuaUiManager.Register(XLuaUi, "UiFubenChallengeEMEX")
local MAX_DISPLAY_STAGE = 7

function XUiFubenChallengeEMEX:OnAwake()
    self:InitAutoScript()
    self.SViewBg.gameObject:SetActive(false)
end

function XUiFubenChallengeEMEX:OnStart(parent, config)
    self.Parent = parent
    self:Init(config)
    self.timer = CS.XScheduleManager.ScheduleForever(self.Refresh, 0)
    self.PanelHover.gameObject:SetActive(false)
    self.OrgPosition = self.PanelMapContainer.transform.localPosition
    self.TargetPosition = self.PanelTargetFlag.transform.position

    XEventManager.AddEventListener(XEventId.EVENT_FUBEN_CLOSE_FUBENSTAGEDETAIL, self.UnFocus, self)
    XEventManager.AddEventListener(XEventId.EVENT_FUBEN_REFRESH_STAGE_DATA, self.RefreshStage, self)
end

function XUiFubenChallengeEMEX:OnDestroy()
    if self.timer then
        CS.XScheduleManager.UnSchedule(self.timer)
        self.timer = nil
    end

    XEventManager.RemoveEventListener(XEventId.EVENT_FUBEN_CLOSE_FUBENSTAGEDETAIL, self.UnFocus, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_FUBEN_REFRESH_STAGE_DATA, self.RefreshStage, self)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiFubenChallengeEMEX:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiFubenChallengeEMEX:AutoInitUi()
    self.PanelMapContainer = self.Transform:Find("FullScreenBackground/PanelMapContainer")
    self.SViewBg = self.Transform:Find("FullScreenBackground/PanelMapContainer/SViewBg"):GetComponent("ScrollRect")
    self.PanelContentBg = self.Transform:Find("FullScreenBackground/PanelMapContainer/SViewBg/Viewport/PanelContentBg")
    self.PanelBg = self.Transform:Find("FullScreenBackground/PanelMapContainer/SViewBg/Viewport/PanelContentBg/PanelBg")
    self.SViewStage = self.Transform:Find("FullScreenBackground/PanelMapContainer/SViewStage"):GetComponent("ScrollRect")
    self.PanelContent = self.Transform:Find("FullScreenBackground/PanelMapContainer/SViewStage/Viewport/PanelContent")
    self.PanelStage = self.Transform:Find("FullScreenBackground/PanelMapContainer/SViewStage/Viewport/PanelContent/PanelStage")
    --self.ImgOpen = self.Transform:Find("FullScreenBackground/PanelMapContainer/SViewStage/Viewport/PanelContent/PanelStage/Stage1/RImgOpen"):GetComponent("RawImage")
    --self.ImgOpenA = self.Transform:Find("FullScreenBackground/PanelMapContainer/SViewStage/Viewport/PanelContent/PanelStage/Stage2/RImgOpen"):GetComponent("RawImage")
    --self.ImgOpenB = self.Transform:Find("FullScreenBackground/PanelMapContainer/SViewStage/Viewport/PanelContent/PanelStage/Stage3/RImgOpen"):GetComponent("RawImage")
    --self.ImgOpenC = self.Transform:Find("FullScreenBackground/PanelMapContainer/SViewStage/Viewport/PanelContent/PanelStage/Stage4/RImgOpen"):GetComponent("RawImage")
    --self.ImgOpenD = self.Transform:Find("FullScreenBackground/PanelMapContainer/SViewStage/Viewport/PanelContent/PanelStage/Stage5/RImgOpen"):GetComponent("RawImage")
    --self.ImgOpenE = self.Transform:Find("FullScreenBackground/PanelMapContainer/SViewStage/Viewport/PanelContent/PanelStage/Stage6/RImgOpen"):GetComponent("RawImage")
    --self.ImgOpenF = self.Transform:Find("FullScreenBackground/PanelMapContainer/SViewStage/Viewport/PanelContent/PanelStage/Stage7/RImgOpen"):GetComponent("RawImage")
    self.PanelTargetFlag = self.Transform:Find("FullScreenBackground/PanelTargetFlag")
    self.PanelHover = self.Transform:Find("FullScreenBackground/PanelHover")
end

function XUiFubenChallengeEMEX:GetAutoKey(uiNode, eventName)
    if not uiNode then
        return
    end
    return eventName .. uiNode:GetHashCode()
end

function XUiFubenChallengeEMEX:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then
        return
    end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiFubenChallengeEMEX:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiFubenChallengeEMEX:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterListener(self.SViewBg, "onValueChanged", self.OnSViewBgValueChanged)
    self:RegisterListener(self.SViewStage, "onValueChanged", self.OnSViewStageValueChanged)
end
-- auto
function XUiFubenChallengeEMEX:OnSViewBgValueChanged(...)

end

function XUiFubenChallengeEMEX:OnSViewStageValueChanged(...)

end

function XUiFubenChallengeEMEX:Init(chapter)
    self.SectionCfg = XDataCenter.FubenDailyManager.GetDailySectionByChapterId(chapter.Id)
    local maxStage = math.min(#self.SectionCfg.StageId, MAX_DISPLAY_STAGE)
    for i = 1, maxStage do
        local stageId = self.SectionCfg.StageId[i]
        local stageCfg = XDataCenter.FubenManager.GetStageCfg(stageId)
        local stageItem = self.PanelStage:Find("Stage" .. i)
        local stageButton = stageItem:Find("Enter"):GetComponent("Button")
        local stageLock = stageItem:Find("StageLock"):GetComponent("Button")
        stageItem:Find("StageLock/Text"):GetComponent("Text").text = stageCfg.Name
        stageItem:Find("StageOpen/Text"):GetComponent("Text").text = stageCfg.Name
        local rImgOpen = stageItem:Find("RImgOpen"):GetComponent("RawImage")
        --self:SetUiSprite(imgOpen, stageCfg.Icon)
        rImgOpen:SetRawImage(stageCfg.Icon)
        stageButton.interactable = true
        stageLock.interactable = true
        self:RegisterClickEvent(stageButton, function()
            self:OpenDetail(stageItem, stageCfg)
        end)
        self:RegisterClickEvent(stageLock, function()
            self:OpenDetail(stageItem, stageCfg)
        end)
    end
    local linePanel = self.PanelStage:Find("Line")
    local rectTransform = self.PanelContent:GetComponent("RectTransform")
    local minX = rectTransform.sizeDelta.x
    for i = maxStage + 1, MAX_DISPLAY_STAGE do
        local stageItem = self.PanelStage:Find("Stage" .. i)
        stageItem.gameObject:SetActive(false)
        local line = linePanel:Find("Image" .. (i - 1))
        if line then
            line.gameObject:SetActive(false)
            local pos = self.PanelContent.transform:InverseTransformPoint(line.transform.position)
            if minX then
                minX = math.min(pos.x + 150, minX)
            else
                minX = pos.x + 150
            end
        end
    end
    rectTransform.sizeDelta = CS.UnityEngine.Vector2(minX, rectTransform.sizeDelta.y)
    self:RefreshStage()
end

function XUiFubenChallengeEMEX:RefreshStage()
    local maxStage = math.min(#self.SectionCfg.StageId, MAX_DISPLAY_STAGE)
    for i = 1, maxStage do
        local stageId = self.SectionCfg.StageId[i]
        local stageCfg = XDataCenter.FubenManager.GetStageCfg(stageId)
        local stageInfo = XDataCenter.FubenManager.GetStageInfo(stageId)
        local stageItem = self.PanelStage:Find("Stage" .. i)
        local stageLock = stageItem:Find("StageLock")
        local stageOpen = stageItem:Find("StageOpen")
        local enter = stageItem:Find("Enter")
        local rImgOpen = XUiHelper.TryGetComponent(stageItem, "RImgOpen", "RawImage")
        if stageInfo.Unlock then
            rImgOpen:SetRawImage(stageCfg.Icon)
        end
        stageLock.gameObject:SetActive(not stageInfo.Unlock)
        enter.gameObject:SetActive(stageInfo.Unlock)
        rImgOpen.gameObject:SetActive(stageInfo.Unlock)
        stageOpen.gameObject:SetActive(stageInfo.Unlock)

    end
end

function XUiFubenChallengeEMEX:OpenDetail(stageItem, stageCfg)
    local stageInfo = XDataCenter.FubenManager.GetStageInfo(stageCfg.StageId)
    if stageInfo and not stageInfo.Unlock then
        local msg = XDataCenter.FubenManager.GetFubenOpenTips(stageCfg.StageId)
        XUiManager.TipMsg(msg)
        return
    end
    self:FocusStage(stageItem)
    if stageCfg.IsMultiplayer then
        self:OpenMultiplayerStageDetail(stageCfg, stageInfo)
    else
        self.Parent:OpenPanelStageDetail(stageCfg, stageInfo)
    end
end

function XUiFubenChallengeEMEX:OpenMultiplayerStageDetail(stageCfg, stageInfo)
    -- XLuaUiManager.Open("UiOnLineTranscript", stageCfg)
    XLuaUiManager.Open("UiFubenStageDetail", stageCfg)
end

function XUiFubenChallengeEMEX:OnCloseStageDetail()
    self:UnFocus()
end

function XUiFubenChallengeEMEX:OnEnterFight()
    self:UnFocus(true)
end

function XUiFubenChallengeEMEX:FocusStage(stageItem)
    local worldPos = stageItem.transform.position
    local localPos = self.PanelMapContainer.transform:InverseTransformPoint(worldPos)
    local tPos = self.PanelMapContainer.transform:InverseTransformPoint(self.TargetPosition)
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

function XUiFubenChallengeEMEX:UnFocus(immediate)
    if immediate then
        self.PanelMapContainer.localPosition = self.OrgPosition
        self.PanelHover.gameObject:SetActive(false)
        return
    end
    local startPos = self.PanelMapContainer.localPosition
    local deltaPos = self.OrgPosition - startPos
    local lineAni = CS.UnityEngine.AnimationCurve.Linear(0, 0, 1, 1)
    XUiHelper.Tween(0.3, function(t)
        if XTool.UObjIsNil(self.PanelMapContainer) then 
            return
        end

        self.PanelMapContainer.localPosition = startPos + deltaPos * lineAni:Evaluate(t)
    end, function()
        if XTool.UObjIsNil(self.PanelMapContainer) then 
            return
        end
        
        self.PanelMapContainer.localPosition = self.OrgPosition
        self.PanelHover.gameObject:SetActive(false)
    end)
end

function XUiFubenChallengeEMEX:Refresh()
    if XTool.UObjIsNil(self.GameObject) then
        if self.timer then
            CS.XScheduleManager.UnSchedule(self.timer)
            self.timer = nil
        end
        return
    end
    self.SViewBg.horizontalNormalizedPosition = self.SViewStage.horizontalNormalizedPosition
    self.SViewBg.verticalNormalizedPosition = self.SViewStage.verticalNormalizedPosition
end

return XUiFubenChallengeEMEX