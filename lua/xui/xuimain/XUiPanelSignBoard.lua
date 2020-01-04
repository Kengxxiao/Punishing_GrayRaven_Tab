XUiPanelSignBoard = XClass()

XUiPanelSignBoard.SignBoardOpenType = {
    MAIN = 1,
    FAVOR = 2
}

function XUiPanelSignBoard:Ctor(ui, parent, openType)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
    self.Parent = parent
    self.OpenType = openType

    self.ClickTrigger = true
    self.CanBreakTrigger = false

    self.OperateTrigger = true
    self.DialogTrigger = true
    self.CvTrigger = true


    self:InitAutoScript()
    self:Init()
end

function XUiPanelSignBoard:Init()

    --模型
    self.RoleModel = XUiPanelRoleModel.New(self.Parent:GetSceneRoot().transform:FindTransform("UiModelParent"), self.Parent.Name, true, false, false)

    self.DisplayCharacterId = -1
    self.AutoPlay = true
    --播放器
    local signBoardPlayer = require("XCommon/XSignBoardPlayer").New(self, CS.XGame.ClientConfig:GetInt("SignBoardPlayInterval"), CS.XGame.ClientConfig:GetFloat("SignBoardDelayInterval"))
    local playerData = XDataCenter.SignBoardManager.GetSignBoardPlayerData()
    signBoardPlayer:SetPlayerData(playerData)
    self.SignBoardPlayer = signBoardPlayer

    local multClickHelper = require("XUi/XUiCommon/XUiMultClickHelper").New(self, CS.XGame.ClientConfig:GetFloat("SignBoardClickInterval"), CS.XGame.ClientConfig:GetInt("SignBoardMultClickCountLimit"))
    self.MultClickHelper = multClickHelper
    self.PanelLayout.gameObject:SetActive(false)

    --用于驱动播放器和连点检测
    self.Timer = CS.XScheduleManager.ScheduleForever(function()
        self:Update()
    end, 0)

    --事件
    CsXGameEventManager.Instance:RegisterEvent(XEventId.EVENT_FIGHT_RESULT, handler(self, self.OnNotify))
    CsXGameEventManager.Instance:RegisterEvent(XEventId.EVENT_FAVORABILITY_GIFT, handler(self, self.OnNotify))

end

function XUiPanelSignBoard:SetDisplayCharacterId(displayCharacterId)
    self.DisplayCharacterId = displayCharacterId
    self.IdleTab = XSignBoardConfigs.GetSignBoardConfigByRoldIdAndCondition(self.DisplayCharacterId, XSignBoardEventType.IDLE)
end

function XUiPanelSignBoard:RefreshCharModel()
    self.DisplayState = XDataCenter.DisplayManager.UpdateRoleModel(self.RoleModel, self.DisplayCharacterId)
end

function XUiPanelSignBoard:RefreshCharacterModelById(templateId)
    XDataCenter.DisplayManager.UpdateRoleModel(self.RoleModel, templateId)
end

function XUiPanelSignBoard:OnNotify(event, ...)
    XDataCenter.SignBoardManager.OnNotify(event, ...)
end

function XUiPanelSignBoard:ResetPlayList()

    local playList = XDataCenter.SignBoardManager.GetPlayElements(self.DisplayCharacterId)
    if not playList then
        return
    end

    self.SignBoardPlayer:SetPlayList(playList)
end

function XUiPanelSignBoard:OnEnable()
    self:RefreshCharModel()

    if self.SignBoardPlayer then
        self.SignBoardPlayer:OnEnable()
    end

    if self.MultClickHelper then
        self.MultClickHelper:OnEnable()
    end

    local playList = XDataCenter.SignBoardManager.GetPlayElements(self.DisplayCharacterId)
    if not playList then
        return
    end

    self.SignBoardPlayer:SetPlayList(playList)

    self.Enable = true
end

function XUiPanelSignBoard:OnDisable()
    if self.SignBoardPlayer then
        self.SignBoardPlayer:OnDisable()
    end

    if self.MultClickHelper then
        self.MultClickHelper:OnDisable()
    end

    if self.PlayingCv then
        self.PlayingCv:Stop()
        self.PlayingCv = nil
    end

    self.Enable = false
end

function XUiPanelSignBoard:OnDestroy()
    if self.Timer ~= nil then
        CS.XScheduleManager.UnSchedule(self.Timer)
        self.Timer = nil
    end

    if self.SignBoardPlayer then
        self.SignBoardPlayer:OnDestroy()
    end

    if self.MultClickHelper then
        self.MultClickHelper:OnDestroy()
    end

    self.Enable = false
end

function XUiPanelSignBoard:Update()
    if not self.Enable then
        return
    end

    local dt = CS.UnityEngine.Time.deltaTime
    if self.SignBoardPlayer then
        self.SignBoardPlayer:Update(dt)
    end

    if self.IdleTab and self.IdleTab[1] and self.SignBoardPlayer.Status == 0 and self.SignBoardPlayer.LastPlayTime > 0 and XTime.Now() - self.SignBoardPlayer.LastPlayTime >= CS.XGame.ClientConfig:GetInt("SignBoardWaitInterval") and self.AutoPlay then
        self.SignBoardPlayer:ForcePlay(self.IdleTab[1])
        self.SignBoardPlayer.LastPlayTime = -1
        self.CanBreakTrigger = true
    end


    if self.MultClickHelper then
        self.MultClickHelper:Update(dt)
    end
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelSignBoard:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiPanelSignBoard:AutoInitUi()
    --self.BtnRole = self.Transform:Find("BtnRole"):GetComponent("Button")
    self.PanelDisplay = self.Transform:Find("PanelDisplay")
    self.PanelLayout = self.Transform:Find("PanelLayout")
    self.PanelChat = self.Transform:Find("PanelLayout/PanelChat")
    self.TxtContent = self.Transform:Find("PanelLayout/PanelChat/Image/TxtContent"):GetComponent("Text")
    self.PanelOpration = self.Transform:Find("PanelLayout/PanelOpration")
    self.BtnReplace = self.Transform:Find("PanelLayout/PanelOpration/BtnReplace"):GetComponent("Button")
    self.BtnCoating = self.Transform:Find("PanelLayout/PanelOpration/BtnCoating"):GetComponent("Button")
    self.BtnCommunication = self.Transform:Find("PanelLayout/PanelOpration/BtnCommunication"):GetComponent("Button")
end

function XUiPanelSignBoard:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelSignBoard:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelSignBoard:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelSignBoard:AutoAddListener()
    self:RegisterClickEvent(self.BtnRole, self.OnBtnRoleClick)
    self:RegisterClickEvent(self.BtnReplace, self.OnBtnReplaceClick)
    self:RegisterClickEvent(self.BtnCoating, self.OnBtnCoatingClick)
    self:RegisterClickEvent(self.BtnCommunication, self.OnBtnCommunicationClick)
end
-- auto
function XUiPanelSignBoard:OnBtnReplaceClick(eventData)
    self.SignBoardPlayer:Stop()
    XLuaUiManager.Open("UiFavorabilityLineRoomCharacter")
end

function XUiPanelSignBoard:OnBtnCoatingClick(eventData)
    self.SignBoardPlayer:Stop()
    XLuaUiManager.Open("UiFashion", self.DisplayCharacterId)
end

function XUiPanelSignBoard:OnBtnCommunicationClick(eventData)
    self.PanelLayout.gameObject:SetActive(false)
    XLuaUiManager.Open("UiFavorability")
end

--播放
function XUiPanelSignBoard:Play(element)
    if not element then
        return
    end

    if element.SignBoardConfig.Content then
        self.TxtContent.text = element.SignBoardConfig.Content
    end

    self:ShowNormalContent(element.SignBoardConfig.Content ~= nil and self.DialogTrigger)
    self.PanelOpration.gameObject:SetActive(element.SignBoardConfig.ShowButton ~= nil and self.OperateTrigger)

    --self.BtnPhoto.gameObject:SetActive(false)
    --self.BtnInteractive.gameObject:SetActive(false)
    -- self.BtnActivity.gameObject:SetActive(false)
    -- if element.SignBoardConfig.ShowButton ~= nil then
    --     local btnIds = string.Split(element.SignBoardConfig.ShowButton, "|")
    --     if btnIds and #btnIds > 0 then
    --         for i, v in ipairs(btnIds) do
    --             if v == "1" then
    --                 self.BtnPhoto.gameObject:SetActive(not self.DisplayPanel.IsShow and self.OpenType == XUiPanelSignBoard.SignBoardOpenType.MAIN)
    --             end
    --             if v == "2" then
    --                 self.BtnInteractive.gameObject:SetActive(self.OpenType == XUiPanelSignBoard.SignBoardOpenType.MAIN)
    --             end
    --             if v == "3" then
    --                 self.BtnActivity.gameObject:SetActive(true)
    --             end
    --         end
    --     end
    -- end
    if element.SignBoardConfig.CvId and element.SignBoardConfig.CvId > 0 and self.CvTrigger then
        self:PlayCv(element.SignBoardConfig.CvId)
    end

    local actionId = element.SignBoardConfig.ActionId
    if actionId then
        self:PlayAnima(actionId)
    end

    if self.OpenType == XUiPanelSignBoard.SignBoardOpenType.MAIN then
        self.Parent:PlayAnimation("AnimOprationBegan")
    end
end

--显示对白
function XUiPanelSignBoard:ShowNormalContent(show)
    self.PanelLayout.gameObject:SetActive(show)
end


--显示操作按钮
function XUiPanelSignBoard:ShowOprationBtn()
    self.PanelOpration.gameObject:SetActive(self.OperateTrigger)
end

--显示对白
function XUiPanelSignBoard:ShowContent(content)
    self.PanelLayout.gameObject:SetActive(content ~= nil)
    self.TxtContent.text = content
end

--播放CV
function XUiPanelSignBoard:PlayCv(cvId)
    self.PlayingCv = CS.XAudioManager.PlayCv(cvId)
end

--播放动作
function XUiPanelSignBoard:PlayAnima(actionId)
    self.RoleModel:PlayAnima(actionId)
end

--暂停
function XUiPanelSignBoard:Pause()
    if self.SignBoardPlayer then
        self.SignBoardPlayer:Pause()
    end
end

--恢复播放
function XUiPanelSignBoard:Resume()
    if self.SignBoardPlayer then
        self.SignBoardPlayer:Resume()
    end
end

--停止
function XUiPanelSignBoard:Stop()
    if self.OpenType == XUiPanelSignBoard.SignBoardOpenType.MAIN then
        if not self.Parent.GameObject.activeSelf then return end
        self.Parent:PlayAnimation("AnimOprationEnd")
    end

    self:ShowNormalContent(false)
end

--点击
function XUiPanelSignBoard:OnBtnRoleClick(eventData)
    if self.ClickTrigger then
        self.MultClickHelper:Click()
    end
end

--强制播放
function XUiPanelSignBoard:ForcePlay(playId)
    local config = XSignBoardConfigs.GetSignBoardConfigById(playId)
    self.SignBoardPlayer:ForcePlay(config)
end

function XUiPanelSignBoard:IsPlaying()
    return self.SignBoardPlayer:IsPlaying()
end

--多点回调
function XUiPanelSignBoard:OnMultClick(clickTimes)

    local config = nil
    if self.SignBoardPlayer:IsPlaying() and not self.CanBreakTrigger then
        return
    end

    self.CanBreakTrigger = false

    config = XDataCenter.SignBoardManager.GetRandomPlayElementsByClick(clickTimes, self.DisplayCharacterId)
    self.SignBoardPlayer:ForcePlay(config)
end

--设置自动播放
function XUiPanelSignBoard:SetAutoPlay(bAutoPlay)
    self.AutoPlay = bAutoPlay
    self.SignBoardPlayer:SetAutoPlay(bAutoPlay)
end

--操作开关
function XUiPanelSignBoard:SetOperateTrigger(bTriggeer)
    self.OperateTrigger = bTriggeer
    if not bTriggeer then
        self.PanelOpration.gameObject:SetActive(false)
    end
end

--对话开关
function XUiPanelSignBoard:SetDialogTrigger(bTriggeer)
    self.DialogTrigger = bTriggeer
    if not bTriggeer then
        self.PanelLayout.gameObject:SetActive(false)
    end
end


return XUiPanelSignBoard