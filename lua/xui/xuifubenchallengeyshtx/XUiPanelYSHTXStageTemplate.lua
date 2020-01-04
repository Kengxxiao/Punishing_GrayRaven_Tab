local XUiPanelYSHTXStageTemplate = XClass()

function XUiPanelYSHTXStageTemplate:Ctor(rootUi, ui, stageCfg, cb)
    self.RootUi = rootUi
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Callback = cb
    self.StageCfg = stageCfg
    self:InitAutoScript()
    self:Refresh()
    XEventManager.BindEvent(self, XEventId.EVENT_FUBEN_REFRESH_STAGE_DATA, self.Refresh, self)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelYSHTXStageTemplate:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiPanelYSHTXStageTemplate:AutoInitUi()
    self.PanelRight = self.Transform:Find("PanelRight")
    self.RImgIcon = self.Transform:Find("PanelRight/RImgIcon"):GetComponent("RawImage")
    self.TxtName = self.Transform:Find("PanelRight/TxtName"):GetComponent("Text")
    self.TxtDesc = self.Transform:Find("PanelRight/TxtDesc"):GetComponent("Text")
    self.ImgLock = self.Transform:Find("ImgLock"):GetComponent("Image")
    self.TxtLockDesc = self.Transform:Find("ImgLock/TxtLockDesc"):GetComponent("Text")
    self.TxtLockName = self.Transform:Find("ImgLock/TxtLockName"):GetComponent("Text")
    self.BtnEnter = self.Transform:Find("BtnEnter"):GetComponent("Button")
end

function XUiPanelYSHTXStageTemplate:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelYSHTXStageTemplate:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelYSHTXStageTemplate:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelYSHTXStageTemplate:AutoAddListener()
    self:RegisterClickEvent(self.BtnEnter, self.OnBtnEnterClick)
end
-- auto
function XUiPanelYSHTXStageTemplate:OnBtnEnterClick(...)
    if self.Callback then
        self.Callback(self.StageCfg, self.StageInfo)
    end
end

function XUiPanelYSHTXStageTemplate:IsOpen()
    return self.StageInfo.Unlock
end

function XUiPanelYSHTXStageTemplate:Refresh()
    if XTool.UObjIsNil(self.GameObject) then
        return
    end

    self.StageInfo = XDataCenter.FubenManager.GetStageInfo(self.StageCfg.StageId)
    if not self.StageInfo then
        return
    end

    if self.StageInfo.Unlock then
        self.PanelRight.gameObject:SetActive(true)
        self.ImgLock.gameObject:SetActive(false)
        self.TxtName.text = self.StageCfg.Name
        self.TxtDesc.text = self.StageCfg.RecommandLevel
    else
        self.PanelRight.gameObject:SetActive(false)
        self.ImgLock.gameObject:SetActive(true)
        self.TxtLockName.text = self.StageCfg.Name
        self.TxtLockDesc.text = self.StageCfg.RecommandLevel
    end

    if self.StageCfg.Icon and self.StageCfg.Icon ~= "" then
        self.RImgIcon:SetRawImage(self.StageCfg.Icon)
    end
end

return XUiPanelYSHTXStageTemplate