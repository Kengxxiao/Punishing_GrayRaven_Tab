local XUiMissionCompleted = XLuaUiManager.Register(XLuaUi, "UiMissionCompleted")
local XUiPanelRewardSmall = require("XUi/XUiMission/XUiPanelRewardSmall")
local XUiPanelRewardBig = require("XUi/XUiMission/XUiPanelRewardBig")

function XUiMissionCompleted:OnAwake()
    self:InitAutoScript()
end

function XUiMissionCompleted:OnStart(reslut, characterId)

    self.IsAnimation = true
    self.RewardSmallPanel = XUiPanelRewardSmall.New(self.PanelRewardSmall, self)
    self.RewardBigPanel = XUiPanelRewardBig.New(self.PanelRewardBig, self)

    self.MissionResult = reslut
    self.CharacterId = characterId
    self.GridList = {}
    self:SetupMissionCompleted()

    if not self.MissionResult then
        return
    end

    if self.MissionResult.IsBigReward then
        self:PlayAnimation("AniMissionRewardBigBegin", function()
            self.IsAnimation = false
        end)
        -- XUiHelper.PlayAnimation(self, "AniMissionRewardBigBegin",nil,function()
        --     self.IsAnimation = false
        -- end)
    else
        self:PlayAnimation("AniMissionRewardSmallBegin", function()
            self.IsAnimation = false
        end)
        -- XUiHelper.PlayAnimation(self, "AniMissionRewardSmallBegin",nil,function()
        --     self.IsAnimation = false
        -- end)
    end


end

function XUiMissionCompleted:SetupMissionCompleted()
    if not self.MissionResult then
        return
    end

    local isBigReward = self.MissionResult.IsBigReward
    --self.PanelDesc.gameObject:SetActive(false)
    --self.PanelBg.gameObject:SetActive(not isBigReward)
    self.PanelRewardSmall.gameObject:SetActive(not isBigReward)
    self.PanelRewardBig.gameObject:SetActive(isBigReward)

    local rewards = self.MissionResult

    if not rewards then
        return
    end

    if isBigReward then
        self.RewardBigPanel:SetupCharacter(self.CharacterId)
        self.RewardBigPanel:SetupReward(rewards)
    else
        self.RewardSmallPanel:SetupReward(rewards)
    end

end

-- auto
-- Automatic generation of code, forbid to edit
function XUiMissionCompleted:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiMissionCompleted:AutoInitUi()
    -- self.PanelRewardBig = self.Transform:Find("FullScreenBackground/PanelRewardBig")
    -- self.PanelRewardSmall = self.Transform:Find("FullScreenBackground/PanelRewardSmall")
    -- self.BtnBg = self.Transform:Find("FullScreenBackground/BtnBg"):GetComponent("Button")
end

function XUiMissionCompleted:GetAutoKey(uiNode, eventName)
    if not uiNode then
        return
    end
    return eventName .. uiNode:GetHashCode()
end

function XUiMissionCompleted:RegisterListener(uiNode, eventName, func)
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
            XLog.Error("XUiMissionCompleted:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiMissionCompleted:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterClickEvent(self.BtnBg, self.OnBtnBgClick)
end
-- auto
function XUiMissionCompleted:OnBtnBgClick(...)

    if self.IsAnimation then
        return
    end

    if self.MissionResult.IsBigReward then
        self:PlayAnimation("AniMissionRewardBigEnd", function()
            --CS.XUiManager.ViewManager:Pop()
            self:Close()
        end)
        -- XUiHelper.PlayAnimation(self, "AniMissionRewardBigEnd", nil, function()
        --     --CS.XUiManager.ViewManager:Pop()
        --     self:Close()
        -- end)
    else
        self:PlayAnimation("AniMissionRewardSmallEnd", function()
            --CS.XUiManager.ViewManager:Pop()
            self:Close()
        end)
        -- XUiHelper.PlayAnimation(self, "AniMissionRewardSmallEnd", nil, function()
        --     --CS.XUiManager.ViewManager:Pop()
        --     self:Close()
        -- end)
    end


end