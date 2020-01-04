XUiPanelSetName = XClass()
local MaxNameLength = CS.XGame.ClientConfig:GetInt("MaxNameLength")

function XUiPanelSetName:Ctor(ui, base)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Base = base
    XTool.InitUiObject(self)
    self:InitAutoScript()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelSetName:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiPanelSetName:AutoInitUi()
    self.TxtA = self.Transform:Find("Txt"):GetComponent("Text")
    self.BtnNameSure = self.Transform:Find("BtnNameSure"):GetComponent("Button")
    self.BtnNameCancel = self.Transform:Find("BtnNameCancel"):GetComponent("Button")
    self.InFSigmA = self.Transform:Find("InFSigm"):GetComponent("InputField")
    self.TxtName = self.Transform:Find("InFSigm/Text"):GetComponent("Text")
end

function XUiPanelSetName:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelSetName:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelSetName:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelSetName:AutoAddListener()
    self:RegisterClickEvent(self.BtnNameSure, self.OnBtnNameSureClick)
    self:RegisterClickEvent(self.BtnNameCancel, self.OnBtnNameCancelClick)
    self.BtnClose.CallBack = function()
        self:OnBtnNameCancelClick()
    end
end
-- auto

function XUiPanelSetName:OnBtnNameCancelClick(...)
    self.Base:HidePanelSetName()
end

function XUiPanelSetName:OnBtnNameSureClick(...)
    local editName = self:trim(self.InFSigmA.text)
    if string.len(editName) > 0 then
        local utf8Count = self.InFSigmA.textComponent.cachedTextGenerator.characterCount - 1
        if utf8Count > MaxNameLength then
            XUiManager.TipError(CS.XTextManager.GetText("MaxNameLengthTips", MaxNameLength))
            return
        end
        XPlayer.ChangeName(editName, function()
            self.Base:ChangeNameCallback()
        end)
    else
        XUiManager.TipError(CS.XTextManager.GetText("RenameLengthError"))
    end
end

function XUiPanelSetName:RefreshLimit()
    self.InFSigmA.text = XPlayer.Name
    if not XPlayer.ChangeNameTime then return end
    local nextCanChangeTime = XPlayer.ChangeNameTime + XPlayerManager.PlayerChangeNameInterval
    local timeLimit = nextCanChangeTime - XTime.Now()
    local hour = math.floor(timeLimit / 3600)
    local minute = math.ceil(timeLimit % 3600 / 60)
    if timeLimit > 0 then
        if minute > 0 then
            self.TxtCoolTip.text = CS.XTextManager.GetText("ChangeNameLimitHourMin", hour, minute)
        else
            self.TxtCoolTip.text = CS.XTextManager.GetText("ChangeNameLimitHour", hour)
        end
    else
        self.TxtCoolTip.text = ""
    end
end

function XUiPanelSetName:trim(s)
    return (string.gsub(s, "^%s*(.-)%s*$", "%1")) 
end
