local XUiPlayerUp = XLuaUiManager.Register(XLuaUi, "UiPlayerUp")
local WAIT_CLOSE_TIME = 2

function XUiPlayerUp:OnAwake()
    self:InitAutoScript()
end

function XUiPlayerUp:OnStart(oldLevel, newLevel)
    self.OldLevel = oldLevel
    self.NewLevel = newLevel

    self:InitText()
    self.BtnClose.gameObject:SetActive(true)
    self.IsAnimating = true
    self.Timer = nil

    self:PlayAnimation("AniPlayerUpBegin", function()

        if XTool.UObjIsNil(self.BtnClose) then
            return
        end

        self.IsAnimating = false

        local time = 0
        self.Timer = CS.XScheduleManager.Schedule(function()
            if XTool.UObjIsNil(self.BtnClose) then
                return
            end

            time = time + 1
            if time >= WAIT_CLOSE_TIME and self.BtnClose.gameObject.activeInHierarchy then
                self:OnBtnCloseClick()
            end
        end, 1000, WAIT_CLOSE_TIME)
    end)
    -- XUiHelper.PlayAnimation(self, "AniPlayerUpBegin", nil, function()

    --     if XTool.UObjIsNil(self.BtnClose) then
    --         return
    --     end

    --     self.IsAnimating = false

    --     local time = 0
    --     self.Timer = CS.XScheduleManager.Schedule(function()
    --         if XTool.UObjIsNil(self.BtnClose) then
    --             return
    --         end

    --         time = time + 1
    --         if time >= WAIT_CLOSE_TIME and self.BtnClose.gameObject.activeInHierarchy then
    --             self:OnBtnCloseClick()
    --         end
    --     end, 1000, WAIT_CLOSE_TIME)
    -- end)
end

function XUiPlayerUp:OnEnable()
    CS.XAudioManager.PlaySound(XSoundManager.UiBasicsMusic.Common_UiPlayerUp)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPlayerUp:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiPlayerUp:AutoInitUi()
    self.TxtLv1 = self.Transform:Find("SafeAreaContentPane/PlayerUpPanel2/GameObject/TxtLv1"):GetComponent("Text")
    self.TxtLv2 = self.Transform:Find("SafeAreaContentPane/PlayerUpPanel2/GameObject/TxtLv2"):GetComponent("Text")
    self.ImgIcon = self.Transform:Find("SafeAreaContentPane/PlayerUpPanel2/GameObject1/ImgIcon"):GetComponent("Image")
    self.Txt1 = self.Transform:Find("SafeAreaContentPane/PlayerUpPanel2/GameObject1/Txt1"):GetComponent("Text")
    self.Txt2 = self.Transform:Find("SafeAreaContentPane/PlayerUpPanel2/GameObject1/Txt2"):GetComponent("Text")
    self.BtnClose = self.Transform:Find("SafeAreaContentPane/BtnClose"):GetComponent("Button")
end

function XUiPlayerUp:GetAutoKey(uiNode, eventName)
    if not uiNode then
        return
    end
    return eventName .. uiNode:GetHashCode()
end

function XUiPlayerUp:RegisterListener(uiNode, eventName, func)
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
            XLog.Error("XUiPlayerUp:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiPlayerUp:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterClickEvent(self.BtnClose, self.OnBtnCloseClick)
end
-- auto
function XUiPlayerUp:InitText()
    local addActionPoint = XPlayerManager.GetMaxActionPoint(self.NewLevel) - XPlayerManager.GetMaxActionPoint(self.OldLevel)
    local differenceGrade = self.NewLevel - self.OldLevel
    local num = 0
    for i = 1, differenceGrade do
        num = num + XPlayerManager.GetFreeActionPoint(self.OldLevel + i - 1)
    end
    self.Txt1.text = num
    self.Txt2.text = CS.XTextManager.GetText("LevelActionPoint", XPlayerManager.GetMaxActionPoint(self.OldLevel), addActionPoint)
    self.TxtLv1.text = self.OldLevel
    self.TxtLv2.text = self.NewLevel
end

function XUiPlayerUp:OnBtnCloseClick()

    if self.IsAnimating then
        return
    end

    self.IsAnimating = true

    local onEnd = function()
        if XTool.UObjIsNil(self.BtnClose) then
            return
        end
        self.IsAnimating = false

        if self.Timer ~= nil then
            CS.XScheduleManager.UnSchedule(self.Timer)
            self.Timer = nil
        end
        self:Close()
        XEventManager.DispatchEvent(XEventId.EVENT_PLAYER_LEVEL_UP_ANIMATION_END)
    end
    self:PlayAnimation("AniPlayerUpEnd", onEnd)
    --XUiHelper.PlayAnimation(self, "AniPlayerUpEnd", nil, onEnd)
end

function XUiPlayerUp:OnDestroy()
    if self.Timer ~= nil then
        CS.XScheduleManager.UnSchedule(self.Timer)
        self.Timer = nil
    end

    XTipManager.Execute()
end