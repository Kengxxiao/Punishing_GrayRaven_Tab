XUiPanelSetBirthday = XClass()

function XUiPanelSetBirthday:Ctor(ui,base)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Base = base
    XTool.InitUiObject(self)
    self:InitAutoScript()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelSetBirthday:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiPanelSetBirthday:AutoInitUi()
    self.BtnBirSure = self.Transform:Find("BtnBirSure"):GetComponent("Button")
    self.BtnBirCancel = self.Transform:Find("BtnBirCancel"):GetComponent("Button")
    self.TxtB = self.Transform:Find("Txt"):GetComponent("Text")
    self.TxtMon = self.Transform:Find("InMon/TxtMon"):GetComponent("Text")
    self.TxtDay = self.Transform:Find("InDay/TxtDay"):GetComponent("Text")
end

function XUiPanelSetBirthday:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelSetBirthday:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelSetBirthday:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelSetBirthday:AutoAddListener()
    self:RegisterClickEvent(self.BtnBirSure, self.OnBtnBirSureClick)
    self:RegisterClickEvent(self.BtnBirCancel, self.OnBtnBirCancelClick)
    self.BtnClose.CallBack = function()
        self:OnBtnBirCancelClick()
    end
end
-- auto

function XUiPanelSetBirthday:OnBtnBirSureClick(...)
    local dayNum = 31
    local mon = tonumber(self.TxtMon.text)
    local day = tonumber(self.TxtDay.text)
    if not mon or not day then
        XUiManager.TipText("WrongDate",XUiManager.UiTipType.Wrong)
        return
    end

    if mon < 1 or mon > 12 then
        XUiManager.TipText("WrongDate",XUiManager.UiTipType.Wrong)
        return
    end
    
    if mon == 2 then
        dayNum = 29
    elseif mon == 4 or mon == 6 or mon == 9 or mon == 11 then
        dayNum = 30
    end

    if day < 1 or day > dayNum then
        XUiManager.TipText("WrongDate",XUiManager.UiTipType.Wrong)
        return
    end

    local currBir = XPlayer.Birthday
    if currBir then
        if (currBir.Mon and mon == currBir.Mon) and (currBir.Day and day == currBir.Day) then
            self.Base:HidePanelSetBirthday()
            return
        end
    end

    XPlayer.ChangeBirthday(mon, day, function()
        self.Base:ChangeBirthdayCallback()
    end)
end

function XUiPanelSetBirthday:OnBtnBirCancelClick(...)
    self.Base:HidePanelSetBirthday()
end

return XUiPanelSetBirthday
