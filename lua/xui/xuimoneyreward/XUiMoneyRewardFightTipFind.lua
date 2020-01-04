local XUiMoneyRewardFightTipFind = XLuaUiManager.Register(XLuaUi, "UiMoneyRewardFightTipFind")

function XUiMoneyRewardFightTipFind:OnAwake()
    self:InitAutoScript()
end

function XUiMoneyRewardFightTipFind:OnStart()
    XUiHelper.PlayAnimation(self, "FindBegan", nil, function()
        self:TryExitFight()
    end)
end

function XUiMoneyRewardFightTipFind:TryExitFight()
    self.Timer = CS.XScheduleManager.ScheduleForever(function()
        self:ExitFight()
    end, CS.XScheduleManager.SECOND, 0)
end

function XUiMoneyRewardFightTipFind:ExitFight()
    XDataCenter.FubenManager.ExitFight()
end

function XUiMoneyRewardFightTipFind:OnDestroy()
    CS.XScheduleManager.UnSchedule(self.Timer)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiMoneyRewardFightTipFind:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiMoneyRewardFightTipFind:AutoInitUi()
    self.PanelFind = self.Transform:Find("FullScreenBackground/PanelFind")
end

function XUiMoneyRewardFightTipFind:GetAutoKey(uiNode, eventName)
    if not uiNode then
        return
    end
    return eventName .. uiNode:GetHashCode()
end

function XUiMoneyRewardFightTipFind:RegisterListener(uiNode, eventName, func)
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
            XLog.Error("XUiMoneyRewardFightTipFind:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiMoneyRewardFightTipFind:AutoAddListener()
    self.AutoCreateListeners = {}
end
-- auto
