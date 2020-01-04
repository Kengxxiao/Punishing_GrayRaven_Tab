local XUiSettleLose = XLuaUiManager.Register(XLuaUi, "UiSettleLose")

function XUiSettleLose:OnAwake()
    self:InitAutoScript()
end

function XUiSettleLose:OnStart(settleData)
    local beginData = XDataCenter.FubenManager.GetFightBeginData()
    local stageInfo = XDataCenter.FubenManager.GetStageCfg(beginData.StageId)
    local count = 0
    for k, v in pairs(beginData.CharList) do
        if v ~= 0 then
            count = count + 1
        end
    end
    self.TxtPeople.text = CS.XTextManager.GetText("BattleLoseActorNum", count)
    self.TxtStageName.text = stageInfo.Name
end

function XUiSettleLose:OnEnable()
    XDataCenter.FunctionEventManager.UnLockFunctionEvent()
end

function XUiSettleLose:OnDestroy()
    XDataCenter.AntiAddictionManager.EndFightAction()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiSettleLose:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiSettleLose:AutoInitUi()
    self.BtnLose = self.Transform:Find("SafeAreaContentPane/PanelLose/BtnLose"):GetComponent("Button")
end

function XUiSettleLose:GetAutoKey(uiNode, eventName)
    if not uiNode then
        return
    end
    return eventName .. uiNode:GetHashCode()
end

function XUiSettleLose:RegisterListener(uiNode, eventName, func)
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
            XLog.Error("XUiSettleLose:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiSettleLose:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterListener(self.BtnLose, "onClick", self.OnBtnLoseClick)
end
-- auto
function XUiSettleLose:OnBtnLoseClick()
    --CS.XAudioManager.RemoveCueSheet(CS.XAudioManager.BATTLE_MUSIC_CUE_SHEET_ID)
    --CS.XAudioManager.PlayMusic(CS.XAudioManager.MAIN_BGM)
    if XDataCenter.ArenaManager.JudgeGotoMainWhenFightOver() then
        return
    end
    self:Close()
end