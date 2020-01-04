XUiPanelPlayerExp = XClass()

function XUiPanelPlayerExp:Ctor(ui, base)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelPlayerExp:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiPanelPlayerExp:AutoInitUi()
    self.ImgExpCircle = self.Transform:Find("ImgExpCircle"):GetComponent("Image")
    self.ImgExpCircleFill1 = self.Transform:Find("ImgExpCircle/ImgExpCircleFill1"):GetComponent("Image")
    self.ImgExpCircleFill2 = self.Transform:Find("ImgExpCircle/ImgExpCircleFill2"):GetComponent("Image")
    self.ImgCircle1 = self.Transform:Find("ImgCircle1"):GetComponent("Image")
    self.TxtLevelNum = self.Transform:Find("TxtLevelNum"):GetComponent("Text")
    self.PanelExp = self.Transform:Find("PanelExp")
    self.TxtExpNum = self.Transform:Find("PanelExp/TxtExpNum"):GetComponent("Text")
end

function XUiPanelPlayerExp:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelPlayerExp:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelPlayerExp:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelPlayerExp:AutoAddListener()
end
-- auto

function XUiPanelPlayerExp:UpdatePlayerLevelInfo()
    local curExp = XPlayer.Exp
    local maxExp= XPlayerManager.GetMaxExp(XPlayer.Level)
    local fillAmount = curExp / maxExp
    XUiHelper.Tween(1, function(f)  
        if XTool.UObjIsNil(self.Transform) then
            return
        end
        
        local fill = math.floor(f * curExp)
        
        self.ImgExpCircleFill1.fillAmount=fill / maxExp
        self.ImgExpCircleFill2.fillAmount=fill / maxExp
    end)

    self.ImgExpCircle.fillAmount=1.0-fillAmount
    self.TxtLevelNum.text=XPlayer.Level
    self.TxtExpNum.text="<color=#0e70bd><size=47>" .. curExp .. "</size></color>" .. "/" ..maxExp
end
