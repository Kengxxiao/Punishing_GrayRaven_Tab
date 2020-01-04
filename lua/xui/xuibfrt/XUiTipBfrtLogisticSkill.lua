local ANIMATION_OPEN = "AniTipJudianBegin"
local ANIMATION_END = "AniTipJudianEnd"
local CLOSE_TIME = 3

local XUiTipBfrtLogisticSkill = XLuaUiManager.Register(XLuaUi, "UiTipBfrtLogisticSkill")

function XUiTipBfrtLogisticSkill:OnStart(groupId)
    self.CurShowIndex = 0
    self.LogisticsInfoIdList = XDataCenter.BfrtManager.GetLogisticsInfoIdList(groupId)
    self.TotalShowTimes = #self.LogisticsInfoIdList

    self:InitAutoScript()
    self:InitComponentState()
    self:UpdateView()
end

function XUiTipBfrtLogisticSkill:InitComponentState()

end

function XUiTipBfrtLogisticSkill:OnDestroy()
    self:ClearCloseTimer()
    self:ClearViewData()
end

function XUiTipBfrtLogisticSkill:ClearViewData()
    self.CurShowIndex = nil
    self.TotalShowTimes = nil
    self.LogisticsInfoIdList = {}
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiTipBfrtLogisticSkill:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiTipBfrtLogisticSkill:AutoInitUi()
    self.PanelTipBfrtLogisticSkill = self.Transform:Find("SafeAreaContentPane/PanelTipBfrtLogisticSkill")
    self.TxtEchelonIndex = self.Transform:Find("SafeAreaContentPane/PanelTipBfrtLogisticSkill/TxtEchelonIndex"):GetComponent("Text")
    self.TxtSkillDes = self.Transform:Find("SafeAreaContentPane/PanelTipBfrtLogisticSkill/TxtSkillDes"):GetComponent("Text")
end

function XUiTipBfrtLogisticSkill:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiTipBfrtLogisticSkill:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiTipBfrtLogisticSkill:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiTipBfrtLogisticSkill:AutoAddListener()
    self.AutoCreateListeners = {}
end
-- auto

function XUiTipBfrtLogisticSkill:UpdateView()
    self.CurShowIndex = self.CurShowIndex + 1
    if self.CurShowIndex > self.TotalShowTimes then
        self:Close()
        return
    end

    self:UpdatePanelDes()
    self:PlayBeginAnimation()
end

function XUiTipBfrtLogisticSkill:PlayBeginAnimation()
    local endCb = function()
        self:AddCloseTimer()
    end
    XUiHelper.PlayAnimation(self, ANIMATION_OPEN, nil, endCb)
end

function XUiTipBfrtLogisticSkill:AddCloseTimer()
    self:ClearCloseTimer()
    local time = 0
    local function action()
        time = time + 1
        if time == CLOSE_TIME then
            self:PlayEndAnimation()
        end
    end
    self.Timer = CS.XScheduleManager.Schedule(action, CS.XScheduleManager.SECOND, CLOSE_TIME, 0)
end

function XUiTipBfrtLogisticSkill:PlayEndAnimation()
    local endCb = function()
        self:UpdateView()
    end
    XUiHelper.PlayAnimation(self, ANIMATION_END, nil, endCb)
end

function XUiTipBfrtLogisticSkill:UpdatePanelDes()
    local echelonId = self.LogisticsInfoIdList[self.CurShowIndex]
    local logisticSkillDes = XDataCenter.BfrtManager.GetLogisticSkillDes(echelonId)
    self.TxtEchelonIndex.text = CS.XTextManager.GetText("BfrtLogisticEchelonTitle", self.CurShowIndex)
    self.TxtSkillDes.text = logisticSkillDes
end

function XUiTipBfrtLogisticSkill:ClearCloseTimer()
    if self.Timer then
        CS.XScheduleManager.UnSchedule(self.Timer)
        self.Timer = nil
    end
end
