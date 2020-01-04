local XUiPanelStoryActive = XClass()

function XUiPanelStoryActive:Ctor(ui, stageId, chapterOrderId)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.StageId = stageId
    self.ChapterOrderId = chapterOrderId
    self:InitAutoScript()
    self:Refresh()
end

function XUiPanelStoryActive:Refresh()
    local stageId = self.StageId
    local stageInfo = XDataCenter.FubenManager.GetStageInfo(stageId)
    local stageCfg = XDataCenter.FubenManager.GetStageCfg(stageId)
    if stageInfo.Type == XDataCenter.FubenManager.StageType.Mainline then
        local strTxtStage = ""
        if XDataCenter.BfrtManager.CheckStageTypeIsBfrt(stageId) then
            strTxtStage = self.ChapterOrderId .. "-" .. XDataCenter.BfrtManager.GetGroupOrderIdByStageId(stageId)
        else
            strTxtStage = self.ChapterOrderId .. "-" .. stageCfg.OrderId
        end
        self.TxtStage.text = strTxtStage
        self.ImgStageOrder.gameObject:SetActive(true)
    else
        self.ImgStageOrder.gameObject:SetActive(false)
    end
end

function XUiPanelStoryActive:UpdateStageId(stageId)
    if self.StageId ~= stageId then
        self.StageId = stageId
        self:Refresh()
    end
end

function XUiPanelStoryActive:GetKillPos()
    if self.KillPos then
        return self.KillPos.position
    else
        return self.Transform.position
    end
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelStoryActive:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiPanelStoryActive:AutoInitUi()
    self.ImgStageOrder = self.Transform:Find("ImgStageOrder"):GetComponent("Image")
    self.TxtStage = self.Transform:Find("ImgStageOrder/TxtStage"):GetComponent("Text")
    self.KillPos = self.Transform:Find("KillPos")
end

function XUiPanelStoryActive:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelStoryActive:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelStoryActive:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelStoryActive:AutoAddListener()
end
-- auto
return XUiPanelStoryActive