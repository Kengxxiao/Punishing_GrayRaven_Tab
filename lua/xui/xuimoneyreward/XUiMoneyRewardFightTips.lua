local XUiMoneyRewardFightTips = XLuaUiManager.Register(XLuaUi, "UiMoneyRewardFightTips")

function XUiMoneyRewardFightTips:OnAwake()
    self:InitAutoScript()
end

function XUiMoneyRewardFightTips:OnStart(stageId)

    local stageInfo = XDataCenter.FubenManager.GetStageInfo(stageId)
    local bountyInfo = XDataCenter.BountyTaskManager.GetBountyTaskConfig(stageInfo.BountyId)

    local rand = math.random(1, #bountyInfo.EnterAnimation)
    local animationName = ""
    if bountyInfo.EnterAnimation and bountyInfo.EnterAnimation ~= "" then
        animationName = bountyInfo.EnterAnimation[rand]
    end

    XUiHelper.PlayAnimation(self, animationName, nil, function()
        XDataCenter.FubenManager.ReadyToFight()
    end)

end

-- auto
-- Automatic generation of code, forbid to edit
function XUiMoneyRewardFightTips:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiMoneyRewardFightTips:AutoInitUi()
    self.BtnBg = self.Transform:Find("FullScreenBackground/BtnBg"):GetComponent("Button")
end

function XUiMoneyRewardFightTips:GetAutoKey(uiNode, eventName)
    if not uiNode then
        return
    end
    return eventName .. uiNode:GetHashCode()
end

function XUiMoneyRewardFightTips:RegisterListener(uiNode, eventName, func)
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
            XLog.Error("XUiMoneyRewardFightTips:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiMoneyRewardFightTips:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterListener(self.BtnBg, "onClick", self.OnBtnBgClick)
end
-- auto
function XUiMoneyRewardFightTips:OnBtnBgClick(...)
    -- if self.AnimationEnd == false then
    --     return
    -- end
    -- CS.XUiManager.ViewManager:Pop()
    -- XDataCenter.BountyTaskManager.EnterFight(self.FightResult)
end