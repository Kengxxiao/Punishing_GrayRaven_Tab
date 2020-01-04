XUiGridChallengeTab = XClass()

function XUiGridChallengeTab:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiGridChallengeTab:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiGridChallengeTab:AutoInitUi()
    self.PanelTabUnSelect = self.Transform:Find("PanelTabUnSelect")
    self.ImgUnSelect = self.Transform:Find("PanelTabUnSelect/ImgUnSelect"):GetComponent("Image")
    self.TxtUnSelectTitle = self.Transform:Find("PanelTabUnSelect/TxtUnSelectTitle"):GetComponent("Text")
    self.PanelTabSelect = self.Transform:Find("PanelTabSelect")
    self.ImgSelect = self.Transform:Find("PanelTabSelect/ImgSelect"):GetComponent("Image")
    self.TxtSelectTitle = self.Transform:Find("PanelTabSelect/TxtSelectTitle"):GetComponent("Text")
    self.PanelTabLock = self.Transform:Find("PanelTabLock")
    self.ImgUnSelect = self.Transform:Find("PanelTabLock/ImgUnSelect"):GetComponent("Image")
    self.ImgLock = self.Transform:Find("PanelTabLock/ImgLock"):GetComponent("Image")
    self.TxtLockTitleA = self.Transform:Find("PanelTabLock/TxtLockTitle"):GetComponent("Text")
    self.ImgNewCheckPoint = self.Transform:Find("ImgNewCheckPoint"):GetComponent("Image")
end

function XUiGridChallengeTab:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiGridChallengeTab:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiGridChallengeTab:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiGridChallengeTab:AutoAddListener()
end
-- auto

function XUiGridChallengeTab:UpdateDefaultViews()
    self.PanelTabUnSelect.gameObject:SetActive(false)
    self.PanelTabSelect.gameObject:SetActive(true)
    self.PanelTabLock.gameObject:SetActive(false)
    self.ImgNewCheckPoint.gameObject:SetActive(false)
    self.TxtSelectTitle.text = CS.XTextManager.GetText("PrequelChallangeTab")
end

return XUiGridChallengeTab
