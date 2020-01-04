local XUiPanelFightActive = XClass()

function XUiPanelFightActive:Ctor(ui, stageId, clickCb)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.StageId = stageId
    self.ClickCb = clickCb
    self:InitAutoScript()
    self:Refresh()
end

function XUiPanelFightActive:Refresh()
    local stagecfg = XDataCenter.FubenManager.GetStageCfg(self.StageId)

    self.RImgFightActiveNor:SetRawImage(stagecfg.Icon)
    self.TxtFightNameNor.text = stagecfg.Name
end

function XUiPanelFightActive:UpdateStageId(stageId)
    if self.StageId ~= stageId then
        self.StageId = stageId
        self:Refresh()
    end
end

function XUiPanelFightActive:GetKillPos()
    if self.KillPos then
        return self.KillPos.position
    else
        return self.Transform.position
    end
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelFightActive:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiPanelFightActive:AutoInitUi()
    self.RImgFightActiveNor = self.Transform:Find("RImgFightActiveNor"):GetComponent("RawImage")
    self.TxtFightNameNor = self.Transform:Find("ImageFightTitleBgNor/TxtFightNameNor"):GetComponent("Text")
    self.BtnStage = self.Transform:Find("BtnStage"):GetComponent("Button")
    self.KillPos = self.Transform:Find("KillPos")
end

function XUiPanelFightActive:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelFightActive:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelFightActive:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelFightActive:AutoAddListener()
    self:RegisterClickEvent(self.BtnStage, self.OnBtnStageClick)
end
-- auto
function XUiPanelFightActive:OnBtnStageClick()
    if self.ClickCb then self.ClickCb() end
end

return XUiPanelFightActive