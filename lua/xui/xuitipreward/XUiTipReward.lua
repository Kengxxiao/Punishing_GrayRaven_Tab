local XUiTipReward = XLuaUiManager.Register(XLuaUi, "UiTipReward")

function XUiTipReward:OnAwake()
    self:InitAutoScript()
    self:InitBtnSound()
end

function XUiTipReward:OnStart(rewardGoodsList, title, closecallback, surecallback)
    self.GridBagItemRecycle.gameObject:SetActive(false)
    self.Items = {}
    self.OkCallback = surecallback
    self.CancelCallback = closecallback
    self:Refresh(rewardGoodsList)
    CS.XAudioManager.PlaySound(XSoundManager.UiBasicsMusic.Tip_Big)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiTipReward:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiTipReward:AutoInitUi()
    self.BtnBg = self.Transform:Find("SafeAreaContentPane/BtnBg"):GetComponent("Button")
    self.BtnDetermine = self.Transform:Find("SafeAreaContentPane/BtnDetermine"):GetComponent("Button")
    self.PanelRecycle = self.Transform:Find("SafeAreaContentPane/ViewRecycle/Viewport/PanelRecycle")
    self.GridBagItemRecycle = self.Transform:Find("SafeAreaContentPane/ViewRecycle/Viewport/PanelRecycle/GridBagItemRecycle")
end

function XUiTipReward:GetAutoKey(uiNode, eventName)
    if not uiNode then
        return
    end
    return eventName .. uiNode:GetHashCode()
end

function XUiTipReward:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then
        return
    end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiTipReward:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiTipReward:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterListener(self.BtnBg, "onClick", self.OnBtnBgClick)
    self:RegisterListener(self.BtnDetermine, "onClick", self.OnBtnDetermineClick)
end
-- auto

--初始化音效

function XUiTipReward:InitBtnSound()
    self.SpecialSoundMap[self:GetAutoKey(self.BtnBg, "onClick")] = XSoundManager.UiBasicsMusic.Return
    self.SpecialSoundMap[self:GetAutoKey(self.BtnDetermine, "onClick")] = XSoundManager.UiBasicsMusic.Confirm
end

function XUiTipReward:OnBtnBgClick(...)
    --CS.XUiManager.ViewManager:Pop()
    self:Close()
    if self.CancelCallback then
        self.CancelCallback()
    end
end

function XUiTipReward:OnBtnDetermineClick(...)
    --CS.XUiManager.ViewManager:Pop()
    self:Close()
    if self.OkCallback then
        self.CancelCallback()
    end
end

function XUiTipReward:Refresh(rewardGoodsList)
    local onCreate = function(grid, data)
        grid:Refresh(data)
    end
    XUiHelper.CreateTemplates(self, self.Items, rewardGoodsList, XUiGridCommon.New, self.GridBagItemRecycle, self.PanelRecycle, onCreate)
end
