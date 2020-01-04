local XUiSignGridDay = XClass()

function XUiSignGridDay:Ctor(ui, rootUi)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    self.Grid = nil

    XTool.InitUiObject(self)
    self.PanelNext.gameObject:SetActive(false)
end

function XUiSignGridDay:Refresh(config, isShow, forceSetTormorrow)
    self.IsShow = isShow
    self.Config = config

    self.TxtDay.text = string.format("%02d", config.Pre)
    if not isShow or forceSetTormorrow then
        self:SetTomorrow()
    end

    local isAlreadyGet = XDataCenter.SignInManager.JudgeAlreadyGet(config.SignId, config.Round, config.Day)
    self.PanelHaveGroup.alpha = isAlreadyGet and 1 or 0
    self.PanelHaveReceive.gameObject:SetActive(isAlreadyGet)
    self:SetEffectActive(false)

    local rewardList = XRewardManager.GetRewardList(config.ShowRewardId)
    if not rewardList or #rewardList <= 0 then
        XEventManager.DispatchEvent(XEventId.EVENT_SING_IN_OPEN_BTN, true)
        return
    end

    if not self.Grid then
        self.Grid = XUiGridCommon.New(self.RootUi, self.GridCommon)
    end

    self.Grid:Refresh(rewardList[1])
    self.GameObject:SetActive(true)
    self:AnimaStart()
end

function XUiSignGridDay:SetTomorrow()
    local isTomorrow = XDataCenter.SignInManager.JudgeTomorrow(self.Config.SignId, self.Config.Round, self.Config.Day)
    self.PanelNext.gameObject:SetActive(isTomorrow)
end

function XUiSignGridDay:AnimaStart()
    if not self.IsShow then
        return
    end

    local isToday, isGet = XDataCenter.SignInManager.JudgeTodayGet(self.Config.SignId, self.Config.Round, self.Config.Day)
    if not isToday then
        return
    end

    if isToday and isGet then
        XEventManager.DispatchEvent(XEventId.EVENT_SING_IN_OPEN_BTN, true, self.Config)
        return
    end

    self:SetEffectActive(true)
    XDataCenter.SignInManager.SignInRequest(self.Config.SignId, function(rewardItems)
        self.PanelHaveGroup.alpha = 1
        self.PanelHaveReceive.gameObject:SetActive(true)
        self.GameObject:PlayTimelineAnimation(function()
            XUiManager.OpenUiObtain(rewardItems)
            self:SetEffectActive(false)
            XEventManager.DispatchEvent(XEventId.EVENT_SING_IN_OPEN_BTN, true, self.Config)
        end)
    end,
    function()
        self:SetEffectActive(false)
        XEventManager.DispatchEvent(XEventId.EVENT_SING_IN_OPEN_BTN, true)
    end)
end

function XUiSignGridDay:SetEffectActive(active)
    self.PanelEffect.gameObject:SetActive(active)
end

return XUiSignGridDay