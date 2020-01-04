local XUiPanelStageSelected = XClass()

function XUiPanelStageSelected:Ctor(ui, stageId,chapterOrderId)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.StageId = stageId
    self.ChapterOrderId = chapterOrderId
    self:InitAutoScript()
    self:Refresh()
end

function XUiPanelStageSelected:Refresh()
    local stageId = self.StageId
    local stageCfg = XDataCenter.FubenManager.GetStageCfg(stageId)

    --文字
    local strTxtStage = ""
    if XDataCenter.BfrtManager.CheckStageTypeIsBfrt(stageId) then
        strTxtStage = self.ChapterOrderId .. "-" .. XDataCenter.BfrtManager.GetGroupOrderIdByStageId(stageId)
    else
        strTxtStage = self.ChapterOrderId .. "-" .. stageCfg.OrderId
    end
    self.TxtStage.text = strTxtStage

    --图标
    local icon = stageCfg.Icon
    if icon then self.RImgNor:SetRawImage(icon) end
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelStageSelected:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiPanelStageSelected:AutoInitUi()
    self.TxtStage = self.Transform:Find("TxtStage"):GetComponent("Text")
    self.RImgNor = self.Transform:Find("RImgNor"):GetComponent("RawImage")
end

function XUiPanelStageSelected:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelStageSelected:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelStageSelected:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelStageSelected:AutoAddListener()
end
-- auto
return XUiPanelStageSelected