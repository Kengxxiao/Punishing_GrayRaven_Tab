local XUiPanelTrialGet = XClass()

function XUiPanelTrialGet:Ctor(ui,uiroot)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.UiRoot = uiroot
    XTool.InitUiObject(self)
    self:InitScript()
end

function XUiPanelTrialGet:SetBtnCB(cb)
    self.BtnCb = cb
end

-- 处理特效和动画
function XUiPanelTrialGet:SetAnimationFx()
    self.FxUiPanelTrialGet01.gameObject:SetActive(true)
    self.timer = CS.XScheduleManager.Schedule(function()
        self.FxUiPanelTrialGet02.gameObject:SetActive(true)
        CS.XScheduleManager.UnSchedule(self.timer)
    end,0,1,200)
end

function XUiPanelTrialGet:InitScript()
    self:AddListener()
end


function XUiPanelTrialGet:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelTrialGet:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelTrialGet:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelTrialGet:AddListener()
    self:RegisterClickEvent(self.BtnClick, self.OnBtnClickClick)
end
-- auto

-- 设置背景
function XUiPanelTrialGet:SetBg(iconpath)
    if not iconpath then
        return
    end

    self.UiRoot:SetUiSprite(self.ImgWafer,iconpath)
end

function XUiPanelTrialGet:SetName(name)
    self.TxtName.text = name or ""
end

function XUiPanelTrialGet:OnBtnClickClick(eventData)
    if not self.BtnCb then 
        return 
    end
    self.BtnCb()
end

return XUiPanelTrialGet
