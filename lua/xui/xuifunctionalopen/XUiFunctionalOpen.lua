local XUiFunctionalOpen = XLuaUiManager.Register(XLuaUi, "UiFunctionalOpen")

local Type = { Normal = 1, Medal = 2 }

function XUiFunctionalOpen:OnAwake()
    self:InitAutoScript()
    self.BtnClear.gameObject:SetActiveEx(false)
    self.TxtTalk.text = ""
end

function XUiFunctionalOpen:OnStart(actionList)
    self:RemovePresentTimer()
    self:RefreshTime()
    self.Transform:PlayLegacyAnimation("ComOpen", function()
        self:SetupContent(actionList)
    end)
    self.IsEnd = false
    self:OffButton()
end

function XUiFunctionalOpen:OnEnable()
    CS.XAudioManager.PlaySound(XSoundManager.UiBasicsMusic.Common_UiFunctionalOpen)
end

function XUiFunctionalOpen:SetupContent(actionList)
    self.Transform:PlayLegacyAnimation("ComLoop")
    self.Content = 1
    self.Index = 1
    self.CanClick = true
    self.CurCharIndex = 0
    self.Interval = 0.5
    self.Timer = nil
    self.ActionList = actionList


    if self.ActionList.BtnContent then
        self.TextBtnClear.text = self.ActionList.BtnContent
    end

    if self.ActionList.NpcHandIcon then
        self:SetUiSprite(self.ImgNpcHand, self.ActionList.NpcHandIcon)
    end

    if self.ActionList.NpcHalfIcon then
        self:SetUiSprite(self.ImgNpcHalf, self.ActionList.NpcHalfIcon)
    end

    self.TxtNameHalf.text = self.ActionList.NpcName
    self.TxtTalk.text = ""
    self:Init()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiFunctionalOpen:InitAutoScript()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiFunctionalOpen:GetAutoKey(uiNode, eventName)
    if not uiNode then
        return
    end
    return eventName .. uiNode:GetHashCode()
end

function XUiFunctionalOpen:RegisterListener(uiNode, eventName, func)
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
            XLog.Error("XUiFunctionalOpen:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiFunctionalOpen:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterClickEvent(self.BtnOpenCommunication, self.OnBtnOpenCommunicationClick)
    self:RegisterClickEvent(self.BtnRefuse, self.OnBtnRefuseClick)
    self:RegisterClickEvent(self.BtnOpenCommunicationOfMedal, self.OnBtnOpenCommunicationClick)
    self:RegisterClickEvent(self.BtnRefuseOfMedal, self.OnBtnRefuseClick)
    self:RegisterClickEvent(self.BtnDirty, self.OnBtnDirtyClick)
    self:RegisterClickEvent(self.BtnClear, self.OnBtnClearClick)
    self:RegisterClickEvent(self.BtnInputOn, self.OnBtnInputOnClick)
    self:RegisterClickEvent(self.BtnOnAction, self.OnBtnOnActionClick)
end
-- auto
function XUiFunctionalOpen:OnBtnDirtyClick(...)

end

function XUiFunctionalOpen:RemoveListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    local listener = self.AutoCreateListeners[key]
    if not key then
        return
    end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end
end

function XUiFunctionalOpen:OnBtnOnActionClick(...)
    self.BtnOnAction.gameObject:SetActiveEx(false)
    self.BtnInputOn.gameObject:SetActiveEx(true)
    self.PanelHintCommunication.gameObject:SetActiveEx(false)
    self.PanelHintAction.gameObject:SetActiveEx(true)
    self.BtnClear.gameObject:SetActiveEx(false)
    local onEnd = function()
        XUiHelper.StopAnimation()

        self:PlayAnimation("TongxinLoop")
        --XUiHelper.PlayAnimation(self, "TongxinLoop", nil, nil)
        self.Content = self.Content - 1
        self.CurrCharTab = string.CharsConvertToCharTab(self.ActionList.Repulse)
        local interval = math.floor(self.Interval * 1000 / #self.CurrCharTab)
        self.Timer = CS.XScheduleManager.Schedule(function(...)
            self:PlayDialog(...)
        end, interval, #self.CurrCharTab + 2, 0)
    end
    XUiHelper.StopAnimation()

    self:PlayAnimation("TongxinBegan", onEnd)
    --XUiHelper.PlayAnimation(self, "TongxinBegan", nil, onEnd)
end

function XUiFunctionalOpen:OnBtnOpenCommunicationClick(...)
    local onEnd = function()
        XUiHelper.StopAnimation()
        self:PlayAnimation("TongxinLoop")
        --XUiHelper.PlayAnimation(self, "TongxinLoop", nil, nil)
        self:HintActionInit()
    end
    self.PanelHintCommunication.gameObject:SetActiveEx(false)
    self.BtnOnAction.gameObject:SetActiveEx(false)
    self.BtnInputOn.gameObject:SetActiveEx(true)
    self.PanelHintAction.gameObject:SetActiveEx(true)
    self.BtnClear.gameObject:SetActiveEx(false)
    XUiHelper.StopAnimation()

    self:PlayAnimation("TongxinBegan", onEnd)
    --XUiHelper.PlayAnimation(self, "TongxinBegan", nil, onEnd)
end

function XUiFunctionalOpen:OnBtnRefuseClick(...)
    -- local onEnd = function()
    --     self.PanelHintCommunication.gameObject:SetActiveEx(false)
    --     self.BtnOnAction.gameObject:SetActiveEx(true)
    --     XTipManager.Execute()
    -- end
    -- XUiHelper.StopAnimation()
    self:OnBtnClearClick()
    -- XUiHelper.PlayAnimation(self, "ComRefuse", nil, onEnd)
end

function XUiFunctionalOpen:OnBtnNoobClick(...)

end

function XUiFunctionalOpen:OnBtnClearClick(...)
    if self.IsEnd then
        return
    end

    local data = XDataCenter.CommunicationManager.GetNextCommunication(self.ActionList.Type)
    XUiHelper.StopAnimation()

    if data then
        local onEnd = function()
            self:SetupContent(data)
        end
        self.ImgNpcHand.gameObject:SetActiveEx(false)
        self:PlayAnimation("ComOpen", onEnd)
        --XUiHelper.PlayAnimation(self, "ComOpen", nil, onEnd)
        self:OffButton()
    else
        local onEnd = function()
            self.Content = 1
            self:RemovePresentTimer()
            self:RemoveTimer()
            self:RemoveListener(self.BtnOpenCommunication, "onClick", self.OnBtnOpenCommunicationClick)
            self:RemoveListener(self.BtnRefuse, "onClick", self.OnBtnRefuseClick)
            self:RemoveListener(self.BtnClear, "onClick", self.OnBtnClearClick)
            self:RemoveListener(self.BtnInputOn, "onClick", self.OnBtnInputOnClick)
            self:RemoveListener(self.BtnOnAction, "onClick", self.OnBtnOnActionClick)

            local actionType = self.ActionList.Type
            local axtionSkipId = self.ActionList.SkipId

            XTipManager.Execute()

            self.PanelHintCommunication.gameObject:SetActiveEx(false)
            self.PanelHintAction.gameObject:SetActiveEx(false)
            XDataCenter.CommunicationManager.SetCommunicating(false)

            self:Close()


            if axtionSkipId then
                XFunctionManager.SkipInterface(axtionSkipId)
            end

            if actionType == XDataCenter.CommunicationManager.Type.Love then
                XEventManager.DispatchEvent(XEventId.EVENT_LOVE_COMMUNICATE_FUNCTION_EVENT_END)
            elseif actionType ~= XDataCenter.CommunicationManager.Type.Medal then
                XEventManager.DispatchEvent(XEventId.EVENT_FUNCTION_EVENT_COMPLETE)
            end

        end

        self:PlayAnimation("TongxinClose", onEnd)
        --XUiHelper.PlayAnimation(self, "TongxinClose", nil, onEnd)
        self.IsEnd = true
    end
end

function XUiFunctionalOpen:OnBtnInputOnClick(...)
    if self.Timer then
        CS.XScheduleManager.UnSchedule(self.Timer)
        self.Timer = nil
        self.TxtTalk.text = ""
        self.TxtTalk.text = table.concat(self.CurrCharTab)
        self.CurCharIndex = 0
        self:TypewritingFinish()
    else
        self:RemoveTimer()
        self.Content = self.Content + 1
        self:Typewriting()
    end
end

function XUiFunctionalOpen:Init()
    self.TxtNameHand.text = self.ActionList.NpcName
    self:SetUiSprite(self.ImgNpcHand, self.ActionList.NpcHandIcon)
    self.ImgNpcHand.gameObject:SetActiveEx(true)
    self.PanelHintCommunication.gameObject:SetActiveEx(true)
    self.PanelHintAction.gameObject:SetActiveEx(false)
    if self.ActionList.Type == Type.Normal then
        self.BtnOpenCommunication.gameObject:SetActiveEx(true)
        self.BtnOpenCommunicationOfMedal.gameObject:SetActiveEx(false)
        self.BtnRefuse.gameObject:SetActiveEx(true)
        self.BtnRefuseOfMedal.gameObject:SetActiveEx(false)
    else
        self.BtnOpenCommunication.gameObject:SetActiveEx(false)
        self.BtnOpenCommunicationOfMedal.gameObject:SetActiveEx(true)
        self.BtnRefuse.gameObject:SetActiveEx(false)
        self.BtnRefuseOfMedal.gameObject:SetActiveEx(true)
    end
end

function XUiFunctionalOpen:OffButton()
    self.BtnOpenCommunication.gameObject:SetActiveEx(false)
    self.BtnOpenCommunicationOfMedal.gameObject:SetActiveEx(false)
    self.BtnRefuse.gameObject:SetActiveEx(false)
    self.BtnRefuseOfMedal.gameObject:SetActiveEx(false)
end

function XUiFunctionalOpen:HintActionInit()
    self:Typewriting()
end

function XUiFunctionalOpen:Typewriting()
    self:RemoveTimer()
    self.TxtTalk.text = ""
    local content = self.ActionList.Contents[self.Content]

    local temp = string.gsub(content, CS.XGame.ClientConfig:GetString("CommunicateReplaceStr"), XPlayer.Name)

    self.CurrCharTab = {}
    if temp and type(temp) == "string" then
        self.CurrCharTab = string.CharsConvertToCharTab(temp)
    end

    local interval = math.floor(self.Interval * 1000 / #self.CurrCharTab)
    self.Timer = CS.XScheduleManager.Schedule(function(...)
        self:PlayDialog(...)
    end, interval, #self.CurrCharTab + 2, 0)
end

function XUiFunctionalOpen:TypewritingFinish()
    if self.Content >= #self.ActionList.Contents then
        self.BtnInputOn.gameObject:SetActiveEx(false)
        self.Content = 1
        self.CanClick = true
        self.BtnClear.gameObject:SetActiveEx(true)
    end
end

function XUiFunctionalOpen:RefreshTime()
    local refreshFunc = function(...)
        if XTool.UObjIsNil(self.GameObject) then
            return
        end
        self.getTime = XTime.TimestampToGameDateTimeString(XTime.GetServerNowTimestamp(), "HH:mm:ss")
        self.TxtTimeHand.text = self.getTime
        self.TxtTimeHalf.text = self.getTime
    end
    refreshFunc()
    self.PresentTimer = CS.XScheduleManager.ScheduleForever(refreshFunc, 1000, 0)
end

function XUiFunctionalOpen:PlayDialog(timer)
    if not timer or self.Timer == nil then
        return
    end
    if self.CurCharIndex + 1 > #self.CurrCharTab then
        self.CurCharIndex = 0
        self:RemoveTimer()
        if Content ~= 1 then
            self:TypewritingFinish()
        end
        return
    end

    -- if not self.TxtTalk then
    --     return
    -- end
    self.CurCharIndex = self.CurCharIndex + 1
    self.TxtTalk.text = self.TxtTalk.text .. self.CurrCharTab[self.CurCharIndex]
end

function XUiFunctionalOpen:RemoveTimer()
    if self.Timer then
        CS.XScheduleManager.UnSchedule(self.Timer)
        self.Timer = nil
    end
end

function XUiFunctionalOpen:RemovePresentTimer()
    if self.PresentTimer then
        CS.XScheduleManager.UnSchedule(self.PresentTimer)
        self.PresentTimer = nil
    end
end

function XUiFunctionalOpen:OnDestroy()
end