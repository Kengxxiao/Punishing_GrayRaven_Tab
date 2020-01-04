local XUiPanelStageLock = XClass()

function XUiPanelStageLock:Ctor(ui, stageId,chapterOrderId)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.StageId = stageId
    self.ChapterOrderId = chapterOrderId
    self:InitAutoScript()
    self:Refresh()
end

function XUiPanelStageLock:Refresh()
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
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelStageLock:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiPanelStageLock:AutoInitUi()
    self.TxtStage = self.Transform:Find("TxtStage"):GetComponent("Text")
end

function XUiPanelStageLock:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelStageLock:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelStageLock:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelStageLock:AutoAddListener()
end
-- auto
return XUiPanelStageLock